uniform mat4 u_Color;
varying vec2 v_TexCoord;
varying vec2 v_TexCoord2;
varying vec2 v_TexCoord3;
varying vec2 v_Position;
uniform sampler2D u_Tex0;
uniform float u_Time;
uniform vec2 u_Resolution;

void main()
{
    gl_FragColor = texture2D(u_Tex0, v_TexCoord);
    vec4 texcolor = texture2D(u_Tex0, v_TexCoord2);
    vec4 texcolor2 = texture2D(u_Tex0, v_TexCoord3);
    if(texcolor.r > 0.9) {
        gl_FragColor *= texcolor.g > 0.9 ? u_Color[0] : u_Color[1];
    } else if(texcolor.g > 0.9) {
        gl_FragColor *= u_Color[2];
    } else if(texcolor.b > 0.9) {
        gl_FragColor *= u_Color[3];
    }
    if(gl_FragColor.a < 0.01) {
        if(texcolor2.a > 0.01) {
            float time = mod(u_Time, 3.14159265 * 2.0); // Loop time every 2*PI
            gl_FragColor = vec4(0.5 + 0.5 * sin(time), 0.5 + 0.5 * sin(time + 2.0944), 0.5 + 0.5 * sin(time + 4.18879), 1.0);
        } else {
            discard;
        }
    }
}
