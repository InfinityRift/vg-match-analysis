
# Doctor Vox

    utils = require '../harvesters/utils'
    stats = require 'simple-statistics'
    builds = require './buildtypes'

This is the robot brain of Doctor Vox, one of the professors at VGU.
He looks into your build.

As with all faculty, he provides one method, `advice`, which takes a match,
participant, and harvested match data, and creates an object of advice, as
documented in [the faculty module](../faculty.litcoffee).  The match is
required to already have its telemetry data embedded.

    exports.advice = ( match, participant, matchData, archive ) ->

Get the array for my build and all other builds in the archive for this same
skill tier and role.

        myBuild = matchData.builds
        fullKey = utils.roleTierKey match, participant, 'builds'
        role = utils.estimateRole match, participant
        tier = utils.simpleSkillTier participant
        next = Math.min tier + 1, 10
        fullKey = utils.changeKeyTier fullKey, next
        otherBuilds = archive[fullKey] ? [ ]

If the player had a nonempty build:  Narrow the big list down to just those
that seem to have the same build type as mine (WP, CP, or other). Compute
the number of times each tracked item was seen in the archive, then convert
each of those counts into a frequency. Now look for really commonly
purchased things that they did not purchase, so we can give those as
suggestions.

        if myBuild.length > 0
            myBuildType = builds.typeOfBuild myBuild
            peers = ( b for b in otherBuilds \
                when myBuildType is builds.typeOfBuild b )
            numberInTheWild = ( 0 for index in builds.itemList )
            for otherBuild in peers
                numberInTheWild[index]++ for index in otherBuild
            frequencies =
                ( 100 * x / peers.length for x in numberInTheWild )
            myMinFreq = stats.min ( frequencies[i] for i in myBuild )
            whatIDidntBuy = ( index \
                for index in [0...builds.itemList.length] \
                when index not in myBuild \
                and frequencies[index] > myMinFreq )
            whatIDidntBuy.sort ( a, b ) -> frequencies[b] - frequencies[a]

If the player had an empty build:  Just rank all items by most commonly
purchased in the same role and tier.

        else
            numberInTheWild = ( 0 for index in builds.itemList )
            for otherBuild in otherBuilds
                numberInTheWild[index]++ for index in otherBuild
            frequencies = ( 100 * x / otherBuilds.length \
                for x in numberInTheWild )
            whatIDidntBuy = [0...builds.itemList.length]
            whatIDidntBuy.sort ( a, b ) -> frequencies[b] - frequencies[a]

Now generate some build advice from the `whatIDidntBut` list.

        if whatIDidntBuy.length >= 2
            long = "There are some items you might try,
                because they're favored by #{role} players in tier #{next}.
                <ul>
                <li><strong>#{builds.itemList[whatIDidntBuy[0]]}</strong>
                shows up
                in #{Number( frequencies[whatIDidntBuy[0]] ).toFixed 0}% of
                the builds.</li>
                <li><strong>#{builds.itemList[whatIDidntBuy[1]]}</strong>
                shows up
                in #{Number( frequencies[whatIDidntBuy[1]] ).toFixed 0}% of
                them.</li>
                </ul>"
        else if whatIDidntBuy.length is 1
            long = "There is one item you might try,
                because it's favored by #{role} players in tier #{next}:<br>
                <strong>#{builds.itemList[whatIDidntBuy[0]]}</strong>
                shows up
                in #{Number( frequencies[whatIDidntBuy[0]] ).toFixed 0}% of
                the builds.  But I don't have any other tips -- you bought
                great."
        else
            long = "Dude, usually I have some tips of what you should have
                bought instead.  But man, you're buying right what's in the
                meta for #{role} heroes in tier #{tier}.  Rock on."

Dr. Vox grades you based on how common your build was.  Don't buy weird
stuff.

        if myBuild.length is 0
            grade = 'F'
        else
            freq = stats.mean ( frequencies[i] for i in myBuild )
            if freq < 15 then grade = 'F'
            else if freq < 30 then grade = 'D'
            else if freq < 45 then grade = 'C'
            else if freq < 60 then grade = 'B'
            else grade = 'A'

Create the advice texts.

        if myBuild.length is 0
            topic = 'Dude, what did you buy?  I see absolutely no tier 3
                items here at all.  That\'s...a fail, in my class.'
            short = if tier < 10
                "I'll suggest some tier 3 items you could have bought, from
                what's most popular among <strong>#{role} players in the
                tier <i>above</i> yours.</strong>
                <br>Wait...you didn't do that troll move where you sell
                your build back at the end of the match, did you?
                That is sooooo kindergarten.  At VGU, that earns an F."
            else
                "Normally I compare your builds with those in the next tier
                up, to help players improve.  But you're Vainglorious, man,
                so like, that's awesome, except that why didn't you buy any
                items!?  Were you trolling?  Yeah, that was mature.
                Whatever.  I'll just list some popular items bought
                by Vainglorious players in the #{role} role."
        else
            topic = 'Dude, what did you buy?  You gotta know what
                everybody\'s doing, man, and go with it.'
            short = if tier < 10
                "To help you improve, I'm comparing your build to those of
                <strong>#{role} players in the tier <i>above</i>
                yours.</strong>  Overall, you built in line with about
                #{Number( freq ).toFixed 0}% of those players.
                See the crazy bars to the right."
            else
                "Normally I compare your builds with those in the next tier
                up, to help players improve.  But you're Vainglorious, man,
                so like, that's awesome.  I'll just compare you to other
                Vainglorious players in the #{role} role.  You built in line
                with about #{Number( freq ).toFixed 0}% of them.
                See the crazy bars to the right."
        prof : 'Dr. Vox'
        quote : 'These guys are waaay too into these crystal things.'
        topic : topic
        short : short
        long : long
        letter : "#{grade} on your build"
        data : if myBuild.length > 0 then [
            type : 'bars'
            bars : for index in myBuild
                icon : builds.nameToIcon builds.itemList[index]
                type : builds.typeOfItem[builds.itemList[index]]
                title : builds.itemList[index]
                min : 0
                max : 100
                value : frequencies[index]
                percent : frequencies[index]
                label : "#{Number( frequencies[index] ).toFixed 0}%"
        ] else null
