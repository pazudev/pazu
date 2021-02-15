package openfl.text._internal;
import haxe.ds.IntMap;
import haxe.ds.StringMap;

#if !openfl_debug
@:fileXml('tags="haxe,release"')
@:noDebug
#end

@:access(openfl.text.TextFormat)
@SuppressWarnings("checkstyle:FieldDocComment")
class ShapeCache
{
	private var __shortWordMap:StringMap<StringMap<Array<GlyphPosition>>>;
	private var __longWordMap:StringMap<IntMap<CacheMeasurement>>;

	public function new()
	{
		__shortWordMap = new StringMap();
		__longWordMap = new StringMap();
	}

	private static function hashFunction(key:String):Int
	{
		var hash = 0, i, chr;
		for (i in 0...key.length)
		{
			chr = key.charCodeAt(i);
			hash = ((hash << 5) - hash) + chr;
			hash |= 0;
		}
		return hash;
	}

	public function cache(formatRange:TextFormatRange, getPositions:Dynamic#if (js && html5) , wordKey:String = null #end):Dynamic
	{
		var formatKey:String = formatRange.format.__cacheKey;
		#if (!js && !html5)
		var wordKey:String = getPositions.text;
		#end
		if (wordKey.length > 15)
		{
			return __cacheLongWord(wordKey, formatKey, getPositions);
		}
		else {
			return __cacheShortWord(wordKey, formatKey, getPositions);
		}
		return null;
	}

	private function __cacheShortWord(wordKey:String, formatKey:String, getPositions:Dynamic):Dynamic
	{
		if (__shortWordMap.exists(formatKey))
		{
			var formatMap = __shortWordMap.get(formatKey);
			if (formatMap.exists(wordKey))
			{
				return formatMap.get(wordKey);
			}
			else
			{
				formatMap.set(wordKey, #if (js && html5) getPositions() #else getPositions.positions #end);
			}
		}
		else
		{
			var formatMap = new StringMap();
			formatMap.set(wordKey, #if (js && html5) getPositions() #else getPositions.positions #end);
			__shortWordMap.set(formatKey, formatMap);
		}
		return #if (js && html5) getPositions() #else getPositions.positions #end;
	}

	private function __cacheLongWord(wordKey:String, formatKey:String, getPositions:Dynamic):Dynamic
	{
		var hash = hashFunction(wordKey);
		if (__longWordMap.exists(formatKey))
		{
			var formatMap = __longWordMap.get(formatKey);
			if (formatMap.exists(hash))
			{
				var measurement = formatMap.get(hash);
				if (measurement.exists(wordKey))
				{
					return measurement.get(wordKey);
				}
				else
				{
					measurement.set(wordKey, #if (js && html5) getPositions() #else getPositions.positions #end);
				}
			}
			else
			{
				var measurement = new CacheMeasurement(wordKey, #if (js && html5) getPositions() #else getPositions.positions #end);
				formatMap.set(hash, measurement);
			}
		}
		else
		{
			var formatMap = new IntMap();
			var measurement = new CacheMeasurement(wordKey, #if (js && html5) getPositions() #else getPositions.positions #end);
			measurement.hash = hash;
			formatMap.set(hash, measurement);
			__longWordMap.set(formatKey, formatMap);
		}
		return #if (js && html5) getPositions() #else getPositions.positions #end;
	}

}