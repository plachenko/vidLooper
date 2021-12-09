precision highp float;

varying vec2 texCoords;

uniform sampler2D textureSampler;

void main(){
    float alpha = 0.2;

    vec4 color = texture2D(textureSampler, texCoords);

    color.a += alpha;

    gl_FragColor = color;
}