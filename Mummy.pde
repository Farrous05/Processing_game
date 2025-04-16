import processing.opengl.*; // Needed for PShader

// REMOVED Static declarations formerly outside class

// REMOVED static keyword from class definition
class Mummy {


  // --- Added instance variables for assets ---
  PImage tex;
  PShader bodyShader;
  PShader eyeShaderInstance; 
  // --- End instance variables ---

  // Position and State
  int gridX, gridY;
  int level;
  float worldX, worldY, worldZ; // Calculated in display
  int state; // 0: WANDERING, 1: CHASING
  static final int WANDERING = 0;
  static final int CHASING = 1;
  int uniqueID; // Added for debugging
  float targetAngle = 0; // Goal rotation angle
  float currentAngle = 0; // Current visual rotation angle (for lerping)
  boolean initializedVisuals = false; // Flag for first visual update
  float visualX, visualY, visualZ; // Visual position for interpolation
  float lerpSpeed = 0.02; // FURTHER DECREASED speed for very slow, smooth visual glide
  float angleLerpSpeed = 0.02; // FURTHER DECREASED speed for very slow angle interpolation
  float bobAmount = 1.5; // Vertical bob height
  float bobSpeed = 0.03; // Vertical bob speed
  int lastWanderDX = 0; // Store last wander direction X
  int lastWanderDY = 1; // Store last wander direction Y (default forward)
  
  // Memory for wandering
  int prevGridX;
  int prevGridY;
  
  // Appearance
  PShape mummyBodyShape;
  PShape mummyArmsShape;
  PShape mummyEyesShape;
  
  // Associated objects
  ArrayList<Insects> insects;
  int numInsects = 25; 
  
  // >> NEW: Sound reference <<
  SoundFile chaseSound; 
  // >> END NEW <<
  
  // Movement params
  int moveCooldown = 0; // RE-ADD movement cooldown
  int moveInterval = 50; // INCREASED SIGNIFICANTLY for slower logical moves
  float sightRange = 5.0f; // Grid units for detection

  // Constructeur: Initialise une nouvelle momie avec sa position, ses assets et son ID.
  Mummy(int startX, int startY, int startLevel, PImage tex, PShader bodyShader, PShader eyeShaderInstance, int id, SoundFile chaseSound) {
    this.gridX = startX;
    this.gridY = startY;
    this.level = startLevel;
    this.state = WANDERING;
    
    // Store asset references
    this.tex = tex;
    this.bodyShader = bodyShader;
    this.eyeShaderInstance = eyeShaderInstance;
    this.uniqueID = id; // Assign ID passed from projet.pde
    this.moveCooldown = moveInterval; // Set initial cooldown
    // visualX/Y/Z will be initialized on first update call
    this.prevGridX = startX; // Initialize memory
    this.prevGridY = startY;
    
    // Store sound reference
    this.chaseSound = chaseSound;

    // Initialize angles based on default wander direction
    this.targetAngle = atan2(lastWanderDY, lastWanderDX);
    this.currentAngle = this.targetAngle; 

    // Create the visual components - Now callable as non-static
    this.mummyBodyShape = createMummyBody(); 
    this.mummyArmsShape = createMummyArms();
    this.mummyEyesShape = createEyes();

    // Initialize insects - Assuming Insect class is also non-static or handled correctly
    this.insects = new ArrayList<Insects>();
    for (int i = 0; i < numInsects; i++) {
      float ix = random(-150, 150); 
      float iy = random(-250, 50); 
      float iz = random(-150, 150);
      // If Insect needs assets, modify its constructor too
      this.insects.add(new Insects(ix, iy, iz)); 
    }
  }

  // Interpolation douce d'angle pour une rotation fluide.
  float lerpAngle(float a, float b, float t) {
    float difference = b - a;
    while (difference < -PI) difference += TWO_PI;
    while (difference > PI) difference -= TWO_PI;
    return a + difference * t;
  }

