package;

import flixel.input.gamepad.FlxGamepad;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;
import flixel.util.FlxTimer;
import lime.net.curl.CURLCode;

#if windows
import Discord.DiscordClient;
#end

#if sys
import sys.io.File;
import sys.FileSystem;
#end

import lime.net.curl.CURLCode;

import flixel.graphics.FlxGraphic;
import openfl.display.BitmapData;

using StringTools;

typedef StorySongsJson = 
{
	var songs: Array<Array<String>>;
	var weekGreyText: Array<String>;
	var weekNames: Array<String>;
	var diffs:Array<Array<String>>;
	var diffSuffix:Array<String>;
	var characters: Array<Array<String>>;
	var weekUnlocked:Array<Bool>;
}

typedef DifficultysJson = 
{
	var difficulties:Array<Dynamic>;
	var defaultDiff:Int;
}
typedef StoryMenuData = 
{
	var menuCharacters:Array<MenuChar>;
	var weeks:Array<Weeks>;
	var lockWeeks:Bool;
}
typedef Weeks =
{
	var weekNum:Int;
	var characters:Array<String>;
	var diffs:Array<String>;
	var diffSuffix:Array<String>;
	var songs:Array<String>;
	var desc:String;
} 

typedef MenuChar = 
{
	var fileName:String;
	var anims:Array<AnimOffsets>;
	var offsets:Array<Float>;
	var flip:Bool;
	var scale:Float;
	var name:String;
}
typedef AnimOffsets = 
{
	var anim:String; 
	var xmlname:String;
	var frameRate:Int;
	var loop:Bool;
}

class StoryMenuState extends MusicBeatState
{
	var scoreText:FlxText;

	var weekData:Array<Dynamic> = [
		/*['Tutorial'],
		['Bopeebo', 'Fresh', 'Dad Battle'],
		['Spookeez', 'South', "Monster"],
		['Pico', 'Philly Nice', "Blammed"],
		['Satin Panties', "High", "Milf"],
		['Cocoa', 'Eggnog', 'Winter Horrorland'],
		// ['Senpai', 'Roses', 'Thorns']*/
	];
	var curDifficulty:Int = 1;

	public static var weekUnlocked:Array<Bool> = [/*true, true, true, true, true, true, true*/];

	var weekCharacters:Array<Dynamic> = [
		/*['', 'bf', 'gf'],
		['dad', 'bf', 'gf'],
		['spooky', 'bf', 'gf'],
		['pico', 'bf', 'gf'],
		['mom', 'bf', 'gf'],
		['parents-christmas', 'bf', 'gf'],
		['senpai', 'bf', 'gf']*/
	];

	var weekGreyText:Array<String> = [];

	var weekNames:Array<String> = [
		/*"",
		"Daddy Dearest",
		"Spooky Month",
		"PICO",
		"MOMMY MUST MURDER",
		"RED SNOW",
		"Hating Simulator ft. Moawling"*/
	];

	var txtWeekTitle:FlxText;

	public static var curWeek:Int = 0;

	var txtTracklist:FlxText;

	var grpWeekText:FlxTypedGroup<MenuItem>;
	var grpWeekCharacters:FlxTypedGroup<MenuCharacter>;

	var grpLocks:FlxTypedGroup<FlxSprite>;

	var difficultySelectors:FlxGroup;
	var sprDifficulty:FlxSprite;
	var diffList:Array<Array<String>> = [];
	var leftArrow:FlxSprite;
	var rightArrow:FlxSprite;

