// Gère les entrées clavier pour les actions du joueur (mouvement, interaction, redémarrage, etc.).
void keyPressed() {
  if (key=='r' || key=='R') {
    restartGame();
    return;
  }

  if (key=='e' || key=='E') {
    if (outsidePyramid) {
      enterPyramid();
    } else {
      showExterior = !showExterior;
    }
    return;
  }

  if (key=='l' || key=='L') {
     inLab = !inLab;
     return;
  }

  if (inTransition || isClimbingStairs || outsidePyramid) return;

  int LAB_SIZE = levelSizes[currentLevel];

  if (anim==0 && (key == 'z' || key == 'Z')) {
    int newX = posX+dirX;
    int newY = posY+dirY;
    if (newX>=0 && newX<LAB_SIZE && newY>=0 && newY<LAB_SIZE &&
      levelLabyrinthes[currentLevel][newY][newX]!='#') {
      posX = newX;
      posY = newY;
      anim=20;
      animT = true;
      animR = false;
      updateExploredArea();
    }
  }
  if (anim==0 && (key == 's' || key == 'S')) {
    int newX = posX-dirX;
    int newY = posY-dirY;
    if (newX>=0 && newX<LAB_SIZE && newY>=0 && newY<LAB_SIZE &&
      levelLabyrinthes[currentLevel][newY][newX]!='#') {
      posX = newX;
      posY = newY;
      updateExploredArea();
    }
  }

  if (anim==0 && (keyCode==LEFT || key == 'q' || key == 'Q')) {
    odirX = dirX;
    odirY = dirY;
    anim = 20;
    int tmp = dirX;
    dirX=dirY;
    dirY=-tmp;
    animT = false;
    animR = true;
  }
  if (anim==0 && (keyCode==RIGHT || key == 'd' || key == 'D')) {
    odirX = dirX;
    odirY = dirY;
    anim = 20;
    animT = false;
    animR = true;
    int tmp = dirX;
    dirX=-dirY;
    dirY=tmp;
  }
}
