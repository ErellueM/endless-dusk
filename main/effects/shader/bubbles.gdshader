shader_type canvas_item;

// --- FARBEN ---
uniform vec4 color_fill : source_color = vec4(0.9, 0.1, 0.1, 1.0); // Helles Rot (die "Brocken")
uniform vec4 color_empty : source_color = vec4(0.4, 0.0, 0.0, 1.0); // Dunkles Rot (der Zwischenraum)

// --- NOISE TEXTUR ---
// WICHTIG: filter_nearest sorgt für harte Kanten!
uniform sampler2D noise_tex : filter_nearest, repeat_enable;

// --- EINSTELLUNGEN ---
uniform float speed_x : hint_range(-2.0, 2.0) = 0.5; // Bewegung horizontal
uniform float speed_y : hint_range(-2.0, 2.0) = 0.2; // Bewegung vertikal
uniform float chunk_size : hint_range(1.0, 100.0) = 20.0; // Wie grob sind die Pixel-Klötze? (Kleiner = Gröber)
uniform float density : hint_range(0.0, 1.0) = 0.5; // Wieviel ist gefüllt?

void fragment() {
	// 1. Verpixeln (Pixelation)
	// Wir runden die UV-Koordinaten auf ein grobes Raster.
	// Je kleiner 'chunk_size', desto größer die Klötze.
	vec2 pixel_uv = floor(UV * chunk_size) / chunk_size;

	// 2. Bewegung
	vec2 moving_uv = pixel_uv + vec2(TIME * speed_x, TIME * speed_y);

	// 3. Noise sampeln
	// Wir holen den Wert aus der Textur an der verpixelten Stelle.
	float noise_val = texture(noise_tex, moving_uv).r;

	// 4. Harte Entscheidung (Step)
	// Ist der Noise-Wert größer als die Dichte? Dann Farbe A, sonst Farbe B.
	// Das step() sorgt dafür, dass es keine weichen Übergänge gibt.
	float is_fill_block = step(density, noise_val);

	// 5. Farbe mischen
	vec4 final_color = mix(color_empty, color_fill, is_fill_block);

	// 6. Auf den Balken anwenden
	// Wir nehmen die berechnete Farbe und multiplizieren sie mit dem Alpha
	// der ursprünglichen Textur (damit der Balken auch leer werden kann).
	COLOR = final_color;
	COLOR.a *= texture(TEXTURE, UV).a;
}