/*
Copyright (c) 2013 Kael Fraga

	This file is part of Mage Escape.

    Mage Escape is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    Mage Escape is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with Mage Escape.  If not, see <http://www.gnu.org/licenses/>.
*/
package;

import org.flixel.FlxButton;
import org.flixel.FlxG;
import org.flixel.FlxSprite;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.util.FlxColor;

/**
 * ...
 * @author Kael Fraga
 */
class MenuMain extends FlxState 
{
	private var _gameTitle:FlxText;
	private var _bg:FlxSprite;
	private var _gameWarn:FlxText;
	
	override public function create():Void 
	{
		/**
		 * fade in from black
		 */
		FlxG.flash(FlxColor.BLACK, 3, null);
		FlxG.mouse.hide();
				
		/**
		 * adding the background image 320x240
		 */
		_bg = new FlxSprite(0, 0, "assets/menu.png");
		add(_bg);

		/**
		 * some credit text
		 */
		add(new FlxText(280, 200, 40, "by Kael Fraga"));
		
		_gameWarn = new FlxText(10, 220, 300, "Press SPACE to start!");
		_gameWarn.setFormat(null, 8, 0xffffff, "center", 0xffffff);
		add(_gameWarn);
	}
	
	override public function update():Void 
	{
		/**
		 * update the sccene
		 */
		super.update();

		if ( FlxG.keys.pressed("SPACE")) 
		{
			onStart();
		}
	}
	
	private function onStart():Void
	{
		FlxG.fade(FlxColor.BLACK, 2, false, this.onFade);
	}
	
	private function onFade():Void
	{
		FlxG.switchState(new Level(Reg.level));
	}

}