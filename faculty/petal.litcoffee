
# Professor Petal

This is the robot brain of Professor Petal, one of the professors at VGU.
She tries to bring out the positive in your game play.

As with all faculty, she provides one method, `advice`, which takes a match
and participant and creates an object of advice, as documented in
[the faculty module](../faculty.litcoffee).  The match is required to
already have its telemetry data embedded.

    exports.advice = ( match, participant ) ->
        prof : 'Prof. Petal'
        short : 'Heading goes here'
        long : 'Some long and very positive advice here'
        data : { none : 'yet', example : [ 1, 2, 3, ] }
