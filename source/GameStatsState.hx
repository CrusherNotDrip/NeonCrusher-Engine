package;

import flixel.text.FlxText;
import flixel.group.FlxGroup;
import flixel.tweens.FlxTween;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;

class GameStatsState extends MusicBeatState
{
    public static var lastPlayed:String = "None";
    public static var totalNotesHit:Float = 0;
    public static var totalSicks:Float = 0;
    public static var totalGoods:Float = 0;
    public static var totalBads:Float = 0;
    public static var totalShits:Float = 0;

    var bg:FlxSprite;
    var bgLane:FlxSprite;

    override function create()
    {
        bg = new FlxSprite().loadGraphic(Paths.image('menuDesat'));
        bg.scrollFactor.set();  
        bg.screenCenter();
        add(bg);

        bgLane = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, FlxColor.BLACK);
        bgLane.scale.x = 0.5;
        bgLane.alpha = 0.5;
        bgLane.scrollFactor.set();
        bgLane.screenCenter(X);
        add(bgLane);

        var daStats:FlxText = new FlxText(0, 0, FlxG.width, 
        "Total Sicks Hit: " + totalSicks +
        "\nTotal Goods Hit: " + totalGoods +
        "\nTotal Bads Hit: " + totalBads,
        50);
        daStats.setFormat(Paths.font("vcr.ttf"), 50, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
        daStats.borderSize = 1.5;
        daStats.borderQuality = 2;
        daStats.scrollFactor.set();
        daStats.screenCenter();
        add(daStats);
    }
}

class GameStatsData
{
    
}