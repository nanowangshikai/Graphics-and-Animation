varying vec3 normal;
varying vec3 position;
varying vec2 texCoord;  // The third coordinate is always 0.0 and is discarded

//Part G : perform the lighting calculations
uniform vec3 AmbientProduct, DiffuseProduct, SpecularProduct; 
uniform float LightBrightness;
uniform float LightBrightness2;
uniform vec3 LightColor;
uniform vec3 LightColor2;

vec4 color;

uniform sampler2D texture;

uniform float Shininess;
uniform float texScale;

uniform vec4 LightPosition;
uniform vec4 LightPosition2;

uniform mat4 ModelView;
uniform mat4 View;



void main()
{
    
    // The vector to the light from the vertex    
    vec3 Lvec = LightPosition.xyz - position;

    // The vector from ligth2
    vec3 Lvec2 = LightPosition2.xyz - position;

    // Unit direction vectors for Blinn-Phong shading calculation
    vec3 L = normalize( Lvec );   // Direction to the light source
    vec3 L2 = normalize( Lvec2 );   // Direction to the light2 source
    vec3 E = normalize( -position);   // Direction to the eye/camera
    vec3 H = normalize( L + E );  // light Halfway vector
    vec3 H2 = normalize( L2 + E );  // light2 Halfway vector

    // Transform vertex normal into eye coordinates (assumes scaling
    // is uniform across dimensions)
    vec3 N = normalize( (ModelView*vec4(normal, 0.0)).xyz );

    // Compute terms in the illumination equation
    vec3 ambient = (LightColor * LightBrightness) * AmbientProduct;
    vec3 ambient2 = (LightColor2 * LightBrightness2) * AmbientProduct;

    // Diffuse for both light1 and light2
    float Kd = max( dot(L, N), 0.0 );
    float Kd2 = max( dot(L2, N), 0.0 );
    vec3  diffuse = Kd * (LightColor*LightBrightness) * DiffuseProduct;
    vec3  diffuse2 = Kd2 * (LightColor2*LightBrightness2) * DiffuseProduct;

    float Ks = pow( max(dot(N, H), 0.0), Shininess );
    float Ks2 = pow( max(dot(N, H2), 0.0), Shininess );

   
    // Part H : specular highlight
    vec3 brightness = vec3(5, 5, 5);
    vec3  specular = Ks * (SpecularProduct + brightness) ;
    vec3  specular2 = Ks2 * (SpecularProduct + brightness) ;    

    if (dot(L, N) < 0.0 ) {
		specular = vec3(0.0, 0.0, 0.0);
    } 

    if (dot(L2, N) < 0.0 ) {
    specular2 = vec3(0.0, 0.0, 0.0);
    } 

    //Part F : ligth reducing 
    float light_redu = 0.1 + length(Lvec);
    float light_redu2 = 0.1 + length(Lvec2);

    float light = 1.0/(1.0 + 1.0*length(Lvec) + light_redu);
    float light2 = 1.0/(1.0 + 1.0*length(Lvec2) + light_redu2);


    // globalAmbient is independent of distance from the light source
    vec3 globalAmbient = vec3(0.1, 0.1, 0.1);
    color.rgb = globalAmbient  + ((ambient + diffuse)/light_redu) + specular + light + light2;
    color.a = 1.0;
   
    gl_FragColor = color * texture2D( texture, texCoord * texScale );

}
