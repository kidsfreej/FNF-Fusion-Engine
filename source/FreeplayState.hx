package;

import Section.SwagSection;
import Song.SwagSong;
import WiggleEffect.WiggleEffectType;
import flash.text.TextField;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.FlxGraphic;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.gamepad.FlxGamepad;
import flixel.math.FlxMath;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxAssets;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import haxe.format.JsonParser;
import lime.app.Application;
import lime.graphics.Image;
import lime.media.AudioContext;
import lime.media.AudioManager;
import lime.utils.Assets;
import lime.utils.Assets;
import llua.Convert;
import llua.Lua;
import llua.LuaL;
import llua.State;
import openfl.Lib;
import openfl.display.BitmapData;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import openfl.geom.Matrix;
import openfl.utils.AssetLibrary;
import openfl.utils.AssetManifest;
import openfl.utils.AssetType;

using StringTools;

#if sys
import flash.media.Sound;
import sys.FileSystem;
import sys.io.File;
#end
#if windows
import Discord.DiscordClient;
#end

typedef FreeplayJson = {
	var songs:Array<String>;
	var icons:Array<String>;
	var categories:Array<String>;
}

class SongMetadatas {
	public var songName:String = "";
	public var week:Int = 0;
	public var songCharacter:String = "";
	public var isFreeplayChart:Bool = false;

	public function new(song:String = "tutorial", week:Int = 0, songCharacter:String = "bf", isFreeplayChart:Bool = false) {
		this.songName = song;
		this.week = week;
		this.songCharacter = songCharacter;
		this.isFreeplayChart = isFreeplayChart;
	}
}

class FreeplayState extends MusicBeatState {
	var songs:Array<SongMetadatas> = [];

	var selector:FlxText;
	var curSelected:Int = 0;
	var curDifficulty:Int = 1;

	var scoreText:FlxText;
	var comboText:FlxText;
	var diffText:FlxText;
	var randomText:FlxText;
	var randomModeText:FlxText;
	var maniaText:FlxText;
	var flipModeText:FlxText;
	var bothSideText:FlxText;
	var randomManiaText:FlxText;
	var noteTypesText:FlxText;

	var keyAmmo:Array<Int> = [4, 6, 9, 5, 7, 8, 1, 2, 3];
	var randMania:Array<String> = ["Off", "Low Chance", "Medium Chance", "High Chance"];
	var randNoteTypes:Array<String> = ["Off", "Low Chance", "Medium Chance", "High Chance", 'Unfair'];

	var lerpScore:Int = 0;
	var intendedScore:Int = 0;
	var combo:String = '';

	private var grpSongs:FlxTypedGroup<Alphabet>;
	private var curPlaying:Bool = false;
	private var diffTextArrays:Array<Array<String>> = [];

	private var iconArray:Array<HealthIcon> = [];

	public static var id:Int = 1;
	public static var useAutoDiffSystem:Bool = true;
	private var ratingArray:Array<Dynamic> = [];
	private var customSongCheck:Array<Bool> = [];

