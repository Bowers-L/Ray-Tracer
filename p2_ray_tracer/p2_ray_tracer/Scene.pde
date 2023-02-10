import java.util.HashSet;

//Useful information returned from raycast
public class RaycastHit {
  public SceneObject obj;
  public RayIntersectionData intersection;
  public float distanceToHit;

  public RaycastHit(SceneObject obj, RayIntersectionData intersection, float distanceToHit) {
    this.obj = obj;
    this.intersection = intersection;
    this.distanceToHit = distanceToHit;
  }
}

public class Scene {
  final Point3 eye = new Point3(0, 0, 0);
  
  private ArrayList<Light> _lights = new ArrayList<Light>();
  private ArrayList<SceneObject> _sceneObjects = new ArrayList<SceneObject>();
  private float _fovDeg = 0;
  private float _k = 0; //The number of units between the 
  private color _background = color(0, 0, 0);

  public Scene() {
    reset();
  }

  public void reset() {
    _background = color(0, 0, 0);
    setFOV(0);
    _lights.clear();
    _sceneObjects.clear();
  }

  // Go through all pixels and draw the scene using Ray Tracing.
  public void render() {
      background(_background);
      
      for (int y = 0; y < height; y++) {
          for (int x = 0; x < width; x++) {
              
              // Maybe set debug flag true for ONE pixel.
              // Have your routines (like ray/triangle intersection)
              // print information when this flag is set.
              debug_flag = false;
              //if (x == 150 && y == 140)
              //debug_flag = true;
              
              // create and cast an eye ray
              Point3 pixelInWorld = screenToWorldPos(x, y);
              Ray eyeRay = new Ray(eye, new Vector3(eye, pixelInWorld));
              
              if (debug_flag) {
                  println("pixel3D: ", pixelInWorld.toString());
                  println("eyeRay: ", eyeRay.toString());
              }
              
              RaycastHit hit = raycast(eyeRay);
              
              // set the pixel color
              if (hit != null) {
                  color c = shade(hit);
                  set(x, y, c);  // make a tiny rectangle to fill the pixel
              }
          }
      }
  }

  //Contains the logic for shading a single pixel using classical RT with an eye hit.
  private color shade(RaycastHit hit) {
      boolean debug_unlit = false;

      if (debug_unlit) {
          //Ignore lighting (useful for intersection testing)
          return hit.obj.surfaceMat.getColor();
      }

      float lightR = 0;
      float lightG = 0;
      float lightB = 0;
      for (Light l : lights()) {
          Ray shadow_ray = new Ray(hit.intersection.contactPoint, new Vector3(hit.intersection.contactPoint, l.position).normalized());
          
          //Raycast ignores the hit object when casting a shadow.
          RaycastHit shadowHit = raycast(shadow_ray, new HashSet<SceneObject>(Arrays.asList(hit.obj)));
          
          boolean objectBlocksLight = false;
          if (shadowHit != null) {
              //Onlycast shadows if the hit object is between the object and the light source.
              float distToLight = shadow_ray.origin.distanceTo(l.position);
              
              objectBlocksLight = shadowHit.distanceToHit > 0 && shadowHit.distanceToHit < distToLight;
          }
          
          if (!objectBlocksLight) {
              float diffuseStrength = max(0, hit.intersection.normal.dot(shadow_ray.direction));
              
              //Additive Blending for now.
              lightR += l.material.r * diffuseStrength;
              lightG += l.material.g * diffuseStrength;
              lightB += l.material.b * diffuseStrength;
          }
      }
      
      float outR = hit.obj.surfaceMat.r * lightR;
      float outG = hit.obj.surfaceMat.g * lightG;
      float outB = hit.obj.surfaceMat.b * lightB;
      
      return color(outR, outG, outB);
  }

  //Casts a ray into the scene and return the closest object hit.
  public RaycastHit raycast(Ray ray, HashSet<SceneObject> ignored) {
    SceneObject closestObject = null;
    RayIntersectionData intersect = null;
    
    float closestDist = Float.POSITIVE_INFINITY;
    for (SceneObject currObj : _sceneObjects) {
      if (ignored.contains(currObj)) {
        continue;
      }

      RayIntersectionData currIntersect = currObj.intersection(ray);
      if (currIntersect != null) {
        float dist = ray.origin.distanceTo(currIntersect.contactPoint);
        if (dist < closestDist) {
          //Record the closest ray intersection.
          closestDist = dist;
          closestObject = currObj;
          intersect = currIntersect;
        }
      }
    }

    if (closestObject == null) {
      return null;
    } else {
      return new RaycastHit(closestObject, intersect, closestDist);
    }
  }

  public RaycastHit raycast(Ray ray) {
    return raycast(ray, new HashSet<SceneObject>());
  }

  public void addObject(SceneObject ro) {
    _sceneObjects.add(ro);
  }

  public void addLight(Light l) {
    _lights.add(l);
  }

  public void setFOV(float fov) {
    _fovDeg = fov;
    _k = tan(DEG2RAD * _fovDeg / 2);
  }

  public void setBackground(color bg) {
    _background = bg;
  }

  public ArrayList<Light> lights() {
    return _lights;
  }

  public ArrayList<SceneObject> sceneObjects() {
    return _sceneObjects;
  }

  private Point3 screenToWorldPos(int px, int py) {
    float x = ((float) px - width / 2) * _k * 2 / width;
    float y = ((float) py - height / 2) * _k * 2 / height;
    y= -y;  //Flip so that +y points up.
    return new Point3(x, y, -1);
  }
}
