package openfl._internal.timeline;


#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end


@:keep class Frame {
	
	
	public var labels:Array<String>;
	public var label:String;
	public var objects:Map<Int,FrameObject>;
	public var script:Dynamic;
	public var scriptSource:String;
	//public var scriptType:FrameScriptType;
	
	
	public function new () {
		
		
		
	}
	
	
}