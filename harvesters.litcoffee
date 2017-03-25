
# Harvesters

    utils = require './harvesters/utils'

## Purpose

This file collects together all the harvester functions defined in
various other files in this repository, so that
[the Archive Updater](update-archive.litcoffee) can access them and ensure
that it runs them all.  In fact, we provide a function to do just that.  But
first, let's load the modules that contain the harvesters we'll use.

    harvesterExplanations =
        kills : 'number of kills'
        deaths : 'number of deaths'
        gold : 'CS (creep score)'
        objectives : 'damage done to objctives'
        stealing : 'gold earned from enemy jungle'
        gotstolen : 'gold enemies earned from my jungle'
        lonelydeaths : 'number of deaths with no allies near'
        goldinearlygame : 'gold earned before 8 minutes'
        goldinmidgame : 'gold earned 8-15 minutes'
        goldinlategame : 'gold earned after 15 minutes'
        dmgheroes : 'damage done to enemy heroes'
        dpsheroes : 'max damage per second on enemy heroes'
        dpsobjectives : 'damage done to objectives'
        dmgperspawn : 'max damage per second on objectives'
        earlyfountain : 'time until fountain purchased'
        secondsupport : 'time until second tier 3 support item'
        dmgperspawn : 'damage done to me per spawn'
        teamdmgperspawn : 'damage done to my team per spawn'
        builds : 'items purchased'
        # abilitynames # was for a temporary purpose -- all done
    exports.getHarvesters = -> harvesterExplanations
    harvesters = ( require "./harvesters/#{name}" \
        for name in Object.keys harvesterExplanations )

All of theses modules appear in [the harvesters folder](./harvesters/).

## Main functions

This function can be used to replace the default `archiveFunction` defined
in [the Archivist module](archivist.litcoffee) with one that runs all the
data scraping tools defined in other modules

    exports.archiveFunction = ( match, accumulated, callback ) ->
        utils.fetchTelemetryData match, ( result ) ->
            if result
                for harvester, index in harvesters
                    try
                        harvester.reap match, accumulated
                    catch e
                        console.log "Error in harvester #{index}: #{e}",
                            e.stack
            else
                console.log '        --> No telemetry data to process'
            callback()

Similarly, we provide a function that replaces the default joining
function.  It requires each harvester to provide a `bind` function taking
three arguments, two to accumulate, and the third into which to embed all
the accumulated data.

    exports.joiningFunction = ( accumulated1, accumulated2 ) ->
        result = { }
        for harvester in harvesters
            harvester.bind accumulated1, accumulated2, result
        result

## API

Use the following convenience function to install the above main functions
into an [archivist](archivist.litcoffee) instance.

    exports.installInto = ( archivist ) ->
        archivist.setArchiveFunction exports.archiveFunction
        archivist.setJoiningFunction exports.joiningFunction

Use the following function to run a deeper analysis (not just the data
skimming for archival purposes, but a deep dive into a single match) on a
match object.

    exports.pick = ( match, participant ) ->
        accumulated = { }
        for harvester in harvesters
            harvester.pick match, participant, accumulated
        accumulated
