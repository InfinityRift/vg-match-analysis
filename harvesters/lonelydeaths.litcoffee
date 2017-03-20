
# Harvester for number of times the player died alone

Total number of times the player died without any allies nearby.  Track this
by role and skill tier, using the appropriate formuals in [the utilities
module in this folder](utils.litcoffee). We build this module using the
basic harvester building tools defined in [the basic module in this
folder](basic.litcoffee).

First, what does "alone" mean?  Let's say that a player is alone if no
allies are within this radius (in units of in-game meters).

    aloneRadius = 10

Then the counting function.

    utils = require './utils'
    ( require './basic' ).setup exports, module.filename,
    ( match, participant ) ->
        result = 0
        allies = utils.getAllies match, participant
        for event in match.telemetry
            if event.type is 'KillActor' and \
               utils.isEventTarget( match, participant, event )
                time = new Date event.time
                myPos = event.payload.Position
                nearby = no
                for ally in allies
                    if utils.isAlive( match, ally, time )
                        allyPos = utils.lastKnownPosition match, ally, time
                        distance = utils.positionDifference myPos, allyPos
                        if distance < aloneRadius
                            nearby = yes
                            break
                if not nearby then result++
        result
