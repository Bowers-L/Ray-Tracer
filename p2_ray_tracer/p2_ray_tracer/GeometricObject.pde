//NOTE: The Primitive class in the PBR book is closer to the SceneObject class in this project.
//Geometric Objects are only used to render basic shapes with a material.
public class GeometricObject extends SceneObject {
    public Shape shape;  //Describes the geometric properties
    public Material material;  //Describes the render properties of the primitive.
    
    public GeometricObject(Shape shape, Material surface) {
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
    
    public String toString() {
      String result = "Geometric Primitive:\n"; 
      result += "\t" + shape + "\n";
      result += "\t" + material + "\n";
      return result;
    }
}
