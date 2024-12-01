# Description of the OMA File Format

***Note: [Oma](https://github.com/kumakyoo42/Oma) software (including
additional programs like [Opa](https://github.com/kumakyoo42/Opa) and
libraries) and [related file
formats](https://github.com/kumakyoo42/oma-file-formats) are currently
experimental and subject to change without notice.***

## General Structure

Files in OPA format are text files. Empty lines are ignored.
Everything after a hashtag (#), including the hashtag, is ignored as
well. Lines may be indented for better readablity. The first line
should start with `#OPA` for better recognition of OPA files.

With the exception of tag pairs every line consists of a name followed
by a colon (without whitespace in between), which may be followed by
some other information, depending on the name.

All coordinates in opa files are in WGS84, with a precision of 7
fractional digits. Longitude is given before latitude.

## Grammar

### File

    <opa> ::=
      <header>
      <chunk>*

    <header> ::=
      "Features:" <features list>
      "BoundingBox:" <bounding box>
      "Chunks:" <number>

The `<features list>` is a comma separated list of zero or more of the
following words: `zipped`, `id`, `version`, `timestamp`, `changeset`,
`user`. Each of these words denotes that the corresponding bit of the
feature byte is set.

The `<bounding box>` gives the bounding box of the whole file and is
given as four comma seperated numbers (lower left corner, upper right
corner).

The last item in the head is the number of chunks given in the file.

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

    <hole> ::=
      "Hole:"
        <coordinate>*

    <tags> ::=
      "Tags:"
        <tag value pair>*

    <tag value pair> ::=
      <key> " = " <value>

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
followed by a space. In keys and values the following characters are
escaped by a backslash:

| character | escape sequence |
| --------- | --------------- |
| #         | \\x             |
| *newline* | \\n             |
| =         | \\=             |
| \         | \\\             |

Metadata is only included if listed in the `<features list>`.

## Example

See [example.opa](/example.opa).
