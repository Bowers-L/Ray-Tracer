// This is the starter code for the CS 6491 Ray Tracing project.
//
// The most important part of this code is the interpreter, which will
// help you parse the scene description (.cli) files.

boolean debug_flag = false;

final Point3 eye = new Point3(0, 0, 0);

float _fov = 0;
color _background = color(0, 0, 0);
ArrayList<RenderObject> _objects = new ArrayList<RenderObject>();
float _k = 0;

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
    interpreter("s1.cli");
    break;
  case '2':
    interpreter("s2.cli");
    break;
  case '3':
    interpreter("s3.cli");
    break;
  case '4':
    interpreter("s4.cli");
    break;
  }
}

// this routine helps parse the text in a scene description file
void interpreter(String file) {

  println("Parsing '" + file + "'");
  String str[] = loadStrings (file);
  if (str == null) println ("Error! Failed to read the file.");

  ArrayList<Point3> vertices = new ArrayList<Point3>();
  color currSurface = color(0, 0, 0);
  for (int i = 0; i < str.length; i++) {

    String[] token = splitTokens (str[i], " ");   // get a line and separate the tokens
    if (token.length == 0) continue;              // skip blank lines

    if (token[0].equals("fov")) {
      _fov = float(token[1]);
      _k = tan(Util.RAD2DEG * _fov / 2);
      println("fov: ", _fov);
      println("k: ", _k);
    } else if (token[0].equals("background")) {
      float r = float(token[1]);  // this is how to get a float value from a line in the scene description file
      float g = float(token[2]);
      float b = float(token[3]);
      _background = color(r, g, b);
      println ("background = " + r + " " + g + " " + b);
    } else if (token[0].equals("light")) {
    } else if (token[0].equals("surface")) {
      float r = float(token[1]);
      float g = float(token[2]);
      float b = float(token[3]);
      currSurface = color(r, g, b);
      println ("surface = " + r + " " + g + " " + b);
    } else if (token[0].equals("begin")) {
      vertices = new ArrayList<Point3>();
    } else if (token[0].equals("vertex")) {
      float x = float(token[1]);
      float y = float(token[2]);
      float z = float(token[3]);

      vertices.add(new Point3(x, y, z));
    } else if (token[0].equals("end")) {
      Triangle t = new Triangle(vertices.get(0), vertices.get(1), vertices.get(2));
      RenderObject ro = new RenderObject(t, currSurface);
      println(ro);
      _objects.add(ro);
    } else if (token[0].equals("render")) {
      draw_scene();   // this is where you actually perform the scene rendering
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
  _objects.clear();
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
      if (x == 150 && y == 140)
        debug_flag = true;

      // create and cast an eye ray
      Point3 pixel3D = pixelTo3DPoint(x, y);
      Ray eyeRay = new Ray(eye, new Vector3(eye, pixel3D));

      if (debug_flag) {
        println("pixel3D: ", pixel3D.toString());
        println("eyeRay: ", eyeRay.toString());
      }

      RenderObject closestObject = null;
      float closestDist = Float.POSITIVE_INFINITY;
      int debug_count = 0;
      for (RenderObject currObj : _objects) {
        debug_count++;
        Point3 intersection = eyeRay.intersect(currObj.triangle);

        if (intersection != null) {

          if (debug_flag) {
            println("intersection: with object ", debug_count, intersection);
          }

          float dist = eye.sqDistanceTo(intersection);
          if (dist < closestDist) {
            closestDist = dist;
            closestObject = currObj;
          }
        }
      }

      // set the pixel color
      if (closestObject != null) {
        color c = closestObject.surface;   // you should put the correct pixel color here
        set (x, y, c);  // make a tiny rectangle to fill the pixel
      }
    }
  }
}

Point3 pixelTo3DPoint(float x, float y) {
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
