public class Accelerator extends SceneObject {
  
  ArrayList<SceneObject> _objects;
  public Accelerator(ArrayList<SceneObject> objects) {
    //Put objects into nodes, bounding boxes, etc.
    _objects = objects;
  }
  
  public AABBox getBoundingBox() {
    return null;
  }

  public RaycastHit raycast(Ray ray) {
      return null;
  }
  
  public String toString() {
    String result = "Accelerator with objects: \n";
    for (SceneObject obj : _objects) {
      result += obj + "\n";
    }
    
    return result;
  }
}
