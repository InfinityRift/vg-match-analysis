
# Scrape for recent pro builds

    vainglory = require 'vainglory'
    key = process.env.VG_API_KEY
    vg = new vainglory key
    utils = require '../harvesters/utils'
    utils.setVGAPIObject vg
    builds = require '../faculty/buildtypes'
    fs = require 'fs'

## Timing utilities

    startTime = null
    startTimeNumTasks = 0
    setStartTime = ( numTasks ) ->
        startTime = new Date
        startTimeNumTasks = numTasks
    reportTime = ( numTasksRemaining ) ->
        numTasksDone = startTimeNumTasks - numTasksRemaining
        if numTasksDone is 0 then return 'time estimate not yet available'
        currentTime = new Date
        elapsed = currentTime - startTime
        if elapsed is 0 then return 'time estimate not yet available'
        remaining = numTasksRemaining * elapsed / numTasksDone
        require( '../strider' ).niceTime( remaining ) + ' remaining'

We need a way to traverse all the recent matches for a set of players, and
to run a function on each match, calling a callback when that's complete.
The following function does so.  It takes these parameters:
 * `players` - a list of objects, each of which must have a string `region`
   (NA, EU, EA, SEA, SA) and string `ign`, these are the players whose
   matches we will fetch
 * `callback` - the function to call when this is complete; it will receive
   a single object as parameter, whose keys will be match ids and whose
   values are the matches themselves (telemetry data not yet fetched).
   Note that even if a single match was played by many players in the
   `players` list, it only shows up once in this object.
 * `maxNumber` - an integer, fetch at most this many matches per player
   (defaults to 50)
 * `delay` - an integer, how many milliseconds to delay between API queries,
   defaults to 1000 (one second)
 * `startDate` - a Date object, fetch matches only from this moment onward,
   defaults to one week before the present


    downloadMatches =
    ( players, callback, maxNumber, delay, startDate ) ->
        now = new Date
        startDate ?= new Date now.valueOf() - 1000*60*60*24*7
        maxNumber ?= 50
        delay ?= 1000
        matches = { }
        setStartTime players.length
        addMatchesToCollection = ( newMatches ) ->
            console.log "Downloaded #{newMatches.length} new matches..."
            numberAdded = 0
            for match in newMatches
                if not matches.hasOwnProperty match.id
                    matches[match.id] = match
                    numberAdded++
            console.log "\t...added #{numberAdded} to the collection."
        do getMatchesForNextPlayer = ->
            if players.length is 0 then return callback matches
            nextOne = ->
                console.log 'Download time:', reportTime players.length
                setTimeout getMatchesForNextPlayer, delay
            { ign, region, offset } = players.shift()
            region = ( region ? 'na' ).toLowerCase()
            if region is 'sea' then region = 'sg'
            console.log "fetching matches for #{ign} in #{region} from
                offset #{offset}"
            vg.setRegion region
            vg.matches.collection
                page :
                    offset : offset
                    limit : maxNumber
                sort : '-createdAt' # doesn't seem to be working...see below
                filter :
                    'createdAt-start' : startDate.toISOString()
                    'createdAt-end' : now.toISOString()
                    'playerNames' : [ ign ]
                    'gameMode' : [ 'ranked' ]
            .then ( data ) ->
                if data.errors
                    console.log 'Match Fetch Error (type 1):', data.messages
                    nextOne()
                else
                    matchTime = ( m ) ->
                        new Date m.data.attributes.createdAt
                    data.match.sort ( a, b ) ->
                        ( matchTime b ) - ( matchTime a )
                    addMatchesToCollection data.match
                    if data.match.length is maxNumber
                        players.unshift
                            ign : ign
                            region : region
                            offset : offset + maxNumber
                    nextOne()
            .catch ( err ) ->
                console.log 'Match Fetch Error (type 2):', err.stack
                nextOne()

