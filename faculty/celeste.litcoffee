
# Prof. Celeste

This is the robot brain of Prof. Celeste, one of the professors at VGU.
She looks into whether you capitalized on your power spikes.

As with all faculty, he provides one method, `advice`, which takes a match,
participant, and harvested match data, and creates an object of advice, as
documented in [the faculty module](../faculty.litcoffee).  The match is
required to already have its telemetry data embedded.

    exports.advice = ( match, participant, matchData, archive ) ->
        prof : 'Prof. Celeste'
        quote : 'Does it burn?'
        topic : 'Capitalizing on your power spikes (like overdriven helios,
            for example), and shutting down power spikes of the enemy team.'
        short : 'Coming soon'
        long : 'Prof. Celeste is doing some field work and we expect her
            back in the laboratory with freshly captured minions any day
            now.'
        # letter : ''
        # data : [ ]

The names of all ultimate abilities:

    ultimates = [
        'HERO_ABILITY_ADAGIO_FRIENDSHIP_NAME' # I think?
        'HERO_ABILITY_ALPHA_C_NAME'
        'HERO_ABILITY_ARDAN_C'
        'HERO_ABILITY_BARON_C_NAME'
        'HERO_ABILITY_HERO021_C_NAME' # blackfeather
        'HERO_ABILITY_CATHERINE_DEADLY_GRACE_NAME' # maybe??
        'HERO_ABILITY_CELESTE_C_NAME'
        'HERO_ABILITY_HERO036_C_NAME' # flicker
        'HERO_ABILITY_FORTRESS_C_NAME'
        'HERO_ABILITY_GLAIVE_BLOODSONG_NAME'
        'HERO_ABILITY_GRUMPJAW_C_NAME'
        'HERO_ABILITY_GWEN_C_NAME'
        'HERO_ABILITY_IDRIS_C_NAME'
        'HERO_ABILITY_JOULE_ORBITAL_NUKE' # I think?
        'HERO_ABILITY_KESTREL_C_NAME'
        'HERO_ABILITY_KOSHKA_FRENZY_NAME'
        'HERO_ABILITY_HERO009_SHIMMERHEART_NAME' # ??
        'HERO_ABILITY_LANCE_C_NAME'
        'HERO_ABILITY_LYRA_C_NAME'
        'HERO_ABILITY_OZO_C_NAME'
        'HERO_ABILITY_PETAL_THORNSTORM_NAME'
        'HERO_ABILITY_PHINN_C_NAME'
        'HERO_ABILITY_REIM_C_NAME'
        'HERO_ABILITY_RINGO_HELLFIRE_SAKE_NAME'
        'HERO_ABILITY_RONA_C_NAME'
        'HERO_ABILITY_SAW_EXPLOSIVE_TIPPED_SHELLS_NAME'
        'HERO_ABILITY_SAMUEL_C_NAME'
        'HERO_ABILITY_SKAARF_C_DRAGON_BREATH'
        'HERO_ABILITY_SKYE_C_NAME'
        'HERO_ABILITY_SAYOC_C' # Taka
        'HERO_ABILITY_VOX_C_NAME'
    ]
