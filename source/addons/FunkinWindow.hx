package addons;

import lime.app.Application;

class FunkinWindow
{
    public static var appName = "Friday Night Funkin': NeonCrusher Engine";
    public static var realtimeAppName = "Null";
    public static var appX = 0;
    public static var appY = 0;
    private static var shakeEDB:Bool = false;

    public static function updateShit() {
        realtimeAppName = Application.current.window.title;
        appX = Application.current.window.x;
        appY = Application.current.window.y;
    }

    public static function changeAppName(newAppName:String) {
        Application.current.window.title = newAppName;
    }

    //shake enable disable shit
    public static function shakeED(f:Bool) {
        switch (f) {
            case true:
                shakeEDB = true;
            case false:
                shakeEDB = false;
        }
    }

    public static function shakeApp(sInt:Int, time) {
        if (shakeEDB) {
            setAppX(1, sInt);
            new FlxTimer().start(time, function(tmr:FlxTimer) 
            {
                setAppY(1, sInt);
                new FlxTimer().start(time, function(tmr:FlxTimer) 
                {
                    setAppX(2, sInt);  
                    new FlxTimer().start(time, function(tmr:FlxTimer) 
                    {
                        setAppY(2, sInt);
                        new FlxTimer().start(time, function(tmr:FlxTimer) 
                        {
                            shakeApp(sInt, time);
                        });
                    });
                });
            });
        }
    }

    public static function setAppX(?style:Int = 0, newAppX:Int) {
        switch (style) {
            case 0:
                Application.current.window.x = newAppX;
            case 1:
                Application.current.window.x += newAppX;
            case 2:
                Application.current.window.x -= newAppX;
        }
    }
    
    public static function setAppY(?style:Int = 0, newAppY:Int) {
        switch (style) {
            case 0:
                Application.current.window.y = newAppY;
            case 1:
                Application.current.window.y += newAppY;
            case 2:
                Application.current.window.y -= newAppY;
        }
    }
}