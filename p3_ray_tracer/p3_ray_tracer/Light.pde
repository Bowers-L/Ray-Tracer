public abstract class Light {
  public Color col;
  
  public Light(Color col) {
    this.col = col;
  }
  
  public abstract BoundedRay getShadowRay(Point3 origin);
}

public class PointLight extends Light {
  private Point3 pos;
  
  public PointLight(Point3 pos, Color col) {
    super(col);
    this.pos = pos;
  }
  
  @Override
  public BoundedRay getShadowRay(Point3 origin) {
    Vector3 oToLight = new Vector3(origin, pos);
    return new BoundedRay(origin, oToLight.normalized(), oToLight.magnitude());
  }
  
  public String toString() {
    return String.format("Light at pos: %s with Color: %s", pos, col); 
  }
}

public class DiskLight extends Light {
  private Point3 center;
  private float radius;
  private Vector3 dir;
  
  public DiskLight(Point3 center, float radius, Vector3 dir, Color col) {
    super(col);
    this.center = center;
    this.radius = radius;
    this.dir = dir;
  }
  
  
  @Override
  public BoundedRay getShadowRay(Point3 origin) {
    //Sample things and do cool stuff.
    Vector3 oToLight = new Vector3(origin, center);
    return new BoundedRay(origin, oToLight.normalized(), oToLight.magnitude());
  }
}
