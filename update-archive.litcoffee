
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
    archivist.setDuration 1*archivist.minutes
    archivist.setStartTime archivist.someTimeAgo 1*archivist.hours
    archivist.setQueryObject new vainglory key
    harvesters = require './harvesters'
    archivist.setArchiveFunction harvesters.archiveFunction

Start the archive-updating process.

    console.log 'Letting archivist run...'
    archivist.startAPIQueries()
