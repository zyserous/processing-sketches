import peasy.*;

float[] xs, ys, zs;
PeasyCam cam;

int SIDE_LENGTH = 20;

void setup() {
  size(800, 600, P3D);
  cam = new PeasyCam(this, 400);
  
  xs = new float[SIDE_LENGTH * SIDE_LENGTH * SIDE_LENGTH];
  ys = new float[xs.length];
  zs = new float[xs.length];
  
  float x = 0;
  float y = 0;
  float z = 0;
  
  float moveDist = 3;
  
  for (int i = 0; i < xs.length; i++) {
    //float x2 = sin(map(i, 0, xs.length, 0, TWO_PI * 100)) * width / 2;
    //float y2 = cos(map(i, 0, xs.length, 0, TWO_PI * 100)) * width / 2;
    float x2 = x + random(-moveDist, moveDist);
    float y2 = y + random(-moveDist, moveDist);
    float z2 = map(i, 0, xs.length, 0, 600);
    
    x = x2;
    y = y2;
    z = z2;
    
    xs[i] = x;
    ys[i] = y;
    zs[i] = z;
  }
  float centerX = sort(xs)[xs.length / 2];
  float centerY = sort(ys)[ys.length / 2];
  float centerZ = sort(zs)[zs.length / 2];
  cam.lookAt(centerX, centerY, centerZ);
}

void draw() {
  background(255);
  strokeCap(ROUND);
  hint(DISABLE_DEPTH_TEST);
  
  cameraPosition = cam.getPosition(); // the camera is at (cx, cy, cz)
  
  lineThickness = 5;
  focalDistance = mouseX;
  //focalDistance = map(
  //blurFactor = map(mouseY, 0, height, 0, 20);
  blurFactor = 20;
  
  for (int i = 0; i < xs.length; i++) {
    float x = xs[i];
    float y = ys[i];
    float z = zs[i];
    
    float gridX = i % SIDE_LENGTH * 10;
    float gridY = (i / SIDE_LENGTH) % SIDE_LENGTH * 10;
    float gridZ = i / (SIDE_LENGTH * SIDE_LENGTH) * 10;
    
    float lerpAmount = 0;
    colorMode(HSB);
    color c = color(map(i, 0, xs.length, 100, 150), 255, 255);
    dofPoint(lerp(x, gridX, lerpAmount), lerp(y, gridY, lerpAmount), lerp(z, gridZ, lerpAmount), c);
  }
  
  //stroke(255, 0, 0);
  //line(0, 0, 0, 100, 0, 0);
  //stroke(0, 255, 0);
  //line(0, 0, 0, 0, 100, 0);
  //stroke(0, 0, 255);
  //line(0, 0, 0, 0, 0, 100);
}

float[] cameraPosition;

float lineThickness; 
float focalDistance;
float blurFactor;

void dofLine(float x, float y, float z, float x2, float y2, float z2) {
  float midX = (x + x2) / 2;
  float midY = (y + y2) / 2;
  float midZ = (z + z2) / 2;
  float distanceToCamera = dist(cameraPosition[0], cameraPosition[1], cameraPosition[2], midX, midY, midZ);
  // we want this to be 0 at focalPoint, and increase as the distance from the focal distance increases
  float dofDistance = distanceToCamera / focalDistance;
  float blurDistance = abs(distanceToCamera - focalDistance); // ranges from 0 to like 500
  float blurAmount = blurDistance / focalDistance * blurFactor; // 0 = no blur at all, 1 = blur to twice its size
  
   // draw a line in 3d space. Points way from the blurAmount are more translucent but also bigger and blurrier
  float percievedThickness = lineThickness / dofDistance;
  //float percievedThickness = lineThickness;
  // lines at the dof are fully opaque, but blurrier lines have more opacity
  float opacity = min(1, 1 / (1 + blurAmount));
  //println(opacity);
  stroke(0, opacity * 255);
  strokeWeight(percievedThickness); // note that the perspective projection already divides by distance; we scale it again to simulate dof blur
  line(x, y, z, x2, y2, z2);
}

void dofPoint(float x, float y, float z, color c) {
  // distance from point to camera
  float pointDistance = dist(cameraPosition[0], cameraPosition[1], cameraPosition[2], x, y, z);
  float distanceToFocalPoint = abs(pointDistance - focalDistance); // ranges from 0 to like 500
  float blurAmount = distanceToFocalPoint / focalDistance * blurFactor; // 0 = no blur at all, 1 = blur to twice its size
  
  //// we want this to be 0 at focalPoint, and increase as the distance from the focal distance increases
  float dofDistance = pointDistance / focalDistance;
  
   // draw a line in 3d space. Points way from the blurAmount are more translucent but also bigger and blurrier
  //float percievedThickness = lineThickness * (1 + blurAmount);
  float percievedThickness = lineThickness / dofDistance; // this feels right
  //float percievedThickness = lineThickness;
  // lines at the dof are fully opaque, but blurrier lines have more opacity
  float opacity = 1 / (1 + blurAmount); // this makes far away things too blurry and close things too opaque
  //float opacity;
  //if (dofDistance < 1) {
  //  opacity = 1 / (1 + blurAmount);
  //} else {
  //  opacity = 1 / (1 + blurAmount / blurFactor);
  //}
  
  stroke(c, opacity * 255);
  strokeWeight(percievedThickness); // note that the perspective projection already divides by distance; we scale it again to simulate dof blur
  point(x, y, z);
  //strokeWeight(1);
  //text(percievedThickness + ", " + opacity, x, y, z);
  //text(dofDistance +", " + blurDistance +", " + blurAmount + ", " + opacity, x, y, z);
}