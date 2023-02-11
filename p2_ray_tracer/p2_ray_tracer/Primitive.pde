//Reference: pbrt 4.1
public class Primitive extends SceneObject {

    public Shape shape;  //Describes the geometric properties
    public Material material;  //Describes the render properties of the primitive.
    
    public Primitive(Shape shape, Material surface) {
      this.shape = shape;
      this.material = surface;
    }
    
    @Override
    public AABBox getBoundingBox() {
      return shape.getBoundingBox();
    }
    
    @Override
    public RaycastHit raycast(Ray ray) {      
      //For normal primitives, we just need to get the ray intersection directly and return the obj.
      SurfaceContact contact = shape.intersection(ray);

      if (contact == null) {
        return null;
      } else {
        //The object has to be in front by at least a tiny bit for it to count.
        float dist = ray.origin.distanceTo(contact.point);
        return new RaycastHit(this, contact, dist);
      }
    }
}
