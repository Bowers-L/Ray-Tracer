public class Float3 {
  float x;
  float y;
  float z;

  public Float3(float x, float y, float z) {
    this.x = x;
    this.y = y;
    this.z = z;
  }

  public float dot(Float3 other) {
    return this.x*other.x + this.y*other.y + this.z*other.z;
  }

  public String toString() {
    return String.format("(%.2f, %.2f, %.2f)", x, y, z);
  }
}

public class Point3 extends Float3 {
  public Point3(float x, float y, float z) {
    super(x, y, z);
  }

  public Point3 add(Vector3 v) {
    return new Point3(x + v.x, y+v.y, z+v.z);
  }
  
  public float sqDistanceTo(Point3 other) {
    return (new Vector3(this, other)).sqMagnitude(); 
  }
  
  public float distanceTo(Point3 other) {
    return (new Vector3(this, other)).magnitude(); 
  }
}

public class Vector3 extends Float3 {
  public Vector3(float x, float y, float z) {
    super(x, y, z);
  }

  public Vector3(Point3 p1, Point3 p2) {
    super(p2.x-p1.x, p2.y-p1.y, p2.z-p1.z);
  }

  public Vector3 add(Vector3 v) {
    return new Vector3(x+v.x, y+v.y, z+v.z);
  }

  public Vector3 scale(float s) {
    return new Vector3(s*x, s*y, s*z);
  }
  
  public float sqMagnitude() {
    return x*x + y*y + z*z;
  }

  public float magnitude() {
    return sqrt(sqMagnitude());
  }

  public Vector3 norm() {
    return this.scale(1 / magnitude());
  }

  public Vector3 cross(Vector3 other) {
    return new Vector3(this.y*other.z-this.z*other.y, this.z*other.x-this.x*other.z, this.x*other.y-this.y*other.x);
  }
}
