public class Triangle extends Shape {
  public Point3[] points = new Point3[3];

  public Triangle(Point3[] points) {
    if (points.length != 3) {
        println("Error: Triangle should have 3 points.");
    }
    this.points = points;
  }
  
  public Triangle(ArrayList<Point3> points) {
    this.points[0] = points.get(0);
    this.points[1] = points.get(1);
    this.points[2] = points.get(2);
  }

  public Vector3 getNormal() {
    Vector3 ab = new Vector3(points[0], points[1]);
    Vector3 bc = new Vector3(points[1], points[2]);

    return ab.cross(bc).normalized();
  }

  public boolean pointInside(Point3 point) {
    Vector3 n = getNormal();

    int side1 = getSide(point, points[0], points[1], n);
    int side2 = getSide(point, points[1], points[2], n);
    int side3 = getSide(point, points[2], points[0], n);

    //Also need to consider if the point is on one of the edges.
    //We have to check all 3 combinations because of the "edge" case (One or more sides could be 0)
    return sameHalfPlane(side1, side2) && sameHalfPlane(side2, side3) && sameHalfPlane(side3, side1);
  }

  private boolean sameHalfPlane(int side1, int side2) {
    return side1 == side2 || side1 == 0 || side2 == 0;
  }

  //returns: 1 if APxAB is parallel to n, -1 if APxAB is anti-parallel, 0 if AP is parallel to AB.
  private int getSide(Point3 p, Point3 a, Point3 b, Vector3 n) {
    Vector3 ab = new Vector3(a, b);
    Vector3 ap = new Vector3(a, p);

    Vector3 apCrossAb = ap.cross(ab);

    float d = n.dot(apCrossAb);

    if (d > 0) {
      return 1;
    } else if (d < 0) {
      return -1;
    } else {
      return 0;
    }
  }

  @Override
  public SurfaceContact intersection(Ray ray) {
    Plane trianglePlane = new Plane(this);
    SurfaceContact planeIntersect = trianglePlane.intersection(ray);

    if (planeIntersect == null) {
      return null;
    }

    boolean isInsideTriangle = pointInside(planeIntersect.point);
    if (isInsideTriangle) {
      return planeIntersect;
    } else {
      return null;
    }
  }
  
  @Override
  public void transform(Mat4f transMat) {
    for (int i = 0; i < 3; i++) {
      points[i] = transMat.multiply(points[i]);
    }
  }
  
  @Override 
  public AABBox getBoundingBox() {
    Point3 min = new Point3(Float.MAX_VALUE, Float.MAX_VALUE, Float.MAX_VALUE);
    Point3 max = new Point3(-Float.MAX_VALUE, -Float.MAX_VALUE, -Float.MAX_VALUE);
    
    for (int i = 0; i < 3; i++) {
      if (points[i].x < min.x) {
        min.x = points[i].x;
      }
      if (points[i].x > max.x) {
        max.x = points[i].x;  
      }
      
      if (points[i].y < min.y) {
        min.y = points[i].y;  
      }
      if (points[i].y > max.y) {
        max.y = points[i].y;  
      }
      
      if (points[i].z < min.z) {
        min.z = points[i].z;  
      }
      if (points[i].z > max.z) {
        max.z = points[i].z;  
      }
    }
    
    return new AABBox(min, max);
  }

  @Override
    public String toString() {
    return String.format("Triangle: %s, %s, %s", points[0].toString(), points[1].toString(), points[2].toString());
  }
}