  // Mise à jour: Gère l'état (errance/chasse), la position logique et visuelle de la momie.
  void update(char[][] currentLabyrinthMap, int playerGridX, int playerGridY, float levelBaseHeight, float cellWidth, float cellHeight) {
    // REMOVED check for assetsLoaded 

    // --- Target Position Calculation (based on current gridX/Y) ---
    float targetX = this.gridX * cellWidth; 
    float targetY = this.gridY * cellHeight; 
    float targetZ = -15 + levelBaseHeight + 1.0; 

    // --- Initialize or Lerp Visual Position --- 
    if (!initializedVisuals) {
        // First update, snap visual position to target
        visualX = targetX;
        visualY = targetY;
        visualZ = targetZ;
        initializedVisuals = true;
    } else {
        // Interpolate visual position towards target
        visualX = lerp(visualX, targetX, lerpSpeed);
        visualY = lerp(visualY, targetY, lerpSpeed);
        visualZ = lerp(visualZ, targetZ, lerpSpeed);
    }

    // --- Smooth Angle Update ---
    currentAngle = lerpAngle(currentAngle, targetAngle, angleLerpSpeed); // Use dedicated angle lerp speed

    // --- State Detection & Angle Calculation ---
    boolean canSeePlayer = false; // Assume cannot see initially
    // Check Line of Sight (includes distance check within the function)
    if (hasLineOfSight(playerGridX, playerGridY, currentLabyrinthMap, sightRange)) {
        canSeePlayer = true; 
    }

    // --- State Transition Logic ---
    if (canSeePlayer) {
        // If player is visible, start or continue chasing
        // >> NEW: Play sound ONLY on transition from WANDERING to CHASING <<
        if (this.state == WANDERING && this.chaseSound != null) {
          this.chaseSound.play(); 
        }
        // >> END NEW <<
        this.state = CHASING;
        float dx = playerGridX - this.gridX;
        float dy = playerGridY - this.gridY;
        if (dx != 0 || dy != 0) { 
          this.targetAngle = atan2(dy, dx); 
        }
    } else {
        // Player cannot be seen
        if (this.state == CHASING) {
            // If LOS is lost while chasing, immediately switch back to wandering.
            this.state = WANDERING;
        } 
        // If already wandering, just continue wandering
        // Update target angle based on last wander direction when wandering
        if (this.state == WANDERING) {
            this.targetAngle = atan2(lastWanderDY, lastWanderDX);
        }
    }

    // --- Movement Logic (Use cooldown, updates gridX/Y) ---
    // REMOVED: Check for visual proximity (distSqToTarget < thresholdDistSq)
    // Cooldown and move decisions now happen based purely on moveInterval timer.
    
    moveCooldown--; // Decrement cooldown every update where logic is allowed
    if (moveCooldown <= 0) {
        // Store current position BEFORE making move decision
        prevGridX = gridX;
        prevGridY = gridY;

        if (state == WANDERING) {
            wander(currentLabyrinthMap); // Decide next grid cell target
        } else { // state == CHASING
            chase(currentLabyrinthMap, playerGridX, playerGridY); // Decide next grid cell target
        }
        // --- Log move decision --- 
        char tileType = '?'; // Determine tile type at the *new* position
        if (gridY >= 0 && gridY < currentLabyrinthMap.length && gridX >= 0 && gridX < currentLabyrinthMap[0].length) {
            tileType = currentLabyrinthMap[gridY][gridX];
        }
        String stateStr = (state == WANDERING) ? "WANDER" : "CHASE";
        println("Mummy ["+ uniqueID + "] - MOVE - State: " + stateStr + " -> Grid: (" + gridX + "," + gridY + ") Tile: '" + tileType + "'");
        // --- END Log --- 
        moveCooldown = moveInterval; // Reset cooldown only after a move decision
    }
    // --- End Modified Movement Logic ---
    
    // --- Update Insects ---
    for (Insects insect : insects) {
      insect.update(); // Assuming Insect class has an update method
    }
  }
  
  // --- Movement Helper Methods ---
  
  // Vérifie si un déplacement vers (nextX, nextY) est valide sur la carte.
  boolean isValidMove(int nextX, int nextY, char[][] map) {
     // Check bounds
     if (nextX < 0 || nextX >= map[0].length || nextY < 0 || nextY >= map.length) {
       return false;
     }
     // Check for walls
     if (map[nextY][nextX] == '#') {
       return false;
     }
     // Add any other invalid space checks here ('E' exit might be walkable?)
     return true;
  }

