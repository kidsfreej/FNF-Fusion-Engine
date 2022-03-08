package;

import Section.SwagSection;
import haxe.Json;
import DownloadingState.DownloadableObj;
import haxe.format.JsonParser;
import lime.utils.Assets;
import tjson.TJSON;
#if sys
import sys.io.File;
import sys.FileSystem;
import lime.system.System;
import haxe.io.Path;
#end

using StringTools;

typedef SwagSong =
{
	var song:String;
	var notes:Array<SwagSection>;
	var bpm:Float;
	var needsVoices:Bool;
	var speed:Float;
	var mania:Int;
	//var noteValues:Array<Float>;

	var player1:String;
	var player2:String;
	var gfVersion:String;
	var noteStyle:String;
	var stage:String;
	var validScore:Bool;

	var instSuffix:String;
	var vocalsSuffix:String;
	var displayName:String;

	var audioFromUrl:Null<Bool>;
	var instUrl:String;
	var vocalsUrl:String;

	var downloadingStuff:Array<DownloadableObj>;

	var isMoody:Null<Bool>;
	var cutsceneType:String;
	var uiType:String;
	var isSpooky:Null<Bool>;
	var isHey:Null<Bool>;
	var isPixelStage:Null<Bool>;
}

class Song
{
	public var song:String;
	public var notes:Array<SwagSection>;
	public var bpm:Float;
	public var needsVoices:Bool = true;
	public var speed:Float = 1;
	public var mania:Int = 0;

	public var player1:String = 'bf';
	public var player2:String = 'dad';
	public var gfVersion:String = '';
	public var noteStyle:String = '';
	public var stage:String = '';

	public var instSuffix:String = '';
	public var vocalsSuffix:String = '';
	public var displayName:String = '';

	public var audioFromUrl:Null<Bool> = false;
	public var instUrl:String = '';
	public var vocalsUrl:String = '';

	public var downloadingStuff:Array<DownloadableObj> = [];
	public var isMoody:Null<Bool> = false;
	public var isSpooky:Null<Bool> = false;
	public var cutsceneType:String = "none";
	public var uiType:String = 'normal';
	public var isHey:Null<Bool> = false;

	public var isPixelStage:Bool = false;

	public function new(song, notes, bpm)
	{
		this.song = song;
		this.notes = notes;
		this.bpm = bpm;
	}

