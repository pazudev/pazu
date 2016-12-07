package openfl.filters;


import lime.graphics.utils.ImageCanvasUtil;
import lime.utils.UInt8Array;
import openfl._internal.renderer.RenderSession;
import openfl.display.BitmapData;
import openfl.display.Shader;
import openfl.geom.Rectangle;


@:final class GlowFilter extends BitmapFilter {
	
	
	private static var __glowShader = new GlowShader ();
	
	public var alpha:Float;
	public var blurX:Float;
	public var blurY:Float;
	public var color:Int;
	public var inner:Bool;
	public var knockout (default, set):Bool;
	public var quality (default, set):Int;
	public var strength:Float;
	
	private var horizontalPasses:Int;
	private var verticalPasses:Int;
	
	
	public function new (color:Int = 0xFF0000, alpha:Float = 1, blurX:Float = 6, blurY:Float = 6, strength:Float = 2, quality:Int = 1, inner:Bool = false, knockout:Bool = false) {
		
		super ();
		
		__preserveOriginal = true;

		this.color = color;
		this.alpha = alpha;
		this.blurX = blurX;
		this.blurY = blurY;
		this.strength = strength;
		this.quality = quality;
		this.inner = inner;
		this.knockout = knockout;
		
		__cacheObject = true;
		
	}
	
	
	public override function clone ():BitmapFilter {
		
		return new GlowFilter (color, alpha, blurX, blurY, strength, quality, inner, knockout);
		
	}
	
	
	private override function __initShader (renderSession:RenderSession, pass:Int):Shader {
		
		var data = __glowShader.data;
		
		if (pass <= horizontalPasses) {
			
			var scale = Math.pow (0.5, pass >> 1);
			data.uRadius.value[0] = blurX * scale;
			data.uRadius.value[1] = 0;
			
		} else {
			
			var scale = Math.pow (0.5, (pass - horizontalPasses) >> 1);
			data.uRadius.value[0] = 0;
			data.uRadius.value[1] = blurY * scale;
			
		}
		
		data.uColor.value[0] = ((color >> 16) & 0xFF) / 255;
		data.uColor.value[1] = ((color >> 8) & 0xFF) / 255;
		data.uColor.value[2] = (color & 0xFF) / 255;
		data.uColor.value[3] = alpha;
		
		return __glowShader;
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function set_knockout (value:Bool):Bool {
		
		return knockout = value;
		
	}
	
	
	private function set_quality (value:Int):Int {
		
		// TODO: Quality effect with fewer passes?
		
		horizontalPasses = (blurX <= 0) ? 0 : Math.round (blurX * (value / 4)) + 1;
		verticalPasses = (blurY <= 0) ? 0 : Math.round (blurY * (value / 4)) + 1;
		
		__numPasses = horizontalPasses + verticalPasses;
		
		return quality = value;
		
	}
	

	private override function __renderFilter (sourceBitmapData:BitmapData, destBitmapData:BitmapData):Void {

		var tmpSrc = sourceBitmapData.clone();
		#if (js && html5)
		ImageCanvasUtil.convertToData (tmpSrc.image);
		ImageCanvasUtil.convertToData (destBitmapData.image);
		#end

		var source = sourceBitmapData.image.data;
		var target = destBitmapData.image.data;

		var i = 0;
		var cR = (color >> 16) & 0xff;
		var cG = (color >> 8) & 0xff;
		var cB = color & 0xff;
		var cA = Std.int(alpha * 0xff);
		while (i < source.length) {
			source[ i ] = target[ i ] = cR;
			source[ i+1 ] = target[ i+1 ] = cG;
			source[ i+2 ] = target[ i+2 ] = cB;
			i += 4;
		}

		FilterUtils.GaussianBlur( source, target, sourceBitmapData.width, sourceBitmapData.height, blurX, blurY );

		tmpSrc = null;

		__filterDirty = false;
	}
	
}


private class GlowShader extends Shader {
	
	
	@:glFragmentSource( 
		
		"varying float vAlpha;
		varying vec2 vTexCoord;
		uniform sampler2D uImage0;
		
		uniform vec4 uColor;
		
		varying vec2 vBlurCoords[7];
		
		void main(void) {
			
			float a = 0.0;
			a += texture2D(uImage0, vBlurCoords[0]).a * 0.00443;
			a += texture2D(uImage0, vBlurCoords[1]).a * 0.05399;
			a += texture2D(uImage0, vBlurCoords[2]).a * 0.24197;
			a += texture2D(uImage0, vBlurCoords[3]).a * 0.39894;
			a += texture2D(uImage0, vBlurCoords[4]).a * 0.24197;
			a += texture2D(uImage0, vBlurCoords[5]).a * 0.05399;
			a += texture2D(uImage0, vBlurCoords[6]).a * 0.00443;
			a *= uColor.a;
			
			gl_FragColor = vec4(uColor.rgb * a, a);
			
		}"
		
	)
	
	
	@:glVertexSource(
		
		"attribute float aAlpha;
		attribute vec4 aPosition;
		attribute vec2 aTexCoord;
		varying float vAlpha;
		varying vec2 vTexCoord;
		
		uniform mat4 uMatrix;
		
		uniform vec2 uRadius;
		varying vec2 vBlurCoords[7];
		uniform vec2 uTextureSize;
		
		void main(void) {
			
			vAlpha = aAlpha;
			vTexCoord = aTexCoord;
			gl_Position = uMatrix * aPosition;
			
			vec2 r = uRadius / uTextureSize;
			vBlurCoords[0] = aTexCoord - r * 1.0;
			vBlurCoords[1] = aTexCoord - r * 0.75;
			vBlurCoords[2] = aTexCoord - r * 0.5;
			vBlurCoords[3] = aTexCoord;
			vBlurCoords[4] = aTexCoord + r * 0.5;
			vBlurCoords[5] = aTexCoord + r * 0.75;
			vBlurCoords[6] = aTexCoord + r * 1.0;
			
		}"
		
	)
	
	
	public function new () {
		
		super ();
		
		data.uRadius.value = [ 0, 0 ];
		data.uColor.value = [ 0, 0, 0, 0 ];
		
	}
	
	
	private override function __update ():Void {
		
		data.uTextureSize.value = [ data.uImage0.input.width, data.uImage0.input.height ];
		
		super.__update ();
		
	}
	
	
}
