# Description of the TYPE File Format

***Note: [Oma](https://github.com/kumakyoo42/Oma) software (including
additional programs like [Opa](https://github.com/kumakyoo42/Opa) and
[libraries](https://github.com/kumakyoo42/OmaLibJava)) and related
file formats are currently experimental and subject to change without
notice.***

## Structure

Type files define keys and values for blocks and slices as well as
clues for separating ways from areas. Additionally they contain
a list of life-cycle-prefixes.

Type files use an indentation notation (known from python programs)
with 0, 2, 4 or 6 spaces at the beginning of each line. Empty lines
are ignored.

Lines without spaces at the beginning start a section (`NODE`, `WAY`,
`COLLECTION`, `LIFECYCLE`).

In the `NODE` section all lines with 2 spaces form a list of keys, that
will be used for blocks. After every key an arbitrary number of values
(with 4 spaces before them) can be listed. These are used for slices
inside the blocks with the key they belong to.

The `WAY` section is similar to the `NODE` section, but there is a layer
between the keys and the values. Thus all values are preceded by 6
spaces. Entries with 4 spaces can be `IS_AREA`, `EXCEPTIONS`, `WAY` and
`AREA`. `IS_AREA` must be the first entry. If it is present, all values
are considered to be areas. If not present, all values are considered
to be ways. The `EXCEPTIONS` section lists values, where this assumption
is negated. `WAY` and `AREA` sections list just the values.

The `COLLECTION` section is identical to the `NODE` section.

The `LIFECYCLE` section contains a list of lifecycle-prefixes, every one
preceded by 2 spaces, but without colon.

## Example "default.type"

The following excerpts are taken from the file
[default.type](https://github.com/kumakyoo42/Oma/blob/main/default.type)
of the OMA software:

    NODE
      addr:housenumber
      natural
        tree
        peak
        spring
      highway
    [...]

Keys of nodes are `addr:housenumber`, `natural`, `highway` and so on.
`addr:housenumber` has no common values, for `natural` there are
three: `tree`, `peak` and `spring`.

    WAY
      building
        IS_AREA
        AREA
          yes
          house
          garage
          [...]
      highway
        EXCEPTIONS
          rest_area
          services
          platform
        WAY
          service
          track
          footway
          [...]
      landuse
    [...]

Keys of ways (and areas) are `building`, `highway`, `landuse` and so
on. All entries with key `building` are considered areas. Common values are
`yes`, `house`, `garage` and several more.

Entries with key `highway` are considered ways (`IS_AREA` is absent).
There are three exceptions, namely `rest_area`, `services` and
`platform`. Common values are `service`, `track`, `footway` and
several more.

    COLLECTION
      route
        bus
        hiking
        [...]
      public_transport

Keys of collections are `route` and `public_transport` (the
information in the `type` tag is not used). `route` has the common
values `bus`, `hiking` and so on, `public_transport` has no common
values.

    LIFECYCLE
      abandoned
      disused
      proposed
      [...]

Life-cycle-prefixes are `abandoned`, `disused`, `proposed` and several
more.
