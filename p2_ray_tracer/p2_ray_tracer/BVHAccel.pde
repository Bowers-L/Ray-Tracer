public class BVHAccel extends Accelerator {

  //Reference: PBR 4.4.1: BVHPrimitiveInfo
  //Instead of storing objects directly in nodes, we store an index into the object array and pre-calculate the bounding box.
  public class SceneObjectData {
    public int index;
    public AABBox bbox;
    public Point3 centroid;

    public SceneObjectData(int index, AABBox bbox) {
      this.index = index;
      this.bbox = bbox;
      this.centroid = bbox.getCentroid();
    }
  }

  public abstract class BVHNode {
    //A leaf node is defined as numObjects > 0.
    public AABBox bbox;
  }

  public class BVHLeafNode extends BVHNode {
    public int indexOffset;
    public int numObjects;
    public BVHLeafNode(AABBox bbox, int offset, int nObj) {
      this.indexOffset = offset;
      this.numObjects = nObj;
      this.bbox = bbox;
    }
  }

  public class BVHInteriorNode extends BVHNode {
    public int splitAxis;
    public BVHNode[] children = new BVHNode[2];

    public BVHInteriorNode(AABBox bbox, int splitAxis, BVHNode c0, BVHNode c1) {
      this.bbox = bbox;
      this.splitAxis = splitAxis;
      this.children[0] = c0;
      this.children[1] = c1;
    }
  }

  private ArrayList<SceneObjectData> _buildData;
  private ArrayList<SceneObject> _objectsInOrder;
  private BVHNode _root;

  public BVHAccel(ArrayList<SceneObject> objects) {
    super(objects);
  }

  @Override
    public void build() {
    //Initialize object data.
    initBuildData();
    _objectsInOrder = new ArrayList<SceneObject>();
    println("Num Objects to do: " + _objects.size()); 
    
    //iterations = 0;
    _root = buildBVHTreeRecursive(0, _objects.size(), new BVHSplitMidpoint(), 0);
  }

  private void initBuildData() {
    _buildData = new ArrayList<SceneObjectData>(_objects.size());  //Allocate enough space initially to hold all the primitives
    for (int i = 0; i < _objects.size(); i++) {
      AABBox bbox = _objects.get(i).getBoundingBox();
      _buildData.add(new SceneObjectData(i, bbox));
    }
  }

  //Interval of objs is [startI, endI) (endI is exclusive)
  //int iterations;
  private BVHNode buildBVHTreeRecursive(int startI, int endI, BVHSplitStrategy splitStrategy, int depth) {
    //iterations++;
    //if (iterations > 1000) {
    //  return null;
    //}
    
    println(getTabs(depth) + String.format("Start-End: (%d, %d)", startI, endI));
    if (startI > endI) {
      //println("Error: BVH Tree is Empty");
      return null;
    }

    int nObjects = endI - startI;

    AABBox bbox = getBBoxAroundObjects(startI, endI);

    if (nObjects <= 1) {
      //BASE CASE (Leaf Node)
      return createLeaf(bbox, startI, endI);
    }

    //Partition nodes into two sets and create an interior node with the two children.
    //Use the "maximum extents along centroid" method in section 4.4 to determine the dimension to split
    Bounds3 centroidBounds = null;
    for (int i = startI; i < endI; i++) {
      centroidBounds = union(centroidBounds, _buildData.get(i).centroid);
    }
    int splitDim = centroidBounds.maximumExtentsDimension();

    Bounds1 splitBounds = new Bounds1(centroidBounds.min.p(splitDim), centroidBounds.max.p(splitDim));
    if (!splitBounds.isValid()) {
      //Just put everything into a leaf node.
      return createLeaf(bbox, startI, endI);
    }

    int midI = splitStrategy.split(_buildData, startI, endI, splitDim, splitBounds);
    
    //EMPTY SETS ARE NOT ALLOWED!!!
    if (startI == midI) {
      midI++;
    } else if (midI == endI) {
      midI--;
    }

    return new BVHInteriorNode(bbox, splitDim,
      buildBVHTreeRecursive(startI, midI, splitStrategy, depth+1),
      buildBVHTreeRecursive(midI, endI, splitStrategy, depth+1)
      );
  }

  private AABBox getBBoxAroundObjects(int startI, int endI) {
    AABBox bbox = null;
    for (int i = startI; i < endI; i++) {
      bbox = union(bbox, _buildData.get(i).bbox);
    }

    return bbox;
  }

  private BVHLeafNode createLeaf(AABBox bbox, int startI, int endI) {
    int offset = _objectsInOrder.size();
    for (int i = startI; i < endI; i++) {
      int objIndex = _buildData.get(i).index;
      _objectsInOrder.add(_objects.get(objIndex));
    }

    return new BVHLeafNode(bbox, offset, endI - startI);
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
        //Debugging
        GeometricObject go = new GeometricObject(curr.bbox, new Material(0.8f, 0.8f, 0.8f));
        updateClosestHit(new RaycastHit(go, contact, ray.origin.distanceTo(contact.point)), closestHit);
      }

      if (curr instanceof BVHLeafNode) {
        BVHLeafNode leaf = (BVHLeafNode) curr;
        for (int i = leaf.indexOffset; i < leaf.indexOffset + leaf.numObjects; i++) {
          SceneObject obj = _objectsInOrder.get(i);
          RaycastHit hit = obj.raycast(ray);

          updateClosestHit(hit, closestHit);
        }
      } else {
        BVHInteriorNode interior = (BVHInteriorNode) curr;
        raycastRecurse(ray, interior.children[0], closestHit, currDepth+1, maxDepth);
        raycastRecurse(ray, interior.children[1], closestHit, currDepth+1, maxDepth);
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

    if (curr instanceof BVHLeafNode) {
      BVHLeafNode leaf = (BVHLeafNode) curr;
      str += tabs + String.format(" Leaf Node with BoundingBox: %s\n\n", curr.bbox);
      for (int i = leaf.indexOffset; i < leaf.indexOffset+leaf.numObjects; i++) {
        str += tabs + _objectsInOrder.get(i) + "\n\n";
      }
    } else {
      str += tabs + (depth == 0 ? "Root: " : " Internal Node: ") + curr.bbox + "\n";
    }

    if (curr instanceof BVHInteriorNode) {
      BVHInteriorNode interior = (BVHInteriorNode) curr;

      str = updateStringPreorder(str, interior.children[0], depth+1);
      str = updateStringPreorder(str, interior.children[1], depth+1);
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

    public abstract int split(ArrayList<BVHAccel.SceneObjectData> buildData, int left, int right, int splitDim, Bounds1 splitBounds);
  }

  public class BVHSplitMidpoint extends BVHSplitStrategy {
    //Partitions buildData within left and right such that all elements at indices below the returned value are to the left of the midpoint.
    public int split(ArrayList<SceneObjectData> buildData, int left, int right, int splitDim, Bounds1 splitBounds) {
      float midpoint = lerp(splitBounds.lower, splitBounds.upper, 0.5f);


      return hoarePartition(buildData, left, right,
        (objectData) -> (objectData.centroid.p(splitDim) < midpoint) );
    }
  }

  //Splitting on count is slightly more complicated since Java doesn't come with a standard quicksort method like C++
}
