package openfl.filters; #if !openfl_legacy

import lime.math.color.ARGB;

import openfl.display.BitmapData;
import openfl.display.Shader;
import openfl.filters.commands.*;
import openfl.geom.Matrix;
import openfl.geom.Point;
import openfl.geom.Rectangle;
import openfl.gl.GL;

@:final class GradientGlowFilter extends BitmapFilter {
	
	public var alpha:Float;
	public var angle:Float;
	public var blurX:Float;
	public var blurY:Float;
	public var colors:Array<Int>; // :TODO: use setter to invalidate and regenerate lookup texture
	public var alphas:Array<Float>; // :TODO: use setter to invalidate and regenerate lookup texture
	public var ratios:Array<Float>; // :TODO: use setter to invalidate and regenerate lookup texture
	public var color:Int;
	public var distance:Float;
	public var type:BitmapFilterType;
	public var knockout (default, set):Bool;
	public var quality (default, set):Int;
	public var strength:Float;
	
	private var __lookupTextureIsDirty:Bool = true;
	private var __lookupTexture:BitmapData;
	private var __glowBitmapData:BitmapData;
	
	public function new (distance:Float = 4, angle:Float = 45, colors:Array<Int>, alphas:Array<Float>, ratios:Array<Float>, blurX:Float = 4, blurY:Float = 4, strength:Float = 1, quality:Int = 1, type:BitmapFilterType = BitmapFilterType.INNER, knockout:Bool = false) {
		
		super ();
		
		this.distance = distance;
		this.angle = angle;
		this.colors = colors;
		this.alphas = alphas;
		this.ratios = ratios;
		this.blurX = blurX;
		this.blurY = blurY;
		this.strength = strength;
		this.quality = quality;
		this.type = type;
		this.knockout = knockout;
	}
	
	
	public override function clone ():BitmapFilter {
		
		return new GradientGlowFilter (distance, angle, colors, alphas, ratios, blurX, blurY, strength, quality, type, knockout);

	}

	public override function dispose(): Void{
		if (__glowBitmapData != null){
			__glowBitmapData.dispose();
			__glowBitmapData = null;
		}

		if (__lookupTexture != null){
			__lookupTexture.dispose();
			__lookupTexture = null;
			__lookupTextureIsDirty = true;
		}
	}
	

	private function updateLookupTexture():Void {
		
		inline function alpha(color:UInt):Float {
			return (color >>> 24) / 255;
		}
		
		inline function rgb(color:UInt):UInt {
			return (color & 0xffffff);
		}
		
		inline function ri(color:UInt):UInt {
			return ((rgb(color) >> 16) & 0xff);
		}
		
		inline function gi(color:UInt):UInt {
			return ((rgb(color) >> 8) & 0xff);
		}
		
		inline function bi(color:UInt):UInt {
			return (rgb(color) & 0xff);
		}
		
		inline function r(color:UInt):Float {
			return ((rgb(color) >> 16) & 0xff) / 255;
		}
		
		inline function g(color:UInt):Float {
			return ((rgb(color) >> 8) & 0xff) / 255;
		}
		
		inline function b(color:UInt):Float {
			return (rgb(color) & 0xff) / 255;
		}
		
		inline function interpolate(color1:UInt, color2:UInt, ratio:Float):UInt {
			var r1:Float = r(color1);
			var g1:Float = g(color1);
			var b1:Float = b(color1);
			var alpha1:Float = alpha(color1);
			var ri:Int = Std.int((r1 + (r(color2) - r1) * ratio) * 255);
			var gi:Int = Std.int((g1 + (g(color2) - g1) * ratio) * 255);
			var bi:Int = Std.int((b1 + (b(color2) - b1) * ratio) * 255);
			var alphai:Int = Std.int((alpha1 + (alpha(color2) - alpha1) * ratio) * 255);
			return bi | (gi << 8) | (ri << 16) | (alphai << 24);
		}
		
		if (__lookupTexture == null ){
			__lookupTexture = new BitmapData (256, 1);
		}
		
		var upperBoundIndex = 0;
		var lowerBound = 0.0;
		var upperBound = Math.max(Math.min(ratios[0] / 0xFF, 1.0),0.0);
		var lowerBoundColor = ARGB.create(Math.round(alphas[0] * 255), ri(colors[0]), gi(colors[0]), bi(colors[0]));
		var upperBoundColor = ARGB.create(Math.round(alphas[0] * 255), ri(colors[0]), gi(colors[0]), bi(colors[0]));
		
		for( x in 0...__lookupTexture.width ) {
			var ratio = (x + 0.5) / __lookupTexture.width;
			
			if (ratio > upperBound) {
				
				while (ratio > upperBound ) {
					if ( upperBoundIndex < ratios.length - 1) {
						++upperBoundIndex;
						upperBound = Math.max(Math.min(ratios[upperBoundIndex] / 0xFF, 1.0),0.0);
					} else {
						upperBound = 1.0;
					}
				}
				
				var lowerBoundIndex = upperBoundIndex == 0 ? 0 : upperBoundIndex - 1;
				upperBoundColor.set(Math.round(alphas[upperBoundIndex] * 255), ri(colors[upperBoundIndex]), gi(colors[upperBoundIndex]), bi(colors[upperBoundIndex]));
				lowerBoundColor.set(Math.round(alphas[lowerBoundIndex] * 255), ri(colors[lowerBoundIndex]), gi(colors[lowerBoundIndex]), bi(colors[lowerBoundIndex]));
				lowerBound = Math.max(Math.min(ratios[lowerBoundIndex] / 0xFF, 1.0),0.0);
				
			}
			
			var lerpFactor = (ratio - lowerBound) / (upperBound - lowerBound);
			var color:ARGB = interpolate(lowerBoundColor, upperBoundColor, lerpFactor);
			
			for( y in 0...__lookupTexture.height ) {
				
				__lookupTexture.setPixel32(x, y, color);
				
			}
			
		}
		
	}

	
	private override function __growBounds (rect:Rectangle, transform:Matrix):Void {
		
		var offset = Point.pool.get ();
		BitmapFilter._getTransformedOffset(offset, distance, angle, transform);
		var halfBlurX = Math.ceil( blurX * 0.5 * quality );
		var halfBlurY = Math.ceil( blurY * 0.5 * quality );
		rect.x -= Math.abs (offset.x) + halfBlurX;
		rect.y -= Math.abs (offset.y) + halfBlurY;
		rect.width += 2.0 * (Math.abs (offset.x) + halfBlurX);
		rect.height += 2.0 * (Math.abs (offset.y) + halfBlurY);
		Point.pool.put (offset);
		
	}
	
	
	private override function __getCommands (bitmap:BitmapData):Array<CommandType> {
			
		var commands:Array<CommandType> = [];
			
		if(__glowBitmapData==null)
			__glowBitmapData = @:privateAccess BitmapData.__asRenderTexture ();

		if (__lookupTextureIsDirty) {
			
			updateLookupTexture();
			__lookupTextureIsDirty = false;
			
		}
			
		@:privateAccess __glowBitmapData.__resize(bitmap.width, bitmap.height);
	
		commands.push (Blur1D (__glowBitmapData, bitmap, blurX, quality, true, 1.0, distance, angle));
		commands.push (Blur1D (__glowBitmapData, __glowBitmapData, blurY, quality, false, strength, 0.0, 0.0));

		commands.push (ColorLookup (__glowBitmapData, __glowBitmapData, __lookupTexture));

		switch (type) {
			
			case BitmapFilterType.FULL:
				commands.push (Combine (bitmap, bitmap, __glowBitmapData));
	
			case BitmapFilterType.INNER:
				commands.push (CombineInner (bitmap, bitmap, __glowBitmapData));
	
			case BitmapFilterType.OUTER:
				commands.push (Combine (bitmap, __glowBitmapData, bitmap));
		
			default:
		
		}
	
		return commands;
	
	}

	// Get & Set Methods
		
		
	private function set_knockout (value:Bool):Bool {
	
		return knockout = value;
	
	}

	
	private function set_quality (value:Int):Int {
	
		return quality = value;
		
	}
	
	
}

#else
typedef GradientGlowFilter = openfl._legacy.filters.GradientGlowFilter;
#end
