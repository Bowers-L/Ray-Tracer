public class RenderObject {
  public Triangle triangle;
  public color surface;

  public RenderObject(Triangle triangle, color surface) {
    this.triangle = triangle;
    this.surface = surface;
  }
  
  public String toString() {
    return String.format("Render Object: \n %s \n surface: %s", triangle, surface); 
  }
}
