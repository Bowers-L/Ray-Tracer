public class ObjectInstance extends SceneObject {

  private SceneObject objReference;
  private Mat4f objToWorld;
  private Mat4f worldToObj;

  public ObjectInstance(SceneObject objReference, Mat4f objToWorld) {
    this.objReference = objReference;
    this.objToWorld = objToWorld;
    this.worldToObj = objToWorld.invert();
  }

  @Override
    public AABBox getBoundingBox() {
    //Doesn't work for rotations
    return (AABBox) objReference.getBoundingBox().transform(objToWorld);
  }

  @Override
    public RaycastHit raycast(Ray ray) {
    
    //Transform ray from world to object space.
    Point3 newO = worldToObj.multiply(ray.origin);
    Vector3 newDir = worldToObj.multiply(ray.direction);
    Ray rayObjectSpace = new Ray(newO, newDir);
    
    RaycastHit hitObjSpace = objReference.raycast(rayObjectSpace);
    
    if (hitObjSpace == null) {
      return null;
    }

    //Transform the hit data back into world space
    Point3 contactPointWorld = objToWorld.multiply(hitObjSpace.contact.point);
    Vector3 contactNormalWorld = worldToObj.transpose().multiply(hitObjSpace.contact.normal);
    contactNormalWorld = contactNormalWorld.normalized();
    
    float distWorld = ray.origin.distanceTo(contactPointWorld);
    RaycastHit hitWorld = new RaycastHit(hitObjSpace.obj, new SurfaceContact(contactPointWorld, contactNormalWorld), distWorld);
    return hitWorld;
  }
}
