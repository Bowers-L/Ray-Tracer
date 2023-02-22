/*
* Author: Logan Bowers
 * IMPORTANT NOTES:
 * - I split up the timer into Build Time and Render Time because I wanted to see if there was a difference.
 * -   Build Time is the time it takes from the start of parsing a scene file to the first render call.
 * -   Render Time is the time it takes from the first render call to when rendering is finished.
 * -   What I found was that build time can sometimes exceed render time for scenes with a large number of objects (such as Bun69k).
 * -   This is ESPECIALLY true for scenes with small, high poly objects (s09.cli, s10.cli, s11.cli), since it still has to build the tree, but a large number of rays will miss the objects entirely.
 
 * - Most of the starter/rendering code has been migrated to the Scene and SceneInterpreter classes.
 * - The actual raytracing and shading is done in the Scene class.
 * - Some files contain multiple smaller classes. This is mainly to save tab space in the Processing IDE by grouping related functionality together.
 * - Most notably:
 -   Ray.pde contains SurfaceContact and RaycastHit
 -   Float3.pde contains Point3 and Vector3
 -   BVH.pde contains the entire Bounding Volume Heirarchy implementation, including helper structures.
 - I tried to architect the code in a way that made sense and leave comments for parts requiring further explanation.
 Since this is a 1.6k line project at this point, some parts might be more documented than others.
 */

import java.util.Arrays;
import java.util.HashMap;

//Where are the scene files located?
final String p1b_dir = "P1B/";
final String p2_dir = "P2/";
final String p3_dir = "P3/";
final String[] p1b_scenes = {"s1.cli", "s2.cli", "s3.cli", "s4.cli", "s5.cli", "s6.cli"};
final String[] p2_scenes = {"s01.cli", "s02.cli", "s03.cli", "s04.cli", "s05.cli", "s06.cli", "s07.cli", "s08.cli", "s09.cli", "s10.cli", "s11.cli"};
final String[] p3_scenes = {"s01a.cli", "s02a.cli", "s03a.cli", "s04a.cli", "s05a.cli", "s06a.cli", "s07a.cli", "s08a.cli", "s09a.cli",
  "s01b.cli", "s02b.cli", "s03b.cli", "s04b.cli", "s05b.cli", "s06b.cli", "s07b.cli", "s08b.cli", "s09b.cli"};

boolean debug_flag = false;

SceneInterpreter _interpreter;

void setup() {
  size(300, 300);
  noStroke();
  background(color(0, 0, 0, 0));
  colorMode(RGB, 1.0);

  _interpreter = new SceneInterpreter(p3_dir, p3_scenes);
}

void keyPressed() {
  int index = -1;

  if (key >= '1' && key <= '9') {
    index = key - '1';
  } else if (key == 'a') {
    index = 9;
  } else {
    switch (key) {
    case '!':
      index = 9;
      break;
    case '@':
      index = 10;
      break;
    case '#':
      index = 11;
      break;
    case '$':
      index = 12;
      break;
    case '%':
      index = 13;
      break;
    case '^':
      index = 14;
      break;
    case '&':
      index = 15;
      break;
    case '*':
      index = 16;
      break;
    case '(':
      index = 17;
      break;
    default:
      break;
    }
  }

  _interpreter.interpretSceneAtIndex(index);
}

// prints mouse location clicks, for help debugging
void mousePressed() {
  println("You pressed the mouse at " + mouseX + " " + mouseY);
}

// you don't need to add anything here
void draw() {
}
