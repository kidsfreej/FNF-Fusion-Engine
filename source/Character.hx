package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;

import flixel.FlxSprite;
import flixel.animation.FlxBaseAnimation;
import flixel.graphics.frames.FlxAtlasFrames;
import flash.display.BitmapData;
import lime.utils.Assets;
import lime.system.System;
import lime.app.Application;
import flixel.tweens.FlxTween;
#if sys
import sys.io.File;
import sys.FileSystem;
import haxe.io.Path;
import openfl.utils.ByteArray;
#end
import haxe.Json;
import tjson.TJSON;
import haxe.format.JsonParser;

import animateatlas.AtlasFrameMaker;
import flixel.tweens.FlxTween;
import flixel.util.FlxSort;
import Section.SwagSection;
import openfl.utils.AssetType;
import openfl.utils.Assets;
import haxe.Json;
import haxe.format.JsonParser;
import flixel.util.FlxColor;
import flixel.graphics.FlxGraphic;

using StringTools;

typedef CharacterFile = {
	var animations:Array<AnimArray>;
	var image:String;
	var scale:Float;
	var sing_duration:Float;
	var healthicon:String;

	var position:Array<Float>;
	var camera_position:Array<Float>;

	var flip_x:Bool;
	var no_antialiasing:Bool;
	var healthbar_color:Array<Int>;
	var hasNoteSkin:Bool;
}
typedef AnimArray = {
	var anim:String;
	var name:String;
	var fps:Int;
	var loop:Bool;
	var indices:Array<Int>;
	var offsets:Array<Int>;
}
enum abstract EpicLevel(Int) from Int to Int {
	var Level_NotAHoe = 0;
	var Level_Boogie = 1;
	var Level_Sadness = 2;
	var Level_Sing = 3;

	@:op(A > B) static function gt(a:EpicLevel, b:EpicLevel):Bool;
	@:op(A >= B) static function gte(a:EpicLevel, b:EpicLevel):Bool;
	@:op(A == B) static function equals(a:EpicLevel, b:EpicLevel):Bool;
	@:op(A != B) static function nequals(a:EpicLevel, b:EpicLevel):Bool;
	@:op(A < B) static function lt(a:EpicLevel, b:EpicLevel):Bool;
	@:op(A <= B) static function lte(a:EpicLevel, b:EpicLevel):Bool;
}
typedef TCharacterRefJson = {
	var like:String;
	var icons:Array<Int>;
	var ?colors:Array<String>;
}
class Character extends FlxSprite
{
	public var animOffsets:Map<String, Array<Dynamic>>;
	public var camOffsets:Map<String, Array<Dynamic>>;
	public var debugMode:Bool = false;

	public var isPlayer:Bool = false;
	public var curCharacter:String = 'bf';
	public var enemyOffsetX:Int = 0;
	public var enemyOffsetY:Int = 0;
	public var camOffsetX:Int = 0;
	public var camOffsetY:Int = 0;
	public var followCamX:Int = 0;
	public var followCamY:Int = 0;
	public var midpointX:Int = 0;
	public var midpointY:Int = 0;
	public var isCustom:Bool = false;
	public var holdTimer:Float = 0;
	public var like:String = "bf";
	public var isDie:Bool = false;
	public var beNormal:Bool = true;

	//modding+

