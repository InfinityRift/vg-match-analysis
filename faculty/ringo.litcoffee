
# Professor Ringo

This is the robot brain of Professor Ringo, one of the professors at VGU.
He focuses on your gold earned at various game phases.

As with all faculty, he provides one method, `advice`, which takes a match,
participant, and harvested match data, and creates an object of advice, as
documented in [the faculty module](../faculty.litcoffee).  The match is
required to already have its telemetry data embedded.

    exports.advice = ( match, participant, matchData, archive ) ->

For each statistics we care about, get the array of values of it across the
sampled data.

        statNames = [ 'goldinearlygame', 'goldinmidgame', 'goldinlategame' ]
        statDescriptions =
            goldinearlygame : 'gold earned in the early game'
            goldinmidgame : 'gold earned in the mid game'
            goldinlategame : 'gold earned in the late game'
        n = statNames.length
        utils = require '../harvesters/utils'
        stats = require 'simple-statistics'
        percentile = ( data, observation ) ->
            numberBelowObservation = 0
            for datum in data
                if datum < observation then numberBelowObservation++
            100 * numberBelowObservation / data.length
        lookup = ( name ) ->
            utils.getRoleTierData archive, match, participant, name, [ ]
        standards = ( lookup name for name in statNames )
        thisTime = ( matchData[name] for name in statNames )
        percentiles =
            ( percentile standards[i], thisTime[i] for i in [0...n] )
        average = stats.mean percentiles
        if average < 40 then letterIndex = 0
        else if average < 60 then letterIndex = 1
        else if average < 75 then letterIndex = 2
        else if average < 90 then letterIndex = 3
        else letterIndex = 4

Return Ringo's advice.

        role = utils.estimateRole match, participant
        tier = utils.simpleSkillTier participant
        ordered = percentiles[..]
        ordered.sort ( a, b ) -> a - b
        if percentiles[0] is ordered[2] then best = 0
        else if percentiles[1] is ordered[2] then best = 1
        else best = 2
        if percentiles[0] is ordered[0] then worst = 0
        else if percentiles[1] is ordered[0] then worst = 1
        else worst = 2
        times = [ 'early', 'mid', 'late' ]
        if letterIndex is 4
            short = "I got no advice for you, man.  You're acing this."
        else if ordered[2] - 10 > ordered[1]
            short = "You're doing best in the #{times[best]} game.  Try to
                work on keeping farm up at other times, too."
        else if ordered[0] + 10 < ordered[1]
            short = "You're clearly weak in the #{times[worst]} game.  Pay
                careful attention to farming at that time.  Well, and not
                dying, of course."
        else
            short = "You're consistent across all three major phases of the
                game, so any improvement will probably effect your whole
                game."
        data = [ ]
        for i in [0...n]
            data.push
                type : 'positionInData'
                name : statDescriptions[statNames[i]]
                value : thisTime[i]
                data : standards[i]
                quartiles : [
                    stats.min standards[i]
                    stats.quantile standards[i], 0.25
                    stats.quantile standards[i], 0.50
                    stats.quantile standards[i], 0.75
                    stats.max standards[i]
                ]
        prof : 'Prof. Ringo'
        quote : 'Ha!  I don\'t miss.'
        topic : 'Let\'s talk about farming gold.'
        short : short
        long : "I'm comparing you only to other
            <strong>tier-#{tier}</strong> players in the
            <strong>#{role}</strong> role.  " + [
                'You\'re, like, below average all the time.  Have you tried
                 drinking?  Just sayin\', it could help.'
                'You\'re doing about average.  Focus on those last
                 hits, man.  Ya gotta climb if you want to get out of the
                 Undersprawl.'
                'You\'re above average.  Meh.'
                'Dude, I\'m proud.  You\'re really getting those last hits.'
                'You don\'t miss either!  Bottoms up, bro.'
            ][letterIndex]
        letter : "#{'FDBCA'[letterIndex]} in farming"
        data : data
