package;

#if desktop
import Discord.DiscordClient;
#end
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import flixel.tweens.FlxTween;
import lime.utils.Assets;
import flash.display.BitmapData;

#if sys
import sys.io.File;
import haxe.io.Path;
import openfl.utils.ByteArray;
import sys.FileSystem;
#end

import haxe.Json;
import tjson.TJSON;
import haxe.format.JsonParser;

using StringTools;

class CreditsState extends MusicBeatState
{
	var curSelected:Int = 1;

	private var grpOptions:FlxTypedGroup<Dynamic>;
	private var iconArray:Array<AttachedSprite> = [];

	private static var creditsStuffFallBack:Array<Dynamic> = [ //Name - Icon name - Description - Link - BG Color
		//https://discord.gg/7mHaNysx7c
		['Developers of Better Fusion'],
		['Discussions', 		'discussions', 		'Main Programmer of Better Fusion Engine', 			'https://gamebanana.com/members/1900848', 			 0xFF57E88A],
		['Teu', 				'teuxml', 			'Main Artist/Animator of Better Fusion Engine', 	'https://www.youtube.com/channel/UC-Mqu9H63TRNYEzqIt-XUUQ',			 0xFF2ECA5f],
		['TheZoroForce', 		'thezoroforce', 	'Note Splash Animations and EK Code',				'https://www.youtube.com/user/TheZoroForce240',		 0xFFFF8800],
		['kidsfreeJ', 			'kidsfreej', 		'Original Developer for Fusion', 					'https://github.com/kidsfreej',						 0xFFE8F115],
		['Special Thanks'],
		['BetaBits', 			'placeholder', 		'Fixed a Bug with Icons in Freeplay', 				'https://gamebanana.com/members/1792702',			 0xFF54E75F],
		['Epic Gamer', 			'epicgamer',		'Fixed a Bug where Freeplay would Crash upon Load',	'https://epicgamer2469.github.io/',					 0xFF0de6fe],
		['srPerez', 			'perez', 			'The Idea of More Keys',							'https://twitter.com/NewSrPerez',					 0xFFFF9E00],
		['kadeDev', 			'kade', 			'Mastermind of Kade',								'https://twitter.com/NewSrPerez',					 0xFF2ECA5f],
		['Psych Engine Team'],
		['Shadow Mario',		'shadowmario',		'Main Programmer of Psych Engine',					'https://twitter.com/Shadow_Mario_',				 0xFFFFDD33],
		['RiverOaken',			'riveroaken',		'Main Artist/Animator of Psych Engine',				'https://twitter.com/river_oaken',					 0xFFC30085],
		['Keoiki',				'keoiki',			'Note Splash Animations',							'https://twitter.com/Keoiki_',						 0xFFFFFFFF],
		['PolybiusProxy',		'polybiusproxy',	'.MP4 Video Loader Extension',						'https://twitter.com/polybiusproxy',				 0xFFE01F32],
		[''],
		["Funkin' Crew"],
		['ninjamuffin99',		'ninjamuffin99',	"Programmer of Friday Night Funkin'",				'https://twitter.com/ninja_muffin99',				 0xFFF73838],
		['PhantomArcade',		'phantomarcade',	"Animator of Friday Night Funkin'",					'https://twitter.com/PhantomArcade3K',				 0xFFFFBB1B],
		['evilsk8r',			'evilsk8r',			"Artist of Friday Night Funkin'",					'https://twitter.com/evilsk8r',						 0xFF53E52C],
		['kawaisprite',			'kawaisprite',		"Composer of Friday Night Funkin'",					'https://twitter.com/kawaisprite',					 0xFF6475F3]
	];

	private static var creditsStuff:Array<Dynamic> = [ //Name - Icon name - Description - Link - BG Color
		
	];

	var bg:FlxSprite;
	var descText:FlxText;
	var intendedColor:Int;
	var colorTween:FlxTween;

	override function create()
	{
		#if desktop
		// Updating Discord Rich Presence
		DiscordClient.changePresence("In the Menus", null);
		#end

		bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
		add(bg);

		grpOptions = new FlxTypedGroup<ShaggyAlphabet>();
		add(grpOptions);

		var parsed = CoolUtil.parseJson(File.getContent('assets/images/betterfusion_customize/custom_credits/credits.jsonc'));
		trace(parsed[0].credits);
		creditsStuff = parsed[0].credits;

		for (i in 0...creditsStuff.length)
		{
			var isSelectable:Bool = !unselectableCheck(i);
			var optionText:ShaggyAlphabet = new ShaggyAlphabet(0, 70 * i, creditsStuff[i][0], !isSelectable, false);
			optionText.isMenuItem = true;
			optionText.screenCenter(X);
			if(isSelectable) {
				optionText.x -= 70;
			}
			optionText.forceX = optionText.x;
			//optionText.yMult = 90;
			optionText.targetY = i;
			grpOptions.add(optionText);

			if(isSelectable) {
				trace(creditsStuff[i][1]);
				var icon:AttachedSprite = new AttachedSprite('credits/' + creditsStuff[i][1]);
				icon.xAdd = optionText.width + 10;
				icon.sprTracker = optionText;
	
				// using a FlxGroup is too much fuss!
				if (creditsStuff[i][1] == 'kidsfreej')
					icon.scale.set(1.5, 1.5);
				iconArray.push(icon);
				add(icon);
			}
		}

		descText = new FlxText(50, 600, 1180, "", 32);
		descText.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		descText.scrollFactor.set();
		descText.borderSize = 2.4;
		add(descText);

		bg.color = creditsStuff[curSelected][4];
		intendedColor = bg.color;
		changeSelection();
		super.create();
	}

	override function update(elapsed:Float)
	{
		if (FlxG.sound.music.volume < 0.7)
		{
			FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
		}

		var upP = controls.UP_P;
		var downP = controls.DOWN_P;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (controls.BACK)
		{
			if(colorTween != null) {
				colorTween.cancel();
			}
			FlxG.sound.play(Paths.sound('cancelMenu'));
			FlxG.switchState(new MainMenuState());
		}
		if(controls.ACCEPT) {
			//fancyOpenURL(creditsStuff[curSelected][3]);

			#if linux
			Sys.command('/usr/bin/xdg-open', [creditsStuff[curSelected][3], "&"]);
			#else
			FlxG.openURL(creditsStuff[curSelected][3]);
			#end
		}
		super.update(elapsed);
	}

	function changeSelection(change:Int = 0)
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
		do {
			curSelected += change;
			if (curSelected < 0)
				curSelected = creditsStuff.length - 1;
			if (curSelected >= creditsStuff.length)
				curSelected = 0;
		} while(unselectableCheck(curSelected));

		var newColor:Int = Std.int(creditsStuff[curSelected][4]);
		if(newColor != intendedColor) {
			if(colorTween != null) {
				colorTween.cancel();
			}
			intendedColor = newColor;
			colorTween = FlxTween.color(bg, 1, bg.color, intendedColor, {
				onComplete: function(twn:FlxTween) {
					colorTween = null;
				}
			});
		}

		var bullShit:Int = 0;

		for (item in grpOptions.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			if(!unselectableCheck(bullShit-1)) {
				item.alpha = 0.6;
				if (item.targetY == 0) {
					item.alpha = 1;
				}
			}
		}
		descText.text = creditsStuff[curSelected][2];
	}

	private function unselectableCheck(num:Int):Bool {
		return creditsStuff[num].length <= 1;
	}
}
