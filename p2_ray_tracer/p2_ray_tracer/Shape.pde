public abstract class Shape {
  public final float rayEpsilon = 0.001;  //How far in front a ray should be for its intersection to count.
    
  public abstract SurfaceContact intersection(Ray ray);
  public abstract void transform(Mat4f transMat);
  public abstract AABBox getBoundingBox();
}
