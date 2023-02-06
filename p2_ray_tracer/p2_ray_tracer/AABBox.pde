public class AABBox extends RenderObject {
    private Point3 min;
    private Point3 max;
    
    public AABBox(Material surfaceMat, float xmin, float ymin, float zmin, float xmax, float ymax, float zmax) {
        super(surfaceMat);
        min = new Point3(xmin, ymin, zmin);
        max = new Point3(xmax, ymax, zmax);
    }
    
    @Override
    public RayIntersectionData intersection(Ray r) {
        Point3 contactP = getIntersectionPoint(r);
        
        return new RayIntersectionData(contactP, null);
    }
    
    private Point3 getIntersectionPoint(Ray r) {
        //Ray BBox Intersection based on PBR section 4.2.1
        float[] currIntersection = new float[2];
        float[] xInterval = getInterval(min.x, max.x, r.origin.x, r.direction.x);
        currIntersection = xInterval;
        float[] yInterval = getInterval(min.y, max.y, r.origin.y, r.direction.y);
        if (!updateIntersection(currIntersection, yInterval)) {
            return null;
        }
        float[] zInterval = getInterval(min.z, max.z, r.origin.z, r.direction.z);
        if (!updateIntersection(currIntersection, zInterval)) {
            return null;
        }
        
        float t = currIntersection[0];
        if (t < 0) {
            return null;
        }
        
        return r.evaluate(t);
    }
    
    private float[] getInterval(float x1, float x2, float ox, float rDirX) {
        float rDirInv = 1./ rDirX;
        float t1 = (x1 - ox) * rDirInv;
        float t2 = (x2 - ox) * rDirInv;
        
        return t1 > t2 ? new float[] { t2, t1 } : new float[] {t1, t2};   
    }
    
    //returns true if intersection is valid and false if it is invalid
    private boolean updateIntersection(float[] currInt, float[] newInt) {
        currInt[0] = newInt[0] > currInt[0] ? newInt[0] : currInt[0];
        currInt[1] = newInt[1] < currInt[1] ? newInt[1] : currInt[1];
        
        if (currInt[0] > currInt[1]) {
            return false;
        }
        
        return true;
    }
}
