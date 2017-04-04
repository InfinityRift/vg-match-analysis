
# The Archivist

    fs = require 'fs'
    utils = require './harvesters/utils'

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

## Debugging controls

    debugging = off
    debug = ( args... ) -> if debugging then console.log args...
    exports.setDebugging = ( onOrOff ) -> debugging = onOrOff

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
    exports.setStartTime = ( t ) ->
        startTime = t
        exports.setMetaData 'start time', t

The end time of the archive:  Note that setting the archive start time may
mess up the entire archive, so you may want to call `deleteEntireArchive()`
so that the archive is rebuilt thereafter.

    endTime = new Date # defaults to now
    exports.getEndTime = -> endTime
    exports.setEndTime = ( t ) ->
        endTime = t
        exports.setMetaData 'end time', t

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
        if exports.isRunning()
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
    exports.setQueryObject = ( v ) -> utils.setVGAPIObject vg = v

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

    exports.simplifyType = ( typeFromAPI ) ->
        if /blitz/i.test typeFromAPI then return 'blitz'
        if /aral/i.test typeFromAPI then return 'battleRoyale'
        if /ranked/i.test typeFromAPI then return 'ranked'
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

Finally, do we want the archiving utility to keep copies of all downloaded
match data?  If so, in what folder should we put them?  If no folder is
specified, we do not archive them.

    matchArchiveFolder = null
    exports.getMatchArchiveFolder = -> matchArchiveFolder
    exports.setMatchArchiveFolder = ( f ) -> matchArchiveFolder = f

The Vainglory JS client keeps the original JSON data for a match in the
`.data` member of a `Match` object, so we can just read it from there, and
reconstruct it by passing that same object to the `Match` constructor.

    exports.archiveOneMatch = ( match ) ->
        if matchArchiveFolder?
            serialized = JSON.stringify utils.vgObjectToJSON match
            fs.writeFileSync "#{matchArchiveFolder}/#{match.data.id}.json",
                serialized
    exports.getMatchFromArchive = ( id ) ->
        utils.vgObjectFromJSON String fs.readFileSync \
            "#{matchArchiveFolder}/#{id}.json"
    exports.allMatchIdsInArchive = ->
        results = [ ]
        for file in fs.readdirSync matchArchiveFolder
            if m = /^([0-9a-fA-F-]*)\.json$/.exec file
                results.push m[1]
        results

## Combining the archive

You can store metadata in the archive.  It will be put in the final
"full archive" file only, and only when that file is created.  You can read
it, too.

    metadata = { }
    exports.setMetaData = ( key, value ) -> metadata[key] = value
    exports.getMetaData = -> exports.allArchiveResults().metadata

Execute the joining function on all archived files as follows.

    getAllArchiveResults = ->
        result = emptyAccumulator no
        for file in fs.readdirSync '.'
            if m = /^archive-([0-9]+)\.json$/.exec file
                next = JSON.parse fs.readFileSync file
                for type in matchTypes
                    result[type] = joiningFunction result[type], next[type]
        result.metadata ?= { }
        for own key, value of metadata
            result.metadata[key] = value
        result

Save them into a cache file as follows.

    saveArchiveResults = ( result ) ->
        result ?= getAllArchiveResults()
        # in case they passed us an incomplete object, add metadata...
        # though it's not necessary if we built it with getAllArchiveResults
        result.metadata ?= { }
        for own key, value of metadata
            result.metadata[key] = value
        fs.writeFileSync 'full-archive.json', JSON.stringify result
        result

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

The optional callback will be called every time another tick happens, and
it will report the latest time in the archive.  This is useful for
implementing progress reporting in the caller.

    interval = null
    exports.startAPIQueries = ( callback ) ->
        nextArchiveStep()
        interval = setInterval ->
            callback? exports.latestDateInArchive()
            nextArchiveStep()
        , queryFrequency
    exports.stopAPIQueries = ->
        clearInterval interval
        interval = null
    exports.isRunning = -> interval?

We keep track of a running API query, which may return many pages of matches
that we must process slowly, asynchronously.  Initially, there is no such
query.

    runningQuery = null

