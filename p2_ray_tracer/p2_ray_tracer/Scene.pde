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
  private ArrayList<Light> _lights = new ArrayList<Light>();
  private ArrayList<SceneObject> _sceneObjects = new ArrayList<SceneObject>();

  public Scene() {
    clear();
  }

  public void clear() {
    _lights.clear();
    _sceneObjects.clear();
  }

  public void addObject(SceneObject ro) {
    _sceneObjects.add(ro);
  }

  public void addLight(Light l) {
    _lights.add(l);
  }

  public ArrayList<Light> lights() {
    return _lights;
  }

  public ArrayList<SceneObject> sceneObjects() {
    return _sceneObjects;
  }

  //cast ray into the scene
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
}
