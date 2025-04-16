// Compass.pde - Outil de navigation pour le labyrinthe 3D de la pyramide

float compassSize = 120; // Taille de base de l'affichage de la boussole
PFont compassFont; // Police pour les étiquettes de la boussole

// Initialise la police de la boussole.
void setupCompass() {
  // Create a font for compass labels if needed
  try {
    compassFont = createFont("Arial Bold", 14, true);
  } catch (Exception e) {
    println("Could not create compass font, using default");
  }
}

// Affiche la boussole à l'écran avec des effets 3D et des informations directionnelles.
void drawCompass() {
  // Save current drawing state
  pushStyle();
  pushMatrix();
  
  // Set up 2D mode for overlay
  hint(DISABLE_DEPTH_TEST);
  camera();
  noLights();
  
  float angleToRotate;
  
  // Determine angle based on player state - always calculate an angle
  if (inLab) {
    // Inside labyrinth - use player direction
    float interpDirX = dirX;
    float interpDirY = dirY;
    
    // Handle rotation animation if active
    if (anim > 0 && animR) {
      // Interpolate between old direction and new direction during rotation
      interpDirX = (odirX * anim + dirX * (20 - anim)) / 20.0;
      interpDirY = (odirY * anim + dirY * (20 - anim)) / 20.0;
    }
    
    angleToRotate = atan2(interpDirY, interpDirX);
  } else if (pyramidExterior != null) {
    // Outside the labyrinth - use the player angle from exterior view
    angleToRotate = pyramidExterior.getPlayerAngle();
  } else {
    // Fallback angle 
    angleToRotate = 0;
  }
  
  // Adjust size and position based on player location
  float actualCompassSize;
  float xPos, yPos;
  float textSize;
  
  if (inLab) {
    // Inside the labyrinth - use the specific settings for inside view
    actualCompassSize = compassSize * 2.5;
    xPos = -700;
    yPos = height + 300;
    textSize = 30;
  } else {
    // Outside - normal size, higher position
    actualCompassSize = compassSize;
    xPos = 80;
    yPos = height - 200;
    textSize = 14;
  }
  
  // Position compass
  translate(xPos, yPos);
  
  // Add 3D perspective effect - tilt the compass slightly
  float tiltAngleX = PI/8; // Tilt forward
  float tiltAngleY = -PI/12; // Slight tilt to right
  
  // Apply the 3D tilt
  rotateX(tiltAngleX);
  rotateY(tiltAngleY);
  
  // Define the compass radius
  float radius = actualCompassSize / 2;
  
  // Create the compass base with lighter beige color and gradient
  // Outer dark ring - make it slightly thicker for 3D effect but lighter
  noStroke();
  drawCompassBase(radius, radius * 0.92, color(120, 100, 80), color(140, 120, 100));
  
  // Main compass face with lighter sand-like texture
  drawCompassBase(radius * 0.92, 0, color(250, 240, 215), color(240, 230, 205));
  
  // Add a subtle shadow under the compass
  pushMatrix();
  translate(0, 0, -2); // Move slightly behind the main compass
  fill(0, 0, 0, 30); // Lighter shadow
  ellipse(radius * 0.1, radius * 0.1, radius * 2.1, radius * 2.1);
  popMatrix();
  
  // Draw the notched edge with more depth - lighter color
  drawNotchedEdge(radius, 32, color(120, 100, 80));
  
  // Save position before rotation
  pushMatrix();
  // Rotate to align with player's view direction
  rotate(-angleToRotate + PI/2);
  
  // Draw direction labels
  if (compassFont != null) {
    textFont(compassFont, textSize);
  } else {
    textSize(textSize);
  }
  textAlign(CENTER, CENTER);
  
  // Draw all directional markings
  String[] directions = {"N", "NE", "E", "SE", "S", "SW", "W", "NW"};
  float labelRadius = radius * 0.75;
  
  for (int i = 0; i < directions.length; i++) {
    float angle = i * PI/4;
    float x = sin(angle) * labelRadius;
    float y = -cos(angle) * labelRadius;
    
    // Make N red, others darker brown
    if (directions[i].equals("N")) {
      fill(200, 0, 0);
    } else {
      fill(80, 60, 40);
    }
    
    text(directions[i], x, y);
  }
  
  // Draw cardinal direction triangles (N, S, E, W only)
  stroke(100, 80, 60);
  strokeWeight(1);
  float triangleSize = radius * 0.12;
  
  // North triangle
  fill(200, 0, 0); // Red for North
  drawCardinalTriangle(0, -radius * 0.88, triangleSize, 0);
  
  // East triangle
  fill(80, 60, 40); // Brown for others
  drawCardinalTriangle(radius * 0.88, 0, triangleSize, PI/2);
  
  // South triangle
  drawCardinalTriangle(0, radius * 0.88, triangleSize, PI);
  
  // West triangle
  drawCardinalTriangle(-radius * 0.88, 0, triangleSize, 3*PI/2);
  
  // Draw smaller intermediate ticks
  stroke(100, 80, 60);
  strokeWeight(1);
  for (int i = 0; i < 16; i++) {
    if (i % 2 != 0) {  // Skip the main directions
      float angle = i * PI/8;
      float x1 = sin(angle) * (radius * 0.85);
      float y1 = -cos(angle) * (radius * 0.85);
      float x2 = sin(angle) * (radius * 0.95);
      float y2 = -cos(angle) * (radius * 0.95);
      
      line(x1, y1, x2, y2);
    }
  }
  
  // Draw compass needle with slight elevation for 3D effect
  pushMatrix();
  translate(0, 0, 2); // Raise needle slightly above compass face
  
  // Red north-pointing end
  fill(200, 0, 0);
  noStroke();
  beginShape(TRIANGLES);
  vertex(0, 0);
  vertex(-radius * 0.08, 0);
  vertex(0, -radius * 0.8);
  endShape();
  
  // White south-pointing end
  fill(255);
  beginShape(TRIANGLES);
  vertex(0, 0);
  vertex(radius * 0.08, 0);
  vertex(0, radius * 0.8);
  endShape();
  
  // Small center circle with 3D effect
  fill(240, 240, 240);
  stroke(150);
  strokeWeight(1);
  ellipse(0, 0, radius * 0.15, radius * 0.15);
  
  // Add a small highlight to center for 3D effect
  noStroke();
  fill(255, 255, 255, 150);
  ellipse(-radius * 0.03, -radius * 0.03, radius * 0.05, radius * 0.05);
  
  popMatrix();
  
  popMatrix();
  
  // Restore 3D rendering state
  hint(ENABLE_DEPTH_TEST);
  popMatrix();
  popStyle();
}

