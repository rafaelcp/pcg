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

import org.flixel.FlxG;
import org.flixel.FlxState;
import org.flixel.FlxText;
import org.flixel.util.FlxColor;

/**
 * ...
 * @author Kael Fraga
 */
class EndGame extends FlxState 
{
	private var _gameTitle:FlxText;
	private var _record:FlxText;
	private var _gameWarn:FlxText;

	override public function create():Void 
	{
		/**
		 * fade in to the scene from black
		 */
		FlxG.flash(FlxColor.BLACK, 3);
		FlxG.mouse.hide();
		
		/**
		 * add some text to show to player some informations
		 */
		_gameTitle = new FlxText(10, 90, 300, "GAME OVER");
		_gameTitle.setFormat(null, 16, 0xffffff, "center", 0xff00ff);
		add(_gameTitle);
		
		_record = new FlxText(65, 125, 200);
		_record.text = Std.string("Top Score: " + Reg.maxScore + "\nYour Score: " + Reg.score); //compare the last score with the current
		_record.setFormat(null, 8, 0xffffff, "center", 0xff00ff);
		add(_record);
		
		_gameWarn = new FlxText(10, 160, 300, "Press SPACE to back!");
		_gameWarn.setFormat(null, 8, 0xffffff, "center", 0xffffff);
		add(_gameWarn);
	}
	
	override public function update():Void 
	{
		/**
		 * update everything on stage
		 */
		super.update();
		
		if ( FlxG.keys.pressed("SPACE")) 
		{
			Reg.score = 0;
			onStart(); //returns to menu
		}
	}
	
	private function onStart():Void
	{
		FlxG.fade(FlxColor.BLACK, 2, false, this.onFade);
	}
	
	private function onFade():Void
	{
		FlxG.switchState(new MenuMain());
	}
}