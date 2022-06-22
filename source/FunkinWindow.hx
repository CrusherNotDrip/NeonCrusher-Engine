package;

import lime.app.Application;
import flixel.FlxG;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;

class FunkinWindow extends Application
{
    public static var appName = "Friday Night Funkin': NeonCrusher Engine";

    public static function changeAppName(newAppName:String) {
        Application.current.window.title = newAppName;
    }

    public function changeWindowSize(width:Float, height:Float, ?smooth:Bool = false)
    {
        
    }
}