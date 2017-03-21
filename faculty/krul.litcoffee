
# Professor Krul

This is the robot brain of Professor Krul, one of the professors at VGU.
He tries to bring out the negative in your game play.

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
                # higher is worse
                cutoff = stats.quantile compare[statName], 0.75
                if matchData[statName] > cutoff
                    include.push statName
                    goods["#{statDescriptions[statName]}"] = 'high'
            else
                # lower is worse
                cutoff = stats.quantile compare[statName], 0.25
                if matchData[statName] < cutoff
                    include.push statName
                    goods["#{statDescriptions[statName]}"] = 'low'

Return Krul's advice.

        role = utils.estimateRole match, participant
        tier = utils.simpleSkillTier participant
        if include.length > 0
            short = ''
            for own key, value of goods
                if short isnt '' then short += ' and '
                short += "#{value} #{key}"
            short = "A #{short}."
        else
            short = 'How impressive...I cannot find a category to
                complain about!'
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
        prof : 'Prof. Krul'
        quote : 'This is your mistake.'
        topic : 'Let\'s see where you\'re doing badly.'
        short : short
        long : "I'm comparing you only to other tier-#{tier} players in the
            #{role} role."
        data : data
