
# Professor Petal

This is the robot brain of Professor Petal, one of the professors at VGU.
She tries to bring out the positive in your game play.

As with all faculty, she provides one method, `advice`, which takes a match,
participant, and harvested match data, and creates an object of advice, as
documented in [the faculty module](../faculty.litcoffee).  The match is
required to already have its telemetry data embedded.

    exports.advice = ( match, participant, matchData, archive ) ->

For each statistics we care about, get the array of values of it across the
sampled data.

        statDescriptions =
            kills : 'number of kills'
            deaths : 'number of deaths'
            gold : 'CS (gold farmed)'
            objectives : 'damage to objectives'
            stealing : 'amount of gold stolen from enemy jungle'
            gotstolen : 'amount of gold enemies stole from your jungle'
            lonelydeaths : 'number of deaths while away from teammates'
        utils = require '../harvesters/utils'
        stats = require 'simple-statistics'
        compare = { }
        include = [ ]
        goods = { }
        for own statName of statDescriptions
            compare[statName] =
                utils.getRoleTierData archive, match, participant,
                    statName, [ ]
            if statName in [ 'deaths', 'gotstolen', 'lonelydeaths' ]
                # lower is better
                cutoff = stats.quantile compare[statName], 0.25
                if matchData[statName] < cutoff
                    include.push statName
                    goods["#{statDescriptions[statName]}"] = 'low'
            else
                # higher is better
                cutoff = stats.quantile compare[statName], 0.75
                if matchData[statName] > cutoff
                    include.push statName
                    goods["#{statDescriptions[statName]}"] = 'high'

Return Petal's advice.

        role = utils.estimateRole match, participant
        tier = utils.simpleSkillTier participant
        if include.length > 0
            short = '<ul>'
            for own key, value of goods
                short += "<li>#{value} #{key}</li>"
            short += '</ul>'
        else
            short = 'Oh noooo...you didn\'t really excel in any category.
                But that\'s okay!
                I\'m sure you\'ll do well in the next match!'
        data = [ ]
        for statName in include
            data.push
                type : 'positionInData'
                name : statDescriptions[statName]
                value : matchData[statName]
                data : compare[statName]
                quartiles : [
                    stats.min compare[statName]
                    stats.quantile compare[statName], 0.25
                    stats.quantile compare[statName], 0.50
                    stats.quantile compare[statName], 0.75
                    stats.max compare[statName]
                ]
        letterIndex = Math.min 2, Math.max 0, include.length - 2
        prof : 'Prof. Petal'
        quote : 'I\'ll light up your life!'
        topic : 'Let\'s see where you\'re doing well.'
        short : short
        long : "I'm comparing you only to other
            <strong>tier-#{tier}</strong> players in the
            <strong>#{role}</strong> role.  " + [
                'I\'d give you a better grade if I had more things to
                 praise -- sorry!'
                'I found three things you\'re doing well -- keep up the
                 good work!'
                'Wow, so many things you\'re doing great at!  Gold star!'
            ][letterIndex]
        letter : 'CBA'[letterIndex]
        data : data
