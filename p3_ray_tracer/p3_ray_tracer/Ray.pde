public class Ray {
  public Point3 origin;
  public Vector3 direction;

  public Ray(Point3 origin, Vector3 direction) {
    this.origin = origin;
    this.direction = direction.normalized();
  }
  
  public Ray(Point3 origin, Point3 other) {
    this.origin = origin;
    this.direction = (new Vector3(origin, other)).normalized();
  }

  public Point3 evaluate(float t) {
    return origin.add(direction.scale(t));
  }

  public String toString() {
    return String.format("Origin: %s, Direction: %s", origin.toString(), direction.toString());
  }
}

public class SurfaceContact {
  //Simplified version that just gets the point and normal at the surface.
  public Point3 point;
  public Vector3 normal;  //The normal to the surface hit

  public SurfaceContact(Point3 contactPoint, Vector3 normal) {
    //this.object = object;
    this.point = contactPoint;
    this.normal = normal;
  }
}

//Useful information returned from raycast
public class RaycastHit {
  public GeometricObject obj;
  public SurfaceContact contact;
  public float distance;
  
  public RaycastHit(GeometricObject obj, SurfaceContact contact, float distance) {
    this.obj = obj;
    this.contact = contact;
    this.distance = distance;
  }
}
