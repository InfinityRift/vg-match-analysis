
# Main module

Important globals.

    vainglory = require 'vainglory'
    { key } = require './my-api-key'
    vg = new vainglory key

This is the server for the main app.

## Start the server

Not built yet...

## Utility functions

Fetch all recent matches for the given player in the given region.  The
parameters are in the form of an options object with these attributes.

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
        .then callback
