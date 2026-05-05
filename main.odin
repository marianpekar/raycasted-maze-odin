package main

import rl "vendor:raylib"

SCREEN_WIDTH :: 1024
SCREEN_HEIGHT :: 768

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Renderer")

    renderImage := rl.GenImageColor(SCREEN_WIDTH, SCREEN_HEIGHT, rl.BLACK)
    defer rl.UnloadImage(renderImage)

    renderTexture := rl.LoadTextureFromImage(renderImage)
    defer rl.UnloadTexture(renderTexture)

    player: Player
    player.mazeType = .Recursive

    cursor: Cursor
    cursor.tile = 1

    map_: Map
    map_.size = 16
    map_.isTransparent = true
    map_.show = true
    
    maze: Maze

    Restart(&maze, &player)

    rays: Rays

    tiles := LoadTiles("tiles")
    mapColors := MakeMapColors(tiles)

    rl.HideCursor()

    for !rl.WindowShouldClose() {
        HandleInputs(&player, &maze, &cursor, &map_, rl.GetFrameTime())

        if player.restart do Restart(&maze, &player)

        CastRays(player, &maze, &rays)

        rl.BeginDrawing()

        Render(player, rays, tiles, &renderImage)
        if map_.show {
            RenderMap(maze, player, rays, mapColors, map_, cursor, &renderImage)
        }

        rl.UpdateTexture(renderTexture, renderImage.data)
        rl.DrawTexture(renderTexture, 0, 0, rl.WHITE)
	    rl.DrawFPS(SCREEN_WIDTH - 100, 10)
        
        rl.EndDrawing()
    }
}

Restart :: proc(maze: ^Maze, player: ^Player) {
    start := Vec2i{MAZE_WIDTH / 2 + 1, MAZE_HEIGHT / 2 + 1}
    maze^ = GenerateMaze(start, player.mazeType)

    player.x = f32(start.x) * TILE_SIZE + TILE_SIZE / 2
    player.y = f32(start.y) * TILE_SIZE + TILE_SIZE / 2
    player.angle = 0
    player.restart = false
}

