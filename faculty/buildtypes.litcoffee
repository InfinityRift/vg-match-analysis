
# Build types utilities

This module is used by some of the faculty in this folder to analyze build
types.

    harvester = require '../harvesters/builds'

A dictionary mapping all the items we track with
[the builds harvester](../harvesters/builds.litcoffee) to a classification
into WP, CP, D(efense), or U(tility).

    exports.typeOfItem =
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
    exports.getTypeOfItem = ( itemName ) ->
        cleanup = ( x ) -> x?.toLowerCase()?.replace /'/g, ''
        for own key, value of exports.typeOfItem
            if cleanup( itemName ) is cleanup( key )
                return value
        undefined
    exports.itemList = harvester.getTrackedItems()

A utility for looking at a build and deciding if it's a WP build, a CP
build, or something else.

    exports.typeOfBuild = ( build ) ->
        types = WP : 0, CP : 0, D : 0, U : 0
        for index in build
            types[exports.getTypeOfItem exports.itemList[index]]++
        if types.WP >= 2 and types.CP < 2 and types.D <= 2 and types.U < 2
            return 'WP'
        if types.CP >= 2 and types.WP < 2 and types.D <= 2 and types.U < 2
            return 'CP'
        'other'

And the icon name can be computed for each item as follows.

    exports.nameToIcon = ( name ) ->
        name.replace RegExp( ' ', 'g' ), '-'
        .replace '\'', ''
        .toLowerCase()
