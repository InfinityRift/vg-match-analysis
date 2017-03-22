
# Plans for the future of this project

Here's a list of things I'd like to add to this project.  I'll add as many
as I can by
[the challenge deadline](https://developer.vainglorygame.com/rules),
and if I like what I have by then, I'll submit it.

## General improvements

 * The match list should say which ones have telemetry data available, so
   you don't have to click through, but you already know beforehand which
   ones to not bother clicking
 * Have faculty start to give letter grades in their subjects, and put them
   next to the faculty member's name, but on the right, in big letters

## New professor: Ringo

 * Focuses on your CS
 * Quote: Ha, I don't miss.
 * Report CS/minute in early, mid, and late game
 * Compare this to others in your role and tier (still by game time block!)

## New professor: SAW

 * Focuses on your damage
 * Quote: Here comes the pain!
 * Compares your total damage to all objectives across data archive
 * Compares your damage per second to all objectives across data archive
 * Compares your total damage in all team fights across data archive
 * Compares your damage per second in team fights across data archive
 * Compares your total damage-to-(kills+assists) ratio across archive

## New professor: Ardan

 * Analyzes your support
 * Quote: I go where I'm needed.
 * How early you got fountain (compared to archive)
 * How early you got the next t3 support item after fountain (compared
   to the archive)
 * How much damage you soaked up in fights (compared across the archive)
 * Total damage to your team divided by total team deaths (means your
   team can get out of danger or heal to stay alive) -- this is a proxy
   until telemetry data will tell us when fountains or crucibles are
   activated and what their results are

## New professor: Vox

 * Need this new utility:  A function that assesses whether a build was WP,
   CP, or neither
 * How common was my build?
 * Quote: These guys are waaay too into these crystal things.
 * This will not only be a comparison among people in your tier and role,
   but restricted to the same WP/CP choice as you made (requires a
   utility given below)
 * A list of your items (with pictures) and next to each, a progress bar
   of length proportional to how common the item was among the population
   mentioned in the previous bullet point
 * At the end, some comments about whether you might need to rethink your
   build or not

## New professor: Celeste

 * Data needed:  A list of what levels each hero has a power spike at
 * Focuses on power spikes
 * Quote: Does it burn?
 * Output a table with these columns:
    * Time period (0:00-0:30, 0:30-1:00, etc., every 30s block)
    * Spikes on your team (names of heroes in that time block that had
      a spike)
    * Spikes on enemy team (same)
    * Your advantage (an integer, number of spikes in your column minus
      number of spikes in enemy column)
    * Kills (how many your team got in that time slice)
    * Objectives (how many your team got in that time slice)
    * Assessment (Capitalized, Overcame, Missed opportunity, etc.)

## New professor: Samuel

 * Requires this data and routine:
    * A partitioning of the map (exhaustively) into named regions
    * A function that maps any position to its named region
 * Quote: Want me to kill your boo-boos?
 * Focuses on your deaths
    * Where did I die?
       * Absolute positioning: list of regions on the map where you died,
         and how often in each (requires a utility, listed below)
       * Relative positioning: how many times you died with one ally near,
         with two near, and with none near
    * When did I die?
       * Absolute: number of deaths in early game (before 8m), mid game
         (from then until 15m) and late game (after 15m)
       * Relative:
          * Within a cluster of other deaths (big fight)?
          * Within a cluster of ally deaths only (slaughter)?
          * Within a cluster of enemy deaths (worth it)?

## New professor: Baron

 * New routine:  For every 2-second interval in the match in which the
   player hit an enemy hero, classify it as:
    * You focused the same person all your nearby teammates were also
      hitting in that interval - Good teamwork
    * You focused one enemy, but one nearby ally was focusing a different
      one, or both nearby allies were focusing two different ones - Bad
      teamwork
    * You focused one enemy, but two nearby allies were focusing the same
      different enemy - Get with the program
    * You shot multiple people during that interval, or all other types of
      situation besides those considered above - Don't include in data
 * Targeting and focusing
 * Quote: Focus is good, but kill everything just in case.
 * How often was I hitting X and both teammates were hitting Y?  (You
   were the one not with the program.)
 * How often were we all hitting different enemies?  (Bad teamwork.)
 * How often were we all hitting the same enemy?  (Good teamwork.)
 * How often was one of my allies not with the program?  (Not your
   fault.)
 * Show this as a pie chart, the team fight pie!

## New professor: Lyra

 * New data:
    * A list of which heroes work well or poorly into which other heroes,
      and why
    * A list of which heroes synergize well or poorly with other heroes,
      and why.
 * Topic: Team composition and drafting
 * Quote: You'll be safer with me.
   (All of these require some utilities listed below.)
    * List all positive snyergies in your team and counters against enemies
    * List all snyergies on enemy team and their counters to your team

## New professor: Flicker

 * Topic: vision
 * Quote: No one is in this bush, no one at all!
 * Unfortunately, many of these may not yet be possible...check the
   telemetry details.
 * Average number of traps on map at once (all these are compared across
   all teams at your skill tier)
 * Percent of the time someone on your team possessed flares, gun, or
   contraption
 * Average number of traps in the enemy's side of the map at once
 * Number of flares fired
 * Number of flares that revealed enemies or traps

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
