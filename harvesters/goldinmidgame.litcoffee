
# Harvester for gold farmed in the mid game (8min to 15min)

Total gold you earned from kills in the middle of the game (from 8 minutes
in until 15 minutes in).  Track this by role and skill tier, using the
appropriate formuals in [the utilities module in this
folder](utils.litcoffee).  We build this module using the basic harvester
building tools defined in [the basic module in this
folder](basic.litcoffee).

    utils = require './utils'
    ( require './basic' ).setup exports, module.filename,
    ( match, participant ) ->
        total = 0
        matchStartTime = new Date match.telemetry[0].time
        leftLimit = new Date matchStartTime.valueOf() + 8*60*1000 # 8 min
        rightLimit = new Date matchStartTime.valueOf() + 15*60*1000 # 15 min
        for event in match.telemetry
            if leftLimit > new Date event.time then continue
            if rightLimit < new Date event.time then break
            if event.payload.Gold? and \
               utils.isEventActor match, participant, event
                total += parseInt event.payload.Gold
        total
