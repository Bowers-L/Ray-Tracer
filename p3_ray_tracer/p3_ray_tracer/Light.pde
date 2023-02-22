public class Light {
  public Point3 position;
  public Material material;
  
  public Light(Point3 position, Material material) {
    this.position = position;
    this.material = material;
  }
  
  public String toString() {
    return String.format("Light at pos: %s with material: %s", position, material); 
  }
}
