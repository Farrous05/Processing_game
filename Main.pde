import processing.sound.*;
import gifAnimation.*;

// 3-Level Pyramid Maze with Exterior View and Enhanced Minimap

int iposX = 1;
int iposY = 1;
int posX = iposX;
int posY = iposY;
int dirX = 0;
int dirY = 1;
int odirX = 0;
int odirY = 1;
int WALLD = 1;

int anim = 0;
boolean animT = false;
boolean animR = false;
boolean inLab = false; // Start outside

int currentLevel = 0;
boolean[] levelCompleted = {false, false, false};
boolean inTransition = false;
int transitionProgress = 0;
int transitionDuration = 45;
int targetLevel = -1;
int targetPosX = -1;
int targetPosY = -1;

int minimapSize = 150;
float minimapCellSize;
int explorationRadius = 3;
int minimapX = 20;
int minimapY = 20;
color exploredColor = color(200, 200, 200);
color unexploredColor = color(50);
color wallColor = color(100, 100, 255);
color playerColor = color(0, 255, 0);
color borderColor = color(255);
color exitColor = color(255, 0, 0);
boolean exitReached = false;
color ladderColor = color(255, 0, 0, 180);

PyramidExterior pyramidExterior;
boolean showExterior = true;
boolean outsidePyramid = true;

ArrayList<Mummy> mummies;
int mummiesPerLevelFactor = 50;

int nextMummyID = 0;

boolean isClimbingStairs = false;
int stairClimbProgress = 0;
int stairClimbDuration = 160;
int stairSourceLevel = -1;
float stairBobAmount = 0.7;
int stairVisNumSteps = 5;
float stairClimbMaxProgress = 0.9;

int playerHealth = 3;
int maxHealth = 3;
boolean isGameOver = false;
boolean playerInvulnerable = false;
int invulnerabilityTimer = 0;
int invulnerabilityDuration = 90;

float shakeAmount = 0;
float shakeDuration = 0;
float shakeDecay = 0.9;

boolean gameWon = false;

// Fonction d'initialisation : Configure la taille de la fenêtre, charge les ressources, génère les labyrinthes et initialise l'état du jeu.
void setup() {
  randomSeed(6);

  // Load all game assets (Textures, Sounds, Models, Fonts, etc.)
  loadAllAssets(); 

  // Now that assets are loaded, set the global font
  if (uiFont != null) {
     textFont(uiFont);
  } else {
     println("WARNING: uiFont is null after loading assets. Using default font.");
  }

  // Setup compass (potentially uses assets like fonts)
  println("Setting up compass...");
  setupCompass();

  // Initialize game size AFTER assets are loaded (if size depends on assets)
  size(1000, 1000, P3D);
  
  // Initialize Mummy list (needs to exist before maze generation calls spawnMummies)
  mummies = new ArrayList<Mummy>(); 
  
  // Generate Maze Layouts and Geometry (calls spawnMummies internally for now)
  generateAllMazes();

  // Print maze layouts for debugging (Moved from inside generation loop)
  for (int lvl = 0; lvl < 3; lvl++) {
    println("Level " + lvl + " maze layout:");
    for (int j = 0; j < levelSizes[lvl]; j++) {
      String row = "";
      for (int i = 0; i < levelSizes[lvl]; i++) {
        row += levelLabyrinthes[lvl][j][i];
      }
      println(row);
    }
    println("Entrance: [" + entranceGridPositions[lvl][0] + ", " + entranceGridPositions[lvl][1] + "]");
    println("Exit: [" + exitGridPositions[lvl][0] + ", " + exitGridPositions[lvl][1] + "]");
  }
  
  // Initial player position based on maze generation
  posX = entranceGridPositions[0][0];
  posY = entranceGridPositions[0][1];
  iposX = posX;
  iposY = posY;

  // Create pyramid exterior object (uses textures loaded in assets)
  if (mummyAssetsLoaded) {
    pyramidExterior = new PyramidExterior(levelSizes, levelHeights, width, height, 
                                      texture0, sandTexture);
  } else {
    println("Skipping exterior creation due to asset loading failure.");
  }

  // Show initial welcome message
  showWelcomeMessage();

  // Initial minimap calculations based on maze
  updateMinimapCellSize();
  updateExploredArea();
}

