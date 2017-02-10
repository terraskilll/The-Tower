vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
  vec4 pixel = Texel(texture, texture_coords );

  mat4 sepiaMatrix;

  sepiaMatrix[0] = vec4(0.393, 0.349, 0.272, 0.000);
  sepiaMatrix[1] = vec4(0.769, 0.686, 0.534, 0.000);
  sepiaMatrix[2] = vec4(0.189, 0.168, 0.131, 0.000);
	sepiaMatrix[3] = vec4(0.000, 0.000, 0.000, 1.000);

  return sepiaMatrix * pixel;
}
