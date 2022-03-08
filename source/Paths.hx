package;

import flixel.FlxG;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.utils.AssetType;
import openfl.utils.Assets as OpenFlAssets;
import lime.utils.Assets;
import sys.io.File;
import sys.FileSystem;
import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;

import flash.media.Sound;


class Paths
{
	inline public static var SOUND_EXT = #if web "mp3" #else "ogg" #end;

	#if (haxe >= "4.0.0")
	public static var ignoreModFolders:Map<String, Bool> = new Map();
	public static var customImagesLoaded:Map<String, FlxGraphic> = new Map();
	public static var customSoundsLoaded:Map<String, Sound> = new Map();
	#else
	public static var ignoreModFolders:Map<String, Bool> = new Map<String, Bool>();
	public static var customImagesLoaded:Map<String, FlxGraphic> = new Map<String, FlxGraphic>();
	public static var customSoundsLoaded:Map<String, Sound> = new Map<String, Sound>();
	#end

	static var currentLevel:String;

	static public function setCurrentLevel(name:String)
	{
		currentLevel = name.toLowerCase();
	}

	static public function getPath(file:String, type:AssetType, library:Null<String> = null)
	{
		if (library != null)
			return getLibraryPath(file, library);

		if (currentLevel != null)
		{
			var levelPath = getLibraryPathForce(file, currentLevel);
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;

			levelPath = getLibraryPathForce(file, "shared");
			if (OpenFlAssets.exists(levelPath, type))
				return levelPath;
		}

	//	trace(getPreloadPath(file));
		return getPreloadPath(file);
	}

	static function getPsychPath(file:String, type:AssetType, library:Null<String>)
		{
			if (library != null)
				return getLibraryPath(file, library);
	
			if (currentLevel != null)
			{
				var levelPath = getLibraryPathForce(file, currentLevel);
				if (OpenFlAssets.exists(levelPath, type))
					return levelPath;
	
				levelPath = getLibraryPathForce(file, "shared");
				if (OpenFlAssets.exists(levelPath, type))
					return levelPath;
			}
			return getPreloadPath(file);
		}

	static public function getLibraryPath(file:String, library = "preload")
	{
		return if (library == "preload" || library == "default") getPreloadPath(file); else getLibraryPathForce(file, library);
	}

	inline static function getLibraryPathForce(file:String, library:String)
	{
		return '$library:assets/$library/$file';
	}

	inline static public function getPreloadPath(file:String = '')
	{
		return 'assets/$file';
	}
	
	inline static public function fileExists(key:String, type:AssetType, ?ignoreMods:Bool = false, ?library:String)
	{
		if(FileSystem.exists(file(key, type, library))) {
			return true;
		}
			
		if(OpenFlAssets.exists(Paths.getPath(key, type))) {
			return true;
		}
		return false;
	}

	inline static public function file(file:String, type:AssetType = TEXT, ?library:String)
	{
		return getPath(file, type, library);
	}

	inline static public function lua(key:String,?library:String)
	{
		return getPath('data/$key.lua', TEXT, library);
	}

	inline static public function luaImage(key:String, ?library:String)
	{
		return getPath('data/$key.png', IMAGE, library);
	}

	inline static public function imageJson(key:String, ?library:String)
	{
		return getPath('images/$key.json', TEXT, library);
	}

	inline static public function txt(key:String, ?library:String)
	{
		return getPath('data/$key.txt', TEXT, library);
	}

	inline static public function imageTxt(key:String, ?library:String)
	{
		return getPath('images/$key.txt', TEXT, library);
	}

	inline static public function xml(key:String, ?library:String)
	{
		return getPath('data/$key.xml', TEXT, library);
	}

	inline static public function json(key:String, ?library:String, freeplay:Bool = false)
	{
		//return getPath('data/$key.json', TEXT, library);
		if (freeplay)
			return getPath('data/freeplayCharts/$key.json', TEXT, library);
		
		return getPath('data/charts/$key.json', TEXT, library);
	}

	inline static public function hScript(file:String)
	{
		return getPath('scripts/$file/script.hscript', TEXT, null);
		//return 'assets/scripts/$file/script.hscript';
	}

