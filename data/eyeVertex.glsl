uniform mat4 transform;

attribute vec4 position;
attribute vec4 color;

varying vec4 vertColor;

void main() {
  // Basic pass-through vertex shader
  gl_Position = transform * position;
  vertColor = color; // Pass the vertex color (set in Processing) to the fragment shader
} 