#version 330 core

// Default Processing attributes
in vec4 position;
in vec2 texCoord;
in vec3 normal; // Include normal for potential lighting

// Default Processing uniforms
uniform mat4 transform;
uniform mat3 normalMatrix; // For transforming normals

// Varying variables to pass to fragment shader
out vec2 vTexCoord;
out vec3 vNormal;
out vec4 vPosition; // Position in eye space for lighting

void main() {
    gl_Position = transform * position;
    vPosition = gl_Position; // Pass eye-space position (or world space if needed)
    vTexCoord = texCoord;
    vNormal = normalize(normalMatrix * normal); // Pass transformed normal
} 