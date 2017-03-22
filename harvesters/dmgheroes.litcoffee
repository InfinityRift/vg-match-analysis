
# Harvester for total damage done to enemy heroes

Total damage done throughout the match to enemy heroes.  Track this by role
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
               event.payload.TargetIsHero and \
               utils.isEventActor match, participant, event
                total += parseInt event.payload.Delt # oh the spelling :(
        total
