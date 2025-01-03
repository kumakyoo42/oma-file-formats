# Description of temporary files used in Oma

***Note: [Oma](https://github.com/kumakyoo42/Oma) software (including
additional programs like [Opa](https://github.com/kumakyoo42/Opa) and
libraries) and [related file
formats](https://github.com/kumakyoo42/oma-file-formats) are currently
experimental and subject to change without notice.***

***Note: The file formats described in this file are given for
completeness. They are subject to change without notice and they even
remain subject to change without notice, after the experimental stage
of the Oma software and the other data formats is finished. The
description provided might be out dated or even completely wrong. Use
with care!***

## tmp1

The temporary file `tmp1` is the result of the first of the three
conversion steps in Oma. In this step ids of various elements are
replaced by the coordinates of these elements. During this process the
tmp1 file may be read in several times and rewritten in a modified
version. In the final version there are no multipolygons (they are
replaced by a sequence of areas).

The format of tmp1 files is just a sequence of elements:

    <tmp1> ::= <element>*

The structure of the elements themselves depends on the type of the
element in question. The type of the element is identified by the
first byte.

    <element> (BoundingBox) ::=
      byte 'B'
      int minlon
      int minlat
      int maxlon
      int maxlat

    <element> (Node) ::=
      byte 'N'
      <meta>
      int count of tags
      <coord>
      <key-value pair>*

    <element> (Way) ::=
      byte 'W'
      <meta>
      int count of nodes
      int count of tags
      <coords>*
      <key-value pair>*

    <element> (Multipolygon) ::=
      byte 'M'
      <meta>
      int count of tags
      <key-value pair>*
      int count of members
      <member>*

    <element> (Area) ::=
      byte 'A'
      <meta>
      int count of nodes
      <coords>*
      int count of holes
      <hole>*

      int count of tags
      <key_value pair>*

    <member> (not replaced) ::=
      byte role ('o'|'i')
      long id

    <member> (replaced) ::=
      byte role ('O'|'I')
      int count of nodes
      <coords>*

    <hole> ::=
      int count of nodes
      <coords>*

The meta data is stored similar to the way they are stored in Oma
files, but the version is saved as an int and the username is saved in
a slightly different version of UTF8, which is used by Javas
DataInput- and DataOutputStreams. Entries, that are not needed later
(because the corresponding bits in the features byte of the Oma file
are not set), are omitted.

    <meta> ::=
      long     id
      int      version
      long     timestamp
      long     changeset
      int      uid
      utf8     username

Coordinates can take to different appearances: They are either stored
as two ints or, in case of ways and when not known, as the id of the
node which contains the coordinates. To avoid confusion,
`0x7f00000000000000` is added to the node id. This ensures, that node id
and lon/lat coordinates cannot be confused.

    <coords> ::=
      int lon
      int lat

    <coords> ::=
      long node_id

Key-value pairs are also stored slightly different to the version in
oma files: Again Javas UTF8 version is used.

    <key-value pair> ::=
      utf8 key
      utf8 value

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
