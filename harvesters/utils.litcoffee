
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
then it contains the telemetry data, and that same data is also stored in
the `telemetry` member of the match object itself.

    exports.getTelemetryAsset = ( match ) ->
        for asset in match.assets ? [ ]
            return asset if asset?.attributes?.name is 'telemetry'
        null
    exports.hasTelemetryData = ( match ) ->
        exports.getTelemetryAsset( match )?
    exports.fetchTelemetryData = ( match, callback ) ->
        telemetryAsset = exports.getTelemetryAsset match
        return callback null unless telemetryAsset?
        fetchedData = ''
        request = https.request telemetryAsset.attributes.URL
        request.on 'response', ( res ) ->
            res.on 'data', ( data ) -> fetchedData += data
            res.on 'end', ->
                try
                    callback match.telemetry = JSON.parse fetchedData
                catch e
                    console.log e, fetchedData[...500]
                    callback null
            res.on 'error', -> callback null
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

From a match-participant pair, find the word for the participant's team
(left or right, lower case).

    exports.sideForParticipant = ( match, participant ) ->
        for roster in match.rosters
            for p in roster.participants
                if p is participant
                    return roster.stats.side.split( '/' )[0]

Similar idea, now find the participant's roster, by index (0 or 1).

    exports.rosterIndexForParticipant = ( match, participant ) ->
        for p in match.rosters[0].participants
            if p.player.name is participant.player.name
                return 0
        1

From the above data, get the participant's allies, if any.

    exports.getAllies = ( match, participant ) ->
        rosterIndex = exports.rosterIndexForParticipant match, participant
        ( x for x in match.rosters[rosterIndex].participants \
            when x isnt participant )

This makes it easy to ask whether a given participant is the doer of an
event, the target of the event, or neither.

    exports.isEventActor = ( match, participant, event ) ->
        team = exports.sideForParticipant match, participant
        doer = correctHeroName event.payload.Actor
        team.toLowerCase() is event.payload.Team.toLowerCase() and \
            participant.actor.toLowerCase() is doer.toLowerCase()
    exports.isEventTarget = ( match, participant, event ) ->
        if event.type is 'DealDamage'
            target = correctHeroName event.payload.Target
        else if event.type is 'KillActor'
            target = correctHeroName event.payload.Killed
        else
            return no
        team = exports.sideForParticipant match, participant
        team.toLowerCase() isnt event.payload.Team.toLowerCase() and \
            participant.actor.toLowerCase() is target.toLowerCase()

Compute total gold earned in a match from various sources.  The `source`
parameter can be lane, jungle, or kills.  The events parameter is the match
telemetry data array.

    exports.goldEarnedFrom = ( match, participant, source ) ->
        result = 0
        for event in match.telemetry
            if event.type is 'KillActor' and \
               exports.isEventActor match, participant, event
                minion = /Minion/.test event.payload.Killed
                jungle = /Jungle/.test event.payload.Killed
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

    exports.goldSpentInCategory = ( match, participant, category ) ->
        result = 0
        for event in match.telemetry
            if event.type is 'BuyItem' and \
               category is itemCategories[event.payload.Item] and \
               exports.isEventActor match, participant, event
                result += parseInt event.payload.Cost
        result

Estimate the role a participant had in a match, by what hero they chose,
what items they bought, and what minions or jungle creeps they mostly
killed.

    exports.estimateRole = ( match, participant ) ->
        util = exports.goldSpentInCategory match, participant, 'Utility'
        def = exports.goldSpentInCategory match, participant, 'Defense'
        wp = exports.goldSpentInCategory match, participant, 'Weapon'
        cp = exports.goldSpentInCategory match, participant, 'Ability'
        actor = participant.actor
        cap = if 'captain' is exports.typicalHeroRole actor then 3000 else 0
        jun = if 'jungler' is exports.typicalHeroRole actor then 1500 else 0
        car = if 'carry' is exports.typicalHeroRole actor then 1500 else 0
        lane = exports.goldEarnedFrom match, participant, 'lane'
        jungle = exports.goldEarnedFrom match, participant, 'jungle'
        captainPoints = util*1.5 + def + cap
        junglerPoints = wp + cp + jun + jungle
        carryPoints = wp + cp + car + lane
        max = Math.max captainPoints, junglerPoints, carryPoints
        if max is captainPoints then return 'captain'
        if max is junglerPoints then return 'jungler'
        'carry'

