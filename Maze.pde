// Maze.pde

// Structure et propriétés du labyrinthe
int[] levelSizes = {21, 19, 17};          // Taille de chaque niveau
char[][][] levelLabyrinthes;           // Stores the layout (wall '#', floor ' ', exit 'E')
char[][][][] levelSides;               // Stores wall presence and exploration data [lvl][y][x][side/explored]
float[] levelHeights = {0, 120, 240};      // Vertical position of each level

// Maze geometry shapes
PShape[] levelShapes;                // Walls shape for each level
PShape[] levelFloors;                // Floor shape for each level
PShape[] levelCeilings;              // Ceiling shape for each level

// Special positions
int[][] exitGridPositions;             // [level][x,y] coordinates of the exit/ladder up
int[][] entranceGridPositions;         // [level][x,y] coordinates of the entrance/ladder down

// Génère tous les niveaux du labyrinthe, y compris la disposition et la géométrie (murs, sols, plafonds).
void generateAllMazes() {
  println("--- Generating All Mazes ---");
  
  // Initialize maze arrays (needs to be done before the loop)
  levelLabyrinthes = new char[3][][];
  levelSides = new char[3][][][];
  levelShapes = new PShape[3];
  levelFloors = new PShape[3];
  levelCeilings = new PShape[3];
  exitGridPositions = new int[3][2];
  entranceGridPositions = new int[3][2];
  
  for (int lvl = 0; lvl < 3; lvl++) {
    int LAB_SIZE = levelSizes[lvl];
    levelLabyrinthes[lvl] = new char[LAB_SIZE][LAB_SIZE];
    levelSides[lvl] = new char[LAB_SIZE][LAB_SIZE][5];
    
    // Generate maze layout using randomized DFS
    int todig = 0;
    for (int j=0; j<LAB_SIZE; j++) {
      for (int i=0; i<LAB_SIZE; i++) {
        for (int s=0; s<5; s++) levelSides[lvl][j][i][s] = 0;
        if (j%2==1 && i%2==1) {
          levelLabyrinthes[lvl][j][i] = '.';
          todig++;
        } else {
          levelLabyrinthes[lvl][j][i] = '#';
        }
      }
    }
    
    int gx = 1;
    int gy = 1;
    while (todig>0) {
      int oldgx = gx;
      int oldgy = gy;
      int alea = floor(random(0, 4));
      if (alea==0 && gx>1) gx -= 2;
      else if (alea==1 && gy>1) gy -= 2;
      else if (alea==2 && gx<LAB_SIZE-2) gx += 2;
      else if (alea==3 && gy<LAB_SIZE-2) gy += 2;

      if (levelLabyrinthes[lvl][gy][gx] == '.') {
        todig--;
        levelLabyrinthes[lvl][gy][gx] = ' ';
        levelLabyrinthes[lvl][(gy+oldgy)/2][(gx+oldgx)/2] = ' ';
      }
    }

    // Define entrances and exits for each level
    if (lvl == 0) {
      int entranceX = LAB_SIZE / 2;
      if (entranceX % 2 == 0) entranceX++;
      int entranceY = LAB_SIZE - 2; 
      levelLabyrinthes[lvl][entranceY][entranceX] = ' '; 
      entranceGridPositions[lvl][0] = entranceX;
      entranceGridPositions[lvl][1] = entranceY;
       if (entranceY > 1) {
          levelLabyrinthes[lvl][entranceY-1][entranceX] = ' ';
       }
    } else {
      int entranceX = 1;
      int entranceY = LAB_SIZE - 2;
      levelLabyrinthes[lvl][entranceY][entranceX] = ' ';
      entranceGridPositions[lvl][0] = entranceX;
      entranceGridPositions[lvl][1] = entranceY;
       if (entranceY > 1) levelLabyrinthes[lvl][entranceY-1][entranceX] = ' ';
       if (entranceX < LAB_SIZE - 2) levelLabyrinthes[lvl][entranceY][entranceX+1] = ' ';
    }

    if (lvl < 2) {
      int exitX = LAB_SIZE - 2;
      int exitY = LAB_SIZE - 2;
      levelLabyrinthes[lvl][exitY][exitX] = 'E';
      exitGridPositions[lvl][0] = exitX;
      exitGridPositions[lvl][1] = exitY;
       if (exitY > 1) levelLabyrinthes[lvl][exitY-1][exitX] = ' ';
       if (exitX > 1) levelLabyrinthes[lvl][exitY][exitX-1] = ' ';
    } else {
      int exitX = LAB_SIZE-2;
      int exitY = LAB_SIZE / 2;
      if (exitY % 2 == 0) exitY++;
      levelLabyrinthes[lvl][exitY][exitX] = 'E';
      exitGridPositions[lvl][0] = exitX;
      exitGridPositions[lvl][1] = exitY;
       if (exitY > 1) levelLabyrinthes[lvl][exitY-1][exitX] = ' ';
       if (exitY < LAB_SIZE - 2) levelLabyrinthes[lvl][exitY+1][exitX] = ' ';
       if (exitX > 1) levelLabyrinthes[lvl][exitY][exitX-1] = ' ';
    }

    // Calculate wall sides (used for minimap/rendering checks potentially)
    for (int j=1; j<LAB_SIZE-1; j++) {
      for (int i=1; i<LAB_SIZE-1; i++) {
        if (levelLabyrinthes[lvl][j][i]==' ' || levelLabyrinthes[lvl][j][i]=='E') {
          if (j>0 && levelLabyrinthes[lvl][j-1][i]=='#' && j<LAB_SIZE-1 && levelLabyrinthes[lvl][j+1][i]==' ' &&
            i>0 && levelLabyrinthes[lvl][j][i-1]=='#' && i<LAB_SIZE-1 && levelLabyrinthes[lvl][j][i+1]=='#')
            levelSides[lvl][j-1][i][0] = 1;
          if (j>0 && levelLabyrinthes[lvl][j-1][i]==' ' && j<LAB_SIZE-1 && levelLabyrinthes[lvl][j+1][i]=='#' &&
            i>0 && levelLabyrinthes[lvl][j][i-1]=='#' && i<LAB_SIZE-1 && levelLabyrinthes[lvl][j][i+1]=='#')
            levelSides[lvl][j+1][i][3] = 1;
          if (j>0 && levelLabyrinthes[lvl][j-1][i]=='#' && j<LAB_SIZE-1 && levelLabyrinthes[lvl][j+1][i]=='#' &&
            i>0 && levelLabyrinthes[lvl][j][i-1]==' ' && i<LAB_SIZE-1 && levelLabyrinthes[lvl][j][i+1]=='#')
            levelSides[lvl][j][i+1][1] = 1;
          if (j>0 && levelLabyrinthes[lvl][j-1][i]=='#' && j<LAB_SIZE-1 && levelLabyrinthes[lvl][j+1][i]=='#' &&
            i>0 && levelLabyrinthes[lvl][j][i-1]=='#' && i<LAB_SIZE-1 && levelLabyrinthes[lvl][j][i+1]==' ')
            levelSides[lvl][j][i-1][2] = 1;
        }
      }
    }

    // Create geometry shapes (Walls, Floor, Ceiling) for the level
    float wallW = width/LAB_SIZE;
    float wallH = height/LAB_SIZE;

    PShape wallShape = createShape();
    PShape floorShape = createShape();
    PShape ceilingShape = createShape();

    wallShape.beginShape(QUADS);
    wallShape.noStroke();
    wallShape.textureMode(NORMAL);
    wallShape.texture(texture0); // Assumes texture0 is loaded (from Assets.pde)

    floorShape.beginShape(QUADS);
    floorShape.noStroke();
    floorShape.textureMode(NORMAL);
    floorShape.texture(textureFloor); // Assumes textureFloor is loaded

    ceilingShape.beginShape(QUADS);
    ceilingShape.noStroke();
    ceilingShape.textureMode(NORMAL);
    ceilingShape.texture(textureFloor); // Assumes textureFloor is loaded

    for (int j=0; j<LAB_SIZE; j++) {
      for (int i=0; i<LAB_SIZE; i++) {
        if (levelLabyrinthes[lvl][j][i]=='#') {
          // Add wall geometry (North face)
          if (j==0 || (j>0 && (levelLabyrinthes[lvl][j-1][i]==' ' || levelLabyrinthes[lvl][j-1][i]=='E'))) {
             wallShape.normal(0, -1, 0);
             wallShape.vertex(i*wallW-wallW/2, j*wallH-wallH/2, -50, 0, 1);
             wallShape.vertex(i*wallW+wallW/2, j*wallH-wallH/2, -50, 1, 1);
             wallShape.vertex(i*wallW+wallW/2, j*wallH-wallH/2,  50, 1, 0);
             wallShape.vertex(i*wallW-wallW/2, j*wallH-wallH/2,  50, 0, 0);
          }
           // Add wall geometry (South face) 
          if (j==LAB_SIZE-1 || (j<LAB_SIZE-1 && (levelLabyrinthes[lvl][j+1][i]==' ' || levelLabyrinthes[lvl][j+1][i]=='E'))) {
             wallShape.normal(0, 1, 0);
             wallShape.vertex(i*wallW-wallW/2, j*wallH+wallH/2,  50, 0, 0);
             wallShape.vertex(i*wallW+wallW/2, j*wallH+wallH/2,  50, 1, 0);
             wallShape.vertex(i*wallW+wallW/2, j*wallH+wallH/2, -50, 1, 1);
             wallShape.vertex(i*wallW-wallW/2, j*wallH+wallH/2, -50, 0, 1);
          }
           // Add wall geometry (West face)
          if (i==0 || (i>0 && (levelLabyrinthes[lvl][j][i-1]==' ' || levelLabyrinthes[lvl][j][i-1]=='E'))) {
             wallShape.normal(-1, 0, 0);
             wallShape.vertex(i*wallW-wallW/2, j*wallH-wallH/2,  50, 0, 0);
             wallShape.vertex(i*wallW-wallW/2, j*wallH+wallH/2,  50, 1, 0);
             wallShape.vertex(i*wallW-wallW/2, j*wallH+wallH/2, -50, 1, 1);
             wallShape.vertex(i*wallW-wallW/2, j*wallH-wallH/2, -50, 0, 1);
          }
           // Add wall geometry (East face)
          if (i==LAB_SIZE-1 || (i<LAB_SIZE-1 && (levelLabyrinthes[lvl][j][i+1]==' ' || levelLabyrinthes[lvl][j][i+1]=='E'))) {
             wallShape.normal(1, 0, 0);
             wallShape.vertex(i*wallW+wallW/2, j*wallH-wallH/2, -50, 0, 1);
             wallShape.vertex(i*wallW+wallW/2, j*wallH+wallH/2, -50, 1, 1);
             wallShape.vertex(i*wallW+wallW/2, j*wallH+wallH/2,  50, 1, 0);
             wallShape.vertex(i*wallW+wallW/2, j*wallH-wallH/2,  50, 0, 0);
          }
        } else {
          // Add floor geometry
          floorShape.normal(0, 0, 1);
          floorShape.vertex(i*wallW-wallW/2, j*wallH-wallH/2, -50, 0, 0);
          floorShape.vertex(i*wallW+wallW/2, j*wallH-wallH/2, -50, 1, 0);
          floorShape.vertex(i*wallW+wallW/2, j*wallH+wallH/2, -50, 1, 1);
          floorShape.vertex(i*wallW-wallW/2, j*wallH+wallH/2, -50, 0, 1);
          
          // Add ceiling geometry
          ceilingShape.normal(0, 0, -1);
          ceilingShape.vertex(i*wallW-wallW/2, j*wallH-wallH/2, 50, 0, 1);
          ceilingShape.vertex(i*wallW+wallW/2, j*wallH-wallH/2, 50, 1, 1);
          ceilingShape.vertex(i*wallW+wallW/2, j*wallH+wallH/2, 50, 1, 0);
          ceilingShape.vertex(i*wallW-wallW/2, j*wallH+wallH/2, 50, 0, 0);
        }
      }
    }

    wallShape.endShape();
    floorShape.endShape();
    ceilingShape.endShape();

    // Spawn mummies for this level
    int numMummiesToSpawn = 0;
    if (lvl == 0) {
      numMummiesToSpawn = 3;
    } else if (lvl == 1) {
      numMummiesToSpawn = 2;
    } else if (lvl == 2) {
      numMummiesToSpawn = 1;
    }
    
    // Check mummyAssetsLoaded (declared in Assets.pde)
    if (mummyAssetsLoaded) { 
      spawnMummies(lvl, numMummiesToSpawn); // Calls spawnMummies() in Main.pde (for now)
    } else {
      println("Skipping mummy spawn for level " + lvl + " due to asset loading failure.");
    }
    
    // Store the generated shapes
    levelShapes[lvl] = wallShape;
    levelFloors[lvl] = floorShape;
    levelCeilings[lvl] = ceilingShape;
  }
  
  println("--- Finished Generating All Mazes ---");
} 