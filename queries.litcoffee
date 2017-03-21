
# Queries supported by the server

Important globals.

    vainglory = require 'vainglory'
    { key } = require './my-api-key'
    vg = new vainglory key

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
        options.region ?= 'na'
        options.howRecent ?= 24*60*60*1000
        options.offset ?= 0
        options.pageSize ?= 50
        now = new Date
        before = new Date now.valueOf() - options.howRecent
        vg.setRegion options.region
        vg.matches.collection
            page :
                offset : options.offset
                limit : options.pageSize
            sort : '-createdAt'
            filter :
                'createdAt-start': before.toISOString()
                'createdAt-end': now.toISOString()
                'playerNames' : [ options.ign ]
                'gameMode' : [ 'ranked' ]
        .then ( data ) -> callback null, data
        .catch ( err ) -> callback err, null

## Compute advice for a player in a match

First, take the given match ID and fetch the match data from the Vainglory
API.  Then fetch the telemetry data attached to the match.  Pass that to
[the faculty module](faculty.litcoffee) for analysis, and send the result to
the callback.

    exports.getAdviceForPlayerInMatch = ( matchId, ign, callback ) ->
        faculty = require './faculty'
        utils = require './harvesters/utils'
        vg.matches.single matchId
        .then ( matchObject ) ->
            participant = utils.getParticipantFromIGN matchObject, ign
            utils.fetchTelemetryData matchObject, ( result ) ->
                if not result?
                    callback 'Could not fetch telemetry data', null, null
                else
                    try
                        callback null, matchObject,
                            faculty.getAllAdvice matchObject, participant
                    catch e
                        console.log e
                        callback e, null, null
        .catch ( err ) ->
            callback err, null, null
