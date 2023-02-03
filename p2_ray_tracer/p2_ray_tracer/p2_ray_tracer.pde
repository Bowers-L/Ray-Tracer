// This is the starter code for the CS 6491 Ray Tracing project.
//
// The most important part of this code is the interpreter, which will
// help you parse the scene description (.cli) files.

import java.util.Arrays;

boolean debug_flag = false;

final Point3 eye = new Point3(0, 0, 0);

//Scene Data
float _fov = 0;
float _k = 0;
color _background = color(0, 0, 0);
Scene _mainScene = new Scene();

//Interpreter buffers (these need to be outside in case we recurse into multiple scene files)
ArrayList<Point3> currVertexBuffer = new ArrayList<Point3>();
Material currMaterial = null;
MatStack _matrixStack = new MatStack();


void setup() {
  size (300, 300);
  noStroke();
  background (_background);
  colorMode(RGB, 1.0);
}

void keyPressed() {
  reset_scene();
  switch(key) {
  case '1':
    interpreter("s01.cli");
    break;
  case '2':
    interpreter("s02.cli");
    break;
  case '3':
    interpreter("s03.cli");
    break;
  case '4':
    interpreter("s04.cli");
    break;
  case '5':
    interpreter("s05.cli");
    break;
  case '6':
    interpreter("s06.cli");
    break;
  case '7':
    interpreter("s07.cli");
    break;
  case '8':
    interpreter("s08.cli");
    break;
  case '9':
    interpreter("s09.cli");
    break;
  case '0':
    interpreter("s10.cli");
    break;
  case 'a':
    interpreter("s11.cli");
    break;
  }
}

// this routine helps parse the text in a scene description file
void interpreter(String file) {

  println("Parsing '" + file + "'");
  String str[] = loadStrings (file);
  if (str == null) println ("Error! Failed to read the file.");

  for (int i = 0; i < str.length; i++) {

    String[] token = splitTokens (str[i], " ");   // get a line and separate the tokens
    if (token.length == 0) continue;              // skip blank lines

    if (token[0].equals("fov")) {
      _fov = float(token[1]);
      _k = tan(DEG2RAD * _fov / 2);
      //println("fov: ", _fov);
      //println("k: ", _k);
    } else if (token[0].equals("background")) {
      float r = float(token[1]);  // this is how to get a float value from a line in the scene description file
      float g = float(token[2]);
      float b = float(token[3]);
      _background = color(r, g, b);
      //println ("background = " + r + " " + g + " " + b);
    } else if (token[0].equals("light")) {
      float x = float(token[1]);
      float y = float(token[2]);
      float z = float(token[3]);
      float r = float(token[4]);
      float g = float(token[5]);
      float b = float(token[6]);

      Point3 pos = new Point3(x, y, z);
      Material mat = new Material(r, g, b);
      Light l = new Light(pos, mat);
      _mainScene.addLight(l);
      //println(_light);
    } else if (token[0].equals("surface")) {
      float r = float(token[1]);
      float g = float(token[2]);
      float b = float(token[3]);
      currMaterial = new Material(r, g, b);
      //println ("surface = " + r + " " + g + " " + b);
    } else if (token[0].equals("begin")) {
      currVertexBuffer = new ArrayList<Point3>();
    } else if (token[0].equals("vertex")) {
      float x = float(token[1]);
      float y = float(token[2]);
      float z = float(token[3]);

      Point3 vertex = new Point3(x, y, z);
      currVertexBuffer.add(_matrixStack.top().multiply(vertex));
    } else if (token[0].equals("end")) {
      Triangle t = new Triangle(currVertexBuffer.get(0), currVertexBuffer.get(1), currVertexBuffer.get(2), currMaterial);
      //println(ro);
      _mainScene.addObject(t);
    } else if (token[0].equals("render")) {
      draw_scene();   // this is where you actually perform the scene rendering
    } else if (token[0].equals("read")) {
        interpreter (token[1]);
    } else if (token[0].equals("translate")) {
      float x = float(token[1]);
      float y = float(token[2]);
      float z = float(token[3]);
      _matrixStack.translate(x, y, z);
    } else if (token[0].equals("scale")) {
      float sx = float(token[1]);
      float sy = float(token[2]);
      float sz = float(token[3]);
      _matrixStack.scale(sx, sy, sz);
    } else if (token[0].equals("rotate")) {
      float angle = float(token[1]);
      float rx = float(token[2]);
      float ry = float(token[3]);
      float rz = float(token[4]);
      _matrixStack.rotate(angle, rx, ry, rz);
    } else if (token[0].equals("push")) {
      _matrixStack.push();  
    } else if (token[0].equals("pop")) {
      _matrixStack.pop();
    } else if (token[0].equals("#")) {
      // comment (ignore)
    } else {
      println ("unknown command: " + token[0]);
    }
  }
}

