
# Doctor Kestrel

This is the robot brain of Doctor Kestrel, one of the professors at VGU.
She looks into your counterbuilding (or lack thereof).

As with all faculty, she provides one method, `advice`, which takes a match,
participant, and harvested match data, and creates an object of advice, as
documented in [the faculty module](../faculty.litcoffee).  The match is
required to already have its telemetry data embedded.

    exports.advice = ( match, participant, matchData, archive ) ->

        utils = require '../harvesters/utils'
        stats = require 'simple-statistics'
        builds = require './buildtypes'
        role = utils.estimateRole match, participant
        tier = utils.simpleSkillTier participant

We will need several utility functions to be able to ask questions about
counterbuilding (and just countering in general).  Here are the questions we
will want to be able to ask, and functions that answer each one.

Did my team (or theirs) have a certain hero on it?

        ridx = utils.rosterIndexForParticipant match, participant
        myTeamRoster = -> match.rosters[ridx]
        theirTeamRoster = -> match.rosters[1-ridx]
        teamHadHero = ( teamRoster, heroName, wpOrCp = null ) ->
            if teamRoster.participants?
                teamRoster = teamRoster.participants
            for participant in teamRoster
                if participant.actor is heroName
                    return not wpOrCp? or \
                        wpOrCp is builds.typeOfBuild participant.stats.items
            no

Did I possess a certain item?  Did anyone on my team possess a certain item?

        participantHadItem = ( participant, itemName ) ->
            cleanUp = ( x ) -> x.toLowerCase().replace /'/g, ''
            cleanUp( itemName ) in for item in participant._stats.items
                cleanUp item
        iHadItem = ( itemName ) -> participantHadItem participant, itemName
        teamHadItem = ( itemName, roster = myTeamRoster() ) ->
            if roster.participants? then roster = roster.participants
            for teammate in roster
                if participantHadItem teammate, itemName
                    return teammate.actor
            return no

Utility functions for constructing arrays of results.

        heroAsset = ( roster, hero, wpOrCp, asset ) ->
            if teamHadHero roster, hero, wpOrCp
                [ "#{hero}'s #{asset}" ]
            else
                [ ]
        itemAsset = ( roster, item, more = '' ) ->
            if hero = teamHadItem item, roster
                [ "#{hero}'s #{item} #{more}" ]
            else
                [ ]

Did a team have sources of burst damage?  This includes CP Ringo's ultimate,
CP Kestrel, Celeste's ultimate, CP Baron's ultimate, CP Joule's ultimate, CP
Skaarf's ultimate, and CP SAW's A.  This will return a list of burst damage
sources, or an empty array if there were none.

        burstSources = ( roster ) ->
            [
                heroAsset( roster, 'Ringo', 'CP', 'hellfire brew' )...
                heroAsset( roster, 'Celeste', 'CP', 'solar storm' )...
                heroAsset( roster, 'Baron', 'CP', 'ion cannon' )...
                heroAsset( roster, 'Joule', 'CP', 'big red button' )...
                heroAsset( roster, 'Skaarf', 'CP', 'dragon breath' )...
                heroAsset( roster, 'SAW', 'CP', 'roadie run' )...
                heroAsset( roster, 'Kestrel', 'CP', 'whole kit' )...
            ]

Did a team have sources of healing?  This will return a list of healing
sources, or an empty array if there were none.

        healSources = ( roster ) ->
            [
                itemAsset( roster, 'Fountain of Renewal' )...
                itemAsset( roster, 'Eve of Harvest' )...
                itemAsset( roster, 'Serpent Mask' )...
                heroAsset( roster, 'Adagio', null, 'gift of fire' )...
                heroAsset( roster, 'Lyra', null, 'imperial sigil' )...
                heroAsset( roster, 'Ozo', null,
                    'three ring circus and heroic perk' )...
                heroAsset( roster, 'Petal', 'CP',
                    'spontaneous combustion' )...
                heroAsset( roster, 'Glaive', 'WP', 'bloodsong' )...
                heroAsset( roster, 'Krul', null, 'spectral smite' )...
                heroAsset( roster, 'Taka', null, 'kaku' )...
            ]

