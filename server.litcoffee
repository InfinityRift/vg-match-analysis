
# Main module

    queries = require './queries'

This is the server for the main app.

## Start the server

Set up a simple express web server for the website's static assets.

    express = require 'express'
    app = express()
    path = require 'path'
    app.use express.static path.join __dirname, 'pages'

There is one endpoint that is not static, for two different actions that the
server must take -- fetching player match lists, or analyzing one particular
match.

    app.get '/query', ( req, res ) ->
        return unless query = req.url.split( '?' )[1..][0]
        dict = { }
        for pair in query.split '&'
            halves = pair.split '='
            dict[halves[0]] = halves[1]

This code answers queries to get match analysis.

        if dict.match? and dict.ign?
            dict.ign = dict.ign.replace /\+/g, ' '
            queries.getAdviceForPlayerInMatch dict.match,
                dict.shard?.toLowerCase() ? 'na',
                dict.ign,
                ( error, matchObject, result ) ->
                    res.setHeader 'Content-Type', 'application/json'
                    if error
                        res.send error : error
                    else
                        res.send JSON.stringify
                            match : matchToJSON matchObject
                            advice : result

This code answers queries to get lists of recent player ranked matches.

        else if dict.ign?
            dict.ign = dict.ign.replace /\+/g, ' '
            queries.recentMatchesForPlayer
                ign : dict.ign
                region : dict.shard?.toLowerCase() ? 'na'
                howRecent : 30*24*60*60*1000
            , ( error, result ) ->
                res.setHeader 'Content-Type', 'application/json'
                if error
                    res.send error : error.message
                else
                    res.send JSON.stringify \
                        ( matchToJSON match for match in result.match )

This code answers queries to browse the data archive.

        else if dict.archive?
            res.setHeader 'Content-Type', 'application/json'
            mode = dict.mode ? 'ranked'
            try
                res.send JSON.stringify \
                    queries.getArchiveData mode, JSON.parse \
                    decodeURIComponent dict.archive
            catch e
                res.send error : e.message

This code answers queries about the list of stats in the data archive.

        else if dict.stats?
            res.setHeader 'Content-Type', 'application/json'
            res.send JSON.stringify \
                require( './harvesters' ).getHarvesters()
        else
            res.status( 404 ).send '404 - Not found'

Start the server listening.

    port = process.env.PORT
    app.listen port, ->
        console.log "Listening on port #{port}"

## Utilities

These functions format objects for transmitting to the client over AJAX.

This function creates JSON data from a participant.

    participantToJSON = ( participant ) ->
        hero : participant.actor
        ign : participant.player.name
        kills : participant._stats.kills
        deaths : participant._stats.deaths
        assists : participant._stats.assists

This function creates JSON data from a match.

    matchToJSON = ( match ) ->
        zeroSide = match.rosters[0].data.attributes.stats.side
        leftIndex = if /left/.test zeroSide then 0 else 1
        left = match.rosters[leftIndex]
        right = match.rosters[1-leftIndex]
        utils = require './harvesters/utils'
        id : match.data.id
        time : match.data.attributes.createdAt
        left : participantToJSON p for p in left.participants
        right : participantToJSON p for p in right.participants
        telemetry : utils.hasTelemetryData match
