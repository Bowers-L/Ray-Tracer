public class RenderObject {
  public Triangle triangle;
  public Material surfaceMat;

  public RenderObject(Triangle triangle, Material surface) {
    this.triangle = triangle;
    this.surfaceMat = surface;
  }
  
  public String toString() {
    return String.format("Render Object: \n %s \n surface: %s", triangle, surfaceMat); 
  }
}
