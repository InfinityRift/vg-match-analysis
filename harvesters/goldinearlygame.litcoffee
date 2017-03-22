
# Harvester for gold farmed in the early game (under 8min)

Total gold you earned from kills in the first 8 minutes of the game.  Track
this by role and skill tier, using the appropriate formuals in [the
utilities module in this folder](utils.litcoffee).  We build this module
using the basic harvester building tools defined in [the basic module in
this folder](basic.litcoffee).

    utils = require './utils'
    ( require './basic' ).setup exports, module.filename,
    ( match, participant ) ->
        total = 0
        matchStartTime = new Date match.telemetry[0].time
        limit = new Date matchStartTime.valueOf() + 8*60*1000 # 8 min
        for event in match.telemetry
            if limit < new Date event.time then break
            if event.payload.Gold? and \
               utils.isEventActor match, participant, event
                total += parseInt event.payload.Gold
        total