	function loadSongFromPath(path:String, song:String, freeplayChart:Bool = false) //freeplay is baased off of file directory.
		{
			if (useAutoDiffSystem)
			{
				#if sys
				
				if (FileSystem.exists(path))
				{
					var diffs:Array<String> = [];
					var sortedDiffs:Array<String> = [];
					var diffTexts:Array<String> = []; //for display text
					var ratingList:Array<Dynamic> = []; 
					diffs = FileSystem.readDirectory(path);
	
					var easy:String = "";
					var normal:String = "";
					var hard:String = "";
					var extra:Array<String> = [];
					var extraCount = 0;
					
					for (file in diffs)
					{
						if (!file.contains(".hscript") && file.endsWith(".json")) //fuck you
						{
							if (!file.endsWith(".json")) //get rid of non json files
								diffs.remove(file);
							else if (file.endsWith("-easy.json")) //add easy first
							{
								easy = file;
							}
							else if (file.endsWith(song.toLowerCase() + ".json")) //add normal
							{
								normal = file;
							}
							else if (file.endsWith("-hard.json")) //add hard
							{
								hard = file;
							}
							else if (file.endsWith(".json"))
							{
								var text:String = StringTools.replace(file, song.toLowerCase() + "-", "");
								var fixedText:String = StringTools.replace(text,".json", "");
								extra.push(fixedText.toUpperCase());
								extraCount++;
							}
						}
	
	
					}
	
					if (easy != "") //me trying to figure out how to sort the diffs in correct order :(
					{
						ratingList.push([0,0]);
						diffTexts.push("EASY"); //it works pog
					}
					if (normal != "")
					{
						ratingList.push([0,0]);
						diffTexts.push("NORMAL");
					}
					if (hard != "")
					{
						ratingList.push([0,0]);
						diffTexts.push("HARD");
					}	
					if (extraCount != 0)
					{
						for (i in extra)
						{
							ratingList.push([0,0]);
							diffTexts.push(i);
						}
					}
	
							
	
					//diffArrays.push(sortedDiffs);
					diffTextArrays.push(diffTexts);
					ratingArray.push(ratingList);
					
				}
				#end
			}
			else 
			{
				var diffTexts = ["EASY", "NORMAL", "HARD"];
				diffTextArrays.push(diffTexts);
				var ratingList = [[0,0],[0,0],[0,0]];
				ratingArray.push(ratingList);
			}
		}

	override function create() {
		PlayState.isStoryMode = false; //so files load properly

		#if !sys
		useAutoDiffSystem = false;
		#end

		var parsed = CoolUtil.parseJson(File.getContent('assets/data/freeplaySongJson.jsonc'));
		trace(parsed[id].songs);
		trace(parsed[id].categoryIcons);
		var initSonglist:Dynamic = parsed[id].songs;
		var initSonglistIcons:Dynamic = parsed[id].icons;
		//	var ICONinitSonglist = CoolUtil.coolTextFile(Paths.txt('ICONfreeplaySonglist'));

		trace(initSonglist + ' | ' + initSonglistIcons + ' | ');

		for (i in 0...initSonglist.length) {
			songs.push(new SongMetadatas(initSonglist[i], 1, initSonglistIcons[i]));
			var path = "assets/data/charts/" + initSonglist[i];
			loadSongFromPath(path, initSonglist[i]);
		}

		#if sys
		var freeplayCharts = FileSystem.readDirectory('assets/data/freeplayCharts');
		if (freeplayCharts.length > 0)
		{
			for (chart in freeplayCharts)
			{
				if (!chart.contains('.txt'))
				{
					songs.push(new SongMetadatas(chart, 0, 'face', true));
					var path = "assets/data/freeplayCharts/" + chart;
					loadSongFromPath(path, chart, true);
				}
			}
		}

		#end

		/* 
			if (FlxG.sound.music != null)
			{
				if (!FlxG.sound.music.playing)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));
			}
		 */

		#if windows
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Freeplay Menu", null);
		#end

		var isDebug:Bool = false;

		#if debug
		isDebug = true;
		#end

		// LOAD MUSIC

		// LOAD CHARACTERS

		var bg:FlxSprite = new FlxSprite().loadGraphic(Paths.image('menuBGBlue'));
		add(bg);

		grpSongs = new FlxTypedGroup<Alphabet>();
		add(grpSongs);

		for (i in 0...songs.length) {
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, songs[i].songName, true, false, true);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpSongs.add(songText);

			var iconName:String = '';

			if (songs[i].songCharacter != null)
				iconName = songs[i].songCharacter;
			else 
				iconName = 'bf';

			var icon:HealthIcon = new HealthIcon(iconName);
			icon.sprTracker = songText;

			// using a FlxGroup is too much fuss!
			iconArray.push(icon);
			add(icon);

			// songText.x += 40;
			// DONT PUT X IN THE FIRST PARAMETER OF new ALPHABET() !!
			// songText.screenCenter(X);
		}

