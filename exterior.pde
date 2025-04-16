// Angle de vue vertical du joueur à l'extérieur.
float playerVerticalAngle = 0;
float maxVerticalAngle = PI/3;
float verticalRotateSpeed = 0.006;

// Gère l'environnement extérieur de la pyramide, incluant le désert, la pyramide elle-même, et les interactions du joueur.
class PyramidExterior {
  int[] levelSizes;
  float[] levelHeights;
  float width, height;
  PShape pyramidShape;
  PShape desertShape;

  PImage stoneTexture;
  PImage sandTexture;
  PImage waterTexture;
  PImage darkTexture;

  PShader sandShader;

  float playerPosX = 5000;
  float playerPosY = 5000;
  float playerHeight = 50;
  float playerAngle = PI;
  float moveSpeed = 20.0;
  float rotateSpeed = 0.03;
  float pyramidBaseWidth;

  float entranceMinX, entranceMaxX, entranceMinY, entranceMaxY, entranceMinZ, entranceMaxZ;
  boolean playerEnteredPyramid = false;

  ArrayList<PalmTree> palmTrees;
  int numPalmTrees = 50;

  ArrayList<Lake> lakes;
  int numLakes = 8;

  color skyColor = color(135, 206, 235);

  // Constructeur: Initialise l'environnement extérieur, charge les textures et crée les formes géométriques.
  PyramidExterior(int[] levelSizes, float[] levelHeights, int width, int height,
                 PImage stoneTexture, PImage sandTexture) {
    this.levelSizes = levelSizes;
    this.levelHeights = levelHeights;
    this.width = (float)width;
    this.height = (float)height;
    this.stoneTexture = stoneTexture;
    this.sandTexture = sandTexture;

    try {
      this.darkTexture = loadImage("dark.png");
      if (this.darkTexture == null) throw new Exception();
      println("Loaded dark.png texture.");
    } catch (Exception e) {
      println("Warning: Could not load dark.png. Creating procedural black texture as fallback.");
      this.darkTexture = createImage(64, 64, RGB);
      this.darkTexture.loadPixels();
      for (int i = 0; i < this.darkTexture.pixels.length; i++) {
        this.darkTexture.pixels[i] = color(0);
      }
      this.darkTexture.updatePixels();
    }

    this.waterTexture = createWaterTexture();
    println("Created procedural water texture");

    try {
      sandShader = loadShader("sand_frag.glsl", "sand_vert.glsl");
      println("Successfully loaded sand shader.");
    } catch (Exception e) {
      println("Error loading sand shader: " + e.getMessage());
      sandShader = null;
    }

    palmTrees = new ArrayList<PalmTree>();
    lakes = new ArrayList<Lake>();

    createPyramidShape();
    createDesertShape();
    createLakesAndOases();

    updatePlayerHeight();
  }

 // Crée une texture procédurale pour l'eau des lacs/oasis.
 PImage createWaterTexture() {
  int size = 512;
  PImage waterTex = createImage(size, size, ARGB);
  waterTex.loadPixels();

  color deepWater = color(0, 130, 255);
  color shallowWater = color(70, 200, 255);
  color highlight = color(255, 255, 255, 200);

  noiseSeed(24);

  for (int y = 0; y < size; y++) {
    for (int x = 0; x < size; x++) {
      float nx = x * 0.01;
      float ny = y * 0.01;
      float largeWave = noise(nx, ny);

      float nx2 = x * 0.05;
      float ny2 = y * 0.05;
      float medRipple = noise(nx2, ny2);

      float nx3 = x * 0.2;
      float ny3 = y * 0.2;
      float smallRipple = noise(nx3, ny3);

      float combined = largeWave * 0.6 + medRipple * 0.3 + smallRipple * 0.1;

      color waterColor;
      if (combined < 0.4) {
        waterColor = deepWater;
      } else if (combined < 0.7) {
        waterColor = lerpColor(deepWater, shallowWater, (combined - 0.4) / 0.3);
      } else {
        float highlightFactor = (combined - 0.7) / 0.3;
        waterColor = lerpColor(shallowWater, highlight, highlightFactor * 0.7);
      }

      waterTex.pixels[y * size + x] = waterColor;
    }
  }

  waterTex.updatePixels();
  return waterTex;
}

