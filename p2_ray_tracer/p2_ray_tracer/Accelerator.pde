public abstract class Accelerator extends SceneObject {
  
  protected ArrayList<SceneObject> _objects;
  
  public Accelerator(ArrayList<SceneObject> objects) {
    //Put objects into nodes, bounding boxes, etc.
    _objects = objects;
    build();
  }
  
  public abstract void build();
  
  //public String toString() {
  //  String result = String.format("Accelerator with %d objects: \n", _objects.size());
  //  for (SceneObject obj : _objects) {
  //    result += String.format("%s \n", obj);
  //  }
    
  //  return result;
  //}
}
