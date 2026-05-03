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