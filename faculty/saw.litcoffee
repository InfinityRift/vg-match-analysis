
# Doctor SAW

This is the robot brain of Doctor SAW, one of the professors at VGU.
He looks into your damage output.

As with all faculty, he provides one method, `advice`, which takes a match,
participant, and harvested match data, and creates an object of advice, as
documented in [the faculty module](../faculty.litcoffee).  The match is
required to already have its telemetry data embedded.

    exports.advice = ( match, participant, matchData, archive ) ->

For each statistics we care about, get the array of values of it across the
sampled data.

        statNames = [
            'dmgheroes'
            'dpsheroes'
            'objectives'
            'dpsobjectives'
        ]
        statDescriptions =
            dmgheroes : 'damage done to enemies'
            dpsheroes : 'highest dps against enemies'
            objectives : 'damage done to objectives'
            dpsobjectives : 'highest dps against objectives'
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

Return SAW's advice.

        role = utils.estimateRole match, participant
        tier = utils.simpleSkillTier participant
        short = ''
        if percentiles[0] + percentiles[1] < 100
            short += 'You\'re not hitting the enemies hard, mate.  Gotta
                make \'em bleed.'
        if percentiles[0] + percentiles[1] > 150
            short += 'You\'re really punishing the enemies.  Keep it up.
                Don\'t slack on the push-ups, either.'
        if percentiles[1] + percentiles[2] < 100
            short += 'Your job is to push turrets.  You\'re slackin\'!'
        if percentiles[1] + percentiles[2] > 150
            short += 'I love your persistence in lane.  A turret is no match
                for a mad cannon, is it?'
        if short is ''
            short = 'You\'re not doing bad, but not really lighting \'em up
                either.  Have you tried three sorrowblades at once yet?'
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
        prof : 'Dr. SAW'
        quote : 'Here comes the pain!'
        topic : 'How\'s your damage output, mate?'
        short : short
        long : "I'm comparing you only to other
            <strong>tier-#{tier}</strong> players in the
            <strong>#{role}</strong> role.  " + [
                'You seem to need some more red items.  Or more time spent
                 with your finger on the trigger.  You know to get Bonesaw
                 if they build brown, right?'
                'Average damage is just average.  Maybe you need some
                 cardio to go with your bench work.'
                'You\'re above average.  Alright.'
                'Now this is some good damage output.  You\'re making the
                 old man proud over here.'
                'Now that\'s what I call some pain!  Nice work!'
            ][letterIndex]
        letter : "#{'FDBCA'[letterIndex]} in damage output"
        data : data
