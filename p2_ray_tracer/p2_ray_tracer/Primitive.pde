//A SINGLE OBJECT
public abstract class Primitive extends SceneObject implements IntersectsRay {

    public Material surfaceMat;
    
    public Primitive(Material surface) {
      this.surfaceMat = surface;
    }
    
    public abstract void transform(Mat4f transMat);
    
    @Override
    public RaycastHit raycast(Ray ray) {      
      //For normal primitives, we just need to get the ray intersection directly and return the obj.
      RayIntersectionData intersect = intersection(ray);

      if (intersect == null) {
        return null;
      } else {
        //The object has to be in front by at least a tiny bit for it to count.
        float dist = ray.origin.distanceTo(intersect.contactPoint);
        return dist < rayEpsilon ? null : new RaycastHit(this, intersect, dist);
      }
    }
}
