
# Death harvester

Muahaha.  This harvester checks all the telemetry data and just picks out
the death events, storing them in the `deaths` member of the match.  It
then just writes the total number of deaths in the match onto the end of a
growing array in the accumulator.

This is not very useful.  I will create better data harvesters in the
future; this one is mostly just a proof of concept that things work.

    exports.reap = ( match, accumulated ) ->
        accumulated.deathsPerMatch ?= [ ]
        count = 0
        for event in match.events
            count++ if event.payload.Killed and event.payload.TargetIsHero
        accumulated.deathsPerMatch.push count

    exports.bind = ( accumulated1, accumulated2, result ) ->
        result.deathsPerMatch = [
            ( accumulated1.deathsPerMatch ? [ ] )...
            ( accumulated2.deathsPerMatch ? [ ] )...
        ]

    exports.pick = ( match, accumulated ) ->
        # do nothing yet