	static public function getTextFromFile(key:String, ?ignoreMods:Bool = false):String
		{
			#if sys
			if (!FileSystem.exists(file(key)))
				return File.getContent(file(key));
	
			if (FileSystem.exists(getPreloadPath(key)))
				return File.getContent(getPreloadPath(key));
	
			if (currentLevel != null)
			{
				var levelPath:String = '';
				if(currentLevel != 'shared') {
					levelPath = getLibraryPathForce(key, currentLevel);
					if (FileSystem.exists(levelPath))
						return File.getContent(levelPath);
				}
	
				levelPath = getLibraryPathForce(key, 'shared');
				if (FileSystem.exists(levelPath))
					return File.getContent(levelPath);
			}
			#end
			return Assets.getText(getPath(key, TEXT));
		}
	

	static public function sound(key:String, ?library:String)
	{
		return getPath('sounds/$key.$SOUND_EXT', SOUND, library);
	}

	inline static public function soundRandom(key:String, min:Int, max:Int, ?library:String)
	{
		return sound(key + FlxG.random.int(min, max), library);
	}

	inline static public function music(key:String, ?library:String)
	{
		return getPath('music/$key.$SOUND_EXT', MUSIC, library);
	}

	inline static public function voices(song:String)
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
			switch (songLowercase) {
				case 'dad-battle': songLowercase = 'dadbattle';
				case 'philly-nice': songLowercase = 'philly';
			}
	//	if (FileSystem.exists('assets/songs/${songLowercase}/Voices.$SOUND_EXT'))
	//		return 'songs:assets/songs/${songLowercase}/Voices.$SOUND_EXT';
	//	else 
			return 'assets/music/${song}_Voices.$SOUND_EXT'; //so old fusion users won't get errors.
	}

	inline static public function inst(song:String , prefix:String = '')
	{
		var songLowercase = StringTools.replace(song, " ", "-").toLowerCase();
			switch (songLowercase) {
				case 'dad-battle': songLowercase = 'dadbattle';
				case 'philly-nice': songLowercase = 'philly';
			}

		//trace(FileSystem.exists('assets/songs/${songLowercase}/Inst${prefix.toLowerCase()}.$SOUND_EXT'));
	//	trace('assets/songs/' + songLowercase + '/Inst' + prefix.toLowerCase() + '.$SOUND_EXT');

	//	if (FileSystem.exists('assets/songs/${songLowercase}/Inst${prefix.toLowerCase()}.$SOUND_EXT')) {
	//		trace('ke song or fusion switch');
	//		return 'songs:assets/songs/${songLowercase}/Inst${prefix.toLowerCase()}.$SOUND_EXT';}
	//	else 
			return 'assets/music/${song}_Inst${prefix.toLowerCase()}.$SOUND_EXT'; //saving old fusion people.
	}

	inline static public function image(key:String, ?library:String)
	{
		return getPath('images/$key.png', IMAGE, library);
	}

	inline static public function psychImage(key:String, ?library:String):Dynamic
	{
		// streamlined the assets process more
		var returnAsset:FlxGraphic = returnGraphic(key, library);
		return returnAsset;
	}

	public static var currentTrackedAssets:Map<String, FlxGraphic> = [];
	public static var localTrackedAssets:Array<String> = [];

	public static function returnGraphic(key:String, ?library:String) {
		var path = getPsychPath('images/$key.png', IMAGE, library);
		if (OpenFlAssets.exists(path, IMAGE)) {
			if(!currentTrackedAssets.exists(key)) {
				var newGraphic:FlxGraphic = FlxG.bitmap.add(path, false, key);
				currentTrackedAssets.set(key, newGraphic);
			}
			localTrackedAssets.push(key);
			return currentTrackedAssets.get(key);
		}
		trace('oh no its returning null NOOOO');
		return null;
	}

	inline static public function categoryMusic(song:String)
	{ //this wasnt soooooooo bad.
		trace('assets/categoryMusic/${song}.$SOUND_EXT');
		return 'assets/categoryMusic/${song}.$SOUND_EXT';
	}

	inline static public function font(key:String)
	{
		return 'assets/fonts/$key';
	}

	inline static public function getSparrowAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSparrow(image(key, library), file('images/$key.xml', library));
	}

	inline static public function getPackerAtlas(key:String, ?library:String)
	{
		return FlxAtlasFrames.fromSpriteSheetPacker(image(key, library), file('images/$key.txt', library));
	}
}
