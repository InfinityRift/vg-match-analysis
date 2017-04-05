
# Doctor Flicker

This is the robot brain of Doctor Flicker, one of the professors at VGU.
He looks into your team's vision.

As with all faculty, he provides one method, `advice`, which takes a match,
participant, and harvested match data, and creates an object of advice, as
documented in [the faculty module](../faculty.litcoffee).  The match is
required to already have its telemetry data embedded.

    exports.advice = ( match, participant, matchData, archive ) ->

For each statistics we care about, get the array of values of it across the
sampled data.

        statNames = [ 'hasflares', 'hastraps' ]
        statDescriptions =
            hasflares : 'percent of time holding flare, gun, or contraption'
            hastraps : 'percent of time holding scout traps or contraption'
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

Return Flicker's advice.

        role = utils.estimateRole match, participant
        tier = utils.simpleSkillTier participant
        data = [ ]
        for i in [0...n]
            data.push
                type : 'positionInData'
                name : statDescriptions[statNames[i]]
                value : Number( thisTime[i] ).toFixed 0
                data : standards[i]
                quartiles : [
                    stats.min standards[i]
                    stats.quantile standards[i], 0.25
                    stats.quantile standards[i], 0.50
                    stats.quantile standards[i], 0.75
                    stats.max standards[i]
                ]
        short = "<ul><li>You were carrying flares/gun/contraption
            #{Number( matchData.hasflares ).toFixed 0}% of the time.</li>
            <li>You were carrying traps/contraption
            #{Number( matchData.hastraps ).toFixed 0}% of the time.</li>
            </ul>"
        if letterIndex < 2
            short += '  Oh dear.  That\'s actually rather shabby.  I bet
                you didn\'t see me coming at all, did you?'
        else if letterIndex > 2
            short += '  Well, now, that\'s good attention to vision indeed,
                my friend.  I\'ll need to be careful around you, won\'t I?'
        else
            short += '  Those grades are average.  Like most students, of
                course.  I\'m sure you\'re special in other ways.'
        prof : 'Dr. Flicker'
        quote : 'No one is in this bush, no one at all!'
        topic : 'Was your team always carrying vision items?'
        short : short
        long : "I'm comparing you only to other
            <strong>tier-#{tier}</strong> players in the
            <strong>#{role}</strong> role.  " + \
            '<br>Dr. Flicker will be expanding his research when more data
            about vision is available, such as when heroes were revealed by
            traps or flares, or damaged by traps, and so on...'
        letter : "#{'FDBCA'[letterIndex]} in vision"
        data : data