// Affiche le message de bienvenue initial à l'écran.
void showWelcomeMessage() {
  fill(0, 0, 0, 200);
  rect(0, 0, width, height);
  
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(32);
  text("Welcome to the Pyramid of the Mummies", width/2, height/2 - 100);
  textSize(24);
  text("Explore the exterior using AZERTY keys", width/2, height/2 - 40);
  text("Beware of wandering mummies!", width/2, height/2 + 0);
  textSize(18);
  text("Walk into the entrance to begin your adventure", width/2, height/2 + 50);
}

// Boucle principale de dessin : Gère le rendu de la scène (extérieur ou labyrinthe), les mises à jour et l'interface utilisateur.
void draw() {
  if (gameWon) {
    drawVictoryScreen();
    return;
  }

  if (isGameOver) {
    drawGameOverScreen();
    return;
  }

  background(0);
  sphereDetail(6);
  if (anim>0) anim--;

  checkAndPlayExteriorSound();

  if (outsidePyramid && pyramidExterior != null && pyramidExterior.playerEnteredPyramid) {
    if (transitionSound != null) {
      transitionSound.play();
    }
    enterPyramid();
    pyramidExterior.playerEnteredPyramid = false;
    return;
  }

  if (playerInvulnerable) {
    invulnerabilityTimer--;
    if (invulnerabilityTimer <= 0) {
      playerInvulnerable = false;
    }
  }

  int LAB_SIZE = levelSizes[currentLevel];
  float wallW = width/LAB_SIZE;
  float wallH = height/LAB_SIZE;

  perspective();
  camera(width/2.0, height/2.0, (height/2.0) / tan(PI*30.0 / 180.0), width/2.0, height/2.0, 0, 0.0f, 1.0f, 0.0f);
  noLights();
  stroke(0);
  
  if (shakeDuration > 0) {
    float shakeX = random(-shakeAmount, shakeAmount);
    float shakeY = random(-shakeAmount, shakeAmount);
    translate(shakeX, shakeY);
    shakeDuration--;
    shakeAmount *= shakeDecay;
  }
  
  if (outsidePyramid && pyramidExterior != null) {
    pyramidExterior.update();
    pyramidExterior.draw();
    
    drawUIInformation();
    
    hint(DISABLE_DEPTH_TEST);
    drawCompass();
    hint(ENABLE_DEPTH_TEST);
    
    return;
  } else if (!inLab && showExterior && pyramidExterior != null) {
    ambientLight(150, 150, 150);
    directionalLight(255, 255, 220, 0.5, 0.5, -1);
    
    pyramidExterior.updateForLevel(currentLevel);
    pyramidExterior.draw();
  }
  
  if (inLab) {
      drawEnhancedMinimap();
  }

  if (isClimbingStairs) {
    if (ambientSound != null && ambientSound.isPlaying()) ambientSound.stop();
    if (desertSound != null && desertSound.isPlaying()) desertSound.stop();
    
    stairClimbProgress++;
    float progress = (float)stairClimbProgress / stairClimbDuration;
    progress = constrain(progress, 0, stairClimbMaxProgress); 

    int sourceLabSize = levelSizes[stairSourceLevel];
    float sourceWallW = width / sourceLabSize;
    float sourceWallH = height / sourceLabSize;
    
    float stairsLength = sourceWallH * 0.8; 
    float startStairY = exitGridPositions[stairSourceLevel][1] * sourceWallH - stairsLength / 2; 
    float endStairY = startStairY + stairsLength; 
    float stairCenterX = exitGridPositions[stairSourceLevel][0] * sourceWallW;
    
    float camYBase = lerp(startStairY, endStairY, progress);
    float camY = camYBase;
    float camX = stairCenterX;
    
    float startZWorld = levelHeights[stairSourceLevel] - 15;
    float targetZWorld = levelHeights[targetLevel] - 15;   
    float camZBase = lerp(startZWorld, targetZWorld, progress);
    
    float bobAngle = map(progress, 0, 1, 0, stairVisNumSteps * PI); 
    float bobOffsetCam = sin(bobAngle) * stairBobAmount;     
    float bobOffsetLook = sin(bobAngle + PI/4) * stairBobAmount * 0.6; 
    
    float camZ = camZBase + bobOffsetCam;

    float lookAtY = lerp(startStairY, endStairY, progress + 0.1);
    float lookAtX = camX;
    float lookAtZ = camZBase + bobOffsetLook;

    perspective(2*PI/3, float(width)/float(height), 1, 1000); 
    camera(camX, camY, camZ, 
           lookAtX, lookAtY, lookAtZ, 
           0.0f, 0.0f, -1.0f);
           
    ambientLight(100, 100, 100); 
    lightFalloff(0.0, 0.01, 0.0001);
    pointLight(255, 255, 255, camX, camY, camZ + 30); 

    for (int lvl = stairSourceLevel; lvl <= targetLevel; lvl++) {
      pushMatrix();
      translate(0, 0, levelHeights[lvl]);
      if (levelShapes[lvl] != null) shape(levelShapes[lvl], 0, 0);
      if (levelFloors[lvl] != null) shape(levelFloors[lvl], 0, 0);
      popMatrix();
    }
    drawLadders();
    if (targetLevel < 2) {
    }

    if (progress >= stairClimbMaxProgress) {
      println("Stair climb finished. Arrived at level " + targetLevel);
      isClimbingStairs = false;
      stairClimbProgress = 0;
      
      currentLevel = targetLevel;
      posX = targetPosX;
      posY = targetPosY;
      stairSourceLevel = -1;
      
      dirX = 1; dirY = 0; 

      targetLevel = -1;
      targetPosX = -1;
      targetPosY = -1;

      updateMinimapCellSize();
      updateExploredArea(); 
    }
    
    drawUIInformation(); 
    
    hint(DISABLE_DEPTH_TEST);
    drawCompass();
    hint(ENABLE_DEPTH_TEST);
    
    return; 
  }
  
  if (inLab) {
    if (ambientSound != null && !ambientSound.isPlaying()) ambientSound.loop();
    if (desertSound != null && desertSound.isPlaying()) desertSound.stop();
    
    perspective(2*PI/3, float(width)/float(height), 1, 1000);
    if (animT) {
      if (dirY == -odirY && dirX == -odirX) {
        camera(posX*wallW, posY*wallH, -15+2*sin(anim*PI/5.0)+levelHeights[currentLevel], 
             (posX+dirX)*wallW, (posY+dirY)*wallH, -15+4*sin(anim*PI/5.0)-2*sin(anim*PI/10.0)+levelHeights[currentLevel], 
             0.0f, 0.0f, -1.0f);
      } else {
        camera((posX-dirX*anim/20.0)*wallW, (posY-dirY*anim/20.0)*wallH, -15+2*sin(anim*PI/5.0)+levelHeights[currentLevel], 
             (posX-dirX*anim/20.0+dirX)*wallW, (posY-dirY*anim/20.0+dirY)*wallH, -15+4*sin(anim*PI/5.0)+levelHeights[currentLevel], 
             0.0f, 0.0f, -1.0f);
      }
    }
    else if (animR)
      camera(posX*wallW, posY*wallH, -15+levelHeights[currentLevel], 
            (posX+(odirX*anim+dirX*(20-anim))/20.0)*wallW, (posY+(odirY*anim+dirY*(20-anim))/20.0)*wallH, -15-5*sin(anim*PI/20.0)+levelHeights[currentLevel], 
            0.0f, 0.0f, -1.0f);
    else {
      camera(posX*wallW, posY*wallH, -15+levelHeights[currentLevel], 
             (posX+dirX)*wallW, (posY+dirY)*wallH, -15+levelHeights[currentLevel], 0.0f, 0.0f, -1.0f);
    }

    ambientLight(100, 100, 100); 

    lightFalloff(0.0, 0.01, 0.0001);
    pointLight(255, 255, 255, posX*wallW, posY*wallH, 15+levelHeights[currentLevel]);
  } else {
    if (desertSound != null && !desertSound.isPlaying()) desertSound.loop();
    if (ambientSound != null && ambientSound.isPlaying()) ambientSound.stop();

    lightFalloff(0.0, 0.05, 0.0001);
    pointLight(255, 255, 255, posX*wallW, posY*wallH, 15+levelHeights[currentLevel]);
  }

  if (shakeDuration > 0) {
    float shakeX = random(-shakeAmount, shakeAmount);
    float shakeY = random(-shakeAmount, shakeAmount);
    translate(shakeX, shakeY);
    shakeDuration--;
    shakeAmount *= shakeDecay;
  }
  
  for (int lvl = 0; lvl <= currentLevel; lvl++) {
    pushMatrix();
    translate(0, 0, levelHeights[lvl]);
    shape(levelShapes[lvl], 0, 0);
    shape(levelFloors[lvl], 0, 0);
    if (inLab) {
      shape(levelCeilings[lvl], 0, 0);
    }
    popMatrix();
  }
  
  drawLadders();
  if (currentLevel < 2) {
  }
  
  if (inLab && mummyAssetsLoaded) { 
     float currentLevelHeight = levelHeights[currentLevel];
     wallW = width/levelSizes[currentLevel]; 
     wallH = height/levelSizes[currentLevel]; 

     float playerRadius = wallW * 0.25;
     float mummyRadius = wallW * 0.2;
     float collisionDistanceThreshold = playerRadius + mummyRadius; 
     float collisionDistSqThreshold = collisionDistanceThreshold * collisionDistanceThreshold;

     float playerWorldX = posX * wallW;
     float playerWorldY = posY * wallH;

     for (int i = mummies.size() - 1; i >= 0; i--) { 
        Mummy m = mummies.get(i);
        if (m.level == currentLevel) {
          m.update(levelLabyrinthes[currentLevel], posX, posY, currentLevelHeight, wallW, wallH);
          m.display();

          float dx = playerWorldX - m.visualX;
          float dy = playerWorldY - m.visualY;
          float distSq = dx*dx + dy*dy;

          if (!isGameOver && !playerInvulnerable && distSq < collisionDistSqThreshold) {
             playerHealth--;
             println("Player hit by Mummy! Health: " + playerHealth);
             playerInvulnerable = true;
             invulnerabilityTimer = invulnerabilityDuration;

             if (damageSound != null) {
               damageSound.play();
             }
             
             startShake(8, 20);

             if (playerHealth <= 0) {
               isGameOver = true;
               println("Game Over!");
               if (mummyChaseSound != null && mummyChaseSound.isPlaying()) {
                 mummyChaseSound.stop();
               }
               if (gameOverSound != null) {
                  if (ambientSound != null && ambientSound.isPlaying()) ambientSound.stop();
                  if (desertSound != null && desertSound.isPlaying()) desertSound.stop();
                  gameOverSound.play();
               }
             }
          }
        }
     }
  }

  if (!isClimbingStairs && !outsidePyramid) {
      if (currentLevel < 2 && levelLabyrinthes[currentLevel][posY][posX] == 'E') { 
          if (posX == exitGridPositions[currentLevel][0] && posY == exitGridPositions[currentLevel][1]) {
              println("Auto-triggering stair climb from level " + currentLevel);
              isClimbingStairs = true;
              stairClimbProgress = 0;
              stairSourceLevel = currentLevel;
              
              targetLevel = currentLevel + 1;
              targetPosX = entranceGridPositions[targetLevel][0];
              targetPosY = entranceGridPositions[targetLevel][1];
              
              if (stairsSound != null) {
                  stairsSound.play();
              }
          }
      }
  }

  if (currentLevel == 2 && inLab) {
    int finalLevelSize = levelSizes[2];
    float finalWallW = width / finalLevelSize;
    float finalWallH = height / finalLevelSize;
    int exitX = exitGridPositions[2][0];
    int exitY = exitGridPositions[2][1];
    float targetX = exitX * finalWallW;
    float targetY = exitY * finalWallH;
    float targetZ = levelHeights[2] - 50;

    pushMatrix();
    translate(targetX, targetY, targetZ);
    rotateX(-PI/2);
    rotateY(PI/2); 
    rotateZ(PI);
    rotateY(PI);
    scale(finalWallW * 0.5);

    ambientLight(50, 50, 50); 
    sarcophagusBack.setFill(color(218, 165, 32));
    sarcophagusFront.setFill(color(218, 165, 32));
    noStroke();

    if (sarcophagusBack != null) {
      sarcophagusBack.noTexture();
      shape(sarcophagusBack, 0, 0);
    }
    if (sarcophagusFront != null) {
      sarcophagusFront.noTexture();
      shape(sarcophagusFront, 0, 0); 
    }
    lights();
    popMatrix();
  }
  
  if (!gameWon && !isGameOver && !inTransition && !isClimbingStairs && currentLevel == 2 && levelLabyrinthes[currentLevel][posY][posX] == 'E' && !levelCompleted[currentLevel]) {
       if (posX == exitGridPositions[currentLevel][0] && posY == exitGridPositions[currentLevel][1]) {
          levelCompleted[currentLevel] = true;
          println("VICTORY! All levels completed!");
          gameWon = true;
          
          if (ambientSound != null && ambientSound.isPlaying()) ambientSound.stop();
          if (desertSound != null && desertSound.isPlaying()) desertSound.stop();
          if (mummyChaseSound != null && mummyChaseSound.isPlaying()) mummyChaseSound.stop();
          
          if (victorySound != null) {
            victorySound.loop();
          } else {
             println("Warning: victorySound was null. Could not play victory sound.");
          }
          
          if (victoryGif != null) {
             victoryGif.play();
          }
       } else {
          println("Warning: Player at final 'E' but not matching exitGridPosition for level " + currentLevel);
       }
    }
  
  drawUIInformation();

  hint(DISABLE_DEPTH_TEST);
  drawCompass();
  hint(ENABLE_DEPTH_TEST);
}

