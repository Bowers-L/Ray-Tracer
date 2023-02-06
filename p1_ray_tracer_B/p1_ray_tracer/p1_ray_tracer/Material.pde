public class Material {
  //Processing represents colors as packed ints, so I separated out the channels here to make the math easier.
  public float r;
  public float g;
  public float b;
  
  public Material(float r, float g, float b) {
    this.r = r;
    this.g = g;
    this.b = b;
  }
  
  public color getColor() {
    return color(r, g, b);
  }
  
  public String toString() {
    return String.format("Material with color (%.2f, %.2f, %.2f)", r, g, b); 
  }
}
