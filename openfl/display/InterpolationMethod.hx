package openfl.display; #if !openfl_legacy


@:enum abstract InterpolationMethod(Null<Int>) {
	
	public var LINEAR_RGB = 0;
	public var RGB = 1;
	
	@:from private static function fromString (value:String):InterpolationMethod {
		
		return switch (value) {
			
			case "linearRGB": LINEAR_RGB;
			case "rgb": RGB;
			default: null;
			
		}
		
	}
	
	@:to private static function toString (value:Int):String {
		
		return switch (value) {
			
			case InterpolationMethod.LINEAR_RGB: "linearRGB";
			case InterpolationMethod.RGB: "rgb";
			default: null;
			
		}
		
	}
	
}


#else
typedef InterpolationMethod = openfl._legacy.display.InterpolationMethod;
#end