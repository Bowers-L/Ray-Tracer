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
    public AABBox bounds;
  }

  public class BVHLeafNode extends BVHNode {
    public int indexOffset;
    public int numObjects;
    public BVHLeafNode(AABBox bounds, int offset, int nObj) {
      this.indexOffset = offset;
      this.numObjects = nObj;
      this.bounds = bounds;
    }
  }

  public class BVHInteriorNode extends BVHNode {
    public int splitAxis;
    public BVHNode[] children = new BVHNode[2];

    public BVHInteriorNode(int splitAxis, BVHNode c0, BVHNode c1) {
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
    _root = buildBVHTreeRecursive(0, _objects.size(), new BVHSplitMidpoint());
  }

  private void initBuildData() {
    _buildData = new ArrayList<SceneObjectData>(_objects.size());  //Allocate enough space initially to hold all the primitives
    for (int i = 0; i < _objects.size(); i++) {
      AABBox bbox = _objects.get(i).getBoundingBox();
      _buildData.add(new SceneObjectData(i, bbox));
    }
  }

  //Interval of objs is [startI, endI) (endI is exclusive)
  private BVHNode buildBVHTreeRecursive(int startI, int endI, BVHSplitStrategy splitStrategy) {
    if (startI >= endI) {
      println("Error: BVH Tree is Empty");
      return null;
    }

    int nObjects = endI - startI;

    AABBox bbox = getBBoxAroundObjects(startI, endI);

    if (nObjects == 1) {
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

    //Use the Midpoint Method to determine a partition
    int midI = splitStrategy.split(_buildData, startI, endI, splitDim, splitBounds);

    return new BVHInteriorNode(splitDim,
      buildBVHTreeRecursive(startI, midI, splitStrategy),
      buildBVHTreeRecursive(midI, endI, splitStrategy)
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

  public AABBox getBoundingBox() {
    return null;
  }

  public RaycastHit raycast(Ray ray) {
    return null;
  }
  
  public String toString() {
    
    //Do an postorder traversal of the tree.
    String result = "Bounding Volume Heirarchy with Nodes: \n\n";
    
    return updateStringPreorder(result, _root, 0);
  }
  
  public String updateStringPreorder(String str, BVHNode curr, int depth) {
    String tabs = "";
    for (int i = 0; i < depth; i++) {
      tabs += "\t";  //Indent number of times based on depth
    }
    if (curr instanceof BVHLeafNode) {
      BVHLeafNode leaf = (BVHLeafNode) curr;
      str += tabs + " Leaf Node with objects: \n";
      for (int i = leaf.indexOffset; i < leaf.indexOffset+leaf.numObjects; i++) {
        str += tabs + _objectsInOrder.get(i) + "\n";  
      }
    } else {
      str += tabs + " Internal Node: \n";
    }
    
    if (curr instanceof BVHInteriorNode) {
      BVHInteriorNode interior = (BVHInteriorNode) curr;
      
      str += updateStringPreorder(str, interior.children[0], depth+1);
      str += updateStringPreorder(str, interior.children[1], depth+1); 
    }
    
    return str;
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
}