void reset_scene() {
  // reset your scene variables here
  _background = color(0, 0, 0);
  _mainScene = new Scene();
  _matrixStack = new MatStack();
}

// This is where you should put your code for creating eye rays and tracing them.
void draw_scene() {
  background(_background);

  for (int y = 0; y < height; y++) {
    for (int x = 0; x < width; x++) {

      // Maybe set debug flag true for ONE pixel.
      // Have your routines (like ray/triangle intersection)
      // print information when this flag is set.
      debug_flag = false;
      //if (x == 150 && y == 140)
      //  debug_flag = true;

      // create and cast an eye ray
      Point3 pixel3D = pixelTo3DPoint(x, y);
      Ray eyeRay = new Ray(eye, new Vector3(eye, pixel3D));

      if (debug_flag) {
        println("pixel3D: ", pixel3D.toString());
        println("eyeRay: ", eyeRay.toString());
      }
      
      RaycastHit hit = _mainScene.raycast(eyeRay);

      // set the pixel color
      if (hit != null) {
        color c = shade(eyeRay, hit);
        set (x, y, c);  // make a tiny rectangle to fill the pixel
      }
    }
  }
}

private color shade(Ray viewRay, RaycastHit hit) {
  Vector3 n = hit.obj.getNormal();
  if (viewRay.direction.dot(n) > 0) {
    n = n.scale(-1);  //Make sure the normal points towards the camera (view dir and normal are opposites)  
  }
  
  float lightR = 0;
  float lightG = 0;
  float lightB = 0;
  for(Light l : _mainScene.lights()) {
      Ray shadow_ray = new Ray(hit.contactPoint, new Vector3(hit.contactPoint, l.position).normalized());
      RaycastHit shadowHit = _mainScene.raycast(shadow_ray, new HashSet<RenderObject>(Arrays.asList(hit.obj)));
      
      boolean objectBlocksLight = false;
      if (shadowHit != null) {
        float distToLight = shadow_ray.origin.distanceTo(l.position);
        
        objectBlocksLight = shadowHit.distanceToHit > 0 && shadowHit.distanceToHit < distToLight;
      }
      
      if (!objectBlocksLight) {
        float diffuseStrength = max(0, n.dot(shadow_ray.direction));
        
        lightR += l.material.r * diffuseStrength;
        lightG += l.material.g * diffuseStrength;
        lightB += l.material.b * diffuseStrength;
      }
  }
  
  float outR = hit.obj.surfaceMat.r * lightR;
  float outG = hit.obj.surfaceMat.g * lightG;
  float outB = hit.obj.surfaceMat.b * lightB;
  
  return color(outR, outG, outB);
}

private Point3 pixelTo3DPoint(float x, float y) {
  float xp = (x - width/2) * _k * 2 / width;
  float yp = (y - height/2) * _k * 2 / height;
  yp = -yp;  //Flip so that +y points up.
  return new Point3(xp, yp, -1);
}

// prints mouse location clicks, for help debugging
void mousePressed() {
  println ("You pressed the mouse at " + mouseX + " " + mouseY);
}

// you don't need to add anything here
void draw() {
}
