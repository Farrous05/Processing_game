// Représente un palmier individuel dans l'environnement désertique extérieur.
class PalmTree {
  float x, y;
  float height;
  float trunkWidth;
  int numLeaves;
  float leafSize;
  float swayAngle;
  float swaySpeed;
  PyramidExterior exterior; // Reference to PyramidExterior for terrain height
  float terrainHeight; // Store terrain height at creation time
  
  // Constructeur: Initialise un nouveau palmier avec sa position, ses dimensions et son animation.
  PalmTree(float x, float y, PyramidExterior exterior) {
    this.x = x;
    this.y = y;
    this.exterior = exterior;
    this.height = random(400, 800);
    this.trunkWidth = random(25, 45);
    this.numLeaves = floor(random(8, 15)); // Increased minimum leaf count
    this.leafSize = random(250, 450); // Increased max leaf size
    this.swayAngle = random(TWO_PI);
    this.swaySpeed = random(0.01, 0.04); // Increased max sway speed
    
    // Get terrain height at creation time
    if (exterior != null) {
      this.terrainHeight = exterior.getTerrainHeightAt(x, y);
    }
  }
  
  // Mise à jour: Anime le léger balancement du palmier.
  void update() {
    // Gentle palm tree sway animation - add more sway to match dramatic terrain
    swayAngle += swaySpeed;
    if (swayAngle > TWO_PI) swayAngle -= TWO_PI;
  }
  
  // Affichage: Dessine le palmier (tronc et feuilles) à sa position et avec son animation.
  void display() {
    pushMatrix();
    
    // Position at the base of the tree
    translate(x, y, 0);
    
    // Use the stored terrain height to position tree correctly
    translate(0, 0, terrainHeight);
    
    // Add more pronounced swaying for more dramatic movement
    float sway = sin(swayAngle) * 0.1; // Doubled sway amount
    
    // Draw trunk with more dramatic curve
    drawTrunk(sway);
    
    // Draw leaves at the top
    translate(0, 0, height);
    drawLeaves(sway);
    
    popMatrix();
  }
  
  // Dessine le tronc du palmier avec une courbure et une texture.
  private void drawTrunk(float sway) {
    // Create a more dramatically curved trunk by stacking segments
    int segments = 12; // More segments for smoother curve
    float segmentHeight = height / segments;
    float curveFactor = trunkWidth * 0.8; // MORE curve to match dramatic terrain
    
    noStroke();
    beginShape(TRIANGLE_STRIP);
    
    // Richer brown trunk color with more variation
    fill(110, 65, 30);
    
    // Create trunk as a curved cylinder
    for (int i = 0; i <= segments; i++) {
      float z = i * segmentHeight;
      
      // More dramatic curve, especially in the middle
      float segmentSway = sin(PI * i / segments) * sway * 4; // More curve in the middle
      float xOffset = sin(segmentSway) * curveFactor * (i / float(segments));
      
      // Create a ring of vertices at this height
      for (float angle = 0; angle <= TWO_PI; angle += PI/10) { // More vertices for smoother trunk
        // Add more roughness to the trunk
        float roughness = 5 * noise(angle * 2, i * 0.3); // More pronounced roughness
        float r = trunkWidth/2 - i * (trunkWidth/10)/segments + roughness;
        
        float vx = cos(angle) * r + xOffset;
        float vy = sin(angle) * r;
        
        vertex(vx, vy, z);
        vertex(vx, vy, z + segmentHeight);
      }
      
      // Close the ring
      float angle = 0;
      float roughness = 5 * noise(angle * 2, i * 0.3);
      float r = trunkWidth/2 - i * (trunkWidth/10)/segments + roughness;
      float vx = cos(angle) * r + xOffset;
      float vy = sin(angle) * r;
      
      vertex(vx, vy, z);
      vertex(vx, vy, z + segmentHeight);
    }
    
    endShape();
    
    // Add more trunk texture/details
    for (int i = 0; i < 18; i++) { // More details
      float angle = random(TWO_PI);
      float z = random(height * 0.1, height * 0.9);
      float xOffset = sin(z/height * sway * 3) * curveFactor * (z/height);
      
      pushMatrix();
      translate(cos(angle) * (trunkWidth/2 + 0.5), sin(angle) * (trunkWidth/2 + 0.5), z);
      rotateX(PI/2);
      rotateY(angle);
      fill(90, 50, 20);
      ellipse(0, 0, trunkWidth/3, trunkWidth/1.5);
      popMatrix();
    }
  }
  
