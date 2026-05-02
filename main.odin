package main

import rl "vendor:raylib"

SCREEN_WIDTH :: 1024
SCREEN_HEIGHT :: 768

Player :: [5]f32 // x, y, width, height, angle

main :: proc() {
    rl.InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Renderer")

    renderImage := rl.GenImageColor(SCREEN_WIDTH, SCREEN_HEIGHT, rl.BLACK)
    defer rl.UnloadImage(renderImage)

    renderTexture := rl.LoadTextureFromImage(renderImage)
    defer rl.UnloadTexture(renderTexture)

    maze := GenerateMazeRecursive({5,5})

    player: Player
    player[0] = 5 * TILE_SIZE + TILE_SIZE / 2
    player[1] = 5 * TILE_SIZE + TILE_SIZE / 2

    rays: Rays

    for !rl.WindowShouldClose() {
        rl.BeginDrawing()

        CastRays(player, &maze, &rays)
        Render(player, rays, &renderImage)

        rl.UpdateTexture(renderTexture, renderImage.data)
        rl.DrawTexture(renderTexture, 0, 0, rl.WHITE)
	    rl.DrawFPS(10, 10)
        
        rl.EndDrawing()
    }
}

