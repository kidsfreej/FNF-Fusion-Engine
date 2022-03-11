package;

import flixel.input.gamepad.FlxGamepad;
import Controls.KeyboardScheme;
import flixel.FlxG;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.effects.FlxFlicker;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import io.newgrounds.NG;
import lime.app.Application;

#if windows
import Discord.DiscordClient;
#end

import flixel.FlxBasic;
import flixel.addons.transition.FlxTransitionableState;
import flixel.FlxSubState;
import hscript.Expr;
import hscript.Interp;
import hscript.Parser;

import lime.app.Application;
import haxe.Json;
import haxe.format.JsonParser;
import Section.SwagSection;
import Song.SwagSong;

#if sys
import sys.io.File;
import sys.FileSystem;
#end

#if sys
import haxe.io.Path;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;
import flixel.system.FlxSound;
#end

using StringTools;

class MainMenuState extends MusicBeatState
{
	var curSelected:Int = 0;

	var menuItems:FlxTypedGroup<FlxSprite>;

	//#if !switch
//	var optionShit:Array<String> = ['story mode', 'freeplay', 'donate', 'options'];
//	#else
//	var optionShit:Array<String> = ['story mode', 'freeplay'];
//	#end

	var optionShit:Array<String> = ['story_mode', 'freeplay', 'credits', #if !switch 'donate', #end 'options'];

	var newGaming:FlxText;
	var newGaming2:FlxText;
	public static var firstStart:Bool = true;

	public static var nightly:String = "";
	public static var kadeEngineVerNum:String = "0.4" + nightly;

	public static var kadeEngineVer:String = "Better Fusion Engine 0.4" + nightly;
	public static var gameVer:String = "0.2.7.1";

	var magenta:FlxSprite;
	var camFollow:FlxObject;
	public static var finishedFunnyMove:Bool = false;
	public static var curSong:String = "Freaky Menu";

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (!FlxG.sound.music.playing)
		{
			FlxG.sound.playMusic(Paths.music('freakyMenu'));
			FlxG.sound.music.onComplete = MainMenuState.musicShit;
		}

		persistentUpdate = persistentDraw = true;

		var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('menuBG'));
		bg.scrollFactor.x = 0;
		bg.scrollFactor.y = 0.10;
		bg.setGraphicSize(Std.int(bg.width * 1.1));
		bg.updateHitbox();
		bg.screenCenter();
		bg.antialiasing = true;
		add(bg);

		camFollow = new FlxObject(0, 0, 1, 1);
		add(camFollow);

		magenta = new FlxSprite(-80).loadGraphic(Paths.image('menuDesat'));
		magenta.scrollFactor.x = 0;
		magenta.scrollFactor.y = 0.10;
		magenta.setGraphicSize(Std.int(magenta.width * 1.1));
		magenta.updateHitbox();
		magenta.screenCenter();
		magenta.visible = false;
		magenta.antialiasing = true;
		magenta.color = 0xFFfd719b;
		add(magenta);
		// magenta.scrollFactor.set();

		menuItems = new FlxTypedGroup<FlxSprite>();
		add(menuItems);

		var tex = Paths.getSparrowAtlas('FNF_main_menu_assets');

		/*for (i in 0...optionShit.length)
		{
			var menuItem:FlxSprite = new FlxSprite(0, FlxG.height * 1.6);
			menuItem.frames = tex;
			menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
			menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
			menuItem.animation.play('idle');
			menuItem.ID = i;
			menuItem.screenCenter(X);
			menuItems.add(menuItem);
			menuItem.scrollFactor.set();
			menuItem.antialiasing = true;
			if (firstStart)
				FlxTween.tween(menuItem,{y: 60 + (i * 160)},1 + (i * 0.25) ,{ease: FlxEase.expoInOut, onComplete: function(flxTween:FlxTween) 
					{ 
						finishedFunnyMove = true; 
						changeItem();
					}});
			else
				menuItem.y = 60 + (i * 160);
		}*/
		for (i in 0...optionShit.length)
			{
				var offset:Float = 108 - (Math.max(optionShit.length, 4) - 4) * 80;
				var menuItem:FlxSprite = new FlxSprite(0, (i * 140)  + offset);
				menuItem.frames = Paths.getSparrowAtlas('mainmenu/menu_' + optionShit[i]);
				menuItem.animation.addByPrefix('idle', optionShit[i] + " basic", 24);
				menuItem.animation.addByPrefix('selected', optionShit[i] + " white", 24);
				menuItem.animation.play('idle');
				menuItem.ID = i;
				menuItem.screenCenter(X);
				menuItems.add(menuItem);
				var scr:Float = (optionShit.length - 4) * 0.135;
				if(optionShit.length < 6) scr = 0;
				menuItem.scrollFactor.set(0, scr);
				menuItem.antialiasing = FlxG.save.data.antialiasing;
				//menuItem.setGraphicSize(Std.int(menuItem.width * 0.58));
				menuItem.updateHitbox();
			}