  // Crée la forme 3D de la pyramide et l'entrée.
  void createPyramidShape() {
    pyramidShape = createShape(GROUP);

    pyramidBaseWidth = this.width * 4.0;
    float baseWidth = pyramidBaseWidth;
    float baseHeight = this.height * 4.0;
    float pyramidHeight = baseWidth * 0.9;

    PShape mainPyramid = createShape();
    mainPyramid.beginShape(TRIANGLES);
    mainPyramid.textureMode(NORMAL);
    mainPyramid.texture(stoneTexture);
    mainPyramid.noStroke();

    float centerX = this.width / 2;
    float centerY = this.height / 2;
    float baseHalfWidth = baseWidth / 2;
    float baseHalfHeight = baseHeight / 2;

    float apexX = centerX;
    float apexY = centerY;
    float apexZ = pyramidHeight;

    float[] baseX = {
      centerX - baseHalfWidth,
      centerX + baseHalfWidth,
      centerX + baseHalfWidth,
      centerX - baseHalfWidth
    };

    float[] baseY = {
      centerY - baseHalfHeight,
      centerY - baseHalfHeight,
      centerY + baseHalfHeight,
      centerY + baseHalfHeight
    };

    float baseZ = 0;

    mainPyramid.normal(0, 1, 0.5f);
    mainPyramid.vertex(baseX[2], baseY[2], baseZ, 0, 8);
    mainPyramid.vertex(baseX[3], baseY[3], baseZ, 8, 8);
    mainPyramid.vertex(apexX, apexY, apexZ, 4f, 0);

    mainPyramid.normal(1, 0, 0.5f);
    mainPyramid.vertex(baseX[1], baseY[1], baseZ, 0, 8);
    mainPyramid.vertex(baseX[2], baseY[2], baseZ, 8, 8);
    mainPyramid.vertex(apexX, apexY, apexZ, 4f, 0);

    mainPyramid.normal(0, -1, 0.5f);
    mainPyramid.vertex(baseX[0], baseY[0], baseZ, 0, 8);
    mainPyramid.vertex(baseX[1], baseY[1], baseZ, 8, 8);
    mainPyramid.vertex(apexX, apexY, apexZ, 4f, 0);

    mainPyramid.normal(-1, 0, 0.5f);
    mainPyramid.vertex(baseX[3], baseY[3], baseZ, 0, 8);
    mainPyramid.vertex(baseX[0], baseY[0], baseZ, 8, 8);
    mainPyramid.vertex(apexX, apexY, apexZ, 4f, 0);

    mainPyramid.normal(0, 0, -1);
    mainPyramid.vertex(baseX[0], baseY[0], baseZ, 0, 0);
    mainPyramid.vertex(baseX[1], baseY[1], baseZ, 8, 0);
    mainPyramid.vertex(baseX[2], baseY[2], baseZ, 8, 8);
    mainPyramid.vertex(baseX[3], baseY[3], baseZ, 0, 8);

    mainPyramid.endShape();

    float doorWidth = baseWidth * 0.06;
    float doorHeight = pyramidHeight * 0.12;
    float doorX_left = centerX - doorWidth / 2;
    float doorX_right = centerX + doorWidth / 2;

    float doorZ_bottom = baseZ;
    float doorY_bottom = baseY[2];

    float doorZ_top = baseZ + doorHeight;

    float t = 0;
    if (apexZ - baseZ != 0) {
      t = doorHeight / (apexZ - baseZ);
    }

    float doorY_top = baseY[2] + t * (apexY - baseY[2]);

    PVector faceNormal = new PVector(0, 1, 0.5f);
    faceNormal.normalize();
    float offsetDistance = 20.0;
    PVector offset = PVector.mult(faceNormal, offsetDistance);

    float collisionBuffer = 30;
    entranceMinX = doorX_left + offset.x - collisionBuffer;
    entranceMaxX = doorX_right + offset.x + collisionBuffer;
    entranceMinY = min(doorY_bottom, doorY_top) + offset.y - collisionBuffer;
    entranceMaxY = max(doorY_bottom, doorY_top) + offset.y + collisionBuffer;
    entranceMinZ = doorZ_bottom + offset.z - collisionBuffer;
    entranceMaxZ = doorZ_top + offset.z + collisionBuffer;

    PShape entranceQuad = createShape();
    entranceQuad.beginShape(QUADS);
    entranceQuad.textureMode(NORMAL);
    entranceQuad.texture(darkTexture);
    entranceQuad.noStroke();
    entranceQuad.normal(faceNormal.x, faceNormal.y, faceNormal.z);

    entranceQuad.vertex(doorX_left + offset.x,  doorY_bottom + offset.y, doorZ_bottom + offset.z, 0, 1);
    entranceQuad.vertex(doorX_right + offset.x, doorY_bottom + offset.y, doorZ_bottom + offset.z, 1, 1);
    entranceQuad.vertex(doorX_right + offset.x, doorY_top + offset.y,    doorZ_top + offset.z,    1, 0);
    entranceQuad.vertex(doorX_left + offset.x,  doorY_top + offset.y,    doorZ_top + offset.z,    0, 0);

    entranceQuad.endShape();

    pyramidShape.addChild(mainPyramid);
    pyramidShape.addChild(entranceQuad);
  }

