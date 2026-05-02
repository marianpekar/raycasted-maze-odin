package main

import "core:math"
import rl "vendor:raylib"

HALF_SCREEN_WIDTH  :: SCREEN_WIDTH / 2
HALF_SCREEN_HEIGHT :: SCREEN_HEIGHT / 2
DistToProjPlane := HALF_SCREEN_WIDTH / math.tan(f32(HALF_FOV))

Render :: proc(player: Player, rays: Rays, image: ^rl.Image) {
    for i in 0..<SCREEN_WIDTH {
        ray := rays[i]
        wallHeight := TILE_SIZE / ray.dist * DistToProjPlane
        wallHalfHeight := wallHeight * 0.5

        wallTopPx := HALF_SCREEN_HEIGHT - wallHalfHeight
        if wallTopPx < 0 do wallTopPx = 0

        wallBottomPx :=  HALF_SCREEN_HEIGHT + wallHalfHeight
        if wallBottomPx > SCREEN_HEIGHT do wallBottomPx = SCREEN_HEIGHT

        for j in 0..=wallTopPx do rl.ImageDrawPixel(image, i32(i), i32(j), rl.GRAY)

        surfaceOffset: Vec2f
        surfaceOffset.x = ray.hit.y if ray.isHitVertical else ray.hit.x

        for j in wallTopPx..<wallBottomPx {
            distFromTop := j + wallHalfHeight - HALF_SCREEN_HEIGHT
            surfaceOffset.y = distFromTop * TILE_SIZE / wallHeight
            
            // TODO: instead of rl.WHITE, sample texture of rays[i].tile
            rl.ImageDrawPixel(image, i32(i), i32(j), rl.WHITE)
        }

        for j in wallBottomPx..<SCREEN_HEIGHT do rl.ImageDrawPixel(image, i32(i), i32(j), rl.GRAY)
    }
}