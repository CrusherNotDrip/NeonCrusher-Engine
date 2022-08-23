package;

import flixel.system.FlxAssets.FlxShader;

class PixelShader extends FlxShader
{
    public var shader(default, null):HentaiShader = new HentaiShader();
    public var pixelAmount(default, set):Float;

    public function new()
    {
        super();
    }

	function set_pixelAmount(value:Float)
    {
		shader.pixels.value = [value];
		return value;
	}
}

class HentaiShader extends FlxShader
{
    @:glFragmentSource('
    #pragma header
    uniform float pixels;

    void main()
    {
        vec2 uv = openfl_TextureCoordv.xy;
        
        uv = floor(uv*openfl_TextureSize.x*pixels)/(openfl_TextureSize.x*pixels);
        
        gl_FragColor = texture2D(bitmap, uv);
    }')

    public function new()
    {
        super();
    }
}