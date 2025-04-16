PShape createMummyArms() {
  PShape arms = createShape(GROUP);
  
  // Create left and right arms
  PShape leftArm = createArm(true);
  PShape rightArm = createArm(false);
  
  arms.addChild(leftArm);
  arms.addChild(rightArm);
  
  return arms;
}

PShape createArm(boolean isLeft) {
  PShape arm = createShape(GROUP);
  
  int nbrTours = 30;
  int segments = 16;
  float armLength = 160;
  
  // Define the arm profile from shoulder to hand
  float[] armRadius = {
    // Shoulder - narrower at the top
    21, 20,
    // Upper arm
    19, 18, 17, 16, 15, 14,
    // Elbow area
    14, 13, 12,
    // Forearm
    12, 11, 10.5, 10.5, 10,
    // Wrist
    8, 8,
    // Hand
    9, 10, 11, 11.5,
    // Fingers (simplified)
    10, 9, 8, 7, 6, 5.5, 5, 4.5
  };
  
  // Position offset for left/right arm
  float xOffset = isLeft ? -45 : 45;
  float shoulderY = -60; // Vertical position of shoulder - RAISED from -55
  
  for (int tour = 0; tour < nbrTours; tour += 2) {
    // Calculate arm position - completely straight arms
    float z = map(tour, 0, nbrTours-1, 25, 25 + armLength * 0.85);
    
    // No downward angle - arms are completely straight
    
    int idxRadius = floor(map(tour, 0, nbrTours-1, 0, armRadius.length-1));
    float baseRadius = armRadius[idxRadius];
    
    // Create a bandage strip
    PShape bandage = createShape();

    // Apply randomized tint per bandage strip - Increased range
    float baseR = 210 + random(-50, 30); // WIDER range: Base beige/brown tone
    float baseG = 190 + random(-45, 35); // WIDER range
    float baseB = 160 + random(-45, 30); // WIDER range

    bandage.beginShape(QUAD_STRIP);
    bandage.fill(baseR, baseG, baseB);
    bandage.noStroke();
    bandage.texture(mummyTexture);
    
    // Static radius variation
    float r = baseRadius + random(-1.5, 1.5);
    
    // Static damaged bandages
    boolean isDamaged = random(1) > 0.7;
    float damage = isDamaged ? random(2, 6) : 0;
    
    // Static loose ends
    boolean hasLooseEnd = random(1) > 0.85;
    int looseEndSegment = hasLooseEnd ? floor(random(segments)) : -1;
    float looseAmount = hasLooseEnd ? random(2.5, 5) : 0;
    
    // Static bandage width - THICKER
    float bandageWidth = armLength / nbrTours * (4.2 + random(-0.5, 0.5));
    
    for (int s = 0; s <= segments; s++) {
      float angle = map(s, 0, segments, 0, TWO_PI);
      
      // Normals for lighting - pointing outward from cylinder
      float nx = cos(angle);
      float ny = sin(angle);
      float nz = 0;
      bandage.normal(nx, ny, nz);
      
      // Texture coordinates
      float u = map(s, 0, segments, 0, 2);
      float v = map(tour, 0, nbrTours-1, 0, 3);
      
      // Static edge irregularities
      float edgeNoise = random(-1.5, 1.5);
      float surfaceNoise = random(-0.75, 0.75);
      
      // Static enhanced loose ends
      if ((s == looseEndSegment || s == looseEndSegment + 1) && hasLooseEnd) {
        edgeNoise += looseAmount;
      }
      
      // Static overlapping effect
      float overlapNoise = random(-3, 3);
      
      // Combine effects - no animation or wind effects
      float totalNoise = edgeNoise + damage + overlapNoise;
      
      // Calculate vertex positions - NO YOFFSET for straight arms
      float x = xOffset + cos(angle) * (r + totalNoise);
      float y = shoulderY + sin(angle) * (r + totalNoise);
      
      // Add vertices - no displacement animation
      bandage.vertex(x, y + surfaceNoise, z, u, v);
      bandage.vertex(x, y + surfaceNoise, z + bandageWidth, u, v+1);
    }
    
    bandage.endShape();
    arm.addChild(bandage);
    
    // Static cross bandages
    if (random(1) > 0.8) {
      PShape crossBandage = createShape();
      
      // Apply randomized tint to cross-bandage strip - Increased range
      float crossR = 205 + random(-50, 35); // WIDER range
      float crossG = 185 + random(-45, 30); // WIDER range
      float crossB = 155 + random(-45, 25); // WIDER range

      crossBandage.beginShape(QUAD_STRIP);
      crossBandage.fill(crossR, crossG, crossB);
      crossBandage.noStroke();
      crossBandage.texture(mummyTexture);
      
      float crossZ = z + random(-8, 15);
      float crossWidth = 7 + random(6);
      
      // Static loose cross bandage ends
      boolean isLooseCrossBandage = random(1) > 0.75;
      float looseCrossEnd = isLooseCrossBandage ? random(5, 8) : 0;
      
      for (float t = 0; t <= 1; t += 0.05) {
        // Diagonal bandage
        float angleOffset = t * PI * 1.2;
        float zOffset = (t - 0.5) * 35;
        
        // Static loose end effect
        float looseFactor = 0;
        if (isLooseCrossBandage && t > 0.85) {
          looseFactor = looseCrossEnd * (t - 0.85) * 4;
        }
        
        for (int i = 0; i < 2; i++) {
          float angleVar = angleOffset;
          float zVar = crossZ + zOffset + (i * crossWidth);
          
          float xEnd = xOffset + cos(angleVar) * (r * 1.05 + looseFactor);
          // No crossYOffset for straight arms
          float yEnd = shoulderY + sin(angleVar) * (r * 1.05 + looseFactor);
          
          // Normals for lighting
          float nxCross = cos(angleVar);
          float nyCross = sin(angleVar);
          crossBandage.normal(nxCross, nyCross, 0);
          
          // Texture coordinates
          float uCross = t * 2;
          float vCross = i * 1.0;
          
          crossBandage.vertex(xEnd, yEnd, zVar, uCross, vCross);
        }
      }
      
      crossBandage.endShape();
      arm.addChild(crossBandage);
    }
  }
  
  return arm;
}