		firstStart = false;

		FlxG.camera.follow(camFollow, null, 0.60 * (60 / FlxG.save.data.fpsCap));

		var versionShit:FlxText = new FlxText(5, FlxG.height - 18, 0, Application.current.meta.get('version') + ' | Better Fusion Engine 0.3 Release', 12);
		versionShit.scrollFactor.set();
		versionShit.setFormat("VCR OSD Mono", 16, FlxColor.WHITE, LEFT, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		add(versionShit);

		// NG.core.calls.event.logEvent('swag').send();


		if (FlxG.save.data.dfjk)
			controls.setKeyboardScheme(KeyboardScheme.Solo, true);
		else
			controls.setKeyboardScheme(KeyboardScheme.Duo(true), true);

		changeItem();

		Application.current.window.onDropFile.add(function (path:String)
		{
			var rawJson = File.getContent(path).trim();
			while (!rawJson.endsWith("}"))
			{
				rawJson = rawJson.substr(0, rawJson.length - 1);
			}
			var swagShit:SwagSong = cast Json.parse(rawJson).song;
			if (swagShit.validScore == false)
				swagShit.validScore = true;
	
			PlayState.SONG = swagShit;
			PlayState.isFreeplayChart = true;
			PlayState.didDownloadContent = false;
			PlayState.isStoryMode = false;
			PlayState.storyDifficulty = 0;
			CoolUtil.CurSongDiffs = ['NORMAL'];
			PlayState.storyWeek = 0;
			FlxG.switchState(new DownloadingState(PlayState.SONG.downloadingStuff));
		});

		super.create();
	}