  // Crée les lacs, les oasis et disperse les palmiers autour d'eux.
  void createLakesAndOases() {
    float centerX = this.width / 2;
    float centerY = this.height / 2;
    float baseRadius = pyramidBaseWidth / 2;
    float margin = 800;
    float exteriorRange = 8000;

    println("Creating " + numLakes + " lakes in the desert");

    for (int i = 0; i < numLakes; i++) {
      float lakeAngle = random(TWO_PI);
      float lakeDistance = baseRadius + margin + random(exteriorRange - margin);
      float lakeX = centerX + cos(lakeAngle) * lakeDistance;
      float lakeY = centerY + sin(lakeAngle) * lakeDistance;
      float lakeSize = random(350, 750);

      Lake lake = new Lake(lakeX, lakeY, lakeSize, waterTexture, this);
      lakes.add(lake);

      int lakeTrees = floor(random(5, 15));

      for (int j = 0; j < lakeTrees; j++) {
        float treeAngle = random(TWO_PI);
        float treeDistance = lakeSize * (0.6 + random(0.3));

        float treeX = lakeX + cos(treeAngle) * treeDistance;
        float treeY = lakeY + sin(treeAngle) * treeDistance;

        palmTrees.add(new PalmTree(treeX, treeY, this));
      }
    }

    int desertTrees = numPalmTrees - palmTrees.size();
    spawnAdditionalPalmTrees(desertTrees, centerX, centerY, baseRadius, margin, exteriorRange);

    println("Created " + lakes.size() + " lakes and " + palmTrees.size() + " palm trees");
  }

  void spawnAdditionalPalmTrees(int count, float centerX, float centerY, float baseRadius, float margin, float exteriorRange) {
    for (int i = 0; i < count; i++) {
      float angle = random(TWO_PI);
      float distance = baseRadius + margin + random(exteriorRange - margin);

      float treeX = centerX + cos(angle) * distance;
      float treeY = centerY + sin(angle) * distance;

      boolean tooCloseToLake = false;
      for (Lake lake : lakes) {
        if (dist(treeX, treeY, lake.x, lake.y) < lake.width * 0.8) {
          tooCloseToLake = true;
          break;
        }
      }

      if (!tooCloseToLake) {
        palmTrees.add(new PalmTree(treeX, treeY, this));
      }
    }
  }

