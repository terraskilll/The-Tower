extern float uLightX;
extern float uLightY;
extern float uSize;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
  vec4 pixel = Texel( texture, vec2( texture_coords.x, texture_coords.y ) );

  float root = sqrt(16 * ( uLightX - texture_coords.x ) * ( uLightX - texture_coords.x ) / 9 +
                         ( uLightY - texture_coords.y ) * ( uLightY - texture_coords.y ) );

  pixel.r = clamp(pixel.r * 0.65 * root/ uSize, 0, 1);
  pixel.g = clamp(pixel.g * 0.65 * root/ uSize, 0, 1);
  pixel.b = clamp(pixel.b * 0.65 * root/ uSize, 0, 1);
  pixel.a = 0.5;

  return pixel * color;
}
