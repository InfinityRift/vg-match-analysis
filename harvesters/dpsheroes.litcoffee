
# Harvester for highest DPS done to enemy heroes

Highest damage per second done to enemy heroes during the match.  Track this
by role and skill tier, using the appropriate formuals in [the utilities
module in this folder](utils.litcoffee).  We build this module using the
basic harvester building tools defined in [the basic module in this
folder](basic.litcoffee).

This computes a rough DPS by finding all intervals in which the player does
damage to enemy heroes "continuously," meaning no break of >2sec between
hits in that interval.  For each such interval, we find the total damage and
divide by the length of the interval.  We then return the maximum of those
DPS values.  Here is the 2-second constant we use below:

    deltaT = 2000

Feel free to change it if you wish to alter the definition of
"continuously."

    utils = require './utils'
    ( require './basic' ).setup exports, module.filename,
    ( match, participant ) ->
        maxDPS = totalDmgInInterval = 0
        lastHitTime = startOfInterval = null
        for event in match.telemetry
            if event.type is 'DealDamage' and \
               event.payload.TargetIsHero and \
               utils.isEventActor match, participant, event
                now = new Date event.time

If this is the start of an interval, just save it as such.

                if not startOfInterval?
                    lastHitTime = startOfInterval = now
                    totalDmgInInterval = event.payload.Delt # always so sad

Or if it is the continuation of an earlier interval, then accumulate and
update.

                else if now < new Date lastHitTime + deltaT
                    lastHitTime = now
                    totalDmgInInterval += event.payload.Delt # mrr

Otherwise, the interval has ended.  Log its DPS and clear out the interval's
data.

                else
                    duration = lastHitTime - startOfInterval
                    if duration > 0
                        thisDPS = totalDmgInInterval / duration
                        maxDPS = Math.max thisDPS, maxDPS
                    totalDmgInInterval = 0
                    lastHitTime = startOfInterval = null

In the end, return the max DPS found.

        maxDPS
