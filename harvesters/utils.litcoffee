
# Harvester utilities

    https = require 'https'

These functions are useful for scanning telemetry data and making
assessments about higher-level concepts, such as roles, builds, tiers, and
so on.

## No tools needed?

For some things, no utility function is needed, just some notes on how to
compute the thing very easily without assistance of any method.  Given a
match, one can get the skill tier of any player in it using code such as
`match.rosters[i].participants[j].stats.skillTier`.  To get the average
skill tier for a whole match, use `matchSkillTier`, defined below.

## Tools in this module

Fetch telemetry data for a match, and call the callback.  If the parameter
to the callback is empty, we could not fetch telemetry data.  If it is not,
then it contains the telemetry data.

    exports.fetchTelemetryData = ( match, callback ) ->
        telemetryAsset = null
        for asset in match.assets ? [ ]
            if asset.attributes.name is 'telemetry'
                telemetryAsset = asset
                break
        callback null unless telemetryAsset
        fetchedData = ''
        request = https.request telemetryAsset.attributes.URL
        request.on 'response', ( res ) ->
            res.on 'data', ( data ) -> fetchedData += data
            res.on 'end', ->
                try
                    callback JSON.parse fetchedData
                catch e
                    console.log e, fetchedData
                    callback null
        request.end()

Average skill tier for all players in a match.

    exports.matchSkillTier = ( match ) ->
        total = count = 0
        for roster in match.rosters
            for participant in roster.participants
                total += participant.stats.skillTier
                count++
        if count then total / count else undefined

Take a hero name and convert it to an estimated role, based on the in-game
categorization of heroes.

    captains = [ 'adagio', 'ardan', 'catherine', 'flicker', 'fortress',
                 'lance', 'lyra', 'phinn' ]
    junglers = [ 'grumpjaw', 'alpha', 'glaive', 'joule', 'koshka', 'krul',
                 'ozo', 'petal', 'reim', 'rona', 'taka' ]
    carries = [ 'baron', 'blackfeather', 'celeste', 'gwen', 'idris',
                'kestrel', 'ringo', 'samuel', 'saw', 'skaarf', 'skye',
                'vox' ]
    exports.typicalHeroRole = ( heroName ) ->
        if heroName.toLowerCase() in captains then return 'captain'
        if heroName.toLowerCase() in junglers then return 'jungler'
        if heroName.toLowerCase() in carries then return 'carry'
        throw "Unknown hero name: #{heroName}"

Take a hero name as it shows up in telemetry data and change it into the
actual name of the hero.

    correctHeroName = ( telemetryHeroName ) ->
        if telemetryHeroName[0] is '*'
            telemetryHeroName = telemetryHeroName[1..]
        if telemetryHeroName[-1..] is '*'
            telemetryHeroName = telemetryHeroName[...-1]
        if telemetryHeroName is 'Sayoc' then telemetryHeroName = 'Taka'
        if telemetryHeroName is 'Hero009' then telemetryHeroName = 'Krul'
        if telemetryHeroName is 'Hero010' then telemetryHeroName = 'Skaarf'
        if telemetryHeroName is 'Hero016' then telemetryHeroName = 'Rona'
        telemetryHeroName

Compute total gold earned in a match from various sources.  The `source`
parameter can be lane, jungle, or kills.  The events parameter is the match
telemetry data array.

    exports.goldEarnedFrom = ( telemetry, team, actor, source ) ->
        result = 0
        for event in telemetry
            if event.type is 'KillActor'
                doer = correctHeroName event.payload.Actor
                targ = correctHeroName event.payload.Killed
                minion = /Minion/.test targ
                jungle = /Jungle/.test targ
                if team.toLowerCase() is event.payload.Team.toLowerCase() \
                   and doer.toLowerCase() is actor.toLowerCase()
                    switch source
                        when 'lane'
                            if minion and not jungle
                                result += parseInt event.payload.Gold
                        when 'jungle'
                            if jungle and minion
                                result += parseInt event.payload.Gold
                        when 'kills'
                            if event.payload.TargetIsHero
                                result += parseInt event.payload.Gold
        result