Convert the skill tier number in a participant into one of the actual
numbers used in the game (0 through 10 for unranked through vainglorious,
rather than the numbers -1 through 29 for unranked through vainglorious
gold, which is too confusing and too granular for my needs).

    exports.simpleSkillTier = ( participant ) ->
        try
            ( ( participant.stats.skillTier + 3 ) / 3 ) | 0
        catch e
            return null

## Storing stats by role and tier

Create an accumulator key that contains both role and simple skill tier,
for partitioning gathered data into these categories.

    exports.roleTierKey = ( match, participant, key ) ->
        "#{exports.estimateRole match, participant}
         #{exports.simpleSkillTier participant} #{key}"

This function uses that key to extract data from an accumulator.

    exports.getRoleTierData =
    ( accumulator, match, participant, key, defaultValue ) ->
        fullKey = exports.roleTierKey match, participant, key
        accumulator[fullKey] ? defaultValue

This function uses the same key to save data into an accumulator.

    exports.setRoleTierData =
    ( accumulator, match, participant, key, value ) ->
        fullKey = exports.roleTierKey match, participant, key
        accumulator[fullKey] = value

The following function takes a `computeStat` function as its final argument,
which must take match-participant pairs to single numbers.  It runs that
stat computer on each participant in the match, storing the resulting data
in the appropriate category of the given accumulator, based on the
participant's role and skill tier.

    exports.reapStat = ( match, accumulator, key, computeStat ) ->
        for roster in match.rosters
            for participant in roster.participants
                soFar = exports.getRoleTierData accumulator,
                    match, participant, key, [ ]
                soFar.push computeStat match, participant
                exports.setRoleTierData accumulator, match, participant,
                    key, soFar

To join two accumulators that were built in this way, we simply concat the
lists stored in the corresponding members of each.  The version of this that
harvesters require (bind) is also provided.

    exports.bindStat = ( accumulator1, accumulator2, result ) ->
        keys = [ ]
        for own key of accumulator1
            if key not in keys then keys.push key
        for own key of accumulator2
            if key not in keys then keys.push key
        for key in keys
            result[key] =
                ( accumulator1[key] ? [ ] ).concat accumulator2[key] ? [ ]
    exports.joinStat = ( accumulator1, accumulator2 ) ->
        result = { }
        exports.bindStat accumulator1, accumulator2, result
        result

## Finding time-dependent player data

How about just finding a specific player?  This takes a match and an IGN and
returns the participant object who has that IGN.

    exports.getParticipantFromIGN = ( match, ign ) ->
        for roster in match.rosters
            for participant in roster.participants
                return participant if participant.player.name is ign
        null

Now, find the last event before a given `Date` object in a given match.
We use a binary search.

    lastIndexBefore = ( match, date ) ->
        leftIndex = 0
        rightIndex = match.telemetry.length - 1
        if ( new Date match.telemetry[rightIndex].time ) < date
            return rightIndex
        while leftIndex < rightIndex
            middleIndex = ( ( leftIndex + rightIndex ) / 2 ) | 0
            middleTime = new Date match.telemetry[middleIndex].time
            if middleTime < date
                if leftIndex is middleIndex then return leftIndex
                leftIndex = middleIndex
            else
                rightIndex = middleIndex
        leftIndex

Where was the player last seen at a given time in a given match?

    exports.lastKnownPosition = ( match, participant, date ) ->
        index = lastIndexBefore match, date
        while index >= 0
            event = match.telemetry[index]
            if event.payload.Position? and \
               exports.isEventActor match, participant, event
                return event.payload.Position
            index--
        null

Is the player alive at a given time in a given match?  This is not reliable,
because there is no respawn event.  Consequently, a player will seem dead
until they take some action, which may be after they've actually respawned
(such as hitting a monster) or even while they're still dead (such as
buying an item), so this is just a temporary approximation to reality.

    exports.isAlive = ( match, participant, date ) ->
        index = lastIndexBefore match, date
        while index >= 0
            event = match.telemetry[index]
            if event.payload.Killed and \
               exports.isEventTarget match, participant, event
                return no
            if exports.isEventActor match, participant, event
                return yes
            index--
        yes

Distance between two positions, Euclidean.

    exports.positionDifference = ( position1, position2 ) ->
        ds = ( position1[i] - position2[i] for i in [0,1,2] )
        Math.sqrt ds[0]*ds[0] + ds[1]*ds[1] + ds[2]*ds[2]
