public class ObjectInstance extends SceneObject {

  private SceneObject objReference;
  private Mat4f transformMat;
  private Mat4f transformMatInv;

  public ObjectInstance(SceneObject objReference, Mat4f transformMat) {
    this.objReference = objReference;
    this.transformMat = transformMat;
    this.transformMatInv = transformMat.invert();
  }

  @Override
    public AABBox getBoundingBox() {
    return null;
  }

  @Override
    public RaycastHit raycast(Ray ray, HashSet<SceneObject> ignored) {
    if (ignored.contains(this)) {
      return null;
    }
    
    //Transform ray from world to object space.
    Point3 newO = transformMatInv.multiply(ray.origin);
    Vector3 newDir = transformMatInv.multiply(ray.direction);
    Ray rayObjectSpace = new Ray(newO, newDir);
    
    RaycastHit hitObjSpace = objReference.raycast(rayObjectSpace, ignored);
    
    if (hitObjSpace == null) {
      return null;
    }

    //Transform the hit data back into world space
    Point3 contactPointWorld = transformMat.multiply(hitObjSpace.intersection.contactPoint);
    Vector3 contactNormalWorld = transformMatInv.transpose().multiply(hitObjSpace.intersection.normal);
    float distWorld = ray.origin.distanceTo(contactPointWorld);
    RaycastHit hitWorld = new RaycastHit(hitObjSpace.obj, new RayIntersectionData(contactPointWorld, contactNormalWorld), distWorld);
    return hitWorld;
  }
}
