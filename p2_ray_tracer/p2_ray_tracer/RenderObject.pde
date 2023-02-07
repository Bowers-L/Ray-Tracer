public abstract class SceneObject implements IntersectsRay {
  public Material surfaceMat;

  public SceneObject(Material surface) {
    this.surfaceMat = surface;
  }
  
  public abstract AABBox getBoundingBox();
}