// Réinitialise le jeu à son état initial.
void restartGame() {
  gameWon = false;
  isGameOver = false;
  playerHealth = maxHealth;
  isClimbingStairs = false;
  stairClimbProgress = 0;
  stairSourceLevel = -1;
  targetLevel = -1;
  targetPosX = -1;
  targetPosY = -1;
  
  currentLevel = 0;
  posX = entranceGridPositions[0][0];
  posY = entranceGridPositions[0][1];
  dirX = 0;
  dirY = 1;
  inLab = false;
  outsidePyramid = true;
  showExterior = true;
  for (int i = 0; i < levelCompleted.length; i++) {
    levelCompleted[i] = false;
  }
  updateMinimapCellSize();
  
  for (int lvl = 0; lvl < 3; lvl++) {
    int LAB_SIZE = levelSizes[lvl];
    for (int j = 0; j < LAB_SIZE; j++) {
      for (int i = 0; i < LAB_SIZE; i++) {
        levelSides[lvl][j][i][4] = 0;
      }
    }
  }
  
  mummies.clear();
  nextMummyID = 0;
  if (mummyAssetsLoaded) {
    for (int lvl = 0; lvl < 3; lvl++) {
      int numMummiesToSpawn = 0;
      if (lvl == 0) numMummiesToSpawn = 3;
      else if (lvl == 1) numMummiesToSpawn = 2;
      else if (lvl == 2) numMummiesToSpawn = 1;
      spawnMummies(lvl, numMummiesToSpawn);
    }
  } else {
    println("Skipping mummy respawn during restart due to asset loading failure.");
  }
  
  if (victorySound != null && victorySound.isPlaying()) {
    victorySound.stop();
  }
  
  if (victoryGif != null && victoryGif.isPlaying()) {
     victoryGif.stop();
  }
  
  showWelcomeMessage();

  if (ambientSound != null && !ambientSound.isPlaying()) {
      ambientSound.loop();
  }
  
  if (pyramidExterior != null) {
    pyramidExterior = new PyramidExterior(levelSizes, levelHeights, width, height, 
                                    texture0, sandTexture);
  } else {
    println("Skipping exterior creation due to asset loading failure.");
  }
  
  checkAndPlayExteriorSound();
}

