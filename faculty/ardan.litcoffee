
# Master Ardan

This is the robot brain of Master SAW, one of the professors at VGU.
He looks into your support play.

As with all faculty, he provides one method, `advice`, which takes a match,
participant, and harvested match data, and creates an object of advice, as
documented in [the faculty module](../faculty.litcoffee).  The match is
required to already have its telemetry data embedded.

    exports.advice = ( match, participant, matchData, archive ) ->

For each statistics we care about, get the array of values of it across the
sampled data.

        statNames = [
            'earlyfountain'
            'secondsupport'
            'dmgperspawn'
            'teamdmgperspawn'
        ]
        utils = require '../harvesters/utils'
        stats = require 'simple-statistics'
        percentile = ( data, observation ) ->
            numberBelowObservation = 0
            for datum in data
                if datum < observation then numberBelowObservation++
            100 * numberBelowObservation / data.length
        lookup = ( name ) ->
            key = utils.roleTierKey match, participant, name
            key = utils.changeKeyRole key, 'captain'
            archive[key] ? [ ]
        standards = ( lookup name for name in statNames )
        thisTime = ( matchData[name] for name in statNames )

Handle the special case when data for the first two statistics is -1.

        standards[0] = ( x for x in standards[0] when x >= 0 )
        standards[1] = ( x for x in standards[1] when x >= 0 )
        percentiles = for statName, index in statNames
            if standards[index].length is 0
                0
            else
                percentile standards[index], thisTime[index]
        if thisTime[0] < 0 then percentiles[0] = 100
        if thisTime[1] < 0 then percentiles[1] = 100
        percentiles[0] = 100 - percentiles[0]
        percentiles[1] = 100 - percentiles[1]

Now compute overall grade.

        average = stats.mean percentiles

Some utilities.

        grade = ( pct ) ->
            return 0 if pct < 40
            return 1 if pct < 60
            return 2 if pct < 75
            return 3 if pct < 90
            4
        sayTime = ( ms ) ->
            secs = ( ms / 1000 ) | 0
            mins = 0
            if secs > 60
                mins = ( secs - secs % 60 ) / 60
                secs = secs % 60
            secs = "#{secs}"
            if secs.length < 2 then secs = "0#{secs}"
            "#{mins}:#{secs}"
        niceNum = ( x ) ->
            if x is 0 then '0'
            if -0.1 < x < 0.1 then return Number( x ).toFixed 3
            if -1 < x < 1 then return Number( x ).toFixed 2
            if -10 < x < 10 then return Number( x ).toFixed 1
            Number( x ).toFixed 0

Return Ardan's advice.

        role = utils.estimateRole match, participant
        tier = utils.simpleSkillTier participant
        long = [ ]
        if role isnt 'captain'
            long.push "It looks like you played #{role} in this match.  I
                only teach captains, really.  I'll give you advice, but it
                won't fit your role."
        if thisTime[0] < 0
            long.push 'You didn\'t buy a Fountain.  Son, captains buy
                Fountains.  Do it.'
        if thisTime[1] < 0
            long.push 'You only bought one team utility item.  I suggest
                you get more than one.  Unless you don\'t like your team.'
        long.push "Your overall scores in this match look better than about
            #{Number( average ).toFixed 0}% of the captains in your skill
            tier."
        if role isnt 'captain' and average > 50
            long[long.length-1] += "  That's pretty sad, since you were
                playing #{role}, as far as I can tell."

Build a table one step at a time.  We could do this as one giant object
literal, but this is nice so that we can insert debugging statement if
needed if something goes wrong.

        table = type : 'table', rows : [ ]
        table.rows.push
            icon : 'fountain'
            headings : [
                'Time to fountain:'
                'Score:'
                'Grade:'
                'Lowest seen:'
            ]
            data : [
                if matchData.earlyfountain >= 0
                    sayTime matchData.earlyfountain
                else
                    'did not buy'
                "#{Number( percentiles[0] ).toFixed 0}%"
                'FDCBA'[grade percentiles[0]]
                if standards[0].length > 0
                    sayTime stats.min standards[0]
                else
                    'no data'
            ]
        table.rows.push
            icon : 'crucible'
            headings : [
                'Second T3 support item:'
                'Score:'
                'Grade:'
                'Lowest seen:'
            ]
            data : [
                if matchData.secondsupport >= 0
                    sayTime matchData.secondsupport
                else
                    'did not buy'
                "#{Number( percentiles[1] ).toFixed 0}%"
                'FDCBA'[grade percentiles[1]]
                if standards[1].length > 0
                    sayTime stats.min standards[1]
                else
                    'no data'
            ]
        table.rows.push
            icon : 'stormguard'
            headings : [
                'Damage taken per spawn:'
                'Score:'
                'Grade:'
                'Highest seen:'
            ]
            data : [
                niceNum matchData.dmgperspawn
                "#{Number( percentiles[2] ).toFixed 0}%"
                'FDCBA'[grade percentiles[2]]
                niceNum stats.max standards[2]
            ]
        table.rows.push
            icon : 'vanguard'
            headings : [
                'Damage team took per spawn:'
                'Score:'
                'Grade:'
                'Highest seen:'
            ]
            data : [
                niceNum matchData.teamdmgperspawn
                "#{Number( percentiles[3] ).toFixed 0}%"
                'FDCBA'[grade percentiles[3]]
                niceNum stats.max standards[3]
            ]

Final result object:

        prof : 'Master Ardan'
        quote : 'I go where I\'m needed.'
        topic : 'Let\'s see how well you helped your team.'
        short : 'I look at damage you took per spawn because captains should
            draw enemy fire.  And live.'
        long : long
        letter : 'FDCBA'[grade average]
        data : [ table ]
