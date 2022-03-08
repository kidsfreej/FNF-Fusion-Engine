package;

import Conductor.BPMChangeEvent;
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.ui.FlxInputText;
import flixel.addons.ui.FlxUI9SliceSprite;
import flixel.addons.ui.FlxUI;
import flixel.addons.ui.FlxUICheckBox;
import flixel.addons.ui.FlxUIDropDownMenu;
import flixel.addons.ui.FlxUIInputText;
import flixel.addons.ui.FlxUINumericStepper;
import flixel.addons.ui.FlxUITabMenu;
import flixel.addons.ui.FlxUITooltip.FlxUITooltipStyle;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.group.FlxGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.ui.FlxButton;
import flixel.ui.FlxSpriteButton;
import flixel.util.FlxColor;
import haxe.Json;
import lime.utils.Assets;
import openfl.events.Event;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.events.IOErrorEvent;
import openfl.media.Sound;
import openfl.net.FileReference;
import openfl.utils.ByteArray;

import lime.system.System;
#if sys
import sys.io.File;
import haxe.io.Path;
import tjson.TJSON;
import openfl.utils.ByteArray;
import lime.media.AudioBuffer;
import flash.media.Sound;
#end

using StringTools;

class ChartingState extends MusicBeatState
{
	var _file:FileReference;
	public var playClaps:Bool = false;
	public static var isCharting:Bool = false;

	var UI_box:FlxUITabMenu;

	/**
	 * Array of notes showing when each section STARTS in STEPS
	 * Usually rounded up??
	 */
	var curSection:Int = 0;

	public static var lastSection:Int = 0;

	var bpmTxt:FlxText;

	var strumLine:FlxSprite;
	var curSong:String = 'Dad battle';
	var amountSteps:Int = 0;
	var bullshitUI:FlxGroup;

	var highlight:FlxSprite;

	var GRID_SIZE:Int = 40;
	var S_GRID_SIZE:Int = 40;

	var dummyArrow:FlxSprite;

	var curRenderedNotes:FlxTypedGroup<Note>;
	var curRenderedSustains:FlxTypedGroup<FlxSprite>;
	var curRenderedTypes:FlxTypedGroup<FlxSprite>;

	var gridBG:FlxSprite;
	var gridBGAbove:FlxSprite;
	var gridBGBelow:FlxSprite;
	var gridBlackLine:FlxSprite;

	//var colorOverlay:FlxSprite;

	var _song:SwagSong;

	var typingShit:FlxInputText;
	/*
	 * WILL BE THE CURRENT / LAST PLACED NOTE
	**/
	var curSelectedNote:Array<Dynamic>;

	//var isGrabbingNote:Bool = false;
	//var grabStartPos:Float;

	var tempBpm:Float = 0;

	var vocals:FlxSound;
	var player2:Character = new Character(0,0, "dad");
	var player1:Boyfriend = new Boyfriend(0,0, "bf");
	var leftIcon:HealthIcon;
	var rightIcon:HealthIcon;
	var keyAmmo:Array<Int> = [4, 6, 9, 5, 7, 8, 1, 2, 3];
	private var lastNote:Note;
	var claps:Array<Note> = [];

	var selectedType:Int = 0;
//	var typingShit:FlxInputText;
	var player1TextField:FlxInputText;
	var player2TextField:FlxInputText;
	var gfTextField:FlxInputText;
	var cutsceneTextField:FlxInputText;
	var uiTextField:FlxInputText;
	var stageTextField:FlxInputText;

	override function create()
	{
		curSection = lastSection;

		gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		add(gridBG);
		gridBGAbove = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		add(gridBGAbove);
		gridBGAbove.y -= gridBG.height;
		gridBGBelow = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
		add(gridBGBelow);
		gridBGBelow.y += gridBG.height;


		leftIcon = new HealthIcon('bf');
		rightIcon = new HealthIcon('dad');
		leftIcon.scrollFactor.set(1, 1);
		rightIcon.scrollFactor.set(1, 1);

		leftIcon.setGraphicSize(0, 45);
		rightIcon.setGraphicSize(0, 45);

		add(leftIcon);
		add(rightIcon);

		leftIcon.setPosition(0, -100);
		rightIcon.setPosition(gridBG.width / 2, -100);

		gridBlackLine = new FlxSprite(gridBG.x + gridBG.width / 2).makeGraphic(2, Std.int(gridBG.height), FlxColor.BLACK);
		add(gridBlackLine);

		curRenderedNotes = new FlxTypedGroup<Note>();
		curRenderedSustains = new FlxTypedGroup<FlxSprite>();
		curRenderedTypes = new FlxTypedGroup<FlxSprite>();

		if (PlayState.SONG != null)
			_song = PlayState.SONG;
		else
		{
			_song = {
				song: 'Test',
				notes: [],
				bpm: 150,
				needsVoices: true,
				player1: 'bf',
				player2: 'dad',
				noteStyle: 'normal',
				stage: 'stage',
				speed: 1,
				mania: 0,
				validScore: false,
				gfVersion: 'gf',
				isHey: false,
				isSpooky: false,
				isMoody: false,
				cutsceneType: "none",
				uiType: 'normal',
				isPixelStage: false,
				instSuffix: '',
				vocalsSuffix: '',
				displayName: '',
				audioFromUrl: false,
				instUrl: '',
				vocalsUrl: '',
				downloadingStuff: []
			};
		}

		FlxG.mouse.visible = true;
		FlxG.save.bind('funkin', 'ninjamuffin99');

		tempBpm = _song.bpm;

		addSection();

		// sections = _song.notes;

		updateGrid();

		loadSong(_song.song);
		Conductor.changeBPM(_song.bpm);
		Conductor.mapBPMChanges(_song);

		bpmTxt = new FlxText(1000, 0, 0, "", 16);
		bpmTxt.scrollFactor.set();
		add(bpmTxt);

		strumLine = new FlxSprite(0, 50).makeGraphic(Std.int(FlxG.width / 1), 4);
		add(strumLine);

		dummyArrow = new FlxSprite().makeGraphic(GRID_SIZE, GRID_SIZE);
		add(dummyArrow);

		var tabs = [ 
			{name: "Song", label: 'Song'},
			{name: "Section", label: 'Section'},
			{name: "Note", label: 'Note'},
		//	{name: "Assets", label: 'Assets'},
			{name: "Char", label: 'Char'}
		];

		UI_box = new FlxUITabMenu(null, tabs, true);

		UI_box.resize(300, 400);
		UI_box.x = FlxG.width / 2 + 40;
		UI_box.y = 20;
		add(UI_box);

		addSongUI();
		addSectionUI();
		addNoteUI();
		addCharsUI();

		add(curRenderedNotes);
		add(curRenderedSustains);
		add(curRenderedTypes);

		super.create();
	}