A dictionary that tells what category of the shop each item sits in:

    itemCategories =
        'Aegis' : 'Defense'
        'Aftershock' : 'Ability'
        'Alternating Current' : 'Ability'
        'Atlas Pauldron' : 'Defense'
        'Barbed Needle' : 'Weapon'
        'Blazing Salvo' : 'Weapon'
        'Bonesaw' : 'Weapon'
        'Book Of Eulogies' : 'Weapon'
        'Breaking Point' : 'Weapon'
        'Broken Myth' : 'Ability'
        'Chronograph' : 'Ability'
        'Clockwork' : 'Ability'
        'Coat of Plates' : 'Defense'
        'Contraption' : 'Utility'
        'Crucible' : 'Defense'
        'Crystal Bit' : 'Ability'
        'Crystal Infusion' : 'Consumable'
        'Dragonblood Contract' : 'Consumable'
        'Dragonheart' : 'Defense'
        'Eclipse Prism' : 'Ability'
        'Energy Battery' : 'Ability'
        'Eve of Harvest' : 'Ability'
        'Flare' : 'Consumable'
        'Flare Gun' : 'Utility'
        'Fountain of Renewal' : 'Defense'
        'Frostburn' : 'Ability'
        'Halcyon Chargers' : 'Utility'
        'Halcyon Potion' : 'Consumable'
        'Heavy Prism' : 'Ability'
        'Heavy Steel' : 'Weapon'
        'Hourglass' : 'Ability'
        'Ironguard Contract' : 'Consumable'
        'Journey Boots' : 'Utility'
        'Kinetic Shield' : 'Defense'
        'Level Juice' : 'Consumable'
        'Lifespring' : 'Defense'
        'Light Armor' : 'Defense'
        'Light Shield' : 'Defense'
        'Lucky Strike' : 'Weapon'
        'Metal Jacket' : 'Defense'
        'Minion Candy' : 'Consumable'
        'Minions Foot' : 'Weapon'
        'Nullwave Gauntlet' : 'Utility'
        'Oakheart' : 'Defense'
        'Piercing Shard' : 'Ability'
        'Piercing Spear' : 'Weapon'
        'Poisoned Shiv' : 'Weapon'
        'Pot of Gold' : 'Consumable'
        'Protector Contract' : 'Consumable'
        'Reflex Block' : 'Defense'
        'Scout Trap' : 'Consumable'
        'Serpent Mask' : 'Weapon'
        'Shatterglass' : 'Ability'
        'Shiversteel' : 'Utility'
        'Six Sins' : 'Weapon'
        'Slumbering Husk' : 'Defense'
        'Sorrowblade' : 'Weapon'
        'Sprint Boots' : 'Utility'
        'Stormcrown' : 'Utility'
        'Stormguard Banner' : 'Utility'
        'Swift Shooter' : 'Weapon'
        'Tension Bow' : 'Weapon'
        'Tornado Trigger' : 'Weapon'
        'Travel Boots' : 'Utility'
        'Tyrants Monocle' : 'Weapon'
        'Void Battery' : 'Ability'
        'War Treads' : 'Utility'
        'Weapon Blade' : 'Weapon'
        'Weapon Infusion' : 'Consumable'

Compute the total gold spent on items of a particular category from the
values in the above dictionary.

    exports.goldSpentInCategory = ( telemetry, team, actor, category ) ->
        result = 0
        for event in telemetry
            if event.type is 'BuyItem'
                doer = correctHeroName event.payload.Actor
                if team.toLowerCase() is event.payload.Team.toLowerCase() \
                   and doer.toLowerCase() is actor.toLowerCase() \
                   and category is itemCategories[event.payload.Item]
                    result += parseInt event.payload.Cost
        result

Estimate the role a participant had in a match, by what hero they chose,
what items they bought, and what minions or jungle creeps they mostly
killed.

    exports.estimateRole = ( telemetry, team, actor ) ->
        util = exports.goldSpentInCategory telemetry, team, actor, 'Utility'
        def = exports.goldSpentInCategory telemetry, team, actor, 'Defense'
        wp = exports.goldSpentInCategory telemetry, team, actor, 'Weapon'
        cp = exports.goldSpentInCategory telemetry, team, actor, 'Ability'
        cap = if 'captain' is exports.typicalHeroRole actor then 3000 else 0
        jun = if 'jungler' is exports.typicalHeroRole actor then 1500 else 0
        car = if 'carry' is exports.typicalHeroRole actor then 1500 else 0
        lane = exports.goldEarnedFrom telemetry, team, actor, 'lane'
        jungle = exports.goldEarnedFrom telemetry, team, actor, 'jungle'
        captainPoints = util*1.5 + def + cap
        junglerPoints = wp + cp + jun + jungle
        carryPoints = wp + cp + car + lane
        max = Math.max captainPoints, junglerPoints, carryPoints
        if max is captainPoints then return 'captain'
        if max is junglerPoints then return 'jungler'
        'carry'
