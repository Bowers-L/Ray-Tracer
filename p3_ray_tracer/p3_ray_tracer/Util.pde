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

public Vector3 getRandomDir() {
  float theta = random(2*PI);
  float phi = random(-PI/2, PI/2);
  
  float x = cos(theta)*cos(phi);
  float y = sin(theta)*cos(phi);
  float z = sin(phi);
  return new Vector3(x, y, z);
}

//Partition items in a list within the range [l, r), return the index of the first false element.
public <T> int hoarePartition(ArrayList<T> items, int left, int right, Predicate<T> lessThanTarget) {
  //Hoare's Algorithm: Start on both ends and work towards the middle.
  int l = left;
  int r = right-1;

  while (true) {
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

//Taken from the p2 assignment description. Repurposed to print an arbitrary timer.
public void print_timer(int startTime, String header)
{
  int new_timer = millis();
  int diff = new_timer - startTime;
  float seconds = diff / 1000.0;
  println (header + " = " + seconds);
}

//t = (-b +- sqrt(b^2 - 4ac)) / (2a)
public float[] solveQuadratic(float a, float b, float c) {
  float disc = b*b - 4*a*c;
  if (disc < 0) {
    return null;  //No Solution
  }

  if (disc == 0) {
    return new float[] { -b / (2*a)};
  }

  float t0 = (-b - sqrt(disc)) / (2*a);
  float t1 = (-b + sqrt(disc)) / (2*a);
  
  //Make sure t0 <= t1.
  if (t1 < t0) {
    float temp = t0;
    t0 = t1;
    t1 = temp;
  }

  return new float[] { t0, t1};
}
