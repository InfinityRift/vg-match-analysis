
# Gathering position data from the match archive

Load the tools for traversing the match archive, and any other needed
modules.

    strider = require '../strider'
    fs = require 'fs'

Initialize the data we'll be creating.

    csvfile = ''

Traverse the archive and extend the data.

    strider.traverseMatchArchive ( match ) ->
        for event in match.telemetry
            if event.type is 'KillActor' and event.payload.TargetIsHero
                p = event.payload.Position
                csvfile += "#{event.payload.Team},#{p.join ','}\n"

Save the data.

    fs.writeFileSync 'deaths-in-archive.csv', csvfile
