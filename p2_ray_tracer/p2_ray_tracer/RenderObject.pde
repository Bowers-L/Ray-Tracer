public abstract class RenderObject implements IntersectsRay {
  public Material surfaceMat;

  public RenderObject(Material surface) {
    this.surfaceMat = surface;
  }
  
  public abstract Vector3 getNormal();
}