  // Fait pivoter la direction d'errance prévue de la momie dans le sens horaire.
  void rotateClockwise() {
      // Current: (DX, DY)
      // Right turn: newDX = oldDY, newDY = -oldDX
      int oldDX = lastWanderDX;
      int oldDY = lastWanderDY;
      lastWanderDX = oldDY;
      lastWanderDY = -oldDX;
  }

  // Comportement d'errance: Détermine le prochain mouvement quand la momie ne chasse pas.
  void wander(char[][] map) {
      // 1. Try moving forward
      int forwardX = gridX + lastWanderDX;
      int forwardY = gridY + lastWanderDY;
      boolean forwardIsPrev = (forwardX == prevGridX && forwardY == prevGridY);
      if (isValidMove(forwardX, forwardY, map) && !forwardIsPrev) {
          gridX = forwardX;
          gridY = forwardY;
          // lastWanderDX/DY remain unchanged
          return;
      }

      // --- Forward blocked, calculate potential turns ---
      // Left turn: newX = -oldY, newY = oldX
      int leftDX = -lastWanderDY;
      int leftDY = lastWanderDX;
      // Right turn: newX = oldY, newY = -oldX
      int rightDX = lastWanderDY;
      int rightDY = -lastWanderDX;
      // Back turn: newX = -oldX, newY = -oldY
      int backDX = -lastWanderDX;
      int backDY = -lastWanderDY;

      // 2. Try turning left
      int leftX = gridX + leftDX;
      int leftY = gridY + leftDY;
      boolean leftIsPrev = (leftX == prevGridX && leftY == prevGridY);
      if (isValidMove(leftX, leftY, map) && !leftIsPrev) {
          gridX = leftX;
          gridY = leftY;
          lastWanderDX = leftDX; // Update direction
          lastWanderDY = leftDY;
          return;
      }

      // 3. Try turning right
      int rightX = gridX + rightDX;
      int rightY = gridY + rightDY;
      boolean rightIsPrev = (rightX == prevGridX && rightY == prevGridY);
      if (isValidMove(rightX, rightY, map) && !rightIsPrev) {
          gridX = rightX;
          gridY = rightY;
          lastWanderDX = rightDX; // Update direction
          lastWanderDY = rightDY;
          return;
      }

      // 4. Try turning back
      int backX = gridX + backDX;
      int backY = gridY + backDY;
      // Allow moving back to previous cell ONLY if F/L/R were invalid or the previous cell
      if (isValidMove(backX, backY, map)) {
          gridX = backX;
          gridY = backY;
          lastWanderDX = backDX; // Update direction
          lastWanderDY = backDY;
          return;
      }

      // 5. Completely blocked - stay put
  }

  // Comportement de chasse: Détermine le prochain mouvement pour se rapprocher du joueur.
  void chase(char[][] map, int playerX, int playerY) {
      int dx = playerX - gridX;
      int dy = playerY - gridY;
      int moveX = 0;
      int moveY = 0;

      // Prioritize move direction that closes the largest distance
      if (abs(dx) > abs(dy)) {
          moveX = dx > 0 ? 1 : -1; // Try horizontal first
          if (!isValidMove(gridX + moveX, gridY, map)) { // If horizontal blocked, try vertical
              moveX = 0; // Reset horizontal attempt
              moveY = dy > 0 ? 1 : -1;
              if (!isValidMove(gridX, gridY + moveY, map)) {
                  moveY = 0; // Vertical also blocked
              }
          }
      } else {
         moveY = dy > 0 ? 1 : -1; // Try vertical first
         if (!isValidMove(gridX, gridY + moveY, map)) { // If vertical blocked, try horizontal
             moveY = 0; // Reset vertical attempt
             moveX = dx > 0 ? 1 : -1;
             if (!isValidMove(gridX + moveX, gridY, map)) {
                  moveX = 0; // Horizontal also blocked
             }
         }
      }

      // If a valid move was found
      if (moveX != 0 || moveY != 0) {
          gridX += moveX;
          gridY += moveY;
          // We already update targetAngle in the main update loop based on player pos when chasing
      } else {
          // Player is likely adjacent but blocked, or right on top. Do nothing or maybe a 'wiggle'?
          // Or try a random move like in wander? For now, do nothing if primary chase moves fail.
          wander(map); // Fallback to wander if chase move is blocked
      }
  }

