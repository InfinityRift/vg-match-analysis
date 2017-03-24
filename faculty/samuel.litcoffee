
# Master Samuel

    utils = require '../harvesters/utils'

This is the robot brain of Master Samuel, one of the professors at VGU.
He looks into your death times and places.

As with all faculty, he provides one method, `advice`, which takes a match,
participant, and harvested match data, and creates an object of advice, as
documented in [the faculty module](../faculty.litcoffee).  The match is
required to already have its telemetry data embedded.

    exports.advice = ( match, participant, matchData, archive ) ->

We'll compute a lot of things from telemetry data, so before we begin, we
initialize some data structures for us to fill in over time.

        deathRegions = { }
        deathTimes = { }
        lastSeenAt = { }
        deathsWithFriends = { }
        situations = { }
        total = 0
        gameStartTime = new Date match.telemetry[0].time

We'll also need some utility functions for use in the telemetry loop.  There
are a few defined at the end of this file, plus some here.

        mySide = utils.sideForParticipant match, participant
        elapsed = ( event ) -> ( new Date event.time ) - gameStartTime
        phaseOf = ( ms ) ->
            return 'early' if ms < 8*60*1000
            return 'mid' if ms < 15*60*1000
            return 'late'
        allies = utils.getAllies match, participant
        count = ( n ) -> if n is 1 then '1 death' else "#{n} deaths"

We need a pre-loop of telemetry data to mark the times of all ally and enemy
deaths, for later querying in the main loop.

        enemyDeathTimes = [ ]
        friendDeathTimes = [ ]
        for event in match.telemetry
            if event.type is 'KillActor' and \
               event.payload.TargetIsHero
                time = elapsed event
                if utils.eventTargetIsOnMyTeam match, participant, event
                    friendDeathTimes.push time
                else
                    enemyDeathTimes.push time

Now the telemetry loop.

        for event in match.telemetry

First, pay attention to where anyone on my team is at any given moment, so I
can tell who was near me when I died, if anyone

            if utils.eventActorIsOnMyTeam match, participant, event
                actor = utils.correctHeroName event.payload.Actor
                if event.payload.Position?
                    lastSeenAt[actor] = event.payload.Position

Now we look at my death events.

            if event.type is 'KillActor' and \
               utils.isEventTarget match, participant, event
                total++

Record regions/sides where I died:

                pos = event.payload.Position
                name = regionNameForPoint pos
                deathRegions[name] ?= 0
                deathRegions[name]++
                side = if pos[0] < 0 then 'left' else 'right'
                deathRegions[side] ?= 0
                deathRegions[side]++

Record time phases in which I died:

                phase = phaseOf time = elapsed event
                deathTimes["#{phase} game"] ?= 0
                deathTimes["#{phase} game"]++

How many allies were nearby when you died?

                numNearby = 0
                nearbyRadius = 10
                for ally in allies
                    allyPos = lastSeenAt[ally.actor]
                    distance = utils.positionDifference pos, allyPos
                    if distance < nearbyRadius then numNearby++
                key = [
                    'all alone'
                    'one ally near'
                    'both allies near'
                ][numNearby]
                deathsWithFriends[key] ?= 0
                deathsWithFriends[key]++

What other deaths happened around then?

                timeRadius = 10*1000
                ally = 0 # will always end up at >= 1, because I died
                for t in friendDeathTimes
                    if Math.abs( time - t ) < timeRadius then ally++
                enemy = 0
                for t in enemyDeathTimes
                    if Math.abs( time - t ) < timeRadius then enemy++
                if ally is enemy
                    situations.trade ?= 0
                    situations.trade++
                else if ally is 1
                    if enemy is 0
                        situations.fail ?= 0
                        situations.fail++
                    else
                        situations.worthIt ?= 0
                        situations.worthIt++
                else
                    if enemy is 0
                        situations.slaughter ?= 0
                        situations.slaughter++
                    else if enemy < ally
                        situations.badTrade ?= 0
                        situations.badTrade++
                    else
                        situations.ace ?= 0
                        situations.ace++

Compute a grade.  We'll rack up points for things that went badly.

        badPoints = total + ( deathRegions[mySide] ? 0 ) \
                          + ( situations.fail ? 0 ) \
                          + ( situations.slaughter ? 0 ) \
                          + ( situations.badTrade ? 0 )
        if badPoints > 16 then grade = 'F'
        else if badPoints > 12 then grade = 'D'
        else if badPoints > 8 then grade = 'C'
        else if badPoints > 4 then grade = 'B'
        else grade = 'A'

Now format the data we gathered in a way we can report it.  First, death
regions.

        zoneTable =
            type : 'table'
            compact : yes
            rows : [
                headings : [ 'Region', 'Deaths' ]
            ]
        orderedZones = Object.keys deathRegions
        orderedZones.sort ( a, b ) ->
            maybe = deathRegions[b] - deathRegions[a]
            if maybe isnt 0 then return maybe
            if a is b then 0 else if a > b then 1 else -1
        for zone in orderedZones
            if zone isnt 'left' and zone isnt 'right'
                zoneTable.rows.push data : [ zone, deathRegions[zone] ]

Now, death times.

        deathTimeTable = { }
        for own key, value of deathTimes
            deathTimeTable["#{key}: #{count value}"] = value
        timePie =
            type : 'pie'
            portions : deathTimeTable

Now, information about how many allies were nearby.

        allyDeathTable = { }
        for own key, value of deathsWithFriends
            allyDeathTable["#{key}: #{count value}"] = value
        allyPie =
            type : 'pie'
            portions : allyDeathTable

