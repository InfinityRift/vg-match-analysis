
# Prof. Celeste

This is the robot brain of Prof. Celeste, one of the professors at VGU.
She looks into whether you capitalized on your power spikes.

As with all faculty, he provides one method, `advice`, which takes a match,
participant, and harvested match data, and creates an object of advice, as
documented in [the faculty module](../faculty.litcoffee).  The match is
required to already have its telemetry data embedded.

    exports.advice = ( match, participant, matchData, archive ) ->
        prof : 'Prof. Celeste'
        quote : 'Does it burn?'
        topic : 'Capitalizing on your power spikes (like overdriven helios,
            for example), and shutting down power spikes of the enemy team.'
        short : 'Coming soon'
        long : 'Prof. Celeste is doing some field work and we expect her
            back in the laboratory with freshly captured minions any day
            now.'
        # letter : ''
        # data : [ ]
