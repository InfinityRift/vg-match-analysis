
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
        topic : 'Where and when did you die?  Despite how delightful that
            is to talk about, maybe by studying it you can learn to avoid
            it.'
        short : 'Coming soon'
        long : 'Master Samuel has not been seen around campus lately.
            Assuming nothing untoward has occurred, we expect him to return
            to his regular academic duties...any day now.'
        # letter : ''
        # data : [ ]

These points are the center of each region, and help us partition the map
using the idea of a
[Voronoi diagram](https://en.wikipedia.org/wiki/Voronoi_diagram).

    mapRegionCenters =
        "Left base" : [ -80, -7 ]
        "Right base" : [ 80, -7 ]
        "Left crystal" : [ -75, 20 ]
        "Right crystal" : [ 75, 20 ]
        "Left choke point" : [ -52, 3 ]
        "Right choke point" : [ 52, 3 ]
        "Left second turret" : [ -36, 1 ]
        "Right second turret" : [ 36, 1 ]
        "Left first turret" : [ -17, 2 ]
        "Right first turret" : [ 17, 2 ]
        "Left back healer" : [ -40, 20 ]
        "Right back healer" : [ 40, 20 ]
        "Left middle healer" : [ -22, 24 ]
        "Right middle healer" : [ 23, 24 ]
        "Left mustache bush" : [ -8, 13 ]
        "Right mustache bush" : [ 8, 13 ]
        "Left triangle bush" : [ -10, 26 ]
        "Right triangle bush" : [ 10, 26 ]
        "Left crystal sentry" : [ -35, 36 ]
        "Right crystal sentry" : [ 35, 36 ]
        "Left back minions" : [ -44, 32 ]
        "Right back minions" : [ 44, 32 ]
        "Left little minions" : [ -13, 38 ]
        "Right little minions" : [ 13, 38 ]
        "Gold miner/Kraken pit" : [ 0, 23 ]
        "Jungle center" : [ 0, 32 ]
        "Lane center" : [ 1, 3 ]
        "Jungle shop" : [ 0, 45 ]

Here we implement the Voronoi idea by finding the closest region center to
any given point, and returning its name.  This is just a loop through the
above table to find the closest center to the given point.

    regionNameForPoint = ( point ) ->
        utils = require '../harvesters/utils'
        shortestDistance = 99999
        regionName = null
        for own name, center of mapRegionCenters
            asIf3D = [ center[0], 0, center[1] ]
            thisDistance = utils.positionDifference asIf3D, point
            if thisDistance < shortestDistance
                shortestDistance = thisDistance
                regionName = name
        regionName