  // Crée la forme du terrain désertique avec des dunes générées par bruit de Perlin.
  void createDesertShape() {
    float desertSize = this.width * 40;

    desertShape = createShape();
    desertShape.beginShape(TRIANGLES);
    desertShape.textureMode(NORMAL);
    desertShape.texture(sandTexture);
    desertShape.noStroke();

    int resolution = 130;
    float cellSize = desertSize / resolution;

    noiseSeed(42);

    for (int z = 0; z < resolution; z++) {
      for (int x = 0; x < resolution; x++) {
        float x1 = -desertSize/2 + x * cellSize;
        float x2 = x1 + cellSize;
        float z1 = -desertSize/2 + z * cellSize;
        float z2 = z1 + cellSize;

        float nx1 = x * 0.018;
        float nx2 = (x+1) * 0.018;
        float nz1 = z * 0.018;
        float nz2 = (z+1) * 0.018;

        float largeDune1 = noise(nx1 * 0.3, nz1 * 0.3) * 60;
        float largeDune2 = noise(nx2 * 0.3, nz1 * 0.3) * 60;
        float largeDune3 = noise(nx1 * 0.3, nz2 * 0.3) * 60;
        float largeDune4 = noise(nx2 * 0.3, nz2 * 0.3) * 60;

        float medDune1 = noise(nx1 * 0.7, nz1 * 0.7) * 20;
        float medDune2 = noise(nx2 * 0.7, nz1 * 0.7) * 20;
        float medDune3 = noise(nx1 * 0.7, nz2 * 0.7) * 20;
        float medDune4 = noise(nx2 * 0.7, nz2 * 0.7) * 20;

        float bump1 = noise(nx1 * 3, nz1 * 3) * 5;
        float bump2 = noise(nx2 * 3, nz1 * 3) * 5;
        float bump3 = noise(nx1 * 3, nz2 * 3) * 5;
        float bump4 = noise(nx2 * 3, nz2 * 3) * 5;

        largeDune1 = pow(largeDune1, 1.1);
        largeDune2 = pow(largeDune2, 1.1);
        largeDune3 = pow(largeDune3, 1.1);
        largeDune4 = pow(largeDune4, 1.1);

        float y1 = -5 + largeDune1 + medDune1 + bump1;
        float y2 = -5 + largeDune2 + medDune2 + bump2;
        float y3 = -5 + largeDune3 + medDune3 + bump3;
        float y4 = -5 + largeDune4 + medDune4 + bump4;

        float centerX = this.width / 2;
        float centerY = this.height / 2;
        float px1 = map(x, 0, resolution, -desertSize/2, desertSize/2);
        float pz1 = map(z, 0, resolution, -desertSize/2, desertSize/2);
        float px2 = map(x+1, 0, resolution, -desertSize/2, desertSize/2);
        float pz2 = map(z+1, 0, resolution, -desertSize/2, desertSize/2);

        float dist1 = dist(px1, pz1, centerX, centerY);
        float dist2 = dist(px2, pz1, centerX, centerY);
        float dist3 = dist(px1, pz2, centerX, centerY);
        float dist4 = dist(px2, pz2, centerX, centerY);

        float pyramidRadius = this.width * 2;

        if (dist1 < pyramidRadius) {
          float factor = map(dist1, 0, pyramidRadius, 0, 1);
          factor = factor * factor;
          y1 = lerp(-5, y1, factor);
        }
        if (dist2 < pyramidRadius) {
          float factor = map(dist2, 0, pyramidRadius, 0, 1);
          factor = factor * factor;
          y2 = lerp(-5, y2, factor);
        }
        if (dist3 < pyramidRadius) {
          float factor = map(dist3, 0, pyramidRadius, 0, 1);
          factor = factor * factor;
          y3 = lerp(-5, y3, factor);
        }
        if (dist4 < pyramidRadius) {
          float factor = map(dist4, 0, pyramidRadius, 0, 1);
          factor = factor * factor;
          y4 = lerp(-5, y4, factor);
        }

        PVector vertex1 = new PVector(x1, z1, y1);
        PVector vertex2 = new PVector(x2, z1, y2);
        PVector vertex3 = new PVector(x1, z2, y3);
        PVector vertex4 = new PVector(x2, z2, y4);

        PVector edge1 = PVector.sub(vertex2, vertex1);
        PVector edge2 = PVector.sub(vertex3, vertex1);
        PVector normal1 = edge1.cross(edge2);
        normal1.normalize();

        PVector edge3 = PVector.sub(vertex4, vertex2);
        PVector edge4 = PVector.sub(vertex3, vertex2);
        PVector normal2 = edge3.cross(edge4);
        normal2.normalize();

        float baseR = 120;
        float baseG = 100;
        float baseB = 65;

        float c1 = map(y1, -5, 60, 0.4, 1.8);
        float c2 = map(y2, -5, 60, 0.4, 1.8);
        float c3 = map(y3, -5, 60, 0.4, 1.8);
        float c4 = map(y4, -5, 60, 0.4, 1.8);

        float u1 = map(x, 0, resolution, 0, 15);
        float u2 = map(x+1, 0, resolution, 0, 15);
        float v1 = map(z, 0, resolution, 0, 15);
        float v2 = map(z+1, 0, resolution, 0, 15);

        desertShape.fill(baseR * c1, baseG * c1, baseB * c1);
        desertShape.normal(normal1.x, normal1.y, normal1.z);
        desertShape.vertex(x1, z1, y1, u1, v1);

        desertShape.fill(baseR * c2, baseG * c2, baseB * c2);
        desertShape.normal(normal1.x, normal1.y, normal1.z);
        desertShape.vertex(x2, z1, y2, u2, v1);

        desertShape.fill(baseR * c3, baseG * c3, baseB * c3);
        desertShape.normal(normal1.x, normal1.y, normal1.z);
        desertShape.vertex(x1, z2, y3, u1, v2);

        desertShape.fill(baseR * c2, baseG * c2, baseB * c2);
        desertShape.normal(normal2.x, normal2.y, normal2.z);
        desertShape.vertex(x2, z1, y2, u2, v1);

        desertShape.fill(baseR * c4, baseG * c4, baseB * c4);
        desertShape.normal(normal2.x, normal2.y, normal2.z);
        desertShape.vertex(x2, z2, y4, u2, v2);

        desertShape.fill(baseR * c3, baseG * c3, baseB * c3);
        desertShape.normal(normal2.x, normal2.y, normal2.z);
        desertShape.vertex(x1, z2, y3, u1, v2);
      }
    }

    desertShape.endShape();
  }

