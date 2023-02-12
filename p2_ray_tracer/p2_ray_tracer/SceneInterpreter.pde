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

  public SceneInterpreter(String sceneFilesDir, String[] sceneFileNames) {
    this.sceneFilesDir = sceneFilesDir;
    this.sceneFileNames = sceneFileNames;
    
    reset();
  }

  public void interpretSceneAtIndex(int index) {    
    if (index < sceneFileNames.length) {
      interpretScene(sceneFilesDir + sceneFileNames[index]);
    }
  }
  
  public void interpretScene(String sceneFile) {
    reset();
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
  
  private void addObject(SceneObject obj) {
    if (_accelBufferStack.empty()) {
      _mainScene.addObject(obj);
    } else {
      _accelBufferStack.peek().add(obj);
    }
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

        //println("fov: ", _fov);
        //println("k: ", _k);
      } else if (token[0].equals("background")) {
        float r = float(token[1]);  // this is how to get a float value from a line in the scene description file
        float g = float(token[2]);
        float b = float(token[3]);
        _mainScene.setBackground(color(r, g, b));
        //println ("background = " + r + " " + g + " " + b);
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
        Material mat = new Material(r, g, b);
        Light l = new Light(pos, mat);
        _mainScene.addLight(l);
        //println(_light);
      } else if (token[0].equals("surface")) {
        float r = float(token[1]);
        float g = float(token[2]);
        float b = float(token[3]);
        _currMaterial = new Material(r, g, b);
        //println ("surface = " + r + " " + g + " " + b);
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
        t.transform(_matrixStack.top());
        //println(ro);
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
        box.transform(_matrixStack.top());
        
        addObject(new GeometricObject(box, _currMaterial));
      }
      
      //NAMED OBJECT
      else if (token[0].equals("named_object")) {
          String objectName = token[1];
          SceneObject objectReference = _mainScene.sceneObjects().remove(_mainScene.sceneObjects().size()-1);
          //println("Added object", objectName, " with reference to ", objectReference);
          _namedObjects.put(objectName, objectReference);
      } else if (token[0].equals("instance")) {
        String objectName = token[1];
        ObjectInstance instance = new ObjectInstance(_namedObjects.get(objectName), _matrixStack.top());
        addObject(instance);
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
        Accelerator accelObj = new BVHAccel(accelObjects);
        //println("Added " + accelObj);
        addObject(accelObj);
      }
      
      //SCENE COMMANDS
      else if (token[0].equals("read")) {
        interpretSceneRecursive(sceneFilesDir + token[1]);
      } else if (token[0].equals("render")) {
        _mainScene.render();
      } else if (token[0].equals("#")) {
        // comment (ignore)
      } else {
        println("unknown command: " + token[0]);
      }
    }
  }
}
