
# Harvester for average damage a player soaks up per spawn

This is a nice statistic to look at for captains, because if they can soak
up a lot of damage from the other team, but still get out of the fight
alive (either because they know when to flee, or they use fountain and
crucible well, or they protect their team until the team kills the enemies,
whatever) then the captain is doing a good job.

Track this by role and skill tier, using the appropriate formuals in [the
utilities module in this folder](utils.litcoffee).  We build this module
using the basic harvester building tools defined in [the basic module in
this folder](basic.litcoffee).

    utils = require './utils'
    ( require './basic' ).setup exports, module.filename,
    ( match, participant ) ->

Loop through all events to find the total damage taken.

        damageTaken = 0
        for event in match.telemetry
            if event.type is 'DealDamage' and \
               event.payload.TargetIsHero and \
               utils.isEventTarget match, participant, event
                damageTaken += parseInt event.payload.Delt

You might think we just divide that total by the number of deaths, but of
course for matches in which you don't die, that gives an undefined value.
So in reality we divide by the number of deaths plus 1, which is the number
of times you spawned, or the number of "lives" you had in that game.

        damageTaken / ( participant.stats.deaths + 1 )