	var selectedSomethin:Bool = false;

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.8)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		FlxG.watch.addQuick("beatShit", curBeat);
		FlxG.watch.addQuick("stepShit", curStep);

		if (FlxG.keys.justPressed.FIVE)
		{
				musicShit();
		}

		if (!selectedSomethin)
		{
			var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

			if (gamepad != null)
			{
				if (gamepad.justPressed.DPAD_UP)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(-1);
				}
				if (gamepad.justPressed.DPAD_DOWN)
				{
					FlxG.sound.play(Paths.sound('scrollMenu'));
					changeItem(1);
				}
			}

			if (FlxG.keys.justPressed.UP)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(-1);
			}

			if (FlxG.keys.justPressed.DOWN)
			{
				FlxG.sound.play(Paths.sound('scrollMenu'));
				changeItem(1);
			}

			if (controls.BACK)
			{
				FlxG.switchState(new TitleState());
			}

			if (controls.ACCEPT)
				{
					if (optionShit[curSelected] == 'donate')
					{
						fancyOpenURL("https://ninja-muffin24.itch.io/funkin");
					}
					else
					{
						selectedSomethin = true;
						FlxG.sound.play(Paths.sound('confirmMenu'));
						
						if (FlxG.save.data.flashing)
							FlxFlicker.flicker(magenta, 1.1, 0.15, false);
	
						menuItems.forEach(function(spr:FlxSprite)
						{
							if (curSelected != spr.ID)
							{
								FlxTween.tween(spr, {alpha: 0}, 1.3, {
									ease: FlxEase.quadOut,
									onComplete: function(twn:FlxTween)
									{
										spr.kill();
									}
								});
							}
							else
							{
								if (FlxG.save.data.flashing)
								{
									FlxFlicker.flicker(spr, 1, 0.06, false, false, function(flick:FlxFlicker)
									{
										goToState();
									});
								}
								else
								{
									new FlxTimer().start(1, function(tmr:FlxTimer)
									{
										goToState();
									});
								}
							}
						});
					}
				}
		}

		super.update(elapsed);

		menuItems.forEach(function(spr:FlxSprite)
		{
			spr.screenCenter(X);
		});
	}

	override function beatHit()
	{
		super.beatHit();

		if (TitleState.camZooming)
			FlxTween.tween(FlxG.camera, {zoom:1.05}, 0.3, {ease: FlxEase.quadOut, type: BACKWARD});
	}
	
	function goToState()
	{
		var daChoice:String = optionShit[curSelected];

		switch (daChoice)
		{
			case 'story_mode':
				FlxG.switchState(new StoryMenuState());
				trace("Story Menu Selected");
			case 'freeplay':
				//FlxG.switchState(new FreeplayState());
				var parsed:Dynamic = CoolUtil.parseJson(File.getContent('assets/data/freeplaySongJson.jsonc'));

				if(parsed.length==1){
					FreeplayState.id = 0;
					FlxG.switchState(new FreeplayState());
				}else{
					FlxG.switchState(new FreeplayCategory());
				}
				trace("Freeplay Menu Selected");
			case 'credits':
				FlxG.switchState(new CreditsState());
				trace("Credits Menu Selected");
			case 'options':
				FlxG.switchState(new OptionsMenu());
				trace("Options Menu Selected");
		}
	}

	function changeItem(huh:Int = 0)
		{
			curSelected += huh;
	
			if (curSelected >= menuItems.length)
				curSelected = 0;
			if (curSelected < 0)
				curSelected = menuItems.length - 1;
	
			menuItems.forEach(function(spr:FlxSprite)
			{
				spr.animation.play('idle');
				spr.offset.y = 0;
				spr.updateHitbox();
	
				if (spr.ID == curSelected)
				{
					spr.animation.play('selected');
					camFollow.setPosition(spr.getGraphicMidpoint().x, spr.getGraphicMidpoint().y);
					spr.offset.x = 0.15 * (spr.frameWidth / 2 + 180);
					spr.offset.y = 0.15 * spr.frameHeight;
					FlxG.log.add(spr.frameWidth);
				}
			});
		}

	public static function musicShit():Void
		{
			#if sys
			FlxG.sound.music.stop();
			var parsed = CoolUtil.parseJson(File.getContent('assets/data/freeplaySongJson.jsonc'));
			var initSonglist:Dynamic = parsed[0].songs;
			var initSonglistL:Int = 0;

			for (i in  0...initSonglist.length)
			{ 
				initSonglistL ++;
			}

			if (initSonglistL > 0)
			{
				var randomSong = FlxG.random.int(0, initSonglistL - 1);
	
		//		var song = initSonglist[randomSong].toLowerCase();

				for (i in 0...initSonglist.length)
				{
					var r = FlxG.random.int(0, initSonglistL - 1);
					var s = initSonglist[i];

					if (r == i && FlxG.sound.music == null) {
					//	FlxG.sound.playMusic(Sound.fromFile(Paths.inst(songs[curSelected].songName.toLowerCase(), '')), 1, false);
						trace(Std.string(s.toLowerCase()));
						FlxG.sound.playMusic(Sound.fromFile(Paths.inst(Std.string(s.toLowerCase()), '')), 0.6, true);
						curSong = Std.string(s);
					}
				}

				if (FlxG.sound.music == null)
					FlxG.sound.playMusic(Paths.music('freakyMenu'), 1);
			}
			else 
				FlxG.sound.playMusic(Paths.music('freakyMenu'), 1);
	
			#else 
			FlxG.sound.playMusic(Paths.music('freakyMenu'), 1);
			#end
	
			FlxG.sound.music.onComplete = MainMenuState.musicShit;
			
			//CacheShit.clearCache();
	
			/*songText = new FlxText(FlxG.width * 0.7, -1000, 0, "Now Playing: " + curSong, 20);
			songText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, LEFT, OUTLINE, FlxColor.BLACK);
			songText.scrollFactor.set();
			add(songText);
			FlxTween.tween(songText, {x: 100}, 1, {ease: FlxEase.quadInOut, 
				onComplete: function(twn:FlxTween)
				{
					new FlxTimer().start(4, function(tmr:FlxTimer)
					{
						FlxTween.tween(songText, {x: -1000}, 1, {ease: FlxEase.quadInOut, 
							onComplete: function(twn:FlxTween)
							{
								remove(songText);
								songText.destroy();
							}});
					});
				}});*/
			//apparently you literaly cant add sprites inside a static function bruh
		}
}