	override function create()
	{
		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Story Mode Menu", null);
		#end

		transIn = FlxTransitionableState.defaultTransIn;
		transOut = FlxTransitionableState.defaultTransOut;

		if (FlxG.sound.music != null)
		{
			if (!FlxG.sound.music.playing)
				FlxG.sound.playMusic(Paths.music('freakyMenu'));
		}

		var storySongJson:StorySongsJson = CoolUtil.parseJson(File.getContent('assets/data/storySonglist.json'));

		for (storySongList in storySongJson.songs) 
		{
			var weekSongs = [];
			for (song in storySongList) 
			{
				if (storySongList[0] == song) 
				{
				//	weekNames.push(song);
			} else 
				{
						weekSongs.push(song);
				}
			}
			weekData.push(weekSongs);
		}
	
		for (i in storySongJson.diffs)
		{
			diffList.push(i);
		}

		for (i in storySongJson.weekGreyText)
		{
			weekNames.push(i);
		}

		for (i in storySongJson.weekUnlocked)
		{
			if(i == false)
				weekUnlocked.push(false);
			else 
				weekUnlocked.push(true);
		}
	
		for (storyCharList in storySongJson.characters) 
		{
			var weekChars = [];
			for (char in storyCharList) 
			{
				weekChars.push(char);
			}
			weekCharacters.push(weekChars);
		}

		persistentUpdate = persistentDraw = true;

		scoreText = new FlxText(10, 10, 0, "SCORE: 49324858", 36);
		scoreText.setFormat("VCR OSD Mono", 32);

		txtWeekTitle = new FlxText(FlxG.width * 0.7, 10, 0, "", 32);
		txtWeekTitle.setFormat("VCR OSD Mono", 32, FlxColor.WHITE, RIGHT);
		txtWeekTitle.alpha = 0.7;

		var rankText:FlxText = new FlxText(0, 10);
		rankText.text = 'RANK: GREAT';
		rankText.setFormat(Paths.font("vcr.ttf"), 32);
		rankText.size = scoreText.size;
		rankText.screenCenter(X);

		var ui_tex = Paths.getSparrowAtlas('campaign_menu_UI_assets');
		var yellowBG:FlxSprite = new FlxSprite(0, 56).makeGraphic(FlxG.width, 400, 0xFFF9CF51);

		grpWeekText = new FlxTypedGroup<MenuItem>();
		add(grpWeekText);

		var blackBarThingie:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, 56, FlxColor.BLACK);
		add(blackBarThingie);

		grpWeekCharacters = new FlxTypedGroup<MenuCharacter>();

		grpLocks = new FlxTypedGroup<FlxSprite>();
		add(grpLocks);

		trace("Line 70");

		for (i in 0...weekData.length)
		{
			var weekThing:MenuItem = new MenuItem(0, yellowBG.y + yellowBG.height + 10, i);
			weekThing.y += ((weekThing.height + 20) * i);
			weekThing.targetY = i;
			grpWeekText.add(weekThing);

			weekThing.screenCenter(X);
			weekThing.antialiasing = true;
			// weekThing.updateHitbox();

			// Needs an offset thingie
			if (!weekUnlocked[i])
			{
				var lock:FlxSprite = new FlxSprite(weekThing.width + 10 + weekThing.x);
				lock.frames = ui_tex;
				lock.animation.addByPrefix('lock', 'lock');
				lock.animation.play('lock');
				lock.ID = i;
				lock.antialiasing = true;
				grpLocks.add(lock);
			}
		}

		trace("Line 96");

		grpWeekCharacters.add(new MenuCharacter(0, 100, 0.5, false));
		grpWeekCharacters.add(new MenuCharacter(450, 25, 0.9, true));
		grpWeekCharacters.add(new MenuCharacter(850, 100, 0.5, true));

		difficultySelectors = new FlxGroup();
		add(difficultySelectors);

		trace("Line 124");

		leftArrow = new FlxSprite(grpWeekText.members[0].x + grpWeekText.members[0].width + 10, grpWeekText.members[0].y + 10);
		leftArrow.frames = ui_tex;
		leftArrow.animation.addByPrefix('idle', "arrow left");
		leftArrow.animation.addByPrefix('press', "arrow push left");
		leftArrow.animation.play('idle');
		difficultySelectors.add(leftArrow);

