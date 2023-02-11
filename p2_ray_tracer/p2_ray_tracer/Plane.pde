public class Plane extends Shape {
  public Vector3 n;
  public float d;

  public Plane(Vector3 n, float d) {
    this.n = n;
    this.d = d;
  }
  
  public Plane(Point3 p, Point3 q, Point3 r) {
   Vector3 v1 = new Vector3(p, q);
   Vector3 v2 = new Vector3(p, r);
   
   //Construct normal
   this.n = v1.cross(v2);
   this.n = n.normalized();
   
   this.d = -p.dot(n);  //d = -ax0 -by0 - cz0 
  }
  
  public Plane(Triangle t) {
    this(t.p1, t.p2, t.p3); 
  }
  
  public float evaluateObjectiveFunction(Point3 p) {
    return p.dot(n) + d;  //Gets ax + by + cz + d for the given point
  }
  
  public boolean pointOnPlane(Point3 p) {
    return evaluateObjectiveFunction(p) == 0;
  }
  
  @Override
  public void transform(Mat4f transMat) {
    //Don't need to transform planes
  }
  
  @Override
  public AABBox getBoundingBox() {
    return null;  //Planes are infinite and don't have bounding boxes.  
  }
  
  @Override
  public SurfaceContact intersection(Ray ray) {
    Point3 contactPoint = getContactPoint(ray);
    
    return contactPoint == null ? null : new SurfaceContact(contactPoint, getOrientedNormal(ray, n));
  }
  
  private Point3 getContactPoint(Ray ray) {
    float objectiveOrigin = evaluateObjectiveFunction(ray.origin);
    float nDotDir = n.dot(ray.direction);

    if (nDotDir == 0f) {
      //Plane is parallel to the ray direction.
      //If the ray origin is not on the plane, there's no solution (no intersection).
      //Otherwise, the origin is the closest solution.
      return pointOnPlane(ray.origin) ? ray.origin : null;
    }
    float t = -objectiveOrigin / nDotDir;  //-(ao_x + bo_y + co_z + d) / (ad_x + bd_y + cd_z)

    if (t < rayEpsilon) {  //Ray shouldn't go backwards.
      return null;
    }

    return ray.evaluate(t);
  }
  
  public String toString() {
     return String.format("Normal: %s, d: %f", n, d); 
  }
}
