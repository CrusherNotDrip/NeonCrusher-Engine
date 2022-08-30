package;

import lime.app.Application;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class FunkinWindow extends Application
{
    public static var appName = "Friday Night Funkin': NeonCrusher Engine";

    public static function changeAppName(newAppName:String)
        Application.current.window.title = newAppName;
    
    public static function changeAppX(newAppX:Int)
        Application.current.window.x = newAppX;
    
    public static function changeAppY(newAppY:Int)
        Application.current.window.y = newAppY;
}
