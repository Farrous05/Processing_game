uniform mat4 transform;
uniform mat4 modelview;
uniform mat3 normalMatrix;
uniform mat4 texMatrix;
uniform float time;

attribute vec4 position;
attribute vec4 color;
attribute vec3 normal;
attribute vec2 texCoord;

varying vec4 vertColor;
varying vec4 vertTexCoord;
varying vec3 vertNormal;
varying vec3 vertLightDir;
varying vec3 vertViewDir;
varying vec3 fragPosition;
varying float facingFactor;

void main() {
  // Calculate a subtle waving motion
  float waveSpeed = 3;
  float waveAmplitude = 2;
  float displacementFactor = sin(position.y * 0.08 + position.x * 0.02 + time * waveSpeed);
  vec3 displacement = normal * displacementFactor * waveAmplitude;
  vec4 displacedPosition = position + vec4(displacement, 0.0);

  // Calculate the vertex position in model view space using the displaced position
  vec4 viewPosition = modelview * displacedPosition;
  
  // Pass the displaced position to the fragment shader
  fragPosition = displacedPosition.xyz;
  
  // Calculate and pass the normal
  vertNormal = normalize(normalMatrix * normal);
  
  // Calculate the view direction (for specular lighting)
  vertViewDir = -normalize(viewPosition.xyz);
  
  // Fixed light direction - coming from directly in front of the mummy
  vertLightDir = normalize(vec3(0.0, 0.0, 1.0));
  
  // Calculate facing factor (how directly the vertex faces forward)
  facingFactor = dot(vertNormal, vertLightDir);
  
  // Pass the color
  vertColor = color;
  
  // Pass the texture coordinates
  vertTexCoord = texMatrix * vec4(texCoord, 0, 1);
  
  // Calculate the final position using the displaced position
  gl_Position = transform * displacedPosition;
} 