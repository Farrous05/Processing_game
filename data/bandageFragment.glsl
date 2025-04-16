#ifdef GL_ES
precision mediump float;
precision mediump int;
#endif

uniform sampler2D bandageTexture;
uniform float time;

varying vec4 vertColor;
varying vec4 vertTexCoord;
varying vec3 vertNormal;
varying vec3 vertLightDir;
varying vec3 vertViewDir;
varying vec3 fragPosition;
varying float facingFactor;

// Lighting parameters
const float ambientStrength = 0.5;
const float diffuseStrength = 0.9;
const float specularStrength = 0.2;
const float shininess = 12.0;
const vec3 lightColor = vec3(1.0, 0.95, 0.8); // Slightly yellow tomb light

// Simple pseudo-random function (noise substitute)
float rand(vec2 co){
    return fract(sin(dot(co.xy ,vec2(12.9898,78.233))) * 43758.5453);
}

void main() {
  // Sample the texture
  vec4 texColor = texture2D(bandageTexture, vertTexCoord.st);
  
  // Use the normal from vertex shader
  vec3 normal = normalize(vertNormal);
  
  // Calculate how directly this fragment faces forward (0-1)
  float frontFacing = max(facingFactor, 0.0);
  
  // Calculate ambient lighting
  vec3 ambient = ambientStrength * lightColor;
  
  // Calculate diffuse lighting
  float diffuse = frontFacing * diffuseStrength;
  
  // Calculate specular lighting (Blinn-Phong)
  vec3 halfwayDir = normalize(vertLightDir + vertViewDir);
  float specular = pow(max(dot(normal, halfwayDir), 0.0), shininess) * specularStrength * frontFacing;
  
  // Static material effects - non-animated
  // Simplified depth variation based only on position
  float depthVariation = 0.1;
  
  // Create a drying/dusty effect on top surfaces
  float dustEffect = max(0.0, dot(vec3(0.0, -1.0, 0.0), normal)) * 0.1;
  
  // Shadow effect on surfaces facing away from front
  float shadowStrength = 0.5; // Reduced from 0.7 - How dark the shadows get (0-1)
  float shadowEffect = clamp((1.0 - frontFacing) * 1.5, 0.0, shadowStrength);
  
  // --- Color Modification ---

  // 1. Base color from texture and randomized vertex color (tint)
  vec3 baseColor = texColor.rgb * vertColor.rgb;

  // 2. REMOVED mixing with fixed ancient color. Use baseColor directly.
  vec3 bandageColor = baseColor; // Start with the tinted texture color
  /*
  // --- PREVIOUS CODE ---
  // Apply ancient, aged coloring, mixing with the base tint - Removed randomMix
  // Make the yellow-brown mix factor also slightly randomized - REMOVED
  // float randomMix = rand(vertTexCoord.st * 50.0) * 0.2 + 0.05; // Small random variation - REMOVED
  vec3 bandageColor = mix(
    baseColor, 
    vec3(0.85, 0.78, 0.65), // Darker Yellow-brown ancient cloth color
    depthVariation + dustEffect // Use only depth and dust for mixing - REMOVED randomMix
  );
  // --- END PREVIOUS CODE ---
  */

  // 3. Apply dust effect (slightly darken upward-facing surfaces)
  // Make dust effect slightly stronger
  bandageColor = mix(bandageColor, bandageColor * 0.85, dustEffect * 1.5); 

  // 4. Apply shadow to areas not facing forward
  bandageColor = mix(
    bandageColor,
    bandageColor * 0.5, // Darkened color for shadow
    shadowEffect
  );
  
  // --- End Color Modification ---

  // Combine all lighting components
  vec3 lighting = (ambient + diffuse * lightColor) + specular * lightColor;
  
  // Final color with lighting
  gl_FragColor = vec4(bandageColor * lighting, texColor.a);
} 