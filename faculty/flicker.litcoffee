
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
        topic : 'Did your team have plenty of vision, and make good use of
            it?'
        short : 'This faculty member can\'t start his research yet,
            <strong>because he doesn\'t have the data.</strong>
            Right now Vainglory matches don\'t
            report events about vision (placing traps, throwing flares,
            using contraption, etc.).  When they do, you can be sure that
            Doctor Flicker will be very interested in that data!'
        long : 'Besides, Doctor Flicker is rather hard to find.  I could
            have sworn he was just here...'
        # letter : ''
        # data : [ ]
