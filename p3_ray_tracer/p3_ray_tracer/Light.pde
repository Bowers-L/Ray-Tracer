public abstract class Light {
  public Color col;
  
  public Light(Color col) {
    this.col = col;
  }
  
  public abstract BoundedRay getShadowRay(Point3 origin);
}

public class PointLight extends Light {
  private Point3 pos;
  
  public PointLight(Point3 pos, Color col) {
    super(col);
    this.pos = pos;
  }
  
  @Override
  public BoundedRay getShadowRay(Point3 origin) {
    Vector3 oToLight = new Vector3(origin, pos);
    return new BoundedRay(origin, oToLight.normalized(), oToLight.magnitude());
  }
  
  public String toString() {
    return String.format("Light at pos: %s with Color: %s", pos, col); 
  }
}

public class DiskLight extends Light {
  private Point3 center;
  private float radius;
  private Vector3 dir;
  
  public DiskLight(Point3 center, float radius, Vector3 dir, Color col) {
    super(col);
    this.center = center;
    this.radius = radius;
    this.dir = dir.normalized();
  }
  
  @Override
  public BoundedRay getShadowRay(Point3 origin) {
    //TODO: Get basis vectors, two randoms between -0.5 and 0.5, get random point on square perp. to dir, reject if not on disk or the ray is facing in the opposite direction.
    Vector3[] basis = getBasisVectors();
    
    Point3 p = null;
    do {
      float r1 = random(-1, 1);
      float r2 = random(-1, 1);
      Vector3 v1 = basis[0].scale(r1*radius);
      Vector3 v2 = basis[1].scale(r2*radius);
      p = center.add(v1.add(v2));
    } while ((new Vector3(center, p)).sqMagnitude() > radius * radius);    //Reject if not in disk.
    
    Vector3 oToLight = new Vector3(origin, p);
    return new BoundedRay(origin, oToLight.normalized(), oToLight.magnitude());
  }
  
  public Vector3[] getBasisVectors() {
    //Create two vectors that are perpendicular to dir and perpendicular to each other.
    
    Vector3 v1 = new Vector3(1, 1, 1);  //This vector is arbitrary.
    v1.z = (-dir.x*v1.x - dir.y*v1.y) / dir.z;
    
    Vector3 v2 = dir.cross(v1);
    
    return new Vector3[] {v1.normalized(), v2.normalized()};
  }
  
  
}
