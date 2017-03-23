
# Plans for the future of this project

Here's a list of things I'd like to add to this project.  I'll add as many
as I can by
[the challenge deadline](https://developer.vainglorygame.com/rules),
and if I like what I have by then, I'll submit it.

## New professor: Celeste

 * Focuses on power spikes
 * Choose a constant C, such as 30 seconds.  It may need to change.
 * Loop through every event in the match.
    * If it's a `LearnAbility` that maxes out the ability, mark that as a
      power spike at the nearest start of a C-second interval, for the
      owning team.
    * If it's a `BuyItem` that is a tier3 item in WP, CP, or utility, mark
      that as a power spike as well, for the owning team.
    * If it's a kill of a hero, mark that as an accomplishment within the
      C-second interval in which it happened, for the appropriate team.
    * If it's a kill of an objective, mark that as an accomplishment within
      the C-second interval in which it happened, for the appropriate team.
 * Output a table with these columns:
    * Time period (0:00-0:30, 0:30-1:00, etc., every C-second block)
    * Spikes on your team (names of heroes in that time block that had
      a spike)
    * Spikes on enemy team (same)
    * Your advantage (an integer, number of spikes in your column minus
      number of spikes in enemy column)
    * Kills (us/them) (how many each team got in that time slice), and
      internally count each as +1/-1 for scoring this interval)
    * Objectives (us/them) (how many each team got in that time slice), and
      internally count each as +3/-3 for scoring this interval)
    * Grade
       * If they had more spikes, score boundaries between FDCBA:
         -5.5, -3.5, -1.5, +1.5
       * If no one had any power spikes, score boundaries between FDCBA:
         -4.5, -2.5, -0.5, +2.5
       * If we had more spikes, score boundaries between FDCBA:
         -2.5, -0.5, +2.5, +5.5
    * Count each FDCBA as 50, 60, 75, 85, 100, respectively, and average
      for an overall grade from Celeste.

## New professor: Vox

 * Need this new utility:  A function that assesses whether a build was WP,
   CP, or neither
 * How common was my build?
 * This will not only be a comparison among people in your tier and role,
   but restricted to the same WP/CP choice as you made (requires a
   utility given below)
 * A list of your items (with pictures) and next to each, a progress bar
   of length proportional to how common the item was among the population
   mentioned in the previous bullet point
 * At the end, some comments about whether you might need to rethink your
   build or not

## New professor: Lyra

 * Topic: Team composition and drafting
    * List all positive synergies in your team and counters against enemies
    * List all snyergies on enemy team and their counters to your team
 * New data required, which I just won't have time to get before the
   challeng ends:
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
