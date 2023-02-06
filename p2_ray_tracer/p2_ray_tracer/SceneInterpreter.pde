
public class SceneInterpreter {
  private String sceneFilesDir;  //Relative path from Processing data folder.
  private String[] sceneFileNames;
  
  //Interpreter buffers (these need to be outside in case we recurse into multiple scene files)
  ArrayList<Point3> _currVertexBuffer = new ArrayList<Point3>();
  Material _currMaterial = null;
  
  public SceneInterpreter(String sceneFilesDir, String[] sceneFileNames) {
    this.sceneFilesDir = sceneFilesDir;
    this.sceneFileNames = sceneFileNames;
  }
  
  public void interpretSceneAtIndex(int index) {
    if (index < sceneFileNames.length) {
        interpretScene(sceneFilesDir + sceneFileNames[index]);
    }
  }
  
    // this routine helps parse the text in a scene description file
  public void interpretScene(String file) {
      
      println("Parsing '" + file + "'");
      String str[] = loadStrings(file);
      if (str == null) {
        println("Error! Failed to read the file.");
        return;
      }
      
      for (int i = 0; i < str.length; i++) {
          
          String[] token = splitTokens(str[i], " ");   // get a line and separate the tokens
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
              _currMaterial = new Material(r, g, b);
              //println ("surface = " + r + " " + g + " " + b);
          } else if (token[0].equals("begin")) {
              _currVertexBuffer = new ArrayList<Point3>();
          } else if (token[0].equals("vertex")) {
              float x = float(token[1]);
              float y = float(token[2]);
              float z = float(token[3]);
              
              Point3 vertex = new Point3(x, y, z);
              _currVertexBuffer.add(_matrixStack.top().multiply(vertex));
          } else if (token[0].equals("end")) {
              Triangle t = new Triangle(_currVertexBuffer.get(0), _currVertexBuffer.get(1), _currVertexBuffer.get(2), _currMaterial);
              //println(ro);
              _mainScene.addObject(t);
          } else if (token[0].equals("render")) {
              draw_scene();   // this is where you actually perform the scene rendering
          } else if (token[0].equals("read")) {
              interpretScene(sceneFilesDir + token[1]);
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
              println("unknown command: " + token[0]);
          }
      }
  }
}
