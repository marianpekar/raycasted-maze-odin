package main

import "core:math"
import rl "vendor:raylib"

Player :: struct { 
    x, y, 
    angle: f32,
    showMap: bool,
    restart: bool,
    mazeType: MazeType,
    mapSize: f32
}

HandleInputs :: proc(player: ^Player, maze: ^Maze, deltaTime: f32) {
    walk := f32(0)
    turn := f32(0)

    if rl.IsKeyDown(rl.KeyboardKey.W) do walk =  1
    if rl.IsKeyDown(rl.KeyboardKey.S) do walk = -1
    if rl.IsKeyDown(rl.KeyboardKey.A) do turn = -1
    if rl.IsKeyDown(rl.KeyboardKey.D) do turn =  1

    player.angle += turn * deltaTime

    step := walk * 200 * deltaTime
    next: Vec2f = {
        player.x + math.cos(player.angle) * step,
        player.y + math.sin(player.angle) * step
    }
    
    if !HasWallAt(maze, next) {
        player.x = next.x
        player.y = next.y
    }

    if rl.IsKeyPressed(rl.KeyboardKey.M) do player.showMap = !player.showMap
    if rl.IsKeyPressed(rl.KeyboardKey.R) do player.restart = true

    if rl.IsKeyPressed(rl.KeyboardKey.T) {
        player.mazeType = .Recursive if player.mazeType == .Stack else .Stack
        player.restart = true
    }

    if rl.IsKeyPressed(rl.KeyboardKey.KP_ADD) do player.mapSize /= 2
    if rl.IsKeyPressed(rl.KeyboardKey.KP_SUBTRACT) do player.mapSize *= 2
    if player.mapSize < 8 do player.mapSize = 8
    if player.mapSize > 32 do player.mapSize = 32

    if rl.IsKeyPressed(rl.KeyboardKey.P) do PaintWalls(maze)
}

