
extern vec2 uResolution;

extern vec3 uLightPosition;

extern vec3 uAmbientLight;
extern vec3 uDiffuseLight;
extern vec3 uSpecularLight;

extern vec3 uAmbientMaterial;
extern vec3 uDiffuseMaterial;
extern vec3 uSpecularMaterial;
//extern float uSpecularIntensity;

extern sampler2D uTexture;
extern sampler2D uNormalMap;

extern vec3 uAttenuation;

extern float uMapStrength;

extern bool uInvertY;
extern bool uUseShadow;
extern bool uUseNormals;

vec4 effect(vec4 color, Image texture, vec2 texture_coords, vec2 pixel_coords) {
  //sample color & normals from our textures
  vec4 textureColor = Texel(uTexture, texture_coords.st);
  vec3 normalColor = Texel(uNormalMap, texture_coords.st).rgb;

  //some bump map programs will need the Y value flipped..
  normalColor.g = uInvertY ? 1.0 - normalColor.g : normalColor.g;

  //this is for debugging purposes, allowing us to lower the intensity of our bump map
  vec3 normalBase = vec3(0.5, 0.5, 1.0);
  normalColor = mix(normalBase, normalColor, uMapStrength);

  //normals need to be converted to [-1.0, 1.0] range and normalized
  vec3 normal = normalize(normalColor * 2.0 - 1.0);

  //here we do a simple distance calculation
  vec3 deltaPos = vec3( (uLightPosition.xy - gl_FragCoord.xy) / uResolution.xy, uLightPosition.z);

  vec3 lightDirection = normalize(deltaPos);
  float lambert = uUseNormals ? clamp(dot(normal, lightDirection), 0.0, 1.0) : 1.0;
 
  //now let's get a nice little falloff
  float d = sqrt(dot(deltaPos, deltaPos));       
  float att = uUseShadow ? 1.0 / (uAttenuation.x + (uAttenuation.y*d) + (uAttenuation.z*d*d)) : 1.0;
 
  vec3 result = (ambientColor * ambientIntensity) + (lightColor.rgb * lambert) * att;

  result *= color.rgb;
 
  return pixel * vec4(result, color.a);

/*


  vec3 L = normalize(uLightDirection);

  vec3 normal = Texel(uNormalMap, texture_coords).rgb;

	normal = normalize(normal * 2.0 - 1.0);
  
  vec3 N = normal; //normalize(vTBN * normal);

  vec3 ambient = uAmbientLight * uAmbientMaterial;

  float diffuseIntensity = max(dot(N, -L), 0.0);

  vec3 diffuse = diffuseIntensity * uDiffuseLight * uDiffuseMaterial;
  
  float specularIntensity = 0.0;

	//if (uSpecularIntensity > 0.0) {
		//vec3 V = normalize(vViewPath);
		//vec3 R = reflect(L, N);
		//specularIntensity = pow(max(dot(R, V), 0.0), uSpecularPower);
	//}

  vec3 specular = specularIntensity * uSpecularLight * uSpecularMaterial;
  vec4 texelc = Texel(uTexture, vTexCoord);
  
  */
  // final
  //return pixel * color; // default return, for tests
}