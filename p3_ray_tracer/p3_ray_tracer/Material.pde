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
  
  public Color getContributionFromLight(Vector3 n, Vector3 l) {
      float diffuseStrength = max(0, n.dot(l));
      Color diffuseContrib = diffuse.scale(diffuseStrength);
      return diffuseContrib;
  }
  
  public String toString() {
    return String.format("Material with diffuse %s", diffuse); 
  }
}
