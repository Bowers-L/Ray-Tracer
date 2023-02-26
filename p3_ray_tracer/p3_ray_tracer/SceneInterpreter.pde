import java.util.Stack;

/* How the Scene Interpreter works
 * When constructing, pass in the root scene file directory relative to the "data" folder (default is ""), and the scene files associated with it.
 * Call interpretSceneAtIndex to interpret one of the files given.
 * Can also call interpretScene(String) to interpret directly from a file
 */
public class SceneInterpreter {
  private String sceneFilesDir;  //Relative path from Processing data folder.
  private String[] sceneFileNames;

  private Scene _mainScene;  //A reference to the scene that's drawn by the interpreter.

  //Data structures used to construct the scene.
  private HashMap<String, SceneObject> _namedObjects = new HashMap<String, SceneObject>();
  private MatStack _matrixStack = new MatStack();
  private ArrayList<Point3> _currVertexBuffer = new ArrayList<Point3>();
  private Stack<ArrayList<SceneObject>> _accelBufferStack = new Stack<ArrayList<SceneObject>>();
  private Material _currMaterial = null;

  private int buildTimer;

  public SceneInterpreter(String sceneFilesDir, String[] sceneFileNames) {
    this.sceneFilesDir = sceneFilesDir;
    this.sceneFileNames = sceneFileNames;

    reset();
  }

  public void interpretSceneAtIndex(int index) {
    if (index >= 0 && index < sceneFileNames.length) {
      interpretScene(sceneFilesDir + sceneFileNames[index]);
    }
  }

  public void interpretScene(String sceneFile) {
    reset();
    reset_timer();
    interpretSceneRecursive(sceneFile);
  }

  private void reset() {
    _mainScene = new Scene();
    _matrixStack = new MatStack();
    _namedObjects = new HashMap<String, SceneObject>();
    _currVertexBuffer = new ArrayList<Point3>();
    _accelBufferStack = new Stack<ArrayList<SceneObject>>();
    _currMaterial = null;
  }

