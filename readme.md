# Procedural Map Generator

This project aims to procedurally generate city maps with layouts inspired by medieval street maps of modern cities like Dublin, Tokyo, and Cairo. The generated maps prioritize organic, irregular patterns to reflect the unique charm and complexity of these historical layouts.

## Getting Started
The primary logic is implemented in scripts located in the `/code/` directory, attached to the Control node of the `resizable_board.tscn` scene. These scripts use Godot's `_draw()` function to render maps dynamically.

### Installation
1. Download and install [Godot Engine 4.x](https://godotengine.org/download)
2. Clone this repository to your local machine `git clone https://github.com/jSiderius/MapGen.git`
3. Open project.godot in the Godot engine 
4. Run resizeable_board.tscn to see the engine in action 


## Notes

The project is under active development. Key components include:
- `resizable_board.tscn`: The main scene to run the generator.
- `/code/`: Contains scripts implementing various algorithms for map generation.
- Other repository contents focus on future enhancements, such as a sprite overlay for the map.
- The scripts are modularized by algorithm for easier tracking and development.

## Built With

* [Godot](https://docs.godotengine.org/en/stable/) - A versatile, open-source game engine to simplify 2D rendering and scripting

## Authors

* **Joshua Siderius** - *Primary Author* - [jSiderius](https://github.com/PurpleBooth)
* **Dr. David Mould** - *Project Advisor* 

## Acknowledgments

* [Using Cellular Automata as a Basis for Procedural Generation of Organic Cities](https://ej-eng.org/index.php/ejeng/article/view/2293): This paper was inspiration for several algorithms used in the project. Particularly for organic, random district generation.