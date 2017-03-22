
# How early you bought your second Tier-3 support item

This is a nice statistic to look at for captains.  Although usually you're
buying Fountain of Renewal first, so finds your first Tier-3 support
purchase thereafter, it really just measures any second Tier-3 support
purchase, which may or may not be fountain, and may or may not follow
fountain.  The measurement is how many seconds of game time have elapsed
before that second Tier-3 support item was purchased.

Here are the items that count as Tier-3 support items.  Basically, it's
anything with team utility, such as an activatable that helps your team, or
the objective-pushing power of Stormcrown.

    tier3SupportItems = [
        'Contraption'
        'Nullwave Gauntlet'
        'Stormcrown'
        'War Treads'
        'Atlas Pauldron'
        'Fountain of Renewal'
        'Crucible'
    ]

Track this by role and skill tier, using the appropriate formuals in [the
utilities module in this folder](utils.litcoffee).  We build this module
using the basic harvester building tools defined in [the basic module in
this folder](basic.litcoffee).

    utils = require './utils'
    ( require './basic' ).setup exports, module.filename,
    ( match, participant ) ->

Loop through all events until we find the player's first fountain purchase.

        startTime = new Date match.telemetry[0].time
        howManyPurchased = 0
        for event in match.telemetry
            if event.type is 'BuyItem' and \
               utils.isEventActor match, participant, event
                if event.payload.Item in tier3SupportItems
                    if ++howManyPurchased is 2
                        secondSupportTime = new Date event.time
                        return secondSupportTime - startTime

It seems the player did not buy two Tier-3 support items in this match.  We
return -1 in that case, since that is an impossible time duration, as a flag
indicating no such purchase.

        -1
