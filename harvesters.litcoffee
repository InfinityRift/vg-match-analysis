
# Harvesters

    utils = require './harvesters/utils'

## Purpose

This file collects together all the harvester functions defined in
various other files in this repository, so that
[the Archive Updater](update-archive.litcoffee) can access them and ensure
that it runs them all.  In fact, we provide a function to do just that.  But
first, let's load the modules that contain the harvesters we'll use.

    harvesters = [
        require './harvesters/death'
    ]

All of theses modules appear in [the harvesters folder](./harvesters/).

## Main functions

This function can be used to replace the default `archiveFunction` defined
in [the Archivist module](archivist.litcoffee) with one that runs all the
data scraping tools defined in other modules

    exports.archiveFunction = ( match, accumulated, callback ) ->
        utils.fetchTelemetryData match, ( result ) ->
            if result
                for harvester in harvesters
                    harvester.reap match, accumulated
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

    exports.pick = ( match ) ->
        accumulated = { }
        for harvester in harvesters
            harvester.pick match, accumulated
        accumulated