	/**
	 * Color used by default for enemy, when not in duo mode or oppnt play.
	 */
	 public var enemyColor:FlxColor = 0xFFFF0000;
	 /**
	  * Color used by default for enemy in duo mode and oppnt play.
	  */
	 public var opponentColor:FlxColor = 0xFFE7C53C;
	 /**
	  * Color used by player while not in duo mode or oppnt play.
	  */
	 public var playerColor:FlxColor = 0xFF66FF33;
	 /**
	  * Color used by player when poisoned in fragile funkin.
	  */
	 public var poisonColor:FlxColor = 0xFFA22CD1;
	 /**
	  * Color used by enemy when poisoned in fragile funkin. 
	  */
	 public var poisonColorEnemy:FlxColor = 0xFFEA2FFF;
	 /**
	  * Color used by player in duo mode or oppnt play.
	  */
	 public var bfColor:FlxColor = 0xFF149DFF;
	 // sits on speakers, replaces gf
	 public var likeGf:Bool = false;
	 // uses animation notes
	 public var hasGun:Bool = false;
	// public var stunned(get, default):Bool = false;
	 public var beingControlled:Bool = false;
	 /**
	  * how many animations our current gf supports. 
	  * acts like a level meter, 0 means we aren't gf,
	  * 1 means we support the least animations (i think pixel-gf)
	  * 2 means we support the middle amount of animations (i think gf-tankmen)
	  * 3 means we support the full amount of animations (regular gf)
	  * you can have an epic level lower than your actual animations, 
	  * but the game will be safe and act like you don't have one.
	  */
	 public var gfEpicLevel:EpicLevel = Level_NotAHoe;
	 // like bf, is playable
	 public var likeBf:Bool = false;
	 public var isPixel:Bool = false;

	//extra stuff

	public var colorTween:FlxTween;
	//public var holdTimer:Float = 0;
	public var heyTimer:Float = 0;
	public var specialAnim:Bool = false;
	public var animationNotes:Array<Dynamic> = [];
	//public var stunned:Bool = false;
	public var singDuration:Float = 4; //Multiplier of how long a character holds the sing pose
	public var idleSuffix:String = '';
	public var danceIdle:Bool = false; //Character use "danceLeft" and "danceRight" instead of "idle"

	public var healthIcon:String = 'face';
	public var animationsArray:Array<AnimArray> = [];

	public var positionArray:Array<Float> = [0, 0];
	public var cameraPosition:Array<Float> = [0, 0];

	//Used on Character Editor
	public var imageFile:String = '';
	public var jsonScale:Float = 1;
	public var noAntialiasing:Bool = false;
	public var originalFlipX:Bool = false;
	public var healthColorArray:Array<Int> = [255, 0, 0];

	public static var DEFAULT_CHARACTER:String = 'bf'; //In case a character is missing, it will use BF on its place

	public var healthBarColor:Int = 0xFF9271FD;

	public var charHasNoteSkin:Bool = false;
	public var isPsychFile:Bool = false;
	public var isModFile:Bool = false;
	public var setLike:Bool = true;
	public var isPlayingAsBF:Bool = false;
	public var charScript:HscriptShit;
	public var colorScript:HscriptShit;
	public var hscriptPath:String = 'assets/images/custom_chars/';
	var noDanceTwice:Int = 0;

	public function call(tfisthis:String, shitToGoIn:Array<Dynamic>) //basically Psych Engine's **callOnLuas**
	{
		if (charScript.enabled)
			charScript.call(tfisthis, shitToGoIn); //because
	}
	public function callColor(tfisthis:String, shitToGoIn:Array<Dynamic>) //basically Psych Engine's **callOnLuas**
	{
		if (colorScript.enabled)
			colorScript.call(tfisthis, shitToGoIn); //because
	}

