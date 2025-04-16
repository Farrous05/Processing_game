// Dessine les informations de l'interface utilisateur (niveau actuel, contrôles) à l'écran.
void drawUIInformation() {
  textFont(uiFont);

  textAlign(RIGHT, BOTTOM);
  fill(255);
  textSize(20);
  
  if (outsidePyramid) {
    text("Outside the Pyramid", width - 20, height - 20); 
  } else {
    String levelText = "";
    if (currentLevel == 0) {
      levelText = "Level 1 of 3";
    } else if (currentLevel == 1) {
      levelText = "Level 2 of 3";
    } else if (currentLevel == 2) {
      levelText = "Level 3 of 3";
    }
    text(levelText, width - 20, height - 20); 
  }
  
  textAlign(LEFT, BOTTOM);
  textSize(16);
  if (outsidePyramid) {
    text("Outside View: Z/S - Move Forward/Back, Q/D - Strafe, Arrows - Look, R - Restart", 20, height - 20);
  } else {
    text("Controls: Z - Forward, S - Backward, Q/Left Arrow - Turn Left, D/Right Arrow - Turn Right, R - Restart", 20, height - 20);
  }
}

// Affiche un message de sortie (probablement inutilisé maintenant).
// NOTE: showExitMessage() is likely unused now that drawVictoryScreen exists.
// Consider removing this function during variable/function cleanup phase.
void showExitMessage() {
  fill(0, 0, 0, 200);
  rect(0, 0, width, height);
  
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(32);
  text("Congratulations! You've made it to the top of the pyramid!", width/2, height/2 - 40);
  textSize(24);
  text("Explore the exterior using AZERTY keys", width/2, height/2 + 10);
  textSize(18);
  text("Press R to restart", width/2, height/2 + 50);
  
  if (frameCount % 180 == 0) {
    outsidePyramid = true;
  }
}
