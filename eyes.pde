// Crée les formes pour les yeux de la momie (pupilles et globes oculaires).
PShape createEyes() {
  PShape leftPupil = createShape(SPHERE,3 );
  leftPupil.setFill(color(#8B0000));
  leftPupil.setStroke(false);
  leftPupil.scale(1,1.6);
  leftPupil.translate(-20, -155,48);
  PShape rightPupil = createShape(SPHERE,3 );
  rightPupil.setFill(color(#8B0000));
  rightPupil.setStroke(false);
  rightPupil.scale(1,1.6);
  rightPupil.translate(20, -155,48);

  PShape leftEye = createShape(SPHERE,6);
  leftEye.setFill(color(230));
  leftEye.setStroke(false);
  leftEye.scale(1.6,1);
  leftEye.translate(-20, -155,43);
  PShape rightEye = createShape(SPHERE, 6);
  rightEye.setFill(color(230));
  rightEye.setStroke(false);
  rightEye.scale(1.6,1);
  rightEye.translate(20,-155,43);

  PShape Eyes = createShape(GROUP);
  Eyes.addChild(leftPupil);
  Eyes.addChild(leftEye);
  Eyes.addChild(rightPupil);
  Eyes.addChild(rightEye);

  return Eyes;
}
