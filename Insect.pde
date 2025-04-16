// Représente une mouche (insecte) individuelle qui vole autour de la momie.
class Insects {
  PVector position;
  PVector velocity;
  PVector acceleration;
  float maxSpeed = 3.5;
  float maxForce = 0.2;
  float size;
  float wingAngle = 0;
  float wingSpeed;
  
  // Noise fields for more organic movement
  float noiseOffsetX;
  float noiseOffsetY;
  float noiseOffsetZ;
  float noiseScale = 0.01;
  
  // Color variables
  color insectColor;
  
  // Constructeur: Initialise une nouvelle mouche avec sa position et sa vitesse initiales.
  Insects(float x, float y, float z) {
    position = new PVector(x, y, z);
    velocity = PVector.random3D().mult(random(1.0, 2.0));
    acceleration = new PVector(0, 0, 0);
    size = random(1.5, 4.0);  // Slightly larger and more varied size range
    wingSpeed = random(0.5, 0.8);  // Faster wing movement for flies
    
    // Initialize noise offsets randomly for varied movement
    noiseOffsetX = random(1000);
    noiseOffsetY = random(1000);
    noiseOffsetZ = random(1000);
    
    // Darker fly color with slight random variation
    float colorVariation = random(-10, 10);
    insectColor = color(20 + colorVariation, 20 + colorVariation, 20 + colorVariation);
  }
  
  // Mise à jour: Calcule le mouvement de la mouche basé sur le bruit de Perlin, l'attraction et la physique.
  void update() {
    // Update wing animation - faster for flies
    wingAngle += wingSpeed;
    
    // Use Perlin noise for more natural flight patterns
    float noiseX = noise(noiseOffsetX) * 2 - 1;
    float noiseY = noise(noiseOffsetY) * 2 - 1;
    float noiseZ = noise(noiseOffsetZ) * 2 - 1;
    
    PVector noiseForce = new PVector(noiseX, noiseY, noiseZ);
    noiseForce.mult(1.2);  // Increase influence of noise
    applyForce(noiseForce);
    
    // Increment noise offsets for movement through the noise field
    noiseOffsetX += noiseScale;
    noiseOffsetY += noiseScale;
    noiseOffsetZ += noiseScale;
    
    // Random jitter for erratic fly movement
    PVector jitter = PVector.random3D();
    jitter.mult(0.5);
    applyForce(jitter);
    
    // Stay near the mummy (attraction to origin)
    PVector toCenter = new PVector(-position.x, -position.y, -position.z);
    float distance = toCenter.mag();
    toCenter.normalize();
    
    // Stronger attraction when far away
    float strength = map(distance, 0, 400, 0, 0.8);
    toCenter.mult(strength);
    applyForce(toCenter);
    
    // Physics update
    velocity.add(acceleration);
    velocity.limit(maxSpeed);
    position.add(velocity);
    acceleration.mult(0);
    
    // Limit how far flies can go
    position.x = constrain(position.x, -300, 300);
    position.y = constrain(position.y, -400, 200);
    position.z = constrain(position.z, -300, 300);
  }
  
  // Applique une force au vecteur d'accélération de la mouche.
  void applyForce(PVector force) {
    acceleration.add(force);
  }
  
  // Affichage: Dessine la mouche (corps, tête, ailes) à sa position actuelle.
  void display() {
    pushMatrix();
    translate(position.x, position.y, position.z);
    
    // Face in direction of movement
    float angle = atan2(velocity.y, velocity.x);
    rotateZ(angle);
    rotateY(atan2(velocity.z, velocity.x));
    
    // Draw fly body
    fill(insectColor);
    noStroke();
    
    // Body (small oval for fly)
    pushMatrix();
    scale(1, 0.6, 0.7);
    sphere(size);
    popMatrix();
    
    // Head (slightly smaller)
    pushMatrix();
    translate(size*0.8, 0, 0);
    scale(0.6, 0.6, 0.6);
    sphere(size);
    popMatrix();
    
    // Transparent wings that flap rapidly
    pushMatrix();
    translate(-size*0.2, 0, 0);
    
    // Left wing
    pushMatrix();
    rotateZ(sin(wingAngle) * PI/4);
    rotateY(cos(wingAngle) * PI/8);
    
    // Thin, delicate wing
    pushMatrix();
    translate(0, 0, size);
    scale(size*1.5, size/10, size);
    beginShape(TRIANGLES);
    fill(200, 200, 200, 100);
    vertex(0, 0, 0);
    vertex(1, 0.5, 0);
    vertex(1, -0.5, 0);
    endShape();
    popMatrix();
    popMatrix();
    
    // Right wing
    pushMatrix();
    rotateZ(-sin(wingAngle) * PI/4);
    rotateY(-cos(wingAngle) * PI/8);
    
    // Thin, delicate wing
    pushMatrix();
    translate(0, 0, -size);
    scale(size*1.5, size/10, size);
    beginShape(TRIANGLES);
    fill(200, 200, 200, 100);
    vertex(0, 0, 0);
    vertex(1, 0.5, 0);
    vertex(1, -0.5, 0);
    endShape();
    popMatrix();
    popMatrix();
    
    popMatrix();
    popMatrix();
  }
} 
