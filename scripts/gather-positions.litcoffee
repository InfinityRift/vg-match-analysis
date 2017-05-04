
# Gathering position data from the match archive

Load the tools for traversing the match archive, and any other needed
modules.

    strider = require '../strider'
    fs = require 'fs'

Initialize the data we'll be creating.

    csvfile = ''

Traverse the archive and extend the data.

    # locs = [ ]
    strider.traverseMatchArchive ( match ) ->
        for event in match.telemetry
            # if event.type is 'DealDamage'
            #     console.log event.payload.Actor,
            #         event.payload.Source
            if p = event.payload.Position
                csvfile += "#{event.payload.Team},#{p.join ','}\n"
                # if event.type is 'KillActor' and \
                #    /turret/i.test JSON.stringify event.payload
                #     loc = "#{p}"
                #     if loc not in locs then locs.push loc

Save the data.

    # fs.writeFileSync 'positions-in-archive.csv', csvfile
    # console.log locs
