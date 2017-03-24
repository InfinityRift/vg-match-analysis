
# Plans for the future of this project

## Before end of contest goals:

 1. Get the app deployed to Heroku
 1. Improve error handling
     a. Improve the Internal Error reporter to not show error messages
        themselves, but just apologize and suggest refreshing or trying a
        different match.
     a. Look up how to handle timeout AJAX requests in jQuery and do that
        for each time the analysis page sends one, giving an appropriate
        error page each time.
     a. Change the npm start command to dump console stuff to a log file
        with `tee`.
 1. Add a data browsing page
     * Provide new server queries for:
        * getting list of harvesters
        * getting archive metadata
        * getting role-tier-harvester data for any given set of such triples
     * Provide a cache for such results
     * Provide a UI for choosing role (or all together), tier (or all
       together), and harvester (must be a specific one), all in a left
       column of controls
     * Enable that UI to just dump JSON data into the right column
     * Make the page smart enough to know how to make charts
 1. Add a link from the other pages to that one for more data details

Here's a list of things I'd like to add to this project.  I'll add as many
as I can by
[the challenge deadline](https://developer.vainglorygame.com/rules),
and if I like what I have by then, I'll submit it.

## New professor: Lyra

 * Topic: Team composition and drafting
    * List all positive synergies in your team and counters against enemies
    * List all snyergies on enemy team and their counters to your team
 * New data required, which I just won't have time to get before the
   challenge ends:
    * A list of which heroes work well or poorly into which other heroes,
      and why
    * A list of which heroes synergize well or poorly with other heroes,
      and why.
 * So Lyra is on hold for now.

## Extend professors Petal and Krul with counterbuilding information

 * Or optionally make this an entirely new professor
 * New routine needed:  Whether or not you counterbuilt
 * New routine needed:  Whether or not counterbuilding was even necessary
 * New routine needed:  Whether you opposite counterbuilt (e.g., bought an
   atlas vs. no speed hitting, or armor vs. double CP)
 * Petal can praise you for when you did it, or didn't need to
 * Krul can criticize you for when you didn't do it, but needed to
 * Krul can really criticize you for opposite counterbuilding

## Extend professors Petal and Krul with rotation information

 * Or optionally make this an entirely new professor
 * New routine needed:  How many times you rotated when you should have,
   and how many times you failed to rotate when you should have rotated
 * Petal can praise you for high % of siezing rotation opportunities
 * Krul can criticize you for a low % of them

## New professor: Flicker

 * Topic: vision
 * Unfortunately, many of these are not yet possible with the telemetry data
   we have now, so Flicker is on indefinite hold.  When the data is
   available, I'd like to do this with it:
 * Average number of traps on map at once (all these are compared across
   all teams at your skill tier)
 * Percent of the time someone on your team possessed flares, gun, or
   contraption
 * Average number of traps in the enemy's side of the map at once
 * Number of flares fired
 * Number of flares that revealed enemies or traps
