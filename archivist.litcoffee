
# The Archivist

    fs = require 'fs'

This file maintains an archive of data sucked from old Vainglory matches. It
can be configured with a start time (call it S), a time duration (call it
D), and a function to run (call it F).  For each successive time interval
T1, T2, ... of length D starting at S, it fetches a sample of the matches
in that time interval, runs F on each one (together with an accumulation
object into which F packs its data), and then archives the resulting
accumulation object in a file stamped with the starting date-time for the
interval.

Note that this means that we are *not* keeping all the data from the matches
we fetch; we are simply doing some computations (whatever F does) on those
matches, and storing the accumulated results of those computations. For
example, maybe F just wants to compute average gold per minute across all
six heroes in a match, and one or two other things.  Whatever F computes,
that's what we archive.

Whenever this script is launched, it deletes any archive files older than
the start time, and slowly adds new files after the last archive until the
archive is up-to-date.  Files are stored as `archive-<datetime>.json`.
The speed at which new queries are run is configurable.

There are other configurable parameters described further below.

## Units

Convenient words for time units:

    exports.seconds = 1000
    exports.minutes = 60*exports.seconds
    exports.hours = 60*exports.minutes
    exports.days = 24*exports.hours

## Parameters

Here are the default parameters described above, together with functions
for getting and setting them.

The duration of each file in the archive:  Note that setting the archive
interval will probably mess up the entire archive, so you should probably
then call `deleteEntireArchive()` so that the archive is rebuilt thereafter.

    duration = 1*exports.days
    exports.getDuration = -> duration
    exports.setDuration = ( d ) -> duration = d

You can also take a given `Date` object and increase it by that duration
with the following convenience function.

    nextDate = ( afterThisDate ) ->
        new Date afterThisDate.valueOf() + duration

The start time of the archive:  Note that setting the archive start time may
mess up the entire archive, so you may want to call `deleteEntireArchive()`
so that the archive is rebuilt thereafter.

    startTime = new Date 2017, 2, 15 # Y M D, with 0=January
    exports.getStartTime = -> startTime
    exports.setStartTime = ( t ) -> startTime = t

The end time of the archive:  Note that setting the archive start time may
mess up the entire archive, so you may want to call `deleteEntireArchive()`
so that the archive is rebuilt thereafter.

    endTime = new Date # defaults to now
    exports.getEndTime = -> endTime
    exports.setEndTime = ( t ) -> endTime = t

It can be handy to ask for a certain distance into the past.  This function
makes that easy.

    exports.someTimeAgo = ( timeDelta ) ->
        new Date ( new Date ).valueOf() - timeDelta

The frequency of making new queries to the API to extend the archive:  How
often you set this depends upon the rate limits for your API key.  Changing
this takes immediate effect, in that any ongoing queries will begin to
happen more frequently.

    queryFrequency = 5*exports.seconds
    exports.getQueryFrequency = -> queryFrequency
    exports.setQueryFrequency = ( f ) ->
        queryFrequency = f
        exports.stopAPIQueries()
        exports.startAPIQueries()

The function that creates the next archive gets run repeatedly.  Each time
it gets run, it takes three parameters: a new Match object, the object into
which it's accumulating all the data it scrapes from the matches, and a
callback function, because it's asynchronous.

For the first call of each new archive file, the second parameter will be
the empty object, and the function will need to add any fields it wants.
Later, those fields will already exist and it can extend them or add to
them.

Be sure to end your implementation by calling the callback.  The default
value just counts how many matches it saw, as a simple test of this module.

If you call `setArchiveFunction`, you should probably then call
`deleteEntireArchive`, so that the archive will be rebuilt thereafter with
your new function.

    archiveFunction = ( match, accumulated, callback ) ->
        accumulated.matchesSeen ?= 0
        accumulated.matchesSeen++
        callback()
    exports.getArchiveFunction = -> archiveFunction
    exports.setArchiveFunction = ( f ) -> archiveFunction = f

You must also provide a valid `Vainglory` object, initialized with your API
Key, for this module to use when running queries.

    vg = null
    exports.setQueryObject = ( v ) -> vg = v

If you would like to archive a maximum number of games from each time frame,
then call the `setMaxima` function defined below.  It takes as a parameter
an object whose keys are those shown in the default value below, and whose
values are the maximum number of each type you'd like to archive.  If
instead you provide a single integer to `setMaxima`, it uses that value for
all game modes.

    matchTypes = [ 'casual', 'ranked', 'blitz', 'battleRoyale' ]
    maxima = { }
    maxima[type] = 5 for type in matchTypes
    exports.getMaxima = -> maxima
    exports.setMaxima = ( m ) ->
        if m instanceof Object
            maxima = m
            for type in matchTypes
                if not maxima.hasOwnProperty type then maxima[type] = 0
        else if 'number' is typeof m
            maxima[key] = m for own key of maxima

