import java.util.HashSet;

public class RaycastHit {
  public RenderObject obj;
  public Point3 contactPoint;
  public float distanceToHit;

  public RaycastHit(RenderObject obj, Point3 contactPoint, float distanceToHit) {
    this.obj = obj;
    this.contactPoint = contactPoint;
    this.distanceToHit = distanceToHit;
  }
}

public class Scene {
  private ArrayList<Light> _lights = new ArrayList<Light>();
  private ArrayList<RenderObject> _sceneObjects = new ArrayList<RenderObject>();

  public Scene() {
    clear();
  }

  public void clear() {
    _lights.clear();
    _sceneObjects.clear();
  }

  public void addObject(RenderObject ro) {
    _sceneObjects.add(ro);
  }

  public void addLight(Light l) {
    _lights.add(l);
  }

  public ArrayList<Light> lights() {
    return _lights;
  }

  public ArrayList<RenderObject> sceneObjects() {
    return _sceneObjects;
  }

  //cast ray into the scene
  public RaycastHit raycast(Ray ray, HashSet<RenderObject> ignored) {
    RenderObject closestObject = null;
    Point3 hitPoint = null;
    float closestDist = Float.POSITIVE_INFINITY;
    for (RenderObject currObj : _sceneObjects) {
      if (ignored.contains(currObj)) {
        continue;
      }

      Point3 intersection = ray.intersect(currObj.triangle);
      if (intersection != null) {
        float dist = ray.origin.sqDistanceTo(intersection);  //Not taking sqrt for optimization.
        if (dist < closestDist) {
          closestDist = dist;
          closestObject = currObj;
          hitPoint = intersection;
        }
      }
    }

    if (closestObject == null) {
      return null;
    } else {
      return new RaycastHit(closestObject, hitPoint, sqrt(closestDist));
    }
  }

  public RaycastHit raycast(Ray ray) {
    return raycast(ray, new HashSet<RenderObject>());
  }
}
