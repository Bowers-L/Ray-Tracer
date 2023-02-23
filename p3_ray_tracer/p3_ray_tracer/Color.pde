
//Handling of Processing colors so that you can modify separate channels.
public class Color {
  public float r;
  public float g;
  public float b;
  
  public Color(float r, float g, float b) {
    this.r = r;
    this.g = g;
    this.b = b;
  }
  
  public color getColor() {
    return color(r, g, b);
  }
  
  public Color add(Color other) {
    return new Color(r+other.r, g+other.g, b+other.b);  
  }
  
  public Color mult(Color other) {
    return new Color(r*other.r, g*other.g, b*other.b);
  }
  
  public Color scale(float scale) {
    return new Color(r*scale, g*scale, b*scale);  
  }
  

  
  public String toString() {
    return String.format("(%.2f, %.2f, %.2f)", r, g, b); 
  }
}