A few related utility functions:

    simplifyType = ( typeFromAPI ) ->
        if /blitz/.test typeFromAPI then return 'blitz'
        if /aral/.test typeFromAPI then return 'battleRoyale'
        if typeFromAPI is 'ranked' then return 'ranked'
        'casual'
    emptyAccumulator = ( withCounts = yes ) ->
        result = { }
        result[type] = { } for type in matchTypes
        if withCounts
            result.found = { }
            result.found[type] = 0 for type in matchTypes
        result

If you choose to provide a joining function, which can take two accumulator
objects and merge them (returning a new, combined object), then do so via
the function below.  This module can then use it iteratively to merge all
files in the archive, creating a single (big) report on all the files whose
data have been saved in the archive.

This default is only functional with the default `archiveFunction` provided
above, and is of near-zero use in reality.

Note that the joining function is called on accumulated data objects for a
single game mode only, not across game modes, nor uniting multiple game
modes at once.

    joiningFunction = ( accumulated1, accumulated2 ) ->
        matchesSeen : accumulated1.matchesSeen + accumulated2.matchesSeen
    exports.getJoiningFunction = -> joiningFunction
    exports.setJoiningFunction = ( f ) -> joiningFunction = f

## Combining the archive

Execute the joining function on all archived files as follows.

    getAllArchiveResults = ->
        result = emptyAccumulator no
        for file in fs.readdirSync '.'
            if m = /^archive-([0-9]+)\.json$/.exec file
                next = JSON.parse fs.readFileSync file
                for type in matchTypes
                    result[type] = joiningFunction result[type], next[type]
        result

Save them into a cache file as follows.

    saveArchiveResults = ->
        results = getAllArchiveResults()
        fs.writeFileSync 'full-archive.json', JSON.stringify results
        results

Read them from the cache (or cause the cache to be created) as follows.  The
`gameMode` parameter is optional; without it, you get the full cache, but
with it, you get just the results from your chosen game mode.

    exports.allArchiveResults = ( gameMode ) ->
        if not fs.existsSync 'full-archive.json'
            cache = saveArchiveResults()
        else
            cache = JSON.parse fs.readFileSync 'full-archive.json'
        if gameMode then cache[gameMode] else cache

You can clear the cache with this function, and we do whenever we add or
delete files to the archive (see the last section in this file).

    clearArchiveResultsCache = ->
        if fs.existsSync 'full-archive.json'
            fs.unlinkSync 'full-archive.json'

## API Queries

Functions for starting and stopping the regular running of API queries.
If you call `startAPIQueries`, they will continue to happen every
`queryFrequency` until the archive is fully up-to-date, at which point the
interval will be cleared (and your script may then terminate).

    interval = null
    exports.startAPIQueries = ->
        nextArchiveStep()
        interval = setInterval nextArchiveStep, queryFrequency
    exports.stopAPIQueries = -> clearInterval interval

We keep track of a running API query, which may return many pages of matches
that we must process slowly, asynchronously.  Initially, there is no such
query.

    runningQuery = null

The following function fetches the next page of results from the running
query, assuming the options for such a query are stored in `runningQuery`.

    fetchNextPage = ( callback ) ->
        console.log '  Fetching page at offset',
            runningQuery.options.page.offset
        vg.matches.collection runningQuery.options
        .then ( matches ) ->
            if matches.errors and \
               matches.messages is 'The specified object could not be
               found.'
                console.log '    No more data in this query.'
                runningQuery.lastFetched = match : [ ]
            else
                runningQuery.lastFetched = matches
                console.log "    Found #{matches.data.length} more matches"
            callback()

The following function fetches the next page that isn't yet in the archive.
Note that a single file in the archive represents a specific time frame,
which consists of several pages.  This function loads and processes the next
page.

If there is such a page, the callback is called after it, and other pages
are not processed until the next time this function is called.  Any
accumulating data is not yet saved to the archive.  If there is not such a
page, then this time interval was completed, and the accumulated data will
be saved to the archive, and then the callback called.

    nextArchiveStep = ->

