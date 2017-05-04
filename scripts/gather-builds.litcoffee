
# Gathering build data from the match archive

Load the tools for traversing the match archive, and any other needed
modules.

    strider = require '../strider'
    utils = require '../harvesters/utils'
    fs = require 'fs'

Initialize the data we'll be creating.

    counts = { }

Traverse the archive and extend the data.

    strider.traverseMatchArchive ( match ) ->
        for roster in match.rosters
            for participant in roster.participants
                if 10 is utils.simpleSkillTier participant
                    counts[participant.actor] ?= 0
                    counts[participant.actor]++

Print the data.

    # fs.writeFileSync 'positions-in-archive.csv', csvfile
    console.log counts
