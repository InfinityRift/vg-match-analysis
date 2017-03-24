
# Prof. Celeste

    utils = require '../harvesters/utils'
    stats = require 'simple-statistics'

This is the robot brain of Prof. Celeste, one of the professors at VGU.
She looks into whether you capitalized on your power spikes.  She slices the
match into successive time interval, for simplicity of reporting.  Here is
the size of each time interval (feel free to change it):

    dt = 60*1000 # 60 seconds

As with all faculty, he provides one method, `advice`, which takes a match,
participant, and harvested match data, and creates an object of advice, as
documented in [the faculty module](../faculty.litcoffee).  The match is
required to already have its telemetry data embedded.

    exports.advice = ( match, participant, matchData, archive ) ->

First define some tools we'll use in the analysis below.  When does the
match begin?

        startTime = new Date match.telemetry[0].time
        elapsed = ( event ) -> ( new Date event.time ) - startTime

Now a data structure we'll build as we analyze the match events:

        spikes = ally : { }, enemy : { }
        kills = ally : { }, enemy : { }
        objectives = ally : { }, enemy : { }
        learned = { }
        lastInterval = 0

Loop through all events in the match.

        for event in match.telemetry

Create the tools needed for recording any power spikes that we find in this
event, or any accomplishments.

            interval = Math.round elapsed( event ) / dt
            lastInterval = Math.max interval, lastInterval
            if utils.eventActorIsOnMyTeam match, participant, event
                team = 'ally'
            else
                team = 'enemy'
            markSpike = ->
                spikes[team][interval] ?= 0
                spikes[team][interval]++
            markKill = ->
                kills[team][interval] ?= 0
                kills[team][interval]++
            markObjective = ->
                objectives[team][interval] ?= 0
                objectives[team][interval]++

If a player learned an ability, track it.  If it was a new ability, that's a
power spike (whether it's their second or third).

            if event.type is 'LearnAbility'
                list = learned[participant.player.name] ?= [ ]
                if event.payload.Ability not in list
                    list.push event.payload.Ability
                    markSpike()

If the event is a player overdriving an ability, that's a power spike.

            if eventIsOverdrive event then markSpike()

If the event is a player purcasing a major item, that's a power spike.

            if eventIsBigBuy event then markSpike()

If the event is a player killing an enemy or an objective, mark it as an
accomplishment.

            if event.type is 'KillActor' or event.type is 'NPCkillNPC'
                if event.payload.TargetIsHero
                    markKill()
                if /Turret|Miner|Kraken/.test event.payload.Killed
                    markObjective()

Form all our results into a table.

        table =
            type : 'table'
            compact : yes
            rows : [
                headings : [ 'Time', 'Spikes (you/them)',
                    'Your advantage', 'Kills (you/them)',
                    'Objectives (you/them)', 'Grade' ]
            ]
        sayTime = ( ms ) ->
            secs = ( ms / 1000 ) | 0
            mins = 0
            if secs >= 60
                mins = ( secs - secs % 60 ) / 60
                secs = secs % 60
            secs = "#{secs}"
            if secs.length < 2 then secs = "0#{secs}"
            "#{mins}:#{secs}"
        worth = F : 50, D : 60, C : 75, B : 85, A : 100
        scores = [ ]
        for i in [0..lastInterval]
            kills.ally[i] ?= 0
            kills.enemy[i] ?= 0
            objectives.ally[i] ?= 0
            objectives.enemy[i] ?= 0
            spikes.ally[i] ?= 0
            spikes.enemy[i] ?= 0
            allyPoints = kills.ally[i] + 3*objectives.ally[i]
            enemyPoints = kills.enemy[i] + 3*objectives.enemy[i]
            alliesScore = allyPoints - enemyPoints
            if spikes.ally[i] > spikes.enemy[i]
                if alliesScore < -2.5 then grade = 'F'
                else if alliesScore < -0.5 then grade = 'D'
                else if alliesScore < 2.5 then grade = 'C'
                else if alliesScore < 5.5 then grade = 'B'
                else grade = 'A'
            else if spikes.ally[i] < spikes.enemy[i]
                if alliesScore < -5.5 then grade = 'F'
                else if alliesScore < -3.5 then grade = 'D'
                else if alliesScore < -1.5 then grade = 'C'
                else if alliesScore < 1.5 then grade = 'B'
                else grade = 'A'
            else # equal
                if alliesScore < -4.5 then grade = 'F'
                else if alliesScore < -2.5 then grade = 'D'
                else if alliesScore < -0.5 then grade = 'C'
                else if alliesScore < 2.5 then grade = 'B'
                else grade = 'A'
            scores.push worth[grade]
            adv = spikes.ally[i] - spikes.enemy[i]
            wrap = ( line ) ->
                if adv > 0
                    "<font color='green'>#{line}</font>"
                else if adv < 0
                    "<font color='red'>#{line}</font>"
                else
                    line
            table.rows.push data : [
                wrap "#{sayTime i*dt}-#{sayTime i*dt+dt}"
                wrap "#{spikes.ally[i]}/#{spikes.enemy[i]}"
                wrap "<strong>#{adv}</strong>"
                wrap "#{kills.ally[i]}/#{kills.enemy[i]}"
                wrap "#{objectives.ally[i]}/#{objectives.enemy[i]}"
                wrap "<strong>#{grade}</strong>"
            ]
        overallGrade = stats.mean scores
        if overallGrade < 40 then overallGrade = 'F'
        else if overallGrade < 60 then overallGrade = 'D'
        else if overallGrade < 75 then overallGrade = 'C'
        else if overallGrade < 90 then overallGrade = 'B'
        else overallGrade = 'A'

Report final results.

        prof : 'Prof. Celeste'
        quote : 'Does it burn?'
        topic : 'I study whether you capitalize on your power spikes (like,
            say, overdriven heliogenesis, a fantastic example), and shutting
            down the enemy team\'s power spikes.'
        short : 'The (naturally, beautiful) table below gives a detailed
            grade of how your team did at each point in the match.'
        long : '<ul>
            <li>I marked power spikes whenever you or enemies
            <strong>learned new abilities, overdrove your abilities, bought
            infusions, or bought effective tier 3 items.</strong></li>
            <li>I graded you based on what you
            accomplished at each point.</li>
            <li>Bonus points if you keep the enemy
            from capitalizing on power spikes.</li>
            <li>Points off if you have a
            spike and don\'t use it for anything.</li>
            </ul>
            Why yes, you\'re right, I am the best instructor at VGU.'
        letter : "#{overallGrade} in power spikes"
        data : [ table ]