Did a team have sources of fortified health?  This will return a list of
fortified health sources, or an empty array if there were none.

        fortifiedHealthSources = ( roster ) ->
            [
                heroAsset( roster, 'Reim', null, 'winter spire' )...
                heroAsset( roster, 'Phinn', null, 'polite company' )...
            ]

Did a team have sources of crowd control?  This will return a list of crowd
control sources, or an empty array if there were none.

        crowdControlSources = ( roster ) ->
            [
                itemAsset( roster, 'Nullwave Gauntlet' )...
                heroAsset( roster, 'Catherine', null,
                    'merciless pursuit and blast tremor' )...
                heroAsset( roster, 'Phinn', null, 'whole kit' )...
                heroAsset( roster, 'Lance', null,
                    'impale and Gythian wall' )...
                heroAsset( roster, 'Samuel', null, 'oblivion' )...
                heroAsset( roster, 'Joule', null, 'rocket leap' )...
                heroAsset( roster, 'Ozo', null, 'bangarang' )...
                heroAsset( roster, 'Grumpjaw', null,
                    'grumpy and stuffed' )...
                heroAsset( roster, 'Adagio', null,
                    'gift of fire and verse of judgment' )...
                heroAsset( roster, 'Koshka', null,
                    'yummy catnip frenzy' )...
                heroAsset( roster, 'Gwen', null,
                    'buckshot bonanza and aces high' )...
                heroAsset( roster, 'Vox', null,
                    'pulse and wait for it' )...
                heroAsset( roster, 'Krul', null,
                    'heroic perk and from hell\'s heart' )...
            ]

Did a team have sources of attack speed?  This will return a list of attack
speed sources, or an empty array if there were none.

        attackSpeedSources = ( roster ) ->
            [
                itemAsset( roster, 'Bonesaw' )...
                itemAsset( roster, 'Breaking Point' )...
                itemAsset( roster, 'Tornado Trigger' )...
                heroAsset( roster, 'Rona', null, 'heroic perk' )...
                heroAsset( roster, 'Grumpjaw', null, 'hangry' )...
                heroAsset( roster, 'Petal', null, 'trampoline' )...
            ]

Did a team have sources of crystal power?  This will return a list of
crystal power sources, or an empty array if there were none.

        crystalPowerSources = ( roster ) ->
            [
                itemAsset( roster, 'Alternating Current' )...
                itemAsset( roster, 'Aftershock' )...
                itemAsset( roster, 'Frostburn' )...
                itemAsset( roster, 'Shatterglass' )...
                itemAsset( roster, 'Eve of Harvest' )...
                itemAsset( roster, 'Clockwork' )...
                itemAsset( roster, 'Broken Myth' )...
            ]

Did a team have sources of weapon power?  This will return a list of weapon
power sources, or an empty array if there were none.

        weaponPowerSources = ( roster ) ->
            [
                itemAsset( roster, 'Serpent Mask' )...
                itemAsset( roster, 'Sorrowblade' )...
                itemAsset( roster, 'Tyrant\'s Monocle' )...
                itemAsset( roster, 'Tornado Trigger' )...
                itemAsset( roster, 'Bonesaw' )...
                itemAsset( roster, 'Tension Bow' )...
                itemAsset( roster, 'Breaking Point' )...
            ]

Did a team have sources of stealth?  This will return a list of stealth
sources, or an empty array if there were none.

        stealthSources = ( roster ) ->
            [
                heroAsset( roster, 'Taka', null, 'kaku' )...
                heroAsset( roster, 'Kestrel', null, 'active camo' )...
                heroAsset( roster, 'Flicker', null,
                    'heroic perk and mooncloak' )...
            ]

