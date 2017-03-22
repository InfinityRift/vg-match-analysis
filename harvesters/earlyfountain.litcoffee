
# How early a captain (or anyone really) bought fountain of renewal

This is a nice statistic to look at for captains, because of how
significant that item is in the game overall.  The earlier they get it, the
stronger their team is.

Track this by role and skill tier, using the appropriate formuals in [the
utilities module in this folder](utils.litcoffee).  We build this module
using the basic harvester building tools defined in [the basic module in
this folder](basic.litcoffee).

    utils = require './utils'
    ( require './basic' ).setup exports, module.filename,
    ( match, participant ) ->

Loop through all events until we find the player's first fountain purchase.

        startTime = new Date match.telemetry[0].time
        for event in match.telemetry
            if event.type is 'BuyItem' and \
               event.payload.Item is 'Fountain of Renewal' and \
               utils.isEventActor match, participant, event
                firstFountainTime = new Date event.time
                return firstFountainTime - startTime

It seems the player did not buy a fountain in this match.  We return -1 in
that case, since that is an impossible time duration, as a flag indicating
no fountain purchase.

        -1
