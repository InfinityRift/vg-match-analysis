
# Build harvester

This harvester tracks a certain set of items, listed here:

    trackedItems = [
        'Sorrowblade'
        'Shatterglass'
        'Tornado Trigger'
        'Metal Jacket'
        'Clockwork'
        'Serpent Mask'
        'Tension Bow'
        'Bonesaw'
        'Shiversteel'
        'Frostburn'
        'Fountain of Renewal'
        'Crucible'
        'Journey Boots'
        'Tyrant\'s Monocle'
        'Aftershock'
        'Broken Myth'
        'War Treads'
        'Atlas Pauldron'
        'Aegis'
        'Breaking Point'
        'Alternating Current'
        'Eve of Harvest'
        'Contraption'
        'Halcyon Chargers'
        'Stormcrown'
        'Poisoned Shiv'
        'Nullwave Gauntlet'
        'Echo'
        'Slumbering Husk'
    ]

For each participant, it computes the build they ended the game with, as an
array of indices into that list of tracked items.  This will be compact,
because it will just be integers rather than strings.  It will also be more
useful, because it will not track every silly thing, but only the tier 3
items that we might want to talk about.

    utils = require './utils'
    ( require './basic' ).setup exports, module.filename,
    ( match, participant ) ->
        build = [ ]
        for event in match.telemetry
            if event.type is 'BuyItem' or event.type is 'SellItem'
                if utils.isEventActor match, participant, event
                    index = trackedItems.indexOf event.payload.Item
                    if index is -1 then continue
                    if event.type is 'BuyItem'
                        build.push index
                    else
                        bindex = build.indexOf index
                        if bindex > -1 then build.splice bindex, 1
        build

Other modules may want to ask this harvester the list of items it tracks, so
that from indices they can get item names.  We let them do so here.

    exports.getTrackedItems = -> trackedItems
