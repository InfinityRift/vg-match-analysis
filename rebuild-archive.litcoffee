
# Rebuild the stats from the local data archive

This script calls one function in the Archivist module, the function that
reads the current local data archive of matches and recomputes all stats in
them, saving the result to `full-archive.json`.  See [that module's documentation](archivist.litcoffee) for details, particularly the
`rebuildArchive` function.

First, create the API access tools.  Note that you need your Vainglory API
key as an environment variable visible to this script when it runs.

    vainglory = require 'vainglory'
    key = process.env.VG_API_KEY

Import the Archivist module and set some parameters.  Hand it the
`vainglory` object just created, so it can make queries using my API key.

    archivist = require './archivist'
    archivist.setQueryObject new vainglory key
    archivist.setMatchArchiveFolder 'archive'
    require './harvesters'
    .installInto archivist

Now let's load the metadata from the last time we did this, so we can
preserve it.

    console.log "Loading metadata..."
    archivist.setMetaData archivist.allArchiveResults().metadata

And rebuild the archive.

    archivist.rebuildArchive()
