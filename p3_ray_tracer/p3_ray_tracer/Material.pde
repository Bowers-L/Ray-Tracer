public class Material {
  public Color diffuse;
  public Color specular;
  public float specPow;
  public float kRefl;
  public float glossRadius;
  
  public Material(float r, float g, float b) {
    this(new Color(r, g, b));
  }
  
  public Material(Color diffuse) {
    this(diffuse, new Color(0, 0, 0), 0, 0, 0);
  }
  
  public Material(Color diffuse, Color specular, float specPow, float kRefl, float glossRadius) {
    this.diffuse = diffuse;
    this.specular = specular;
    this.specPow = specPow;
    this.kRefl = kRefl;
    this.glossRadius = glossRadius;
  }
  
  public String toString() {
    return String.format("Material with diffuse %s", diffuse); 
  }
}
