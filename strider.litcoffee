
# Traversing the match archive

## Setup

A script to look through the archive and do...well, anything you like.
First, we need some other modules set up.

    archivist = require './archivist'
    vainglory = require 'vainglory'
    key = process.env.VG_API_KEY
    archivist.setQueryObject new vainglory key
    archivist.setMatchArchiveFolder 'archive'

## Main function

To use this module, call the following function, with `f` as the function to
run on each match. Do your own initialization before and finalization
afterwards.  This routine handles everything else, including printing
progress reports with `console.log`, if and only if you say so with the
second parameter.

    exports.traverseMatchArchive = ( f = example, showProgress = yes ) ->

Get a list of all the matches we'll loop over:

        ids = archivist.allMatchIdsInArchive()
        if showProgress
            console.log "Found #{ids.length} matches in match archive."

Keep track of how long this took, so the console can see some indication of
progress:

        start = new Date

Run the main loop:

        for id, index in ids

Only show progress every 10 matches, to reduce console spam.

            if index % 10 is 0
                pctDone = 100 * index / ids.length
                if index > 0
                    elapsed = ( new Date ) - start
                    ratio = ( 100 - pctDone ) / pctDone
                    remaining = elapsed * ratio / 60000
                    report = "#{Number( remaining ).toFixed 2} minutes"
                else
                    report = "(no estimate available yet)"
                console.log "Processed #{index}/#{ids.length} matches
                    (#{Number( pctDone ).toFixed 2}%) --
                    time remaining: #{report}"

Run the user's function on this match.

            f archivist.getMatchFromArchive id

Loop complete.

        if showProgress then console.log 'Done.'

## One utility

This is just an example function that gets run if you don't provide your own
processing function.  So you can call `traverseMatchArchive()` and just see
how it goes before you provide your own `f`.

    example = ( match ) ->
        console.log "#{match.data.id} has #{match.telemetry.length} events"
