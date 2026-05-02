package main

import "core:math"
import rl "vendor:raylib"

HALF_SCREEN_WIDTH  :: SCREEN_WIDTH / 2
HALF_SCREEN_HEIGHT :: SCREEN_HEIGHT / 2
DistToProjPlane := (HALF_SCREEN_WIDTH) / math.tan(f32(HALF_FOV))

Render :: proc(player: Player, rays: Rays, image: ^rl.Image) {
    for i in 0..<SCREEN_WIDTH {
        perpDist := rays[i].dist * math.cos(rays[i].angle - player[4])
        projWallHeight := TILE_SIZE / perpDist * DistToProjPlane
        projWallHalfHeight := projWallHeight * 0.5

        wallTopPx := HALF_SCREEN_HEIGHT - projWallHalfHeight
        if wallTopPx < 0 do wallTopPx = 0

        wallBottomPx :=  HALF_SCREEN_HEIGHT + projWallHalfHeight
        if wallBottomPx > SCREEN_HEIGHT do wallBottomPx = SCREEN_HEIGHT

        for j in 0..=wallTopPx do rl.ImageDrawPixel(image, i32(i), i32(j), rl.GRAY)

        surfaceOffset: Vec2f
        surfaceOffset.x = rays[i].hit.y if rays[i].isHitVertical else rays[i].hit.x

        for j in wallTopPx..<wallBottomPx {
            distFromTop := j + projWallHalfHeight - HALF_SCREEN_HEIGHT
            surfaceOffset.y = distFromTop * TILE_SIZE / projWallHeight
            
            // TODO: instead of rl.WHITE, sample texture of rays[i].tile
            rl.ImageDrawPixel(image, i32(i), i32(j), rl.WHITE)
        }

        for j in wallBottomPx..<SCREEN_HEIGHT do rl.ImageDrawPixel(image, i32(i), i32(j), rl.GRAY)
    }
}