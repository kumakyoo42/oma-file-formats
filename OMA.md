# Description of the OMA File Format

*Note: This document is considered final. Updates will only be made to
clearify unclear statements, to correct mistakes, or to add supported
compression algorithms. The file format itself will not change unless
the version byte increases.*

## General Structure

Oma files contain a binary representation of [OSM
data](https://wiki.openstreetmap.org/wiki/Planet.osm). A file in OMA
format is divided into [chunks](#chunks). Each chunk contains data of
a certain region of the world of a certain type (node, way, area
etc.). Each chunk is divided into [blocks](#blocks) and each block is
divided into [slices](#slices) using pivotal tags. Slices contain the
[elements](#elements). Slices can be stored in compressed version to
reduce file size.

## Basic Data Formats

All numbers in Oma files are stored in big endian order, and in most
cases they are signed. `byte` refers to a single-byte number, `short`
to a two-byte number, `int` to a four-byte number and `long` to an
eight-byte number.

In several places, you can expect to see small unsigned numbers. These
are stored as `smallints`: Values 0 to 254 are stored as a single
(unsigned) `byte`, values 255 to 65534 are stored as a 255 byte
followed by an (unsigned) `short` and all larger values are stored as
three 255 bytes followed by a (signed) `int`.

Geographic coordinates are stored in WGS84, multiplied by
10<sup>7</sup> and rounded to the nearest integer. Except for bounding
boxes, coordinates are always stored delta encoded: Instead of the
number itself, the difference from the last coordinate is used if it
is small enough, that is if it is between -32767 and 32767 inclusive.
In this case, the difference is stored as a `short`. Larger numbers
are stored as the value -32768 (as `short`) followed by the number
(not the difference) as an `int`. The delta encoding starts anew at
each slice with both coordinates initialised to 0. Missing coordinates
are stored as twice the value 0x7fffffff.

Bounding boxes are stored as four `ints`: the coordinates of the lower
left corner followed by the coordinates of the upper right corner of
the box, longitude before latitude. All bounding boxes include the
points at their edges. Bounding boxes containing the antimeridian
should have a maxlon value less than the minlon value. Such bounding
boxes are not yet supported by the Oma software, but hopefully will be
in the future. If no bounding box is available, all four entries must
be 2<sup>31</sup>-1, which is the maximum value of an `int`.

Strings are stored in UTF-8 encoding. Each `string` is preceded by a
`smallint` representing the number of bytes used in the UTF-8 encoding
of the `string`.

## Grammar

### File

    <oma> ::=
      <header>
      (<chunk>|<chunktable>)+

Every Oma file starts with a header, followed by [chunks](#chunks).
Exactly one of these chunks is a special chunk - called
[chunktable](#chunktable-1) - which contains information about the normal
chunks. This is usually the last chunk of the file, but could be
any chunk.

    <header> ::=
      <magic number>
      byte version
      <features byte>
      <bounding box>
      <chunktable position>
      <header entry>*
      byte 0

    <magic number> ::=
      byte 'O'
      byte 'M'
      byte 'A'

    <features byte> ::=
      byte features

    <bounding box> ::=
      int minlon
      int minlat
      int maxlon
      int maxlat

    <chunktable position> ::=
      long pos

The header consists of a three-byte magic number identifying OMA files
(the ASCII characters O, M and A), a version byte, a features byte, the
bounding box, a pointer to the chunktable and a list of additional header
entries that is terminated by a null byte.

The version byte indicates the version of the format in use. 0 means
experimental. This can be used to develop further versions of the
format or to meet individual needs. 1 indicates the version described
in this document. Higher numbers are reserved for future use.

The features byte is a bitfield, identifying some features of the
file. The bits of the features byte are described in the following
table:

| Bit | Value | Meaning                           |
|-----|-------|-----------------------------------|
|   0 |     1 | elements contain id               |
|   1 |     2 | elements contain version          |
|   2 |     4 | elements contain timestamp        |
|   3 |     8 | elements contain changeset        |
|   4 |    16 | elements contain user information |
|   5 |    32 | each element is added only once   |
|   6 |    64 | *reserved, must be 0*             |
|   7 |   128 | *reserved, must be 0*             |

The first five entries specify whether some meta information is added
for each element. The sixth entry indicates whether elements with
multiple keys are stored only once or multiple times.

The bounding box restricts the locations of the elements. Unless no
bounding box is giveb, all elements of the file must be completely
inside of the bounding box.

The chunktable position specifies the file position where the
chunktable starts.

### Header Entries

    <header entry> ::=
      byte type
      int next
      <type specific data>

Each header entry starts with a byte indicating the type of the entry,
followed by an integer specifying the file position of the next header
entry.

The format of the type-specific data depends on the type. Currently,
only two types are defined: 'c' for a compression algorithm and 't'
for a type table.

If the most significant bit of the type is set, the type-specific data
is compressed.

### Compression Algorithm ###

    <compression algorithm> ::=
      string name
      <algorithm specific data>

This entry specifies which compression algorithm was used to compress
parts of the file. If present, this must be the first header entry and
it must not be compressed.

If the entry is not present or the name is 'NONE', there is no
compressed data in the file.

Currently, only one compression algorithm is defined: the Deflate
algorithm from the ZLIB compression library. Its name must be
'DEFLATE'.

Depending on the compression algorithm used, additional information
may be stored in this header entry. For example, the Zstandard
compression algorithm might store a dictionary here for better
compression and performance. The Deflate compression algorithm does
not store any additional data.

In any case, if a compression algorithm is used, the compressed parts
of this file are always preceeded by an int, which specifies the
length of the compressed part, so that programms may extract the
compressed parts completely from the file and decompress them at once.

*Note: There are plans to add support for the Zstandard compression
algorithm in the near future. Its name will be 'ZSTD'. Further
details will be added to this document in due course.*

### Type Table

    <type table> ::=
      smallint count
      <type table entry>*

    <type table entry> ::=
      byte type
      smallint count
      <key with values>*

    <key with values> ::=
      string key
      smallint count
      <value>*

    <value> ::=
      string value

The type table contains a copy of the type table used to create this
file.

The first entry in the type table is the number of types in the type
table itself. The entries follow after this item.

Each entry is a list of keys with values, preceded by the type and the
number of entries in the list.

A key with values consists of the key followed by the number of values
and then a list of values.

### Chunktable

    <chunktable> ::=
      int count
      <chunktable entry>*

    <chunktable entry> ::=
      long position
      byte type
      <bounding box>

The first item in the chunktable is the number of entries of the
chunktable. After this item, the entries follow.

Each chunktable entry consists of the file position where the chunk
starts, followed by two entries (type and bounding box) which describe
the nature of the elements in this chunk.

Currently the type of a chunk must be one of ('N' for nodes, 'W' for
ways, 'A' for areas and 'C' for collections). It is possible that
further types will be defined in the future.

All elements of a chunk must be completely contained in the bounding
box. If no bounding box is given, the chunk may contain any element
including elements without geographic location.

### Chunks

    <chunk> ::=
      <chunk header>
      (<block>|<blocktable>)+

    <chunk header> ::=
      int position

The structure of a chunk is made up similar to the structure of the
whole file: A short header followed by [blocks](#blocks), one of which
is a special block, which contains the [blocktable](#blocktable-1). Again
this is usually the last block, but not necessarily.

The header of a chunk consists only of one `int`, which is the
position of the blocktable, *relative to the start of the chunk*.

### Blocktable

    <blocktable> ::=
      smallint count
      <blocktable entry>*

    <blocktable entry> ::=
      int position
      string key

The blocktable consists of a `smallint` that specifies the number of
entries in the blocktable, followed by the entries themselves.

Each blocktable entry contains the position of the block (relative to
the start of the chunk) and the key of this block (for example
'highway', 'amenity' and so on). If the block has no key, an empty
string is used.

### Blocks

    <block> ::=
      <block header>
      (<slice>|<slicetable>)+

    <block header> ::=
      int position

The structure of a block is yet similar to the structure of the whole
file and the structure of a chunk: A short header followed by
[slices](#slices), one of which is a special slice. which contains the
[slicetable](#slicetable-1). Again this is usually the last slice, but
not necessarily.

The header of a block consists only of one `int`, which is the
position of the slicetable, *relative to the start of the block*.

### Slicetable

    <slicetable> ::=
      smallint count
      <slicetable entry>*

    <slicetable entry> ::=
      int position
      string value

The slicetable consists of a `smallint` that specifies the number of
entries of the slicetable, followed by the entries themselves.

Each slicetable entry contains the position of the slice (relative to
the start of the block) and the value of this slice (for example if
the key of the block is `highway', the value might be 'service' or
'footway' and so on). If the block has no key or the slice has no
value, an empty string is used.

### Slices

    <slice> ::=
      int count
      <element>*

    <element> ::=
      <geometry> <tags> <members> <meta>

At the beginning of each slice there is an `int`, denoting the number
of elements of this slice, followed by the [elements](elements)
themselves. If slices are compressed, compression does not include the
first four bytes of the slice.

Each element consists of the geometry of the element (depending on the
type of the chunk), followed by the tags of the elements, followed by
meta information.

### Elements

    <geometry> (node) ::=
      <coord>

    <geometry> (way) ::=
      smallint count
      <coord>*

    <geometry> (area) ::=
      smallint count
      <coord>*
      smallint holecount
      <hole>*

    <geometry> (collection) ::=
      smallint count
      <slice definition>*

    <hole> ::=
      smallint count
      <coord>*

    <coord> ::=
      delta lon
      delta lat

    <slice definition>
      byte <type>
      <bounding box>
      string key
      string value

The geometry of a node is just its coordinate pair.

The geometry of a way is a list of coordinate pairs preceeded by the
count of these pairs.

An area consists of an outer ring and optionally an arbitrary number
of holes. The outer ring is saved as a list of coordinate pairs
preceeded by the count of these pairs. Divergent of OSM convention the
starting point of this ring is not repeated at the end. Holes are
saved the same way. The pairs of coordinates of the outer ring must be
stored in clockwise order, the pairs of coordinates in the inner ring
must be stored in counterclockwise order.

The geometry of a collection isn't really a geometry. Instead it's a
list of slices. This list defines the slices, where the members of the
collection can be found. If the list is empty, this information is
missing. In this case, the members can be in any slice.

    <tags> ::=
      smallint count
      <key-value pair>*

    <key-value pair> ::=
      string key
      string value

Tags are saved as a list of key-value pairs, preceded by the count of
these pairs. Each pair consists of two strings, the key and the value
of the tag. Key and value of block and slice, if any, must be repeated
here.

    <members> ::=
      smallint count
      <member>*

    <member> ::=
      long     id
      string   role
      smallint position

Each member entry consists of the id of the collection this element
belongs to, the role it playes and the position, which can be used to
sort the elements of a collection.

    <meta> ::=
      long     id
      smallint version
      long     timestamp
      long     changeset
      int      uid
      string   username

Meta information is only stored if the corresponding bits in the
features byte are set. Otherwise they are skipped. It is possible that
there is no meta information at all. However, if the element is of
type 'collection', the ID is always present.

Meta information consists of the id, the version and the timestamp
(seconds since 1970) of the element, the id of the latest changeset
and uid and username of the user who did the most recent change.

## Example

As an example the file [example.oma](/example.oma) is used. It is a
converted version of the artifical OSM file
[example.osm](/example.osm). ID and timestamp where preserved from the
meta data and the type file [example.type](/example.type) was used.

You might compare this and the following descriptions with
[example.opa](/example.opa), which is a human readable representation
of this binary data.

### Header

The file starts with a header:

    0000  4f 4d 41                 magic number 'OMA'
    0003  01                       version 1
    0004  05                       features: ID (1) and timestamp (4)
    0005  04 b0 ab e1 1c 9c 2f da  bounding box
          04 b0 ba b7 1c 9c 38 f1

The bounding box is made up of four ints: 78687201, 479997914,
78690999, 480000241. Dividing these numbers by 10^7 leads to:
7.8687201, 47.9997914, 7.8690999, 48.0000241.

    0015  00 00 00 00 00 00 04 20  pointer to the chunktable

The Chunktable is located at file position `0x420`.

    001d  63 00 00 00 2a 07 44 45  header entry 'compression'
          46 4c 41 54 45

The first byte gives the type of this entry: `0x63` is the letter 'c'
which tells you that this is a compression entry. Compression entries
must always be the first item in the list of header entrys, so
consecutive entries can be compressed.

The type byte is followed by an int (`0x0000002a`) which gives the
file position, where the next entry starts.

After that there is the string 'DEFLATE', telling you that the deflate
algorithm is used to compress parts of this file.

    002a  f4 00 00 00 c0 00 00 00  header entry 'type table', compressed
          8d 78 da 3d 8e ...

The first byte of this entry is `0xf4`, the character `t` with most
significant bit set. `t` stands for a type table header, the set bit
tells you, that this entry is compressed.

The next four bytes form the pointer `0x000000c0` to the location of
the next header entry. As this entry is compressed, it is followed by
another integer `0x0000008d` which gives the length of the compressed
data. After that, all data is compressed. Uncompressed, it looks like
this:

    +0000  04                       4 entries
    +0001  4e                       'N' node entries
    +0002  02                       2 node entries
    +0003  07 6e 61 74 75 72 61 6c  key 'natural'
    +000b  03                       3 values
    +000c  04 74 72 65 65           value 'tree'
    +0011  04 70 65 61 6b           value 'peak'
    +0016  06 73 70 72 69 6e 67     value 'spring'
    +001d  07 74 6f 75 72 69 73 6d  key 'tourism'
    +0025  01                       1 value
    +0026  0b 69 6e 66 6f 72 6d 61  value 'information'
           74 69 6f 6e
    +0032  57                       'W' way entries
    +0033  03                       3 way entries
    +0034  07 68 69 67 68 77 61 79  key 'highway'
    +003c  03                       3 values
    +003d  07 73 65 72 76 69 63 65  value 'service'
    +0045  05 74 72 61 63 6b        value 'track'
    +004b  07 66 6f 6f 74 77 61 79  value 'footway'
    +0053  07 6c 61 6e 64 75 73 65  key 'landuse'
    +005b  00                       0 values
    +005c  07 6e 61 74 75 72 61 6c  key 'natural'
    +0064  01                       1 value
    +0065  08 74 72 65 65 5f 72 6f  value 'tree_row'
           77
    +006e  41                       'A' area entries
    +006f  03                       3 area entries
    +0070  07 68 69 67 68 77 61 79  key 'highway'
    +0078  00                       0 values
    +0079  07 6c 61 6e 64 75 73 65  key 'landuse'
    +0081  02                       2 values
    +0082  06 6d 65 61 64 6f 77     value 'meadow'
    +0089  08 66 61 72 6d 6c 61 6e  value 'farmland'
           64
    +0092  07 6e 61 74 75 72 61 6c  key 'natural'
    +009a  01                       1 value
    +009b  05 77 61 74 65 72        value 'water'
    +00a1  43                       'C' collection entries
    +00a2  01                       1 collection key
    +00a3  05 72 6f 75 74 65        key 'route'
    +00a9  03                       3 values
    +00aa  03 62 75 73              value 'bus'
    +00ae  06 68 69 6b 69 6e 67     value 'hiking'
    +00b5  07 62 69 63 79 63 6c 65  value 'bicycle'

After this header entry there is only one more byte in the header:

    00c0  00                       end of header entries

### Chunktable

The chunktable starts at byte `0x0420`:

    0420  00 00 00 05              number of chunktable entries is 5
    0424  00 00 00 00 00 00 00 c1  chunk 1 starts at file position 00c1
    042c  4e                       is a node chunk
    042d  03 93 87 00 1c 03 a1 80  with bounding box 6.0, 47.0, 8.0, 48.0
          04 c4 b4 00 1c 9c 38 00
    043d  00 00 00 00 00 00 02 15  chunk 2 starts at file position 0215
    0445  41                       is an area chunk
    0446  03 93 87 00 1c 03 a1 80  with bounding box 6.0, 47.0, 8.0, 48.0
          04 c4 b4 00 1c 9c 38 00
    0456  00 00 00 00 00 00 02 94  chunk 3 starts at file position 0294
    045e  57                       is a way chunk
    045f  03 93 87 00 1c 03 a1 80  with bounding box 6.0, 47.0, 8.0, 48.0
          04 c4 b4 00 1c 9c 38 00
    046f  00 00 00 00 00 00 03 41  chunk 4 starts at file position 0341
    0477  41                       is an area chunk
    0478  00 00 00 00 17 d7 84 00  with bounding box 0.0, 40.0, 10.0, 50.0
          05 f5 e1 00 1d cd 65 00
    0488  00 00 00 00 00 00 03 d7  chunk 5 starts at file position 03d7
    0490  43                       is a collection chunk
    0491  7f ff ff ff 7f ff ff ff  without bounding box
          7f ff ff ff 7f ff ff ff

### Chunk 1

The first chunk starts at `0x00c1`:

    00c1  00 00 01 3b              position of the block table

The position of the block table is relative to the start of the chunk.
Thus it can be found at `0x00c1` + `0x013b` = `0x01fc`.

    01fc  02                       number of block table entries
    01fd  00 00 00 04              start of block 1 is at `0x0004` + `0x00c1` = `0x00c5`
    0201  07 6e 61 74 75 72 61 6c  key of block 1 is 'natural'
    0209  00 00 00 d8              start of block 2 is at `0x00d8` + `0x00c1` = `0x0199`
    020d  07 74 6f 75 72 69 73 6d  key of block 2 is 'tourism'

### Block 1

    00c5  00 00 00 c5              position of the slice table

The position of the slice table is relative to the start of the block.
Thus it can be found at `0x00c5` + `0x00c5` = `0x018a`.

    018a  02                       number of slice table entries
    018b  00 00 00 04              start of slice 1 is at `0x0004` + `0x00c5` = `0x00c9`
    018f  04 74 72 65 65           value of slice 1 is 'tree'
    0194  00 00 00 90              start of slice 2 is at `0x0090` + `0x00c5` = `0x0155`
    0198  00                       slice 2 is without value

### Slice 1

    00c9  00 00 00 03              the slice contains 3 elements
    00cd  00 00 00 84              length of compressed data is `0x0084`
    00d1  78 da 6b 60 60 d9 ...    data is compressed

Uncompressed, the data of the slice looks like this:

    +0000  80 00 04 b0 ae 08        longitude: 7.8687752
    +0006  80 00 1c 9c 37 56        latitude: 47.9999830

The coordinates in a slice are stored delta encoded. Here, the delta
is too large and hence the marker 80 00 tells, that the next four
bytes give the coordinate unencoded.

    +000c  01                       one tag
    +000d  07 6e 61 74 75 72 61 6c  key: 'natural'
    +0015  04 74 72 65 65           value: 'tree'
    +001a  00                       element is not member of any collection
    +001b  00 00 00 00 00 00 63 7d  id is 25469
    +0023  00 00 00 00 68 61 21 f9  timestamp is 1751196153 (2025-06-29, 11:22:33)

The second element:

    +002b  02 0e                    longitude: 7.8688278 (0x04b0ae08 + 0x020e)
    +002d  fb ba                    latitude: 47.9998736 (0x1c9c3756 + 0xfbba - 0x10000)
    +002f  04                       four tags
    +0030  0a 6c 65 61 66 5f 63 79  key: 'leave_cycle'
           63 6c 65
    +003b  09 65 76 65 72 67 72 65  value: 'evergreen'
           65 6e
    +0045  07 6e 61 74 75 72 61 6c  key: 'natural'
    +004e  04 74 72 65 65           value: 'tree'
    +0053  0a 64 65 6e 6f 74 61 74  key: 'denotation'
           69 6f 6e
    +005e  10 6e 61 74 75 72 61 6c  value: 'natural_monument'
           5f 6d 6f 6e 75 6d 65 6e
           74
    +006f  09 6c 65 61 66 5f 74 79  key: 'leaf_type'
           70 65
    +0079  0c 6e 65 65 64 6c 65 6c  value: 'needleleaved'
           65 61 76 65 64
    +0086  00                       element is not member of any collection
    +0087  00 00 00 00 00 00 63 8a  id is 25482
    +008f  00 00 00 00 65 3e 49 b7  timestamp is 1698580919 (2023-10-29, 12:01:59)

The third element:

    +0097  05 50                    longitude: 7.8689638 (0x04b0b016 + 0x0550)
    +0099  02 21                    latitude: 47.9999281 (0x1c9c3310 + 0x0221)
    +009b  01                       one tag
    +009c  07 6e 61 74 75 72 61 6c  key: 'natural'
    +00a4  04 74 72 65 65           value: 'tree'
    +00a9  00                       element is not member of any collection
    +00aa  00 00 00 00 00 00 63 8f  id is 25487
    +00b2  00 00 00 00 68 61 21 f9  timestamp is 1751196153 (2025-06-29, 11:22:33)

### Slice 2

    0155  00 00 00 01              the slice contains 1 element
    0159  00 00 00 2d              length of compressed data is `0x002d`
    015d  78 da 6b 60 ...          data is compressed

Uncompressed:

    +0000  80 00 04 b0 b1 e9        longitude: 7.8688745
    +0006  80 00 1c 9c 36 b4        latitude: 47.9999668
    +000c  01                       one tag
    +000d  07 6e 61 74 75 72 61 6c  key: 'natural'
    +0015  04 72 6f 63 6b           value: 'rock'
    +001a  00                       element is not member of any collection
    +001b  00 00 00 00 00 00 63 7f  id is 25471
    +0023  00 00 00 00 68 61 21 f9  timestamp is 1751196153 (2025-06-29, 11:22:33)

### Block 2

    0199  00 00 00 52              position of the slice table (0x01eb)

    01eb  01                       one slice
    01ec  00 00 00 04              start of slice 1 is at `0x0004` + `0x0199` = `0x019d`
    01f0  0b 69 6e 66 6f 72 6d 61  value for slice 1 is 'information'
          74 69 6f 6e

### Slice 1

    019d  00 00 00 01              one element
    01a1  00 00 00 46              length of compressed data is `0x0046`
    01a5  78 da 6b 60 60 ...       data is compressed

Uncompressed:

    +0000  80 00 04 b0 b0 99        longitude:
    +0006  80 00 1c 9c 35 12        latitude:
    +000c  02                       2 tags
    +000d  07 74 6f 75 72 69 73 6d  key: 'tourism'
    +0015  0b 69 6e 66 6f 72 6d 61  value: 'information'
           74 69 6f 6e
    +0021  0b 69 6e 66 6f 72 6d 61  key: 'information'
           74 69 6f 6e
    +002d  09 67 75 69 64 65 70 6f  value: 'guidepost'
           73 74
    +0037  01                       is member of one collection
    +0038  00 00 00 00 00 00 00 40  id of the collection is 64
    +0040  09 67 75 69 64 65 70 6f  role in the collection is 'guidepost'
           73 74
    +004a  03                       position in the collection is 3
    +004b  00 00 00 00 00 00 63 82  id is 25474
    +0052  00 00 00 00 68 61 21 f9  timestamp is 1751196153 (2025-06-29, 11:22:33)

### Chunk 2

    0215  00 00 00 72              position of the block table (0x287)

    0287  01                       one entry
    0288  00 00 00 04              start of block 1 at 0x0004
    028c  07 6e 61 74 75 72 61 6c  key of block 1 is 'natural'

### Block 1

    0219  00 00 00 63              position of the slice table (0x268)

    027c  01                       one entry
    027d  00 00 00 04              start of slice 1 at 0x0004
    0281  05 77 61 74 65 72        value of slice 1 is 'water'

### Slice 1

    021d  00 00 00 01              one element
    0221  00 00 00 57              length of compressed data is `0x0057`

Uncompressed:

    +0000  05                       outer of area has got 5 coordinates
    +0001  80 00 04 b0 b6 33        longitude: 7.8689481
    +0007  80 00 1c 9c 34 2a        latitude: 47.9999105
    +000d  ff 24                    longitude: 7.8689234
    +000f  fe fb                    latitude: 47.9998982
    +0011  fe df                    longitude: 7.8689334
    +0013  ff da                    latitude: 47.9998719
    +0015  ff 9c                    longitude: 7.8689623
    +0017  01 07                    latitude: 47.9998757
    +0019  00 f7                    longitude: 7.8689843
    +001b  00 7b                    latitude: 47.9999018
    +001d  00                       no holes
    +001e  03                       3 tags
    +001f  07 6e 61 74 75 72 61 6c  key: 'natural'
    +0027  05 77 61 74 65 72        value: 'water'
    +002d  04 6e 61 6d 65           key: 'name'
    +0032  0d 4c 61 6b 65 20 57 68  value: 'Lake Whatever'
           61 74 65 76 65 72
    +0040  05 77 61 74 65 72        key: 'water'
    +0045  04 6c 61 6b 65           value: 'lake'
    +004a  00                       element is not member of any collection
    +004b  00 00 00 00 00 00 02 ba  id is 698
    +0052  00 00 00 00 68 61 21 f9  timestamp is 1751196153 (2025-06-29, 11:22:33)

### Chunk 3

    0294  00 00 00 a0              position of block table (0x334)

    0334  01                       one entry
    0335  00 00 00 04              start of block 1 at 0x0004
    0339  07 68 69 67 68 77 61 79  key of block 1 is 'highway'

### Block 1

    0298  00 00 00 8f              position of slice table (0x327)

    0327  01                       one entry
    0328  00 00 00 04              start of slice 1 at 0x0004
    032c  07 66 6f 6f 74 77 61 79  key of slice 1 is 'footway'

### Slice 1

    029c  00 00 00 04              4 elements
    02a0  00 00 00 83              length of compressed data is `0x0083`

Uncompressed:

    +0000 04                       way has 4 coordinates
    +0001 80 00 04 b0 b0 11        longitude: 7.8688273
    +0007 80 00 1c 9c 31 7c        latitude: 47.9998332
    +000d 03 19                    longitude: 7.8689066
    +000f 00 b3                    latitude: 47.9998511
    +0011 ff 13                    longitude: 7.8688829
    +0013 02 1a                    latitude: 47.9999049
    +0015 02 d0                    longitude: 7.8689549
    +0017 02 36                    latitude: 47.9999615
    +0019 01                       one tag
    +001a 07 68 69 67 68 77 61 79  key: 'highway'
    +0022 07 66 6f 6f 74 77 61 79  value: 'footway'
    +002a 01                       member of one collection
    +002b 00 00 00 00 00 00 00 40  id of the collection is 64
    +0033 00                       role is ''
    +0034 01                       position in the collection is 1
    +0035 00 00 00 00 00 00 02 48  id is 584
    +003e 00 00 00 00 65 ab 7f 2a  timestamp: 1705738026 (2024-01-20 08:07:06)

    +0045 02                       way has 2 coordinates
    +0046 00 00                    longitude: 7.8689549
    +0048 00 00                    latitude: 47.9999615
    +004a fe 38                    longitude: 7.8689093
    +004c 01 7c                    latitude: 47.9999995
    +004e 01                       one tag
    +004f 07 68 69 67 68 77 61 79  key: 'highway'
    +0057 07 66 6f 6f 74 77 61 79  value: 'footway'
    +005f 01                       member of one collection
    +0060 00 00 00 00 00 00 00 40  id of the collection is 64
    +0068 00                       role is ''
    +0069 02                       position in the collection is 2
    +006a 00 00 00 00 00 00 02 4a  id is 586
    +0072 00 00 00 00 68 61 21 f9  timestamp is 1751196153 (2025-06-29, 11:22:33)

    +007a 02                       way has 2 coordinates
    +007b 01 c8                    longitude: 7.8689549
    +007d fe 84                    latitude: 47.9999615
    +007f 03 34                    longitude: 7.8690369
    +0081 fe ea                    latitude: 47.9999337
    +0083 01                       one tag
    +0084 07 68 69 67 68 77 61 79  key: 'highway'
    +008c 07 66 6f 6f 74 77 61 79  value: 'footway'
    +0094 00                       not member of any collection
    +0095 00 00 00 00 00 00 02 58  id is 600
    +009d 00 00 00 00 68 61 21 f9  timestamp is 1751196153 (2025-06-29, 11:22:33)

    +00a5 05                       way has 5 coordinates
    +00a6 f8 05                    longitude: 7.8688326
    +00a8 02 00                    latitude: 47.9999849
    +00aa ff 18                    longitude: 7.8688094
    +00ac ff 24                    latitude: 47.9999629
    +00ae fd d8                    longitude: 7.8687542
    +00b0 fe cb                    latitude: 47.9999320
    +00b2 00 ae                    longitude: 7.8687716
    +00b4 fd f8                    latitude: 47.9998800
    +00b6 02 2d                    longitude: 7.8688273
    +00b8 fe 2c                    latitude: 47.9998332
    +00ba 01                       one tag
    +00bb 07 68 69 67 68 77 61 79  key: 'highway'
    +00c3 07 66 6f 6f 74 77 61 79  value: 'footway'
    +00cb 01                       member of one collection
    +00cc 00 00 00 00 00 00 00 40  id of the collection is 64
    +00d4 00                       role is ''
    +00d5 00                       position in the collection is 0
    +00d6 00 00 00 00 00 00 02 b8  id is 696
    +00de 00 00 00 00 68 61 21 f9  timestamp is 1751196153 (2025-06-29, 11:22:33)

### Chunk 4

    0341  00 00 00 89              position of block table (0x3ca)

    03ca  01                       one entry
    03cb  00 00 00 04              start of block 1 at 0x0004
    03cf  07 6c 61 6e 64 75 73 65  key of block 1 is 'landuse'

### Block 1

    0345  00 00 00 79              position of slice table (0x3be)

    03be  01                       one entry
    03bf  00 00 00 04              start of slice 1 at 0x0004
    03c3  06 6d 65 61 64 6f 77     key of slice 1 is 'meadow'

### Slice 1

    0349  00 00 00 01              one element
    034d  00 00 00 6d              length of compressed data is `0x006d`

Uncompressed:

    +0000  06                       outer of area has 6 coordinates
    +0001  80 00 04 b0 b2 d6        longitude: 7.8687968
    +0007  80 00 1c 9c 38 f1        latitude: 48.0000206
    +000d  07 e1                    longitude: 7.8687337
    +000f  fc 12                    latitude: 47.9999872
    +0011  f6 9a                    longitude: 7.8687201
    +0013  fa d7                    latitude: 47.9998817
    +0015  fa 90                    longitude: 7.8688593
    +0017  03 87                    latitude: 47.9997914
    +0019  00 88                    longitude: 7.8690999
    +001b  04 1f                    latitude: 47.9999235
    +001d  02 77                    longitude: 7.8688982
    +001f  01 4e                    latitude: 48.0000241
    +0021  01                       there is one hole
    +0022  05                       hole has 5 coordinates
    +0023  05 e9                    longitude: 7.8689481
    +0025  fb b3                    latitude: 47.9999105
    +0027  ff 09                    longitude: 7.8689234
    +0029  ff 85                    latitude: 47.9998982
    +002b  00 64                    longitude: 7.8689334
    +002d  fe f9                    latitude: 47.9998719
    +002f  01 21                    longitude: 7.8689623
    +0031  00 26                    latitude: 47.9998757
    +0033  00 dc                    longitude: 7.8689843
    +0035  01 05                    latitude: 47.9999018
    +0037  02                       two tags
    +0038  07 6c 61 6e 64 75 73 65  key: 'landuse'
    +0040  06 6d 65 61 64 6f 77     value: 'meadow'
    +0047  04 74 79 70 65           key: 'type'
    +004c  0c 6d 75 6c 74 69 70 6f  value: 'multipolygon'
           6c 79 67 6f 6e
    +0059  00                       not member of any collection
    +005a  00 00 00 00 00 00 00 3b  id is 59
    +0062  00 00 00 00 68 61 21 f9  timestamp is 1751196153 (2025-06-29, 11:22:33)

### Chunk 5

    03d7  00 00 00 3e              position of block table (0x415)

    0415  01                       one entry
    0416  00 00 00 04              start of block 1 at 0x0004
    041a  05 72 6f 75 74 65        key of block 1 is 'route'

### Block 1

    03db  00 00 00 34              position of slice table (0x40f)

    040f  01                       one entry
    0410  00 00 00 04              start of slice 1 at 0x0004
    0414  00                       slice without value

### Slice 1

    03df  00 00 00 01              one element
    03e3  00 00 00 28              length of compressed data is `0x0028`

Uncompressed:

    +0000 00                       no slice definition provided
    +0001 02                       two tags
    +0002 05 72 6f 75 74 65        key: 'route'
    +0008 07 65 78 61 6d 70 6c 65  value: 'example'
    +0010 04 74 79 70 65           key: 'type'
    +0015 05 72 6f 75 74 65        value: 'route'
    +001b 00                       not member of any collection
    +001c 00 00 00 00 00 00 00 40  id is 64
    +0024 00 00 00 00 68 61 21 f9  timestamp is 1751196153 (2025-06-29, 11:22:33)

Slice definition is currently not created by the OMA converter. If it
were created, the start of the uncompressed part would have looked
like this:

    +0000  02                       two definitions

    +0001  4e                       node
    +0002  03 93 87 00 1c 03 a1 80  bounding box 6.0, 47.0, 8.0, 48.0
           04 c4 b4 00 1c 9c 38 00
    +0012  07 74 6f 75 72 69 73 6d  key: 'tourism'
    +001a  0b 69 6e 66 6f 72 6d 61  value: 'information'
           74 69 6f 6e

    +0027  57                       way
    +0028  03 93 87 00 1c 03 a1 80  bounding box 6.0, 47.0, 8.0, 48.0
           04 c4 b4 00 1c 9c 38 00
    +0038  07 68 69 67 68 77 61 79  key: 'highway'
    +0040  07 66 6f 6f 74 77 61 79  value: 'footway'
