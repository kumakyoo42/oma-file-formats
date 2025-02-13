# Description of temporary files used in Oma

***Note: [Oma](https://github.com/kumakyoo42/Oma) software (including
additional programs like [Opa](https://github.com/kumakyoo42/Opa) and
[libraries](https://github.com/kumakyoo42/OmaLibJava)) and related
file formats are currently experimental and subject to change without
notice.***

***Note: The file formats described in this file are given for
completeness. They are subject to change without notice and they even
remain subject to change without notice, after the experimental stage
of the Oma software and the other data formats is finished. The
description provided might be out dated or even completely wrong. Use
with care!***

## tmp1

The temporary file `tmp1` is the result of the first of the three
conversion steps in Oma. In this step ids of various elements are
replaced by the coordinates of these elements and relations are split
into ways, areas and collections.

The format of tmp1 files is just a sequence of elements:

    <tmp1> ::= <element>*

The structure of the elements themselves depends on the type of the
element in question. The type of the element is identified by the
first byte.

    <element> (BoundingBox) ::=
      byte 'B'
      <bounding box>

    <element> (Node) ::=
      byte 'N'
      <meta>
      <coord>
      <tags>
      <members>

    <element> (Way) ::=
      byte 'W'
      <meta>
      smallint count
      <coords>*
      <tags>
      <members>

    <element> (Area) ::=
      byte 'A'
      <meta>
      smallint count
      <coords>*
      smallint count
      <hole>*
      <tags>
      <members>

    <element> (Collection) ::=
      byte 'C'
      <meta> (id always present)
      <bounding box>
      <tags>
      <members>

    <hole> ::=
      smallint count
      <coords>*

    <bounding box>
      int minlon
      int minlat
      int maxlon
      int maxlat

    <tags> ::=
      smallint count
      <key-value pair>*

    <members> ::=
      smallint count
      <member>

    <member> ::=
      long id
      string role
      smallint position

The meta data is stored similar to the way they are stored in Oma
files. With the exception of the id of collections, entries, that are
not needed later (because the corresponding bits in the features byte
of the Oma file are not set), are omitted.

    <meta> ::=
      long     id
      smallint version
      long     timestamp
      long     changeset
      int      uid
      string   username

Coordinates can take two different appearances: They are either stored
as two ints or, in case of ways and when not known, as the id of the
node which contains the coordinates. To avoid confusion,
`0x7f00000000000000` is added to the node id. This ensures, that node id
and lon/lat coordinates cannot be confused. Coordinates are never
delta encoded.

    <coords> ::=
      int lon
      int lat

    <coords> ::=
      long node_id

Key-value pairs are stored as two strings.

    <key-value pair> ::=
      string key
      string value

## tmp2

The intermediate format created in the second step of Oma ist quite
similar to the final Oma format: Header and chunktable are identical,
but there is no typetable.

    <chunk> ::=
      int count
      <element>*

The chunks themselves aren't divided into blocks and slices, but just
contain the number of elements followed by the elements. Elements are
encoded the same way, they are encoded in Oma files. Delta encoding of
coordinates is used and resetted at the beginning of every chunk.
There is no compression.

## Temporary file `n`

    <n> ::=
      <metadata with id>
      int lon
      int lat
      <tags>

## Temporary file `w`

    <w> ::=
      <metadata with id>
      smallint count
      <coord>*
      <tags>

## Temporary file `rw`

    <rw> ::=
      <metadata with id>
      smallint count
      <member>*
      <tags>

## Temporary file `ra`

    <ra> ::=
      <metadata with id>
      smallint count
      <member>*
      <tags>

## Temporary file `rc`

    <rc> ::=
      <metadata with id>
      smallint count
      <member>*
      <tags>

## Temporary file `nodes`

    <nodes> ::= <node>*

    <node> ::=
      long id
      int lon
      int lat

## tmp.nodes

If the coordinates of all nodes cannot be kept in memory completely in
the first step of Oma, part of them are written to a temporary file as
a sequence of nodes:

    <tmp.nodes> ::= <node>*

    <node> ::=
      long id
      int lon
      int lat

## tmp.chunks

In the second step of oma, if not all chunks fit into memory, the
largest chunks are written to temporary files. They are identical to
the chunks in tmp2 files, apart from the initial count, which is
missing.

## tmp.split

In the third step of oma, way chunks are splitted into area and way
chunks. The way chunks are saved in memory while the area chunks are
written directly to the output file. If a way chunk does not fit
completely into memory, a temporary split file is written. This is a
sequence of ways identical to the ways in Oma files.
