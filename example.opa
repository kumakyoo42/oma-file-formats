#OPA: from ../oma-file-formats/example.oma

Features: zipped, id
BoundingBox: 7.868666, 47.99977, 7.869138, 48.000043
Chunks: 4

Chunk: # 1
  Type: N
  Start: 28
  BoundingBox: 6.0, 47.0, 8.0, 48.0
  Blocks: 2
  Block: natural
    Slices: 2
    Slice: tree
      Elements: 3
      Element: # 0
        Position: 7.8687752, 47.999983
        Tags: # 1
          natural = tree
        ID: 25469
      Element: # 1
        Position: 7.8688278, 47.9998736
        Tags: # 4
          leaf_cycle = evergreen
          natural = tree
          denotation = natural_monument
          leaf_type = needleleaved
        ID: 25482
      Element: # 2
        Position: 7.8689638, 47.9999281
        Tags: # 1
          natural = tree
        ID: 25487
    Slice: -
      Elements: 1
      Element: # 0
        Position: 7.8688745, 47.9999668
        Tags: # 1
          natural = rock
        ID: 25471
  Block: tourism
    Slices: 1
    Slice: information
      Elements: 1
      Element: # 0
        Position: 7.8688409, 47.999925
        Tags: # 2
          tourism = information
          information = guidepost
        ID: 25474

Chunk: # 2
  Type: A
  Start: 324
  BoundingBox: 6.0, 47.0, 8.0, 48.0
  Blocks: 1
  Block: natural
    Slices: 1
    Slice: water
      Elements: 1
      Element: # 0
        Positions: # 5
          7.8689481, 47.9999105
          7.8689234, 47.9998982
          7.8689334, 47.9998719
          7.8689623, 47.9998757
          7.8689843, 47.9999018
        Holes: 0
        Tags: # 3
          natural = water
          name = Lake Whatever
          water = lake
        ID: 698

Chunk: # 3
  Type: W
  Start: 441
  BoundingBox: 6.0, 47.0, 8.0, 48.0
  Blocks: 1
  Block: highway
    Slices: 1
    Slice: footway
      Elements: 1
      Element: # 0
        Positions: # 9
          7.8688326, 47.9999849
          7.8688094, 47.9999629
          7.8687542, 47.999932
          7.8687716, 47.99988
          7.8688273, 47.9998332
          7.8689066, 47.9998511
          7.8688829, 47.9999049
          7.8689549, 47.9999615
          7.8690369, 47.9999337
        Tags: # 1
          highway = footway
        ID: 696

Chunk: # 4
  Type: A
  Start: 554
  BoundingBox: 0.0, 40.0, 10.0, 50.0
  Blocks: 1
  Block: landuse
    Slices: 1
    Slice: meadow
      Elements: 1
      Element: # 0
        Positions: # 6
          7.8687968, 48.0000206
          7.8687337, 47.9999872
          7.8687201, 47.9998817
          7.8688593, 47.9997914
          7.8690999, 47.9999235
          7.8688982, 48.0000241
        Holes: 1
          Hole: # 0
            7.8689481, 47.9999105
            7.8689234, 47.9998982
            7.8689334, 47.9998719
            7.8689623, 47.9998757
            7.8689843, 47.9999018
        Tags: # 1
          landuse = meadow
        ID: 59

# end of file