	function addSongUI():Void
	{
		var UI_songTitle = new FlxUIInputText(10, 10, 70, _song.song, 8);
		typingShit = UI_songTitle;

		var check_voices = new FlxUICheckBox(10, 25, null, null, "Has voice track", 100);
		check_voices.checked = _song.needsVoices;
		// _song.needsVoices = check_voices.checked;
		check_voices.callback = function()
		{
			_song.needsVoices = check_voices.checked;
			trace('CHECKED!');
		};

		

		var check_mute_inst = new FlxUICheckBox(10, 200, null, null, "Mute Instrumental (in editor)", 100);
		check_mute_inst.checked = false;
		check_mute_inst.callback = function()
		{
			var vol:Float = 1;

			if (check_mute_inst.checked)
				vol = 0;

			FlxG.sound.music.volume = vol;
		};

		var saveButton:FlxButton = new FlxButton(110, 8, "Save", function()
		{
			saveLevel();
		});

		var reloadSong:FlxButton = new FlxButton(saveButton.x + saveButton.width + 10, saveButton.y, "Reload Audio", function()
		{
			loadSong(_song.song);
		});

		var reloadSongJson:FlxButton = new FlxButton(reloadSong.x, saveButton.y + 30, "Reload JSON", function()
		{
			loadJson(_song.song.toLowerCase());
		});

		var isSpookyCheck = new FlxUICheckBox(10, 280,null,null,"Is Spooky", 100);

		var restart = new FlxButton(10,130,"Reset Chart", function()
            {
                for (ii in 0..._song.notes.length)
                {
                    for (i in 0..._song.notes[ii].sectionNotes.length)
                        {
                            _song.notes[ii].sectionNotes = [];
                        }
                }
                resetSection(true);
            });
		var loadAutosaveBtn:FlxButton = new FlxButton(reloadSongJson.x, reloadSongJson.y + 30, 'load autosave', loadAutosave);
		var isPixelCheck = new FlxUICheckBox(loadAutosaveBtn.x, loadAutosaveBtn.y+ 30,null,null,"Is Pixel Stage", 100);


		var stepperBPM:FlxUINumericStepper = new FlxUINumericStepper(10, 65, 0.1, 1, 1.0, 5000.0, 1);
		stepperBPM.value = Conductor.bpm;
		stepperBPM.name = 'song_bpm';

		var stepperBPMLabel = new FlxText(74,65,'BPM');
		
		var stepperSpeed:FlxUINumericStepper = new FlxUINumericStepper(10, 80, 0.1, 1, 0.1, 10, 1);
		stepperSpeed.value = _song.speed;
		stepperSpeed.name = 'song_speed';

		var stepperSpeedLabel = new FlxText(74,80,'Scroll Speed');
		
		var stepperVocalVol:FlxUINumericStepper = new FlxUINumericStepper(10, 95, 0.1, 1, 0.1, 10, 1);
		stepperVocalVol.value = vocals.volume;
		stepperVocalVol.name = 'song_vocalvol';

		var stepperVocalVolLabel = new FlxText(74, 95, 'Vocal Volume');
		
		var stepperSongVol:FlxUINumericStepper = new FlxUINumericStepper(10, 110, 0.1, 1, 0.1, 10, 1);
		stepperSongVol.value = FlxG.sound.music.volume;
		stepperSongVol.name = 'song_instvol';


		var hitsounds = new FlxUICheckBox(10, stepperSongVol.y + 60, null, null, "Play hitsounds", 100);
		hitsounds.checked = false;
		hitsounds.callback = function()
		{
			playClaps = hitsounds.checked;
		};

		var stepperSongVolLabel = new FlxText(74, 110, 'Instrumental Volume');

		
		var shiftNoteDialLabel = new FlxText(10, 245, 'Shift Note FWD by (Section)');
		var stepperShiftNoteDial:FlxUINumericStepper = new FlxUINumericStepper(10, 260, 1, 0, -1000, 1000, 0);
		stepperShiftNoteDial.name = 'song_shiftnote';
		var shiftNoteDialLabel2 = new FlxText(10, 275, 'Shift Note FWD by (Step)');
		var stepperShiftNoteDialstep:FlxUINumericStepper = new FlxUINumericStepper(10, 290, 1, 0, -1000, 1000, 0);
		stepperShiftNoteDialstep.name = 'song_shiftnotems';
		var shiftNoteDialLabel3 = new FlxText(10, 305, 'Shift Note FWD by (ms)');
		var stepperShiftNoteDialms:FlxUINumericStepper = new FlxUINumericStepper(10, 320, 1, 0, -1000, 1000, 2);
		stepperShiftNoteDialms.name = 'song_shiftnotems';

		var shiftNoteButton:FlxButton = new FlxButton(10, 335, "Shift", function()
		{
			shiftNotes(Std.int(stepperShiftNoteDial.value),Std.int(stepperShiftNoteDialstep.value),Std.int(stepperShiftNoteDialms.value));
		});

		var characters:Array<String> = CoolUtil.coolTextFile(Paths.txt('characterList'));
		var gfVersions:Array<String> = CoolUtil.coolTextFile(Paths.txt('gfVersionList'));
		var stages:Array<String> = CoolUtil.coolTextFile(Paths.txt('stageList'));
		var noteStyles:Array<String> = CoolUtil.coolTextFile(Paths.txt('noteStyleList'));

	//	var player1DropDown = new FlxUIDropDownMenu(10, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
	//		{
	//			_song.player1 = characters[Std.parseInt(character)];
	//		});
	//		player1DropDown.selectedLabel = _song.player1;
	
	//		var player1Label = new FlxText(10,80,64,'Player 1');
	
	//		var player2DropDown = new FlxUIDropDownMenu(140, 100, FlxUIDropDownMenu.makeStrIdLabelArray(characters, true), function(character:String)
	///		{
	//			_song.player2 = characters[Std.parseInt(character)];
	//		});
	//		player2DropDown.selectedLabel = _song.player2;
	
		var player2Label = new FlxText(140,80,64,'Player 2');
		var isMoodyCheck = new FlxUICheckBox(10, 220, null, null, "Is Moody", 100);
		var isHeyCheck = new FlxUICheckBox(10, 250, null, null, "Is Hey", 100);

		isMoodyCheck.name = "isMoody";
		isHeyCheck.name = "isHey";
		isMoodyCheck.checked = _song.isMoody;
		isSpookyCheck.checked = _song.isSpooky;
		isPixelCheck.checked = _song.isPixelStage;
		isHeyCheck.checked = _song.isHey;
		var curStage = _song.stage;

		//var ammo:Array<String> = CoolUtil.coolTextFile(Paths.txt('ammo'));

		//var maniaDropDown = new FlxUIDropDownMenu(10, 45, FlxUIDropDownMenu.makeStrIdLabelArray(ammo, true), function(keys:String)
			//{
				//_song.mania = 0;
				//_song.mania = Std.parseInt(ammo[Std.parseInt(keys)]);
		//	});

	//	player2DropDown.selectedLabel = _song.player2;
	//	var gfVersionDropDown = new FlxUIDropDownMenu(10, 200, FlxUIDropDownMenu.makeStrIdLabelArray(gfVersions, true), function(gfVersion:String)
	//		{
	//			_song.gfVersion = gfVersions[Std.parseInt(gfVersion)];
	//		});
	//	gfVersionDropDown.selectedLabel = _song.gfVersion;

	//	var gfVersionLabel = new FlxText(10,180,64,'Girlfriend');

	//	var stageDropDown = new FlxUIDropDownMenu(140, 200, FlxUIDropDownMenu.makeStrIdLabelArray(stages, true), function(stage:String)
	//		{
	//			_song.stage = stages[Std.parseInt(stage)];
	//		});
	//	stageDropDown.selectedLabel = _song.stage;
		
	//	var stageLabel = new FlxText(140,180,64,'Stage');

	//	var noteStyleDropDown = new FlxUIDropDownMenu(10, 300, FlxUIDropDownMenu.makeStrIdLabelArray(noteStyles, true), function(noteStyle:String)
	//		{
	//			_song.noteStyle = noteStyles[Std.parseInt(noteStyle)];
	//		});
	//	noteStyleDropDown.selectedLabel = _song.noteStyle;

	//	var noteStyleLabel = new FlxText(10,280,64,'Note Skin');

		var tab_group_song = new FlxUI(null, UI_box);
		tab_group_song.name = "Song";
		tab_group_song.add(UI_songTitle);
		tab_group_song.add(restart);

		tab_group_song.add(check_voices);

		tab_group_song.add(check_mute_inst);
		tab_group_song.add(isMoodyCheck);
		tab_group_song.add(isSpookyCheck);
		tab_group_song.add(isPixelCheck);
		tab_group_song.add(isHeyCheck);
		tab_group_song.add(saveButton);
		tab_group_song.add(reloadSong);
		tab_group_song.add(reloadSongJson);
		tab_group_song.add(loadAutosaveBtn);
		tab_group_song.add(stepperBPM);
		tab_group_song.add(stepperBPMLabel);
		tab_group_song.add(stepperSpeed);
		tab_group_song.add(stepperSpeedLabel);
		tab_group_song.add(stepperVocalVol);
		tab_group_song.add(stepperVocalVolLabel);
		tab_group_song.add(stepperSongVol);
		tab_group_song.add(stepperSongVolLabel);
        tab_group_song.add(shiftNoteDialLabel);
        tab_group_song.add(stepperShiftNoteDial);
        tab_group_song.add(shiftNoteDialLabel2);
        tab_group_song.add(stepperShiftNoteDialstep);
        tab_group_song.add(shiftNoteDialLabel3);
        tab_group_song.add(stepperShiftNoteDialms);
        tab_group_song.add(shiftNoteButton);
		tab_group_song.add(hitsounds);

		/*var tab_group_assets = new FlxUI(null, UI_box);
		tab_group_assets.name = "Assets";
		tab_group_assets.add(noteStyleDropDown);
		tab_group_assets.add(noteStyleLabel);
		tab_group_assets.add(gfVersionDropDown);
		tab_group_assets.add(gfVersionLabel);
		tab_group_assets.add(stageDropDown);
		tab_group_assets.add(stageLabel);
		tab_group_assets.add(player1DropDown);
		tab_group_assets.add(player2DropDown);
		tab_group_assets.add(player1Label);
		tab_group_assets.add(player2Label);
		//tab_group_song.add(maniaDropDown);*/


		UI_box.addGroup(tab_group_song);
		//UI_box.addGroup(tab_group_assets);
		UI_box.scrollFactor.set();

		FlxG.camera.follow(strumLine);
	}

