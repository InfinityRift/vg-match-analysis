
# Doctor Flicker

This is the robot brain of Doctor Flicker, one of the professors at VGU.
He looks into your team's vision.

As with all faculty, he provides one method, `advice`, which takes a match,
participant, and harvested match data, and creates an object of advice, as
documented in [the faculty module](../faculty.litcoffee).  The match is
required to already have its telemetry data embedded.

    exports.advice = ( match, participant, matchData, archive ) ->
        prof : 'Dr. Flicker'
        quote : 'No one is in this bush, no one at all!'
        topic : 'Coming soon'
        short : 'Coming soon'
        long : 'Coming soon'
        letter : '...'
        data : [ ]
