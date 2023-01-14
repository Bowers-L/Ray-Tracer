public class Triangle {
  public Point3 p1;
  public Point3 p2;
  public Point3 p3;

  public Triangle(Point3 p1, Point3 p2, Point3 p3) {
    this.p1 = p1;
    this.p2 = p2;
    this.p3 = p3;
  }
  
  public boolean pointInside(Point3 point) {
    Vector3 n = getNormalTo();
    
    int side1 = getSide(point, p1, p2, n);
    int side2 = getSide(point, p2, p3, n);
    int side3 = getSide(point, p3, p1, n);
    
    //Also need to consider if the point is on one of the edges.
    //We have to check all 3 combinations because of the "edge" case (One or more could be 0
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
  
  public Vector3 getNormalTo() {
   Vector3 ab = new Vector3(p1, p2);
   Vector3 bc = new Vector3(p2, p3);
   
   return ab.cross(bc);
  }

  @Override
  public String toString() {
    return String.format("Triangle: %s, %s, %s", p1.toString(), p2.toString(), p3.toString());
  }
}
