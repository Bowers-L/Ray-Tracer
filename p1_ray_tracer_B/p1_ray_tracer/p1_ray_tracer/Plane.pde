public class Plane {
  public Vector3 n;
  public float d;

  public Plane(Vector3 n, float d) {
    this.n = n;
    this.d = d;
  }
  
  public Plane(Point3 p, Point3 q, Point3 r) {
   Vector3 v1 = new Vector3(p, q);
   Vector3 v2 = new Vector3(p, r);
   
   //Construct normal
   this.n = v1.cross(v2);
   this.n = n.normalized();
   
   this.d = -p.dot(n);  //d = -ax0 -by0 - cz0 
  }
  
  public Plane(Triangle t) {
    this(t.p1, t.p2, t.p3); 
  }
  
  public float evaluateObjectiveFunction(Point3 p) {
    return p.dot(n) + d;  //Gets ax + by + cz + d for the given point
  }
  
  public boolean pointOnPlane(Point3 p) {
    return evaluateObjectiveFunction(p) == 0; 
  }
  
  public String toString() {
     return String.format("Normal: %s, d: %f", n, d); 
  }
}
