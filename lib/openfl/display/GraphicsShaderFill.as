package openfl.display {
	
	
	import openfl.geom.Matrix;
	
	
	/**
	 * @externs
	 */
	final public class GraphicsShaderFill implements IGraphicsData, IGraphicsFill {
		
		
		public var matrix:Matrix;
		public var shader:Shader;
		
		public function GraphicsShaderFill (shader:Shader = null, matrix:Matrix = null) {}
		
		
	}
	
	
}