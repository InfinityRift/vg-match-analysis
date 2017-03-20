
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
        goods = { }
        for own statName of statDescriptions
            compare[statName] =
                utils.getRoleTierData archive, match, participant,
                    statName, [ ]
            if statName in [ 'deaths', 'gotstolen', 'lonelydeaths' ]
                # lower is better
                cutoff = stats.quantile compare[statName], 0.25
                if matchData[statName] < cutoff
                    goods["#{statDescriptions[statName]}"] = 'low'
            else
                # higher is better
                cutoff = stats.quantile compare[statName], 0.75
                if matchData[statName] > cutoff
                    goods["#{statDescriptions[statName]}"] = 'high'

Return Petal's advice.

        role = utils.estimateRole match, participant
        tier = utils.simpleSkillTier participant
        short = ''
        for own key, value of goods
            if short isnt '' then short += ' and '
            short += "#{value} #{key}"
        short = "A #{short}."
        prof : 'Prof. Petal'
        quote : 'I\'ll light up your life!'
        topic : 'Let\'s see where you\'re doing well.'
        short : short
        long : "I'm comparing you only to other tier-#{tier} players in the
            #{role} role."
        data : for own key, value of statDescriptions
            type : 'positionInData'
            value : matchData[key]
            data : compare[key]
            quartiles : [
                stats.min compare[key]
                stats.quantile compare[key], 0.25
                stats.quantile compare[key], 0.50
                stats.quantile compare[key], 0.75
                stats.max compare[key]
            ]