	public function new(x:Float, y:Float, ?character:String = "bf", ?isPlayer:Bool = false)
	{
		animOffsets = new Map<String, Array<Dynamic>>();
		camOffsets = new Map<String, Array<Dynamic>>();
		super(x, y);

		curCharacter = character;
		this.isPlayer = isPlayer;
		this.hscriptPath += (character + '/');

		isPlayingAsBF = !FlxG.save.data.flip;

		var tex:FlxAtlasFrames;
		antialiasing = FlxG.save.data.antialiasing;

		switch (curCharacter)
		{
			default: //you can case your character if you want to, but would rather u use hscript or json.
				setLike = false;
				if (FileSystem.exists("assets/images/custom_chars/psych-"+curCharacter+".json"))
					isPsychFile = true;

				if (FileSystem.exists("assets/images/custom_chars/"+curCharacter+".hscript")) {
					var tex:FlxAtlasFrames;
					antialiasing = true;

					curCharacter = curCharacter.trim();
					trace(curCharacter);
					isCustom = true;
					if (StringTools.endsWith(curCharacter, "-dead"))
					{
						isDie = true;
						curCharacter = curCharacter.substr(0, curCharacter.length - 5);
					}

					// failsafe so you dont crash when loading a nonexistant character :)
					if (!FileSystem.exists('assets/images/custom_chars/' + character) && !isDie) {
						curCharacter = 'dad';
						trace(character + ' doesnt exist!');
					}

					trace(curCharacter);
					var charJson:Dynamic = null;
					var isError:Bool = false;
					charJson = CoolUtil.parseJson(Assets.getText('assets/images/custom_chars/custom_chars.jsonc'));
					//charScript.interp = Character.getAnimInterp(curCharacter);
					charScript = new HscriptShit("assets/images/custom_chars/"+curCharacter+".hscript", curCharacter, true);
					var charPath:String = 'assets/images/custom_chars/' + character + '/';
					trace(this.hscriptPath);
					call("init", [this]);
				}

				switch (isPsychFile)
				{
					case false:
						#if sys
				// assume it is a custom character. if not: oh well
				// protective ritual to protect against new lines
				curCharacter = curCharacter.trim();
				isCustom = true;
				if (StringTools.endsWith(curCharacter, "-dead")) {
					isDie = true;
					curCharacter = curCharacter.substr(0, curCharacter.length - 5);
				}
				var charJson:Dynamic = null;
				var isError:Bool = false;
				try {
					charJson = CoolUtil.parseJson(Assets.getText('assets/images/custom_chars/custom_chars.jsonc'));
				} catch (exception) {
					// uh oh someone messed up their json
					Application.current.window.alert("Hey! You messed up your custom_chars.jsonc. Your game won't crash but it will load bf. "+exception, "Alert");
					isError = true;
				}
				if (!isError) {
					// use assets, as it is less laggy
					var animJson = File.getContent("assets/images/custom_chars/"+Reflect.field(charJson,curCharacter).like+".json");
					if (!FileSystem.exists("assets/images/custom_chars/"+Reflect.field(charJson,curCharacter).like+".json"))
						var animJson = File.getContent("assets/images/custom_chars/bf.json"); //default to bf to avoid crashing.
					
					var parsedAnimJson:Dynamic = CoolUtil.parseJson(animJson);


					var playerSuffix = 'char';
					if (isDie) {
						// poor programming but whatev
						playerSuffix = 'dead';
						parsedAnimJson.animation = parsedAnimJson.deadAnimation;
						parsedAnimJson.offset = parsedAnimJson.deadOffset;
					}
					var rawPic = BitmapData.fromFile('assets/images/custom_chars/'+curCharacter+"/"+playerSuffix+".png");
					var tex:FlxAtlasFrames;
					var rawXml:String;
					// GOD IS DEAD WHY DOES THIS NOT WORK
					if (FileSystem.exists('assets/images/custom_chars/'+curCharacter+"/"+playerSuffix+".txt")){
						rawXml = File.getContent('assets/images/custom_chars/'+curCharacter+"/"+playerSuffix+".txt");
						tex = FlxAtlasFrames.fromSpriteSheetPacker(rawPic,rawXml);
					} else {
						rawXml = File.getContent('assets/images/custom_chars/'+curCharacter+"/"+playerSuffix+".xml");
						tex = FlxAtlasFrames.fromSparrow(rawPic,rawXml);
					}
					frames = tex;

					for(field in Reflect.fields(parsedAnimJson.animation) ) {
						var fps = 24;
						if (Reflect.hasField(Reflect.field(parsedAnimJson.animation,field), "fps")) {
							fps = Reflect.field(parsedAnimJson.animation,field).fps;
						}
						var loop = false;
						if (Reflect.hasField(Reflect.field(parsedAnimJson.animation,field), "loop")) {
							loop = Reflect.field(parsedAnimJson.animation,field).loop;
						}
						if (Reflect.hasField(Reflect.field(parsedAnimJson.animation,field),"flippedname") && !isPlayer) {
							// the double not is to turn a null into a false
							if (Reflect.hasField(Reflect.field(parsedAnimJson.animation,field),"indices")) {
								var indicesAnim:Array<Int> = Reflect.field(parsedAnimJson.animation,field).indices;
								animation.addByIndices(field, Reflect.field(parsedAnimJson.animation,field).flippedname, indicesAnim, "", fps, !!Reflect.field(parsedAnimJson.animation,field).loop);
							} else {
								animation.addByPrefix(field,Reflect.field(parsedAnimJson.animation,field).flippedname, fps, !!Reflect.field(parsedAnimJson.animation,field).loop);
							}

						} else {
							if (Reflect.hasField(Reflect.field(parsedAnimJson.animation,field),"indices")) {
								var indicesAnim:Array<Int> = Reflect.field(parsedAnimJson.animation,field).indices;
								animation.addByIndices(field, Reflect.field(parsedAnimJson.animation,field).name, indicesAnim, "", fps, !!Reflect.field(parsedAnimJson.animation,field).loop);
							} else {
								animation.addByPrefix(field,Reflect.field(parsedAnimJson.animation,field).name, fps, !!Reflect.field(parsedAnimJson.animation,field).loop);
							}
						}
					}
					for( field in Reflect.fields(parsedAnimJson.offset)) {
						addOffset(field, Reflect.field(parsedAnimJson.offset,field)[0],  Reflect.field(parsedAnimJson.offset,field)[1]);
					}

					camOffsetX = if (parsedAnimJson.camOffset != null) parsedAnimJson.camOffset[0] else 0;
					camOffsetY = if (parsedAnimJson.camOffset != null) parsedAnimJson.camOffset[1] else 0;
					enemyOffsetX = if (parsedAnimJson.enemyOffset != null) parsedAnimJson.enemyOffset[0] else 0;
					enemyOffsetY = if (parsedAnimJson.enemyOffset != null) parsedAnimJson.enemyOffset[1] else 0;
					followCamX = if (parsedAnimJson.followCam != null) parsedAnimJson.followCam[0] else 150;
					followCamY = if (parsedAnimJson.followCam != null) parsedAnimJson.followCam[1] else -100;
					midpointX = if (parsedAnimJson.midpoint != null) parsedAnimJson.midpoint[0] else 0;
					midpointY = if (parsedAnimJson.midpoint != null) parsedAnimJson.midpoint[1] else 0;
					flipX = if (parsedAnimJson.flipx != null) parsedAnimJson.flipx else false;

					/*healthColorArray[0] = if (parsedAnimJson.healthbar_color[0] != null) parsedAnimJson.healthbar_color[0] else 131;
					healthColorArray[1] = if (parsedAnimJson.healthbar_color[1] != null) parsedAnimJson.healthbar_color[1] else 234;
					healthColorArray[2] = if (parsedAnimJson.healthbar_color[2] != null) parsedAnimJson.healthbar_color[2] else 35;*/
					//gonna make it get your color from the custom_chars json.

					charHasNoteSkin = if (parsedAnimJson.hasNoteSkin != null) parsedAnimJson.hasNoteSkin else false;

				//	if (isPlayer) healthBarColor = PlayState.colormansucks; //why, why, why

					like = parsedAnimJson.like;
					if (like == "bf-car") {
						// ignore it, this is used for gameover state
						like = "bf";
					}

					if (like == "pico")
						trace('you can be gay right along with him');
					
					isPixel = parsedAnimJson.isPixel;
					if (parsedAnimJson.isPixel) {
						antialiasing = false;
						setGraphicSize(Std.int(width * 6));
						updateHitbox(); // when the hitbox is sus!
					}
					if (!isDie) {
						width += if (parsedAnimJson.size != null) parsedAnimJson.size[0] else 0;
						height += if (parsedAnimJson.size != null) parsedAnimJson.size[1] else 0;
					}
					playAnim(parsedAnimJson.playAnim);
				} else {
					// uh oh we got an error
					// pretend its boyfriend to prevent crashes
					var tex = FlxAtlasFrames.fromSparrow('assets/images/BOYFRIEND.png', 'assets/images/BOYFRIEND.xml');
					frames = tex;
					animation.addByPrefix('idle', 'BF idle dance', 24, false);
					animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
					animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
					animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
					animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
					animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
					animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
					animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
					animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
					animation.addByPrefix('hey', 'BF HEY', 24, false);

					animation.addByPrefix('firstDeath', "BF dies", 24, false);
					animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
					animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

					animation.addByPrefix('scared', 'BF idle shaking', 24);

					addOffset('idle', -5);
					addOffset("singUP", -29, 27);
					addOffset("singRIGHT", -38, -7);
					addOffset("singLEFT", 12, -6);
					addOffset("singDOWN", -10, -50);
					addOffset("singUPmiss", -29, 27);
					addOffset("singRIGHTmiss", -30, 21);
					addOffset("singLEFTmiss", 12, 24);
					addOffset("singDOWNmiss", -11, -19);
					addOffset("hey", 7, 4);
					addOffset('firstDeath', 37, 11);
					addOffset('deathLoop', 37, 5);
					addOffset('deathConfirm', 37, 69);
					addOffset('scared', -4);

					flipX = true;
					like = "bf";
					playAnim('idle');
				}

				#else
				// pretend its boyfriend, screw html5
				var tex = FlxAtlasFrames.fromSparrow('assets/images/BOYFRIEND.png', 'assets/images/BOYFRIEND.xml');
				frames = tex;
				animation.addByPrefix('idle', 'BF idle dance', 24, false);
				animation.addByPrefix('singUP', 'BF NOTE UP0', 24, false);
				animation.addByPrefix('singLEFT', 'BF NOTE LEFT0', 24, false);
				animation.addByPrefix('singRIGHT', 'BF NOTE RIGHT0', 24, false);
				animation.addByPrefix('singDOWN', 'BF NOTE DOWN0', 24, false);
				animation.addByPrefix('singUPmiss', 'BF NOTE UP MISS', 24, false);
				animation.addByPrefix('singLEFTmiss', 'BF NOTE LEFT MISS', 24, false);
				animation.addByPrefix('singRIGHTmiss', 'BF NOTE RIGHT MISS', 24, false);
				animation.addByPrefix('singDOWNmiss', 'BF NOTE DOWN MISS', 24, false);
				animation.addByPrefix('hey', 'BF HEY', 24, false);

				animation.addByPrefix('firstDeath', "BF dies", 24, false);
				animation.addByPrefix('deathLoop', "BF Dead Loop", 24, true);
				animation.addByPrefix('deathConfirm', "BF Dead confirm", 24, false);

				animation.addByPrefix('scared', 'BF idle shaking', 24);

				addOffset('idle', -5);
				addOffset("singUP", -29, 27);
				addOffset("singRIGHT", -38, -7);
				addOffset("singLEFT", 12, -6);
				addOffset("singDOWN", -10, -50);
				addOffset("singUPmiss", -29, 27);
				addOffset("singRIGHTmiss", -30, 21);
				addOffset("singLEFTmiss", 12, 24);
				addOffset("singDOWNmiss", -11, -19);
				addOffset("hey", 7, 4);
				addOffset('firstDeath', 37, 11);
				addOffset('deathLoop', 37, 5);
				addOffset('deathConfirm', 37, 69);
				addOffset('scared', -4);

				flipX = true;
				like = "bf";
				playAnim('idle');
				#end

				case true:
					var characterPath:String = "custom_chars/psych-"+curCharacter+".json";
					var path:String = Paths.imageJson(characterPath);
				
				if (!FileSystem.exists(path)) {
					path = Paths.getPreloadPath(characterPath);
				}

				if (!FileSystem.exists(path))
					var path:String = Paths.getPreloadPath(characterPath);

				if (!Assets.exists(path))
				{
					path = Paths.getPreloadPath("assets/images/custom_chars/psych-"+DEFAULT_CHARACTER+".json"); //If a character couldn't be found, change him to BF just to prevent a crash
				}

				var rawJson = Assets.getText(path);

				var json:CharacterFile = cast Json.parse(rawJson);
				var spriteType = "sparrow";
				var modTxtToFind:String = Paths.imageTxt(json.image);
				var txtToFind:String = Paths.getPath('images/' + json.image + '.txt', TEXT);
				
				//var modTextureToFind:String = Paths.modFolders("images/"+json.image);
				//var textureToFind:String = Paths.getPath('images/' + json.image, new AssetType();
				
				if (Assets.exists(Paths.getPath('images/' + json.image + '.txt', TEXT)))
				{
					spriteType = "packer";
				}		
				
				if (Assets.exists(Paths.getPath('images/' + json.image + '/Animation.json', TEXT)))
				{
					
					spriteType = "texture";
					
				}
				
				switch (spriteType){
					
					case "packer":
						frames = Paths.getPackerAtlas(json.image);
					
					case "sparrow":
						frames = Paths.getSparrowAtlas(json.image);
					
					case "texture":
						frames = AtlasFrameMaker.construct(json.image);
				}
				
				imageFile = json.image;

				if(json.scale != 1) {
					jsonScale = json.scale;
					setGraphicSize(Std.int(width * jsonScale));
					updateHitbox();
				}

				positionArray = json.position;
				cameraPosition = json.camera_position;

				healthIcon = json.healthicon;
				singDuration = json.sing_duration;
				flipX = !!json.flip_x;
				if(json.no_antialiasing) {
					antialiasing = false;
					noAntialiasing = true;
				}

				if(json.healthbar_color != null && json.healthbar_color.length > 2)
					healthColorArray = json.healthbar_color;

				antialiasing = !noAntialiasing;
				if(!ClientPrefs.globalAntialiasing) antialiasing = false;

				animationsArray = json.animations;
				if(animationsArray != null && animationsArray.length > 0) {
					for (anim in animationsArray) {
						var animAnim:String = '' + anim.anim;
						var animName:String = '' + anim.name;
						var animFps:Int = anim.fps;
						var animLoop:Bool = !!anim.loop; //Bruh
						var animIndices:Array<Int> = anim.indices;
						if(animIndices != null && animIndices.length > 0) {
							animation.addByIndices(animAnim, animName, animIndices, "", animFps, animLoop);
						} else {
							animation.addByPrefix(animAnim, animName, animFps, animLoop);
						}

						if(anim.offsets != null && anim.offsets.length > 1) {
							addOffset(anim.anim, anim.offsets[0], anim.offsets[1]);
						}
					}
				} else {
					quickAnimAdd('idle', 'BF idle dance');
				}
				//trace('Loaded file to character ' + curCharacter);
				}
		}

		if (setLike) {
			switch (curCharacter)
			{
				case 'gf' | 'gf-christmas':
					like = "bf";
				case 'bf' | 'bf-christmas':
					like = "bf";
				case 'mom' | 'mom-car':
					like = "mom";
				case 'monster' | 'monster-christmas':
					like = "newmonster";
				default:
					like = curCharacter;
			}
		}

		dance();

		if (isPlayer)
		{
			flipX = !flipX;

			// Doesn't flip for BF, since his are already in the right place???
			if (!curCharacter.startsWith('bf'))
			{
				// var animArray
				var oldRight = animation.getByName('singRIGHT').frames;
				animation.getByName('singRIGHT').frames = animation.getByName('singLEFT').frames;
				animation.getByName('singLEFT').frames = oldRight;

				// IF THEY HAVE MISS ANIMATIONS??
				if (animation.getByName('singRIGHTmiss') != null)
				{
					var oldMiss = animation.getByName('singRIGHTmiss').frames;
					animation.getByName('singRIGHTmiss').frames = animation.getByName('singLEFTmiss').frames;
					animation.getByName('singLEFTmiss').frames = oldMiss;
				}
			}
		}
	}