		scoreText = new FlxText(FlxG.width * 0.7, 5, 0, "", 32);
		// scoreText.autoSize = false;
		scoreText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT);
		// scoreText.alignment = RIGHT;

		var scoreBG:FlxSprite = new FlxSprite(scoreText.x - 6, 0).makeGraphic(Std.int(FlxG.width * 0.35), 66, 0xFF000000);
		scoreBG.alpha = 0.6;
		add(scoreBG);

		randomText = new FlxText(FlxG.width * 0.7, 489, 0, FlxG.save.data.randomNotes ? "Randomization On (R)" : "Randomization Off (R)", 20);
		randomText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, RIGHT);

		randomModeText = new FlxText(randomText.x, randomText.y + 32,
			FlxG.save.data.randomSection ? "Mode: Per Section (best for extra keys) (T)" : "Mode: Regular (T)", 16);
		randomModeText.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.WHITE, RIGHT);

		randomManiaText = new FlxText(randomText.x, randomText.y + 64, "Randomly change Amount of keys: " + randMania[FlxG.save.data.randomMania] + " (Y)",
			16);
		randomManiaText.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.WHITE, RIGHT);

		maniaText = new FlxText(randomText.x, randomText.y + 96, "Set ammount of keys: " + keyAmmo[FlxG.save.data.mania] + " (4 = default) (U)", 24);
		maniaText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);

		noteTypesText = new FlxText(randomText.x, randomText.y + 128, "Randomly Place Note Types: " + randNoteTypes[FlxG.save.data.randomNoteTypes] + "(I)",
			24);
		noteTypesText.setFormat(Paths.font("vcr.ttf"), 16, FlxColor.WHITE, RIGHT);

		flipModeText = new FlxText(randomText.x, randomText.y + 160, FlxG.save.data.flip ? "Play as Oppenent: On (O)" : "Play as Oppenent: Off (O)", 20);
		flipModeText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, RIGHT);

		bothSideText = new FlxText(randomText.x, randomText.y + 192,
			FlxG.save.data.bothSide ? "Both side: On (only 4k songs, turns into 8k) (P)" : "Both side: Off (P)", 16);
		bothSideText.setFormat(Paths.font("vcr.ttf"), 14, FlxColor.WHITE, RIGHT);

		//curDiff = new DifficultyIcons(CoolUtil.difficultyArray, 1, 0, -1000);

		var settingsBG:FlxSprite = new FlxSprite(randomText.x - 6, 484).makeGraphic(Std.int(FlxG.width * 0.35), 300, 0xFF000000);
		settingsBG.alpha = 0.6;
		add(settingsBG);
		diffText = new FlxText(scoreText.x, scoreText.y + 36, 0, "", 24);
		diffText.font = scoreText.font;
		add(diffText);

		comboText = new FlxText(diffText.x + 100, diffText.y, 0, "", 24);
		comboText.font = diffText.font;
		add(comboText);

		add(scoreText);
		add(randomText);
		add(randomModeText);
		add(maniaText);
		//add(curDiff);
		add(flipModeText);
		add(bothSideText);
		add(randomManiaText);
		add(noteTypesText);

		changeSelection();
		changeDiff();

		// FlxG.sound.playMusic(Paths.music('title'), 0);
		// FlxG.sound.music.fadeIn(2, 0, 0.8);
		selector = new FlxText();

		selector.size = 40;
		selector.text = ">";
		// add(selector);

		var swag:Alphabet = new Alphabet(1, 0, "swag");

		// JUST DOIN THIS SHIT FOR TESTING!!!
		/* 
			var md:String = Markdown.markdownToHtml(Assets.getText('CHANGELOG.md'));

			var texFel:TextField = new TextField();
			texFel.width = FlxG.width;
			texFel.height = FlxG.height;
			// texFel.
			texFel.htmlText = md;

			FlxG.stage.addChild(texFel);

			// scoreText.textField.htmlText = md;

			trace(md);
		 */

		super.create();
	}

	public function addSong(songName:String, weekNum:Int, songCharacter:String) {
		songs.push(new SongMetadatas(songName, weekNum, songCharacter));
	}

	public function addWeek(songs:Array<String>, weekNum:Int, ?songCharacters:Array<String>) {
		if (songCharacters == null)
			songCharacters = ['dad'];

		var num:Int = 0;
		for (song in songs) {
			addSong(song, weekNum, songCharacters[num]);

			if (songCharacters.length != 1)
				num++;
		}
	}

	private static var vocals:FlxSound = null;

	var instPlaying:Int = -1;

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (FlxG.sound.music.volume < 0.7) {
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		lerpScore = Math.floor(FlxMath.lerp(lerpScore, intendedScore, 0.4));

		if (Math.abs(lerpScore - intendedScore) <= 10)
			lerpScore = intendedScore;

		scoreText.text = "PERSONAL BEST:" + lerpScore;
		comboText.text = combo + '\n';

		var upP = FlxG.keys.justPressed.UP;
		var downP = FlxG.keys.justPressed.DOWN;
		var accepted = controls.ACCEPT;

		var gamepad:FlxGamepad = FlxG.gamepads.lastActive;

		if (gamepad != null) {
			if (gamepad.justPressed.DPAD_UP) {
				changeSelection(-1);
			}
			if (gamepad.justPressed.DPAD_DOWN) {
				changeSelection(1);
			}
			if (gamepad.justPressed.DPAD_LEFT) {
				changeDiff(-1);
			}
			if (gamepad.justPressed.DPAD_RIGHT) {
				changeDiff(1);
			}
		}

		if (upP) {
			changeSelection(-1);
		}
		if (downP) {
			changeSelection(1);
		}

		if (FlxG.keys.justPressed.R) {
			FlxG.save.data.randomNotes = !FlxG.save.data.randomNotes;
			randomText.text = FlxG.save.data.randomNotes ? "Randomization On (R)" : "Randomization Off (R)";
		}
		if (FlxG.keys.justPressed.T) {
			FlxG.save.data.randomSection = !FlxG.save.data.randomSection;
			randomModeText.text = FlxG.save.data.randomSection ? "Mode: Per Section (best for extra keys) (T)" : "Mode: Regular (T)";
		}

		if (FlxG.keys.justPressed.Y) {
			FlxG.save.data.randomMania += 1;
			if (FlxG.save.data.randomMania > 3)
				FlxG.save.data.randomMania = 0;
			randomManiaText.text = "Randomly change Amount of keys: " + randMania[FlxG.save.data.randomMania] + " (Y)";
		}

		if (FlxG.keys.justPressed.U) {
			FlxG.save.data.mania += 1;
			if (FlxG.save.data.mania > 8)
				FlxG.save.data.mania = 0;
			maniaText.text = "Set ammount of keys: " + keyAmmo[FlxG.save.data.mania] + " (4 = default) (U)";
		}
		if (FlxG.keys.justPressed.I) {
			FlxG.save.data.randomNoteTypes += 1;
			if (FlxG.save.data.randomNoteTypes > 4)
				FlxG.save.data.randomNoteTypes = 0;
			noteTypesText.text = "Randomly Place Note Types: " + randNoteTypes[FlxG.save.data.randomNoteTypes] + "(I)";
		}
		if (FlxG.keys.justPressed.O) {
			FlxG.save.data.flip = !FlxG.save.data.flip;
			flipModeText.text = FlxG.save.data.flip ? "Play as Oppenent: On (O)" : "Play as Oppenent: Off (O)";
		}
		if (FlxG.keys.justPressed.P) {
			FlxG.save.data.bothSide = !FlxG.save.data.bothSide;
			bothSideText.text = FlxG.save.data.bothSide ? "Both side: On (only 4k songs, turns into 8k) (P)" : "Both side: Off (P)";
		}

		if (FlxG.keys.justPressed.LEFT)
			changeDiff(-1);
		if (FlxG.keys.justPressed.RIGHT)
			changeDiff(1);

		if (controls.BACK) {
			FlxG.switchState(new MainMenuState());
		}

		if (accepted) { 
			if (!FlxG.keys.pressed.SHIFT) {
				// adjusting the song name to be compatible
				var semiDiff = StringTools.replace(diffText.text, "<", "");
				var gettinThereDiff = StringTools.replace(semiDiff, ">", "");
				//now on normal charts, it would add "-normal", so we gotta fix that
				var nonNormalDiff = StringTools.replace(gettinThereDiff, "-normal", "");
				var actualDiff = StringTools.replace(nonNormalDiff, " ", "");
				actualDiff += ".json";

				var songFormat = StringTools.replace(songs[curSelected].songName, " ", "-");
				switch (songFormat) {
					case 'Dad-Battle':
						songFormat = 'Dadbattle';
					case 'Philly-Nice':
						songFormat = 'Philly';
				}

				trace('assets/data/charts/' + songFormat.toLowerCase() + '/' + songFormat.toLowerCase() + '-' + actualDiff.toLowerCase());

				var jsonExists = FileSystem.exists('assets/data/charts/' + songFormat.toLowerCase() + '/' + songFormat.toLowerCase() + '-' + actualDiff.toLowerCase());

				if (jsonExists) {

				trace(songs[curSelected].songName);

				var poop:String = Highscore.formatSong(songFormat, curDifficulty);

				trace(poop);

				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;
				PlayState.storyWeek = songs[curSelected].week;
				trace('CUR WEEK' + PlayState.storyWeek);
				CoolUtil.CurSongDiffs = diffTextArrays[curSelected];
				trace('SONG DIFFICULTIES: ' + CoolUtil.CurSongDiffs);
				LoadingState.loadAndSwitchState(new PlayState());
				}
				var jsonExists = FileSystem.exists('assets/data/freeplayCharts/' + songFormat.toLowerCase() + '/' + songFormat.toLowerCase() + '-' + actualDiff.toLowerCase());
				if (jsonExists) 
				{

					trace(songs[curSelected].songName);
					var poop:String = Highscore.formatSong(songFormat, curDifficulty);
					trace(poop);
	
					PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName);
					PlayState.isStoryMode = false;
					PlayState.storyDifficulty = curDifficulty;
					PlayState.storyWeek = songs[curSelected].week;
					trace('CUR WEEK' + PlayState.storyWeek);
					CoolUtil.CurSongDiffs = diffTextArrays[curSelected];
					trace('SONG DIFFICULTIES: ' + CoolUtil.CurSongDiffs);
					LoadingState.loadAndSwitchState(new PlayState());
					}
			} else {
				var semiDiff = StringTools.replace(diffText.text, "<", "");
				var gettinThereDiff = StringTools.replace(semiDiff, ">", "");
				//now on normal charts, it would add "-normal", so we gotta fix that
				var nonNormalDiff = StringTools.replace(gettinThereDiff, "-normal", "");
				var actualDiff = StringTools.replace(nonNormalDiff, " ", "");
				actualDiff += ".json";

				// adjusting the song name to be compatible
				var songFormat = StringTools.replace(songs[curSelected].songName, " ", "-");
				switch (songFormat) {
					case 'Dad-Battle':
						songFormat = 'Dadbattle';
					case 'Philly-Nice':
						songFormat = 'Philly';
				}

				var jsonExists = FileSystem.exists('assets/data/charts/' + songFormat.toLowerCase() + '/' + songFormat.toLowerCase() + '-' + actualDiff.toLowerCase());

				if (jsonExists) 
				{

				trace(songs[curSelected].songName);
				var poop:String = Highscore.formatSong(songFormat, curDifficulty);
				trace(poop);

				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;
				PlayState.storyWeek = songs[curSelected].week;
				CoolUtil.CurSongDiffs = diffTextArrays[curSelected];
				trace('SONG DIFFICULTIES: ' + CoolUtil.CurSongDiffs);
				LoadingState.loadAndSwitchState(new ChartingState());
				Main.editor = true;
				}

				var jsonExists = FileSystem.exists('assets/data/freeplayCharts/' + songFormat.toLowerCase() + '/' + songFormat.toLowerCase() + '-' + actualDiff.toLowerCase());

				if (jsonExists) {
				trace(songs[curSelected].songName);

				var poop:String = Highscore.formatSong(songFormat, curDifficulty);
				trace(poop);

				PlayState.SONG = Song.loadFromJson(poop, songs[curSelected].songName);
				PlayState.isStoryMode = false;
				PlayState.storyDifficulty = curDifficulty;
				PlayState.storyWeek = songs[curSelected].week;
				CoolUtil.CurSongDiffs = diffTextArrays[curSelected];
				trace('SONG DIFFICULTIES: ' + CoolUtil.CurSongDiffs);
				LoadingState.loadAndSwitchState(new ChartingState());
				Main.editor = true;
				}
			}
		}
	}

	function changeDiff(change:Int = 0) {
	/*	var diffJson = CoolUtil.parseJson(File.getContent("assets/images/custom_difficulties/difficulties.json"));
		var maxDiff:Int = 0;
		var length = diffJson.difficulties.length - 1;
		for (i in 0...length)
		{
			maxDiff += 1;
		}
		trace(maxDiff);*/

		curDifficulty += change;

		if (curDifficulty < 0)
			curDifficulty = diffTextArrays[curSelected].length - 1;
		if (curDifficulty > diffTextArrays[curSelected].length - 1)
			curDifficulty = 0;

	//	var _diff = DifficultyIcons.changeDifficultyFreeplay(curDifficulty, change);

	//	trace(_diff.difficulty);

		// adjusting the highscore song name to be compatible (changeDiff)
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore) {
			case 'Dad-Battle':
				songHighscore = 'Dadbattle';
			case 'Philly-Nice':
				songHighscore = 'Philly';
		}

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		#end

		diffText.text = '< ' + diffTextArrays[curSelected][curDifficulty] + ' >';
		/*if (ratingArray[curSelected][curDifficulty] != null)
		{
			ratingsText.text = "P1 Rating: " + ratingArray[curSelected][curDifficulty][0];
			p2ratingsText.text = "P2 Rating: " + ratingArray[curSelected][curDifficulty][1];
		}	*/
	}

	function changeSelection(change:Int = 0) {
		#if !switch
		// NGio.logEvent('Fresh');
		#end

		// NGio.logEvent('Fresh');
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = songs.length - 1;
		if (curSelected >= songs.length)
			curSelected = 0;

		// selector.y = (70 * curSelected) + 30;

		// adjusting the highscore song name to be compatible (changeSelection)
		// would read original scores if we didn't change packages
		var songHighscore = StringTools.replace(songs[curSelected].songName, " ", "-");
		switch (songHighscore) {
			case 'Dad-Battle':
				songHighscore = 'Dadbattle';
			case 'Philly-Nice':
				songHighscore = 'Philly';
		}

		#if !switch
		intendedScore = Highscore.getScore(songHighscore, curDifficulty);
		combo = Highscore.getCombo(songHighscore, curDifficulty);
		// lerpScore = 0;
		#end

		#if PRELOAD_ALL
		FlxG.sound.playMusic(Sound.fromFile(Paths.inst(songs[curSelected].songName.toLowerCase(), '')), 1, false);
		#end

		var bullShit:Int = 0;

		for (i in 0...iconArray.length) {
			iconArray[i].alpha = 0.6;
			iconArray[i].animation.curAnim.curFrame = 0; //shout out to BetaBits. he figured this idea to put the thing here and it worked!
		}

		iconArray[curSelected].alpha = 1;

		for (item in grpSongs.members) {
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0) {
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}
}
