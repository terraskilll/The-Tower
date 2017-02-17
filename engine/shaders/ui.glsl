extern bool uIsSelected;
extern bool uIsEnabled;

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 screen_coords ){
  vec4 pixel = Texel( texture, texture_coords );

  if ( uIsSelected ){

    return pixel * color;

  }else{
    number avg = ( pixel.r + pixel.b + pixel.g ) / 3.0;

    pixel.r = avg;
    pixel.g = avg;
    pixel.b = avg;

    if ( uIsEnabled ) {
      pixel.a = 0.6f; // transparent
    }else{
      pixel.a = 0.25f; // transparent
    }

    return pixel * color;
  }

}