Once that has done its work, you can archive the big bolus of matches it
downloaded into a single enormous JSON object if you like, and then restore
it from that giant object.  Here are two functions that let you do so, and
read/write the big object to/from a file.

    saveDownloadedMatches = ( matches, filename ) ->
        console.log "Saving #{Object.keys( matches ).length} matches to
            #{filename}..."
        for own key, value of matches
            matches[key] = utils.vgObjectToJSON value
        fs.writeFileSync filename, JSON.stringify matches
        console.log '\tDone.'
    restoreDownloadedMatches = ( filename ) ->
        console.log "Restoring matches from #{filename}..."
        matches = JSON.parse String fs.readFileSync filename
        for own key, value of matches
            matches[key] = utils.vgObjectFromJSON value
        console.log "\tRestored #{Object.keys( matches ).length} matches."
        matches

The following function analyzes a set of matches (in the form of a big
object like the one returned from `downloadMatches`, as documented above)
and runs the function `f` on each, calling the given callback when complete.
The function should take two inputs, a match object and a callback function
to call when its work is complete.  It should return no value, but store any
of its work in some global data structures.

    analyzeAllMatches = ( matches, f, callback ) ->
        console.log "Analyzing #{Object.keys( matches ).length} matches..."
        ids = Object.keys matches
        setStartTime original = ids.length
        return do nextAnalysis = ->
            if ids.length is 0 then return callback()
            match = matches[id = ids.shift()]
            f match, ->
                done = original - ids.length
                console.log 'Analysis time:', reportTime( ids.length ),
                    "(#{Number( 100*done/original ).toFixed 0}% done)"
                delete matches[id]
                setTimeout nextAnalysis, 100

Next, we need a list of pro players.  It's not necessary for this script to
categorize them by team, but I already had this data ready, so no harm to
keep it categorized by team (and region).

    proScene =
        na :
            'Team SoloMid' : [ 'BestChuckNa', 'FlashX', 'VONC' ]
            'Cloud9' : [ 'gabevizzle', 'iLoveJoseph', 'Oldskool' ]
            'Immortals' : [ 'Aloh4', 'Vains', 'DNZio', 'SuiJeneris' ]
            'Echo Fox' : [ 'MICSHE', 'CullTheMeek', 'LoneDelphi', 'FooJee' ]
            'Rogue' : [ 'Sibs', 'Hami', 'eVoL' ]
            'Hammers' : [ 'StartingAllOver', 'ttigers', 'Chicken123' ]
            'GankStars' : [ 'IraqiZorro', 'R3cKeD', 'Xelciar', 'XenoTek' ]
            'Misfits' : [ 'Eeko', 'IllesT', 'King' ]
            'NRG' : [ 'Hardek', 'Gaspy', 'chombo305' ]
        eu :
            'Cyclone' : [ 'WalDeMar', 'red-ABTION', 'PTLam', 'Melyssandre',
                'radha' ]
            'SK Gaming' : [ 'jetpacks', 'KValafar', 'Tyruzz', 'Raph' ]
            'Rising Lotus' : [ 'Agony', 'Flobby', 'romgemsword' ]
            'G2 Esports' : [ 'Hundor', 'DarkPotato', 'KeanuNakoa',
                'Reddix', 'D1ngo' ]
            'FNATIC' : [ 'TetnoJJ', 'Palmatoro', 'nettetoilette', 'kaerl' ]
            'mousesports' : [ 'GreatkhALI', 'Asater', 'Emirking',
                'SkorpiBro', 'IroNs' ]
            'Team Secret' : [ 'Mowglie', 'L3oN', 'Tr1cKy', 'justman00' ]
            'Beyond HorizoN' : [ 'ArtemisGrace', 'Bashn', 'ImtheDoom' ]
        ea :
            'DetonatioN Gaming' : [ 'ViViQIZ', 'ViViRoyaL', 'tatuki217' ]
            'GG NEWtype 2nd' : [ 'mukuEA', 'LyRiz', 'Supercell7' ]
            'Invincible Armada' : [ 'druid', 'MANGOxJAMONG', 'Willy' ]
            'ACE Gaming' : [ 'ACEImPaLe', 'ACET4SA', 'ACEMojo' ]
            'Team pQq' : [ 'StriVE', 'TenaciTy', 'pQq' ]
            'Hack' : [ '-DaDa-', 'Yup', 'ILoveYoungJoo' ]
            'Black Cat Knights' : [ 'ZouBH', 'beyou115', 'LeblaNc',
                'TrendyWorld' ]
            'Team QUAD' : [ 'YakumoIRan', 'i4N', 'SpaceLok', 'TinoChung' ]
        sea :
            'Artisan' : [ 'Truffless', 'Chingy', 'HARKONS', 'Delfyre' ]
            'Elite 8' : [ 'AnimeSaveMe', 'HundJaegers', 'officialhein',
                'iLoC' ]
            'Exorcists' : [ '-Kalua-', 'IIBaby', 'Iangryyoudie', 'k0sh',
                'RubberMonkey' ]
            'Impunity' : [ 'INKED', 'deftQ', '-spaghetti-', 'Quatervois' ]
            'J3X Inferno' : [ 'Bxrealis', 'Cyduck', 'DeityStarZ',
                'METEORITE' ]
            'PH Alliance' : [ 'Wharlly', 'SynC1', 'WheyaM', 'tomiya',
                'Init1alize' ]
            'Silver' : [ 'VETRUZ', 'WwkilozinwW', 'laykieng', 'DepressioN',
                'RaCcooN', 'RasenShuriKen' ]
            'Infamous' : [ 'uNi', 'QuiXotic', 'PerfectBladeX', 'SnkEA',
                'shak2713' ]
        sa :
            'Red Canids' : [ 'UrameshiYusuke', 'Mirotic', 'SrMusTer' ]
            'Zonic Esports' : [ 'FalconDorian', 'Mestreijo', 'GwM' ]
    regionPlayerPairs = [ ]
    for own regionName, teams of proScene
        for own teamName, team of teams
            for ign in team
                regionPlayerPairs.push
                    region : regionName
                    ign : ign
                    offset : 0

