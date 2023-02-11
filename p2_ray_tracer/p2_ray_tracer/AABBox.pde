public class AABBox extends Primitive {
    private Point3 min;
    private Point3 max;
    
    public class Bounds {
      public float lower;
      public float upper;
      
      public Bounds(float lower, float upper) {
        this.lower = lower;
        this.upper = upper;
      }
      
      //returns true if intersection is valid and false if it is invalid
      public Bounds intersection(Bounds other) {

          //Increase the lower bound up (if possible)
          float intersectLower = other.lower > this.lower ? other.lower : this.lower;
          
          //Decrease the upper bound (if possible)
          float intersectUpper = other.upper < this.upper ? other.upper : this.upper;
          
          Bounds intersection = new Bounds(intersectLower, intersectUpper);
          
          boolean isValidIntersection = intersection.lower <= intersection.upper;
          if (!isValidIntersection) {
              return null;
          }
          
          return intersection;
      }
    }
    
    public AABBox(Material surfaceMat, Point3 min, Point3 max) {
        super(surfaceMat);
        this.min = min;
        this.max = max;
    }
    
    @Override
    public RayIntersectionData intersection(Ray r) {
        Point3 contactP = getIntersectionPoint(r);
        return contactP == null ? null : new RayIntersectionData(contactP, getNormal(r, contactP));
    }
    
    @Override
    public void transform(Mat4f transMat) {
        min = transMat.multiply(min);
        max = transMat.multiply(max);  
    }
    
    @Override
    public AABBox getBoundingBox() {
      return this;
    } 
    
    public Vector3 halfExtents() {
      Vector3 halfExtents = new Vector3(min, max);
      return halfExtents.scale(0.5);
    }
    
    public Point3 center() {
      return min.add(halfExtents());  
    }
    
    private Point3 getIntersectionPoint(Ray r) {
        //Ray BBox Intersection based on PBR section 4.2.1
        
        Bounds tBoundsX = getRayTBounds(min.x, max.x, r.origin.x, r.direction.x);
        Bounds tBoundsY = getRayTBounds(min.y, max.y, r.origin.y, r.direction.y);
        Bounds tBoundsXY = tBoundsX.intersection(tBoundsY);
        if (tBoundsXY == null) {
            return null;
        }
        
        Bounds tBoundsZ = getRayTBounds(min.z, max.z, r.origin.z, r.direction.z);
        Bounds tBoundsXYZ = tBoundsXY.intersection(tBoundsZ);
        if (tBoundsXYZ == null) {
            return null;
        }
        
        float t = tBoundsXYZ.lower;
        if (t < 0) {
            return null;
        }
        
        return r.evaluate(t);
    }
    
    private Vector3 getNormal(Ray ray, Point3 contactP) {
      //Translate the box to (0, 0, 0)
      Vector3 centerToOrigin = new Vector3(center(), new Point3(0, 0, 0));
      Point3 contactPObjSpace = contactP.add(centerToOrigin);
      
      Vector3 halfBoxSize = halfExtents();
      
      //Scale min and max to unit box
      //0/0 situation means the box is actually a plane (or a line), so normal points in that direction
      float normalizedX = halfBoxSize.x == 0 ? 1 : contactPObjSpace.x / halfBoxSize.x;
      float signX = normalizedX < 0 ? -1 : 1;
      float normalizedY = halfBoxSize.y == 0 ? 1 : contactPObjSpace.y / halfBoxSize.y;
      float signY = normalizedY < 0 ? -1 : 1;
      float normalizedZ = halfBoxSize.z == 0 ? 1 : contactPObjSpace.z / halfBoxSize.z;
      float signZ = normalizedZ < 0 ? -1 : 1;
      
      //Add float delta, trunctate by casting to float then int.
      float epsilon = 0.001;
      Vector3 normal = new Vector3(
        truncate(normalizedX + signX * epsilon), 
        truncate(normalizedY + signY * epsilon), 
        truncate(normalizedZ + signZ * epsilon));
      
      return normal;
    }
    
    private Bounds getRayTBounds(float x1, float x2, float ox, float rDirX) {
      //t = (x - a_x) / b_x
        float rDirInv = 1./ rDirX;
        float t1 = (x1 - ox) * rDirInv;
        float t2 = (x2 - ox) * rDirInv;
        
        return t1 > t2 ? new Bounds(t2, t1) : new Bounds(t1, t2);   
    }
}