The names of all ultimate abilities:

    ultimates = [
        'HERO_ABILITY_ADAGIO_FRIENDSHIP_NAME' # I think?
        'HERO_ABILITY_ALPHA_C_NAME'
        'HERO_ABILITY_ARDAN_C'
        'HERO_ABILITY_BARON_C_NAME'
        'HERO_ABILITY_HERO021_C_NAME' # blackfeather
        'HERO_ABILITY_CATHERINE_DEADLY_GRACE_NAME' # maybe??
        'HERO_ABILITY_CELESTE_C_NAME'
        'HERO_ABILITY_HERO036_C_NAME' # flicker
        'HERO_ABILITY_FORTRESS_C_NAME'
        'HERO_ABILITY_GLAIVE_BLOODSONG_NAME'
        'HERO_ABILITY_GRUMPJAW_C_NAME'
        'HERO_ABILITY_GWEN_C_NAME'
        'HERO_ABILITY_IDRIS_C_NAME'
        'HERO_ABILITY_JOULE_ORBITAL_NUKE' # I think?
        'HERO_ABILITY_KESTREL_C_NAME'
        'HERO_ABILITY_KOSHKA_FRENZY_NAME'
        'HERO_ABILITY_HERO009_SHIMMERHEART_NAME' # ??
        'HERO_ABILITY_LANCE_C_NAME'
        'HERO_ABILITY_LYRA_C_NAME'
        'HERO_ABILITY_OZO_C_NAME'
        'HERO_ABILITY_PETAL_THORNSTORM_NAME'
        'HERO_ABILITY_PHINN_C_NAME'
        'HERO_ABILITY_REIM_C_NAME'
        'HERO_ABILITY_RINGO_HELLFIRE_SAKE_NAME'
        'HERO_ABILITY_RONA_C_NAME'
        'HERO_ABILITY_SAW_EXPLOSIVE_TIPPED_SHELLS_NAME'
        'HERO_ABILITY_SAMUEL_C_NAME'
        'HERO_ABILITY_SKAARF_C_DRAGON_BREATH'
        'HERO_ABILITY_SKYE_C_NAME'
        'HERO_ABILITY_SAYOC_C' # Taka
        'HERO_ABILITY_VOX_C_NAME'
    ]

A utility function that takes an event and returns true if and only if the
event is an upgrade that overdrives an ability.

    eventIsOverdrive = ( event ) ->
        return no unless event.type is 'LearnAbility'
        return yes if event.payload.Level is 5
        return no unless event.payload.Level is 3
        event.payload.Ability in ultimates

All tier 3 items that count as power spikes when purchasing them.

    tier3Items = [
        'Sorrowblade'
        'Shatterglass'
        'Tornado Trigger'
        'Serpent Mask'
        'Tension Bow'
        'Bonesaw'
        'Shiversteel'
        'Frostburn'
        'Fountain of Renewal'
        'Crucible'
        'Tyrant\'s Monocle'
        'Aftershock'
        'Weapon Infusion'
        'Crystal Infusion'
        'Broken Myth'
        'Atlas Pauldron'
        'Breaking Point'
        'Alternating Current'
        'Eve of Harvest'
        'Stormcrown'
        'Poisoned Shiv'
        'Nullwave Gauntlet'
        'Echo'
        'Aftershock'
    ]

A utility function that takes an event and returns true if and only if the
event is a purchase of an important tier 3 item or infusion.

    eventIsBigBuy = ( event ) ->
        event.type is 'BuyItem' and event.payload.Item in tier3Items