	override function update(elapsed:Float)
	{
		if (!isPlayingAsBF)
		{
			if (curCharacter.startsWith('bf') && !isPlayer)
				{
					if (animation.curAnim.name.startsWith('sing'))
					{
						holdTimer += elapsed;
					}
		
					var dadVar:Float = 4;
		
					if (curCharacter == 'dad')
						dadVar = 6.1;
					if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
					{
						trace('dance');
						dance();
						holdTimer = 0;
					}
				}
		
		}
		else
		{
			if (!isPlayer)
				{
					if (animation.curAnim.name.startsWith('sing'))
					{
						holdTimer += elapsed;
					}
		
					var dadVar:Float = 4;
		
					if (curCharacter == 'dad')
						dadVar = 6.1;
					if (holdTimer >= Conductor.stepCrochet * dadVar * 0.001)
					{
						trace('dance');
						dance();
						holdTimer = 0;
					}
				}
		}
		
		switch (curCharacter)
		{
			case 'gf':
				if (animation.curAnim.name == 'hairFall' && animation.curAnim.finished)
					playAnim('danceRight');
		}

		super.update(elapsed);
	}

	private var danced:Bool = false;

	/**
	 * FOR GF DANCING SHIT
	 */
	public function dance()
	{
		noDanceTwice++;
		if (noDanceTwice == 2) {
			noDanceTwice = 0;
		if (!debugMode && !FileSystem.exists("assets/images/custom_chars/"+curCharacter+".hscript"))
		{
			switch (curCharacter)
			{
				case 'gf':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'gf-christmas':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'gf-car':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}
				case 'gf-pixel':
					if (!animation.curAnim.name.startsWith('hair'))
					{
						danced = !danced;

						if (danced)
							playAnim('danceRight');
						else
							playAnim('danceLeft');
					}

				case 'spooky':
					danced = !danced;

					if (danced)
						playAnim('danceRight');
					else
						playAnim('danceLeft');
				default:
					playAnim('idle');
			}
		} else if (!debugMode) {
			if (!debugMode && beNormal)
			{
				if (charScript.interp != null)
					call("dance", [this])
				else
					playAnim('idle');

				if (color != FlxColor.WHITE)
				{
					color = FlxColor.WHITE;
				}
			}
		}
	}
	}

	public function playAnim(AnimName:String, Force:Bool = false, Reversed:Bool = false, Frame:Int = 0):Void
	{
		animation.play(AnimName, Force, Reversed, Frame);

		var daOffset = animOffsets.get(AnimName);
		if (animOffsets.exists(AnimName))
		{
			offset.set(daOffset[0], daOffset[1]);
		}
		else
			offset.set(0, 0);

		if (curCharacter == 'gf')
		{
			if (AnimName == 'singLEFT')
			{
				danced = true;
			}
			else if (AnimName == 'singRIGHT')
			{
				danced = false;
			}

			if (AnimName == 'singUP' || AnimName == 'singDOWN')
			{
				danced = !danced;
			}
		}
	}

	public function addOffset(name:String, x:Float = 0, y:Float = 0)
	{
		animOffsets[name] = [x, y];
	}

	public function getAnimJson(char:String) {
		switch (isPsychFile) {
			case false:
				var charJson = CoolUtil.parseJson(Assets.getText('assets/images/custom_chars/custom_chars.jsonc'));
				var animJson = CoolUtil.parseJson(File.getContent('assets/images/custom_chars/'+Reflect.field(charJson,char).like + '.json'));
				return animJson;
			case true: 
				var animJson = CoolUtil.parseJson(File.getContent('assets/images/custom_chars/psych-'+ curCharacter.toLowerCase() + '.json'));
				return animJson;
		}
	}

	public function recalculateDanceIdle() {
		danceIdle = (animation.getByName('danceLeft' + idleSuffix) != null && animation.getByName('danceRight' + idleSuffix) != null);
	}
	public function quickAnimAdd(name:String, anim:String, fps:Int = 24, loop:Bool = false)
	{
		animation.addByPrefix(name, anim, fps, loop);
	}
}
