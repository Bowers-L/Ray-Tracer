/*
* Implementation Notes:
* - I used an out of place implementation for partitioning objects into nodes in order to differentiate it from the pbrt implementation.
* - This has the advantage of being simpler to understand and not needing to modify the object list directly, but has a space overhead compared to the in-place implementation.
* - Build time is also slightly slower, but render time remains the same.
*/
public class BVH extends Accelerator {
  
  public class BVHNode {
      public AABBox bbox;
      public BVHNode left;
      public BVHNode right;
      public ArrayList<SceneObject> objects;
      
      public BVHNode(AABBox bbox, BVHNode left, BVHNode right) {
        //Interior Node
        this.bbox = bbox;
        this.left = left;
        this.right = right; 
        this.objects = new ArrayList<SceneObject>();
      }
      
      public BVHNode(AABBox bbox, ArrayList<SceneObject> objects) {
        //Leaf Node
        this.bbox = bbox;
        this.left = null;
        this.right = null;
        this.objects = objects;  
      }
      
      public boolean isLeaf() {
        return left == null && right == null;  
      }
  }

  private BVHNode _root;
  private BVHSplitStrategy _splitMethod;

  public BVH(ArrayList<SceneObject> objects) {
    super(objects);
  }

  @Override
    public void build() {
    _splitMethod = new BVHSplitMidpoint();
    _root = buildBVHTreeRecursive(_objects, 0);
  }

  //Interval of objs is [startI, endI) (endI is exclusive)
  private BVHNode buildBVHTreeRecursive(ArrayList<SceneObject> subtreeObjects, int depth) {
    //STACK OVERFLOW DEBUG
    //numRecursiveCalls++;
    //if (numRecursiveCalls > 1000) {
    //  return null;
    //}
    
    //println(getTabs(depth) + String.format("Start-End: (%d, %d)", startI, endI));
    if (subtreeObjects.isEmpty()) {
      println("Error: Subtree cannot be empty! Partitions should create 2 nonempty sets (or create a leaf if possible).");
      return null;
    }

    AABBox bbox = getBBoxAroundObjects(subtreeObjects);

    if (subtreeObjects.size() <= 1) {
      //BASE CASE (Leaf Node)
      return createLeaf(bbox, subtreeObjects);
    }

    Bounds3.MaxExtentsDim centroidMaxExtents = getCentroidMaxExtentsDimension(subtreeObjects);
    
    if (!centroidMaxExtents.bounds.isValid()) {
      //The object centroids are literally in the exact same place, or a bounds split is otherwise not obtainable (should be rare).
      //In any case we can just create a leaf here.
      return createLeaf(bbox, subtreeObjects);
    }

    ArrayList<ArrayList<SceneObject>> subsets = _splitMethod.split(subtreeObjects, centroidMaxExtents);

    return new BVHNode(bbox, 
      buildBVHTreeRecursive(subsets.get(0), depth+1),
      buildBVHTreeRecursive(subsets.get(1), depth+1)
      );
  }
  
  private Bounds3.MaxExtentsDim getCentroidMaxExtentsDimension(ArrayList<SceneObject> objects) {
    //Partition nodes into two sets and create an interior node with the two children.
    //Use the "maximum extents along centroid" method to determine the dimension to split.
    
    if (objects.size() == 0) {
      throw new IllegalArgumentException("Need at least one object to get centroid extents");
    }
    
    Bounds3 centroidBounds = null;
    for (SceneObject object : objects) {
      centroidBounds = boundsUtil.union(centroidBounds, object.getBoundingBox().getCentroid());
    }
    
    //Non-null as long as objects.size() > 0
    return centroidBounds.maximumExtentsDimension();
  }    
  
  private AABBox getBBoxAroundObjects(ArrayList<SceneObject> objects) {
    AABBox bbox = null;
    for (SceneObject obj : objects) {
      bbox = union(bbox, obj.getBoundingBox());
    }

    return bbox;
  }

  private BVHNode createLeaf(AABBox bbox, ArrayList<SceneObject> objects) {
    return new BVHNode(bbox, objects);
  }

  @Override
    public AABBox getBoundingBox() {
    return _root.bbox;
  }

  @Override
    public RaycastHit raycast(Ray ray) {
    //Do binary search to find the right primitive and raycast against it.

    RaycastHit closestHit = new RaycastHit(null, null, Float.MAX_VALUE);
    raycastRecurse(ray, _root, closestHit, 0, Integer.MAX_VALUE);

    return closestHit.obj == null ? null : closestHit;
  }

