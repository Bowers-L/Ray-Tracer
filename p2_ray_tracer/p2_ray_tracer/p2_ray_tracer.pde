// This is the starter code for the CS 6491 Ray Tracing project.
//
// The most important part of this code is the interpreter, which will
// help you parse the scene description (.cli) files.

import java.util.Arrays;
import java.util.HashMap;

final String p1b_dir = "P1B/";
final String p2_dir = "";
final String[] p1b_scenes = {"s1.cli", "s2.cli", "s3.cli", "s4.cli", "s5.cli", "s6.cli"};
final String[] p2_scenes = {"s01.cli", "s02.cli", "s03.cli", "s04.cli", "s05.cli", "s06.cli", "s07.cli", "s08.cli", "s09.cli", "s10.cli", "s11.cli"};

boolean debug_flag = false;

final Point3 eye = new Point3(0, 0, 0);

//Scene Data
float _fov = 0;
float _k = 0;
color _background = color(0, 0, 0);
Scene _mainScene = new Scene();
HashMap<String, SceneObject> _namedObjects = new HashMap<String, SceneObject>();
MatStack _matrixStack = new MatStack();

SceneInterpreter _interpreter = new SceneInterpreter(p2_dir, p2_scenes);

void setup() {
    size(300, 300);
    noStroke();
    background(_background);
    colorMode(RGB, 1.0);
}

void keyPressed() {
    reset_scene();
    switch(key) {
        case '1':
            _interpreter.interpretSceneAtIndex(0);
            break;
        case '2':
            _interpreter.interpretSceneAtIndex(1);
            break;
        case '3':
            _interpreter.interpretSceneAtIndex(2);
            break;
        case '4':
            _interpreter.interpretSceneAtIndex(3);
            break;
        case '5':
            _interpreter.interpretSceneAtIndex(4);
            break;
        case '6':
            _interpreter.interpretSceneAtIndex(5);
            break;
        case '7':
            _interpreter.interpretSceneAtIndex(6);
            break;
        case '8':
            _interpreter.interpretSceneAtIndex(7);
            break;
        case '9':
            _interpreter.interpretSceneAtIndex(8);
            break;
        case '0':
            _interpreter.interpretSceneAtIndex(9);
            break;
        case 'a':
            _interpreter.interpretSceneAtIndex(10);
            break;
    }
}

void reset_scene() {
    //reset your scene variables here
    _background = color(0, 0, 0);
    _mainScene = new Scene();
    _matrixStack = new MatStack();
}

// This is where you should put your code for creating eye rays and tracing them.
void draw_scene() {
    background(_background);
    
    for (int y = 0; y < height; y++) {
        for (int x = 0; x < width; x++) {
            
            // Maybe set debug flag true for ONE pixel.
            // Have your routines (like ray/triangle intersection)
            // print information when this flag is set.
            debug_flag = false;
            //if (x == 150 && y == 140)
            //debug_flag = true;
            
            // create and cast an eye ray
            Point3 pixel3D = pixelTo3DPoint(x, y);
            Ray eyeRay = new Ray(eye, new Vector3(eye, pixel3D));
            
            if (debug_flag) {
                println("pixel3D: ", pixel3D.toString());
                println("eyeRay: ", eyeRay.toString());
            }
            
            RaycastHit hit = _mainScene.raycast(eyeRay);
            
            // set the pixel color
            if (hit != null) {
                color c = shade(hit);
                set(x, y, c);  // make a tiny rectangle to fill the pixel
            }
        }
    }
}

private color shade(RaycastHit hit) {
    boolean debug_unlit = false;

    if (debug_unlit) {
        //Ignore lighting (useful for intersection testing)
        return hit.obj.surfaceMat.getColor();
    }

    float lightR = 0;
    float lightG = 0;
    float lightB = 0;
    for (Light l : _mainScene.lights()) {
        Ray shadow_ray = new Ray(hit.intersection.contactPoint, new Vector3(hit.intersection.contactPoint, l.position).normalized());
        
        //Raycast ignores the hit object when casting a shadow.
        RaycastHit shadowHit = _mainScene.raycast(shadow_ray, new HashSet<SceneObject>(Arrays.asList(hit.obj)));
        
        boolean objectBlocksLight = false;
        if (shadowHit != null) {
            //Onlycast shadows if the hit object is between the object and the light source.
            float distToLight = shadow_ray.origin.distanceTo(l.position);
            
            objectBlocksLight = shadowHit.distanceToHit > 0 && shadowHit.distanceToHit < distToLight;
        }
        
        if (!objectBlocksLight) {
            float diffuseStrength = max(0, hit.intersection.normal.dot(shadow_ray.direction));
            
            //Additive Blending for now.
            lightR += l.material.r * diffuseStrength;
            lightG += l.material.g * diffuseStrength;
            lightB += l.material.b * diffuseStrength;
        }
    }
    
    float outR = hit.obj.surfaceMat.r * lightR;
    float outG = hit.obj.surfaceMat.g * lightG;
    float outB = hit.obj.surfaceMat.b * lightB;
    
    return color(outR, outG, outB);
}

private Point3 pixelTo3DPoint(float x, float y) {
    float xp = (x - width / 2) * _k * 2 / width;
    float yp = (y - height / 2) * _k * 2 / height;
    yp= -yp;  //Flip so that +y points up.
    return new Point3(xp, yp, -1);
}

// prints mouse location clicks, for help debugging
void mousePressed() {
    println("You pressed the mouse at " + mouseX + " " + mouseY);
}

// you don't need to add anything here
void draw() {
}
