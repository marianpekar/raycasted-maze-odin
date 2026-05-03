package main

import "core:strings"
import "core:os"
import rl "vendor:raylib"

NUM_TILES :: 8
TILE_SIZE :: 64

Tile :: [^]rl.Color
Tiles :: [NUM_TILES]Tile

LoadTiles :: proc(dir: string) -> Tiles {
    tiles: Tiles

    fis, err := os.read_all_directory_by_path(dir, context.temp_allocator)

    for info, i in fis {
        path := strings.clone_to_cstring(info.fullpath)
        image := rl.LoadImage(path)
        tiles[i] = rl.LoadImageColors(image)
        rl.UnloadImage(image)
    }

    return tiles
}
