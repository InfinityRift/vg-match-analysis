
# Gold harvester

Compute the total CS (i.e., farm, or minion kills that gave gold) for a
participant in a match.  (This doesn't actually need to be computed, just
looked up in the participant stats record.)  Track this by role and skill
tier, using the appropriate formuals in [the utilities module in this
folder](utils.litcoffee). We build this module using the basic harvester
building tools defined in [the basic module in this
folder](basic.litcoffee).

    utils = require './utils'
    ( require './basic' ).setup exports, module.filename,
    ( match, participant ) ->
        participant.stats.farm
