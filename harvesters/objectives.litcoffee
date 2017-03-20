
# Harvester for damage done to objectives

Add up the damage a player did to objectives in the match.  Track this by
role and skill tier, using the appropriate formuals in
[the utilities module in this folder](utils.litcoffee).
We build this module using the basic harvester building tools defined in
[the basic module in this folder](basic.litcoffee).

Right now this is hackily done, because it seems we get `DealDamage` events
for only damage done to heroes, turrets, the crystal, and the kraken
(both before and after it's captured).

    utils = require './utils'
    ( require './basic' ).setup exports, module.filename,
    ( match, participant ) ->
        total = 0
        for event in match.telemetry
            if event.type is 'DealDamage' and \
               not event.payload.TargetIsHero and \
               utils.isEventActor match, participant, event
                total += parseInt event.payload.Delt # oh the spelling :(
        total
