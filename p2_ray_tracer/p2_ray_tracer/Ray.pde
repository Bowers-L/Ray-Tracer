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

public interface IntersectsRay {
  //Return the point that the ray hits, or null if the ray misses.
  public abstract Point3 intersection(Ray ray);
}
