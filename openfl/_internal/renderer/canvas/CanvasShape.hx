package openfl._internal.renderer.canvas;


import openfl.display.DisplayObject;

@:access(openfl.display.DisplayObject)
@:access(openfl.display.Graphics)


class CanvasShape {
	
	
	public static inline function render (shape:DisplayObject, renderSession:RenderSession):Void {
		
		#if js
		if (!shape.__renderable || shape.__worldAlpha <= 0) return;
		
		var graphics = shape.__graphics;
		
		if (graphics != null) {
			
			if (graphics.__drawTilesMode) {
				var m = shape.__worldTransform.clone();
				var p = m.deltaTransformPoint(new openfl.geom.Point(m.tx, m.ty));
				m.translate(-p.x, -p.y);
				m.invert();
				
				p = m.transformPoint(new openfl.geom.Point(graphics.__bounds.width, graphics.__bounds.height));
				graphics.__bounds.width = p.x;
				graphics.__bounds.height = p.y;
				
				graphics.__bounds.x -= shape.__worldTransform.tx;
				graphics.__bounds.y -= shape.__worldTransform.ty;
				graphics.__drawTilesMode = false;
			}
			
			//#if old
			CanvasGraphics.render (graphics, renderSession);
			//#else
			//CanvasGraphics.renderObjectGraphics (shape, renderSession);
			//#end
			
			if (graphics.__canvas != null) {
				
				//if (sprite.__mask != null) {
					
					//renderSession.maskManager.pushMask (__mask);
					
				//}
				
				var context = renderSession.context;
				var scrollRect = shape.scrollRect;
				
				context.globalAlpha = shape.__worldAlpha;
				var transform = shape.__worldTransform;
				
				if (renderSession.roundPixels) {
					
					context.setTransform (transform.a, transform.b, transform.c, transform.d, Std.int (transform.tx), Std.int (transform.ty));
					
				} else {
					
					context.setTransform (transform.a, transform.b, transform.c, transform.d, transform.tx, transform.ty);
					
				}
				
				if (scrollRect == null) {
					
					context.drawImage (graphics.__canvas, graphics.__bounds.x, graphics.__bounds.y);
					
				} else {
					
					context.drawImage (graphics.__canvas, scrollRect.x - graphics.__bounds.x, scrollRect.y - graphics.__bounds.y, scrollRect.width, scrollRect.height, graphics.__bounds.x + scrollRect.x, graphics.__bounds.y + scrollRect.y, scrollRect.width, scrollRect.height);
					
				}
				
				//if (sprite.__mask != null) {
					
					//renderSession.maskManager.popMask ();
					
				//}
				
			}
			
		}
		#end
		
	}
	
	
}
