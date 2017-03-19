
# Death harvester

Muahaha.  This harvester checks all the telemetry data and just picks out
the death events, storing them in the `deaths` member of the match.  It
then just writes the total number of deaths in the match onto the end of a
growing array in the accumulator.

This is not very useful.  I will create better data harvesters in the
future; this one is mostly just a proof of concept that things work.

    exports.reap = ( match, accumulated ) ->
        accumulated.deathsPerMatch ?= [ ]
        match.deaths = [ ]
        for event in match.events
            if event.payload.Killed and event.payload.TargetIsHero
                match.deaths.push event
        accumulated.deathsPerMatch.push match.deaths.length
