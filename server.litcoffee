
# Main module

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
        if dict.match? and dict.ign?
            queries = require './queries'
            queries.getAdviceForPlayerInMatch dict.match, dict.ign,
                ( error, result ) ->
                    res.setHeader 'Content-Type', 'application/json'
                    if error
                        res.send error : error
                    else
                        res.send JSON.stringify result
        else if dict.ign?
            queries = require './queries'
            queries.recentMatchesForPlayer
                ign : dict.ign
                shard : dict.shard?.toLowerCase() ? 'na'
                howRecent : 30*24*60*60*1000
            , ( error, result ) ->
                res.setHeader 'Content-Type', 'application/json'
                if error
                    res.send error : error
                else
                    res.send JSON.stringify \
                        ( match.id for match in result.data )
        else
            res.status( 404 ).send '404 - Not found'

Start the server listening.

    port = 7777
    app.listen port, ->
        console.log "Listening on port #{port}"