  // Dessine la couronne de feuilles du palmier avec une animation de balancement.
  private void drawLeaves(float sway) {
    // Draw a crown of palm leaves with more dynamic motion
    for (int i = 0; i < numLeaves; i++) {
      float angle = map(i, 0, numLeaves, 0, TWO_PI);
      
      // More dramatic upward sweep and sway pattern
      float leafAngle = PI/3 + PI/8 * sin(swayAngle + angle); // More upright
      
      pushMatrix();
      // Rotate around trunk
      rotateZ(angle);
      // Add variable sway based on wind direction
      float windFactor = sin(swayAngle * 1.5 + i * 0.3) * 0.15; // More variable sway
      rotateZ(windFactor); // Leaves shift in wind
      // Angle leaves up/down
      rotateY(leafAngle);
      
      // Draw the leaf as a long, thin shape with more dramatic shape
      drawPalmLeaf(leafSize);
      
      popMatrix();
    }
  }
  
  // Dessine une feuille de palmier individuelle avec des frondes détaillées.
  private void drawPalmLeaf(float length) {
    float width = length * 0.18; // Slightly wider leaves
    
    // Create leaf stem
    stroke(90, 130, 40);
    strokeWeight(6); // Thicker stem
    line(0, 0, 0, length, 0, 0);
    noStroke();
    
    // Create leaf fronds with more detail
    int numFronds = 40; // More fronds for denser leaves
    float frondLength = width * 1.3; // Longer fronds
    
    beginShape(TRIANGLES);
    
    // Richer colors with more variety
    color darkGreen = color(40, 140, 40);
    color lightGreen = color(70, 200, 70);
    
    for (int i = 0; i < numFronds; i++) {
      float pos = map(i, 0, numFronds-1, 0.1, 0.95); // Position along stem
      float stemPos = length * pos;
      
      // More dramatic curved frond lengths
      float frondCurrentLength = frondLength * sin(PI * pos); // Fronds are longer in the middle
      
      // Add color variation along the leaf
      float colorBlend = sin(PI * pos); // 0->1->0 along the length
      fill(lerpColor(darkGreen, lightGreen, colorBlend));
      
      // Left frond - more dramatic angle
      vertex(stemPos, 0, 0);
      vertex(stemPos - frondCurrentLength * 0.3, -frondCurrentLength, 0);
      vertex(stemPos + frondCurrentLength * 0.3, -frondCurrentLength, 0);
      
      // Right frond - more dramatic angle
      vertex(stemPos, 0, 0);
      vertex(stemPos - frondCurrentLength * 0.3, frondCurrentLength, 0);
      vertex(stemPos + frondCurrentLength * 0.3, frondCurrentLength, 0);
      
      // Add smaller overlapping fronds for more density
      if (i > 0 && i < numFronds-1 && i % 2 == 0) {
        float midPos = (pos + map(i-1, 0, numFronds-1, 0.1, 0.95)) / 2;
        float midStemPos = length * midPos;
        float midFrondLength = frondLength * sin(PI * midPos) * 0.7;
        
        // Add middle fronds at half positions
        vertex(midStemPos, 0, 0);
        vertex(midStemPos - midFrondLength * 0.2, -midFrondLength, 0);
        vertex(midStemPos + midFrondLength * 0.2, -midFrondLength, 0);
        
        vertex(midStemPos, 0, 0);
        vertex(midStemPos - midFrondLength * 0.2, midFrondLength, 0);
        vertex(midStemPos + midFrondLength * 0.2, midFrondLength, 0);
      }
    }
    
    // Add tip of the leaf
    fill(40, 160, 40);
    vertex(length, 0, 0);
    vertex(length - width * 0.3, width * 0.3, 0);
    vertex(length - width * 0.3, -width * 0.3, 0);
    
    endShape();
    
    // Add some hanging dead palm fronds for realism (brown/yellow)
    if (random(1) > 0.6) { // 40% chance of having a dead frond
      beginShape(TRIANGLES);
      fill(180, 160, 80); // Yellowish brown dead frond
      
      float deadPos = random(0.3, 0.7); // Position along stem
      float deadStemPos = length * deadPos;
      float deadFrondLength = frondLength * 1.1; // Slightly longer
      
      // Drooping frond pointing more downward
      vertex(deadStemPos, 0, 0);
      vertex(deadStemPos - deadFrondLength * 0.2, deadFrondLength * 1.2, 0);
      vertex(deadStemPos + deadFrondLength * 0.2, deadFrondLength * 1.2, 0);
      
      endShape();
    }
  }
}
