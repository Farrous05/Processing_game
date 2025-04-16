#ifdef GL_ES
precision mediump float;
#endif

uniform vec3 glowColor; // Color for the glow, set from Processing
uniform float glowIntensity; // Intensity of the glow, set from Processing

varying vec4 vertColor; // Color received from vertex shader (original fill color)

void main() {
  // Basic glow: Start with the original vertex color and add the glow color scaled by intensity
  // The alpha comes from the original vertex color (or texture if we add one later)
  vec3 finalColor = vertColor.rgb + glowColor * glowIntensity;
  
  // Clamp the color to avoid exceeding 1.0 (though HDR might be desirable later)
  finalColor = clamp(finalColor, 0.0, 1.0);
  
  gl_FragColor = vec4(finalColor, vertColor.a); 
} 