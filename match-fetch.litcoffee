
    vainglory = require 'vainglory'
    vg = new vainglory process.env.VG_API_KEY
    queries = require './queries'

    [ ign, shard ] = process.argv[2..]
    if shard is 'sea' then shard = 'sg'
    queries.recentMatchesForPlayer
        ign : ign
        region : shard?.toLowerCase() ? 'na'
        howRecent : 30*24*60*60*1000
    , ( error, result ) ->
        if error
            console.log error : error.message
        else
            console.log result