void spawnMummies(int level, int count) {
  int LAB_SIZE = levelSizes[level];
  int spawned = 0;
  int attempts = 0;
  int maxAttempts = count * 10;

  println("Spawning " + count + " mummies for level " + level); 

  while (spawned < count && attempts < maxAttempts) {
    attempts++;
    int tryX = floor(random(1, LAB_SIZE - 1));
    int tryY = floor(random(1, LAB_SIZE - 1));

    if ((levelLabyrinthes[level][tryY][tryX] == ' ' || levelLabyrinthes[level][tryY][tryX] == 'E') && 
        !(level == 0 && tryX == entranceGridPositions[0][0] && tryY == entranceGridPositions[0][1]))
    { 
      boolean tooClose = false;
      for (Mummy m : mummies) {
        if (m.level == level && dist(tryX, tryY, m.gridX, m.gridY) < 2.0) {
          tooClose = true;
          break;
        }
      }
      
      if (!tooClose) {
          mummies.add(new Mummy(tryX, tryY, level, mummyTexture, mummyBodyShader, mummyEyeShader, nextMummyID, mummyChaseSound));
          nextMummyID++;
          spawned++;
      }
    }
  }
  if (spawned < count) {
      println("Warning: Could only spawn " + spawned + " out of " + count + " requested mummies for level " + level);
  }
}

