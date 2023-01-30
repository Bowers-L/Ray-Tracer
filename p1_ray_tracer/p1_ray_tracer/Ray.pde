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

  public Point3 intersect(Plane plane) {
    float objectiveOrigin = plane.evaluateObjectiveFunction(origin);
    float nDotDir = plane.n.dot(direction);

    if (nDotDir == 0f) {
      //Plane is parallel to the ray direction.
      //If the ray origin is not on the plane, there's no solution (no intersection).
      //Otherwise, the origin is the closest solution.
      return plane.pointOnPlane(origin) ? origin : null;
    }
    float t = -objectiveOrigin / nDotDir;  //-(ao_x + bo_y + co_z + d) / (ad_x + bd_y + cd_z)

    if (t < 0) {  //Ray shouldn't go backwards.
      return null;
    }

    return evaluate(t);
  }

  public Point3 intersect(Triangle triangle) {
    Plane trianglePlane = new Plane(triangle);
    Point3 pointOnPlane = intersect(trianglePlane);

    if (pointOnPlane == null) {
      return null;
    }

    boolean pointOnTriangle = triangle.pointInside(pointOnPlane);
    if (pointOnTriangle) {
      return pointOnPlane;
    } else {
      return null;
    }
  }

  public String toString() {
    return String.format("Origin: %s, Direction: %s", origin.toString(), direction.toString());
  }
}
