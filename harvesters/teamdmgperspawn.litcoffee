
# Harvester for average damage a team soaks up per player spawn

This is a nice statistic to look at for captains, because if their team can
take a lot of damage without dying, then probably the captain is doing
something right (or maybe multiple things, such as leading the team out of a
bad situation, or using fountain and/or crucible well, juggling turret
aggression, etc.).

Track this by role and skill tier, using the appropriate formuals in [the
utilities module in this folder](utils.litcoffee).  We build this module
using the basic harvester building tools defined in [the basic module in
this folder](basic.litcoffee).

    utils = require './utils'
    ( require './basic' ).setup exports, module.filename,
    ( match, participant ) ->

Loop through all events to find the total damage taken by the whole team.

        damageTaken = 0
        for event in match.telemetry
            if event.type is 'DealDamage' and \
               event.payload.TargetIsHero and \
               utils.eventTargetIsOnMyTeam match, participant, event
                damageTaken += parseInt event.payload.Delt

You might think we just divide that total by the number of deaths, but of
course for matches in which no one on your team dies, that gives an
undefined value. So in reality we divide by the number of deaths plus 1
(added up for each player, so a minimum of 3 in a typical match), which is
the number of times you or a teammate spawned, or the number of "lives" your
team had in that game.

        totalSpawns = participant.stats.deaths + 1
        for ally in utils.getAllies match, participant
            totalSpawns += ally.stats.deaths + 1
        damageTaken / totalSpawns
