
# Plans for the future of this project

Here's a list of things I'd like to add to this project.  I'll add as many
as I can by
[the challenge deadline](https://developer.vainglorygame.com/rules),
and if I like what I have by then, I'll submit it.

## New professor: Baron

 * Targeting and focusing
 * Quote: Focus is good, but kill everything just in case.
 * New routine:
    * First loop through the telemetry data and for every 2-second interval
      in which the player in question hit an enemy, create a list of that
      interval's DealDamage events.  The result of this pass is thus a list
      of lists of events, each sublist for a separate 2-second interval.
    * Now loop through those lists of interval lists, and classify each one
      as one of these categories:
       * The player had no allies nearby who were hitting enemies (type 1)
       * The player or one of its nearby allies was hitting multiple
         enemies during that interval (type 2)
       * The player and each nearby ally were all hitting the same enemy
         (type 3)
       * The player and each nearby ally were each hitting a different
         enemy (type 4)
       * The player and both nearby allies were hitting two different
         enemies (type 5)
    * Delete and ignore everything of type 1.
    * The other four types then make up a partition of the whole, which can
      be expressed as percents of a pie chart.  Describe them to the user
      like so:
       * Type 3 - Good teamwork (all focusing the same enemy)
       * Type 5 - Neutral (all focusing two enemies)
       * Type 4 - Bad teamwork (all focusing different enemies)
       * Type 2 - In transition (shifting focus among enemies)
 * Show this as a pie chart, the team fight pie!

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