void enterMazeFromExterior(float exteriorX, float exteriorY, float exteriorAngle) {
  if (outsidePyramid) {
    println("Player physically entered the pyramid");
    
    if (desertSound != null && desertSound.isPlaying()) desertSound.stop();
    if (ambientSound != null && !ambientSound.isPlaying()) ambientSound.loop();
    
    outsidePyramid = false;
    inLab = true;
    
    posX = entranceGridPositions[0][0];
    posY = entranceGridPositions[0][1];
    
    dirX = 0;
    dirY = -1; 
    
    currentLevel = 0;
    
    updateExploredArea();
  }
}

void showEntranceTransitionEffect() {
  fill(0, 0, 0, 200);
  rectMode(CORNER);
  rect(0, 0, width, height);
  
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(28);
  text("Entering the Pyramid", width/2, height/2);
}

void enterPyramid() {
  println("Entering Pyramid...");
  
  if (desertSound != null && desertSound.isPlaying()) desertSound.stop();
  if (ambientSound != null && !ambientSound.isPlaying()) ambientSound.loop();
    
  outsidePyramid = false;
  inLab = true;
  currentLevel = 0;
  
  posX = entranceGridPositions[currentLevel][0];
  posY = entranceGridPositions[currentLevel][1];
  
  println("  - Target Start Level: " + currentLevel);
  println("  - Entrance Position from Array: [" + entranceGridPositions[currentLevel][0] + ", " + entranceGridPositions[currentLevel][1] + "]");
  println("  - Setting Player Position to: [" + posX + ", " + posY + "]");
  
  dirX = 0;
  dirY = -1;
}

