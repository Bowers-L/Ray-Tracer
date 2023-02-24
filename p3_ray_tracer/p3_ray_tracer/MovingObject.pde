public class MovingObject extends SceneObject {
    private SceneObject objReference;
    private Vector3 dPos;
    private float currTime;
    
    public MovingObject(SceneObject objReference, Vector3 dPos) {
      this.objReference = objReference;
      this.dPos = dPos;
    }
    
    @Override
    public AABBox getBoundingBox() {
      return (AABBox) objReference.getBoundingBox().transform(objToWorld());
    }

    @Override 
    public RaycastHit raycast(Ray ray) {
      //Transform ray from world to object space.
      Point3 newO = worldToObj().multiply(ray.origin);
      Vector3 newDir = worldToObj().multiply(ray.direction);
      Ray rayObjectSpace = new Ray(newO, newDir);
      
      RaycastHit hitObjSpace = objReference.raycast(rayObjectSpace);
      
      if (hitObjSpace == null) {
        return null;
      }
  
      //Transform the hit data back into world space
      Point3 contactPointWorld = objToWorld().multiply(hitObjSpace.contact.point);
      Vector3 contactNormalWorld = worldToObj().transpose().multiply(hitObjSpace.contact.normal);
      contactNormalWorld = contactNormalWorld.normalized();
      
      float distWorld = ray.origin.distanceTo(contactPointWorld);
      RaycastHit hitWorld = new RaycastHit(hitObjSpace.obj, new SurfaceContact(contactPointWorld, contactNormalWorld), distWorld);
      return hitWorld;
    }
    
    @Override
    public void perPixelRay() {
      assignRandomTime();  
    }
    
    public void assignRandomTime() {
        currTime = random(1f);
    }
    
    public Mat4f objToWorld() {
        return matTranslate(dPos.x*currTime, dPos.y*currTime, dPos.z*currTime);
    }
    
    public Mat4f worldToObj() {
      return matTranslate(-dPos.x*currTime, -dPos.y*currTime, -dPos.z*currTime);
    }
}
