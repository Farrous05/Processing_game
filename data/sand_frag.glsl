#version 330 core

// Input from vertex shader
in vec2 vTexCoord;
in vec3 vNormal; // Received normal
in vec4 vPosition; // Received position

// Uniforms from Processing sketch
uniform sampler2D sandTextureSampler; // The sand texture
uniform float time; // Time variable for animating sparkles
uniform vec2 resolution; // Screen resolution for noise scaling

// Output color
out vec4 fragColor;

// Simple pseudo-random number generator (hash function)
float hash(vec2 p) {
    // Simple hash function
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

// Noise function (using hash)
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    f = f*f*(3.0-2.0*f);
    
    float bottom_left = hash(i + vec2(0.0, 0.0));
    float bottom_right = hash(i + vec2(1.0, 0.0));
    float top_left = hash(i + vec2(0.0, 1.0));
    float top_right = hash(i + vec2(1.0, 1.0));
    
    return mix(mix(bottom_left, bottom_right, f.x),
               mix(top_left, top_right, f.x), f.y);
}

void main() {
    // Sample the base sand texture
    vec4 baseColor = texture(sandTextureSampler, vTexCoord);
    
    // Make the base sand color lighter
    baseColor.rgb *= 1.2; // Increase brightness (adjust factor as needed)

    // --- Sparkle Effect ---
    float sparkleIntensity = 0.0;
    
    // Use screen coordinates scaled by resolution and time for noise input
    // This makes sparkles appear at fixed points on the screen that glitter
    // Adjust the scaling factor (e.g., 5.0) to change sparkle density
    vec2 screenCoord = gl_FragCoord.xy / resolution;
    float noiseVal = noise(screenCoord * 5.0 + vec2(time * 0.5)); // Add time for animation
    
    // Use a higher frequency noise or a thresholded random value for sparser sparkles
    float sparkleThreshold = 0.96; // Adjust threshold (0.9 to 0.99) for sparkle density
    float randomSpark = hash(vTexCoord + vec2(sin(time * 10.0), cos(time * 10.0)));

    if (randomSpark > sparkleThreshold) {
        // Make sparkles brighter and slightly yellowish/white
        sparkleIntensity = (randomSpark - sparkleThreshold) / (1.0 - sparkleThreshold);
        sparkleIntensity = pow(sparkleIntensity, 2.0); // Sharpen the sparkle appearance
        
        // Add sparkle color (Darker bronze/gold color)
        vec3 sparkleColor = vec3(0.6, 0.4, 0.1); // Changed from bright yellow/white
        baseColor.rgb = mix(baseColor.rgb, sparkleColor, sparkleIntensity * 0.8); // Blend sparkle color
    }
    
    // --- Basic Lighting (Optional) ---
    // Simplified directional light
    vec3 lightDir = normalize(vec3(0.5, 0.5, 1.0)); // Example light direction
    float diff = max(dot(normalize(vNormal), lightDir), 0.0);
    vec3 diffuse = vec3(diff);
    
    // Combine base color, lighting, and sparkle
    // fragColor = vec4(baseColor.rgb * diffuse, baseColor.a);
    fragColor = baseColor; // Output final color (without basic lighting for now)
} 