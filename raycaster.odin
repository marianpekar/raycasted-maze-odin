package main

import "core:math"

FOV :: 60 * math.PI / 180
HALF_FOV :: FOV / 2

Vec2f :: [2]f32
BitField :: i32

Ray :: struct {
    angle: f32,
    dist: f32,
    hit: Vec2f,
    rayInfo: BitField
}

Rays :: [SCREEN_WIDTH]Ray

TILE_SIZE :: 64

IsHitVertical      :: proc(rayInfo: BitField) -> bool { return rayInfo & 1 == 1 }
IsRayPointingDown  :: proc(rayInfo: BitField) -> bool { return rayInfo & 2 == 2 }
IsRayPointingRight :: proc(rayInfo: BitField) -> bool { return rayInfo & 4 == 4 }

SetHitVertical      :: proc(rayInfo: ^BitField, value: bool) { if value do rayInfo^ |= 1; else do rayInfo^ &~= 1 }
SetRayPointingDown  :: proc(rayInfo: ^BitField, value: bool) { if value do rayInfo^ |= 2; else do rayInfo^ &~= 2 }
SetRayPointingRight :: proc(rayInfo: ^BitField, value: bool) { if value do rayInfo^ |= 4; else do rayInfo^ &~= 4 }

GetHitTile :: proc(rayInfo: i32) -> i32 { return rayInfo >> 5 }
SetHitTile :: proc(rayInfo: ^i32, content: i32) { rayInfo^ = (rayInfo^ & 0x1F) | (content << 5) }

CastRays :: proc(player: Player, maze: ^Maze, rays: ^Rays) {
    rayAngle := player[4] - HALF_FOV

    for i in 0..<SCREEN_WIDTH {
        CastRay(player, maze, NormalizeAngle(rayAngle), rays, i)
        rayAngle += FOV / SCREEN_WIDTH
    }

    NormalizeAngle :: proc(angle: f32) -> f32 {
        a := math.remainder(angle, math.TAU)
        if a < 0 {
            a += math.TAU
        }
        return a
    }

    CastRay :: proc(player: Player, maze: ^Maze, rayAngle: f32, rays: ^Rays, rayIdx: int) {
        isRayPoitingDown := rayAngle > 0 && rayAngle < math.PI
        isRayPointingRight := rayAngle < 0.5 * math.PI || rayAngle > 1.5 * math.PI

        hasHorizontalHit := false
        hHit: Vec2f
        hTile: i32
        intercept: Vec2f
        
        intercept.y = math.floor(player[1] / TILE_SIZE) * TILE_SIZE + (TILE_SIZE if isRayPoitingDown else 0)
        intercept.x = player[0] + (intercept.y - player[1]) / math.tan(rayAngle)

        step: Vec2f = {TILE_SIZE / math.tan(rayAngle), TILE_SIZE}
        if !isRayPoitingDown do step.y *= -1
        if !isRayPointingRight && step.x > 0 do step.x *= -1
        if  isRayPointingRight && step.x < 0 do step.x *= -1

        hNext: Vec2f = {intercept.x, intercept.y}
        for IsInBounds(hNext) {
            check: Vec2f = {hNext.x, hNext.y + (-1 if !isRayPoitingDown else 0)}
            if (HasWallAt(maze, check)) {
                hHit = {hNext.x, hNext.y}
                hTile = GetTile(maze, check)
                hasHorizontalHit = true
                break
            }
            hNext += step
        }

        hasVerticalHit := false
        vHit: Vec2f
        vTile: i32

        intercept.x = math.floor(player[0] / TILE_SIZE) * TILE_SIZE + (TILE_SIZE if isRayPointingRight else 0)
        intercept.y = player[1] + (intercept.x - player[0]) * math.tan(rayAngle)

        step.x = TILE_SIZE * (-1 if !isRayPointingRight else 1)
        step.y = TILE_SIZE * math.tan(rayAngle)
        if !isRayPoitingDown && step.y > 0 do step.y *= -1
        if isRayPoitingDown && step.y < 0 do step.y *= -1

        vNext: Vec2f = {intercept.x, intercept.y}
        for IsInBounds(vNext) {
            check: Vec2f = {vNext.x + (-1 if !isRayPointingRight else 0), vNext.y}
            if (HasWallAt(maze, check)) {
                vHit = {vNext.x, vNext.y}
                vTile = GetTile(maze, check)
                hasVerticalHit = true
                break
            }
            vNext += step
        }

        hHitDist := GetDistance({player[0], player[1]}, hHit) if hasHorizontalHit else 999_999
        vHitDist := GetDistance({player[0], player[1]}, vHit) if hasVerticalHit else 999_999

        if vHitDist < hHitDist {
            rays[rayIdx].dist = vHitDist
            rays[rayIdx].hit = vHit
            SetHitVertical(&rays[rayIdx].rayInfo, true)
            SetHitTile(&rays[rayIdx].rayInfo, vTile)
        } else {
            rays[rayIdx].dist = hHitDist
            rays[rayIdx].hit = hHit
            SetHitVertical(&rays[rayIdx].rayInfo, false)
            SetHitTile(&rays[rayIdx].rayInfo, hTile)
        }

        rays[rayIdx].angle = rayAngle
        SetRayPointingDown(&rays[rayIdx].rayInfo, isRayPoitingDown)
        SetRayPointingRight(&rays[rayIdx].rayInfo, isRayPointingRight)

        return
        
        IsInBounds :: proc(t: Vec2f) -> bool {
            return t.x >= 0 && t.x <= MAZE_WIDTH * TILE_SIZE &&
                   t.y >= 0 && t.y <= MAZE_HEIGHT * TILE_SIZE
        }
        
        HasWallAt :: proc(maze: ^Maze, p: Vec2f) -> bool {
            if p.x < 0 || p.x > MAZE_WIDTH * TILE_SIZE || p.y < 0 || p.y > MAZE_HEIGHT * TILE_SIZE {
                return true
            }

            tile: Vec2i = { i32(p.x / TILE_SIZE), i32(p.y / TILE_SIZE)}
            return !IsOpen(maze, tile)
        }

        GetTile :: proc(maze: ^Maze, p: Vec2f) -> i32 {
            tile: Vec2i = { i32(p.x / TILE_SIZE), i32(p.y / TILE_SIZE)}
            return GetItem(maze, tile)
        }

        GetDistance :: proc(a, b: Vec2f) -> f32 {
            return math.sqrt((b.x - a.x) * (b.x - a.x) + (b.y - a.y) * (b.y - a.y))
        }
    }
}