public class AABBox extends SceneObject {
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
      private boolean updateIntersection(Bounds newBounds) {
          //Increase the lower bound up (if possible)
          this.lower = newBounds.lower > this.lower ? newBounds.lower : this.lower;
          
          //Decrease the upper bound (if possible)
          this.upper = newBounds.upper < this.upper ? newBounds.upper : this.upper;
          
          //Lower bound should not exceed upper bound
          if (this.lower > this.upper) {
              return false;
          }
          
          return true;
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
        Bounds tBounds = tBoundsX;
        
        Bounds tBoundsY = getRayTBounds(min.y, max.y, r.origin.y, r.direction.y);
        if (!tBounds.updateIntersection(tBoundsY)) {
            return null;
        }
        
        Bounds tBoundsZ = getRayTBounds(min.z, max.z, r.origin.z, r.direction.z);
        if (!tBounds.updateIntersection(tBoundsZ)) {
            return null;
        }
        
        float t = tBounds.lower;
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
      Vector3 normal = new Vector3(
        truncate(normalizedX + signX * 0.001), 
        truncate(normalizedY + signY * 0.001), 
        truncate(normalizedZ + signZ * 0.001));
      
      //println("Contact Point: ", contactP);
      //println("Contact Point Obj: ", contactPObjSpace);
      //println("Normalized: ", new Float3(normalizedX, normalizedY, normalizedZ));
      //println("Result: " + result);
      return getOrientedNormal(ray, normal);
    }
    
    private Bounds getRayTBounds(float x1, float x2, float ox, float rDirX) {
      //t = (x - a_x) / b_x
        float rDirInv = 1./ rDirX;
        float t1 = (x1 - ox) * rDirInv;
        float t2 = (x2 - ox) * rDirInv;
        
        return t1 > t2 ? new Bounds(t2, t1) : new Bounds(t1, t2);   
    }
}
