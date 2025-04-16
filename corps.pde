// Crée la forme 3D du corps de la momie en générant des bandelettes de manière procédurale.
PShape createMummyBody() {
  PShape corps = createShape(GROUP);  // Groupe pour combiner les bandelettes
  
  int nbrTours = 65;
  int segments = 20;
  float hauteur = 400;
  // Définition du profil du corps
  float[] rayon = {
    //tete - Wider curve
    35, 38, 40, 42, 43,       
    43, 42, 41, 40, 39, 

    //epaule
    37, 40, 43, 46, 48,       
    50, 52, 53, 54, 53, 

    //torso
    52, 51, 50, 49, 48,       
    47, 46, 45, 44, 43, 

    //corps
    42, 41, 40, 39, 38,       
    37, 36, 35, 34, 33, 

    //pieds
    32, 31, 30, 29, 28,       
    27, 26, 25, 24, 23        
  };
  
  for (int tour = 0; tour < nbrTours; tour += 2) {  // Créer une bandelette tous les 2 tours
    float z = map(tour, 0, nbrTours-1, -hauteur/2, hauteur/2);
    int idxRayon = floor(map(tour, 0, nbrTours-1, 0, rayon.length-1));
    float rayonBase = rayon[idxRayon];
    
    // Create a bandage strip
    PShape bandage = createShape();

    // Apply randomized tint per bandage strip - WIDER range for more contrast
    float baseR = 210 + random(-70, 40); // Base beige/brown tone - Keep this wide range
    float baseG = 190 + random(-60, 40); // Keep this wide range
    float baseB = 160 + random(-60, 30); // Keep this wide range
    bandage.beginShape(QUAD_STRIP);
    bandage.fill(baseR, baseG, baseB);
    bandage.noStroke();
    bandage.texture(mummyTexture);
    
    // Static radius with small random variation
    float r = rayonBase + random(-2, 2);
    
    // Damaged bandages - static damage
    boolean isDamaged = random(1) > 0.7;
    float damage = isDamaged ? random(2, 8) : 0;
    
    // Static loose ends
    boolean hasLooseEnd = random(1) > 0.8;
    int looseEndSegment = hasLooseEnd ? floor(random(segments)) : -1;
    float looseAmount = hasLooseEnd ? random(3, 7) : 0;
    
    // Largeur variable des bandelettes - now static - THICKER
    float bandageWidth = hauteur / nbrTours * (4.5 + random(-0.5, 0.5));
    
    for (int s = 0; s <= segments; s++) {
      float angle = map(s, 0, segments, 0, TWO_PI);
      
      // Normales pour l'éclairage
      float nx = cos(angle);
      float ny = 0;
      float nz = sin(angle);
      bandage.normal(nx, ny, nz);
      
      // Coordonnées de texture
      float u = map(s, 0, segments, 0, 2);
      float v = map(tour, 0, nbrTours-1, 0, 5);
      
      // Static edge irregularities using random instead of noise
      float edgeNoise = random(-2.5, 2.5);
      float surfaceNoise = random(-1.5, 1.5);
      
      // Amplifier les extrémités lâches - now static
      if ((s == looseEndSegment || s == looseEndSegment + 1) && hasLooseEnd) {
        edgeNoise += looseAmount;
      }
      
      // Static overlap effect
      float overlapNoise = random(-4, 4);
      
      // Combinaison des effets - no wind effect
      float totalNoise = edgeNoise + damage + overlapNoise;
      
      float x = cos(angle) * (r + totalNoise);
      float y = sin(angle) * (r + totalNoise);
      
      // Ajouter les vertices - no displacement
      bandage.vertex(x, z + surfaceNoise, y, u, v);
      bandage.vertex(x, z + bandageWidth - surfaceNoise, y, u, v+1);
    }
    
    bandage.endShape();
    // Add random rotation to the bandage strip
    float randomAngle = random(-PI/32, PI/32);
    bandage.rotateY(randomAngle);
    corps.addChild(bandage);
    
    // Bandelettes croisées - static
    if (random(1) > 0.75) {
      PShape crossBandage = createShape();

      // Apply randomized tint to cross-bandage strip - WIDER range for more contrast
      float crossR = 205 + random(-70, 40); // Keep this wide range
      float crossG = 185 + random(-60, 40); // Keep this wide range
      float crossB = 155 + random(-60, 30); // Keep this wide range
      crossBandage.beginShape(QUAD_STRIP);
      crossBandage.fill(crossR, crossG, crossB);
      crossBandage.noStroke();
      crossBandage.texture(mummyTexture);
      
      float crossZ = z + random(-10, 20);
      float crossWidth = 10 + random(8);
      
      // Static loose cross bandage ends
      boolean isLooseCrossBandage = random(1) > 0.7;
      float looseCrossEnd = isLooseCrossBandage ? random(8, 15) : 0;
      
      for (float t = 0; t <= 1; t += 0.05) {
        // Bandelette en diagonale
        float angleOffset = t * PI * 1.2;
        float heightOffset = (t - 0.5) * 60;
        
        // Static loose end effect
        float looseFactor = 0;
        if (isLooseCrossBandage && t > 0.8) {
          looseFactor = looseCrossEnd * (t - 0.8) * 5;
        }
        
        for (int i = 0; i < 2; i++) {
          float angleVar = angleOffset + (i * 0.1); 
          float heightVar = crossZ + heightOffset + (i * crossWidth);
          
          float xEnd = cos(angleVar) * (r * 1.05 + looseFactor);
          float yEnd = sin(angleVar) * (r * 1.05 + looseFactor);
          
          // Normales pour l'éclairage
          float nxCross = cos(angleVar);
          float nzCross = sin(angleVar);
          crossBandage.normal(nxCross, 0, nzCross);
          
          // Coordonnées de texture
          float uCross = t * 2;
          float vCross = i * 1.0;
          
          crossBandage.vertex(xEnd, heightVar, yEnd, uCross, vCross);
        }
      }
      
      crossBandage.endShape();
      // Add random rotation to the cross-bandage strip
      float randomCrossAngle = random(-PI/24, PI/24);
      crossBandage.rotateY(randomCrossAngle);
      corps.addChild(crossBandage);
    }
  }
  
  return corps;
}
