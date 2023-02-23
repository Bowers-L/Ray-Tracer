//Reference: https://www.pbr-book.org/3ed-2018/Shapes/Spheres
public class Sphere extends Shape {
  private float radius;
  private Point3 center;

  public Sphere(float radius, Point3 center) {
    this.radius = radius;
    this.center = center;
  }

  @Override
    public SurfaceContact intersection(Ray ray) {
    Point3 contactP = getContactPoint(ray);
    
    if (contactP == null) {
      return null;
    }
    Vector3 normal = (new Vector3(center, contactP)).normalized();
    
    return new SurfaceContact(contactP, normal);
  }

  private Point3 getContactPoint(Ray ray) {
    Vector3 o = new Vector3(center, ray.origin);  //Ray origin w.r.t the sphere center.
    Vector3 d = ray.direction;

    //Construct quadratic constraint
    float a = d.x*d.x + d.y*d.y + d.z*d.z;
    float b = 2 * (d.x*o.x + d.y*o.y + d.z*o.z);
    float c = o.x*o.x + o.y*o.y + o.z*o.z - radius*radius;

    float[] tResults = solveQuadratic(a, b, c);

    if (tResults == null || tResults.length == 0) {
      return null;
    }

    if (tResults.length == 1) {
      if (tResults[0] < rayEpsilon) {
        return null;
      } else {
        return ray.evaluate(tResults[0]);
      }
    }

    //t0 <= t1
    float t0 = tResults[0];
    float t1 = tResults[1];

    if (t1 < rayEpsilon) {
      return null;
    } else if (t0 < rayEpsilon) {
      return ray.evaluate(t1);
    } else {
      return ray.evaluate(t0);
    }
  }

  @Override
    public Shape transform(Mat4f transMat) {
    //Note: This doesn't work for scaling
    Point3 newCenter = transMat.multiply(center);
    return new Sphere(radius, newCenter);
  }

  @Override
    public AABBox getBoundingBox() {
    Point3 min = new Point3(-radius, -radius, -radius);
    Point3 max = new Point3(radius, radius, radius);

    return new AABBox(min, max);
  }
}
