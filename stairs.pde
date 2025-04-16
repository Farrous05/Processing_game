// Dessine les escaliers (anciennement échelles) qui relient les différents niveaux du labyrinthe.
void drawLadders() {
  int numSteps = 5;
  float stepHeightRatio = 0.8;

  pushMatrix();
  textureMode(NORMAL);
  fill(255);
  noStroke();

  for (int lvl = 0; lvl < 2; lvl++) {
    int exitX = exitGridPositions[lvl][0];
    int exitY = exitGridPositions[lvl][1];

    int LAB_SIZE_CURRENT = levelSizes[lvl];
    float wallW_Current = width / LAB_SIZE_CURRENT;
    float wallH_Current = height / LAB_SIZE_CURRENT;

    float startZ_base = levelHeights[lvl] - 49;
    float endZ_base = levelHeights[lvl+1] - 49;
    float totalStairsHeight = (endZ_base - startZ_base) * stepHeightRatio;
    float stepHeight = totalStairsHeight / numSteps;

    float stairsWidth = wallW_Current * 0.9;
    float stairsLength = wallH_Current * 0.8;
    float stepDepth = stairsLength / numSteps;

    float startY = exitY * wallH_Current - stairsLength / 2;
    float endY = startY + stairsLength;
    float startX = exitX * wallW_Current - stairsWidth / 2;
    float endX = exitX * wallW_Current + stairsWidth / 2;

    beginShape(QUADS);
    texture(texture0);
    vertex(startX, startY, startZ_base,  0, 1);
    vertex(startX, endY,   endZ_base,    1, 0);
    vertex(startX, endY,   startZ_base,  1, 1);
    vertex(startX, startY, startZ_base,  0, 1);
    endShape();

    beginShape(QUADS);
    texture(texture0);
    vertex(endX, startY, startZ_base,  0, 1);
    vertex(endX, endY,   endZ_base,    1, 0);
    vertex(endX, endY,   startZ_base,  1, 1);
    vertex(endX, startY, startZ_base,  0, 1);
    endShape();

    for (int i = 0; i < numSteps; i++) {
        float currentZ = startZ_base + i * stepHeight;
        float nextZ = startZ_base + (i + 1) * stepHeight;
        float currentY = startY + i * stepDepth;
        float nextY = startY + (i + 1) * stepDepth;

        beginShape(QUADS);
        texture(texture0);
        vertex(startX, currentY, currentZ, 0, 1);
        vertex(endX,   currentY, currentZ, 1, 1);
        vertex(endX,   currentY, nextZ,    1, 0);
        vertex(startX, currentY, nextZ,    0, 0);
        endShape();

        beginShape(QUADS);
        texture(texture0);
        vertex(startX, currentY, nextZ,    0, 0);
        vertex(endX,   currentY, nextZ,    1, 0);
        vertex(endX,   nextY,    nextZ,    1, 1);
        vertex(startX, nextY,    nextZ,    0, 1);
        endShape();
    }
  }
  popMatrix();
}
