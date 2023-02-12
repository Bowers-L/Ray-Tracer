public abstract class Accelerator extends SceneObject {
  
  protected ArrayList<SceneObject> _objects;
  
  public Accelerator(ArrayList<SceneObject> objects) {
    //Put objects into nodes, bounding boxes, etc.
    _objects = objects;
    build();
  }
  
  public abstract void build();
}