// Dessine un triangle pointant dans une direction cardinale (N, S, E, O).
void drawCardinalTriangle(float x, float y, float size, float angle) {
  pushMatrix();
  translate(x, y);
  rotate(angle);
  
  beginShape();
  vertex(0, -size);
  vertex(-size * 0.7, size * 0.5);
  vertex(size * 0.7, size * 0.5);
  endShape(CLOSE);
  
  popMatrix();
}

// Dessine la base de la boussole avec un dégradé de couleurs.
void drawCompassBase(float outerRadius, float innerRadius, color outerColor, color innerColor) {
  int numSegments = 48; // Number of segments to create a smooth circle
  
  beginShape(TRIANGLE_STRIP);
  for (int i = 0; i <= numSegments; i++) {
    float angle = map(i, 0, numSegments, 0, TWO_PI);
    float x1 = cos(angle) * outerRadius;
    float y1 = sin(angle) * outerRadius;
    float x2 = cos(angle) * innerRadius;
    float y2 = sin(angle) * innerRadius;
    
    // Color gradient from outer to inner
    fill(outerColor);
    vertex(x1, y1);
    fill(innerColor);
    vertex(x2, y2);
  }
  endShape();
}

// Dessine un bord cranté autour de la boussole pour un effet visuel.
void drawNotchedEdge(float radius, int numNotches, color notchColor) {
  float notchDepth = radius * 0.05;
  float notchWidth = PI / numNotches;
  
  fill(notchColor);
  beginShape();
  for (int i = 0; i <= numNotches * 2; i++) {
    float angle = i * notchWidth;
    float r = (i % 2 == 0) ? radius : radius - notchDepth;
    vertex(cos(angle) * r, sin(angle) * r);
  }
  endShape(CLOSE);
} 