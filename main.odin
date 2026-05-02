package main

main :: proc() {
    maze := GenerateMazeStack({5,5})
    PrintMaze(&maze, "Stack")
    mazeV2 := GenerateMazeRecursive({5,5})
    PrintMaze(&mazeV2, "Recursive")
}

