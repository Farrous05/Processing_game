// Assets.pde

// Variables pour les textures
PImage texture0;       // Texture des murs
PImage textureFloor;   // Texture du sol
PImage textureStairs;  // Texture des escaliers
PImage sandTexture;    // Texture procédurale du sable pour l'extérieur
PImage heartImage;     // Image UI pour la santé du joueur (supposée chargée ou créée)

// Variables pour les sons
SoundFile ambientSound;
SoundFile transitionSound;
SoundFile mummyChaseSound;
SoundFile stairsSound;
SoundFile desertSound;
SoundFile damageSound;
SoundFile gameOverSound;
SoundFile victorySound;

// Mummy Assets
PImage mummyTexture;
PShader mummyBodyShader;
PShader mummyEyeShader;
boolean mummyAssetsLoaded = false; // Flag to check if mummy assets loaded successfully

// Sarcophagus Assets
PShape sarcophagusBack;
PShape sarcophagusFront;

// Font Assets
PFont uiFont;

// Victory Screen Assets
Gif victoryGif;

// Charge toutes les ressources du jeu (textures, sons, modèles, polices).
void loadAllAssets() {
  println("--- Loading All Assets ---");

  // --- Load Font ---
  try {
    uiFont = createFont("Arial Black", 16);
    if (uiFont == null) throw new Exception("Failed to load font");
    println("UI Font loaded successfully.");
  } catch (Exception e) {
    println("Error loading UI Font: " + e.getMessage() + ". Using default font.");
    // If font loading fails, Processing will use a default font
  }

  // --- Load Image Textures ---
  texture0 = loadImage("stones.jpg");
  if (texture0 == null) {
    println("Error: Could not load stones.jpg");
    texture0 = createImage(100, 100, RGB);
    texture0.loadPixels();
    for (int i = 0; i < texture0.pixels.length; i++) {
      texture0.pixels[i] = color(random(100, 200), random(100, 200), random(100, 200));
    }
    texture0.updatePixels();
  }

  textureFloor = loadImage("floor.jpg");
  if (textureFloor == null) {
    println("Error: Could not load floor.jpg. Using procedural fallback.");
    textureFloor = createImage(100, 100, RGB);
    textureFloor.loadPixels();
    for (int i = 0; i < textureFloor.pixels.length; i++) {
      int gray = int(random(180, 220));
      textureFloor.pixels[i] = color(gray, gray, gray-10);
    }
    textureFloor.updatePixels();
  }

  if (textureStairs == null) {
    println("Error: Could not load stairs.png. Using stone texture as fallback.");
    textureStairs = texture0;
  }

  // --- Procedural Sand Texture Generation ---
  int sandTexWidth = 256;
  int sandTexHeight = 256;
  sandTexture = createImage(sandTexWidth, sandTexHeight, RGB);
  sandTexture.loadPixels();
  float noiseScaleBase = 0.04;
  float noiseScaleDetail = 0.3;
  float noiseStrengthBase = 45;
  float noiseStrengthDetail = 25;
  for (int y = 0; y < sandTexHeight; y++) {
    for (int x = 0; x < sandTexWidth; x++) {
      float nxb = x * noiseScaleBase;
      float nyb = y * noiseScaleBase;
      float noiseValBase = noise(nxb, nyb);
      float nxd = x * noiseScaleDetail;
      float nyd = y * noiseScaleDetail;
      float noiseValDetail = noise(nxd, nyd);
      float baseR = 194;
      float baseG = 178;
      float baseB = 128;
      float r = baseR + (noiseValBase - 0.5) * noiseStrengthBase;
      float g = baseG + (noiseValBase - 0.5) * noiseStrengthBase;
      float b = baseB + (noiseValBase - 0.5) * noiseStrengthBase;
      float brightnessFactor = map(noiseValDetail, 0, 1, 1.0 - noiseStrengthDetail / 100.0, 1.0 + noiseStrengthDetail / 100.0);
      r *= brightnessFactor;
      g *= brightnessFactor;
      b *= brightnessFactor;
      r = constrain(r, 0, 255);
      g = constrain(g, 0, 255);
      b = constrain(b, 0, 255);
      int index = x + y * sandTexWidth;
      sandTexture.pixels[index] = color(r, g, b);
    }
  }
  sandTexture.updatePixels();
  println("Procedural sand texture generated.");

  // --- Load Mummy Assets ---
  println("Loading Mummy assets...");
  try {
    mummyTexture = loadImage("bandageTexture1.jpg");
    if (mummyTexture == null) throw new Exception("Failed to load bandageTexture1.jpg");

    mummyBodyShader = loadShader("bandageFragment.glsl", "bandageVertex.glsl");
    if (mummyBodyShader == null) throw new Exception("Failed to load bandage shader");
    mummyBodyShader.set("bandageTexture", mummyTexture);

    mummyEyeShader = loadShader("eyeFragment.glsl", "eyeVertex.glsl");
    if (mummyEyeShader == null) throw new Exception("Failed to load eye shader");
    mummyEyeShader.set("glowColor", 139.0/255.0, 0.0/255.0, 0.0/255.0);
    mummyEyeShader.set("glowIntensity", 0.7);

    mummyAssetsLoaded = true;
    println("Mummy assets loaded successfully.");
  } catch (Exception e) {
    println("Error loading Mummy assets: " + e.getMessage());
    mummyAssetsLoaded = false;
  }

  // --- Load Sarcophagus Models ---
  println("Loading Sarcophagus models...");
  try {
    sarcophagusBack = loadShape("objets3d/BackSarcophagus.obj");
    if (sarcophagusBack == null) throw new Exception("Failed to load objets3d/BackSarcophagus.obj");

    sarcophagusFront = loadShape("objets3d/FrontSarcophagus.obj");
    if (sarcophagusFront == null) throw new Exception("Failed to load objets3d/FrontSarcophagus.obj");
    
    println("Sarcophagus models loaded successfully.");
  } catch (Exception e) {
    println("Error loading Sarcophagus models: " + e.getMessage());
    sarcophagusBack = null;
    sarcophagusFront = null;
  }

  // --- Load Sounds ---
  println("Loading sounds...");
  try {
    ambientSound = new SoundFile(this, "ambient.wav");
    if (ambientSound != null) {
      ambientSound.loop();
      println("Ambient sound loaded and looping.");
    } else {
      println("Error: Could not load ambient sound file.");
    }
  
    transitionSound = new SoundFile(this, "transition.wav");
     if (transitionSound != null) {
      println("Transition sound loaded.");
    } else {
      println("Error: Could not load transition sound file.");
    }
    
    mummyChaseSound = new SoundFile(this, "M.wav");
    if (mummyChaseSound != null) {
        println("Mummy chase sound loaded.");
    } else {
        println("Error: Could not load mummy chase sound file (M.wav).");
    }
  
    stairsSound = new SoundFile(this, "stairs.wav");
    if (stairsSound != null) {
        println("Stairs climbing sound loaded.");
    } else {
        println("Error: Could not load stairs sound file (stairs.wav).");
    }
  
    desertSound = new SoundFile(this, "desert.wav");
    if (desertSound != null) {
        println("Desert ambient sound loaded.");
    } else {
        println("Error: Could not load desert sound file (desert.wav).");
    }
  
    damageSound = new SoundFile(this, "damage.wav");
    if (damageSound != null) {
        println("Damage sound loaded.");
    } else {
        println("Error: Could not load damage sound file (damage.wav).");
    }
  
    gameOverSound = new SoundFile(this, "gameover.wav");
    if (gameOverSound != null) {
        println("Game over sound loaded.");
    } else {
        println("Error: Could not load game over sound file (gameover.wav).");
    }
  
    victorySound = new SoundFile(this, "fortnite.wav");
    if (victorySound != null) {
        println("Victory sound loaded.");
    } else {
        println("Error: Could not load victory sound file (fortnite.wav).");
    }
  
  } catch (Exception e) {
    println("Error loading sounds: " + e.getMessage());
    e.printStackTrace();
  }

  // --- Load Victory GIF ---
  println("Loading victory GIF...");
  try {
    victoryGif = new Gif(this, "sphinx.gif");
    if (victoryGif != null) {
      victoryGif.loop();
      println("Victory GIF loaded successfully.");
    } else {
      println("Error: Could not load victory GIF file (sphinx.gif).");
    }
  } catch (Exception e) {
    println("Error loading victory GIF: " + e.getMessage());
    e.printStackTrace();
  }
  
  println("--- Finished Loading All Assets ---");
} 
