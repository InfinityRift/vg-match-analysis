
# Doctor Baron

This is the robot brain of Doctor Baron, one of the professors at VGU.
He looks into your team's ability to focus your damage.

As with all faculty, he provides one method, `advice`, which takes a match,
participant, and harvested match data, and creates an object of advice, as
documented in [the faculty module](../faculty.litcoffee).  The match is
required to already have its telemetry data embedded.

    exports.advice = ( match, participant, matchData, archive ) ->

        utils = require '../harvesters/utils'
        stats = require 'simple-statistics'
        role = utils.estimateRole match, participant
        tier = utils.simpleSkillTier participant

First loop through the telemetry data and for every 2-second interval in
which the player in question hit an enemy, create a list of that interval's
DealDamage events.  The result of this pass is thus a list of lists of
events, each sublist for a separate 2-second interval.

        intervals = { }
        lastSeenAt = { }
        startTime = new Date match.telemetry[0].time
        for event in match.telemetry
            if utils.eventActorIsOnMyTeam match, participant, event

Because `DealDamage` events don't have position data, we have to track that
in any other event we can, and copy it over to `DealDamage` events.

                actor = utils.correctHeroName event.payload.Actor
                if event.payload.Position?
                    lastSeenAt[actor] = event.payload.Position

When we see `DealDamage` events, archive them by the 2-second interval in
which they happened, and add position data if needed.

                if event.type is 'DealDamage' and \
                   event.payload.TargetIsHero
                    event.payload.Position ?= lastSeenAt[actor]
                    time = new Date event.time
                    elapsed = time - startTime
                    intervalIndex = ( elapsed / 2000 ) | 0
                    ( intervals[intervalIndex] ?= [ ] ).push event

Now loop through those lists of interval lists, and classify each one as
good, bad, or neutral teamwork, or shifting between types.

        good = neutral = bad = shifting = 0
        for own index, events of intervals

Create a map for this interval from ally names to the list of enemies that
they attacked.  Each such list should be unique (i.e., don't list an enemy
more than once even if it were hit more than once by that ally).

            targetsOfAlly = { }
            positionOfAlly = { }
            for event in events
                ally = utils.correctHeroName event.payload.Actor
                target = utils.correctHeroName event.payload.Target
                targetsOfAlly[ally] ?= [ ]
                if target not in targetsOfAlly[ally]
                    targetsOfAlly[ally].push target
                positionOfAlly[ally] ?= event.payload.Position

If the participant isn't among the attacking allies, ignore this interval.

            myPosition = positionOfAlly[participant.actor]
            continue unless myPosition?

Ignore every interval in which there weren't allies nearby, so no issue of
team focus arises.

            nearbyRadius = 10
            keys = Object.keys positionOfAlly
            for ally in keys
                if ally is participant.actor then continue
                distance = utils.positionDifference myPosition,
                    positionOfAlly[ally]
                if distance > nearbyRadius
                    delete positionOfAlly[ally]
                    delete targetsOfAlly[ally]
            nearbyAllies = Object.keys positionOfAlly
            continue if nearbyAllies.length <= 1

If any of the player or their allies were hitting multiple enemies during
the interval, classify it as one in which they were shifting focus among
enemies.

            wereShifting = no
            for own ally, targets of targetsOfAlly
                if targets.length > 1
                    wereShifting = yes
                    break
            if wereShifting
                shifting++
                continue

If the player and all nearby allies were hitting the same enemy, classify
that as good teamwork.

            myTarget = targetsOfAlly[participant.actor][0]
            for own ally, targets of targetsOfAlly
                if targets[0] isnt myTarget
                    myTarget = null
                    break
            if myTarget?
                good++
                continue

If the player and each nearby ally were each hitting a different enemy,
classify that as bad teamwork.

            allTargets = [ ]
            for own ally, targets of targetsOfAlly
                if targets[0] not in allTargets
                    allTargets.push targets[0]
            if targets.length is nearbyAllies.length
                bad++
                continue

The only other possibility is that all three members of the player's team
were near together, and together they were focusing 2 enemies.  I'll call
that neutral teamwork (not bad, not good).

            neutral++

Convert all scores to percentages.

        total = good + neutral + bad + shifting
        good = good * 100 / total
        neutral = neutral * 100 / total
        bad = bad * 100 / total
        shifting = shifting * 100 / total

The player's score is going to be the percent of time they had neutral or
good teamwork.

        score = neutral + good
        grade = ( pct ) ->
            return 0 if pct < 40
            return 1 if pct < 60
            return 2 if pct < 75
            return 3 if pct < 90
            4
        long = "<ul>
            <li><strong>Good teamwork</strong> is when you and any nearby
            allies are targeting your attacks at the same enemy hero.</li>
            <li><strong>Bad teamwork</strong> is when you're all hitting
            different enemies. Don't do that.</li>
            <li><strong>Shifting teamwork</strong> means you were changing
            targets, which is fine to do sometimes, but not constantly.</li>
            <li><strong>Neutral teamwork</strong> is everything
            else.</li></ul>"
        short = "<strong>#{Number( score ).toFixed 0}%</strong> of your
            team fights included <strong>good or neutral teamwork</strong>."
        role = utils.estimateRole match, participant
        if role is 'captain'
            short += '  You can improve this number as captain by pinging
                which enemy you want your allies to focus.'
        else
            short += '  You can improve this number by watching which enemy
                your captain wants you to focus, and following their lead.'

Return Baron's advice.

        prof : 'Dr. Baron'
        quote : 'Focus is good, but kill everything just in case.'
        topic : 'We better look at how well your team is focusing enemy
            heroes.'
        short : short
        long : long
        letter : 'FDCBA'[grade score]
        data : [
            type : 'pie'
            portions :
                'good teamwork' : good
                'bad teamwork' : bad
                'shifting focus' : shifting
                'neutral' : neutral
        ]
