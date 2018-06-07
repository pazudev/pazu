package openfl.geom {
	
	
	import openfl.Vector;
	
	
	/**
	 * @externs
	 */
	public class Utils3D {
		
		
		// #if flash
		// @:noCompletion @:dox(hide) public static function pointTowards (percent:Float, mat:Matrix3D, pos:Vector3D, ?at:Vector3D, ?up:Vector3D):Matrix3D;
		// #end
		
		
		public static function projectVector (m:Matrix3D, v:Vector3D):Vector3D { return null; }
		public static function projectVectors (m:Matrix3D, verts:openfl.Vector, projectedVerts:openfl.Vector, uvts:openfl.Vector):void {}
		
		
	}
	
	
}