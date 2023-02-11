// This is the starter code for the CS 6491 Ray Tracing project.
//
// The most important part of this code is the interpreter, which will
// help you parse the scene description (.cli) files.

/*
* Author: Logan Bowers
* Important Notes:
* - Most of the starter/rendering code has been migrated to the Scene and SceneInterpreter classes.
* - The actual raytracing and shading is done in the Scene class.
* - Some files contain multiple smaller classes. This is mainly to save tab space in the Processing IDE by grouping related functionality together.
* - Most notably:
  -   Ray.pde contains SurfaceContact and RaycastHit
  -   Float3.pde contains Point3 and Vector3
  -   AABBox.pde contains Bounds 
*/

import java.util.Arrays;
import java.util.HashMap;

//Where are the scene files located?
final String p1b_dir = "P1B/";
final String p2_dir = "";
final String[] p1b_scenes = {"s1.cli", "s2.cli", "s3.cli", "s4.cli", "s5.cli", "s6.cli"};
final String[] p2_scenes = {"s01.cli", "s02.cli", "s03.cli", "s04.cli", "s05.cli", "s06.cli", "s07.cli", "s08.cli", "s09.cli", "s10.cli", "s11.cli"};

boolean debug_flag = false;

SceneInterpreter _interpreter;

void setup() {
    size(300, 300);
    noStroke();
    background(color(0, 0, 0, 0));
    colorMode(RGB, 1.0);
    
    _interpreter = new SceneInterpreter(p2_dir, p2_scenes);
}

void keyPressed() {
    switch(key) {
        case '1':
            _interpreter.interpretSceneAtIndex(0);
            break;
        case '2':
            _interpreter.interpretSceneAtIndex(1);
            break;
        case '3':
            _interpreter.interpretSceneAtIndex(2);
            break;
        case '4':
            _interpreter.interpretSceneAtIndex(3);
            break;
        case '5':
            _interpreter.interpretSceneAtIndex(4);
            break;
        case '6':
            _interpreter.interpretSceneAtIndex(5);
            break;
        case '7':
            _interpreter.interpretSceneAtIndex(6);
            break;
        case '8':
            _interpreter.interpretSceneAtIndex(7);
            break;
        case '9':
            _interpreter.interpretSceneAtIndex(8);
            break;
        case '0':
            _interpreter.interpretSceneAtIndex(9);
            break;
        case 'a':
            _interpreter.interpretSceneAtIndex(10);
            break;
    }
}

// prints mouse location clicks, for help debugging
void mousePressed() {
    println("You pressed the mouse at " + mouseX + " " + mouseY);
}

// you don't need to add anything here
void draw() {
}
