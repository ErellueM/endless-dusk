shader_type canvas_item;

uniform vec4 bg_color : source_color = vec4(0.0, 0.078, 0.267, 1.0);
uniform vec4 soul_color : source_color = vec4(0.1, 0.3, 0.6, 1.0);
uniform float speed = 0.6;

// NEU: Hier empfängt der Shader deine Zeit aus dem GDScript!
uniform float custom_time = 0.0; 

void fragment() {
    // Wir nutzen jetzt 'custom_time' statt 'TIME'
    float wave1 = sin(UV.x * 4.0 - custom_time * speed);
    float wave2 = sin(UV.x * 2.5 + UV.y * 2.0 - custom_time * (speed * 0.8));

    float flow = (wave1 + wave2) * 0.5;
    flow = smoothstep(-0.2, 0.8, flow);

    float intensity = flow * 0.25;
    vec4 final_color = mix(bg_color, soul_color, intensity);

    COLOR = vec4(final_color.rgb, final_color.a * texture(TEXTURE, UV).a);
}