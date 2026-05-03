package main

import "core:math"
import rl "vendor:raylib"

HALF_SCREEN_WIDTH  :: SCREEN_WIDTH / 2
HALF_SCREEN_HEIGHT :: SCREEN_HEIGHT / 2
DistToProjPlane := HALF_SCREEN_WIDTH / math.tan(f32(HALF_FOV))

Render :: proc(player: Player, rays: Rays, tiles: Tiles, image: ^rl.Image) {
    for i in 0..<SCREEN_WIDTH {
        ray := rays[i]
        wallHeight := TILE_SIZE / ray.dist * DistToProjPlane
        wallHalfHeight := wallHeight * 0.5

        wallTopPx := HALF_SCREEN_HEIGHT - wallHalfHeight
        if wallTopPx < 0 do wallTopPx = 0

        wallBottomPx :=  HALF_SCREEN_HEIGHT + wallHalfHeight
        if wallBottomPx > SCREEN_HEIGHT do wallBottomPx = SCREEN_HEIGHT

        for j in 0..=wallTopPx do rl.ImageDrawPixel(image, i32(i), i32(j), rl.DARKGRAY)

        tileOffset: Vec2f
        tileOffset.x = ray.hit.y if ray.isHitVertical else ray.hit.x

        for j in wallTopPx..<wallBottomPx {
            distFromTop := j + wallHalfHeight - HALF_SCREEN_HEIGHT
            tileOffset.y = distFromTop * TILE_SIZE / wallHeight
            
            texel := tiles[ray.tile-1][i32(tileOffset.y) * TILE_SIZE + i32(tileOffset.x) % TILE_SIZE]
            rl.ImageDrawPixel(image, i32(i), i32(j), texel)
        }

        for j in wallBottomPx..<SCREEN_HEIGHT do rl.ImageDrawPixel(image, i32(i), i32(j), rl.GRAY)
    }
}

RenderMap :: proc(maze: Maze, player: Player, rays: Rays, colors: MapColors, image: ^rl.Image, size: f32 = 0.0625) {
    for y in 0..<MAZE_HEIGHT {
        for x in 0..<MAZE_WIDTH {
            tile := maze[x + y * MAZE_WIDTH]
            color := colors[NUM_TILES] if tile == 0 else colors[tile-1]

            px := i32(f32(x * TILE_SIZE) * size)
            py := i32(f32(y * TILE_SIZE) * size)
            size := i32(f32(TILE_SIZE) * size)
            for dy in 0..<size {
                for dx in 0..<size {
                    current := rl.GetImageColor(image^, px + dx, py + dy)
                    color := rl.ColorAlphaBlend(current, color, rl.WHITE)
                    rl.ImageDrawPixel(image, px + dx, py + dy, color)
                }
            }
        }
    }

    psx := i32(f32(player.x) * size)
    psy := i32(f32(player.y) * size)
    pex := i32(f32(player.x + math.cos(player.angle) * TILE_SIZE) * size)
    pey := i32(f32(player.y + math.sin(player.angle) * TILE_SIZE) * size)
    rl.ImageDrawLine(image, psx, psy, pex, pey, rl.WHITE)
}