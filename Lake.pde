// Représente un lac ou une oasis dans l'environnement désertique extérieur.
class Lake {
  float x, y;           // Center position
  float width, length;  // Dimensions
  float depth;          // Visual depth for rendering
  ArrayList<PVector> shorePoints; // Points defining the shore's irregular shape
  int resolution;       // Number of points around the perimeter
  PImage waterTexture;  // The water texture to use
  PyramidExterior exterior; // Reference to PyramidExterior for terrain height
  float terrainHeight;  // Store terrain height at creation time
  
  // Constructeur: Initialise un nouveau lac avec sa position, sa taille, sa texture et génère sa rive.
  Lake(float x, float y, float size, PImage waterTexture, PyramidExterior exterior) {
    this.x = x;
    this.y = y;
    this.width = size * random(0.8, 1.2);  // Slight variation in width
    this.length = size * random(0.8, 1.2); // Slight variation in length
    this.depth = random(25, 40);           // Increased depth for better visual effect (was 15-30)
    this.resolution = floor(size / 15);    // More points for larger lakes
    if (this.resolution < 12) this.resolution = 12;
    this.waterTexture = waterTexture;      // Store the water texture
    this.exterior = exterior;
    
    // Get terrain height at creation time
    if (exterior != null) {
      this.terrainHeight = exterior.getTerrainHeightAt(x, y);
    }
    
    // Generate irregular shore
    generateShorePoints();
  }
  
  // Génère les points définissant la forme irrégulière de la rive du lac.
  void generateShorePoints() {
    shorePoints = new ArrayList<PVector>();
    
    for (int i = 0; i < resolution; i++) {
      float angle = TWO_PI * i / resolution;
      // Create irregular shore with noise
      float noiseVal = 0.7 + 0.3 * noise(cos(angle) * 1.5, sin(angle) * 1.5);
      float radius = (i % 2 == 0 ? width : length) * 0.5 * noiseVal;
      
      float px = x + cos(angle) * radius;
      float py = y + sin(angle) * radius;
      
      shorePoints.add(new PVector(px, py));
    }
  }
  
  // Affichage: Dessine le lac avec son eau, sa rive et des effets visuels comme des vagues.
  void display() {
    pushMatrix();
    pushStyle();
    
    // Disable stroke to avoid black lines
    noStroke();
    
    // Position lakes slightly below the terrain
    // Always position at a consistent height relative to terrain for visibility
    translate(x, y, terrainHeight - 7);  // 7 units below terrain for better visibility
    
    // Create a more vibrant blue color for lakes
    fill(0, 150, 255, 240);  // Slightly more opaque vibrant blue
    
    // Create a more interesting shore with waves
    int segments = 48; // More segments for smoother edges
    float baseRadius = width * 0.5;  // Use the lake's width property
    
    // Draw the main water body as a slightly undulating surface
    beginShape(TRIANGLE_FAN);
    // Center point
    vertex(0, 0, 0);
    
    // Perimeter points with wave effect
    for (int i = 0; i <= segments; i++) {
      float angle = TWO_PI * i / segments;
      float waveOffset = sin(angle * 8) * 5; // 8 waves around the lake
      float px = cos(angle) * (baseRadius + waveOffset);
      float py = sin(angle) * (baseRadius + waveOffset);
      // Add a subtle sway to the water surface
      float waterHeight = sin(frameCount * 0.05 + angle * 3) * 1.5;
      vertex(px, py, waterHeight);
    }
    endShape();
    
    // Add a more detailed shore
    beginShape(TRIANGLE_STRIP);
    
    // More varied shore colors that match the desert better
    fill(235, 215, 175);  // Lighter sand color for shore
    
    for (int i = 0; i <= segments; i++) {
      float angle = TWO_PI * i / segments;
      float waveOffset = sin(angle * 8) * 5; // Match water waves
      
      // Inner shore point (water edge)
      float innerX = cos(angle) * (baseRadius + waveOffset);
      float innerY = sin(angle) * (baseRadius + waveOffset);
      float innerZ = sin(frameCount * 0.05 + angle * 3) * 1.5; // Match water height
      vertex(innerX, innerY, innerZ);
      
      // Outer shore point with varied height
      float shoreVariation = noise(angle * 2, frameCount * 0.01) * 8; // Varied shore height
      float outerRadius = baseRadius * 1.4; // Wider shore
      float outerX = cos(angle) * outerRadius;
      float outerY = sin(angle) * outerRadius;
      vertex(outerX, outerY, 3 + shoreVariation);  // Blend with terrain slope
    }
    endShape();
    
    // Add details to make the lake more interesting
    
    // 1. Small waves on water surface
    fill(100, 200, 255, 150); // Lighter blue for highlights
    for (int i = 0; i < 8; i++) {
      float angle = random(TWO_PI);
      float dist = random(baseRadius * 0.2, baseRadius * 0.8);
      float waveSize = random(15, 30);
      
      pushMatrix();
      translate(cos(angle) * dist, sin(angle) * dist, 1);
      rotateZ(angle);
      
      // Draw an elongated ellipse as a wave
      ellipse(0, 0, waveSize * 2, waveSize);
      popMatrix();
    }
    
    popStyle();
    popMatrix();
  }

  // Vérifie si un point (px, py) est contenu dans la surface du lac.
  boolean contains(float px, float py) {
    // Use a slightly larger radius for detection to account for waves
    float avgRadius = width * 0.55;
    return dist(x, y, px, py) < avgRadius;
  }
}
