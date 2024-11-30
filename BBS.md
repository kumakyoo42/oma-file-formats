# Description of the BBS File Format

***Note: [Oma](https://github.com/kumakyoo42/Oma) software (including
additional programs like [Opa](https://github.com/kumakyoo42/Opa) and
libraries) and [related file
formats](https://github.com/kumakyoo42/oma-file-formats) are currently
experimental and subject to change without notice.***

## Structure

BBS files define a list of bounding boxes used for sorting the
elements into chunks. Each line of a BBS file must consist of six real
numbers:

    minlat maxlat steplat minlon maxlon steplon

These numbers define a grid of bounding boxes of size `steplat`
x `steplon`. The lower latitude of the boxes loops from
`minlat` (including) to `maxlat` (excluding) and
the lower longitute of the boxes loops from `minlon`
(including) to `maxlon` (excluding).

[Oma](https://github.com/kumakyoo42/Oma) uses the order of the entries
in this file for deciding which bounding box is used for a certain
element. Thus it makes sense to put larger bounding boxes later in the
file.

There is no need to include a whole world bounding box, as this is
always added automatically as a fall back.

Please note that the defined bounding boxes may overlap; indeed
neighbouring bounding boxes of a grid always overlap at a line,
because all bounding boxes include the points on their borders.

## Example "default.bbs"

The file
[default.bbs](https://github.com/kumakyoo42/Oma/blob/main/default.bbs)
of the OMA software looks like this:

    -45 45 1 -180 180 1
    45 60 1 -180 180 2
    -60 -45 1 -180 180 2
    60 75 1 -180 180 3
    -75 -60 1 -180 180 3
    75 85 2 -180 180 10
    -85 -75 2 -180 180 10
    85 90 5 -180 180 360
    -90 -85 5 -180 180 360
    -90 90 10 -180 180 10

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

## Example "Single Bounding Box"

A single Bounding Box "minlon, minlat, maxlon, maxlat" still has to be
written as grid with 6 numbers:

    minlon maxlon maxlon-minlon minlat maxlat maxlat-minlat
