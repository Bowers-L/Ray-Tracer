public abstract class SceneObject implements IntersectsRay {
  public Material surfaceMat;

  public SceneObject(Material surface) {
    this.surfaceMat = surface;
  }
  
  public abstract void transform(Mat4f transMat);
  
  public abstract AABBox getBoundingBox();
}
