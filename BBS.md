# Description of the BBS File Format

***Note: [Oma](https://github.com/kumakyoo42/Oma) software (including
additional programs like [Opa](https://github.com/kumakyoo42/Opa) and
[libraries](https://github.com/kumakyoo42/OmaLibJava)) and related
file formats are currently experimental and subject to change without
notice.***

## Structure

BBS files define a list of bounding boxes used for sorting the
elements into chunks. Each line of a BBS file must consist of four or
six integers. All coordinates are in WGS84 format, multiplied by
10.000.000.

    minlon maxlon minlat maxlat
    minlon maxlon steplon minlat maxlat steplat

The first version defines a bounding box.

The second version defines a grid of bounding boxes of size `steplon`
x `steplat`. The lower latitude of the boxes loops from `minlon`
(including) to `maxlon` (excluding) and the lower longitute of the
boxes loops from `minlat` (including) to `maxlat` (excluding).

[Oma](https://github.com/kumakyoo42/Oma) uses the order of the entries
in this file for deciding which bounding box is used for a certain
element. Thus it makes sense to put larger bounding boxes later in the
file.

There is no need to include a whole world bounding box, as this is
always added automatically as a fall back.

Please note that the defined bounding boxes may overlap; indeed
neighbouring bounding boxes of a grid always overlap at a line,
because all bounding boxes include the points on their edges.

## Example "default.bbs"

The file
[default.bbs](https://github.com/kumakyoo42/Oma/blob/main/default.bbs)
of the OMA software looks like this:

    -1800000000 1800000000 10000000 -450000000 450000000 10000000
    -1800000000 1800000000 20000000 450000000 600000000 10000000
    -1800000000 1800000000 20000000 -600000000 -450000000 10000000
    -1800000000 1800000000 30000000 600000000 750000000 10000000
    -1800000000 1800000000 30000000 -750000000 -600000000 10000000
    -1800000000 1800000000 100000000 750000000 850000000 20000000
    -1800000000 1800000000 100000000 -850000000 -750000000 20000000
    -1800000000 1800000000 850000000 900000000
    -1800000000 1800000000 -900000000 -850000000
    -1800000000 1800000000 100000000 -900000000 900000000 100000000

The first line defines 32400 bounding boxes, each of size 1° x 1°.
They range from 45° south to 45° north and span the whole world in
west-east-direction.

The next line defines 2700 bounding boxes, each of size 2° x 1°. They
range from 45° north to 60° north, again spanning the whole world. The
next line is the same on the southern hemispere.

The next lines continue this pattern, with box sizes increasing when
getting closer to the poles.

The last line might be surprising, as it defines a new mesh above the
already used mesh. It defines 648 bounding boxes of size 10° x 10°,
spanning almost the whole globe (but not the areas near the poles).
This mash is used to capture elements, which do not fit into a single
one of the smaller bounding boxes.
