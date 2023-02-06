public class Ray {
  public Point3 origin;
  public Vector3 direction;

  public Ray(Point3 origin, Vector3 direction) {
    this.origin = origin;
    this.direction = direction;
  }

  public Point3 evaluate(float t) {
    return origin.add(direction.scale(t));
  }

  public String toString() {
    return String.format("Origin: %s, Direction: %s", origin.toString(), direction.toString());
  }
}

public class RayIntersectionData {
  public Point3 contactPoint;
  public Vector3 normal;  //The normal to the surface hit

  public RayIntersectionData(Point3 contactPoint, Vector3 normal) {
    this.contactPoint = contactPoint;
    this.normal = normal;
  }
}

public interface IntersectsRay {
  //Return the point AND normal that the ray hits, or null if the ray misses.
  public abstract RayIntersectionData intersection(Ray ray);
}
