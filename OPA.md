# Description of the OPA File Format

***Note: [Oma](https://github.com/kumakyoo42/Oma) software (including
additional programs like [Opa](https://github.com/kumakyoo42/Opa) and
[libraries](https://github.com/kumakyoo42/OmaLibJava)) and related
file formats are currently experimental and subject to change without
notice.***

## General Structure

Files in OPA format are text files. Blank lines are ignored. Anything
after a hash (#), including the hash, is also ignored. Lines can be
indented for better readability. The first line should start with
`#OPA` for better recognition of OPA files.

Most lines consists of a name followed by a colon
(without whitespace in between), which may be followed by some other
information, depending on the name.

All coordinates in Opa files are in WGS84, with a precision of 7
fractional digits. Longitude is given before latitude.

## Grammar

### File

    <opa> ::=
      <header>
      <chunk>*

    <header> ::=
      "Version:" <number>
      "Features:" <features list>
      "BoundingBox:" <bounding box>
      <typetable>
      "Chunks:" <number>

The first item is the version of the Oma file format. As long, as this
format is in experimental stage, this is always 0.

The `<features list>` is a comma separated list of zero or more of the
following words: `zipped`, `id`, `version`, `timestamp`, `changeset`,
`user`, `once`. Each of these words indicates that the corresponding
bit of the feature byte is set.

The `<bounding box>` gives the bounding box of the whole file and is
given as four comma seperated numbers (lower left corner, upper right
corner).

Next, the typetable follows, see below.

The last item in the head is the number of chunks given in the file.

### Typetable

    <typetable> ::=
      "Types:" <number>
      <typeentry>*

    <typeentry> ::=
      "Type:" <type>
      "Keys:" <number>
      <key with values>*

    <key with values> ::=
      "Key:" <key>
      "Values:" <number>
        <value>*

The typetable consists of the number of types, followed by an entry
for each type. Each entry consists of the type, the number of keys and
a list of keys with values. Each entry in this list consists of a key
the number of values and the values.

### Chunks

    <chunk> ::=
      <chunkheader>
      <block>*

    <chunkheader> ::=
      "Chunk:"
      "Type:" <type>
      "Start:" <number>
      "BoundingBox:" <bounding box>
      "Blocks:" <number>

Each chunk consists of a short header. The header contains type,
starting position (in the OMA file) and bounding box as well as the
number of blocks in the chunk, followed by the blocks.

### Blocks

    <block> ::=
      <blockheader>
      <slice>*

    <blockheader> ::=
      "Block:" <key>
      "Slices:" <number>

Each block consists of a short header. The header contains the key of
the block and the number of slices in the block, followed by the
slices. If the block has no key a minus sign must be used as key.

### Slices

    <slice> ::=
      <sliceheader>
      <element>*

    <sliceheader> ::=
      "Slice:" <value>
      "Elements:" <number>

Each slice consists of a short header. The header contains the value
of the slice and the number of elements in the slice, followed by the
elements. If the surrounding block has no key or the slice has no
value, the value of the slice must be a minus sign.

### Elements

    <element> ::=
      "Element:"
      <geometry>
      <tags>
      <members>
      <meta information>

    <geometry> (Node) ::=
      "Position:" <coordinate>

    <geometry> (Way) ::=
      "Positions:"
        <coordinate>*

    <geometry> (Area) ::=
      "Positions:"
        <coordinate>*
      "Holes:" <number>
        <hole>*

    <geometry> (Collection) ::=
      "ID:" <number>
      "Slices:" <number>
        <slice definition>*

    <hole> ::=
      "Hole:"
        <coordinate>*

    <slice definition> ::=
      "Type:" <type>
      "BoundingBox:" <bounding box>
      "Key: " <string>
      "Value: " <string>

    <tags> ::=
      "Tags:"
        <tag value pair>*

    <tag value pair> ::=
      <key> " = " <value>

    <members> ::=
      "Members:" <number>
        <member>*

    <member> ::=
      <number> <number> <string>

    <meta information> ::=
      "ID:" <number>
      "Version:" <number>
      "Timestamp:" <number>
      "Changeset:" <number>
      "User:" <number> "(" <name> ")"

Which geometry is used depends on the type of the surrounding chunk.
Ways and areas contain lists of coordinates. In this case each
coordinate is written on a single line.

Tags are listed, one after another, each on a separate line. Key and
value must be separated by a space followed by an equals sign,
followed by a space.

In keys and values of tags, as well as in roles in a collection, the
following characters are escaped by a backslash:

| character | escape sequence |
| --------- | --------------- |
| #         | \\x             |
| *newline* | \\n             |
| =         | \\=             |
| \         | \\\             |

Members are saved as id, followed by the position and the role. The
role is escaped like keys and tags. It may contain spaces.

Metadata is only included if listed in the `<features list>`, with the
exception of IDs of collections, where the ID is always present (and
repeated before the bounding box).

## Example

*Note: This example is outdated: The `version byte` and the
`typetable` are missing and it does not contain an example for a
collection, nor are there members.*

See [example.opa](/example.opa).