Did a team have sources of armor?  This will return a list of armor sources,
or an empty array if there were none.

        armorSources = ( roster ) ->
            [
                itemAsset( roster, 'Metal Jacket', '(though Coat of Plates
                    is better)' )...
                itemAsset( roster, 'Coat of Plates' )...
                itemAsset( roster, 'Atlas Pauldron' )...
                itemAsset( roster, 'Aegis', '(which has a little armor,
                    but Coat of Plates is much better)' )...
            ]

Did a team have sources of shield?  This will return a list of shield
sources, or an empty array if there were none.

        shieldSources = ( roster ) ->
            [
                itemAsset( roster, 'Kinetic Shield', '(though Aegis is
                    better)' )...
                itemAsset( roster, 'Coat of Plates', '(which has a little
                    shield, but Aegis is much better)' )...
                itemAsset( roster, 'Aegis' )...
                itemAsset( roster, 'Fountain of Renewal', '(though this has
                    very little shield)' )...
            ]

Did a team have sources of armor pierce?  This will return a list of armor
pierce sources, or an empty array if there were none.

        armorPierceSources = ( roster ) ->
            [
                itemAsset( roster, 'Piercing Spear', '(though Tension Bow
                    and Bonesaw are better)' )...
                itemAsset( roster, 'Tension Bow' )...
                itemAsset( roster, 'Bonesaw' )...
            ]

Did a team have sources of shield pierce?  This will return a list of shield
pierce sources, or an empty array if there were none.

        shieldPierceSources = ( roster ) ->
            [
                itemAsset( roster, 'Piercing Shard', '(though Broken Myth
                    is better)' )...
                itemAsset( roster, 'Broken Myth' )...
            ]

Did a team have sources of mortal wounds?  This will return a list of mortal
wounds sources, or an empty array if there were none.

        mortalWoundsSources = ( roster ) ->
            [
                itemAsset( roster, 'Poisoned Shiv' )...
                heroAsset( roster, 'Taka', null, 'heroic perk' )...
                heroAsset( roster, 'Fortress', null,
                    'truth of the tooth' )...
            ]

Did a hero have a source of blocks?  This will return a list of ways a hero
could block something, or an empty array if there were none.

        blockSources = ( roster, hero ) ->
            [
                itemAsset( [ hero ], 'Reflex Block' )...
                itemAsset( [ hero ], 'Aegis' )...
                itemAsset( roster, 'Crucible' )...
                heroAsset( [ hero ], 'Gwen', null, 'skedaddle' )...
                heroAsset( [ hero ], 'Blackfeather', null,
                    'rose offensive' )...
                heroAsset( [ hero ], 'Taka', null, 'kaiten' )...
            ]

Did a team have sources of vision?  This will return a list of vision
sources, or an empty array if there were none.

        visionSources = ( roster ) ->
            [
                itemAsset( roster, 'Flare Gun' )...
                itemAsset( roster, 'Contraption' )...
                heroAsset( roster, 'Celeste', null, 'heliogenesis' )...
                heroAsset( roster, 'Lyra', null, 'imperial sigil' )...
                heroAsset( roster, 'Gwen', null, 'buckshot bonanza' )...
            ]

Now with all the above utility functions, we can start to ask what
opportunities there were to counterbuild, and how many of them were siezed.
We set up here the table in which we will report those results, together
with tools for adding rows to the table and creating and tracking grades.

        table = type : 'table', rows : [ ]
        table.rows.push headings : [
            '' # icon column
            'Enemy Threat'
            'Your Response'
            'Your Grade'
        ]
        points = maxPoints = 0
        addPoints = ( earned, maximum ) ->
            points += earned
            maxPoints += maximum
        finalGrade = ->
            percent = points * 100 / maxPoints
            return 'A' if percent >= 90
            return 'B' if percent >= 80
            return 'C' if percent >= 70
            return 'D' if percent >= 60
            'F'
        cell = ( heading, items ) ->
            if items.length > 0
                "#{heading}: <ul><li>#{items.join '</li><li>'}</li>"
            else
                "#{heading}:<ul><li><i>none</i></li></ul>"
        addRow = ( threatName, threatList, responseName, responseList,
                   minThreats = 1, responseGoal = 2, importance = 100,
                   icon ) ->
            return unless threatList.length >= minThreats
            if responseList.length >= responseGoal
                value = importance
                grade = 'A'
            else if responseList.length is 0
                value = 0.5 * importance
                grade = 'F'
            else if responseList.length >= responseGoal - 1
                value = 0.85 * importance
                grade = 'B'
            else if responseList.length >= responseGoal - 2
                value = 0.75 * importance
                grade = 'C'
            else
                value = 0.65 * importance
                grade = 'D'
            table.rows.push
                icon : icon
                data : [
                    cell threatName, threatList
                    cell responseName, responseList
                    "#{grade} (#{value} out of #{importance})"
                ]
            addPoints value, importance

