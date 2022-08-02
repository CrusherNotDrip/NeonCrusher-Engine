package;

import Controls.Control;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.FlxSubState;
import flixel.addons.transition.FlxTransitionableState;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.util.FlxColor;

class PauseSubState extends MusicBeatSubstate
{
	var grpMenuShit:FlxTypedGroup<Alphabet>;

	var pauseOG:Array<String> = ['Resume', 'Restart Song', 'Change Difficulty', 'Toggle Botplay', 'Toggle Practice Mode', 'Exit to menu'];
	var difficultyChoices:Array<String> = ['EASY', 'NORMAL', 'HARD', 'BACK'];

	var menuItems:Array<String> = [];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	var botplayText:FlxText;
	var practiceText:FlxText;

	public function new(x:Float, y:Float)
	{
		if (PlayState.isStoryMode)
			FunkinWindow.changeAppName(FunkinWindow.appName + " - " + PlayState.SONG.song + " - " + CoolUtil.difficultyString()  + " - (Story Mode) - PAUSED");
		else
			FunkinWindow.changeAppName(FunkinWindow.appName + " - " + PlayState.SONG.song + " - " + CoolUtil.difficultyString()  + " - (Freeplay) - PAUSED");

		super();

		menuItems = pauseOG;

		pauseMusic = new FlxSound().loadEmbedded(Paths.music('breakfast'), true, true);
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		var bg:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		var levelInfo:FlxText = new FlxText(20, 15, 0, "", 32);
		levelInfo.text += PlayState.SONG.song;
		levelInfo.scrollFactor.set();
		levelInfo.setFormat(Paths.font("vcr.ttf"), 32);
		levelInfo.updateHitbox();
		add(levelInfo);

		var levelDifficulty:FlxText = new FlxText(20, 15 + 32, 0, "", 32);
		levelDifficulty.text += CoolUtil.difficultyString();
		levelDifficulty.scrollFactor.set();
		levelDifficulty.setFormat(Paths.font('vcr.ttf'), 32);
		levelDifficulty.updateHitbox();
		add(levelDifficulty);

		var blueballedText:FlxText = new FlxText(20, 15 + 64, 0, "Blueballed: ", 32);
		blueballedText.text += PlayState.blueballed; 
		blueballedText.scrollFactor.set();
		blueballedText.setFormat(Paths.font('vcr.ttf'), 32);
		blueballedText.updateHitbox();
		add(blueballedText);

		practiceText = new FlxText(20, 15 + 96, 0, "PRACTICE MODE", 32);
		practiceText.scrollFactor.set();
		practiceText.setFormat(Paths.font('vcr.ttf'), 32);
		practiceText.updateHitbox();
		practiceText.x = FlxG.width - (practiceText.width + 20);
		practiceText.visible = PlayState.practiceMode;
		add(practiceText);

		botplayText = new FlxText(20, 15 + 126, 0, "BOTPLAY", 32);
		botplayText.scrollFactor.set();
		botplayText.setFormat(Paths.font('vcr.ttf'), 32);
		botplayText.updateHitbox();
		botplayText.x = FlxG.width - (botplayText.width + 20);
		botplayText.visible = PlayState.botplay;
		add(botplayText);

		levelDifficulty.alpha = 0;
		levelInfo.alpha = 0;
		blueballedText.alpha = 0;

		levelInfo.x = FlxG.width - (levelInfo.width + 20);
		levelDifficulty.x = FlxG.width - (levelDifficulty.width + 20);
		blueballedText.x = FlxG.width - (blueballedText.width + 20);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});
		FlxTween.tween(levelInfo, {alpha: 1, y: 20}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(levelDifficulty, {alpha: 1, y: levelDifficulty.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});
		FlxTween.tween(blueballedText, {alpha: 1, y: blueballedText.y + 5}, 0.4, {ease: FlxEase.quartInOut, startDelay: 0.5});

		grpMenuShit = new FlxTypedGroup<Alphabet>();
		add(grpMenuShit);

		regenMenu();
	}

	private function regenMenu()
	{
		while (grpMenuShit.members.length > 0)
		{
			grpMenuShit.remove(grpMenuShit.members[0], true);
		}


		for (i in 0...menuItems.length)
		{
			var songText:Alphabet = new Alphabet(0, (70 * i) + 30, menuItems[i], true, false);
			songText.isMenuItem = true;
			songText.targetY = i;
			grpMenuShit.add(songText);
		}

		curSelected = 0;

		changeSelection();
	}

	override function update(elapsed:Float)
	{
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		super.update(elapsed);

		var upP = controls.UI_UP_P;
		var downP = controls.UI_DOWN_P;
		var accepted = controls.ACCEPT;

		if (upP)
		{
			changeSelection(-1);
		}
		if (downP)
		{
			changeSelection(1);
		}

		if (accepted)
		{
			var daSelected:String = menuItems[curSelected];

			switch (daSelected)
			{
				case "Resume":
					close();
					if (PlayState.isStoryMode)
						FunkinWindow.changeAppName(FunkinWindow.appName + " - " + PlayState.SONG.song + " - " + CoolUtil.difficultyString()  + " - (Story Mode)");
					else
						FunkinWindow.changeAppName(FunkinWindow.appName + " - " + PlayState.SONG.song + " - " + CoolUtil.difficultyString()  + " - (Freeplay)");
				case "Restart Song":
					FlxG.resetState();
				case "Change Difficulty":
					menuItems = difficultyChoices;
					regenMenu();
				case "Toggle Botplay":
					PlayState.modeUsed = true;
					PlayState.botplay = !PlayState.botplay;
					botplayText.visible = PlayState.botplay;
				case "Toggle Practice Mode":
					PlayState.modeUsed = true;
					PlayState.practiceMode = !PlayState.practiceMode;
					practiceText.visible = PlayState.practiceMode;
				case "Exit to menu":
					endSong();

				case "EASY" | "NORMAL" | "HARD":
					PlayState.SONG = Song.loadFromJson(Highscore.formatSong(PlayState.SONG.song.toLowerCase(), curSelected), PlayState.SONG.song.toLowerCase());
					PlayState.storyDifficulty = curSelected;
					FlxG.resetState();
				case "BACK":
					menuItems = pauseOG;
					regenMenu();
			}
		}
	}

	override function destroy()
	{
		pauseMusic.destroy();

		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);

		curSelected += change;

		if (curSelected < 0)
			curSelected = menuItems.length - 1;
		if (curSelected >= menuItems.length)
			curSelected = 0;

		var bullShit:Int = 0;

		for (item in grpMenuShit.members)
		{
			item.targetY = bullShit - curSelected;
			bullShit++;

			item.alpha = 0.6;
			// item.setGraphicSize(Std.int(item.width * 0.8));

			if (item.targetY == 0)
			{
				item.alpha = 1;
				// item.setGraphicSize(Std.int(item.width));
			}
		}
	}

	function endSong() 
	{
		if (PlayState.isStoryMode)
			FlxG.switchState(new StoryMenuState());
		else 
			FlxG.switchState(new FreeplayState());

		GameStatsState.lastPlayed = PlayState.SONG.song;
		GameStatsState.icon = PlayState.gameVar.iconP2.char;
		GameStatsState.iconColour = PlayState.gameVar.dad.iconColour;

		if (!PlayState.modeUsed)
		{
			GameStatsState.totalNotesHit += PlayState.gameVar.songHits;
			GameStatsState.totalSicks += PlayState.gameVar.sicks;
			GameStatsState.totalGoods += PlayState.gameVar.goods;
			GameStatsState.totalBads += PlayState.gameVar.bads;
			GameStatsState.totalShits += PlayState.gameVar.shits;
			GameStatsState.totalMisses += PlayState.gameVar.songMisses;
			GameStatsState.totalBlueballed += PlayState.blueballed;
	
			GameStatsState.songNotesHit = PlayState.gameVar.songHits;
			GameStatsState.songSicks = PlayState.gameVar.sicks;
			GameStatsState.songGoods = PlayState.gameVar.goods;
			GameStatsState.songBads = PlayState.gameVar.bads;
			GameStatsState.songShits = PlayState.gameVar.shits;
			GameStatsState.songMisses = PlayState.gameVar.songMisses;
			GameStatsState.songBlueballed = PlayState.blueballed;
		}
		else
		{
			GameStatsState.totalNotesHit += 0;
			GameStatsState.totalSicks += 0;
			GameStatsState.totalGoods += 0;
			GameStatsState.totalBads += 0;
			GameStatsState.totalShits += 0;
			GameStatsState.totalMisses += 0;
			GameStatsState.totalBlueballed += 0;
	
			GameStatsState.songNotesHit = 0;
			GameStatsState.songSicks = 0;
			GameStatsState.songGoods = 0;
			GameStatsState.songBads = 0;
			GameStatsState.songShits = 0;
			GameStatsState.songMisses = 0;
			GameStatsState.songBlueballed = 0;
		}
		
		GameStatsState.songBpm = PlayState.SONG.bpm;

		GameStatsState.saveGameData();

		PlayState.blueballed = 0;
		PlayState.seenCutscene = false;
		PlayState.botplay = false;
		PlayState.practiceMode = false;
		PlayState.modeUsed = false;
	}
}
