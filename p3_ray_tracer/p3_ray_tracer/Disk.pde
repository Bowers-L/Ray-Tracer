public class Disk {
  private Point3 center;
  private float radius;
  private Vector3 dir;
  
  public Disk(Point3 center, float radius, Vector3 dir) {
    this.center = center;
    this.radius = radius;
    this.dir = dir.normalized();
  }
  
  public Point3 randomPointOn() {
    Vector3[] basis = getBasisVectors();
    
    Point3 p = null;
    do {
      float r1 = random(-1, 1);
      float r2 = random(-1, 1);
      Vector3 v1 = basis[0].scale(r1*radius);
      Vector3 v2 = basis[1].scale(r2*radius);
      p = center.add(v1.add(v2));
    } while ((new Vector3(center, p)).sqMagnitude() > radius * radius);    //Reject if not in disk.  
    
    return p;
  }
  
  private Vector3[] getBasisVectors() {
    //Create two vectors that are perpendicular to dir and perpendicular to each other.
    
    Vector3 v1 = new Vector3(1, 1, 1);  //This vector is arbitrary.
    v1.z = (-dir.x*v1.x - dir.y*v1.y) / dir.z;
    
    Vector3 v2 = dir.cross(v1);
    
    return new Vector3[] {v1.normalized(), v2.normalized()};
  } 
}