If you want to do a quick test, leave the following line uncommented.  If
you want to do a full run, comment it out.

    # regionPlayerPairs = regionPlayerPairs[...3]

Initialize any global variables that will be populated as we analyze
matches, and any functions that are useful for adding to these global data
structures.

    gatheredBuilds = { }
    filterForType = ( build, type ) ->
        ( index for index in build when \
            type is builds.getTypeOfItem builds.itemList[index] )
    addFightData = ( hero, build, duration, numHits, rawDmg, realDmg ) ->
        build = filterForType build, 'WP'
        if build.length is 0 then return
        heroData = gatheredBuilds[hero] ?= { }
        build.sort ( a, b ) -> a - b
        buildData = heroData[build.join ' '] ?= [ ]
        buildData.push
            duration : duration
            hits : numHits
            damage : rawDmg
            dealt : realDmg

Define the function that will be run on each match to populate global
variables.

    analysisResultsFilename = './wp-analysis.json'
    analyze = ( match, callback ) ->
        deltaT = 2000 # num ms that must elapse to break hit streaks
        recordTheseHeroes = [
            'Adagio'
            'Alpha'
            'Idris'
            'Joule'
            'Krul'
            'Ozo'
            'Ringo'
            'Taka'
        ]
        utils.fetchTelemetryData match, ( result ) ->
            try
                for roster in match.rosters
                    for participant in roster.participants
                        if participant.actor not in recordTheseHeroes
                            continue
                        buildIndices = [ ]
                        hitSequenceStartedAt = hitSequenceEndedAt = null
                        numHits = rawDmgTotal = realDmgTotal = 0
                        start = ( time ) ->
                            hitSequenceStartedAt = hitSequenceEndedAt = time
                            numHits = rawDmgTotal = realDmgTotal = 0
                        extend = ( time, raw, real ) ->
                            hitSequenceEndedAt = time
                            numHits++
                            rawDmgTotal += raw
                            realDmgTotal += real
                        record = ->
                            duration = ( hitSequenceEndedAt - \
                                hitSequenceStartedAt ) / 1000
                            if duration > 0
                                addFightData participant.actor,
                                    buildIndices, duration, numHits,
                                    rawDmgTotal, realDmgTotal
                            start null
                        for event in match.telemetry
                            date = new Date event.time
                            if hitSequenceStartedAt? and \
                               date - hitSequenceStartedAt > deltaT
                                record()
                            if utils.isEventActor match, participant, event
                                isVsHero = event.payload.TargetIsHero is 1
                                if event.type is 'BuyItem'
                                    item = builds.itemNameToIndex \
                                        event.payload.Item
                                    if item > -1
                                        buildIndices.push item
                                        buildIndices = buildIndices.sort \
                                            ( a, b ) -> a - b
                                else if event.type is 'SellItem'
                                    item = builds.itemNameToIndex \
                                        event.payload.Item
                                    index = buildIndices.indexOf item
                                    buildIndices.splice index, 1
                                else if event.type is 'DealDamage' and \
                                   event.payload.Source is 'Unknown' and \
                                   event.payload.TargetIsHero
                                    if not hitSequenceStartedAt?
                                        start date
                                    else
                                        extend date, parseInt( \
                                            event.payload.Damage ),
                                            parseInt( event.payload.Delt )
                        if hitSequenceStartedAt? then record date
            catch e
                console.log e.stack
            fs.writeFileSync analysisResultsFilename,
                JSON.stringify gatheredBuilds
            callback()