  // Calcule la hauteur du terrain désertique à une position (x, z) donnée.
  float getTerrainHeightAt(float x, float z) {
    float desertSize = this.width * 40;

    float nx = map(x, -desertSize/2, desertSize/2, 0, 1);
    float nz = map(z, -desertSize/2, desertSize/2, 0, 1);

    nx *= 0.018;
    nz *= 0.018;

    float largeDune = noise(nx * 0.3, nz * 0.3) * 60;
    largeDune = pow(largeDune, 1.1);

    float medDune = noise(nx * 0.7, nz * 0.7) * 20;

    float bump = noise(nx * 3, nz * 3) * 5;

    float height = -5 + largeDune + medDune + bump;

    float centerX = this.width / 2;
    float centerY = this.height / 2;
    float dist = dist(x, z, centerX, centerY);
    float pyramidRadius = this.width * 2;

    if (dist < pyramidRadius) {
      float factor = map(dist, 0, pyramidRadius, 0, 1);
      factor = factor * factor;
      height = lerp(-5, height, factor);
    }

    for (Lake lake : lakes) {
      if (lake.contains(x, z)) {
        return -5;
      }
    }

    return height;
  }

  // Met à jour la hauteur du joueur pour qu'il reste au niveau du sol.
  void updatePlayerHeight() {
    float terrainHeight = getTerrainHeightAt(playerPosX, playerPosY);
    playerHeight = terrainHeight + 50;
  }

