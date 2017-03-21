
# Plans for the future of this project

Here's a list of things I'd like to add to this project.  I'll add as many
as I can by
[the challenge deadline](https://developer.vainglorygame.com/rules),
and if I like what I have by then, I'll submit it.

## New professors

 * Samuel - focuses on your deaths ("Want me to kill your boo-boos?")
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
 * Ringo - focuses on your CS ("Ha, I don't miss.")
    * Report CS/minute in early, mid, and late game
    * Compare this to others in your role and tier (still by game time
      block!)
 * SAW - focuses on your damage ("Here comes the pain!")
    * Compares your total damage to all objectives across data archive
    * Compares your damage per second to all objectives across data archive
    * Compares your total damage in all team fights across data archive
    * Compares your damage per second in team fights across data archive
    * Compares your total damage-to-(kills+assists) ratio across archive
 * Ardan - analyzes your support ("I go where I'm needed.")
    * How early you got fountain (compared to archive)
    * How early you got the next t3 support item after fountain (compared
      to the archive)
    * How much damage you soaked up in fights (compared across the archive)
    * Total damage to your team divided by total team deaths (means your
      team can get out of danger or heal to stay alive) -- this is a proxy
      until telemetry data will tell us when fountains or crucibles are
      activated and what their results are
 * Lyra - team composition and drafting ("You'll be safer with me.")
   (All of these require some utilities listed below.)
    * List all positive snyergies in your team and counters against enemies
    * List all snyergies on enemy team and their counters to your team
 * Celeste - power spikes ("Does it burn?") (Requires utilities listed
   below)
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
 * Vox - how common was my build? ("These guys are waaay too into these
   crystal things.")
    * This will not only be a comparison among people in your tier and role,
      but restricted to the same WP/CP choice as you made (requires a
      utility given below)
    * A list of your items (with pictures) and next to each, a progress bar
      of length proportional to how common the item was among the population
      mentioned in the previous bullet point
    * At the end, some comments about whether you might need to rethink your
      build or not
 * Baron - targeting and focusing ("Focus is good, but kill everything just
   in case.")
    * How often was I hitting X and both teammates were hitting Y?  (You
      were the one not with the program.)
    * How often were we all hitting different enemies?  (Bad teamwork.)
    * How often were we all hitting the same enemy?  (Good teamwork.)
    * How often was one of my allies not with the program?  (Not your
      fault.)
    * Show this as a pie chart, the team fight pie!
 * Flicker - vision ("No one is in this bush, no one at all!")
    * Unfortunately, many of these may not yet be possible...check the
      telemetry details.
    * Average number of traps on map at once (all these are compared across
      all teams at your skill tier)
    * Percent of the time someone on your team possessed flares, gun, or
      contraption
    * Average number of traps in the enemy's side of the map at once
    * Number of flares fired
    * Number of flares that revealed enemies or traps

## New features of existing professors

 * Have faculty start to give letter grades in their subjects
 * Petal
    * When you changed position to get near a team fight (good rotation)
    * When you counterbuilt well
 * Krul
    * When you failed to change position to get near a team fight, and your
      allies suffered for it (lack of rotation)
    * When you failed to counterbuild

## Utilities

 * For Samuel:  A partitioning of the map (exhaustively) into named
   regions, and a function that maps any position to its named region
 * For Lyra:  A list of which heroes work well or poorly into which other
   heroes, and why.  Another list of which heroes synergize well or poorly
   with other heroes, and why.
 * For Celeste:  A list of what levels each hero has a power spike at
 * For Vox:  A function that assesses whether a build was WP, CP, or neither
