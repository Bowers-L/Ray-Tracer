public class ObjectInstance extends SceneObject {

  private SceneObject objReference;
  private Mat4f transformMat;
  private Mat4f transformMatInv;

  public ObjectInstance(SceneObject objReference, Mat4f transformMat) {
    super(objReference.surfaceMat);
    this.objReference = objReference;
    this.transformMat = transformMat;
    this.transformMatInv = transformMat.invert();
  }

  @Override
    public AABBox getBoundingBox() {
    return null;
  }
  
  @Override
    public void transform(Mat4f transMat) {
    
  }

  @Override
    public RayIntersectionData intersection(Ray ray) {
    Point3 newO = transformMatInv.multiply(ray.origin);
    Vector3 newDir = transformMatInv.multiply(ray.direction);
    
    Ray transformedRay = new Ray(newO, newDir);
    
    RayIntersectionData intersect = objReference.intersection(transformedRay);
    
    if (intersect == null) {
      return null;
    }

    intersect.contactPoint = transformMat.multiply(intersect.contactPoint);
    intersect.normal = transformMatInv.transpose().multiply(intersect.normal);
    return intersect;
  }
}
