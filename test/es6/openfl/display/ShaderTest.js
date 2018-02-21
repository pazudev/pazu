import Shader from "openfl/display/Shader";
import ShaderPrecision from "openfl/display/ShaderPrecision";
import ByteArray from "openfl/utils/ByteArray";
import * as assert from "assert";


describe ("ES6 | Shader", function () {
	
	
	it ("byteCode", function () {
		
		// TODO: Confirm functionality
		
		var shader = new Shader ();
		// #if !flash
		shader.byteCode = new ByteArray ();
		// #end
		
	});
	
	
	it ("data", function () {
		
		// TODO: Confirm functionality
		
		var shader = new Shader ();
		var exists = shader.data;
		
		// #if flash
		// assert.equal (exists, null);
		// #else
		assert.notEqual (exists, null);
		// #end
		
	});
	
	
	it ("precisionHint", function () {
		
		// TODO: Confirm functionality
		
		var shader = new Shader ();
		var exists = shader.precisionHint;
		
		assert.equal (shader.precisionHint, ShaderPrecision.FULL);
		
	});
	
	
	it ("new", function () {
		
		// TODO: Confirm functionality
		
		var shader = new Shader ();
		var exists = shader;
		
		assert.notEqual (exists, null);
		
	});
	
	
});