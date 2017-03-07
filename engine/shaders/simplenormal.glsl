// base on https://love2d.org/forums/viewtopic.php?f=1&t=11076


extern vec3 uLightPosition[5];
extern vec3 uLightDiffuse[5];

// calculate luminance from linear rgb
float luminance( vec3 light ) {
   return dot( light, vec3( 0.2126, 0.7152, 0.0722 ) );
}

vec4 effect( vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords ) {
   vec4 diffuse = pow( Texel( texture, texture_coords ), vec4(2.2) );
   vec4 channels = Texel( texture, texture_coords + vec2( 0.66667, 0 ) );

   float ambientOcclusion = channels.r;
   float bypass = channels.g;

   vec3 normal = Texel( texture, texture_coords + vec2(0.3333, 0) ).rgb;
   normal.y = 1 - normal.y;
   normal = normalize(mix(vec3(-1), vec3(1), normal));

   vec3 light    = vec3(0);
   vec3 celLight = vec3(0);

   for (int i = 0; i < uLightPosition.length(); i++ ) {

      vec3 lightDirection = uLightPosition[i] - vec3( pixel_coords, 0 );
      float dist = length( lightDirection );
      float attenuation = smoothstep( 100, 50, dist );
      lightDirection = normalize( lightDirection );

      vec3 currentLight = clamp( dot( normal, lightDirection), 0.0, 1.0) * uLightDiffuse[i] * attenuation * ( ambientOcclusion * 0.7 + 0.3 );

      light += currentLight;

      celLight += step( 0.2, ( currentLight.r + currentLight.g + currentLight.b) / 3.0 ) * currentLight * diffuse.rgb;
   }

   vec3 darkColor = vec3(0.0, 0.0, 1.0); // TODO set by extern
   vec3 lightColor = vec3(0.25, 0.25, 0.0); // TODO set by extern

   vec3 goochLight = mix( darkColor, lightColor, luminance( light ) ) * 0.06;
   vec3 ambient = diffuse.rgb * 0.06;

   vec3 finalLight = pow( goochLight + ambient + celLight, vec3(0.4545) );

   return vec4( mix( diffuse.rgb, finalLight, bypass ), diffuse.a );
}
