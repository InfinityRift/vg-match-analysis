
# Queries supported by the server

Important globals.

    vainglory = require 'vainglory'
    key = process.env.VG_API_KEY
    vg = new vainglory key
    utils = require './harvesters/utils'

## Fetch recent matches for player

Fetch all recent matches for the given player in the given region.  The
parameters are in the form of an options object with these attributes.
Right now, only ranked mode is used on this server.

 * `ign` - player's in-game name, required, case sensitive
 * `region` - lower-case string of region name, such as na or sea
   (defaults to na)
 * `howRecent` - how old (time before now) should we look for matches
   (in milliseconds, defaults to one day, `24*60*60*1000`)
 * `offset` - matches are returned in pages of 50, and you can page through
   them by calling this routine again with offsets of 50, 100, etc.
   (default is zero)
 * `pageSize` - defaults to 50, used when paging; if you change it, then
   `offset` should be supplied in multiples of the new value you provide


    exports.recentMatchesForPlayer = ( options, callback ) ->
        try
            options.region ?= 'na'
            if options.region is 'sea' then options.region = 'sg'
            options.howRecent ?= 24*60*60*1000
            options.offset ?= 0
            options.pageSize ?= 50
            console.log 'fetching recent matches for',
                options.ign, 'in', options.region
            now = new Date
            before = new Date now.valueOf() - options.howRecent
            vg.setRegion options.region
            vg.matches.collection
                page :
                    offset : options.offset
                    limit : options.pageSize
                sort : '-createdAt' # doesn't seem to be working...see below
                filter :
                    'createdAt-start': before.toISOString()
                    'createdAt-end': now.toISOString()
                    'playerNames' : [ options.ign ]
                    'gameMode' : [ 'ranked' ]
            .then ( data ) ->
                if data.errors
                    callback message : data.messages
                else
                    matchTime = ( m ) ->
                        new Date m.data.attributes.createdAt
                    data.match.sort ( a, b ) ->
                        ( matchTime b ) - ( matchTime a )
                    callback null, data
            .catch ( err ) ->
                callback {
                    type : 'Matches Fetching Error'
                    stack : err.stack
                }, null
        catch err
            callback {
                type : 'Matches Preparation Error'
                stack : err.stack
            }, null

## Compute advice for a player in a match

First, take the given match ID and fetch the match data from the Vainglory
API.  Then fetch the telemetry data attached to the match.  Pass that to
[the faculty module](faculty.litcoffee) for analysis, and send the result to
the callback.

    exports.getAdviceForPlayerInMatch =
    ( matchId, region, ign, callback ) ->
        try
            console.log 'fetching advice for', ign, 'in', matchId, 'in',
                region
            faculty = require './faculty'
            utils = require './harvesters/utils'
            region ?= 'na'
            if region is 'sea' then region = 'sg'
            vg.setRegion region
            vg.matches.single matchId
            .then ( matchObject ) ->
                participant = utils.getParticipantFromIGN matchObject, ign
                utils.fetchTelemetryData matchObject, ( result ) ->
                    if not result?
                        callback 'Could not fetch telemetry data', null,
                            null
                    else
                        try
                            callback null, matchObject,
                                faculty.getAllAdvice matchObject,
                                    participant
                        catch err
                            callback {
                                type : 'Advice Algorithms Error'
                                stack : err.stack
                            }, null, null
            .catch ( err ) ->
                callback {
                    type : 'Match Fetching Error'
                    stack : err.stack
                }, null, null
        catch err
            callback {
                type : 'Advice Preparation Error'
                stack : err.stack
            }, null, null

## Get archive data

The input is a list of role-tier-harvester triples, such as
`[ [ 'captain', 7, 'deaths' ], [ 'captain', 10, 'kills' ] ]`.
The result will be a list in the same order, each entry being the data from
the archive corresponding to the triple in the input.  You cannot pass a
single triple outside of a list; enclose even one triple in a list, and get
back a list of length one.

    exports.getArchiveData = ( mode, triples ) ->
        everything = require( './archivist' ).allArchiveResults()
        result = ( everything[mode][utils.rawRoleTierKey triple...] \
            for triple in triples )
        result