When done, this callback reports the results.

    csvfilename = './wp-results.csv'
    createCSVFile = ->
        csvfile = ''
        row = ( args... ) -> csvfile += "\"#{args.join '","'}\"\n"
        row 'Hero', 'Build', 'Total seconds used', 'Hits per second',
            'Raw damage per second', 'Actual damage per second'
        gatheredBuilds =
            JSON.parse String fs.readFileSync analysisResultsFilename
        for own heroName, data of gatheredBuilds
            for own buildString, sequences of data
                build = if buildString.length > 0
                    ( builds.itemList[parseInt item] \
                        for item in buildString.split ' ' )
                else
                    [ ]
                rates = { }
                totalDuration = 0
                for sequence in sequences
                    newTotal = totalDuration + sequence.duration
                    for own key, value of sequence
                        if key is 'duration' then continue
                        if key is 'hits' then value--
                        rates["#{key}/sec"] =
                            ( totalDuration * ( rates["#{key}/sec"] ?= 0 ) \
                            + value ) / newTotal
                    totalDuration = newTotal
                buildName = build.join ' & '
                row heroName, buildName, totalDuration, rates['hits/sec'],
                    rates['damage/sec'], rates['dealt/sec']
                if rates['hits/sec'] > 5
                    console.log heroName, build
                    for sequence in sequences
                        console.log "\t#{sequence.hits} hits /
                            #{sequence.duration} sec =
                            #{sequence.hits/sequence.duration} hits/sec"
        fs.writeFileSync csvfilename, csvfile
        console.log "Wrote file to #{csvfilename} -- Done!"

Define the scraping process in phases.

Downloading and archiving a lot of matches:

    downloadPhase = ( callback ) ->
        filename = './downloaded-matches.json'
        downloadMatches regionPlayerPairs, ( matches ) ->
            saveDownloadedMatches matches, filename
            callback()
        , 50, 1000, new Date 2017, 2, 30

Running an analysis on a pre-downloaded archive:

    analysisPhase = ( callback ) ->
        analyzeAllMatches \
            restoreDownloadedMatches( './downloaded-matches.json' ),
            analyze, callback

Run whichever phases you want by uncommenting.

    # downloadPhase -> # just download matches, don't analyze yet
    # analysisPhase -> # just analyze matches, creating gatheredBuilds
    # createCSVFile() # just finalize analysis and save to CSV file
    analysisPhase createCSVFile # last two phases sequentially
    # downloadPhase analysisPhase createCSVFile # all 3 phases sequentially
