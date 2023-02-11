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
