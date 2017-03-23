
# Master Samuel

This is the robot brain of Master Samuel, one of the professors at VGU.
He looks into your death times and places.

As with all faculty, he provides one method, `advice`, which takes a match,
participant, and harvested match data, and creates an object of advice, as
documented in [the faculty module](../faculty.litcoffee).  The match is
required to already have its telemetry data embedded.

    exports.advice = ( match, participant, matchData, archive ) ->
        prof : 'Master Samuel'
        quote : 'Want me to kiss your boo-boos?'
        topic : 'Coming soon'
        short : 'Coming soon'
        long : 'Coming soon'
        letter : '...'
        data : [ ]