  private void raycastRecurse(Ray ray, BVHNode curr, RaycastHit closestHit, int currDepth, int maxDepth) {
    if (curr == null) {
      return;  //This is possible??
    }

    SurfaceContact contact = curr.bbox.intersection(ray);
    
    if (contact != null) {
      if (currDepth >= maxDepth) {
        //Debugging by drawing AABB at depth.
        GeometricObject go = new GeometricObject(curr.bbox, new Material(0.8f, 0.8f, 0.8f));
        updateClosestHit(new RaycastHit(go, contact, ray.origin.distanceTo(contact.point)), closestHit);
      }

      if (curr.isLeaf()) {
        //Raycast against objects in leaf
        for (SceneObject obj : curr.objects) {
          RaycastHit hit = obj.raycast(ray);
          updateClosestHit(hit, closestHit);
        }
      } else {
        raycastRecurse(ray, curr.left, closestHit, currDepth+1, maxDepth);
        raycastRecurse(ray, curr.right, closestHit, currDepth+1, maxDepth);
      }
    }
  }

  private void updateClosestHit(RaycastHit hit, RaycastHit closestHit) {
    //No pointers in Java, so you have to update the obj's properties, not assign to it.
    boolean shouldUpdateClosest = hit != null && (closestHit == null || hit.distance < closestHit.distance);
    if (shouldUpdateClosest) {
      closestHit.obj = hit.obj;
      closestHit.contact = hit.contact;
      closestHit.distance = hit.distance;
    }
  }

  public String toString() {

    //Do an postorder traversal of the tree.
    String result = "Bounding Volume Heirarchy with Nodes: \n\n";

    return updateStringPreorder(result, _root, 0);
  }

  public String updateStringPreorder(String str, BVHNode curr, int depth) {
    String tabs = getTabs(depth);

    if (curr.isLeaf()) {
      str += tabs + String.format(" Leaf Node with BoundingBox: %s\n\n", curr.bbox);
      for (SceneObject obj : curr.objects) {
        str += tabs + obj + "\n\n";
      }
    } else {
      str += tabs + (depth == 0 ? "Root: " : " Internal Node: ") + curr.bbox + "\n";
      str = updateStringPreorder(str, curr.left, depth+1);
      str = updateStringPreorder(str, curr.right, depth+1);
    }

    return str;
  }

  private String getTabs(int depth) {
    String tabs = "";
    for (int i = 0; i < depth; i++) {
      tabs += "\t";  //Indent number of times based on depth
    }
    
    return tabs;
  }

  public abstract class BVHSplitStrategy {

    public abstract ArrayList<ArrayList<SceneObject>> split(ArrayList<SceneObject> objects, Bounds3.MaxExtentsDim maxExtentsDim);
    
    public ArrayList<ArrayList<SceneObject>> createNonEmptyParitition(ArrayList<SceneObject> leftPart, ArrayList<SceneObject> rightPart) {
      //ENSURE BOTH SETS ARE NOT EMPTY!
      //This should only happen if both parts are pretty small, so the O(n) ArrayList remove cost shouldn't matter too much.
      if (leftPart.size() == 0) {
        SceneObject obj = rightPart.remove(0);
        leftPart.add(obj);
      } else if (rightPart.size() == 0) {
        SceneObject obj = leftPart.remove(leftPart.size()-1);
        rightPart.add(obj);
      }
      
      //Annoying Java things to get this return value to work.
      ArrayList<ArrayList<SceneObject>> partition = new ArrayList<ArrayList<SceneObject>>(2);
      partition.add(leftPart);
      partition.add(rightPart);
      return partition;
    }
  }

  public class BVHSplitMidpoint extends BVHSplitStrategy {
    //Partitions buildData within left and right such that all elements at indices below the returned value are to the left of the midpoint.
    public ArrayList<ArrayList<SceneObject>> split(ArrayList<SceneObject> objects, Bounds3.MaxExtentsDim maxExtentsDim) {
      if (objects.size() < 2) {
        throw new IllegalArgumentException("Error: Cannot split less than 2 objects into 2 nonempty subsets. BVH should create a leaf node instead.");
      }
      
      float midpoint = lerp(maxExtentsDim.bounds.lower, maxExtentsDim.bounds.upper, 0.5f);
      
      ArrayList<SceneObject> leftPart = new ArrayList<SceneObject>();
      ArrayList<SceneObject> rightPart = new ArrayList<SceneObject>();
      for (SceneObject obj : objects) {
        float centroidDimValue = obj.getBoundingBox().getCentroid().p(maxExtentsDim.dim);
        if (centroidDimValue < midpoint) {
          leftPart.add(obj);
        } else {
          rightPart.add(obj);
        }
      }

      return createNonEmptyParitition(leftPart, rightPart);
    }
  }

  //Splitting on count is slightly more complicated since Java doesn't come with a standard quicksort method.
}
