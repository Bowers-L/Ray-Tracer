public class AABBox extends Shape {
  private Bounds3 _bounds;

  public AABBox(Bounds3 bounds) {
    this._bounds = bounds;
  }

  public AABBox(Point3 min, Point3 max) {
    this(new Bounds3(min, max));
  }

  @Override
    public SurfaceContact intersection(Ray r) {
    Point3 contactP = getIntersectionPoint(r);
    return contactP == null ? null : new SurfaceContact(contactP, getNormal(contactP));
  }

  @Override
    public Shape transform(Mat4f transMat) {
    return new AABBox(transMat.multiply(_bounds.min), transMat.multiply(_bounds.max));
  }

  @Override
    public AABBox getBoundingBox() {
    return this;
  }

  public Bounds3 bounds() {
    return _bounds;
  }

  public Vector3 halfExtents() {
    Vector3 halfExtents = new Vector3(_bounds.min, _bounds.max);
    return halfExtents.scale(0.5);
  }

  public Point3 getCentroid() {
    return _bounds.min.add(halfExtents());
  }

  private Point3 getIntersectionPoint(Ray r) {
    //Ray BBox Intersection based on PBR section 4.2.1

    Bounds1 tBoundsX = getRayTBounds(_bounds.min.x, _bounds.max.x, r.origin.x, r.direction.x);
    Bounds1 tBoundsY = getRayTBounds(_bounds.min.y, _bounds.max.y, r.origin.y, r.direction.y);
    Bounds1 tBoundsXY = boundsUtil.intersection(tBoundsX, tBoundsY);
    if (!tBoundsXY.isValid()) {
      return null;
    }

    Bounds1 tBoundsZ = getRayTBounds(_bounds.min.z, _bounds.max.z, r.origin.z, r.direction.z);
    Bounds1 tBoundsXYZ = boundsUtil.intersection(tBoundsXY, tBoundsZ);
    if (!tBoundsXYZ.isValid()) {
      return null;
    }

    float t = tBoundsXYZ.lower;
    if (t < rayEpsilon) {
      return null;
    }

    return r.evaluate(t);
  }

  private Vector3 getNormal(Point3 contactP) {
    //Translate the box to (0, 0, 0)
    Vector3 centerToOrigin = new Vector3(getCentroid(), new Point3(0, 0, 0));
    Point3 contactPObjSpace = contactP.add(centerToOrigin);

    Vector3 halfBoxSize = halfExtents();

    //Scale min and max to unit box
    //0/0 situation means the box is actually a plane (or a line), so normal points in that direction
    float normalizedX = halfBoxSize.x == 0 ? 1 : contactPObjSpace.x / halfBoxSize.x;
    float signX = normalizedX < 0 ? -1 : 1;
    float normalizedY = halfBoxSize.y == 0 ? 1 : contactPObjSpace.y / halfBoxSize.y;
    float signY = normalizedY < 0 ? -1 : 1;
    float normalizedZ = halfBoxSize.z == 0 ? 1 : contactPObjSpace.z / halfBoxSize.z;
    float signZ = normalizedZ < 0 ? -1 : 1;

    //Add float delta, trunctate by casting to float then int.
    float epsilon = 0.001;
    Vector3 normal = new Vector3(
      truncate(normalizedX + signX * epsilon),
      truncate(normalizedY + signY * epsilon),
      truncate(normalizedZ + signZ * epsilon));

    return normal;
  }

  private Bounds1 getRayTBounds(float x1, float x2, float ox, float rDirX) {
    //t = (x - a_x) / b_x
    float rDirInv = 1./ rDirX;
    float t1 = (x1 - ox) * rDirInv;
    float t2 = (x2 - ox) * rDirInv;

    return t1 > t2 ? new Bounds1(t2, t1) : new Bounds1(t1, t2);
  }
  
  public String toString() {
    String result = "";
    result += "min: " + _bounds.min + " ";
    result += "max: " + _bounds.max;
    return result;
  }
}

public AABBox union(AABBox box1, AABBox box2) {
  if (box1 == null && box2 == null) {
    return null;
  }

  if (box1 == null || box2 == null) {
    return box1 == null ? box2 : box1;
  }

  return new AABBox(boundsUtil.union(box1.bounds(), box2.bounds()));
}