	public static function loadFromJson(jsonInput:String, ?folder:String, freeplay:Bool = false):SwagSong
	{
		/*trace(jsonInput);

		// pre lowercasing the folder name
		var folderLowercase = StringTools.replace(folder, " ", "-").toLowerCase();
		switch (folderLowercase) {
			case 'dad-battle': folderLowercase = 'dadbattle';
			case 'philly-nice': folderLowercase = 'philly';
		}
		
		trace('loading ' + folderLowercase + '/' + jsonInput.toLowerCase());

		var rawJson = Assets.getText(Paths.json(folderLowercase + '/' + jsonInput.toLowerCase())).trim();

		while (!rawJson.endsWith("}"))
		{
			rawJson = rawJson.substr(0, rawJson.length - 1);
			// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
		}

		return parseJSONshit(rawJson);*//*
		var rawJson:String = "";
			if (jsonInput != folder)
			{
				// means this isn't normal difficulty
				// raw json 
				// folder is always just the song name
				rawJson = File.getContent("assets/data/"+folder.toLowerCase()+"/"+folder.toLowerCase()+".json").trim();
			} else {
				#if sys
				rawJson = File.getContent("assets/data/" + folder.toLowerCase() + "/" + jsonInput.toLowerCase() + '.json').trim();
				#else
				rawJson = Assets.getText('assets/data/' + folder.toLowerCase() + '/' + jsonInput.toLowerCase() + '.json').trim();
				#end
			}
			while (!rawJson.endsWith("}"))
			{
				rawJson = rawJson.substr(0, rawJson.length - 1);
				// LOL GOING THROUGH THE BULLSHIT TO CLEAN IDK WHATS STRANGE
			}*/

		#if sys
		var rawJson = File.getContent(Paths.json(folder.toLowerCase() + '/' + jsonInput.toLowerCase(), freeplay)).trim();
		#else
		var rawJson = Assets.getText(Paths.json(folder.toLowerCase() + '/' + jsonInput.toLowerCase(), false)).trim();
		#end

			var parsedJson = parseJSONshit(rawJson);
			if (parsedJson.stage == null) {
				if (parsedJson.song.toLowerCase() == 'spookeez'|| parsedJson.song.toLowerCase() == 'monster' || parsedJson.song.toLowerCase() == 'south') {
					parsedJson.stage = 'spooky';
				} else if (parsedJson.song.toLowerCase() == 'pico' || parsedJson.song.toLowerCase() == 'philly' || parsedJson.song.toLowerCase() == 'blammed') {
					parsedJson.stage = 'philly';
				} else if (parsedJson.song.toLowerCase() == 'milf' || parsedJson.song.toLowerCase() == 'high' || parsedJson.song.toLowerCase() == 'satin-panties') {
					parsedJson.stage = 'limo';
				} else if (parsedJson.song.toLowerCase() == 'cocoa' || parsedJson.song.toLowerCase() == 'eggnog') {
					parsedJson.stage = 'mall';
				} else if (parsedJson.song.toLowerCase() == 'winter-horrorland') {
					parsedJson.stage = 'mallEvil';
				} else if (parsedJson.song.toLowerCase() == 'senpai' || parsedJson.song.toLowerCase() == 'roses'){
					parsedJson.stage = 'school';
				} else if (parsedJson.song.toLowerCase() == 'thorns'){
					parsedJson.stage = 'schoolEvil';
				} else {
					parsedJson.stage = 'stage';
				}
			}

			if (parsedJson.isPixelStage == null) {
				var pixelornot:Bool;
				switch (parsedJson.song.toLowerCase())
				{
					case 'senpai' | 'roses' | 'thorns':
						pixelornot = true;
					default: 
						pixelornot = false;
				}

				PlayState.isPixelStage = pixelornot;
			}
			else {
				PlayState.isPixelStage = parsedJson.isPixelStage;
			}

			if (parsedJson.isHey == null) {
				parsedJson.isHey = false;
				if (parsedJson.song.toLowerCase() == 'bopeebo')
					parsedJson.isHey = true;
			}
			if (parsedJson.gfVersion == null) {
				// are you kidding me did i really do song to lowercase
				switch (parsedJson.stage) {
					case 'limo':
						parsedJson.gfVersion = 'gf-car';
					case 'mall':
						parsedJson.gfVersion = 'gf-christmas';
					case 'mallEvil':
						parsedJson.gfVersion = 'gf-christmas';
					case 'school':
						parsedJson.gfVersion = 'gf-pixel';
					case 'schoolEvil':
						parsedJson.gfVersion = 'gf-pixel';
					default:
						parsedJson.gfVersion = 'gf';
				}
	
			}
			if (parsedJson.isMoody == null) {
				if (parsedJson.song.toLowerCase() == 'roses') {
					parsedJson.isMoody = true;
				} else {
					parsedJson.isMoody = false;
				}
			}
			// is spooky means trails on spirit
			if (parsedJson.isSpooky == null) {
				if (parsedJson.stage.toLowerCase() == 'mallEvil') {
					parsedJson.isSpooky = true;
				} else {
					parsedJson.isSpooky = false;
				}
			}
			if (parsedJson.song.toLowerCase() == 'winter-horrorland') {
				parsedJson.cutsceneType = "monster";
			}
			if (parsedJson.cutsceneType == null) {
				switch (parsedJson.song.toLowerCase()) {
					case 'roses':
						parsedJson.cutsceneType = "angry-senpai";
					case 'senpai':
						parsedJson.cutsceneType = "senpai";
					case 'thorns':
						parsedJson.cutsceneType = 'spirit';
					case 'winter-horrorland':
						parsedJson.cutsceneType = 'monster';
					default:
						parsedJson.cutsceneType = 'none';
				}
			}
			if (parsedJson.uiType == null) {
				if (parsedJson.song.toLowerCase() == 'roses' || parsedJson.song.toLowerCase() == 'senpai' || parsedJson.song.toLowerCase() == 'thorns') {
					parsedJson.uiType = 'pixel';
				} else {
					parsedJson.uiType = 'normal';
				}
			}

			if (parsedJson.audioFromUrl == null) {
					parsedJson.audioFromUrl = false;
			}

			if (parsedJson.instUrl == null) {
					parsedJson.instUrl = '';
			}

			if (parsedJson.vocalsUrl == null) {
					parsedJson.vocalsUrl = '';

			}

			// FIX THE CASTING ON WINDOWS/NATIVE
			// Windows???
			// trace(songData);
	
			// trace('LOADED FROM JSON: ' + songData.notes);
			/*
				for (i in 0...songData.notes.length)
				{
					trace('LOADED FROM JSON: ' + songData.notes[i].sectionNotes);
					// songData.notes[i].sectionNotes = songData.notes[i].sectionNotes
				}
	
					daNotes = songData.notes;
					daSong = songData.song;
					daSections = songData.sections;
					daBpm = songData.bpm;
					daSectionLengths = songData.sectionLengths; */
			if (jsonInput != folder)
			{
				// means this isn't normal difficulty
				// lets finally overwrite notes
				var realJson = parseJSONshit(File.getContent("assets/data/" + (freeplay ? "freeplayCharts/" : "charts/") + folder.toLowerCase() + "/" + jsonInput.toLowerCase() + '.json').trim());
				parsedJson.notes = realJson.notes;
				parsedJson.bpm = realJson.bpm;
				parsedJson.needsVoices = realJson.needsVoices;
				parsedJson.speed = realJson.speed;
			}
			return parsedJson;
	}

	public static function parseJSONshit(rawJson:String):SwagSong
	{
		//var swagShit:SwagSong = cast Json.parse(rawJson).song;
	//	swagShit.validScore = true;
	//	return swagShit;
		var swagShit:SwagSong = cast CoolUtil.parseJson(rawJson).song;
		return swagShit;
	}
}
