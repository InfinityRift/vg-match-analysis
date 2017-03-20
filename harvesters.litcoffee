
# Harvesters

    https = require 'https'

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

Check: is there any telemetry data?

        telemetryAsset = null
        for asset in match.assets ? [ ]
            if asset.attributes.name is 'telemetry'
                telemetryAsset = asset
                break

If so, go get it from the internet, *then* process the match after that
asynchronous fetching is done.

        if telemetryAsset
            match.events = ''
            request = https.request asset.attributes.URL
            count = 1
            request.on 'response', ( res ) ->
                res.on 'data', ( data ) ->
                    match.events += data
                res.on 'end', ->
                    match.events = JSON.parse match.events

Now that we have the full match data, including telemetry, we run each
harvester in turn, then call the callback.

                    for harvester in harvesters
                        harvester.reap match, accumulated
                    callback()
            request.end()

Otherwise, you can just process it right now, synchronously.

        else
            console.log '        --> Could not process: no telemetry data!'
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