	function addCharsUI():Void
	{
		player1TextField = new FlxUIInputText(10, 100, 70, _song.player1, 8);
		player2TextField = new FlxUIInputText(80, 100, 70, _song.player2, 8);
		gfTextField = new FlxUIInputText(10, 120, 70, _song.gfVersion, 8);
		stageTextField = new FlxUIInputText(80, 120, 70, _song.stage, 8);
		cutsceneTextField = new FlxUIInputText(80, 140, 70, _song.cutsceneType, 8);
		uiTextField = new FlxUIInputText(10, 140, 70, _song.uiType, 8);
		var curStage = _song.stage;
	
		var tab_group_char = new FlxUI(null, UI_box);
		tab_group_char.name = "Char";
	
	
		tab_group_char.add(uiTextField);
		tab_group_char.add(cutsceneTextField);
		tab_group_char.add(stageTextField);
		tab_group_char.add(gfTextField);
		tab_group_char.add(player1TextField);
		tab_group_char.add(player2TextField);
	
		UI_box.addGroup(tab_group_char);
		UI_box.scrollFactor.set();
	}

	var stepperLength:FlxUINumericStepper;
	var check_mustHitSection:FlxUICheckBox;
	var check_changeBPM:FlxUICheckBox;
	var stepperSectionBPM:FlxUINumericStepper;
	var check_altAnim:FlxUICheckBox;

	function addSectionUI():Void
	{
		var tab_group_section = new FlxUI(null, UI_box);
		tab_group_section.name = 'Section';

		stepperLength = new FlxUINumericStepper(10, 10, 4, 0, 0, 999, 0);
		stepperLength.value = _song.notes[curSection].lengthInSteps;
		stepperLength.name = "section_length";

		var stepperLengthLabel = new FlxText(74,10,'Section Length (in steps)');
		stepperSectionBPM = new FlxUINumericStepper(10, 80, 1, Conductor.bpm, 0, 999, 0);
		stepperSectionBPM.value = Conductor.bpm;
		stepperSectionBPM.name = 'section_bpm';

		var stepperCopy:FlxUINumericStepper = new FlxUINumericStepper(110, 132, 1, 1, -999, 999, 0);
		var stepperCopyLabel = new FlxText(174,132,'sections back');

		var copyButton:FlxButton = new FlxButton(10, 130, "Copy last section", function()
		{
			copySection(Std.int(stepperCopy.value));
		});

		var clearSectionButton:FlxButton = new FlxButton(10, 150, "Clear Section", clearSection);

		var swapSection:FlxButton = new FlxButton(10, 170, "Swap Section", function()
		{
			for (i in 0..._song.notes[curSection].sectionNotes.length)
			{
				var note = _song.notes[curSection].sectionNotes[i];

				var half = keyAmmo[_song.mania];
				note[1] = (note[1] + 8) % 16;
				_song.notes[curSection].sectionNotes[i] = note;
				updateGrid();
			}
		});

		check_mustHitSection = new FlxUICheckBox(10, 30, null, null, "Must hit section", 100);
		check_mustHitSection.name = 'check_mustHit';
		check_mustHitSection.checked = true;
		// _song.needsVoices = check_mustHit.checked;

		check_altAnim = new FlxUICheckBox(10, 400, null, null, "Alternate Animation", 100);
		check_altAnim.name = 'check_altAnim';

		check_changeBPM = new FlxUICheckBox(10, 60, null, null, 'Change BPM', 100);
		check_changeBPM.name = 'check_changeBPM';

		tab_group_section.add(stepperLength);
		tab_group_section.add(stepperLengthLabel);
		tab_group_section.add(stepperSectionBPM);
		tab_group_section.add(stepperCopy);
		tab_group_section.add(stepperCopyLabel);
		tab_group_section.add(check_mustHitSection);
		tab_group_section.add(check_altAnim);
		tab_group_section.add(check_changeBPM);
		tab_group_section.add(copyButton);
		tab_group_section.add(clearSectionButton);
		tab_group_section.add(swapSection);

		UI_box.addGroup(tab_group_section);
	}

	var stepperSusLength:FlxUINumericStepper;

	var stepperNoteTypes:FlxUINumericStepper;

	var stepperGlobalHealthDrain:FlxUINumericStepper;
	var stepperHealthDrain:FlxUINumericStepper;
	var stepperFireNote:FlxUINumericStepper;
	var stepperDeathNote:FlxUINumericStepper;
	var stepperWarningNote:FlxUINumericStepper;
	var stepperGlitchNote:FlxUINumericStepper;

	var noteTypes:Array<String> = ['Normal', 'Fire', 'Death', 'Warning', 'Angel', 'Alt Anim', 'Bob', 'Glitch'];
	var typeChangeLabel:FlxText;

