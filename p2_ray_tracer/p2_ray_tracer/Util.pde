import java.util.function.Predicate;

public static final float DEG2RAD = PI / 180;

public float truncate(float f) {
  return (float) (int) (f);
}

public Vector3 getOrientedNormal(Ray ray, Vector3 normal) {
    if (ray.direction.dot(normal) > 0) {
      normal = normal.scale(-1);  //Make sure the normal and the ray point in opposite directions.
    }
    
    return normal.normalized();
}    

//Partition items in a list within the range [l, r), return the index of the first false element.
public <T> int hoarePartition(ArrayList<T> items, int left, int right, Predicate<T> lessThanTarget) {
  //Hoare's Algorithm: Start on both ends and work towards the middle. 
  int l = left;
  int r = right-1;
  
  while(true) {
    while (l <= r && lessThanTarget.test(items.get(l))) {
      l++;  
    }
    
    while (l <= r && !lessThanTarget.test(items.get(r))) {
      r--;
    }
    
    if (l > r) {
      return l;
    }
    
    //Swap elements
    T temp = items.get(l);
    items.set(l, items.get(r));
    items.set(r, temp);
    l++;
    r--;
  }
}

public void print_timer(int startTime)
{
  int new_timer = millis();
  int diff = new_timer - startTime;
  float seconds = diff / 1000.0;
  println ("Render Time = " + seconds);
}
