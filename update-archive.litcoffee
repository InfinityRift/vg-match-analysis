
# Update the local data archive

This short script simply starts up an instance of the Archivist module.
See [that module's documentation](archivist.litcoffee) for details of what
that module does when started.

First, create the API access tools.  Note that if you've cloned this
repository, you won't have the `my-api-key` module, because I'm not
committing my private API key to the repository.  You'll have to create
your own module of that name containing just one attribute, a string
containing your API key.

    vainglory = require 'vainglory'
    { key } = require './my-api-key'

Import the Archivist module and set some parameters.  Hand it the
`vainglory` object just created, so it can make queries using my API key.

    archivist = require './archivist'
    archivist.setStartTime new Date 2017, 2, 16
    archivist.setEndTime new Date 2017, 2, 21
    archivist.setMaxima ranked : 2 # everything else zero
    archivist.setQueryFrequency 7*archivist.seconds
    archivist.setQueryObject new vainglory key
    require './harvesters'
    .installInto archivist

Now I want to choose the value for `setDuration` based on having a priori
chosen how many matches I want in my archive.  This is not necessary for
every use of the `archivist` module; it's just what I want to do here.  So
I choose this value:

    getThisManyMatches = 200

Now I compute all this stuff to figure out what value to pass to
`setDuration`, and doing so then completes the archivist setup process.

    numberEachInterval = 0
    for own gameMode, count of archivist.getMaxima()
        numberEachInterval += count
    numberOfIntervals = getThisManyMatches / numberEachInterval
    totalDuration = archivist.getEndTime() - archivist.getStartTime()
    archivist.setDuration totalDuration / numberOfIntervals

Start the archive-updating process.

    process.on 'unhandledRejection', ( err ) -> console.log err
    startedAt = new Date
    startedWithArchiveAt = archivist.latestDateInArchive()
    console.log 'Starting to update archive...'
    archivist.setDebugging on
    archivist.startAPIQueries ( progress ) ->
        progress ?= archivist.getStartTime()
        elapsed = ( new Date ) - startedAt
        completed = progress - startedWithArchiveAt
        toComplete = archivist.getEndTime() - startedWithArchiveAt
        estimatedTotalTime = if completed > 0
            elapsed * toComplete / completed
        else
            undefined
        percentDone = if toComplete > 0
            100 * completed / toComplete
        else
            undefined
        remainingString = if estimatedTotalTime
            left = ( estimatedTotalTime - elapsed ) / 60000
            "estimating #{Number( left ).toFixed 1}min left"
        else
            'no completion estimate available yet'
        console.log "Completed #{Number( percentDone ).toFixed 1}% in
            #{Number( elapsed / 60000 ).toFixed 1}min,
            #{remainingString}"
