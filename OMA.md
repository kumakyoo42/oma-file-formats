# Description of the OMA File Format

***Note: [Oma](https://github.com/kumakyoo42/Oma) software (including
additional programs like [Opa](https://github.com/kumakyoo42/Opa) and
libraries) and [related file
formats](https://github.com/kumakyoo42/oma-file-formats) are currently
experimental and subject to change without notice.***

## General Structure

Oma files contain a binary representation of [OSM
data](https://wiki.openstreetmap.org/wiki/Planet.osm). A file in OMA
format is divided into [chunks](#chunks). Each chunk contains data of
a certain region of the world of a certain type (node, way, area
etc.). Each chunks is divided into [blocks](#blocks) and each block is
divided into [slices](#slices) using pivotal tags. Slices contain the
[elements](#elements). Slices can be stored in compressed version to
reduce file size.

## Basic Data Formats

All numbers in Oma files are stored in big endian order and in most
cases they are signed. `byte` refers to a single byte number, `short`
to a two byte number, `int` to a four byte number and `long` to an
eight byte number.

At several places small unsigned numbers can be expected. These are
saved as `smallints`: Values 0 to 254 are stored as a single (unsigned)
`byte`, values 255 to 65534 are stored as a 255 byte followed by an
(unsigned) `short` and all larger values are saved by three 255 bytes
followed by a (signed) `int`.

Geographical coordinates are stored in WGS84, multiplied by
10<sup>7</sup> and rounded to the nearest integer. Appart from
bounding boxes, coordinates are always stored delta encoded: Instead
of the number itself, the difference from the last coordinate is used
if it is small enough, that is if it is between -32767 and 32767
inclusive. In this case the difference is saved as a `short`. Larger
numbers are saved as the value -32768 (as `short`) followed by the
number (not the difference) as an `int`. Delta encoding starts anew at
every slice with both coordinates initialised to 0.

Bounding boxes are saved as four `ints`: the coordinates of the lower
left followed by the coordinates of the upper right corner of the box,
longitude before latitude. All bounding boxes include the points on
their borders. Bounding boxes, containing the antimeridian, should
have a maxlon value that is smaller than the minlon value. Such
bounding boxes are not yet supported by the Oma software, but
hopefully will be in the future. If there is no bounding box
available, all four entries must be 2<sup>31</sup>-1, which is the
maximum value of an `int`.

Strings are stored in UTF-8 encoding. A `smallint` precedes every
`string`, denoting the number of bytes used in the UTF-8 encoding of the
`string`.

## Grammar

### File

    <oma> ::=
      <header>
      (<chunk>|<chunktable>)+

Each Oma file starts with a header, followed by [chunks](#chunks).
Exactly one of these chunks is a special chunk - called
[chunktable](#chunktable-1) - containing information about the normal
chunks. This is typically the last chunk of the file, but could be
anyone.

    <header> ::=
      <magic number>
      byte version
      <features byte>
      <bounding box>
      <chunktable position>

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

The header consists of a three byte magic number identifying OMA-files
(the ASCII characters O, M and A), a version byte, a features byte, the
bounding box and a pointer to the chunktable.

The version byte is currently always 0 indicating experimental stage.

The features byte is a bitfield, identifying some features of the
file. Currently only the lower six bits are used; the remaining two
bits are reserved for future use and must be 0. For a description of
the bits of the features byte see the following table:

| Bit | Value | Meaning                           |
| --- | ----- |---------------------------------- |
|   0 |     1 | all slices are compressed         |
|   1 |     2 | elements contain id               |
|   2 |     4 | elements contain version          |
|   3 |     8 | elements contain timestamp        |
|   4 |    16 | elements contain changeset        |
|   5 |    32 | elements contain user information |
|   6 |    64 | reserved, must be 0               |
|   7 |   128 | reserved, must be 0               |

All elements of the file must be completely inside the bounding box
unless no bounding box is given.

The chunktable position is the file position where the chunktable
starts.

# Chunktable

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
ways and 'A' for areas). It is possible and highly likely, that
further types will be defined in the future.

All elements of a chunk must be completely contained in the bounding
box. If no bounding box is given, the chunk may contain any element
including elements without geographic location (not yet possible, but
might come in the future).

### Chunks

    <chunk> ::=
      <chunk header>
      (<block>|<blocktable>)+

    <chunk header> ::=
      int position

The structure of a chunk is made up similar to the structure of the
whole file: A short header followed by [blocks](#blocks), one of which
is a special block containing the [blocktable](#blocktable-1). Again
this is usually the last block but not necessarily.

The header of a chunk consists only of one `int`, which is the
position of the blocktable, *relative to the start of the chunk*.

# Blocktable

    <blocktable> ::=
      smallint count
      <blocktable entry>*

    <blocktable entry> ::=
      int position
      string key

The blocktable is made up of a `smallint` which gives the number of
entries of the blocktable, followed by these entries.

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
file and the structure of a chunk: A short header, followed by
[slices](#slices), one of which is a special slice containing the
[slicetable](#slicetable-1). Again this is usually the last slice but
not necessarily.

The header of a block consists only of one `int`, which is the
position of the slicetable, *relative to the start of the block*.

# Slicetable

    <slicetable> ::=
      smallint count
      <slicetable entry>*

    <slicetable entry> ::=
      int position
      string value

The slicetable is made up of a `smallint` which gives the number of
entries of the slicetable, followed by these entries.

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
      <geometry> <tags> <meta>

At the beginning of each slice there is an `int`, denoting the number
of elements of this slice, followed by the [elements](elements)
themselves. If slices are compressed (the lowest bit of the [feature
byte](#file) is set), compression does not include the first four
bytes of the slice. For compression the deflate algorithm of the ZLIB
compression library is used.

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

    <hole> ::=
      smallint count
      <coord>*

    <coord> ::=
      delta lon
      delta lat

The geometry of a node is just its coordinate pair.

The geometry of a way is a list of coordinate pairs preceeded by the
count of these pairs.

An area consists of an outer ring and optional an arbitrary number of
holes. The outer ring is saved as a list of coordinate pairs preceeded
by the count of these pairs. Divergent of OSM convention the starting
point of this ring is not repeated at the end. Holes are saved the
same way.

    <tags> ::=
      smallint count
      <key-value pair>*

    <key-value pair> ::=
      string key
      string value

Tags are saved as a list of key-value-pairs, preceded by the count of
these pairs. Each pair consists of two strings, the key and the value
of the tag. Key and value of block and slice, if any, must be repeated
here.

    <meta> ::=
      long     id
      smallint version
      long     timestamp
      long     changeset
      int      uid
      string   username

Meta information is only stored if the corresponding bits in the
features byte are set. Otherwise they are skipped. It is possible
that there is no meta information at all.

Meta information consists of the id, the version and the timestamp
(seconds since 1970) of the element, the id of the latest changeset
and uid and username of the user who did the most recent change.

## Example

The following hexdump is taken from [example OMA file](/example.oma),
which is a converted version of the artifical OSM file
[example.osm](/example.osm):

    00000000  4f 4d 41 03 04 b0 a9 c4  1c 9c 2f 04 04 b0 bc 34  |OMA......./....4|
    00000010  1c 9c 39 ae 00 00 00 00  00 00 02 a3 00 00 01 0f  |..9.............|
    00000020  00 00 00 a9 00 00 00 03  78 da 6b 60 60 d9 b0 8e  |........x.k``...|
    00000030  a3 81 41 66 8e 79 18 23  7b 5e 62 49 69 51 62 0e  |..Af.y.#{^bIiQb.|
    00000040  4b 49 51 6a 2a 03 18 24  d7 32 f1 fd de c5 c2 95  |KIQj*..$.2......|
    00000050  93 9a 98 16 9f 5c 99 9c  93 ca 99 5a 96 5a 94 0e  |.....\.....Z.Z..|
    00000060  54 90 87 a2 9c 2b 25 35  2f bf 24 b1 24 33 3f 4f  |T....+%5/.$.$3?O|
    00000070  00 2a 1e 9f 9b 9f 57 9a  9b 9a 57 c2 09 d6 5d 52  |.*....W...W...]R|
    00000080  59 90 ca 93 97 9a 9a 92  93 0a e4 97 a5 a6 40 6d  |Y.............@m|
    00000090  e8 62 0d 60 52 c4 6a 77  3f 00 11 f1 32 69 00 00  |.b.`R.jw?...2i..|
    000000a0  00 01 78 da 6b 60 60 d9  b0 f1 65 03 83 cc 1c b3  |..x.k``...e.....|
    000000b0  2d 8c ec 79 89 25 a5 45  89 39 2c 45 f9 c9 d9 0c  |-..y.%.E.9,E....|
    000000c0  60 90 5c 0f 00 d1 b4 0a  85 02 00 00 00 04 04 74  |`.\............t|
    000000d0  72 65 65 00 00 00 7e 00  00 00 00 42 00 00 00 01  |ree...~....B....|
    000000e0  78 da 6b 60 60 d9 b0 61  66 03 83 cc 1c 53 21 26  |x.k``..af....S!&|
    000000f0  f6 92 fc d2 a2 cc e2 5c  ee cc bc b4 fc a2 dc c4  |.......\........|
    00000100  92 cc fc 3c 64 36 67 7a  69 66 4a 6a 41 7e 71 09  |...<d6gzifJjA~q.|
    00000110  03 18 24 37 01 00 c3 c9  15 3d 01 00 00 00 04 0b  |..$7.....=......|
    00000120  69 6e 66 6f 72 6d 61 74  69 6f 6e 02 00 00 00 04  |information.....|
    00000130  07 6e 61 74 75 72 61 6c  00 00 00 bc 07 74 6f 75  |.natural.....tou|
    00000140  72 69 73 6d 00 00 00 68  00 00 00 59 00 00 00 01  |rism...h...Y....|
    00000150  78 da 63 6d 60 60 d9 b0  e5 64 03 83 cc 1c 93 c6  |x.cm``...d......|
    00000160  ff 9c ff 5b 19 52 fe fd  64 54 64 50 63 b8 c3 c8  |...[.R..dTdPc...|
    00000170  ca c0 cc 9e 97 58 52 5a  94 98 c3 5a 9e 58 92 5a  |.....XRZ...Z.X.Z|
    00000180  c4 92 97 98 9b ca eb 93  98 9d aa 10 9e 01 14 28  |...............(|
    00000190  4b 2d 82 4a e4 00 c5 18  c0 80 69 17 00 c1 bc 1a  |K-.J......i.....|
    000001a0  f8 01 00 00 00 04 05 77  61 74 65 72 01 00 00 00  |.......water....|
    000001b0  04 07 6e 61 74 75 72 61  6c 00 00 00 64 00 00 00  |..natural...d...|
    000001c0  53 00 00 00 01 78 da e3  6c 60 60 d9 b0 c1 ad 81  |S....x..l``.....|
    000001d0  41 66 8e 79 e6 7f 89 ff  2a 7f 6f fc 3b cd b0 ee  |Af.y....*.o.;...|
    000001e0  ef 0f 26 dd 7f 3a cc 92  0c 9b ff 0b 33 49 31 5d  |..&..:......3I1]|
    000001f0  60 32 63 36 f9 f7 8a 91  3d 23 33 3d a3 3c b1 92  |`2c6....=#3=.<..|
    00000200  3d 2d 3f bf 04 48 33 80  01 d3 0e 00 f2 30 19 c9  |=-?..H3......0..|
    00000210  01 00 00 00 04 07 66 6f  6f 74 77 61 79 01 00 00  |......footway...|
    00000220  00 04 07 68 69 67 68 77  61 79 00 00 00 6c 00 00  |...highway...l..|
    00000230  00 5c 00 00 00 01 78 da  63 6b 60 60 d9 b0 ee 41  |.\....x.ck``...A|
    00000240  03 83 cc 1c 8b 73 7f 3b  ff 6d fa 5f f1 fb 21 6b  |.....s.;.m._..!k|
    00000250  c1 9f 4a ce 34 56 cd 1f  f2 cc ef 18 59 19 3f ff  |..J.4V......Y.?.|
    00000260  9e f0 9f f3 7f 2b 43 ca  bf 9f 8c 8a 0c 6a 0c 77  |.....+C......j.w|
    00000270  80 62 ec 39 89 79 29 a5  c5 a9 6c b9 a9 89 29 f9  |.b.9.y)...l...).|
    00000280  e5 0c 10 60 0d 00 82 ba  1e 67 01 00 00 00 04 06  |...`.....g......|
    00000290  6d 65 61 64 6f 77 01 00  00 00 04 07 6c 61 6e 64  |meadow......land|
    000002a0  75 73 65 00 00 00 04 00  00 00 00 00 00 00 1c 4e  |use............N|
    000002b0  03 93 87 00 1c 03 a1 80  04 c4 b4 00 1c 9c 38 00  |..............8.|
    000002c0  00 00 00 00 00 00 01 44  41 03 93 87 00 1c 03 a1  |.......DA.......|
    000002d0  80 04 c4 b4 00 1c 9c 38  00 00 00 00 00 00 00 01  |.......8........|
    000002e0  b9 57 03 93 87 00 1c 03  a1 80 04 c4 b4 00 1c 9c  |.W..............|
    000002f0  38 00 00 00 00 00 00 00  02 2a 41 00 00 00 00 17  |8........*A.....|
    00000300  d7 84 00 05 f5 e1 00 1d  cd 65 00                 |.........e.|

You might compare this and the following descriptions with the
[corresponding OPA file](/example.opa), which is a human readable
representation of this binary data.

### Header

The first 28 bytes form the header:

    00000000  4f 4d 41 03 04 b0 a9 c4  1c 9c 2f 04 04 b0 bc 34  |OMA......./....4|
    00000010  1c 9c 39 ae 00 00 00 00  00 00 02 a3              |..9.........|

After the three byte magic number 'OMA' follows the feature byte
(`0x03`) with two bits set: Bit 0 (slices are compressed) and bit 1 (IDs
are preserved).

The next 16 bytes define the bounding box as four `ints`:
`0x04B0A9C4`=78686660, `0x1c9c2f04`=479997700, `0x04b0bc34`=78691380,
`0x1C9C39AE`=480000430, which is the bounding box 7.868666, 47.99977,
7.869138, 48.000043.

The last 8 bytes are a pointer to the position of the chunktable
at position `0x2a3`.

### Chunktable

The chunktable starts at byte `0x2a3`:

    000002a0           00 00 00 04 00  00 00 00 00 00 00 1c 4e     |............N|
    000002b0  03 93 87 00 1c 03 a1 80  04 c4 b4 00 1c 9c 38 00  |..............8.|
    000002c0  00 00 00 00 00 00 01 44  41 03 93 87 00 1c 03 a1  |.......DA.......|
    000002d0  80 04 c4 b4 00 1c 9c 38  00 00 00 00 00 00 00 01  |.......8........|
    000002e0  b9 57 03 93 87 00 1c 03  a1 80 04 c4 b4 00 1c 9c  |.W..............|
    000002f0  38 00 00 00 00 00 00 00  02 2a 41 00 00 00 00 17  |8........*A.....|
    00000300  d7 84 00 05 f5 e1 00 1d  cd 65 00                 |.........e.|

The first four bytes give the number of entries, 4 in this case.
Each entry consists of a file position (8 bytes) a type (1 byte) and a
bounding box (16 bytes). This is the deciphered chunktable:

| chunk | file position | type | bounding box          |
| ----- | ------------- | ---- | --------------------- |
|     1 |         0x01c | N    | 6.0, 47.0, 8.0, 48.0  |
|     2 |         0x144 | A    | 6.0, 47.0, 8.0, 48.0  |
|     3 |         0x1b9 | W    | 6.0, 47.0, 8.0, 48.0  |
|     4 |         0x22a | A    | 0.0, 40.0, 10.0, 50.0 |

### Chunk 1

The first chunk starts at `0x01c`:

    00000010                                       00 00 01 0f  |            ....|

The first four bytes give the position of the blocktable *relative to
the start of the chunk*. Thus you have to add `0x01c` + `0x10f` =
`0x12b` to get the absolute file position of the blocktable.

### Blocktable

    00000120                                    02 00 00 00 04  |           .....|
    00000130  07 6e 61 74 75 72 61 6c  00 00 00 bc 07 74 6f 75  |.natural.....tou|
    00000140  72 69 73 6d                                       |rism|

The blocktable starts with a `smallint` (`0x02`), thus it contains two
entries. Each entry is an `int` (giving the position inside the
chunk), followed by a `string` (`smallint`, followed by
UTF8-characters), giving the key of the block. This is the blocktable
deciphered:

| block | position | key     |
| ----- | -------- | ------- |
|     1 |     0x04 | natural |
|     2 |     0xbc | tourism |

### Block 1

Block 1 starts at `0x1c` + `0x04` = `0x20`:

    00000020  00 00 00 a9                                       |....            |

The first four bytes give the position of the slicetable *relative to
the start of the chunk*. Thus you have to add `0x020` + `0x0a9` =
`0x0c9` to get the absolute file position of the slicetable.

### Slicetable

    000000c0                              02 00 00 00 04 04 74  |         ......t|
    000000d0  72 65 65 00 00 00 7e 00                           |ree...~.|

The slice table starts with a `smallint` (`0x02`), denoting the number
of entries of the table. Each entry is an `int` (giving the position
inside the block), followed by a `string` (`smallint`, followed by
UTF8-characters), giving the value of the slice. This is the
slicetable deciphered:

| slice | position | value |
| ----- | -------- | ----- |
|     1 |     0x04 | tree  |
|     2 |     0x7e |       |

### Slice 1

Slice 1 starts at `0x20` + `0x04` = `0x24`:

    00000020              00 00 00 03  78 da 6b 60 60 d9 b0 8e  |    ....x.k``...|
    00000030  a3 81 41 66 8e 79 18 23  7b 5e 62 49 69 51 62 0e  |..Af.y.#{^bIiQb.|
    ...
    00000080  59 90 ca 93 97 9a 9a 92  93 0a e4 97 a5 a6 40 6d  |Y.............@m|
    00000090  e8 62 0d 60 52 c4 6a 77  3f 00 11 f1 32 69        |.b.`R.jw?...2i|

The first four bytes give the number of elements in this slice, namely
3. The rest of the slice is compressed and thus not human
readable. The decompressed version looks like this:

    00000020                           80 00 04 b0 ae 08 80 00  |................|
    00000030  1c 9c 37 56 01 07 6e 61  74 75 72 61 6c 04 74 72  |..7V..natural.tr|
    00000040  65 65 00 00 00 00 00 00  63 7d 02 0e fb ba 04 0a  |ee......c}......|
    00000050  6c 65 61 66 5f 63 79 63  6c 65 09 65 76 65 72 67  |leaf_cycle.everg|
    00000060  72 65 65 6e 07 6e 61 74  75 72 61 6c 04 74 72 65  |reen.natural.tre|
    00000070  65 0a 64 65 6e 6f 74 61  74 69 6f 6e 10 6e 61 74  |e.denotation.nat|
    00000080  75 72 61 6c 5f 6d 6f 6e  75 6d 65 6e 74 09 6c 65  |ural_monument.le|
    00000090  61 66 5f 74 79 70 65 0c  6e 65 65 64 6c 65 6c 65  |af_type.needlele|
    000000a0  61 76 65 64 00 00 00 00  00 00 63 8a 05 50 02 21  |aved......c..P.!|
    000000b0  01 07 6e 61 74 75 72 61  6c 04 74 72 65 65 00 00  |..natural.tree..|
    000000c0  00 00 00 00 63 8f

As this is part of a node chunk, the elements are all nodes. Each node
starts with its coordinates delta encoded. `0x8000` means, the delta
is too large and thus the complete number is saved in the next four
bytes: `0x04b0ae08` = 78687752, which is longitude 7.8687752. Next
latitude `0x1c9c3756` = 479999830, which is 47.999983 follows.

The next `smallint` (`0x01`) gives the number of tags. These tags
follow as key-value pairs (here natural=tree).

After this, the meta data is saved. In this file the meta data
consists only of the ID (`0x000000000000637d` = 25469).

The coordinates of the next node element are close enough to the
former node to use deltas: `0x020e` (=526) and `0xfbba` (=-1094). Thus
the coordinates of this element are 78687752+526 = 78688278 which is
longitude 7.8688278 and 479999830-1094 = 479998736 which is latitude
47.9998736.

This element contains 4 tags: leaf_cycle=evergreen, natural=tree,
denotation=natural_monument and leaf_type=needleleaved.