Lastly, information about other deaths that took place around the same time.

        times = ( n ) ->
            return '<strong>once</strong>' if n is 1
            return '<strong>twice</strong>' if n is 2
            "<strong>#{n} times</strong>"
        Times = ( n ) ->
            times( n ).replace( 'once', 'Once' ).replace( 'twice', 'Twice' )
        if total is 0
            long = 'Normally I would talk about whether your deaths were a
                waste or a good trade.  But you didn\'t die.  Well, maybe
                next time.'
        else
            long = [ ]
            if situations.slaughter > 0
                long.push "You let them kill two or three of you
                    #{times situations.slaughter} without killing any of
                    them.  Avoid that situation." + \
                    if situations.slaughter > 2
                        "  I shouldn't have to explain this to you."
                    else ''
            if situations.badTrade > 0
                long.push "You let them kill two or three of you
                    #{times situations.badTrade} but didn't kill as many in
                    return.  Points off." + \
                    if situations.badTrade > 2
                        "  Since you did this #{times situations.badTrade},
                        I'll assume it's a problem with simple counting."
                    else ''
            if situations.fail > 0
                long.push "You died alone #{times situations.fail} without
                    taking any enemies with you.
                    Honestly, we all die alone, in the end.  But try to be
                    careful when you don't have allies nearby." + \
                    if situations.fail > 2
                        '  This is within your control, and it\'s
                        important, given how often it happened.'
                    else ''
            if situations.trade > 0
                long.push "Team fights came out as an even trade
                    #{times situations.trade}.
                    No criticisms there.  No praises either."
            if situations.worthIt > 0
                long.push "#{Times situations.worthIt} you sacrificed
                    yourself while you and your pals took out two or three
                    of them.  Much as I hate altruism, that's totally
                    worth it."
            if situations.ace > 0
                long.push "You aced them #{times situations.ace}.
                    That's it.  Embrace your anger.  Also, bonus points in
                    my class."
            if deathRegions[mySide] > 0
                long.push "You died #{times deathRegions[mySide]} on your
                    own side of the map.  Try to use your turrets, sentry,
                    and allies to better effect."
            if total - deathRegions[mySide] > 0
                long.push "You died #{times total - deathRegions[mySide]} on
                    the enemies' side of the map.  I love that agression.
                    Just don't let it get out of control."
            if total < 3
                long.unshift "You only died #{times total}.  You're going
                    to do well in my class."
            if total > 6
                long.unshift "You died #{times total}??  You know that most
                    people consider deaths bad, right?"
            long = "<ul><li>#{long.join '</li><li>'}</li></ul>"

Return an advice object (finally!).

        prof : 'Master Samuel'
        quote : 'Want me to kiss your boo-boos?'
        topic : 'Where and when did you die?  Despite how delightful that
            is to talk about, maybe by studying it you can learn to avoid
            common mistakes.'
        short : if total > 0
            'I have a lot to say, and I wouldn\'t want you to get lost,
            so I\'ll make some tables and pictures.<br>Study them carefully.
            You have to be <i>smart</i> to get it.'
        else
            'You didn\'t die in this match?  And I was so hoping to talk
            about your stupidity.  Oh well.  Good job, I guess.'
        long : long
        letter : grade
        data : if total > 0
            [
                zoneTable
                timePie
                allyPie
            ]
        else
            null

These points are the center of each region, and help us partition the map
using the idea of a
[Voronoi diagram](https://en.wikipedia.org/wiki/Voronoi_diagram).

    mapRegionCenters =
        "Left base" : [ -80, -7 ]
        "Right base" : [ 80, -7 ]
        "Left crystal" : [ -75, 20 ]
        "Right crystal" : [ 75, 20 ]
        "Left choke point" : [ -52, 3 ]
        "Right choke point" : [ 52, 3 ]
        "Left second turret" : [ -36, 1 ]
        "Right second turret" : [ 36, 1 ]
        "Left first turret" : [ -17, 2 ]
        "Right first turret" : [ 17, 2 ]
        "Left back healer" : [ -40, 20 ]
        "Right back healer" : [ 40, 20 ]
        "Left middle healer" : [ -22, 24 ]
        "Right middle healer" : [ 23, 24 ]
        "Left mustache bush" : [ -8, 13 ]
        "Right mustache bush" : [ 8, 13 ]
        "Left triangle bush" : [ -10, 26 ]
        "Right triangle bush" : [ 10, 26 ]
        "Left crystal sentry" : [ -35, 36 ]
        "Right crystal sentry" : [ 35, 36 ]
        "Left back minions" : [ -44, 32 ]
        "Right back minions" : [ 44, 32 ]
        "Left little minions" : [ -13, 38 ]
        "Right little minions" : [ 13, 38 ]
        "Gold miner/Kraken pit" : [ 0, 23 ]
        "Jungle center" : [ 0, 32 ]
        "Lane center" : [ 1, 3 ]
        "Jungle shop" : [ 0, 45 ]

Here we implement the Voronoi idea by finding the closest region center to
any given point, and returning its name.  This is just a loop through the
above table to find the closest center to the given point.

    regionNameForPoint = ( point ) ->
        shortestDistance = 99999
        regionName = null
        for own name, center of mapRegionCenters
            asIf3D = [ center[0], 0, center[1] ]
            thisDistance = utils.positionDifference asIf3D, point
            if thisDistance < shortestDistance
                shortestDistance = thisDistance
                regionName = name
        regionName
