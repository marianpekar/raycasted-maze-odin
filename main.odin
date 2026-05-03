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

    start := Vec2i{MAZE_WIDTH / 2 + 1, MAZE_HEIGHT / 2 + 1}
    maze := GenerateMaze(start, .Recursive)

    PrintMaze(&maze, "Recursive")

    player: Player
    player.x = f32(start.x) * TILE_SIZE + TILE_SIZE / 2
    player.y = f32(start.y) * TILE_SIZE + TILE_SIZE / 2

    rays: Rays

    tiles := LoadTiles("tiles")
    mapColors := MakeMapColors(tiles)

    for !rl.WindowShouldClose() {
        HandleInputs(&player, &maze, rl.GetFrameTime())
        CastRays(player, &maze, &rays)

        rl.BeginDrawing()

        Render(player, rays, tiles, &renderImage)
        RenderMap(maze, player, rays, mapColors, &renderImage)

        rl.UpdateTexture(renderTexture, renderImage.data)
        rl.DrawTexture(renderTexture, 0, 0, rl.WHITE)
	    rl.DrawFPS(SCREEN_WIDTH - 100, 10)
        
        rl.EndDrawing()
    }
}

