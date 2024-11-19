// Thanks for the help dear LLM.
shader_type canvas_item;

uniform vec4 shine_color : source_color = vec4(1.0);
uniform float shine_speed : hint_range(0.01, 5.0, 0.01) = 1.0; // Speed of shine animation
uniform float shine_size : hint_range(0.01, 1.0, 0.01) = 0.1;
uniform float shine_angle : hint_range(0.0, 360.0, 0.1) = 45.0;
uniform float shine_pause : hint_range(0.0, 2.0, 0.01) = 0.5; // Pause duration as a fraction of the total cycle

float scale(float value, float inMin, float inMax, float outMin, float outMax) {
    return (value - inMin) * (outMax - outMin) / (inMax - inMin) + outMin;
}

void fragment() {
    COLOR = texture(TEXTURE, UV);

    // Calculate the direction vector based on the angle
    vec2 direction = vec2(cos(radians(shine_angle)), sin(radians(shine_angle)));

    // Total cycle duration including active and pause phases
    float cycle_duration = 1.0 + shine_pause;

    // Modulate progress through the entire cycle
    float raw_progress = mod(TIME * shine_speed, cycle_duration);

    // Shine progress during the active phase only
    float shine_progress = raw_progress / 1.0;

    // Ensure the shine is active only during the first part of the cycle
    if (raw_progress > 1.0) {
        shine_progress = -1.0; // Shine is inactive during the pause phase
    }

    // Scale shine_progress to move fully across the diagonal
    float progress = scale(shine_progress, 0.0, 1.0, -1.0 - shine_size, 1.0 + shine_size);

    // Calculate the shine distance
    float shine = step(dot(UV, direction), progress + shine_size) - step(dot(UV, direction), progress);

    // Apply the shine effect
    COLOR.rgb = mix(COLOR.rgb, shine_color.rgb, shine * shine_color.a);
}