  // Vérifie s'il y a une ligne de vue directe entre la momie et la cible (tx, ty).
  boolean hasLineOfSight(int tx, int ty, char[][] map, float maxRange) {
    int x0 = this.gridX;
    int y0 = this.gridY;
    int x1 = tx;
    int y1 = ty;

    // Check max range first (using squared distance for efficiency)
    float actualDistSq = sq(x1 - x0) + sq(y1 - y0);
    if (actualDistSq > sq(maxRange)) {
      return false;
    }

    int dx = abs(x1 - x0);
    int sx = x0 < x1 ? 1 : -1;
    int dy = -abs(y1 - y0);
    int sy = y0 < y1 ? 1 : -1;
    int err = dx + dy; // error value e_xy

    int currentX = x0;
    int currentY = y0;

    while (true) {
      // Check the current cell for obstacles, but skip the mummy's own starting cell.
      if (currentX != x0 || currentY != y0) {
        // Bounds check for the map
        if (currentY < 0 || currentY >= map.length || currentX < 0 || currentX >= map[0].length) {
          return false; // Line goes out of map bounds
        }
        // Wall check
        if (map[currentY][currentX] == '#') {
          return false; // Obstacle found
        }
      }

      if (currentX == x1 && currentY == y1) {
          break; // Reached target cell
      }

      int e2 = 2 * err;
      if (e2 >= dy) { // e_xy+e_x >= 0
        if (currentX == x1) break; // Safety break to prevent overshoot X
        err += dy;
        currentX += sx;
      }
      if (e2 <= dx) { // e_xy+e_y <= 0
        if (currentY == y1) break; // Safety break to prevent overshoot Y
        err += dx;
        currentY += sy;
      }
    }

    return true; // Reached target without hitting any obstacles
  }

  // Affichage: Dessine la momie à sa position visuelle actuelle avec animations.
  void display() {
   

    // --- Calculate Bobbing Offset --- 
    float bobOffset = sin(frameCount * bobSpeed) * bobAmount;
    float finalZ = visualZ + bobOffset; // Apply bobbing to interpolated Z

    pushMatrix();
    // --- Use Interpolated Visual Position + Bobbing for Translation --- 
    translate(visualX, visualY, finalZ); 
    
    // --- Apply Rotations & Scale --- 
    rotateZ(this.currentAngle - PI/2); // Facing rotation (use smoothed angle)
    rotateX(-PI/2); // Stand upright rotation
    scale(0.15); // Scaling

    // --- Render Mummy Model --- 
    // --- Draw Body and Arms with Bandage Shader ---
    if (this.bodyShader != null && mummyBodyShape != null && mummyArmsShape != null) {
      // Re-enabled shader
      shader(this.bodyShader); 
      shape(mummyBodyShape);
      shape(mummyArmsShape);
      // Re-enabled shader reset
      resetShader(); 
    } else {
      // Fallback rendering 
      fill(200, 180, 160); // Mummy-like color
      if (mummyBodyShape != null) shape(mummyBodyShape);
      if (mummyArmsShape != null) shape(mummyArmsShape);
    }

    // --- Draw Eyes with Eye Shader ---
    if (mummyEyesShape != null) {
      // Re-enabled shader
      shader(this.eyeShaderInstance);
      noStroke(); 
      shape(mummyEyesShape);
      // Re-enabled shader reset
      resetShader(); 
    } else {
       // Fallback rendering
       fill(139, 0, 0); // Dark red
       if (mummyEyesShape != null) shape(mummyEyesShape);
    }
    // --- END RESTORED ORIGINAL RENDERING ---

    // --- Draw Insects ---
    // Insects are positioned relative to the mummy, so they inherit the translation
    pushMatrix(); // Isolate insect transformations if needed
    // lights(); // Temporarily disable lights for insects - might conflict
    for (Insects insect : insects) {
      // Assuming Insect class has a display method
      insect.display(); 
    }
    popMatrix(); // Restore from insect transformations

    popMatrix(); // Restore from mummy's transformation
  }
}
