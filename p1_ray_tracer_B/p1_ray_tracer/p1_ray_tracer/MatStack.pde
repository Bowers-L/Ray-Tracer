import java.util.Stack;

public class MatStack {
  Stack<Mat4f> stack;
  
  public MatStack() {
    stack = new Stack<Mat4f>();
    stack.push(matIdentity());
  }
  
  public void push() {
    stack.push(new Mat4f(stack.peek()));  
  }
  
  public void pop() {
    Mat4f top = stack.pop();  
    if (stack.empty()) {
      println("ERROR: Tried to pop matrix stack when it only had one element.");  
      stack.push(top);
    }
  }
  
  public Mat4f top() {
    return stack.peek();
  }
  
  public void translate(float x, float y, float z) {
    multiplyStackRight(matTranslate(x, y, z));  
    //println("Matrix after translate ", x, y, z);
    //println(stack.peek());
  }
  
  public void scale(float sx, float sy, float sz) {
    multiplyStackRight(matScale(sx, sy, sz));
    //println("Matrix after scale ", sx, sy, sz);
    //println(stack.peek());
  }
  
  public void rotate(float angle, float rx, float ry, float rz) {
    //This just assumes rotations around a single axis
    if (rx > 0) {
      multiplyStackRight(matRotateX(angle));
    } else if (ry > 0) {
      multiplyStackRight(matRotateY(angle));
    } else if (rz > 0) {
      multiplyStackRight(matRotateZ(angle));
    }
    
    //println("Matrix after rotate ", angle, rx, ry, rz);
    //println(stack.peek());
  }
  
  private void multiplyStackRight(Mat4f right) {
    //println("Multiplying stack by: ");
    //println(right);
    Mat4f currTop = stack.pop();
    Mat4f newTop = currTop.multiply(right);
    stack.push(newTop);
  }
}
