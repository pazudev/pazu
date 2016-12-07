package openfl.filters;


import lime.graphics.utils.ImageCanvasUtil;
import openfl._internal.renderer.RenderSession;
import openfl.display.BitmapData;
import openfl.display.Shader;
import openfl.filters.BitmapFilter;
import openfl.filters.FilterUtils;
import openfl.geom.Rectangle;


@:final class BlurFilter extends BitmapFilter {
	
	
	private static var __blurShader = new BlurShader ();
	
	public var blurX:Float;
	public var blurY:Float;
	public var quality (default, set):Int;
	
	private var horizontalPasses:Int;
	private var verticalPasses:Int;
	
	
	public function new (blurX:Float = 4, blurY:Float = 4, quality:Int = 1) {
		
		super ();
		
		this.blurX = blurX;
		this.blurY = blurY;
		this.quality = quality;
		
	}
	
	
	public override function clone ():BitmapFilter {
		
		return new BlurFilter (blurX, blurY, quality);
		
	}
	
	
	
	
	// Get & Set Methods
	
	
	
	
	private function set_quality (value:Int):Int {
		
		// TODO: Quality effect with fewer passes?
		
		horizontalPasses = (blurX <= 0) ? 0 : Math.round (blurX * (value / 4)) + 1;
		verticalPasses = (blurY <= 0) ? 0 : Math.round (blurY * (value / 4)) + 1;
		
		__numPasses = horizontalPasses + verticalPasses;
		
		return quality = value;
		
	}


	private override function __getFilterBounds( sourceBitmapData:BitmapData ) : Rectangle {

		return new Rectangle( blurX, blurY, sourceBitmapData.width + blurX + blurX, sourceBitmapData.height + blurY + blurY );

	}


	private override function __renderFilter (sourceBitmapData:BitmapData, destBitmapData:BitmapData):Void {

		#if (js && html5)
		ImageCanvasUtil.convertToData (sourceBitmapData.image);
		ImageCanvasUtil.convertToData (destBitmapData.image);
		#end

		var source = sourceBitmapData.clone().image.data;
		var target = destBitmapData.image.data;

		FilterUtils.GaussianBlur( source, target, sourceBitmapData.width, sourceBitmapData.height, blurX, blurY );

		super.__renderFilter( sourceBitmapData, destBitmapData );
	}

}

private class BlurShader extends Shader {
	
	
	@:glFragmentSource( 
		
		"varying float vAlpha;
		varying vec2 vTexCoord;
		uniform sampler2D uImage0;
		
		varying vec2 vBlurCoords[7];
		
		void main(void) {
			
			vec4 sum = vec4(0.0);
			sum += texture2D(uImage0, vBlurCoords[0]) * 0.00443;
			sum += texture2D(uImage0, vBlurCoords[1]) * 0.05399;
			sum += texture2D(uImage0, vBlurCoords[2]) * 0.24197;
			sum += texture2D(uImage0, vBlurCoords[3]) * 0.39894;
			sum += texture2D(uImage0, vBlurCoords[4]) * 0.24197;
			sum += texture2D(uImage0, vBlurCoords[5]) * 0.05399;
			sum += texture2D(uImage0, vBlurCoords[6]) * 0.00443;
			
			gl_FragColor = sum;
			
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
		
	}
	
	
	private override function __update ():Void {
		
		data.uTextureSize.value = [ data.uImage0.input.width, data.uImage0.input.height ];
		
		super.__update ();
		
	}
	
	
}
