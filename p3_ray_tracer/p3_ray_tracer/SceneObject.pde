//This is the equivalent of the "Primitive" class.
public abstract class SceneObject {
  public abstract RaycastHit raycast(Ray ray);
  public abstract AABBox getBoundingBox();
  
  public void perPixelRay() {}  //Virtual method, but every method is virtual in Java by default.
}