  // Met à jour la position et l'angle du joueur en fonction des entrées clavier et gère les collisions.
  void update() {
    float moveX = 0, moveY = 0;
    boolean isMoving = false;

    if (keyPressed) {
      if (key == 'z' || key == 'Z') {
        moveX = cos(playerAngle) * moveSpeed;
        moveY = sin(playerAngle) * moveSpeed;
        isMoving = true;
      }
      if (key == 's' || key == 'S') {
        moveX = -cos(playerAngle) * moveSpeed;
        moveY = -sin(playerAngle) * moveSpeed;
        isMoving = true;
      }
      if (key == 'q' || key == 'Q') {
        moveX = cos(playerAngle - PI/2) * moveSpeed;
        moveY = sin(playerAngle - PI/2) * moveSpeed;
        isMoving = true;
      }
      if (key == 'd' || key == 'D') {
        moveX = cos(playerAngle + PI/2) * moveSpeed;
        moveY = sin(playerAngle + PI/2) * moveSpeed;
        isMoving = true;
      }

      if (keyCode == LEFT) playerAngle -= rotateSpeed;
      if (keyCode == RIGHT) playerAngle += rotateSpeed;

      if (keyCode == UP) playerVerticalAngle = max(playerVerticalAngle - verticalRotateSpeed, -maxVerticalAngle);
      if (keyCode == DOWN) playerVerticalAngle = min(playerVerticalAngle + verticalRotateSpeed, maxVerticalAngle);

      if (isMoving) {
        float nextX = playerPosX + moveX;
        float nextY = playerPosY + moveY;
        float nextZ = playerHeight;

        if (isCollidingWithEntrance(nextX, nextY, nextZ)) {
           playerEnteredPyramid = true;
           return;
        }

        if (!isCollidingWithPyramid(nextX, nextY) && !isCollidingWithPalmTree(nextX, nextY)) {
          playerPosX = nextX;
          playerPosY = nextY;
          updatePlayerHeight();
        }
      }
    }

    float desertSize = this.width * 40;
    playerPosX = constrain(playerPosX, -desertSize/2 + 50, desertSize/2 - 50);
    playerPosY = constrain(playerPosY, -desertSize/2 + 50, desertSize/2 - 50);

    for (PalmTree tree : palmTrees) {
      tree.update();
    }
  }

  // Vérifie si une position donnée entre en collision avec le modèle de la pyramide.
  boolean isCollidingWithPyramid(float testX, float testY) {
    float centerX = this.width / 2;
    float centerY = this.height / 2;

    float halfWidth = pyramidBaseWidth / 2;
    float minX = centerX - halfWidth;
    float maxX = centerX + halfWidth;
    float minY = centerY - halfWidth;
    float maxY = centerY + halfWidth;

    float buffer = 50;
    float entranceBuffer = 10;

    return (testX > minX - buffer && testX < maxX + buffer &&
            testY > minY - buffer && testY < maxY + entranceBuffer);
  }

  // Vérifie si une position donnée entre en collision avec un palmier.
  boolean isCollidingWithPalmTree(float testX, float testY) {
    for (PalmTree tree : palmTrees) {
      float distanceToTree = dist(testX, testY, tree.x, tree.y);
      float collisionRadius = tree.trunkWidth / 2 + 20;

      if (distanceToTree < collisionRadius) {
        return true;
      }
    }
    return false;
  }

  // Vérifie si une position donnée entre en collision avec la zone de l'entrée de la pyramide.
  boolean isCollidingWithEntrance(float testX, float testY, float testZ) {
    return (testX >= entranceMinX && testX <= entranceMaxX &&
            testY >= entranceMinY && testY <= entranceMaxY &&
            testZ >= entranceMinZ && testZ <= entranceMaxZ);
  }

  // Vérifie si le joueur est proche de l'entrée de la pyramide.
  boolean isNearPyramidEntrance() {
    float entranceCenterX = (entranceMinX + entranceMaxX) / 2;
    float entranceCenterY = (entranceMinY + entranceMaxY) / 2;

    float distanceToEntrance = dist(playerPosX, playerPosY, entranceCenterX, entranceCenterY);
    float entranceDetectionRadius = 250;

    return distanceToEntrance < entranceDetectionRadius;
  }

