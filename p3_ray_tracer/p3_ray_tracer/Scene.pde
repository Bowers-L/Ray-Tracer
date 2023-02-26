import java.util.HashSet;

public class Scene {
  final Point3 eye = new Point3(0, 0, 0);

  private ArrayList<Light> _lights = new ArrayList<Light>();
  private ArrayList<SceneObject> _sceneObjects = new ArrayList<SceneObject>();
  private float _fovDeg = 0;
  private float _k = 0;
  private Color _background = new Color(0f, 0f, 0f);
  
  private int _raysPerPixel = 1;
  private Lens _lens = null;

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
      
      //Check that there's a hit, the hit is closer than the previous closest hit, and the hit is in bounds of the ray.
      boolean shouldUpdateClosest = hit != null && (closestHit == null || hit.distance < closestHit.distance);
      //if (shouldUpdateClosest && ray instanceof BoundedRay) {
      //  shouldUpdateClosest = hit.distance < ((BoundedRay) ray).getMaxDist();
      //}
      
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
      
      if (_lens != null) {
        eyeRay = _lens.getNewRandomRay(eyeRay);
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
      BoundedRay shadowRay = l.getShadowRay(eyeHit.contact.point);
      RaycastHit shadowHit = null;
      if (shadowRay != null) {
        shadowHit = raycast(shadowRay);
      }

      boolean castShadow = shadowHit != null || shadowRay == null;
      if (!castShadow) {
        Color contrib = getContributionFromLight(eyeHit.obj.material, l.col, eyeHit.contact.normal, shadowRay.direction, eye.direction.scale(-1));
        out = out.add(contrib);
      }
    }

    return out;
  }
  
  private Color getContributionFromLight(Material objMat, Color lightCol, Vector3 n, Vector3 l, Vector3 e) {
        //Reference: Fundamentals of CG Section 10.2 eq. 10.9
        //DIFFUSE (cr*cl*(n dot l))
        Color contrib = new Color(0f, 0f, 0f);
        
        float diffuseStrength = max(0, n.dot(l));
        Color diffuseC = objMat.diffuse.mult(lightCol.scale(diffuseStrength));  //
        contrib = contrib.add(diffuseC);
        
        //SPECULAR (cp*cl*(h dot n)^pow)
        Vector3 h = e.add(l).normalized();
        float specularStrength = pow(h.dot(n), objMat.specPow);
        Color specularC = objMat.specular.mult(lightCol.scale(specularStrength));
        contrib = contrib.add(specularC);
        
        return contrib;
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
  
  public void addLens(float radius, float focalDist) {
    Vector3 dir = new Vector3(0, 0, -1);
    _lens = new Lens(eye, radius, dir, focalDist);
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
