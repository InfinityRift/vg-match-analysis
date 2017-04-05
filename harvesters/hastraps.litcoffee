
# Harvester for percent of time holding traps

Compute the percentage of the match during which the player was holding a
scout trap or contraption.  No notion of cooldown is taken into account
here.  Just your possession of the item is what's tracked, as a proxy for
your readiness to drop a trap.

Track this by role and skill tier, using the appropriate formuals in [the
utilities module in this folder](utils.litcoffee). We build this module
using the basic harvester building tools defined in [the basic module in
this folder](basic.litcoffee).

    utils = require './utils'
    ( require './basic' ).setup exports, module.filename,
    ( match, participant ) ->

Track these items:

        trackedItems = [ 'Scout Trap', 'Contraption' ]

We will track how much time elapsed in the whole match, compared to how much
time the player was holding one of the tracked items, in these variables.

        timeOfLastEvent = null
        timeHoldingItem = 0
        totalTimeOfMatch = 0
        possessions = { }

Main loop through all match events:

        for event in match.telemetry

Update times and differences.

            timeOfThisEvent = new Date event.time
            timeOfLastEvent ?= timeOfThisEvent
            elapsed = timeOfThisEvent - timeOfLastEvent

Give time-credit for carrying one of the items, if the player has one.

            for itemName in trackedItems
                if possessions[itemName] ? 0 > 0
                    timeHoldingItem += elapsed
                    break

If they bought or sold one of the items we're tracking, note that in the
`possessions` data structure.

            if event.type is 'BuyItem' and \
               utils.isEventActor( match, participant, event ) and \
               event.payload.Item in trackedItems
                possessions[event.payload.Item] ?= 0
                possessions[event.payload.Item]++
            else if event.type is 'SellItem' and \
                    utils.isEventActor( match, participant, event ) and \
                    event.payload.Item in trackedItems
                possessions[event.payload.Item] ?= 0
                possessions[event.payload.Item]--

Update total time and time of last event for next loop iteration.

            totalTimeOfMatch += elapsed
            timeOfLastEvent = timeOfThisEvent

Return the result as a percentage.

        timeHoldingItem * 100 / totalTimeOfMatch