  // this routine helps parse the text in a scene description file
  private void interpretSceneRecursive(String file) {
    println("Parsing '" + file + "'");
    String str[] = loadStrings(file);
    if (str == null) {
      println("Error! Failed to read the file.");
      return;
    }

    for (int i = 0; i < str.length; i++) {

      String[] token = splitTokens(str[i], " ");   // get a line and separate the tokens
      if (token.length == 0) continue;              // skip blank lines

      //SCENE SETUP (fov, background)
      if (token[0].equals("fov")) {
        _mainScene.setFOV(float(token[1]));
      } else if (token[0].equals("background")) {
        float r = float(token[1]);  // this is how to get a float value from a line in the scene description file
        float g = float(token[2]);
        float b = float(token[3]);
        _mainScene.setBackground(new Color(r, g, b));
      }

      //LIGHT
      else if (token[0].equals("light")) {
        float x = float(token[1]);
        float y = float(token[2]);
        float z = float(token[3]);
        float r = float(token[4]);
        float g = float(token[5]);
        float b = float(token[6]);

        Point3 pos = new Point3(x, y, z);
        Color col = new Color(r, g, b);
        Light l = new PointLight(pos, col);
        _mainScene.addLight(l);
        //println(_light);
      } else if (token[0].equals("disk_light")) {
        float x = float(token[1]);
        float y = float(token[2]);
        float z = float(token[3]);
        float radius = float(token[4]);
        float dx = float(token[5]);
        float dy = float(token[6]);
        float dz = float(token[7]);
        float r = float(token[8]);
        float g = float(token[9]);
        float b = float(token[10]);
        
        Point3 pos = new Point3(x, y, z);
        Vector3 dir = new Vector3(dx, dy, dz);
        Color col = new Color(r, g, b);
        
        Light l = new DiskLight(pos, radius, dir, col);
        _mainScene.addLight(l);
      }
      
      //MATERIAL
      else if (token[0].equals("surface")) {
        float r = float(token[1]);
        float g = float(token[2]);
        float b = float(token[3]);
        _currMaterial = new Material(r, g, b);
        //println ("surface = " + r + " " + g + " " + b);
      } else if (token[0].equals("glossy")) {
        float dr = float(token[1]);
        float dg = float(token[2]);
        float db = float(token[3]);
        
        float sr = float(token[4]);
        float sg = float(token[5]);
        float sb = float(token[6]);
        
        float spec_pow = float(token[7]);
        float k_refl = float(token[8]);
        float gloss_radius = float(token[9]);
        
        Color diffuse = new Color(dr, dg, db);
        Color specular = new Color(sr, sg, sb);
        
        _currMaterial = new Material(diffuse, specular, spec_pow, k_refl, gloss_radius);
      }

      //TRIANGLE PRIMITIVE
      else if (token[0].equals("begin")) {
        _currVertexBuffer = new ArrayList<Point3>();
      } else if (token[0].equals("vertex")) {
        float x = float(token[1]);
        float y = float(token[2]);
        float z = float(token[3]);

        Point3 vertex = new Point3(x, y, z);
        _currVertexBuffer.add(vertex);
      } else if (token[0].equals("end")) {
        Triangle t = new Triangle(_currVertexBuffer);
        t = (Triangle) t.transform(_matrixStack.top());
        addObject(new GeometricObject(t, _currMaterial));
      }

      //BOX PRIMITIVE
      else if (token[0].equals("box")) {
        float xmin = float(token[1]);
        float ymin = float(token[2]);
        float zmin = float(token[3]);
        float xmax = float(token[4]);
        float ymax = float(token[5]);
        float zmax = float(token[6]);

        Point3 min = new Point3(xmin, ymin, zmin);
        Point3 max = new Point3(xmax, ymax, zmax);

        AABBox box = new AABBox(min, max);
        box = (AABBox) box.transform(_matrixStack.top());

        addObject(new GeometricObject(box, _currMaterial));
      }
      
      //SPHERE PRIMITIVE
      else if (token[0].equals("sphere")) {
        float radius = float(token[1]);
        float cx = float(token[2]);
        float cy = float(token[3]);
        float cz = float(token[4]);
        
        Point3 center = new Point3(cx, cy, cz);

        Sphere sphere = new Sphere(radius, center);
        sphere = (Sphere) sphere.transform(_matrixStack.top());

        addObject(new GeometricObject(sphere, _currMaterial));
      }

      //NAMED OBJECT
      else if (token[0].equals("named_object")) {
        String objectName = token[1];
        SceneObject objectReference = popLastCreatedObj();
        //println("Added object", objectName, " with reference to ", objectReference);
        _namedObjects.put(objectName, objectReference);
      } else if (token[0].equals("instance")) {
        String objectName = token[1];
        ObjectInstance instance = new ObjectInstance(_namedObjects.get(objectName), _matrixStack.top());
        addObject(instance);
      }
      
      //MOVING OBJECT
      else if (token[0].equals("moving_object")) {
        float dx = float(token[1]);
        float dy = float(token[2]);
        float dz = float(token[3]);
        
        SceneObject objReference = popLastCreatedObj();
        Vector3 dPos = new Vector3(dx, dy, dz);
        
        addObject(new MovingObject(objReference, dPos));
      }

      //MATRIX STACK
      else if (token[0].equals("translate")) {
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
      }

      //ACCELERATION
      else if (token[0].equals("begin_accel")) {
        _accelBufferStack.push(new ArrayList<SceneObject>());
      } else if (token[0].equals("end_accel")) {
        ArrayList<SceneObject> accelObjects = _accelBufferStack.pop();
        Accelerator accelObj = new BVH(accelObjects);
        //println("Added " + accelObj);
        addObject(accelObj);
      }
      
      //RAYS PER PIXEL
      else if (token[0].equals("rays_per_pixel")) {
        _mainScene.setRaysPerPixel(int(token[1]));  
      }
      
      //DEPTH OF FIELD
      else if (token[0].equals("lens")) {
        float radius = float(token[1]);
        float dist = float(token[2]);
        
        _mainScene.addLens(radius, dist);
      }

      //SCENE COMMANDS
      else if (token[0].equals("read")) {
        interpretSceneRecursive(sceneFilesDir + token[1]);
      } else if (token[0].equals("render")) {
        print_timer(buildTimer, "Scene Build Time");
        _mainScene.render();
      } else if (token[0].equals("#")) {
        // comment (ignore)
      } else {
        println("unknown command: " + token[0]);
      }
    }
  }

  private void reset_timer() {
    buildTimer = millis();
  }

  private void addObject(SceneObject obj) {
    if (_accelBufferStack.empty()) {
      _mainScene.addObject(obj);
    } else {
      _accelBufferStack.peek().add(obj);
    }
  }
  
  private SceneObject popLastCreatedObj() {
    return _mainScene.sceneObjects().remove(_mainScene.sceneObjects().size()-1);  
  }
}
