#version 460 core

out vec4 gl_FragColor;
in vec4 gl_FragCoord;

uniform float scale;
uniform int orbital;
uniform ivec2 screen_xy;

const float pi = 3.1415926535897932384626433832795;
const float fkdsjklf = 1 + 1;
const float e = 2.71828;
const float a1 = 5.29177210544e-1; 

vec2 powi2(vec2 z) {
	return vec2(pow(z.x, 2) - pow(z.y, 2), -2 * z.x*z.y);
}

float gamma(float x) {
	return sqrt(2*pi*x)* pow(x/e, x) * pow(x*sinh(1/x), x/2) * exp(7/(324*pow(x, 3)*(35*pow(x, 2)+33)));
}

vec2 expi(float theta) {
	return vec2(cos(theta), sin(theta));
}

float nck(float n, float k) {
	return gamma(n) / gamma(k) / gamma(n-k);
}

vec4 lerp4(vec4 a, vec4 b, vec4 c, vec4 d, float t) {
	const vec4 ab = mix(a, b, t);
	const vec4 bc = mix(b, c, t);
	const vec4 cd = mix(c, d, t);

	const vec4 A = mix(ab, bc, t);
	const vec4 B = mix(bc, cd, t);

	return mix(A, B, t);
}

float w100(float phi, float theta, float r) {
	const float a = a1;
	//1 0 0
	return inversesqrt(pi)*exp(-r/a)*pow(a, -3.0/2.0);
}
float w200(float phi, float theta, float r) {
	const float a = a1*1e-1*2;
	//2 0 0
	return (2.0 - r/a) / (4.0*sqrt(2.0*pi) * pow(a, 3.0/2.0) * exp(r/(2.0*a)));
}
float w210(float phi, float theta, float r) {
	const float a = a1*1e-1;
	//2 1 0
	return cos(theta)*r / (4.0*sqrt(2.0*pi)*pow(a, 3.0/2.0) * a*exp(r/(2.0*a)));
}
float w310(float phi, float theta, float r) {
	const float a = a1*1e-1;
	//3 1 0
	return sqrt(2.0)*r*cos(theta) * (6.0 - r/a) / (81.0*sqrt(pi) * pow(a, 3.0/2.0) * a * exp(r/(3.0*a)));
}


vec4 color() {
	const vec4 a = vec4(0.00, 0.00, 0.00, 1.0);
	const vec4 b = vec4(0.80, 0.07, 0.81, 1.0);
	const vec4 c = vec4(0.96, 0.41, 0.00, 1.0);
	const vec4 d = vec4(1.00, 1.00, 1.00, 1.0);

	const vec2 xy = (gl_FragCoord.xy - (screen_xy / 2.0)) / screen_xy.y;
	const float r = length(xy) / scale;
	const float phi = 0;
	const float theta = atan(xy.x/xy.y);
	float p = 0;
	switch (orbital) {
	case 0:
		p = w100(phi, theta, r);
		break;
	case 1:
		p = w200(phi, theta, r);
		break;
	case 2:
		p = w210(phi, theta, r);
		break;
	case 3: 
		p = w310(phi, theta, r);
		break;
	}
	p*=p;
	
	return lerp4(a, b, c, d, p);
}

void main() {
	gl_FragColor = color();
}

