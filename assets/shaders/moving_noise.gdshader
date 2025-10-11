shader_type canvas_item;
render_mode blend_mix;

// Variables customizables
uniform float time_scale : hint_range(0.0, 5.0) = 1.0;
uniform float noise_scale : hint_range(0.1, 10.0) = 1.0;
uniform float pattern_intensity : hint_range(0.0, 2.0) = 1.0;
uniform vec2 pattern_offset = vec2(0.0, 0.0);
uniform float warp_strength : hint_range(0.0, 2.0) = 1.0;

// Colores del mapa de color (puntos de control)
uniform bool use_custom_colors = false;
uniform vec4 color_low : source_color = vec4(0.212, 0.0, 0.212, 1.0);
uniform vec4 color_mid : source_color = vec4(1.0, 0.5, 0.0, 1.0);
uniform vec4 color_high : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float color_mid_position : hint_range(0.0, 1.0) = 0.5;

// Parámetros de FBM
uniform int octaves : hint_range(1, 8) = 6;
uniform float fbm_lacunarity : hint_range(1.0, 4.0) = 2.0;
uniform float fbm_gain : hint_range(0.0, 1.0) = 0.5;

float colormap_red(float x) {
    if (x < 0.0) {
        return 54.0 / 255.0;
    } else if (x < 20049.0 / 82979.0) {
        return (829.79 * x + 54.51) / 255.0;
    } else {
        return 1.0;
    }
}

float colormap_green(float x) {
    if (x < 20049.0 / 82979.0) {
        return 0.0;
    } else if (x < 327013.0 / 810990.0) {
        return (8546482679670.0 / 10875673217.0 * x - 2064961390770.0 / 10875673217.0) / 255.0;
    } else if (x <= 1.0) {
        return (103806720.0 / 483977.0 * x + 19607415.0 / 483977.0) / 255.0;
    } else {
        return 1.0;
    }
}

float colormap_blue(float x) {
    if (x < 0.0) {
        return 54.0 / 255.0;
    } else if (x < 7249.0 / 82979.0) {
        return (829.79 * x + 54.51) / 255.0;
    } else if (x < 20049.0 / 82979.0) {
        return 127.0 / 255.0;
    } else if (x < 327013.0 / 810990.0) {
        return (792.02249341361393720147485376583 * x - 64.364790735602331034989206222672) / 255.0;
    } else {
        return 1.0;
    }
}

vec4 colormap(float x) {
    return vec4(colormap_red(x), colormap_green(x), colormap_blue(x), 1.0);
}

vec4 custom_colormap(float x) {
    if (x < color_mid_position) {
        // Interpolar entre color_low y color_mid
        float t = x / color_mid_position;
        return mix(color_low, color_mid, t);
    } else {
        // Interpolar entre color_mid y color_high
        float t = (x - color_mid_position) / (1.0 - color_mid_position);
        return mix(color_mid, color_high, t);
    }
}

// Simplex 2D noise
vec3 permute(vec3 x) { return mod(((x*34.0)+1.0)*x, 289.0); }

float snoise(vec2 v){
    const vec4 C = vec4(0.211324865405187, 0.366025403784439,
                        -0.577350269189626, 0.024390243902439);
    vec2 i  = floor(v + dot(v, C.yy) );
    vec2 x0 = v -   i + dot(i, C.xx);
    vec2 i1;
    i1 = (x0.x > x0.y) ? vec2(1.0, 0.0) : vec2(0.0, 1.0);
    vec4 x12 = x0.xyxy + C.xxzz;
    x12.xy -= i1;
    i = mod(i, 289.0);
    vec3 p = permute( permute( i.y + vec3(0.0, i1.y, 1.0 ))
    + i.x + vec3(0.0, i1.x, 1.0 ));
    vec3 m = max(0.5 - vec3(dot(x0,x0), dot(x12.xy,x12.xy),
    dot(x12.zw,x12.zw)), 0.0);
    m = m*m ;
    m = m*m ;
    vec3 x = 2.0 * fract(p * C.www) - 1.0;
    vec3 h = abs(x) - 0.5;
    vec3 ox = floor(x + 0.5);
    vec3 a0 = x - ox;
    m *= 1.79284291400159 - 0.85373472095314 * ( a0*a0 + h*h );
    vec3 g;
    g.x  = a0.x  * x0.x  + h.x  * x0.y;
    g.yz = a0.yz * x12.xz + h.yz * x12.yw;
    return 130.0 * dot(m, g);
}

float noise(vec2 p){
    // Convertir de rango [-1,1] a [0,1] y elevar al cuadrado como el original
    float n = snoise(p) * 0.5 + 0.5;
    return n * n;
}

const mat2 mtx = mat2(vec2(0.80, 0.60), vec2(-0.60, 0.80));

float fbm(vec2 p) {
    float f = 0.0;
    float amplitude = 0.5;
    float total_amplitude = 0.0;
    
    // Primera octava con tiempo
    f += amplitude * noise(p + TIME * time_scale);
    total_amplitude += amplitude;
    p = mtx * p * 2.02;
    amplitude *= 0.5;
    
    // Segunda octava
    f += amplitude * noise(p);
    total_amplitude += amplitude;
    p = mtx * p * 2.01;
    amplitude *= 0.5;
    
    // Tercera octava
    f += amplitude * noise(p);
    total_amplitude += amplitude;
    p = mtx * p * 2.03;
    amplitude *= 0.5;
    
    // Cuarta octava
    f += amplitude * noise(p);
    total_amplitude += amplitude;
    p = mtx * p * 2.01;
    amplitude *= 0.5;
    
    // Quinta octava
    f += amplitude * noise(p);
    total_amplitude += amplitude;
    p = mtx * p * 2.04;
    amplitude *= 0.5;
    
    // Sexta octava con sin(tiempo)
    f += amplitude * noise(p + sin(TIME * time_scale));
    total_amplitude += amplitude;
    
    return f / total_amplitude;
}

float pattern(in vec2 p) {
    return fbm(p + fbm(p + fbm(p) * warp_strength) * warp_strength);
}

void fragment() {
    // Replicar exactamente el comportamiento de ShaderToy
    // UV ya está en 0-1, así que lo escalamos al tamaño del rect
    vec2 resolution = 1.0 / SCREEN_PIXEL_SIZE;
    vec2 fragCoord = UV * resolution;
    
    // ShaderToy: vec2 uv = fragCoord/iResolution.x;
    vec2 uv = fragCoord / resolution.x;
    uv = uv * noise_scale + pattern_offset;
    
    float shade = pattern(uv) * pattern_intensity;
    shade = clamp(shade, 0.0, 1.0);
    
    vec4 color;
    if (use_custom_colors) {
        color = custom_colormap(shade);
    } else {
        color = colormap(shade);
    }
    
    COLOR = vec4(color.rgb, shade);
}