	function addNoteUI():Void
	{

		var tab_group_note = new FlxUI(null, UI_box);
		tab_group_note.name = 'Note';

		stepperSusLength = new FlxUINumericStepper(10, 10, Conductor.stepCrochet / 2, 0, 0, Conductor.stepCrochet * 16);
		stepperSusLength.value = 0;
		stepperSusLength.name = 'note_susLength';

		stepperNoteTypes = new FlxUINumericStepper(100, 55, 1, selectedType, 0, noteTypes.length - 1, 0);
		stepperNoteTypes.value = selectedType;
		stepperNoteTypes.name = 'note_types';

		typeChangeLabel = new FlxText(100, 75, 64, noteTypes[selectedType] + " notes");

		var applyLength:FlxButton = new FlxButton(100, 10, 'Apply');

		var ammolabel = new FlxText(10,35,64,'Amount of Keys');

		var typelabel = new FlxText(100,35,64,'Note Types');

		/*var resetValues:FlxButton = new FlxButton(200, 235, 'Reset Values');

		var valuelabel = new FlxText(100,235,64,'Note Values');

		var drainlabel = new FlxText(10,245,64,'Global Health Drain');

		stepperGlobalHealthDrain = new FlxUINumericStepper(10, 255, 0.01, _song.noteValues[0], 0, 0.1, 0);
		stepperGlobalHealthDrain.value = _song.noteValues[0];
		stepperGlobalHealthDrain.name = 'global_health_drain';

		var noteDrainlabel = new FlxText(10,265,64,'Health Drain Note');

		stepperHealthDrain = new FlxUINumericStepper(10, 275, 0.01, _song.noteValues[1], 0.01, 0.1, 0);
		stepperHealthDrain.value = _song.noteValues[1];
		stepperHealthDrain.name = 'health_drain';

		var fireNotelabel = new FlxText(10,285,64,'Fire Note');

		stepperFireNote = new FlxUINumericStepper(10, 295, 0.05, _song.noteValues[2], 0.05, 1, 0);
		stepperFireNote.value = _song.noteValues[2];
		stepperFireNote.name = 'fire_note';


		var deathlabel = new FlxText(100,245,64,'Death Notes');

		stepperDeathNote = new FlxUINumericStepper(100, 255, 0.1, _song.noteValues[3], 0.1, 4, 0);
		stepperDeathNote.value = _song.noteValues[3];
		stepperDeathNote.name = 'death_note';

		var warninglabel = new FlxText(100,265,64,'Warning Note');

		stepperWarningNote = new FlxUINumericStepper(100, 275, 0.1, _song.noteValues[4], 0.1, 4, 0);
		stepperWarningNote.value = _song.noteValues[4];
		stepperWarningNote.name = 'warning_note';

		var glitchNotelabel = new FlxText(100,285,64,'Bob/Glitch Note');

		stepperGlitchNote = new FlxUINumericStepper(100, 295, 0.0005, _song.noteValues[5], 0.0005, 0.0075, 0);
		stepperGlitchNote.value = _song.noteValues[5];
		stepperGlitchNote.name = 'glitch_note';*/





		var m_check = new FlxUICheckBox(10, 165, null, null, "6", 100);
		m_check.checked = (_song.mania == 1);
		m_check.callback = function()
		{
			_song.mania = 0;
			if (m_check.checked)
			{
				_song.mania = 1;
			}
			trace('vos sos puto');
		};

		var m_check2 = new FlxUICheckBox(10, 225, null, null, "9", 100);
		m_check2.checked = (_song.mania == 2);
		m_check2.callback = function()
		{
			_song.mania = 0;
			if (m_check2.checked)
			{
				_song.mania = 2;
			}
			trace('vos sos puto otra vez no weí');
		};
		var m_check3 = new FlxUICheckBox(10, 145, null, null, "5", 100);
		m_check3.checked = (_song.mania == 3);
		m_check3.callback = function()
		{
			_song.mania = 0;
			if (m_check3.checked)
			{
				_song.mania = 3;
			}
			trace('5 keys pog');
		};
		var m_check4 = new FlxUICheckBox(10, 185, null, null, "7", 100);
		m_check4.checked = (_song.mania == 4);
		m_check4.callback = function()
		{
			_song.mania = 0;
			if (m_check4.checked)
			{
				_song.mania = 4;
			}
			trace('7 keys pog');
		};
		var m_check5 = new FlxUICheckBox(10, 205, null, null, "8", 100);
		m_check5.checked = (_song.mania == 5);
		m_check5.callback = function()
		{
			_song.mania = 0;
			if (m_check5.checked)
			{
				_song.mania = 5;
			}
			trace('8 keys pog');
		};
		var m_check6 = new FlxUICheckBox(10, 65, null, null, "1", 100);
		m_check6.checked = (_song.mania == 5); 
		m_check6.callback = function()
		{
			_song.mania = 0;
			if (m_check6.checked)
			{
				_song.mania = 6;
			}
			trace('1 keys pog');
		};
		var m_check7 = new FlxUICheckBox(10, 85, null, null, "2", 100);
		m_check7.checked = (_song.mania == 7);
		m_check7.callback = function()
		{
			_song.mania = 0;
			if (m_check7.checked)
			{
				_song.mania = 7;
			}
			trace('2 keys pog');
		};
		var m_check8 = new FlxUICheckBox(10, 105, null, null, "3", 100);
		m_check8.checked = (_song.mania == 5);
		m_check8.callback = function()
		{
			_song.mania = 0;
			if (m_check8.checked)
			{
				_song.mania = 8;
			}
			trace('3 keys pog');
		};

		var m_check0 = new FlxUICheckBox(10, 125, null, null, "4", 100);
		m_check0.checked = (_song.mania == 0);
		m_check0.callback = function()
		{
			_song.mania = 0;
			if (m_check0.checked)
			{
				_song.mania = 0;
			}
			trace('4 keys cringe');
		};

		tab_group_note.add(stepperSusLength);
		tab_group_note.add(applyLength);
		//tab_group_note.add(resetValues);
		tab_group_note.add(ammolabel);
		tab_group_note.add(stepperNoteTypes);
		tab_group_note.add(typeChangeLabel);
		tab_group_note.add(typelabel);
		/*tab_group_note.add(valuelabel);
		tab_group_note.add(drainlabel);
		tab_group_note.add(stepperGlobalHealthDrain);
		tab_group_note.add(noteDrainlabel);
		tab_group_note.add(stepperHealthDrain);
		tab_group_note.add(fireNotelabel);
		tab_group_note.add(stepperFireNote);
		tab_group_note.add(deathlabel);
		tab_group_note.add(stepperDeathNote);
		tab_group_note.add(warninglabel);
		tab_group_note.add(stepperWarningNote);
		tab_group_note.add(glitchNotelabel);
		tab_group_note.add(stepperGlitchNote);*/
		tab_group_note.add(m_check0);
		tab_group_note.add(m_check);
		tab_group_note.add(m_check2);
		tab_group_note.add(m_check3);
		tab_group_note.add(m_check4);
		tab_group_note.add(m_check5);
		tab_group_note.add(m_check6);
		tab_group_note.add(m_check7);
		tab_group_note.add(m_check8);

		UI_box.addGroup(tab_group_note);
	}

	function loadSong(daSong:String):Void
	{
		if (FlxG.sound.music != null)
		{
			FlxG.sound.music.stop();
			// vocals.stop();
		}

		FlxG.sound.playMusic(Paths.inst(daSong), 0.6);

		// WONT WORK FOR TUTORIAL OR TEST SONG!!! REDO LATER
		vocals = new FlxSound().loadEmbedded(Paths.voices(daSong));
		FlxG.sound.list.add(vocals);

		FlxG.sound.music.pause();
		vocals.pause();

		FlxG.sound.music.onComplete = function()
		{
			vocals.pause();
			vocals.time = 0;
			FlxG.sound.music.pause();
			FlxG.sound.music.time = 0;
			changeSection();
		};
	}

	function generateUI():Void
	{
		while (bullshitUI.members.length > 0)
		{
			bullshitUI.remove(bullshitUI.members[0], true);
		}

		// general shit
		var title:FlxText = new FlxText(UI_box.x + 20, UI_box.y + 20, 0);
		bullshitUI.add(title);
		/* 
			var loopCheck = new FlxUICheckBox(UI_box.x + 10, UI_box.y + 50, null, null, "Loops", 100, ['loop check']);
			loopCheck.checked = curNoteSelected.doesLoop;
			tooltips.add(loopCheck, {title: 'Section looping', body: "Whether or not it's a simon says style section", style: tooltipType});
			bullshitUI.add(loopCheck);
		 */
	}

	override function getEvent(id:String, sender:Dynamic, data:Dynamic, ?params:Array<Dynamic>)
	{
		if (id == FlxUICheckBox.CLICK_EVENT)
		{
			var check:FlxUICheckBox = cast sender;
			var label = check.getLabel().text;
			switch (label)
			{
				case 'Must hit section':
					_song.notes[curSection].mustHitSection = check.checked;

					updateHeads();

				case 'Change BPM':
					_song.notes[curSection].changeBPM = check.checked;
					FlxG.log.add('changed bpm shit');
				case "Alternate Animation":
					_song.notes[curSection].altAnim = check.checked;
					case "Is Moody":
						_song.isMoody = check.checked;
					case "Is Spooky":
						_song.isSpooky = check.checked;
					case "Is Hey":
						_song.isHey = check.checked;
			}
		}
		else if (id == FlxUINumericStepper.CHANGE_EVENT && (sender is FlxUINumericStepper))
		{
			var nums:FlxUINumericStepper = cast sender;
			var wname = nums.name;
			FlxG.log.add(wname);
			if (wname == 'section_length')
			{
				if (nums.value <= 4)
					nums.value = 4;
				_song.notes[curSection].lengthInSteps = Std.int(nums.value);
				updateGrid();
			}
			else if (wname == 'song_speed')
			{
				if (nums.value <= 0)
					nums.value = 0;
				_song.speed = nums.value;
			}
			else if (wname == 'song_bpm')
			{
				if (nums.value <= 0)
					nums.value = 1;
				tempBpm = Std.int(nums.value);
				Conductor.mapBPMChanges(_song);
				Conductor.changeBPM(Std.int(nums.value));
			}
			else if (wname == 'note_susLength')
			{
				if (curSelectedNote == null)
					return;

				if (nums.value <= 0)
					nums.value = 0;
				curSelectedNote[2] = nums.value;
				updateGrid();
			}
			else if (wname == 'section_bpm')
			{
				if (nums.value <= 0.1)
					nums.value = 0.1;
				_song.notes[curSection].bpm = Std.int(nums.value);
				updateGrid();
			}else if (wname == 'song_vocalvol')
			{
				if (nums.value <= 0.1)
					nums.value = 0.1;
				vocals.volume = nums.value;
			}else if (wname == 'song_instvol')
			{
				if (nums.value <= 0.1)
					nums.value = 0.1;
				FlxG.sound.music.volume = nums.value;
			}
			else if (wname == 'note_type')
				{
					selectedType = Std.int(nums.value);
					
					//updateGrid();
				}
			/*else if (wname == 'global_health_drain')
				{
					_song.noteValues[0] = nums.value;
				}
			else if (wname == 'health_drain')
				{
					_song.noteValues[1] = nums.value;
				}
			else if (wname == 'fire_note')
				{
					_song.noteValues[2] = nums.value;
				}
			else if (wname == 'death_note')
				{
					_song.noteValues[3] = nums.value;
				}
			else if (wname == 'warning_note')
				{
					_song.noteValues[4] = nums.value;
				}
			else if (wname == 'glitch_note')
				{
					_song.noteValues[5] = nums.value;
				}*/
		}

		// FlxG.log.add(id + " WEED " + sender + " WEED " + data + " WEED " + params);
	}