  // Dessine l'environnement extérieur (désert, pyramide, ciel, palmiers, lacs) et l'interface utilisateur.
  void draw() {
    pushMatrix();
    perspective(PI/3, width/(float)height, 1, 30000);

    float lookAtX = playerPosX + cos(playerAngle);
    float lookAtY = playerPosY + sin(playerAngle);
    float lookAtZ = playerHeight - sin(playerVerticalAngle) * 10;

    camera(
      playerPosX,
      playerPosY,
      playerHeight,
      lookAtX,
      lookAtY,
      lookAtZ,
      0, 0, -1
    );

    background(skyColor);

    drawClouds();

    ambientLight(30, 30, 35);
    directionalLight(255, 235, 210, 0.8, 0.8, -0.2);
    directionalLight(140, 150, 160, -0.6, -0.4, -0.5);

    textureWrap(REPEAT);

    if (sandShader != null) {
      sandShader.set("sandTextureSampler", sandTexture);
      sandShader.set("time", millis() / 1000.0);
      sandShader.set("resolution", width, height);
      shader(sandShader);
    }

    shape(desertShape, this.width/2, this.height/2);

    if (sandShader != null) {
      resetShader();
    }

    shape(pyramidShape, 0, 0);
    for (Lake lake : lakes) {
      lake.display();
    }

    for (PalmTree tree : palmTrees) {
      tree.display();
    }

    textureWrap(CLAMP);

    popMatrix();

    fill(0);
    textAlign(LEFT, TOP);
    textSize(16);
    text("Controls: Z - Forward, S - Backward, Q - Strafe Left, D - Strafe Right", 20, 20);
    text("Arrow Keys - Look Around (Up/Down/Left/Right), R - Restart", 20, 40);
  }

  // Dessine les nuages dans le ciel.
  void drawClouds() {
    pushMatrix();

    randomSeed(53);

    int numClouds = 15;
    for (int i = 0; i < numClouds; i++) {
      float cloudAngle = random(TWO_PI);
      float cloudDist = random(4000, 8000);
      float cloudHeight = random(3000, 6000);

      float cloudX = this.width/2 + cos(cloudAngle) * cloudDist;
      float cloudY = this.height/2 + sin(cloudAngle) * cloudDist;
      float cloudZ = cloudHeight;

      fill(180, 180, 180, 200);
      noStroke();

      pushMatrix();
      translate(cloudX, cloudY, cloudZ);

      int cloudPuffs = floor(random(3, 8));
      float cloudSize = random(300, 800);

      for (int j = 0; j < cloudPuffs; j++) {
        float puffX = random(-cloudSize/2, cloudSize/2);
        float puffY = random(-cloudSize/2, cloudSize/2);
        float puffZ = random(-cloudSize/6, cloudSize/6);
        float puffSize = random(cloudSize/3, cloudSize/1.5);

        pushMatrix();
        translate(puffX, puffY, puffZ);
        sphere(puffSize);
        popMatrix();
      }

      popMatrix();
    }

    randomSeed(0);
    popMatrix();
  }

  // Retourne la position X actuelle du joueur.
  float getPlayerPosX() {
    return playerPosX;
  }

  // Retourne la position Y actuelle du joueur.
  float getPlayerPosY() {
    return playerPosY;
  }

  // Retourne l'angle horizontal actuel du joueur.
  float getPlayerAngle() {
    return playerAngle;
  }

  // Met à jour l'éclairage de la scène en fonction du niveau actuel du labyrinthe.
  void updateForLevel(int currentLevel) {
    float progressFactor = map(currentLevel, 0, 2, 0.8, 1.2);

    directionalLight(255 * progressFactor,
                    250 * progressFactor,
                    235 * progressFactor,
                    0.5, 0.5, -0.8);

    if (currentLevel == 2) {
      ambientLight(50, 40, 0);
    }
  }

  // Définit la position et l'angle du joueur (utilisé lors de la sortie/entrée de la pyramide).
  void setPlayerPos(float x, float y, float angle) {
    this.playerPosX = x;
    this.playerPosY = y;
    this.playerAngle = angle;
    updatePlayerHeight();
  }
}
