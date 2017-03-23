
# Doctor Vox

This is the robot brain of Doctor Vox, one of the professors at VGU.
He looks into your build.

As with all faculty, he provides one method, `advice`, which takes a match,
participant, and harvested match data, and creates an object of advice, as
documented in [the faculty module](../faculty.litcoffee).  The match is
required to already have its telemetry data embedded.

    exports.advice = ( match, participant, matchData, archive ) ->
        prof : 'Dr. Vox'
        quote : 'These guys are waaay too into these crystal things.'
        topic : 'Let\'s look at how your build went.'
        short : 'Coming soon'
        long : 'Dr. Vox is taking a leave of absence to play with an EDM
            band, and will return to academic duties at an unspecified
            future time.'
        # letter : ''
        # data : [ ]
