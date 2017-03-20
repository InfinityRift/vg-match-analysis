
# Death harvester

Count the total number of deaths the player had in the match.  Track this by
role and skill tier, using the appropriate formuals in
[the utilities module in this folder](utils.litcoffee).
We build this module using the basic harvester building tools defined in
[the basic module in this folder](basic.litcoffee).

    utils = require './utils'
    ( require './basic' ).setup exports, 'deaths', ( match, participant ) ->
        count = 0
        for event in match.telemetry
            if event.type is 'KillActor' and \
               utils.isEventTarget match, participant, event
                count++
        count
