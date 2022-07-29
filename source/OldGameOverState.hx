package;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;

class OldGameOverState extends MusicBeatState
{
	override function create()
	{
		var loser:FlxSprite = new FlxSprite(100, 100);
		var loseTex = Paths.getSparrowAtlas('lose');
		loser.frames = loseTex;
		loser.animation.addByPrefix('lose', 'lose', 24, false);
		loser.animation.play('lose');
		add(loser);

		var restart:FlxSprite = new FlxSprite(500, 50).loadGraphic(Paths.image('restart'));
		restart.setGraphicSize(Std.int(restart.width * 0.6));
		restart.updateHitbox();
		restart.alpha = 0;
		restart.antialiasing = true;
		add(restart);

		FlxG.sound.music.fadeOut(2, FlxG.sound.music.volume * 0.6);

		FlxTween.tween(restart, {alpha: 1}, 1, {ease: FlxEase.quartInOut});
		FlxTween.tween(restart, {y: restart.y + 40}, 7, {ease: FlxEase.quartInOut, type: PINGPONG});

		super.create();
	}

	override function update(elapsed:Float)
	{
		if (controls.ACCEPT)
		{
			FlxG.sound.music.fadeOut(0.5, 0, function(twn:FlxTween)
			{
				FlxG.sound.music.stop();
				LoadingState.loadAndSwitchState(new PlayState());
			});
		}
		else if (controls.BACK)
		{
			if (PlayState.isStoryMode)
				FlxG.switchState(new StoryMenuState());
			else 
				FlxG.switchState(new FreeplayState());
	
			GameStatsState.lastPlayed = PlayState.SONG.song;
			GameStatsState.icon = PlayState.gameVar.iconP2.char;
			GameStatsState.iconColour = PlayState.gameVar.dad.iconColour;
	
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
	
			GameStatsState.saveGameData();
	
			PlayState.blueballed = 0;
			PlayState.seenCutscene = false;
		}
		super.update(elapsed);
	}
}