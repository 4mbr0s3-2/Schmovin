package schmovin.shaders;

import flixel.system.FlxAssets.FlxShader;

// Quick plane raymarcher thingy by 4mbr0s3 2 (partially)

@:deprecated('GLSL raymarchers replaced by 3D note mod transformations (set the \'cam-\' note mods)')
class PlaneRaymarcher
{
	public var shader(default, null):PlaneRaymarcherShader = new PlaneRaymarcherShader();

	public var pitch(get, set):Float;
	public var yaw(get, set):Float;
	public var cameraOffX(get, set):Float;
	public var cameraOffY(get, set):Float;
	public var cameraOffZ(get, set):Float;
	public var cameraLookAtX(get, set):Float;
	public var cameraLookAtY(get, set):Float;
	public var cameraLookAtZ(get, set):Float;

	private function get_pitch():Float
	{
		return shader.pitch.value[0];
	}

	private function get_cameraOffX():Float
	{
		return shader.cameraOff.value[0];
	}

	private function get_cameraOffY():Float
	{
		return shader.cameraOff.value[1];
	}

	private function get_cameraOffZ():Float
	{
		return shader.cameraOff.value[2];
	}

	private function get_cameraLookAtX():Float
	{
		return shader.cameraLookAt.value[0];
	}

	private function get_cameraLookAtY():Float
	{
		return shader.cameraLookAt.value[1];
	}

	private function get_cameraLookAtZ():Float
	{
		return shader.cameraLookAt.value[2];
	}

	private function set_pitch(value:Float):Float
	{
		shader.pitch.value = [value];
		return value;
	}

	private function set_cameraOffX(value:Float):Float
	{
		shader.cameraOff.value[0] = value;
		return value;
	}

	private function set_cameraOffY(value:Float):Float
	{
		shader.cameraOff.value[1] = value;
		return value;
	}

	private function set_cameraOffZ(value:Float):Float
	{
		shader.cameraOff.value[2] = value;
		return value;
	}

	private function set_cameraLookAtX(value:Float):Float
	{
		shader.cameraLookAt.value[0] = value;
		return value;
	}

	private function set_cameraLookAtY(value:Float):Float
	{
		shader.cameraLookAt.value[1] = value;
		return value;
	}

	private function set_cameraLookAtZ(value:Float):Float
	{
		shader.cameraLookAt.value[2] = value;
		return value;
	}

	private function get_yaw():Float
	{
		return shader.yaw.value[0];
	}

	private function set_yaw(value:Float):Float
	{
		shader.yaw.value = [value];
		return value;
	}

	public function new():Void
	{
		shader.cameraOff.value = [0, 0, 0];
		shader.cameraLookAt.value = [0, 0, 0];
		shader.pitch.value = [0];
		shader.yaw.value = [0];
		shader.uTime.value = [0];
	}

	public function update(elapsed:Float):Void
	{
		shader.uTime.value[0] += elapsed;
	}
}

class PlaneRaymarcherShader extends FlxShader
{
	// Drafted this in Shadertoy: https://www.shadertoy.com/view/fdlXzn
	@:glFragmentSource('
        // "RayMarching starting point" 
		// by Martijn Steinrucken aka The Art of Code/BigWings - 2020
		// The MIT License
        // Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions: The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
        // Original shader: https://www.shadertoy.com/view/WtGXDD
        // You can use this shader as a template for ray marching shaders

        #define MAX_STEPS 100
        #define MAX_DIST 100.
        #define SURF_DIST .01
        #define WIDTH 1.778
        #define HEIGHT 1.

        #pragma header
        uniform float uTime;
        uniform float pitch;
        uniform float yaw;
        uniform vec3 cameraOff;
        uniform vec3 cameraLookAt;

        mat2 Rot(float a) {
            float s=sin(a), c=cos(a);
            return mat2(c, -s, s, c);
        }

        float BoxSDF( vec3 p, vec3 b )
        {
        vec3 q = abs(p) - b;
        return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
        }

        float GetDist(vec3 p) {
            vec4 s = vec4(0, 1, 6, 1);
            
            float playfieldDist = BoxSDF(p, vec3(WIDTH, HEIGHT, 0));
            float d = playfieldDist; // Union
            
            return d;
        }

        vec3 GetNormal(vec3 p) {
            float d = GetDist(p);
            vec2 e = vec2(.001, 0);
            
            vec3 n = d - vec3(
                GetDist(p-e.xyy),
                GetDist(p-e.yxy),
                GetDist(p-e.yyx));
            
            return normalize(n);
        }


        vec3 GetRayDir(vec2 uv, vec3 p, vec3 l, float z) {
            vec3 f = normalize(l-p),
                r = normalize(cross(vec3(0,1,0), f)),
                u = cross(f,r),
                c = f*z,
                i = c + uv.x*r + uv.y*u,
                d = normalize(i);
            return d;
        }

        float RayMarch(vec3 ro, vec3 rd) {
            float d0 = 0.; // Distance marched
            for (int i = 0; i < MAX_STEPS; i++) {
                vec3 p = ro + rd * d0;
                float dS = GetDist(p); // Closest distance to surface
                d0 += dS;
                if (d0 > MAX_DIST || dS < SURF_DIST) {
                    break;
                }
            }
            return d0;
        }

        void main()
        {
            vec2 uv = openfl_TextureCoordv - vec2(0.5);
            uv.x *= WIDTH / HEIGHT;
            vec3 ro = vec3(0, 0, -2); // Ray origin
            ro += cameraOff;
            ro.yz *= Rot(pitch);
            ro.xz *= Rot(yaw);
            vec3 rd = GetRayDir(uv, ro, cameraLookAt, 1.);
            
            float d = RayMarch(ro, rd);
            
            vec4 col = vec4(0);
            
            // Collision
            if (d < MAX_DIST) {
                vec3 p = ro + rd * d;
                vec3 n = GetNormal(p);
                
                float dif = dot(n, normalize(vec3(1,2,3)))*0.5+0.5;
                col += dif * dif;
                
                uv = vec2(p.x / WIDTH, p.y) * 0.5 + vec2(0.5);
                col = texture2D(bitmap, uv);
            }
            
            gl_FragColor = col;
        }')
	public function new()
	{
		super();
	}
}
