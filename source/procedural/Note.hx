/*
Copyright (c) 2013 Rafael C.P.

	This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU Lesser General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Lesser General Public License for more details.

    You should have received a copy of the GNU Lesser General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
*/
package procedural; 

	import org.flixel.util.FlxRandom;

	/**
	 * ...
	 * @author Rafael C.P.
	 */
	class Note 
	{
		public var pitch:Int;
		public var octave:Int = 4;
		public var length:Int = 8;
		public var cumlength:Float = 1.0/8;
		public var previous:Note;
		public var next:Note;
		public var vel:Int;
		public var acc:Int;
		public var index:Int = 0;
		public var defaultLength:Int = 8;
		public var defaultOctave:Int = 4;
		
		public function new(pitch:Int, octave:Int = 4, length:Int = 8, previous:Note = null) {
			this.pitch = pitch;
			this.octave = octave;
			this.length = length;
			this.cumlength = 1.0/length;
			this.previous = previous;
			if (previous != null) {
				var v:Int = (pitch - previous.pitch);
				acc = v - previous.vel;
				vel = v;
				index = previous.index + 1;
				cumlength += previous.cumlength;
			}
		}
		
		public function toString():String {
			var scale:String = 'cdega';
			//trace(length);
			if (length != defaultLength) {
				return scale.charAt(pitch) + Std.string(length);
			}
			else {
				return scale.charAt(pitch);				
			}
		}
		
		public function resetIndex():Void {
			index = 0;
		}
		
		public function calcCumSum():Float {
			var s:Float = 1.0 / length;
			var n:Note = this;
			while (n.previous != null) {
				n = n.previous;
				s += 1.0 / n.length;
			}			
			return s;
		}
		
		public function nextNote(rhythmEnergy:Float):Note {
			var scale:String = 'cdega';
			var currnote:Int = pitch;
			var l:Int = length;
			var prob:Array<Float> = new Array<Float>();
			var i:Int;
			var currdist:Float;
			var middledist:Float;
			var dev:Float = rhythmEnergy * (2 * Math.pow((scale.length - 1) / 2, 2));
			var centrality:Float;
			var proximity:Float;
			//trace(rhythmEnergy);
			
			for (i in 0 ...  (scale.length)) {
				//if (i >= currnote-1)
					proximity = Math.exp( -Math.pow(currnote - i, 2) / dev);
				//else
					//proximity = Math.exp( -Math.pow(currnote - i, 2) / (dev/2));
				centrality = Math.exp( -Math.pow((scale.length - 1) / 2 - i, 2) / dev);
				prob.push(proximity * centrality);
				//if (i - currnote > 1) prob[prob.length-1] *= 2;
				if (i - currnote < -1) prob[prob.length-1] *= 0.1;
			}
			if (FlxRandom.float() < rhythmEnergy) {
				currnote = Composer.roulette(prob, FlxRandom.float());
			}			
/*
			if (acc == 0) {
				l  = defaultLength * 2;
			}
			else if (Math.abs(acc) > 0) {
				l = defaultLength;
			}*/
			if (1.0 / l > 1 - cumlength) {
				l = Math.round(1.0/(1 - cumlength));
			}
			
			var n:Note = new Note(currnote, octave, l, this);
			next = n;
			return 	n;		
		}
		
		public function nextNote2(rhythmEnergy:Float):Note {
			var scale:String = 'cdefgab';
			var leap:Int = 0;
			var currnote:Int = pitch;
			var l:Int = length;
			//step or leap?
			//trace(index+" / "+vel+" / "+ rhythmEnergy + " / " + acc);
			if (Math.abs(vel) == 1 && FlxRandom.float() < rhythmEnergy && acc == 0 && length <= defaultLength && FlxRandom.float() < Math.abs(currnote - 3.0)/3.0 && (currnote - 3.0) * vel > 0) { //last note is 1 step higher/lower than previous note, can leap down/up
				leap = -vel * Math.round(FlxRandom.float() * 4 * rhythmEnergy + 2);					
				currnote += leap;					
				//trace("leap on " + index + ": " + leap);				
			}
			else if (Math.abs(vel) > 1) { //Coming from a leap up/down, step down/up
				currnote -= Math.round(vel / Math.abs(vel));					
			}
			else if (acc != 0) {
				 currnote += vel;
			}
			else { //Step
				if (currnote > (scale.length - 1) / 2 && FlxRandom.float() < 0.1) currnote -= Math.round(FlxRandom.float());
				else if (currnote < (scale.length - 1) / 2 && FlxRandom.float() < 0.1) currnote += Math.round(FlxRandom.float());
				else if (FlxRandom.float() < 0.1) currnote += vel;
				else currnote += Math.round(FlxRandom.float() * 2 - 1);
			}
			if (currnote < 0) {
				//if (open >= 1) { //Lower limit octave
					currnote = 0;
				/*}
				else {
					currnote = scale.length + currnote;
					m += '>';
					open++;
				}*/
			}
			else if (currnote >= scale.length) {
				//if (open <= -1) { //Upper limit octave
					currnote = scale.length - 1;
				/*}
				else {
					currnote = currnote % scale.length;
					m += '<';
					open--;
				}*/
			}
						
			if (acc == 0) {
				l  = defaultLength * 2;
				//trace("SOBE PRA "+l);
			}
			/*else if (Math.abs(acc) > 1) {
				l = defaultLength / 2;
				//trace("DESCE PRA "+l+" def "+defaultLength+" vel "+vel);
			}*/
			else if (Math.abs(acc) > 0) {
				l = defaultLength;
				//trace("NORMALIZA PRA "+l+" def "+defaultLength+" vel "+vel);
			}
			
			//trace(cumlength + " / " + calcCumSum());
			
			if (1.0 / l > 1 - cumlength) {
				//trace(" cum " + cumlength + " l " + l);
				l = Math.round(1.0/(1 - cumlength));
			}
			
			//trace(vel);
			var n:Note = new Note(currnote, octave, l, this);
			next = n;
			return 	n;		
		}
	}
