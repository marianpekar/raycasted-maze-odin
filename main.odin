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

    maze := GenerateMaze({5,5}, .Recursive)

    player: Player
    player.x = 5 * TILE_SIZE + TILE_SIZE / 2
    player.y = 5 * TILE_SIZE + TILE_SIZE / 2

    rays: Rays

    for !rl.WindowShouldClose() {
        HandleInputs(&player, &maze, rl.GetFrameTime())
        CastRays(player, &maze, &rays)

        rl.BeginDrawing()

        Render(player, rays, &renderImage)

        rl.UpdateTexture(renderTexture, renderImage.data)
        rl.DrawTexture(renderTexture, 0, 0, rl.WHITE)
	    rl.DrawFPS(10, 10)
        
        rl.EndDrawing()
    }
}

