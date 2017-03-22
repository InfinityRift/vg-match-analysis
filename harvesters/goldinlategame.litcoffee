
# Harvester for gold farmed in the late game (after 15min)

Total gold you earned from kills in the late game (after 15 minutes).  Track
this by role and skill tier, using the appropriate formuals in [the
utilities module in this folder](utils.litcoffee).  We build this module
using the basic harvester building tools defined in [the basic module in
this folder](basic.litcoffee).

    utils = require './utils'
    ( require './basic' ).setup exports, module.filename,
    ( match, participant ) ->
        total = 0
        matchStartTime = new Date match.telemetry[0].time
        leftLimit = new Date matchStartTime.valueOf() + 15*60*1000 # 15 min
        for event in match.telemetry
            if leftLimit > new Date event.time then continue
            if event.payload.Gold? and \
               utils.isEventActor match, participant, event
                total += parseInt event.payload.Gold
        total
