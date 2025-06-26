#OPA: from ../oma-file-formats/example.oma

Version: 1
Features: id, timestamp
BoundingBox: 7.8687201, 47.9997914, 7.8690999, 48.0000241
Compression: DEFLATE
Types: 4
  Type: N
  Keys: 2
    Key: natural
    Values: 3
      tree
      peak
      spring
    Key: tourism
    Values: 1
      information
  Type: W
  Keys: 3
    Key: highway
    Values: 3
      service
      track
      footway
    Key: landuse
    Values: 0
    Key: natural
    Values: 1
      tree_row
  Type: A
  Keys: 3
    Key: highway
    Values: 0
    Key: landuse
    Values: 2
      meadow
      farmland
    Key: natural
    Values: 1
      water
  Type: C
  Keys: 1
    Key: route
    Values: 3
      bus
      hiking
      bicycle
Chunks: 5

Chunk: # 1
  Type: N
  Start: 193
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
        Members: 0
        ID: 25469
        Timestamp: 1751196153 # Sun Jun 29 13:22:33 CEST 2025
      Element: # 1
        Position: 7.8688278, 47.9998736
        Tags: # 4
          leaf_cycle = evergreen
          natural = tree
          denotation = natural_monument
          leaf_type = needleleaved
        Members: 0
        ID: 25482
        Timestamp: 1698580919 # Sun Oct 29 13:01:59 CET 2023
      Element: # 2
        Position: 7.8689638, 47.9999281
        Tags: # 1
          natural = tree
        Members: 0
        ID: 25487
        Timestamp: 1751196153 # Sun Jun 29 13:22:33 CEST 2025
    Slice: -
      Elements: 1
      Element: # 0
        Position: 7.8688745, 47.9999668
        Tags: # 1
          natural = rock
        Members: 0
        ID: 25471
        Timestamp: 1751196153 # Sun Jun 29 13:22:33 CEST 2025
  Block: tourism
    Slices: 1
    Slice: information
      Elements: 1
      Element: # 0
        Position: 7.8688409, 47.999925
        Tags: # 2
          tourism = information
          information = guidepost
        Members: 1
          64 3 guidepost
        ID: 25474
        Timestamp: 1751196153 # Sun Jun 29 13:22:33 CEST 2025

Chunk: # 2
  Type: A
  Start: 533
  BoundingBox: 6.0, 47.0, 8.0, 48.0
  Blocks: 1
  Block: natural
    Slices: 1
    Slice: water
      Elements: 1
      Element: # 0
        Positions: # 5
          7.8689843, 47.9999018
          7.8689623, 47.9998757
          7.8689334, 47.9998719
          7.8689234, 47.9998982
          7.8689481, 47.9999105
        Holes: 0
        Tags: # 3
          natural = water
          name = Lake Whatever
          water = lake
        Members: 0
        ID: 698
        Timestamp: 1751196153 # Sun Jun 29 13:22:33 CEST 2025

Chunk: # 3
  Type: W
  Start: 660
  BoundingBox: 6.0, 47.0, 8.0, 48.0
  Blocks: 1
  Block: highway
    Slices: 1
    Slice: footway
      Elements: 4
      Element: # 0
        Positions: # 4
          7.8688273, 47.9998332
          7.8689066, 47.9998511
          7.8688829, 47.9999049
          7.8689549, 47.9999615
        Tags: # 1
          highway = footway
        Members: 1
          64 1 ""
        ID: 584
        Timestamp: 1705738026 # Sat Jan 20 09:07:06 CET 2024
      Element: # 1
        Positions: # 2
          7.8689549, 47.9999615
          7.8689093, 47.9999995
        Tags: # 1
          highway = footway
        Members: 1
          64 2 ""
        ID: 586
        Timestamp: 1751196153 # Sun Jun 29 13:22:33 CEST 2025
      Element: # 2
        Positions: # 2
          7.8689549, 47.9999615
          7.8690369, 47.9999337
        Tags: # 1
          highway = footway
        Members: 0
        ID: 600
        Timestamp: 1751196153 # Sun Jun 29 13:22:33 CEST 2025
      Element: # 3
        Positions: # 5
          7.8688326, 47.9999849
          7.8688094, 47.9999629
          7.8687542, 47.999932
          7.8687716, 47.99988
          7.8688273, 47.9998332
        Tags: # 1
          highway = footway
        Members: 1
          64 0 ""
        ID: 696
        Timestamp: 1751196153 # Sun Jun 29 13:22:33 CEST 2025

Chunk: # 4
  Type: A
  Start: 833
  BoundingBox: 0.0, 40.0, 10.0, 50.0
  Blocks: 1
  Block: landuse
    Slices: 1
    Slice: meadow
      Elements: 1
      Element: # 0
        Positions: # 6
          7.8688982, 48.0000241
          7.8690999, 47.9999235
          7.8688593, 47.9997914
          7.8687201, 47.9998817
          7.8687337, 47.9999872
          7.8687968, 48.0000206
        Holes: 1
          Hole: # 0
            7.8689481, 47.9999105
            7.8689234, 47.9998982
            7.8689334, 47.9998719
            7.8689623, 47.9998757
            7.8689843, 47.9999018
        Tags: # 2
          landuse = meadow
          type = multipolygon
        Members: 0
        ID: 59
        Timestamp: 1751196153 # Sun Jun 29 13:22:33 CEST 2025

Chunk: # 5
  Type: C
  Start: 983
  BoundingBox: -
  Blocks: 1
  Block: route
    Slices: 1
    Slice: -
      Elements: 1
      Element: # 0
        ID: 64
        Slices: 0
        Tags: # 2
          route = example
          type = route
        Members: 0
        ID: 64
        Timestamp: 1751196153 # Sun Jun 29 13:22:33 CEST 2025

# end of file
