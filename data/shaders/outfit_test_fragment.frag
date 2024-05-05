#version 330 core

in vec2 TexCoords;
out vec4 color;

uniform sampler2D scene;

void main()
{    
    vec4 originalColor = texture(scene, TexCoords);
    vec4 glowColor = vec4(1.0, 0.7, 0.3, 1.0); // Brilho constante
    float dist = distance(TexCoords, vec2(0.5, 0.5));
    color = mix(originalColor, glowColor, smoothstep(0.4, 0.45, dist));
}
