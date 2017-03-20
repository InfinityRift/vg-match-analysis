
# Harvester for farm stolen away from the player

Total gold enemies earned from jungle creeps they killed in the player's
jungle, throughout the match.  Track this by role and skill tier, using the
appropriate formuals in [the utilities module in this
folder](utils.litcoffee). We build this module using the basic harvester
building tools defined in [the basic module in this
folder](basic.litcoffee).

    utils = require './utils'
    ( require './basic' ).setup exports, module.filename,
    ( match, participant ) ->
        total = 0
        side = utils.sideForParticipant match, participant
        doneByMyTeam = ( event ) ->
            event.payload.Team.toLowerCase() is side.toLowerCase()
        belongsToMe = ( event ) ->
            position = event.payload.Position
            if side is 'left' then position[0] < 0 else position[0] > 0
        for event in match.telemetry
            if event.type is 'KillActor' and \
               /Jungle/.test( event.payload.Killed ) and \
               belongsToMe( event ) and not doneByMyTeam( event )
                total += parseInt event.payload.Gold
        total
