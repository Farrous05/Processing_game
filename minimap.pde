// Met à jour la taille des cellules de la minimap en fonction de la taille du niveau actuel.
void updateMinimapCellSize() {
  minimapCellSize = (float) minimapSize / levelSizes[currentLevel];
}

// Dessine la minimap améliorée à l'écran, montrant les zones explorées, la position du joueur et l'orientation.
void drawEnhancedMinimap() {
  if (outsidePyramid) return;

  int minimapOffsetX = 50;
  int minimapOffsetY = 50;

  pushMatrix();

  int LAB_SIZE = levelSizes[currentLevel];
  float wallW = width/LAB_SIZE;
  float wallH = height/LAB_SIZE;

  for (int j = 0; j < LAB_SIZE; j++) {
    for (int i = 0; i < LAB_SIZE; i++) {
      if (levelSides[currentLevel][j][i][4] == 1) {
        if (levelLabyrinthes[currentLevel][j][i] == '#') {
          fill(i*25, j*25, 255-i*10+j*10);
          pushMatrix();
          translate(minimapOffsetX + i*wallW/8, minimapOffsetY + j*wallH/8, 50);
          box(wallW/10, wallH/10, 5);
          popMatrix();
        } else if (levelLabyrinthes[currentLevel][j][i] == 'E') {
          fill(255, 0, 0);
          pushMatrix();
          translate(minimapOffsetX + i*wallW/8, minimapOffsetY + j*wallH/8, 50);
          float pulseSize = 1.0 + 0.2 * sin(frameCount * 0.1);
          box(wallW/10 * pulseSize, wallH/10 * pulseSize, 5);
          popMatrix();
        }
      }
    }
  }

  pushMatrix();
  fill(0, 255, 0);
  noStroke();
  translate(minimapOffsetX + posX*wallW/8, minimapOffsetY + posY*wallH/8, 50);
  sphere(3);

  stroke(255, 255, 0);
  strokeWeight(2);
  line(0, 0, 0, dirX*5, dirY*5, 0);
  noStroke();
  popMatrix();

  fill(255);
  textAlign(LEFT, TOP);
  textSize(14);
  text("Level " + (currentLevel+1) + " of 3", minimapOffsetX, minimapOffsetY + LAB_SIZE*wallH/8 + 10);

  popMatrix();
}

// Met à jour le statut d'exploration des cellules du labyrinthe autour de la position actuelle du joueur.
void updateExploredArea() {
  if (outsidePyramid) return;

  int LAB_SIZE = levelSizes[currentLevel];
  for (int j = max(posY - explorationRadius, 0); j <= min(posY + explorationRadius, LAB_SIZE-1); j++) {
    for (int i = max(posX - explorationRadius, 0); i <= min(posX + explorationRadius, LAB_SIZE-1); i++) {
      float distance = dist(posX, posY, i, j);
      if (distance <= explorationRadius) {
        levelSides[currentLevel][j][i][4] = 1;
      }
    }
  }
}
