package main

import "core:fmt"
import "core:math/rand"

Vec2i :: [2]i32

MAZE_WIDTH :: 65
MAZE_HEIGHT :: 65

Maze :: [MAZE_WIDTH * MAZE_HEIGHT]i32

GenerateMazeStack :: proc(start: Vec2i) -> Maze {
    Directions :: [4]Vec2i
    AllDirections :: [24]Directions

    maze: Maze = 1
    stack: Stack(Vec2i)
    dirs := MakeAllDirections()

    Open(&maze, start)
    Push(&stack, start)

    for !IsEmpty(&stack) {
        c := Pop(&stack)

        currentDirs := dirs[rand.int31_max(24)]

        for i in 0..<4 {
            d := currentDirs[i]
            n: Vec2i = {c.x + d.x * 2, c.y + d.y * 2}

            if !IsValid(n) do continue

            if !IsOpen(&maze, n) {
                Open(&maze, {(n.x + c.x) / 2, (n.y + c.y) / 2})
                Open(&maze, n)
                Push(&stack, n)
            }
        }
    }

    return maze

    MakeAllDirections :: proc() -> AllDirections {
        all: AllDirections
        base: Directions = {{1,0}, {-1,0}, {0,1}, {0,-1}}
        factorials := [4]int{6, 2, 1, 1}
        for n in 0..<24 {
            rem, d := base, n
            for i in 0..<4 {
                j := d / factorials[i]
                d   %= factorials[i]
                all[n][i] = rem[j]
                for k in j..<(3 - i) { rem[k] = rem[k + 1] }
            }
        }
        return all
    }
}

GenerateMazeRecursive :: proc(start: Vec2i) -> Maze {
    maze: Maze = 1
    Step(&maze, start)
    return maze

    Step :: proc(maze: ^Maze, p: Vec2i) {
        dirs: [4]i32
        for i in 0..<4 {
            dirs[i] = rand.int31_max(4)
        }
    
        for dir in dirs {
            switch dir {
                case 0:
                    if p.y - 2 <= 0 do continue
                    if !IsOpen(maze, {p.x, p.y - 2}) {
                        Open(maze, {p.x, p.y - 2})
                        Open(maze, {p.x, p.y - 1})
                        Step(maze, {p.x, p.y - 2})
                    }
                case 1:
                    if p.x + 2 >= MAZE_WIDTH do continue
                    if !IsOpen(maze, {p.x + 2, p.y}) {
                        Open(maze, {p.x + 2, p.y})
                        Open(maze, {p.x + 1, p.y})
                        Step(maze, {p.x + 2, p.y})
                    }
                case 2:
                    if p.y + 2 >= MAZE_HEIGHT do continue
                    if !IsOpen(maze, {p.x, p.y + 2}) {
                        Open(maze, {p.x, p.y + 2})
                        Open(maze, {p.x, p.y + 1})
                        Step(maze, {p.x, p.y + 2})
                    }                
                case 3:
                    if p.x - 2 <= 0 do continue
                    if !IsOpen(maze, {p.x - 2, p.y}) {
                        Open(maze, {p.x - 2, p.y})
                        Open(maze, {p.x - 1, p.y})
                        Step(maze, {p.x - 2, p.y})
                    }
            }
        }
    }
}

Open :: proc(maze: ^Maze, p: Vec2i) {
    maze[p.x + p.y * MAZE_WIDTH] = 0
}

IsOpen :: proc(maze: ^Maze, p: Vec2i) -> bool {
    return maze[p.x + p.y * MAZE_WIDTH] == 0
}

GetItem :: proc(maze: ^Maze, p: Vec2i) -> i32 {
    return maze[p.x + p.y * MAZE_WIDTH]
}

IsValid :: proc(p: Vec2i) -> bool {
    return p.x > 0 && p.x < MAZE_WIDTH - 1 &&
           p.y > 0 && p.y < MAZE_HEIGHT - 1
}

PrintMaze :: proc(maze: ^Maze, title: string) {
    fmt.printf("\n%v:\n", title)
    for i in 0..<len(maze) {
        if maze[i] == 0 do fmt.print(' ')
        else do fmt.print('#')
        if (i + 1) % MAZE_WIDTH == 0 do fmt.print('\n')
    }
}