
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

The following is what we want to do to each match, but for now we just
declare it as a function.  We just run each harvester in turn, then call the
callback.  We will run this function later.

        processMatch = ->
            for harvester in harvesters
                harvester.reap match, accumulated
            callback()

First, I fetch the telemetry data for the match.  This requires a hack to
[the Vainglory JavaScript API](https://github.com/seripap/vainglory) at the
moment, which doesn't yet have telemetry support.  So this won't work
unless you modify your copy in `node_modules` in a similarly hacky way to
what I did.

Check: is there any telemetry data?

        telemetryAsset = null
        for asset in match.assets
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
                    processMatch()
            request.end()

Otherwise, you can just process it right now, synchronously.

        else
            processMatch()

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