The following function fetches the next page of results from the running
query, assuming the options for such a query are stored in `runningQuery`.

    fetchNextPage = ( callback ) ->
        debug '  Fetching page at offset', runningQuery.options.page.offset
        # debug JSON.stringify runningQuery.options
        vg.matches.collection runningQuery.options
        .then ( matches ) ->
            # debug matches
            if matches.errors and \
               matches.messages is 'The specified object could not be
               found.'
                debug '    No more data in this query.'
                runningQuery.lastFetched = match : [ ]
            else if matches.errors
                console.log 'API ERROR:', matches.messages
                throw matches.messages
            else
                runningQuery.lastFetched = matches
                debug "    Found #{matches.data.length} more matches"
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
            latest = exports.latestDateInArchive()
            next = if latest then nextDate latest else startTime
            nextnext = nextDate next
            if nextnext > endTime
                debug 'Archive is fully up-to-date.'
                saveArchiveResults()
                debug 'Also created full summary file.  Done.'
                return exports.stopAPIQueries()
            runningQuery =
                startDate : next
                endDate : nextnext
                options :
                    page :
                        offset : 0
                        limit : 50
                    sort : 'createdAt'
                    filter :
                        'createdAt-start' : next.toISOString()
                        'createdAt-end' : nextnext.toISOString()
                        'gameMode' :
                            ( x for own x of maxima when maxima[x] > 0 )
                nextMatchToProcess : 0
                accumulated : emptyAccumulator()
            debug "Analyzing time interval from
                #{runningQuery.startDate} to #{runningQuery.endDate}"

If the current query (whether we just created it or not) has no page of
data loaded, then call `fetchNextPage` with this routine as the callback.

        if not fetched = runningQuery.lastFetched
            # debug 'time to call fetch next page'
            return fetchNextPage nextArchiveStep

If the page of data in the current query is empty, we must have exhausted
all the pages (and thus gotten an empty one).  We therefore save all the
data we've gleaned from that time interval into the next archive file and
delete the `runningQuery` object.

        if not fetched?.match?
            debug "Something is wrong with this fetched data:", fetched
            runningQuery = null
            return
        if fetched.match.length is 0
            debug "Completed time interval from
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
            debug "We now have enough of each type - this time frame
                is complete"
            saveArchiveFile runningQuery.startDate, runningQuery.accumulated
            runningQuery = null
            return

If we haven't yet processed all the matches in the current page, process
the next one, and then asynchronously come back to this function to do so
yet again, recursively traversing the whole current page of results.

        if runningQuery.nextMatchToProcess < fetched.match.length
            match = fetched.match[runningQuery.nextMatchToProcess++]
            type = exports.simplifyType match.gameMode
            if runningQuery.accumulated.found[type] >= maxima[type]
                debug "      Skipping match
                    #{runningQuery.nextMatchToProcess} of
                    #{fetched.data.length} - seen enough #{type}"
                return nextArchiveStep()
            debug "      Processing match
                #{runningQuery.nextMatchToProcess} of
                #{fetched.data.length} - type #{type}"
            runningQuery.accumulated.found[type]++
            return do ( match ) ->
                archiveFunction match, runningQuery.accumulated[type],
                    -> archiveOneMatch match ; nextArchiveStep()

The only other possible outcome is that we have processed the entire page of
results, so we delete the processed page of data.  This will force the next
call of this function (by the `setInterval` ticker in `startAPIQueries`) to
fetch another page of data.

        # debug 'about to get the next page of results, with',
        #     runningQuery.accumulated, 'accumulated so far'
        runningQuery.options.page.offset += fetched.match.length
        runningQuery.nextMatchToProcess = 0
        delete runningQuery.lastFetched

## Rebuilding the archive

If the data was harvested and archived in the past, with a match archive
folder enabled, then there is no sense in re-fetching all match data from
the internet just to harvest new stats from it.  That's where this function
comes in.  You can run this function to re-read all match archives from the
match archive folder (if you created one when fetching the matches in the
first place) and it will re-compute all stats from those matches (with
their telemetry data, which was saved with them), without hitting the web
at all.

    exports.rebuildArchive = ->
        clearArchiveResultsCache()
        console.log "Loading match list..."
        ids = exports.allMatchIdsInArchive()
        console.log "Found #{ids.length} matches in match archive."
        start = new Date
        accumulated = emptyAccumulator no
        for id, index in ids
            if index % 10 is 0
                pctDone = 100 * index / ids.length
                if index > 0
                    elapsed = ( new Date ) - start
                    ratio = ( 100 - pctDone ) / pctDone
                    remaining = elapsed * ratio / 60000
                    report = "#{Number( remaining ).toFixed 1} minutes"
                else
                    report = "(no estimate available yet)"
                console.log "Processed #{index}/#{ids.length} matches
                    (#{Number( pctDone ).toFixed 1}%) --
                    time remaining: #{report}"
            match = exports.getMatchFromArchive id
            type = exports.simplifyType match.gameMode
            archiveFunction match, accumulated[type]
        console.log 'Completed all; saving accumulated data...'
        saveArchiveResults accumulated
        console.log 'Done.'

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

    exports.latestDateInArchive = ->
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
