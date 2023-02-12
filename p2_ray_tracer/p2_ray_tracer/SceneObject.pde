//Reference: pbrt 4.1
//This is the equivalent of the "Primitive" class.
public abstract class SceneObject {
  public abstract RaycastHit raycast(Ray ray);
  public abstract AABBox getBoundingBox();
}
