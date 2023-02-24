import java.util.HashSet;

public class Scene {
  final Point3 eye = new Point3(0, 0, 0);

  private ArrayList<Light> _lights = new ArrayList<Light>();
  private ArrayList<SceneObject> _sceneObjects = new ArrayList<SceneObject>();
  private float _fovDeg = 0;
  private float _k = 0;
  private Color _background = new Color(0f, 0f, 0f);
  private int _raysPerPixel = 1;

  private int renderTimer;

  public Scene() {
    reset();
  }

  public void reset() {
    _background = new Color(0f, 0f, 0f);
    setFOV(0);
    _lights.clear();
    _sceneObjects.clear();
  }

  // Go through all pixels and draw the scene using Ray Tracing.
  public void render() {
    reset_timer();
    background(_background.getColor());

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {

        // Maybe set debug flag true for ONE pixel.
        // Have your routines (like ray/triangle intersection)
        // print information when this flag is set.
        debug_flag = false;
        //if (x == 150 && y == 140)
        //debug_flag = true;

        // create and cast an eye ray
        Color shadedPixel = null;
        if (_raysPerPixel > 1) {
          shadedPixel = getPixelColorAntiAliased(x, y);
        } else {
          shadedPixel = getPixelColorSingleRaycast(x, y);  
        }
        
        if (shadedPixel != null) {
          set(x, y, shadedPixel.getColor());
        }    
      }
    }
    
    print_timer(renderTimer, "Render Time");
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
  
  private Color getPixelColorSingleRaycast(float x, float y) {
      Point3 pixelInWorld = screenToWorldPos(x, y);
      Ray eyeRay = new Ray(eye, new Vector3(eye, pixelInWorld));     
      
      for (SceneObject s : _sceneObjects) {
        s.perPixelRay();
      }
      RaycastHit hit = raycast(eyeRay);
      
      return hit == null ? null : shadeEyeHit(eyeRay, hit);
  }
  
  private Color getPixelColorAntiAliased(float x, float y) {
      Color avgColor = _background;
      for (int i = 0; i < _raysPerPixel; i++) {
        float rx = random(1f);
        float ry = random(1f);
        
        Color c = getPixelColorSingleRaycast(x+rx, y+ry);
        
        if (c == null) {
          avgColor = avgColor.add(_background);  
        } else {
          avgColor = avgColor.add(c);  
        }
      } 
      
      //"Box Filter"
      return avgColor==null ? null : avgColor.scale(1./_raysPerPixel);
  }

  //Contains the logic for shading a single pixel given an eye hit.
  private Color shadeEyeHit(Ray eye, RaycastHit eyeHit) {
    boolean debug_unlit = false;

    if (debug_unlit) {
      //Ignore lighting (useful for intersection testing)
      return eyeHit.obj.material.diffuse;
    }

    Color out = new Color(0, 0, 0);
    for (Light l : lights()) {
      Ray shadowRay = new Ray(eyeHit.contact.point, new Vector3(eyeHit.contact.point, l.position).normalized());
      RaycastHit shadowHit = raycast(shadowRay);

      boolean objectBlocksLight = false;
      if (shadowHit != null) {
        //Only cast shadows if the hit object is between the object and the light source.
        float distToLight = shadowRay.origin.distanceTo(l.position);
        objectBlocksLight = shadowHit.distance < distToLight;
      }

      if (!objectBlocksLight) {
        Material objMat = eyeHit.obj.material;
        Material lightMat = l.material;
        Vector3 n = eyeHit.contact.normal;
        Vector3 ldir = shadowRay.direction;
        Vector3 e = eye.direction.scale(-1);
        
        //Reference: Fundamentals of CG Section 10.2 eq. 10.9
        
        //DIFFUSE (cr*cl*(n dot l))
        float diffuseStrength = max(0, n.dot(ldir));
        Color diffuseC = objMat.diffuse.mult(lightMat.diffuse.scale(diffuseStrength));  //
        out = out.add(diffuseC);
        
        //SPECULAR (cp*cl*(h dot n)^pow)
        Vector3 h = e.add(ldir).normalized();
        float specularStrength = pow(h.dot(n), objMat.specPow);
        Color specularC = objMat.specular.mult(lightMat.diffuse.scale(specularStrength));
        out = out.add(specularC);
      }
    }

    return out;
  }
  
  private void reset_timer()
  {
    renderTimer = millis();
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

  public void setBackground(Color bg) {
    _background = bg;
  }
  
  public void setRaysPerPixel(int rpp) {
    _raysPerPixel = rpp;  
  }

  public ArrayList<Light> lights() {
    return _lights;
  }

  public ArrayList<SceneObject> sceneObjects() {
    return _sceneObjects;
  }

  private Point3 screenToWorldPos(float px, float py) {
    float x = (px - width / 2) * _k * 2 / width;
    float y = (py - height / 2) * _k * 2 / height;
    y= -y;  //Flip so that +y points up.
    return new Point3(x, y, -1);
  }
}
