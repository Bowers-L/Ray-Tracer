//This object exists bc Java doesn't allow static methods in non-static classes and also doesn't allow static classes in inner classes (which all PDE classes are)
BoundsUtil boundsUtil = new BoundsUtil();

public class Bounds1 {
  public float lower;
  public float upper;

  public Bounds1(float lower, float upper) {
    this.lower = lower;
    this.upper = upper;
  }

  public boolean isValid() {
    return this.lower <= this.upper;
  }
}

public class Bounds3 {
  public class MaxExtentsDim {
    public int dim;
    public Bounds1 bounds;

    public MaxExtentsDim(int dim, Bounds1 bounds) {
      this.dim = dim;
      this.bounds = bounds;
    }
  }

  public Point3 min;
  public Point3 max;

  public Bounds3(Point3 min, Point3 max) {
    this.min = min;
    this.max = max;
  }

  public MaxExtentsDim maximumExtentsDimension() {
    float extentsX = max.x - min.x;
    float extentsY = max.y - min.y;
    float extentsZ = max.z - min.z;
    if (extentsX > extentsY && extentsX > extentsZ) {
      return new MaxExtentsDim(0, new Bounds1(min.x, max.x));
    } else if (extentsY > extentsZ) {
      return new MaxExtentsDim(1, new Bounds1(min.y, max.y));
    } else {
      return new MaxExtentsDim(2, new Bounds1(min.z, max.z));
    }
  }
}

public class BoundsUtil {
  //These are free functions because I want the ability to pass in null (i.e. empty set) and it still be valid.

  public Bounds1 union(Bounds1 b1, Bounds1 b2) {
    float unionLower = min(b1.lower, b2.lower);
    float unionUpper = max(b1.upper, b2.upper);

    return new Bounds1(unionLower, unionUpper);
  }

  public Bounds1 intersection(Bounds1 b1, Bounds1 b2) {

    //Increase the lower bound (if possible)
    float intersectLower = max(b1.lower, b2.lower);

    //Decrease the upper bound (if possible)
    float intersectUpper = min(b1.upper, b2.upper);

    return new Bounds1(intersectLower, intersectUpper);
  }

  //Returns a bounds that covers the extents of both bounds. Used for BVH.
  public Bounds3 union(Bounds3 bounds1, Bounds3 bounds2) {
    if (bounds1 == null && bounds2 == null) {
      return null;
    }

    if (bounds1 == null || bounds2 == null) {
      return bounds1 == null ? bounds2 : bounds1;
    }

    Bounds1 b1x = new Bounds1(bounds1.min.x, bounds1.max.x);
    Bounds1 b2x = new Bounds1(bounds2.min.x, bounds2.max.x);
    Bounds1 bx = union(b1x, b2x);

    Bounds1 b1y = new Bounds1(bounds1.min.y, bounds1.max.y);
    Bounds1 b2y = new Bounds1(bounds2.min.y, bounds2.max.y);
    Bounds1 by = union(b1y, b2y);

    Bounds1 b1z = new Bounds1(bounds1.min.z, bounds1.max.z);
    Bounds1 b2z = new Bounds1(bounds2.min.z, bounds2.max.z);
    Bounds1 bz = union(b1z, b2z);

    Point3 min = new Point3(bx.lower, by.lower, bz.lower);
    Point3 max = new Point3(bx.upper, by.upper, bz.upper);
    return new Bounds3(min, max);
  }

  //Returns a bounds that covers the extents of "bounds" and includes "point".
  public Bounds3 union(Bounds3 bounds, Point3 point) {
    return union(bounds, new Bounds3(point, point));
  }
}
