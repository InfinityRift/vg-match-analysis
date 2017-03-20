
# Tool for building basic harvesters

    utils = require './utils'

This module assumes that the statistic you need to harvest from a match is
based on its telemetry data, and is about one participant in the match, and
can be harvested by a single `computeStat` function that takes the match and
participant as parameters.  You provide that function as a parameter to the
following setup routine, and this module installs the reap, bind, and pick
functions into your harvester module for you, based on your `computeStat`
function.  You must also provide a text key to use in accumulators for the
stat you're computing (e.g., "gold" if you're counting gold earned).

    exports.setup = ( harvester, key, computeStat ) ->
        key = key.split( '/' )[-1..][0].split( '.' )[0]
        harvester.reap = ( match, accumulated ) ->
            utils.reapStat match, accumulated, key, computeStat
        harvester.bind = utils.bindStat
        harvester.pick = ( match, participant, accumulated ) ->
            accumulated[key] = computeStat match, participant
