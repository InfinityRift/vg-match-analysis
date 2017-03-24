
# Doctor Vox

    utils = require '../harvesters/utils'
    harvester = require '../harvesters/builds'

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
        next = Math.max tier + 1, 10
        fullKey = utils.changeKeyTier fullKey, next
        otherBuilds = archive[fullKey] ? [ ]

Narrow that big list down to just those that seem to have the same build
type as mine (WP, CP, or other).

        myBuildType = typeOfBuild myBuild
        peers = ( b for b in otherBuilds when myBuildType is typeOfBuild b )

Compute the number of times each tracked item was seen in the archive,
then convert each of those counts into a frequency.

        numberInTheWild = ( 0 for index in itemList )
        for otherBuild in peers
            numberInTheWild[index]++ for index in otherBuild
        frequencies = ( 100 * x / peers.length for x in numberInTheWild )

Dr. Vox grades you based on how common your build was.  Don't buy weird
stuff.

        stats = require 'simple-statistics'
        freq = stats.mean ( frequencies[i] for i in myBuild )
        if freq < 20 then grade = 'F'
        else if freq < 40 then grade = 'D'
        else if freq < 60 then grade = 'C'
        else if freq < 80 then grade = 'B'
        else grade = 'A'

Now look for really commonly purchased things that they did not purchase,
so we can give those as suggestions.

        myMinFreq = stats.min ( frequencies[i] for i in myBuild )
        whatIDidntBuy = ( index for index in [0...itemList.length] \
            when index not in myBuild and frequencies[index] > myMinFreq )
        whatIDidntBuy.sort ( a, b ) -> frequencies[b] - frequencies[a]
        if whatIDidntBuy.length >= 2
            long = "There are some items you might try,
                because they're favored by #{role} players in tier #{next}.
                <ul>
                <li><strong>#{itemList[whatIDidntBuy[0]]}</strong> shows up
                in #{Number( frequencies[whatIDidntBuy[0]] ).toFixed 0}% of
                the builds.</li>
                <li><strong>#{itemList[whatIDidntBuy[1]]}</strong> shows up
                in #{Number( frequencies[whatIDidntBuy[1]] ).toFixed 0}% of
                them.</li>
                </ul>"
        else if whatIDidntBuy.length is 1
            long = "There is one item you might try,
                because it's favored by #{role} players in tier #{next}:<br>
                <strong>#{itemList[whatIDidntBuy[0]]}</strong> shows up
                in #{Number( frequencies[whatIDidntBuy[0]] ).toFixed 0}% of
                the builds.  But I don't have any other tips -- you bought
                great."
        else
            long = "Dude, usually I have some tips of what you should have
                bought instead.  But man, you're buying right what's in the
                meta for #{role} heroes in tier #{tier}.  Rock on."

Create the advice texts.

        prof : 'Dr. Vox'
        quote : 'These guys are waaay too into these crystal things.'
        topic : 'Dude, what did you buy?  You gotta know what everybody\'s
            doing, man, and go with it.'
        short : if tier < 10
            "To help you improve, I'm comparing your build to those of
            <strong>#{role} players in the tier <i>above</i>
            yours.</strong>  Overall, you built in line with about
            #{Number( freq ).toFixed 0}% of those players.
            See the crazy bars to the right."
        else
            "Normally I builds with those in the next tier up, to help
            players learn.  But you're Vainglorious, man, so like, that's
            awesome.  I'll just compare you to other Vainglorious players
            in the #{role} role.  You built in line with about
            #{Number( freq ).toFixed 0}% of them.
            See the crazy bars to the right."
        long : long
        letter : grade
        data : [
            type : 'bars'
            bars : for index in myBuild
                icon : nameToIcon itemList[index]
                type : typeOfItem[itemList[index]]
                title : itemList[index]
                min : 0
                max : 100
                value : frequencies[index]
                percent : frequencies[index]
                label : "#{Number( frequencies[index] ).toFixed 0}%"
        ]

A dictionary mapping all the items we track with
[the builds harvester](../harvesters/builds.litcoffee) to a classification
into WP, CP, D(efense), or U(tility).

    typeOfItem =
        'Sorrowblade' : 'WP'
        'Shatterglass' : 'CP'
        'Tornado Trigger' : 'WP'
        'Metal Jacket' : 'D'
        'Clockwork' : 'CP'
        'Serpent Mask' : 'WP'
        'Tension Bow' : 'WP'
        'Bonesaw' : 'WP'
        'Shiversteel' : 'U'
        'Frostburn' : 'CP'
        'Fountain of Renewal' : 'D'
        'Crucible' : 'D'
        'Journey Boots' : 'U'
        'Tyrant\'s Monocle' : 'WP'
        'Aftershock' : 'CP'
        'Broken Myth' : 'CP'
        'War Treads' : 'U'
        'Atlas Pauldron' : 'D'
        'Aegis' : 'D'
        'Breaking Point' : 'WP'
        'Alternating Current' : 'CP'
        'Eve of Harvest' : 'CP'
        'Contraption' : 'U'
        'Halcyon Chargers' : 'U'
        'Stormcrown' : 'U'
        'Poisoned Shiv' : 'WP'
        'Nullwave Gauntlet' : 'U'
        'Echo' : 'CP'
        'Slumbering Husk' : 'D'
    itemList = harvester.getTrackedItems()

A utility for looking at a build and deciding if it's a WP build, a CP
build, or something else.

    typeOfBuild = ( build ) ->
        types = WP : 0, CP : 0, D : 0, U : 0
        types[typeOfItem[itemList[index]]]++ for index in build
        if types.WP >= 2 and types.CP < 2 and types.D <= 2 and types.U < 2
            return 'WP'
        if types.CP >= 2 and types.WP < 2 and types.D <= 2 and types.U < 2
            return 'CP'
        'other'

And the icon name can be computed for each item as follows.

    nameToIcon = ( name ) ->
        name.replace ' ', '-'
        .replace '\'', ''
        .toLowerCase()