void checkAndPlayExteriorSound(){
  if (isGameOver) {
      if (ambientSound != null && ambientSound.isPlaying()) ambientSound.stop();
      if (desertSound != null && desertSound.isPlaying()) desertSound.stop();
      return;
  }

  if (isClimbingStairs) {
    if (ambientSound != null && ambientSound.isPlaying()) ambientSound.stop();
    if (desertSound != null && desertSound.isPlaying()) desertSound.stop();
    return;
  }

  if (outsidePyramid) {
    if (desertSound != null && !desertSound.isPlaying()) desertSound.loop();
    if (ambientSound != null && ambientSound.isPlaying()) ambientSound.stop();
  } else {
    if (ambientSound != null && !ambientSound.isPlaying()) ambientSound.loop();
    if (desertSound != null && desertSound.isPlaying()) desertSound.stop();
  }
}

void drawGameOverScreen() {
  pushStyle();
  pushMatrix();
  camera();
  noLights();
  hint(DISABLE_DEPTH_TEST);
  
  fill(0, 0, 0, 200);
  rectMode(CORNER);
  rect(0, 0, width, height);
  
  fill(255, 0, 0);
  textAlign(CENTER, CENTER);
  textSize(200);
  if (uiFont != null) textFont(uiFont);
  text("GAME OVER", width/2, height/2 - 100);
  
  fill(255);
  textSize(48);
  text("The mummies got you!", width/2, height/2);
  
  textSize(36);
  text("Press R to restart", width/2, height/2 + 100);
  
  hint(ENABLE_DEPTH_TEST);
  popMatrix();
  popStyle();
}

void startShake(float amount, float duration) {
  shakeAmount = amount;
  shakeDuration = duration;
}

void drawVictoryScreen() {
  pushStyle();
  pushMatrix();
  camera();
  noLights();
  hint(DISABLE_DEPTH_TEST);
  
  background(0);
  
  if (victoryGif != null) {
    imageMode(CENTER); 
    image(victoryGif, width/2, height/2, width, height);
  }
  
  fill(255, 215, 0);
  textAlign(CENTER, CENTER);
  textSize(80); 
  if (uiFont != null) textFont(uiFont);
  text("VICTORY!", width/2, height/2 - 50);
  
  textSize(36);
  fill(255);
  text("Press R to restart", width/2, height - 100);
  
  hint(ENABLE_DEPTH_TEST);
  popMatrix();
  popStyle();
}
