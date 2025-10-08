shader_type canvas_item;

// Blur
uniform float blur_amount: hint_range(0.0, 5.0) = 4.0;

// Glassmorphism
uniform float brightness: hint_range(0.5, 2.0) = 1.2;
uniform float saturation: hint_range(0.5, 2.0) = 1.15;
uniform vec4 tint_color: source_color = vec4(0.95, 0.95, 1.0, 0.15);

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

// Ajustar saturación
vec3 adjust_saturation(vec3 color, float adjustment) {
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    return mix(vec3(luminance), color, adjustment);
}

void fragment() {
    // 1. Obtener fondo con blur
    vec3 blurred = textureLod(screen_texture, SCREEN_UV, blur_amount).rgb;
    
    // 2. Aplicar glassmorphism
    blurred *= brightness;
    blurred = adjust_saturation(blurred, saturation);
    
    // 3. Aplicar tinte sutil
    vec3 final_color = mix(blurred, tint_color.rgb, tint_color.a);
    
    COLOR.rgb = final_color;
    COLOR.a = 0.95; // Opacidad del taskbar
}