If no query is running, set one up for the next time interval we don't yet
have in the archive.

        if not runningQuery
            latest = latestDateInArchive()
            next = if latest then nextDate latest else startTime
            nextnext = nextDate next
            if nextnext > endTime then return exports.stopAPIQueries()
            runningQuery =
                startDate : next
                endDate : nextnext
                options :
                    page :
                        offset : 0
                        limit : 50
                    sort : 'createdAt'
                    filter :
                        'createdAt-start': next.toISOString()
                        'createdAt-end': nextnext.toISOString()
                nextMatchToProcess : 0
                accumulated : emptyAccumulator()
            console.log "Analyzing time interval from
                #{runningQuery.startDate} to #{runningQuery.endDate}"

If the current query (whether we just created it or not) has no page of
data loaded, then call `fetchNextPage` with this routine as the callback.

        if not fetched = runningQuery.lastFetched
            # console.log 'time to call fetch next page'
            return fetchNextPage nextArchiveStep

If the page of data in the current query is empty, we must have exhausted
all the pages (and thus gotten an empty one).  We therefore save all the
data we've gleaned from that time interval into the next archive file and
delete the `runningQuery` object.

        if fetched.match.length is 0
            console.log "Completed time interval from
                #{runningQuery.startDate} to #{runningQuery.endDate}"
            saveArchiveFile runningQuery.startDate, runningQuery.accumulated
            runningQuery = null
            return

If we have found enough matches of each type, then behave exactly as if the
query were empty, that is, as if we can be done processing this entire time
interval.

        foundEnoughOfEachType = yes
        for type in matchTypes
            if runningQuery.accumulated.found[type] < maxima[type]
                foundEnoughOfEachType = no
                break
        if foundEnoughOfEachType
            console.log "We now have enough of each type - this time frame
                is complete"
            saveArchiveFile runningQuery.startDate, runningQuery.accumulated
            runningQuery = null
            return

If we haven't yet processed all the matches in the current page, process
the next one, and then asynchronously come back to this function to do so
yet again, recursively traversing the whole current page of results.

        if runningQuery.nextMatchToProcess < fetched.match.length
            match = fetched.match[runningQuery.nextMatchToProcess++]
            type = simplifyType match.gameMode
            if runningQuery.accumulated.found[type] >= maxima[type]
                console.log "      Skipping match
                    #{runningQuery.nextMatchToProcess} of
                    #{fetched.data.length} - seen enough #{type}"
                return nextArchiveStep()
            console.log "      Processing match
                #{runningQuery.nextMatchToProcess} of
                #{fetched.data.length} - type #{type}"
            runningQuery.accumulated.found[type]++
            return archiveFunction match, runningQuery.accumulated[type],
                nextArchiveStep

The only other possible outcome is that we have processed the entire page of
results, so we delete the processed page of data.  This will force the next
call of this function (by the `setInterval` ticker in `startAPIQueries`) to
fetch another page of data.

        # console.log 'about to get the next page of results, with',
        #     runningQuery.accumulated, 'accumulated so far'
        runningQuery.options.page.offset += fetched.match.length
        runningQuery.nextMatchToProcess = 0
        delete runningQuery.lastFetched

## Archive files

This function adds a new file to the archived JSON files.  The first
parameter is the `Date` object for the start of the time period.  The second
object is the JSON data to store in the archive.

    saveArchiveFile = ( dateTime, data ) ->
        clearArchiveResultsCache()
        fs.writeFile "archive-#{dateTime.valueOf()}.json",
            JSON.stringify( data ), ->

This function deletes the entire set of archived JSON files.

    deleteEntireArchive = ->
        clearArchiveResultsCache()
        fs.readdir '.', ( err, files ) ->
            files.forEach ( file ) ->
                fs.unlinkSync file if /^archive-[0-9]+\.json$/.test file

Get the latest date on any file in the archive.

    latestDateInArchive = ->
        latest = 0
        for file in fs.readdirSync '.'
            if m = /^archive-([0-9]+)\.json$/.exec file
                latest = Math.max latest, parseInt m[1]
        if latest then new Date latest else null

If you have recently advanced the archive start time (using `setStartTime`)
to a (new, later) time for which we currently have an archive file, you can
clean out the earlier (no longer needed) archive files with the following
function.

    deleteExpiredArchiveFiles = ->
        clearArchiveResultsCache()
        startNumber = startTime.valueOf()
        fs.readdir ',', ( err, files ) ->
            files.forEach ( file ) ->
                if m = /^archive-([0-9]+)\.json$/.exec file
                    fs.unlinkSync file if startNumber > parseInt m[1]
