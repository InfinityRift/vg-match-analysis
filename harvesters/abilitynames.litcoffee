
# Ability name harvester

The dumbest thing is that abilities don't have a consistent internal naming
scheme.  So if you want to know what they are, you better harvest them.
Here we go.

    utils = require './utils'
    ( require './basic' ).setup exports, module.filename,
    ( match, participant ) ->
        unique = [ ]
        for event in match.telemetry
            if event.type is 'UseAbility'
                actor = utils.correctHeroName event.payload.Actor
                ability = event.payload.Ability
                record = "#{actor} #{ability}"
                unique.push record unless record in unique
        unique
