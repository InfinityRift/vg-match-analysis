
# Harvester for total damage done to objectives

Total damage done throughout the match to objectives.  Track this by role
and skill tier, using the appropriate formuals in [the utilities module in
this folder](utils.litcoffee).  We build this module using the basic
harvester building tools defined in [the basic module in this
folder](basic.litcoffee).

    utils = require './utils'
    ( require './basic' ).setup exports, module.filename,
    ( match, participant ) ->
        total = 0
        for event in match.telemetry
            if event.type is 'DealDamage' and \
               /Miner|Kraken|Turret|Crystal/.test event.payload.Target and \
               utils.isEventActor match, participant, event
                total += parseInt event.payload.Delt # oh the spelling :(
        total
