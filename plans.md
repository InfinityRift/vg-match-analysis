
# Plans for the future of this project

Here's a list of things I'd like to add to this project.  I can't add any
more before
[the challenge deadline](https://developer.vainglorygame.com/rules),
but this is just thinking ahead in case I play with this project more after
the deadline.

## Feature request

 * Allow players to have their casual matches graded, too.

## Bug report

 * Visual glitches on some devices, [as shown in this
   tweet](https://twitter.com/VGsenlark/status/850185258158800897/photo/1)

## Quality of Life/UX Improvements

 * Some grades don't make sense for some roles.  For instance, the top grade
   is always Ringo grading CS, even though captains don't care about their
   CS.  Some good captain players have even told me they should get more
   points for *lower* CS.  Three ideas come out of this:
    * Organize the UI more like a report card, where you don't scroll to see
      the subjects, but you choose them from tabs.  Then things you don't
      want to see, you just never see.
    * Make each professor return a relevance assessment as one of the
      properties in the advice object.  Sort the resulting advice list by
      relevance, with the most relevant stuff first.
    * If a professor returns a low relevance assessment, make them say
      something about it in their feedback.  For instance, right now Ardan
      says that his advice probably only applies to captains.  Those kinds of
      comments make the AI seem smarter and more human, so put them everywhere
      that the relevance scores are low.
 * Create a new university on [Rate My
   Professors](http://www.ratemyprofessors.com/) and add all the faculty.
   Then add links from each of their output to go complain/brag about grades
   you got from them.

## Quality of code improvements

 * Factor all the JS out of the HTML pages into sensible modules.
 * Consider rewriting it as CS code, and adding a build process that
   compiles it, so the whole codebase is documented and readable on GitHub.

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

## New professor: Skaarf

 * His quote will be dragon onomatopoeia only.  His advice will be gestures
   that are explained in plain text, since he can't actually say anything.
 * New routine needed:  How many times you rotated when you should have,
   and how many times you failed to rotate when you should have rotated

## Extend professor Flicker

 * Unfortunately, many of these are not yet possible with the telemetry data
   we have now, so Flicker is on indefinite hold.  When the data is
   available, I'd like to do this with it:
 * Average number of traps on map at once (all these are compared across
   all teams at your skill tier)
 * Average number of traps in the enemy's side of the map at once
 * Number of flares fired
 * Number of flares that revealed enemies or traps
