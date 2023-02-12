import java.util.HashSet;

public class Scene {
  final Point3 eye = new Point3(0, 0, 0);

  private ArrayList<Light> _lights = new ArrayList<Light>();
  private ArrayList<SceneObject> _sceneObjects = new ArrayList<SceneObject>();
  private float _fovDeg = 0;
  private float _k = 0; //The number of units between the
  private color _background = color(0, 0, 0);

  private int timer;

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
    reset_timer();
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
    
    print_timer();
  }

  private void reset_timer()
  {
    timer = millis();
  }
  
  private void print_timer()
  {
    int new_timer = millis();
    int diff = new_timer - timer;
    float seconds = diff / 1000.0;
    println ("timer = " + seconds);
  }

  //Contains the logic for shading a single pixel using classical RT with an eye hit.
  private color shade(RaycastHit eyeHit) {
    boolean debug_unlit = false;

    if (debug_unlit) {
      //Ignore lighting (useful for intersection testing)
      return eyeHit.obj.material.getColor();
    }

    float lightR = 0;
    float lightG = 0;
    float lightB = 0;
    for (Light l : lights()) {
      Ray shadowRay = new Ray(eyeHit.contact.point, new Vector3(eyeHit.contact.point, l.position).normalized());

      //Raycast ignores the hit object when casting a shadow.
      RaycastHit shadowHit = raycast(shadowRay);  //Don't ignore the eyeHit object because the shadow ray could pass through it to get to the light.

      boolean objectBlocksLight = false;
      if (shadowHit != null) {
        //Only cast shadows if the hit object is between the object and the light source.
        float distToLight = shadowRay.origin.distanceTo(l.position);
        objectBlocksLight = shadowHit.distance > 0 && shadowHit.distance < distToLight;
      }

      if (!objectBlocksLight) {
        float diffuseStrength = max(0, eyeHit.contact.normal.dot(shadowRay.direction));

        //Additive Blending for now.
        lightR += l.material.r * diffuseStrength;
        lightG += l.material.g * diffuseStrength;
        lightB += l.material.b * diffuseStrength;
      }
    }

    float outR = eyeHit.obj.material.r * lightR;
    float outG = eyeHit.obj.material.g * lightG;
    float outB = eyeHit.obj.material.b * lightB;

    return color(outR, outG, outB);
  }

  //Casts a ray into the scene and return information about the closest object hit.
  public RaycastHit raycast(Ray ray) {
    RaycastHit closestHit = null;
    for (SceneObject currObj : _sceneObjects) {
      RaycastHit hit = currObj.raycast(ray);
      boolean shouldUpdateClosest = hit != null && (closestHit == null || hit.distance < closestHit.distance);
      if (shouldUpdateClosest) {
        closestHit = hit;
      }
    }

    if (closestHit == null) {
      return null;
    } else {
      return closestHit;
    }
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
