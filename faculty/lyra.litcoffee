
# Doctor Lyra

This is the robot brain of Doctor Lyra, one of the professors at VGU.
She looks into your team composition.

As with all faculty, he provides one method, `advice`, which takes a match,
participant, and harvested match data, and creates an object of advice, as
documented in [the faculty module](../faculty.litcoffee).  The match is
required to already have its telemetry data embedded.

    exports.advice = ( match, participant, matchData, archive ) ->
        prof : 'Dr. Lyra'
        quote : 'You\'ll be safer with me.'
        topic : 'Did your team composition synergize?  Did it work well into
            the enemy team\'s composition?'
        short : '<strong>Advice from Dr. Lyra may be coming in the
            future.</strong>'
        long : 'She is on sabbatical for the 2016-2017 academic year,
            writing another (levitating, magical) book.<br>
            She will return to teaching duties thereafter.'
        # letter : ''
        # data : [ ]