Now, for the counterbuilding principles:

If the enemy has lots of CP, you should build shield.

        addRow 'Crystal power', crystalPowerSources( theirTeamRoster() ),
               'Shield', shieldSources( [ participant ] ), 1, 1, 100,
               'shatterglass'

If the enemy has lots of WP, you should build armor.

        addRow 'Weapon power', weaponPowerSources( theirTeamRoster() ),
               'Armor', armorSources( [ participant ] ), 1, 1, 100,
               'sorrowblade'

If the enemy has lots of CC, you should build blocks.

        addRow 'Crowd control', crowdControlSources( theirTeamRoster() ),
               'Blocks', blockSources( myTeamRoster(), participant ), 2, 1,
               100, 'stars'

If the enemy has stealth, your team should have vision.

        addRow 'Stealth', stealthSources( theirTeamRoster() ),
               'Vision', visionSources( myTeamRoster() ), 1, 1, 100, 'kaku'

If the enemy has lots of burst damage, you should build blocks or a husk.

        blocks = blockSources myTeamRoster(), participant
        .concat itemAsset [ participant ], 'Slumbering Husk'
        addRow 'Burst damage', burstSources( theirTeamRoster() ),
               'Blocks', blocks, 2, 1, 100, 'solar-storm'

If the enemy has lots of attack speed, you should build an atlas.

        addRow 'Attack speed', attackSpeedSources( theirTeamRoster() ),
               'Atlas Pauldron',
               itemAsset( myTeamRoster(), 'Atlas Pauldron' ), 2, 1, 100,
               'tornado-trigger'

If the enemy has lots of heals, you should build mortal wounds.

        addRow 'Healing', healSources( theirTeamRoster() ),
               'Mortal wounds', mortalWoundsSources( myTeamRoster() ),
               2, 1, 50, 'fountain-of-renewal'

If the enemy has lots of armor, you should build armor pierce.

        addRow 'High armor', armorSources( theirTeamRoster() ),
               'Armor pierce', armorPierceSources( myTeamRoster() ),
               2, 1, 50, 'metal-jacket'

If the enemy has lots of shield, you should build shield pierce.

        addRow 'High shield', shieldSources( theirTeamRoster() ),
               'Shield pierce', shieldPierceSources( myTeamRoster() ),
               2, 1, 50, 'aegis'

If the enemy has fortified health, you should build mortal wounds.

        addRow 'Fortified health',
               fortifiedHealthSources( theirTeamRoster() ),
               'Mortal wounds', mortalWoundsSources( myTeamRoster() ),
               1, 1, 25, 'frostguard'

Return Kestrel's advice.

        prof : 'Dr. Kestrel'
        quote : 'Boots? Oakheart? Who cares, just pick something!'
        topic : 'Let\'s talk about counterbuilding.  You know what that is,
            right?  I hope so.'
        short : 'I list each enemy threat below, then I check to see if you
            were smart enough to counter it.<br>
            You like to eliminate threats, right?'
        long : 'I look for these threats:  CP, WP, CC, stealth, burst,
            attack speed, heals, armor, shield, and fortified health.<br>
            Obviously they don\'t all show up at once.'
        letter : "#{finalGrade()} in counterbuilding"
        data : [ table ]