		var diffPath = 'assets/images/custom_difficulties/' + diffList[curWeek][curDifficulty] + ".png"; //maybe i will have seperate folders for more customizability
		//trace(diffList[curWeek][curDifficulty]);
		/*var diffImage:FlxGraphic;
		if (CacheShit.images[diffPath] == null)
		{
			var image:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(diffPath));
			image.persist = true;
			CacheShit.images[diffPath] = image;
		}
		diffImage = CacheShit.images[diffPath];*/
		//trace(BitmapData.fromFile(diffPath));
		//trace(diffPath);

		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y).loadGraphic(BitmapData.fromFile(diffPath));
	//	changeDifficulty();

		difficultySelectors.add(sprDifficulty);

		rightArrow = new FlxSprite(leftArrow.x + 130 + sprDifficulty.width + 50, leftArrow.y);
		rightArrow.frames = ui_tex;
		rightArrow.animation.addByPrefix('idle', 'arrow right');
		rightArrow.animation.addByPrefix('press', "arrow push right", 24, false);
		rightArrow.animation.play('idle');
		difficultySelectors.add(rightArrow);
		changeDifficulty();

		trace("Line 299");

		add(yellowBG);
		add(grpWeekCharacters);

		txtTracklist = new FlxText(FlxG.width * 0.05, yellowBG.x + yellowBG.height + 100, 0, "Tracks", 32);
		txtTracklist.alignment = CENTER;
		txtTracklist.font = rankText.font;
		txtTracklist.color = 0xFFe55777;
		add(txtTracklist);
		// add(rankText);
		add(scoreText);
		add(txtWeekTitle);

		updateText();

		trace("Line 165");

		super.create();
	}

	override function update(elapsed:Float)
	{
		// scoreText.setFormat('VCR OSD Mono', 32);
		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.5));

		scoreText.text = "WEEK SCORE:" + lerpScore;

		txtWeekTitle.text = weekNames[curWeek].toUpperCase();
		txtWeekTitle.x = FlxG.width - (txtWeekTitle.width + 10);

		// FlxG.watch.addQuick('font', scoreText.font);

		difficultySelectors.visible = weekUnlocked[curWeek];
		sprDifficulty.visible = weekUnlocked[curWeek];

		grpLocks.forEach(function(lock:FlxSprite)
		{
			lock.y = grpWeekText.members[lock.ID].y;
		});

		if (!movedBack)
		{
			if (!selectedWeek)
			{
				var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

				if (gamepad != null)
				{
					if (gamepad.justPressed.DPAD_UP)
					{
						changeWeek(-1);
					}
					if (gamepad.justPressed.DPAD_DOWN)
					{
						changeWeek(1);
					}

					if (gamepad.pressed.DPAD_RIGHT)
						rightArrow.animation.play('press')
					else
						rightArrow.animation.play('idle');
					if (gamepad.pressed.DPAD_LEFT)
						leftArrow.animation.play('press');
					else
						leftArrow.animation.play('idle');

					if (gamepad.justPressed.DPAD_RIGHT)
					{
						changeDifficulty(1);
					}
					if (gamepad.justPressed.DPAD_LEFT)
					{
						changeDifficulty(-1);
					}
				}

				if (FlxG.keys.justPressed.UP)
				{
					changeWeek(-1);
				}

				if (FlxG.keys.justPressed.DOWN)
				{
					changeWeek(1);
				}

				if (controls.RIGHT)
					rightArrow.animation.play('press')
				else
					rightArrow.animation.play('idle');

				if (controls.LEFT)
					leftArrow.animation.play('press');
				else
					leftArrow.animation.play('idle');

				if (controls.RIGHT_P)
					changeDifficulty(1);
				if (controls.LEFT_P)
					changeDifficulty(-1);
			}

			if (controls.ACCEPT)
			{
				selectWeek();
			}
		}

		if (controls.BACK && !movedBack && !selectedWeek)
		{
			FlxG.sound.play(Paths.sound('cancelMenu'));
			movedBack = true;
			FlxG.switchState(new MainMenuState());
		}

		super.update(elapsed);
	}

	var movedBack:Bool = false;
	var selectedWeek:Bool = false;
	var stopspamming:Bool = false;

	function selectWeek()
	{
		if (weekUnlocked[curWeek])
		{
			if (stopspamming == false)
			{
				FlxG.sound.play(Paths.sound('confirmMenu'));

				grpWeekText.members[curWeek].startFlashing();
				grpWeekCharacters.members[1].animation.play('bfConfirm');
				stopspamming = true;
				PlayState.songDiffsArray = diffList;
			}

			PlayState.storyPlaylist = weekData[curWeek];
			PlayState.isStoryMode = true;
			selectedWeek = true;


			PlayState.storyDifficulty = curDifficulty;

			// adjusting the song name to be compatible
			var songFormat = StringTools.replace(PlayState.storyPlaylist[0], " ", "-");
			switch (songFormat) {
				case 'Dad-Battle': songFormat = 'Dadbattle';
				case 'Philly-Nice': songFormat = 'Philly';
			}

			var poop:String = Highscore.formatSong(songFormat, curDifficulty);
			PlayState.sicks = 0;
			PlayState.bads = 0;
			PlayState.shits = 0;
			PlayState.goods = 0;
			PlayState.campaignMisses = 0;
			PlayState.SONG = Song.loadFromJson(poop, PlayState.storyPlaylist[0]);
			PlayState.storyWeek = curWeek;
			PlayState.campaignScore = 0;
			new FlxTimer().start(1, function(tmr:FlxTimer)
			{
				LoadingState.loadAndSwitchState(new PlayState(), true);
			});
		}
	}

	function changeDifficulty(change:Int = 0):Void
	{
		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = diffList[curWeek].length - 1;
		if (curDifficulty > diffList[curWeek].length - 1)
			curDifficulty = 0;

		difficultySelectors.remove(sprDifficulty); //remake diff sprite
		var diffPath = 'assets/images/custom_difficulties/' + diffList[curWeek][curDifficulty] + ".png";
		/*var diffImage:FlxGraphic;
		if (CacheShit.images[diffPath] == null)
		{
			var image:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(diffPath));
			image.persist = true;
			CacheShit.images[diffPath] = image;
		}
		diffImage = CacheShit.images[diffPath];*/
		sprDifficulty = new FlxSprite(leftArrow.x + 130, leftArrow.y).loadGraphic(BitmapData.fromFile(diffPath));
		difficultySelectors.add(sprDifficulty);

		sprDifficulty.offset.x = 0;

		switch (curDifficulty)
		{
			case 0:
				sprDifficulty.offset.x = 20;
			case 1:
				sprDifficulty.offset.x = 70;
			case 2:
				sprDifficulty.offset.x = 20;
		}

		rightArrow.x = sprDifficulty.x + sprDifficulty.width;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;

		sprDifficulty.alpha = 0;

		// USING THESE WEIRD VALUES SO THAT IT DOESNT FLOAT UP
		sprDifficulty.y = leftArrow.y - 15;
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end

		FlxTween.tween(sprDifficulty, {y: leftArrow.y + 15, alpha: 1}, 0.07);
	}

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;

	function changeWeek(change:Int = 0):Void
	{
		curWeek += change;

		if (curWeek >= weekData.length)
			curWeek = 0;
		if (curWeek < 0)
			curWeek = weekData.length - 1;

		var bullShit:Int = 0;

		for (item in grpWeekText.members)
		{
			item.targetY = bullShit - curWeek;
			if (item.targetY == Std.int(0) && weekUnlocked[curWeek])
				item.alpha = 1;
			else
				item.alpha = 0.6;
			bullShit++;
		}

		FlxG.sound.play(Paths.sound('scrollMenu'));

		updateText();
	}

	function updateText()
	{
		grpWeekCharacters.members[0].setCharacter(weekCharacters[curWeek][0]);
		grpWeekCharacters.members[1].setCharacter(weekCharacters[curWeek][1]);
		grpWeekCharacters.members[2].setCharacter(weekCharacters[curWeek][2]);

		txtTracklist.text = "Tracks\n";
		var stringThing:Array<String> = weekData[curWeek];

		for (i in stringThing)
			txtTracklist.text += "\n" + i;

		txtTracklist.text = txtTracklist.text.toUpperCase();

		txtTracklist.screenCenter(X);
		txtTracklist.x -= FlxG.width * 0.35;

		txtTracklist.text += "\n";

		#if !switch
		intendedScore = Highscore.getWeekScore(curWeek, curDifficulty);
		#end
	}
}
