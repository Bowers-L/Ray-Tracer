public class Bounds1 {
  public float lower;
  public float upper;

  public Bounds1(float lower, float upper) {
    this.lower = lower;
    this.upper = upper;
  }

  //returns true if intersection is valid and false if it is invalid
  public Bounds1 intersection(Bounds1 other) {

    //Increase the lower bound (if possible)
    float intersectLower = max(this.lower, other.lower);

    //Decrease the upper bound (if possible)
    float intersectUpper = min(this.upper, other.upper);

    return new Bounds1(intersectLower, intersectUpper);
  }

  public Bounds1 union(Bounds1 other) {
    float unionLower = min(this.lower, other.lower);
    float unionUpper = max(this.upper, other.upper);

    return new Bounds1(unionLower, unionUpper);
  }

  public boolean isValid() {
    return this.lower <= this.upper;
  }
}

public class Bounds3 {
  public Point3 min;
  public Point3 max;

  public Bounds3(Point3 min, Point3 max) {
    this.min = min;
    this.max = max;
  }

  public int maximumExtentsDimension() {
    float extentsX = max.x - min.x;
    float extentsY = max.y - min.y;
    float extentsZ = max.z - min.z;
    if (extentsX > extentsY && extentsX > extentsZ) {
      return 0;
    } else if (extentsY > extentsZ) {
      return 1;
    } else {
      return 2;
    }
  }
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
  Bounds1 bx = b1x.union(b2x);

  Bounds1 b1y = new Bounds1(bounds1.min.y, bounds1.max.y);
  Bounds1 b2y = new Bounds1(bounds2.min.y, bounds2.max.y);
  Bounds1 by = b1y.union(b2y);

  Bounds1 b1z = new Bounds1(bounds1.min.z, bounds1.max.z);
  Bounds1 b2z = new Bounds1(bounds2.min.z, bounds2.max.z);
  Bounds1 bz = b1z.union(b2z);

  Point3 min = new Point3(bx.lower, by.lower, bz.lower);
  Point3 max = new Point3(bx.upper, by.upper, bz.upper);
  return new Bounds3(min, max);
}

//Returns a bounds that covers the extents of "bounds" and includes "point".
public Bounds3 union(Bounds3 bounds, Point3 point) {
    return union(bounds, new Bounds3(point, point));
}