	var updatedSection:Bool = false;

	/* this function got owned LOL
		function lengthBpmBullshit():Float
		{
			if (_song.notes[curSection].changeBPM)
				return _song.notes[curSection].lengthInSteps * (_song.notes[curSection].bpm / _song.bpm);
			else
				return _song.notes[curSection].lengthInSteps;
	}*/
	function stepStartTime(step):Float
	{
		return _song.bpm / (step / 4) / 60;
	}
	function sectionStartTime(section:Int):Float
	{
		//var whichSection:Int = section;
		var daBPM:Float = _song.bpm;
		var daPos:Float = 0;
		for (i in 0...section)
		{
			if (_song.notes[i].changeBPM)
			{
				daBPM = _song.notes[i].bpm;
			}
			daPos += 4 * (1000 * 60 / daBPM);
		}
		return daPos;
	}

	override function update(elapsed:Float)
	{
		typeChangeLabel.text = noteTypes[Std.int(stepperNoteTypes.value)] + ' notes';
		curStep = recalculateSteps();
		if (_song.mania == 2 && gridBG.width != S_GRID_SIZE * 18)
		{
			remove(gridBG);
			gridBG = FlxGridOverlay.create(S_GRID_SIZE, GRID_SIZE, S_GRID_SIZE * 18, GRID_SIZE * 16);
			add(gridBG);
			remove(gridBGAbove);
			gridBGAbove = FlxGridOverlay.create(S_GRID_SIZE, GRID_SIZE, S_GRID_SIZE * 18, GRID_SIZE * 16);
			add(gridBGAbove);
			remove(gridBGBelow);
			gridBGBelow = FlxGridOverlay.create(S_GRID_SIZE, GRID_SIZE, S_GRID_SIZE * 18, GRID_SIZE * 16);
			add(gridBGBelow);
		}
		if (_song.mania == 5 && gridBG.width != S_GRID_SIZE * 16)
			{
				remove(gridBG);
				gridBG = FlxGridOverlay.create(S_GRID_SIZE, GRID_SIZE, S_GRID_SIZE * 16, GRID_SIZE * 16);
				add(gridBG);
				remove(gridBGAbove);
				gridBGAbove = FlxGridOverlay.create(S_GRID_SIZE, GRID_SIZE, S_GRID_SIZE * 16, GRID_SIZE * 16);
				add(gridBGAbove);
				remove(gridBGBelow);
				gridBGBelow = FlxGridOverlay.create(S_GRID_SIZE, GRID_SIZE, S_GRID_SIZE * 16, GRID_SIZE * 16);
				add(gridBGBelow);
			}
		if (_song.mania == 4 && gridBG.width != GRID_SIZE * 14)
			{
				remove(gridBG);
				gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 14, GRID_SIZE * 16);
				add(gridBG);
				remove(gridBGAbove);
				gridBGAbove = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 14, GRID_SIZE * 16);
				add(gridBGAbove);
				remove(gridBGBelow);
				gridBGBelow = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 14, GRID_SIZE * 16);
				add(gridBGBelow);
			}
		if (_song.mania == 1 && gridBG.width != GRID_SIZE * 12)
		{
			remove(gridBG);
			gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 12, GRID_SIZE * 16);
			add(gridBG);
			remove(gridBGAbove);
			gridBGAbove = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 12, GRID_SIZE * 16);
			add(gridBGAbove);
			remove(gridBGBelow);
			gridBGBelow = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 12, GRID_SIZE * 16);
			add(gridBGBelow);
		}
		if (_song.mania == 3 && gridBG.width != GRID_SIZE * 10)
			{
				remove(gridBG);
				gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 10, GRID_SIZE * 16);
				add(gridBG);
				remove(gridBGAbove);
				gridBGAbove = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 10, GRID_SIZE * 16);
				add(gridBGAbove);
				remove(gridBGBelow);
				gridBGBelow = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 10, GRID_SIZE * 16);
				add(gridBGBelow);
			}
		if (_song.mania == 0 && gridBG.width != GRID_SIZE * 8)
		{
			remove(gridBG);
			gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
			add(gridBG);
			remove(gridBGAbove);
			gridBGAbove = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
			add(gridBGAbove);
			remove(gridBGBelow);
			gridBGBelow = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 8, GRID_SIZE * 16);
			add(gridBGBelow);
		}
		if (_song.mania == 6 && gridBG.width != GRID_SIZE * 2)
			{
				remove(gridBG);
				gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 2, GRID_SIZE * 16);
				add(gridBG);
				remove(gridBGAbove);
				gridBGAbove = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 2, GRID_SIZE * 16);
				add(gridBGAbove);
				remove(gridBGBelow);
				gridBGBelow = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 2, GRID_SIZE * 16);
				add(gridBGBelow);
			}
		if (_song.mania == 7 && gridBG.width != GRID_SIZE * 4)
			{
				remove(gridBG);
				gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 4, GRID_SIZE * 16);
				add(gridBG);
				remove(gridBGAbove);
				gridBGAbove = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 4, GRID_SIZE * 16);
				add(gridBGAbove);
				remove(gridBGBelow);
				gridBGBelow = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 4, GRID_SIZE * 16);
				add(gridBGBelow);
			}
		if (_song.mania == 8 && gridBG.width != GRID_SIZE * 6)
			{
				remove(gridBG);
				gridBG = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 6, GRID_SIZE * 16);
				add(gridBG);
				remove(gridBGAbove);
				gridBGAbove = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 6, GRID_SIZE * 16);
				add(gridBGAbove);
				remove(gridBGBelow);
				gridBGBelow = FlxGridOverlay.create(GRID_SIZE, GRID_SIZE, GRID_SIZE * 6, GRID_SIZE * 16);
				add(gridBGBelow);
			}
		gridBlackLine.x = gridBG.x + gridBG.width / 2;
		leftIcon.setPosition(0, -100);
		rightIcon.setPosition(gridBG.width / 2, -100);
		UI_box.x = FlxG.width / 2;// + 160 * _song.mania;
		UI_box.y = 20;
		if (_song.mania != 0)
		{
			UI_box.x = FlxG.width / 2 + 160;// + 160 * _song.mania;
			UI_box.y = 100;
		}

 		gridBGAbove.y = gridBG.y - gridBG.height;
		gridBGBelow.y = gridBG.y + gridBG.height;
		gridBGAbove.alpha = 0.7;
		gridBGBelow.alpha = 0.7;

		if (curSection == 0)
			gridBGAbove.alpha = 0;

		Conductor.songPosition = FlxG.sound.music.time;
		_song.song = typingShit.text;

		strumLine.y = getYfromStrum((Conductor.songPosition - sectionStartTime(curSection)) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps));
		if (_song.mania == 2 || _song.mania == 5) strumLine.x = -70;
		else strumLine.x = -300;

		if (playClaps)
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.sound.music.playing)
					{
						FlxG.overlap(strumLine, note, function(_, _)
						{
							if(!claps.contains(note))
							{
								claps.push(note);
								FlxG.sound.play(Paths.sound('SNAP'));
							}
						});
					}
				});
			}

		if (curBeat % 4 == 0 && curStep >= 16 * (curSection + 1))
		{
			trace(curStep);
			trace((_song.notes[curSection].lengthInSteps) * (curSection + 1));
			trace('DUMBSHIT');

			if (_song.notes[curSection + 1] == null || _song.notes[curSection + 2] == null)
			{
				addSection();
			}

			changeSection(curSection + 1, false);
		}

		FlxG.watch.addQuick('daBeat', curBeat);
		FlxG.watch.addQuick('daStep', curStep);

		if (FlxG.mouse.justPressed)
		{
			if (FlxG.mouse.overlaps(curRenderedNotes))
			{
				curRenderedNotes.forEach(function(note:Note)
				{
					if (FlxG.mouse.overlaps(note))
					{
						if (FlxG.keys.pressed.CONTROL)
						{
							selectNote(note);
						}
						else if (FlxG.keys.pressed.SHIFT)
						{
							//isGrabbingNote = true;
							//grabStartPos = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
						}
						else
						{
							trace('tryin to delete note...');
							deleteNote(note);
						}
					}
				});
			}
			else
			{
				if (FlxG.mouse.x > gridBG.x
					&& FlxG.mouse.x < gridBG.x + gridBG.width
					&& FlxG.mouse.y > gridBG.y
					&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
				{
					FlxG.log.add('added note');
					addNote();
				}
			}
		}
		if (FlxG.mouse.x > gridBG.x
			&& FlxG.mouse.x < gridBG.x + gridBG.width
			&& FlxG.mouse.y > gridBG.y
			&& FlxG.mouse.y < gridBG.y + (GRID_SIZE * _song.notes[curSection].lengthInSteps))
		{
			var arX = Math.floor(FlxG.mouse.x / GRID_SIZE) * GRID_SIZE;
			if (_song.mania == 2 || _song.mania == 5) arX = Math.floor(FlxG.mouse.x / S_GRID_SIZE) * S_GRID_SIZE;
			dummyArrow.x = arX;
			if (FlxG.keys.pressed.SHIFT)
				dummyArrow.y = FlxG.mouse.y;
			else
				dummyArrow.y = Math.floor(FlxG.mouse.y / GRID_SIZE) * GRID_SIZE;
		}

		if (FlxG.keys.justPressed.ENTER)
		{
			lastSection = curSection;

			PlayState.SONG = _song;
			FlxG.sound.music.stop();
			vocals.stop();
			Main.editor = false;
			FlxG.switchState(new PlayState());
		}

		if (FlxG.keys.justPressed.E)
		{
			changeNoteSustain(Conductor.stepCrochet);
		}
		if (FlxG.keys.justPressed.Q)
		{
			changeNoteSustain(-Conductor.stepCrochet);
		}

		if (FlxG.keys.justPressed.T)
			FlxG.camera.zoom += 0.25;
		if (FlxG.keys.justPressed.Y)
			FlxG.camera.zoom -= 0.25;

		if (FlxG.keys.justPressed.TAB)
		{
			if (FlxG.keys.pressed.SHIFT)
			{
				UI_box.selected_tab -= 1;
				if (UI_box.selected_tab < 0)
					UI_box.selected_tab = 2;
			}
			else
			{
				UI_box.selected_tab += 1;
				if (UI_box.selected_tab >= 3)
					UI_box.selected_tab = 0;
			}
		}

		if (!typingShit.hasFocus)
		{
			if (FlxG.keys.justPressed.SPACE)
			{
				if (FlxG.sound.music.playing)
				{
					FlxG.sound.music.pause();
					vocals.pause();
					claps.splice(0, claps.length);
				}
				else
				{
					vocals.play();
					FlxG.sound.music.play();
				}
			}

			if (FlxG.keys.justPressed.R)
			{
				if (FlxG.keys.pressed.SHIFT)
					resetSection(true);
				else
					resetSection();
			}

			if (FlxG.mouse.wheel != 0)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				FlxG.sound.music.time -= (FlxG.mouse.wheel * Conductor.stepCrochet * 0.4);
				vocals.time = FlxG.sound.music.time;
			}

			if (!FlxG.keys.pressed.SHIFT)
			{
				if (FlxG.keys.pressed.W || FlxG.keys.pressed.S)
				{
					FlxG.sound.music.pause();
					vocals.pause();
					claps.splice(0, claps.length);

					var daTime:Float = 700 * FlxG.elapsed;

					if (FlxG.keys.pressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}
			else
			{
				if (FlxG.keys.justPressed.W || FlxG.keys.justPressed.S)
				{
					FlxG.sound.music.pause();
					vocals.pause();

					var daTime:Float = Conductor.stepCrochet * 2;

					if (FlxG.keys.justPressed.W)
					{
						FlxG.sound.music.time -= daTime;
					}
					else
						FlxG.sound.music.time += daTime;

					vocals.time = FlxG.sound.music.time;
				}
			}
		}

		_song.bpm = tempBpm;

		/* if (FlxG.keys.justPressed.UP)
				Conductor.changeBPM(Conductor.bpm + 1);
			if (FlxG.keys.justPressed.DOWN)
				Conductor.changeBPM(Conductor.bpm - 1); */

		var shiftThing:Int = 1;
		if (FlxG.keys.pressed.SHIFT)
			shiftThing = 4;
		if (FlxG.keys.justPressed.RIGHT || FlxG.keys.justPressed.D)
			changeSection(curSection + shiftThing);
		if (FlxG.keys.justPressed.LEFT || FlxG.keys.justPressed.A)
			changeSection(curSection - shiftThing);

		bpmTxt.text = bpmTxt.text = Std.string(FlxMath.roundDecimal(Conductor.songPosition / 1000, 2))
			+ " / "
			+ Std.string(FlxMath.roundDecimal(FlxG.sound.music.length / 1000, 2))
			+ "\nSection: "
			+ curSection
			+ "\nCurStep: "
			+ curStep;
		super.update(elapsed);
	}

	function changeNoteSustain(value:Float):Void
	{
		if (curSelectedNote != null)
		{
			if (curSelectedNote[2] != null)
			{
				curSelectedNote[2] += value;
				curSelectedNote[2] = Math.max(curSelectedNote[2], 0);
			}
		}

		updateNoteUI();
		updateGrid();
	}

	function recalculateSteps():Int
	{
		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length)
		{
			if (FlxG.sound.music.time > Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((FlxG.sound.music.time - lastChange.songTime) / Conductor.stepCrochet);
		updateBeat();

		return curStep;
	}

	function resetSection(songBeginning:Bool = false):Void
	{
		updateGrid();

		FlxG.sound.music.pause();
		vocals.pause();

		// Basically old shit from changeSection???
		FlxG.sound.music.time = sectionStartTime(curSection);

		if (songBeginning)
		{
			FlxG.sound.music.time = 0;
			curSection = 0;
		}

		vocals.time = FlxG.sound.music.time;
		updateCurStep();

		updateGrid();
		updateSectionUI();
	}

	function changeSection(sec:Int = 0, ?updateMusic:Bool = true):Void
	{
		trace('changing section' + sec);

		if (_song.notes[sec] != null)
		{
			curSection = sec;

			updateGrid();

			if (updateMusic)
			{
				FlxG.sound.music.pause();
				vocals.pause();

				/*var daNum:Int = 0;
					var daLength:Float = 0;
					while (daNum <= sec)
					{
						daLength += lengthBpmBullshit();
						daNum++;
				}*/

				FlxG.sound.music.time = sectionStartTime(curSection);
				vocals.time = FlxG.sound.music.time;
				updateCurStep();
			}

			updateGrid();
			updateSectionUI();
		}
	}

	function copySection(?sectionNum:Int = 1)
	{
		var daSec = FlxMath.maxInt(curSection, sectionNum);

		for (note in _song.notes[daSec - sectionNum].sectionNotes)
		{
			var strum = note[0] + Conductor.stepCrochet * (_song.notes[daSec].lengthInSteps * sectionNum);

			var copiedNote:Array<Dynamic> = [strum, note[1], note[2]];
			_song.notes[daSec].sectionNotes.push(copiedNote);
		}

		updateGrid();
	}

	function updateSectionUI():Void
	{
		var sec = _song.notes[curSection];

		stepperLength.value = sec.lengthInSteps;
		check_mustHitSection.checked = sec.mustHitSection;
		check_altAnim.checked = sec.altAnim;
		check_changeBPM.checked = sec.changeBPM;
		stepperSectionBPM.value = sec.bpm;

		updateHeads();
	}

	function updateHeads():Void
	{
		if (check_mustHitSection.checked)
		{
			leftIcon.changeChartingIcon('bf');
			rightIcon.changeChartingIcon('dad');
		}
		else
		{
			leftIcon.changeChartingIcon('dad');
			rightIcon.changeChartingIcon('bf');
		}
	}

	function updateNoteUI():Void
	{
		if (curSelectedNote != null)
			stepperSusLength.value = curSelectedNote[2];
	}

	function updateGrid():Void
	{
		while (curRenderedNotes.members.length > 0)
		{
			curRenderedNotes.remove(curRenderedNotes.members[0], true);
		}

		while (curRenderedSustains.members.length > 0)
		{
			curRenderedSustains.remove(curRenderedSustains.members[0], true);
		}

		while (curRenderedTypes.members.length > 0)
			{
				curRenderedTypes.remove(curRenderedTypes.members[0], true);
			}

		var sectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;

		var lastSectionInfo:Array<Dynamic> = _song.notes[curSection].sectionNotes;
		if (curSection != 0)
			lastSectionInfo = _song.notes[curSection - 1].sectionNotes;

		var nextSectionInfo:Array<Dynamic> = _song.notes[curSection + 1].sectionNotes;

		var sectionArray:Array<Int> = [0, -1, 1];

		if (_song.notes[curSection].changeBPM && _song.notes[curSection].bpm > 0)
		{
			Conductor.changeBPM(_song.notes[curSection].bpm);
			FlxG.log.add('CHANGED BPM!');
		}
		else
		{
			// get last bpm
			var daBPM:Float = _song.bpm;
			for (i in 0...curSection)
				if (_song.notes[i].changeBPM)
					daBPM = _song.notes[i].bpm;
			Conductor.changeBPM(daBPM);
		}

		/* // PORT BULLSHIT, INCASE THERE'S NO SUSTAIN DATA FOR A NOTE
			for (sec in 0..._song.notes.length)
			{
				for (notesse in 0..._song.notes[sec].sectionNotes.length)
				{
					if (_song.notes[sec].sectionNotes[notesse][2] == null)
					{
						trace('SUS NULL');
						_song.notes[sec].sectionNotes[notesse][2] = 0;
					}
				}
			}
		 */
		/*for (ii in 0...sectionArray.length)
		{
			var noteyposShit:Int;
			var whichFuckingSectionIsIt:Array<Dynamic> = sectionInfo;
			switch (sectionArray[ii])
			{
				case 0: 
					whichFuckingSectionIsIt = sectionInfo;
				case 1: 
					//if (_song.notes[curSection - 1] != null)
						//whichFuckingSectionIsIt = lastSectionInfo;
				case 3: 
					whichFuckingSectionIsIt = nextSectionInfo;
			}
			for (i in whichFuckingSectionIsIt)
				{
					var daNoteInfo = i[1];
					var daStrumTime = i[0];
					var daSus = i[2];
					var daType = i[3];
					var note:Note = new Note(daStrumTime, daNoteInfo % (keyAmmo[_song.mania]));
					note.sustainLength = daSus;
					note.noteType = daType;
					note.setGraphicSize(GRID_SIZE, GRID_SIZE);
					note.updateHitbox();
		
					//note.updateHitbox();note.burning = daNoteInfo > 7;
						
					
					note.x = Math.floor(daNoteInfo * GRID_SIZE);
					note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime()) % (Conductor.stepCrochet * _song.notes[curSection + sectionArray[ii]].lengthInSteps)));
		
					if (_song.mania == 2 || _song.mania == 5)
					{
						note.setGraphicSize(S_GRID_SIZE, GRID_SIZE);
						note.x = Math.floor(daNoteInfo * S_GRID_SIZE);
					}
		
					if (daType != 0)
						{
							var thetext:String = Std.string(daType);
							var typeText:FlxText = new FlxText(note.x, note.y, 0, thetext, 25, true);
							typeText.color = FlxColor.fromRGB(255,0,0);
							if (daType == 5)
								{
									typeText.text = "Alt";
								}
							curRenderedTypes.add(typeText);
						}
		
					curRenderedNotes.add(note);
		
					if (daSus > 0)
					{
						var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
							note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
						curRenderedSustains.add(sustainVis);
					}
				}
		}*/
		for (i in sectionInfo)
			{
				var daNoteInfo = i[1];
				var daStrumTime = i[0];
				var daSus = i[2];
				var daType = i[3];
				var note:Note = new Note(daStrumTime, daNoteInfo % (keyAmmo[_song.mania]));
				note.sustainLength = daSus;
				note.noteType = daType;
				note.setGraphicSize(GRID_SIZE, GRID_SIZE);
				note.updateHitbox();
	
				//note.updateHitbox();note.burning = daNoteInfo > 7;
					
				
				note.x = Math.floor(daNoteInfo * GRID_SIZE);
				note.y = Math.floor(getYfromStrum((daStrumTime - sectionStartTime(curSection)) % (Conductor.stepCrochet * _song.notes[curSection].lengthInSteps)));
	
				if (_song.mania == 2 || _song.mania == 5)
				{
					note.setGraphicSize(S_GRID_SIZE, GRID_SIZE);
					note.x = Math.floor(daNoteInfo * S_GRID_SIZE);
				}
	
				if (daType != 0)
					{
						var thetext:String = Std.string(daType);
						var typeText:FlxText = new FlxText(note.x, note.y, 0, thetext, 25, true);
						typeText.color = FlxColor.fromRGB(255,0,0);
						if (daType == 5)
							{
								typeText.text = "Alt";
							}
						curRenderedTypes.add(typeText);
					}
	
				curRenderedNotes.add(note);
	
				if (daSus > 0)
				{
					var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
						note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
					curRenderedSustains.add(sustainVis);
				}
			}
		if (curSection != 0)
		{
			for (i in lastSectionInfo)//copy pasted cuz it was broken as shit and crashing and shit and i hate this chart editor please nija mff make good one please
				{
					var daNoteInfo = i[1];
					var daStrumTime = i[0];
					var daSus = i[2];
					var daType = i[3];
					var note:Note = new Note(daStrumTime, daNoteInfo % (keyAmmo[_song.mania]));
					note.sustainLength = daSus;
					note.noteType = daType;
					note.setGraphicSize(GRID_SIZE, GRID_SIZE);
					note.updateHitbox();
		
					//note.updateHitbox();note.burning = daNoteInfo > 7;
						
					
					note.x = Math.floor(daNoteInfo * GRID_SIZE);
					note.y = Math.floor(getAboveYfromStrum((daStrumTime - sectionStartTime(curSection - 1)) % (Conductor.stepCrochet * _song.notes[curSection - 1].lengthInSteps)));
					//note.y += gridBG.height;
		
					if (_song.mania == 2 || _song.mania == 5)
					{
						note.setGraphicSize(S_GRID_SIZE, GRID_SIZE);
						note.x = Math.floor(daNoteInfo * S_GRID_SIZE);
					}
		
					if (daType != 0)
						{
							var thetext:String = Std.string(daType);
							var typeText:FlxText = new FlxText(note.x, note.y, 0, thetext, 25, true);
							typeText.color = FlxColor.fromRGB(255,0,0);
							if (daType == 5)
								{
									typeText.text = "Alt";
								}
							curRenderedTypes.add(typeText);
						}
		
					curRenderedNotes.add(note);
		
					if (daSus > 0)
					{
						var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
							note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
						curRenderedSustains.add(sustainVis);
					}
				}
		}
		for (i in nextSectionInfo)
			{
				var daNoteInfo = i[1];
				var daStrumTime = i[0];
				var daSus = i[2];
				var daType = i[3];
				var note:Note = new Note(daStrumTime, daNoteInfo % (keyAmmo[_song.mania]));
				note.sustainLength = daSus;
				note.noteType = daType;
				note.setGraphicSize(GRID_SIZE, GRID_SIZE);
				note.updateHitbox();
	
				//note.updateHitbox();note.burning = daNoteInfo > 7;
					
				
				note.x = Math.floor(daNoteInfo * GRID_SIZE);
				note.y = Math.floor(getBelowYfromStrum((daStrumTime - sectionStartTime(curSection + 1)) % (Conductor.stepCrochet * _song.notes[curSection + 1].lengthInSteps)));
				//note.y += gridBG.height;
	
				if (_song.mania == 2 || _song.mania == 5)
				{
					note.setGraphicSize(S_GRID_SIZE, GRID_SIZE);
					note.x = Math.floor(daNoteInfo * S_GRID_SIZE);
				}
	
				if (daType != 0)
					{
						var thetext:String = Std.string(daType);
						var typeText:FlxText = new FlxText(note.x, note.y, 0, thetext, 25, true);
						typeText.color = FlxColor.fromRGB(255,0,0);
						if (daType == 5)
							{
								typeText.text = "Alt";
							}
						curRenderedTypes.add(typeText);
					}
	
				curRenderedNotes.add(note);
	
				if (daSus > 0)
				{
					var sustainVis:FlxSprite = new FlxSprite(note.x + (GRID_SIZE / 2),
						note.y + GRID_SIZE).makeGraphic(8, Math.floor(FlxMath.remapToRange(daSus, 0, Conductor.stepCrochet * 16, 0, gridBG.height)));
					curRenderedSustains.add(sustainVis);
				}
			}

	}

	private function addSection(lengthInSteps:Int = 16):Void
	{
		var sec:SwagSection = {
			lengthInSteps: lengthInSteps,
			bpm: _song.bpm,
			changeBPM: false,
			mustHitSection: true,
			sectionNotes: [],
			typeOfSection: 0,
			altAnim: false
		};

		_song.notes.push(sec);
	}

	function selectNote(note:Note):Void
	{
		var swagNum:Int = 0;

		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i.strumTime == note.strumTime && i.noteData % (keyAmmo[_song.mania]) == note.noteData)
			{
				curSelectedNote = _song.notes[curSection].sectionNotes[swagNum];
			}

			swagNum += 1;
		}

		updateGrid();
		updateNoteUI();
	}

	function deleteNote(note:Note):Void
	{
		for (i in _song.notes[curSection].sectionNotes)
		{
			if (i[0] == note.strumTime && i[1] % (keyAmmo[_song.mania]) == note.noteData)
			{
				FlxG.log.add('FOUND EVIL NUMBER');
				_song.notes[curSection].sectionNotes.remove(i);
			}
		}

		updateGrid();
	}

	function clearSection():Void
	{
		_song.notes[curSection].sectionNotes = [];

		updateGrid();
	}

	/*function ResetNoteValues():Void
		{
			_song.noteValues = [0, 0.01, 0.45, 2.2, 1, 0.005];

			updateNoteUI();
		}*/

	function clearSong():Void
	{
		for (daSection in 0..._song.notes.length)
		{
			_song.notes[daSection].sectionNotes = [];
		}

		updateGrid();
	}
	private function newSection(lengthInSteps:Int = 16,mustHitSection:Bool = false,altAnim:Bool = true):SwagSection
		{
			var sec:SwagSection = {
				lengthInSteps: lengthInSteps,
				bpm: _song.bpm,
				changeBPM: false,
				mustHitSection: mustHitSection,
				sectionNotes: [],
				typeOfSection: 0,
				altAnim: altAnim
			};

			return sec;
		}

	function shiftNotes(measure:Int=0,step:Int=0,ms:Int = 0):Void
		{
			var newSong = [];
			
			var millisecadd = (((measure*4)+step/4)*(60000/_song.bpm))+ms;
			var totaladdsection = Std.int((millisecadd/(60000/_song.bpm)/4));
			trace(millisecadd,totaladdsection);
			if(millisecadd > 0)
				{
					for(i in 0...totaladdsection)
						{
							newSong.unshift(newSection());
						}
				}
			for (daSection1 in 0..._song.notes.length)
				{
					newSong.push(newSection(16,_song.notes[daSection1].mustHitSection,_song.notes[daSection1].altAnim));
				}
	
			for (daSection in 0...(_song.notes.length))
			{
				var aimtosetsection = daSection+Std.int((totaladdsection));
				if(aimtosetsection<0) aimtosetsection = 0;
				newSong[aimtosetsection].mustHitSection = _song.notes[daSection].mustHitSection;
				newSong[aimtosetsection].altAnim = _song.notes[daSection].altAnim;
				//trace("section "+daSection);
				for(daNote in 0...(_song.notes[daSection].sectionNotes.length))
					{	
						var newtiming = _song.notes[daSection].sectionNotes[daNote][0]+millisecadd;
						if(newtiming<0)
						{
							newtiming = 0;
						}
						var futureSection = Math.floor(newtiming/4/(60000/_song.bpm));
						_song.notes[daSection].sectionNotes[daNote][0] = newtiming;
						newSong[futureSection].sectionNotes.push(_song.notes[daSection].sectionNotes[daNote]);
	
						//newSong.notes[daSection].sectionNotes.remove(_song.notes[daSection].sectionNotes[daNote]);
					}
	
			}
			//trace("DONE BITCH");
			_song.notes = newSong;
			updateGrid();
			updateSectionUI();
			updateNoteUI();
		}

	private function addNote(?n:Note):Void
	{
		var noteStrum = getStrumTime(dummyArrow.y) + sectionStartTime(curSection);
		//var noteStrum = getStrumTime(dummyArrow.y) + (curSection * (Conductor.stepCrochet * 16));
		var noteData = Math.floor(FlxG.mouse.x / GRID_SIZE);
		var noteSus = 0;
		var noteType = 0;
		noteType = Std.int(stepperNoteTypes.value);



		if (_song.mania == 2 || _song.mania == 5)
		{
			var noteData = Math.floor(FlxG.mouse.x / S_GRID_SIZE);
		}

		if (n != null)
			_song.notes[curSection].sectionNotes.push([n.strumTime, n.noteData, n.sustainLength, n.noteType]);
		else
			_song.notes[curSection].sectionNotes.push([noteStrum, noteData, noteSus, noteType]);

		var thingy = _song.notes[curSection].sectionNotes[_song.notes[curSection].sectionNotes.length - 1];

		curSelectedNote = thingy;
		if (FlxG.keys.pressed.CONTROL)
		{
			_song.notes[curSection].sectionNotes.push([noteStrum, (noteData -18), noteSus]);
		}


		trace(noteStrum);
		trace(curSection);

		updateGrid();
		updateNoteUI();

		autosaveSong();
	}

	function getStrumTime(yPos:Float):Float
	{
		return FlxMath.remapToRange(yPos, gridBG.y, gridBG.y + gridBG.height, 0, 16 * Conductor.stepCrochet);
	}

	function getYfromStrum(strumTime:Float):Float
	{
		return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBG.y, gridBG.y + gridBG.height);
	}
	function getAboveYfromStrum(strumTime:Float):Float
		{
			return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBGAbove.y, gridBGAbove.y + gridBGAbove.height);
		}
	function getBelowYfromStrum(strumTime:Float):Float
		{
			return FlxMath.remapToRange(strumTime, 0, 16 * Conductor.stepCrochet, gridBGBelow.y, gridBGBelow.y + gridBGBelow.height);
		}

	/*
		function calculateSectionLengths(?sec:SwagSection):Int
		{
			var daLength:Int = 0;
			for (i in _song.notes)
			{
				var swagLength = i.lengthInSteps;
				if (i.typeOfSection == Section.COPYCAT)
					swagLength * 2;
				daLength += swagLength;
				if (sec != null && sec == i)
				{
					trace('swag loop??');
					break;
				}
			}
			return daLength;
	}*/
	private var daSpacing:Float = 0.3;

	function loadLevel():Void
	{
		trace(_song.notes);
	}

	function getNotes():Array<Dynamic>
	{
		var noteData:Array<Dynamic> = [];
		//var noteType:Array<Dynamic> = [];

		for (i in _song.notes)
		{
			noteData.push(i.sectionNotes);
			//noteType.push(i.sectionNotes);
		}

		return noteData;
	//	return noteType;
	}

	function loadJson(song:String):Void
	{
		PlayState.SONG = Song.loadFromJson(song.toLowerCase(), song.toLowerCase());
		FlxG.resetState();
	}

	function loadAutosave():Void
	{
		PlayState.SONG = Song.parseJSONshit(FlxG.save.data.autosave);
		FlxG.resetState();
	}

	function autosaveSong():Void
	{
		FlxG.save.data.autosave = Json.stringify({
			"song": _song
		});
		FlxG.save.flush();
	}

	private function saveLevel()
	{
		var json = {
			"song": _song
		};

		var data:String = Json.stringify(json);

		if ((data != null) && (data.length > 0))
		{
			_file = new FileReference();
			_file.addEventListener(Event.COMPLETE, onSaveComplete);
			_file.addEventListener(Event.CANCEL, onSaveCancel);
			_file.addEventListener(IOErrorEvent.IO_ERROR, onSaveError);
			_file.save(data.trim(), _song.song.toLowerCase() + ".json");
		}
	}

	function onSaveComplete(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.notice("Successfully saved LEVEL DATA.");
	}

	/**
	 * Called when the save file dialog is cancelled.
	 */
	function onSaveCancel(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
	}

	/**
	 * Called if there is an error while saving the gameplay recording.
	 */
	function onSaveError(_):Void
	{
		_file.removeEventListener(Event.COMPLETE, onSaveComplete);
		_file.removeEventListener(Event.CANCEL, onSaveCancel);
		_file.removeEventListener(IOErrorEvent.IO_ERROR, onSaveError);
		_file = null;
		FlxG.log.error("Problem saving Level data");
	}
}
