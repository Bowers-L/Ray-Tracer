public abstract class Light {
  public class ShadowRayInfo {
    Ray ray;
    float distToLight;
    
    public ShadowRayInfo(Ray ray, float distToLight) {
      this.ray = ray;
      this.distToLight = distToLight;
    }
  }
  
  public Color col;
  
  public Light(Color col) {
    this.col = col;
  }
  
  public abstract ShadowRayInfo getShadowRay(Point3 origin);
}

public class PointLight extends Light {
  private Point3 pos;
  
  public PointLight(Point3 pos, Color col) {
    super(col);
    this.pos = pos;
  }
  
  @Override
  public ShadowRayInfo getShadowRay(Point3 origin) {
    Vector3 oToLight = new Vector3(origin, pos);
    return new ShadowRayInfo(new Ray(origin, oToLight.normalized()), oToLight.magnitude());
  }
  
  public String toString() {
    return String.format("Light at pos: %s with Color: %s", pos, col); 
  }
}

public class DiskLight extends Light {
  private Disk disk;
  
  public DiskLight(Disk disk, Color col) {
    super(col);
    this.disk = disk;
  }
  
  public DiskLight(Point3 center, float radius, Vector3 dir, Color col) {
    this(new Disk(center, radius, dir), col);
  }
  
  @Override
  public ShadowRayInfo getShadowRay(Point3 origin) {
    //TODO: Get basis vectors, two randoms between -0.5 and 0.5, get random point on square perp. to dir, reject if not on disk or the ray is facing in the opposite direction.

    Point3 p = disk.randomPointOn();
    Vector3 oToLight = new Vector3(origin, p);
    
    if (debug_flag) {
      println("Printing info for shadow ray:");
      println("P: ", p);
      println("origin to light: ", oToLight);
    }
    return new ShadowRayInfo(new Ray(origin, oToLight.normalized()), oToLight.magnitude());
  }
}
