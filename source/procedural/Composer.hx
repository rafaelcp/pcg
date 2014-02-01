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
	import org.si.sion.*;
	import org.si.sion.utils.SiONPresetVoice;
	import org.si.sion.SiONVoice;

	/**
	 * ...
	 * @author Rafael C.P.
	 */
	class Composer 
	{
		
		static public var presetVoice:SiONPresetVoice = new  SiONPresetVoice();

		public function Composer() 
		{
			
		}
		
		public static function makeRhythm(pulses:Int, steps:Int):Array<Array<Int>> {			
			var r:Array<Array<Int>> = new  Array<Array<Int>>();
			var i:Int;
			for (i in 0 ... (pulses)) {				
				r.push([1]);				
			}
			for (i in pulses ... (steps)) {				
				r.push([0]);
			}
			//trace(r.length+" / "+r[0].length+" / "+r);
			while (true) {
				for (i in 0 ... (Math.round(Math.min(pulses, steps - pulses)))) {
					r[i] = r[i].concat(r[r.length - 1]);
					//trace(i+": "+r.length+" / "+r[0].length+" / "+r);
					r = r.slice(0, r.length - 1);
					//trace(i+": "+r.length+" / "+r[0].length+" / "+r);
				}
				pulses = Math.round(Math.min(pulses, steps - pulses));// i;
				steps = r.length;
				//trace("foi " + i);				
				if (pulses <= 1) {
					break;
				}
			}
			//trace(r.length+" / "+r[0].length+" / "+r);
			return r;
		}
		
		public static function rhythmToString(rhythm:Array<Array<Int>>):String {
			var s:String = '';
			var i:Int;
			var j:Int;
			for (i in 0 ...(rhythm.length)) {
				var l:Array<Int> = rhythm[i];
				for (j in 0...(l.length)) {
					if (l[j] == 1) {
						s += 'x';
					}
					else {
						s += '.';
					}
				}
			}
			return s;
		}
		
		public static function getEnergyAt(rhythms:Array<String>, pos:Int):Int {
			var i:Int;
			var sum:Int = 0;
			for (i in 0...(rhythms.length)) {
				//trace(rhythms[i]);
				if ((cast(rhythms[i],String)).charAt(pos % (cast(rhythms[i],String)).length) == 'x') {
					sum++;
				}
			}
			return sum;
		}
		
		public static function calcAccentInterval(rhythms:Array<String>):Int {
			var x:Int = 1;
			var pos:Int = 1;
			var i:Int;
			var sum:Int = 0;
			while (true) {
				sum = getEnergyAt(rhythms, pos);
				if (sum == rhythms.length) {
					return pos;
				}
				pos++;
			}
			return x;
		}
		
		public static function rhythmToMML(rhythm:Array<Array<Int>>, note:String = 'c', instrument:Int = 1):String {			
			//var mml:String = 't100 q0 l16 o3 v8 %9 @'+instrument+' $ ';
			//trace(note, instrument);
		
			/*
			//LISTA TODOS OS INSTRUMENTOS
			trace(presetVoice.categolies);
			for (i in 0 ... presetVoice.categolies.length) {
				trace(i, presetVoice.categolies[i].name);
				for (j in 0 ... presetVoice.categolies[i].length) {
					trace(i, j, presetVoice.categolies[i][j].name);// , presetVoice.categolies[i][j].param);
				}
			}
			*/
			
			//PERCUSS
			//var v:SiONVoice = new SiONVoice(presetVoice.categolies[6][15]);// instruments[instrument % instruments.length]]);   
			var instruments:Array<Int> = [0, 1, 2, 3, 4, 6, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 22, 23, 24, 26, 27, 29, 30, 32, 33, 34, 35, 36];
			var v:SiONVoice = presetVoice.categolies[6][instruments[instrument % instruments.length]];   
			var mml:String = v.getMML(instrument % instruments.length) + '\nt100 l16 o4 v4 %6 @'+(instrument % instruments.length)+' $ ';
						
			//trace(presetVoice.categolies[6].name,presetVoice.categolies[6][instruments[instrument % instruments.length]].name);// , presetVoice.categolies[i][j].param);
			
			var c:Int = 0;
			var i:Int;
			var j:Int;
			for (i in 0...(rhythm.length)) {
				var l:Array<Int> = rhythm[i]; 
				for (j in 0...(l.length)) {
					if (l[j] == 1) {
						if (c > 0) {
							mml += '[r]' + c; //String(c)
							c = 0;
						}
						mml += 'c';// note;
					}
					else {
						c++;
					}
				}
			}
			if (c > 0) {
				mml += '[r]' + c; //String(c)
			}
			mml += '; //Rhythm \n';
			return mml;
		}
		
		public static function getCol(a:Array<Array<Float>>, col:Int):Array<Float> {			
			var c:Array<Float> = new Array<Float>();
			var i:Int;
			for (i in 0...(a.length)) {
				c.push(a[i][col]);
			}
			return c;
		}
		
		public static function arraySum(a:Array<Float>):Float {
			var sum:Float = 0;
			var i:Int;
			for (i in 0...(a.length)) {
				sum += a[i];
			}			
			return sum;
		}
		
		public static function arrayDivide(a:Array<Float>,x:Float):Array<Float> {
			var c:Array<Float> = new Array<Float>();
			var i:Int;
			for (i in 0...(a.length)) {
				c.push(a[i] / x);				
			}			
			return c;
		}
		
		public static function arrayProb(a:Array<Float>):Array<Float> {
			return Composer.arrayDivide(a, Composer.arraySum(a));			
		}
		
		public static function roulette(probs:Array<Float>, r:Float=-1):Int {			
			var cs:Float = 0;
			probs = Composer.arrayProb(probs);
			if (r < 0) r = FlxRandom.float();
			//trace(probs, r);
			var i:Int;
			for (i in 0...(probs.length)) {
				cs += probs[i];
				if (r <= cs) {
					return i;
				}
			}
			return 0;
		}
		
		public static function makeBar(rhythm:Array<Int>):Array<Int> {
			var a:Array<Int> = new Array<Int>();
			//var rhythm:Array = Composer.makeRythm(
			var barsize:Int = 16;
			var i:Int;
			for (i in 0...(barsize)) {
				
			}
			return a;
		}

		public static function makeHarmonyBar(rhythms:Array<String>,seed:Float=0):Array<String> {	
			var h1:String = '';
			var h2:String = '';
			var h3:String = '';
			var chordprog:Array<Array<Float>> = [
				[24,   35,    0,   20,   70,    5],
				[ 2,    2,    5,    1,    1,    5],
                [ 2,    1,    0,    1,    2,    1],
                [39,    4,   85,    1,   13,   49],
                [20,   86,    2,   76,    1,   39],
                [35,    4,    8,    1,   14,    1]
				];
			
			var chords:Array<String> = ['ceg', 'dfa', 'egb', 'fac', 'gbd', 'ace'];
			var oldchord:Int = 0;
			var currchord:Int = 0;
			var barsize:Int = 4;
			var i:Int;
			for (i in 0... (barsize)) {
				h1 += (cast(chords[currchord],String)).charAt(0);
				h2 += (cast(chords[currchord],String)).charAt(1);
				h3 += (cast(chords[currchord],String)).charAt(2);
				//trace(Composer.getEnergyAt(rhythms, i * 2));
				if (FlxRandom.float() < Composer.getEnergyAt(rhythms, i * Math.floor(16 / barsize)) / rhythms.length) {					
					currchord = roulette(getCol(chordprog, currchord), FlxRandom.float());
					chordprog[currchord][oldchord]++;
					oldchord = currchord;
				}
				else if (i > 0 && i < barsize-1) {
					h1 += '&';
					h2 += '&';
					h3 += '&';
				}
			}
			//trace(Composer.arrayProb(Composer.getCol(chordprog, 1)));			
			return [h1,h2,h3];
		}
		
		public static function makeHarmony(rhythms:Array<String>, bars:Int = 4, time:Int = 100, eighth:Int = 4):String {	
			var start:Int = 16;// Math.floor(calcAccentInterval(rhythms) / 2) * 4;
			
			//var h:String = 't100 l8 [r]' + start + ' o4 v4 %9 @' + (FlxRandom.nextInt(127) + 0) + ' $ ';			
			//var h:String = '\nt100 l4 [r]' + start + ' o4 v4 %6 @254 $ ';			
			var h:String = '\nt' + time + ' l4 [r]' + start + ' o '+ eighth +' v4 %6 @254 $ ';	
			var h1:String = h;
			var h2:String = h;
			var h3:String = h;
			var a:Array<String> = new Array<String>();
			var i:Int;
			for (i in 0... (bars)) {
				a = makeHarmonyBar(rhythms, (FlxRandom.globalSeed + 1) * (i + 1));
				h1 +=  a[0] + ' ';
				h2 +=  a[1] + ' ';
				h3 +=  a[2] + ' ';
			}
			h1 += ';\n';
			h2 += ';\n';
			h3 += '; //Harmony\n';
			
			//PIANO			
			var instruments:Array<Int> =  [3, 5, 6, 7, 10,12, 13, 14, 15, 16, 17];
			//var v:SiONVoice = new SiONVoice(presetVoice.categolies[7][instruments[Math.floor(FlxRandom.float() * (instruments.length - 1))]]);
			var v:SiONVoice = presetVoice.categolies[7][instruments[Math.floor(FlxRandom.float() * (instruments.length - 1))]];
			
			//trace(presetVoice.categolies[7].name,presetVoice.categolies[7][instruments[Math.floor(FlxRandom.float() * (instruments.length - 1))]].name);// , presetVoice.categolies[i][j].param);
						
			return v.getMML(254) + h1 + h2 + h3;
			//return SiONVoice(presetVoice["valsound.piano"][instruments[Math.floor(FlxRandom.float()*(instruments.length-1))]]).getMML(254) + h1 + h2 + h3;
		}
		
		public static function makeHarmony2(rhythms:Array<String>, size:Int = 100):String {	
			var start:Int = Math.floor(calcAccentInterval(rhythms) / 2);
			var header:String = '[r]' + start + ' l8 o4 v8 %1 $ ';			
			var h1:String = header;
			var h2:String = header;
			var h3:String = header;
			var chordprog:Array<Array<Float>> = [
				[24,   35,    0,   20,   70,    5],
				[ 2,    2,    5,    1,    1,    5],
                [ 2,    1,    0,    1,    2,    1],
                [39,    4,   85,    1,   13,   49],
                [20,   86,    2,   76,    1,   39],
                [35,    4,    8,    1,   14,    1]
				];
			var rhythmEnergy:Int = 0;
			//var pos:Int = 0;
			
			var chords:Array<String> = ['ceg', 'dfa', 'egb', 'fac', 'gbd', 'ace'];
			var oldchord:Int = 0;
			var currchord:Int = 0;
			//var nextchord = 0;
			var i:Int;
			for (i in 0 ... (size)) {
				h1 += (cast(chords[currchord],String)).charAt(0);
				h2 += (cast(chords[currchord],String)).charAt(1);
				h3 += (cast(chords[currchord],String)).charAt(2);
				rhythmEnergy = getEnergyAt(rhythms, i + start);
				if (rhythmEnergy >= rhythms.length) {
					currchord = roulette(getCol(chordprog, currchord), FlxRandom.float());
					chordprog[currchord][oldchord]++;
					oldchord = currchord;
				}
				else {
					h1 += '&';
					h2 += '&';
					h3 += '&';
				}
			}
			h1 += '; ';
			h2 += '; ';
			h3 += '; ';
			//trace(Composer.arrayProb(Composer.getCol(chordprog, 1)));			
			return h1 + h2 + h3;
		}
		
		public static function nextNote(currnote:Int, lastLength:Int, vel:Int, acc:Int, rhythmEnergy:Int, i:Int):Int {
			var scale:String = 'cdefgab';
			var leap:Int = 0;
			//step or leap?
			if (i > 2 && i < 13 && Math.abs(vel) > 0 && FlxRandom.float() < rhythmEnergy && acc == 0) { //last note is 1 step higher/lower than previous note, can leap down/up
				leap = -vel * Math.floor(FlxRandom.float() * 4 + 2);					
				currnote += leap;					
			}
			else if (Math.abs(vel) > 1) { //Coming from a leap up/down, step down/up
				currnote -= Math.floor(vel / Math.abs(vel));					
			}
			else if (acc != 0) {
				 currnote += vel;
			}
			else { //Step
				if (currnote > (scale.length - 1) / 2 && FlxRandom.float() < 0.9) currnote -= Math.round(FlxRandom.float());
				else if (currnote < (scale.length - 1) / 2 && FlxRandom.float() < 0.9) currnote += Math.round(FlxRandom.float());
				else if (FlxRandom.float() < 0.9) currnote += vel;
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
			return currnote;
		}
		
		public static function makeMelodyBar(rhythms:Array<String>, seed:Float = 0, currnote:Int = 0):String {	
			
			var m:String = '';
			var scale:String = 'cdefgab';
			var oldernote:Int = 0;
			var oldnote:Int = 0;
			var vel:Int = 0;
			var acc:Int = 0;
			var open:Int = 0;

			var rhythmEnergy:Float = 0;
			var firstNote:Note = new  Note(currnote, 4, 8);
			var note:Note = firstNote;
			var size:Int = 8;
			
			var i:Int;
			for (i in 0...(size)) {
				if (note.length == 0) break;
				m += note.toString();
				if (note.cumlength >= 1) break;
				rhythmEnergy = Composer.getEnergyAt(rhythms, i * Math.round(16 / size)) / rhythms.length;
				oldnote = note.pitch;
				note = note.nextNote(rhythmEnergy);
				if (oldnote == note.pitch && FlxRandom.float() < 0.9) {					
					m += '&';
				}
			}
				//trace(m);
			
			/*for (i = 0; i < Math.abs(open); i++) {
				if (open < 0) m += '>';
				else if (open > 0) m += '<';
			}*/
			//m += '; '
			return m;
		}
		
		public static function makeMelodyBar2(rhythms:Array<String>, seed:Float = 0, currnote:Int = 0):String {
			
			var m:String = '';
			var scale:String = 'cdefgab';
			var oldernote:Int = 0;
			var oldnote:Int = 0;
			var vel:Int = 0;
			var acc:Int = 0;
			var open:Int = 0;
			var rhythmEnergy:Float = 0;
			var length:Int = 0;
			var i:Int;
			for (i in 0 ... (16)) {
				m += scale.charAt(currnote);
				if (i > 0 && scale.indexOf(m.charAt(m.length - 1)) >= 0 && FlxRandom.float() < 0.9){//Math.abs(i - 7.5) / 7.5) {					
					m += '&';
				}
				
				acc = (currnote - oldnote) - vel;
				vel = currnote - oldnote;
				rhythmEnergy = Composer.getEnergyAt(rhythms, i) / rhythms.length;
				oldnote = currnote;
				currnote = nextNote(currnote, length, vel, acc, Math.round(rhythmEnergy), i);
				if (oldnote == currnote) {
					length++;
				}
				else {
					length = 1;
				}
				
			}
			for (i in 0 ... Math.round(Math.abs(open))) {
				if (open < 0) m += '>';
				else if (open > 0) m += '<';
			}
			//m += '; '
			return m;
		}

		public static function makeMelody(rhythms:Array<String>, bars:Int = 4, time:Int = 100, eighth:Int = 2):String {			
			
			var start:Int = 64;// Math.floor(calcAccentInterval(rhythms)) + 64;
			//var scale:String = 'cdefgab';
			var scale:String = 'cdega';
			//var m:String = SiONVoice(presetVoice["valsound.guitar"][14]).getMML(1)+' t100 l8 v10 [r]' + start + ' %6 @1 ' + (FlxRandom.nextInt(127) + 0) + ' o5 $ [';			
			var m:String;
			var instruments:Array<Int> = new  Array<Int>();
			/*if (FlxRandom.float() < 0.5) {
			 * 
			 * //GUITAR
				var v:SiONVoice = new SiONVoice(presetVoice.categolies[4][Math.round(FlxRandom.float() * 17)]);
				m = v.getMML(255) + '\nt100 l8 v10 [r]' + start + ' %6 @255 o4 $ [';
				//m = v.getMML(255) + '\nt100 l8 v10 [r]' + start + ' %6 @255 o4 $ [';
			}
			else {*/
					
				//LEAD
				instruments = [0, 4, 6, 7, 8, 12, 15, 16, 17, 19, 24, 29, 31, 33, 34, 35, 36, 38, 40, 41];
				//var v:SiONVoice =  new SiONVoice(presetVoice.categolies[5][instruments[Math.round(FlxRandom.float() * (instruments.length - 1))]]);
				var v:SiONVoice =  presetVoice.categolies[5][instruments[Math.round(FlxRandom.float() * (instruments.length - 1))]];
				m = v.getMML(255) + '\nt'+ time +' l8 v10 [r]' + start + ' %6 @255 o'+ eighth +' $ [';
				//m = v.getMML(255) + '\nt100 l8 v10 [r]' + start + ' %6 @255 o4 $ [';
				
				//trace(presetVoice.categolies[5].name,presetVoice.categolies[5][instruments[Math.round(FlxRandom.float() * (instruments.length - 1))]].name);
			//}
			var currnote:Int = 0;
			var i:Int;
			for (i in 0 ...( bars)) {
				//if (i > 0) {
				//	currnote = scale.indexOf(m.charAt(m.length - 2));
				//}
				m += makeMelodyBar(rhythms, (FlxRandom.globalSeed + 1) * (i + 1), currnote) + ' ';				
			}
			//m = m.replace(/[a-z](\d*) $/g, "c$1");
			/*if (m.slice( -2) == '16') {
				//trace("aham");
				m = m.slice(0, -2);
				m += ']4 c r16[r]' + (start - 2) + ';';
			}
			else {*/
				m += ']4 c&c&c&c [r]' + (start-4) + ';';
			//}
			return m + ' //Melody';
		}
		
		public static function makeMelody2(rhythms:Array<String>, size:Int=100):String {
			
			var start:Int = Math.floor(calcAccentInterval(rhythms));
			var m:String = '[r]' + start + '%1 l16 o5 $ ';
			var scale:String = 'cdefgab';
			var oldernote:Int = 0;
			var oldnote:Int = 0;
			var currnote:Int = 0;
			var open:Int = 0;
			var rhythmEnergy:Int = 0;
			var i:Int;
			for (i in 0 ... (size)) {
				rhythmEnergy = getEnergyAt(rhythms, i + start);
				if (scale.indexOf(m.charAt(m.length - 1)) >= 0 && FlxRandom.float() < 0.5) {
					m += '&';
				}
				m += scale.charAt(currnote);
				oldernote = oldnote;
				oldnote = currnote;
				//step or leap?
				if (rhythmEnergy > 0) {
					
					if (oldnote - oldernote == 1 && rhythmEnergy >= rhythms.length) { //last note is 1 step higher than previous note, can leap down
						currnote -= Math.round(FlxRandom.float() * oldnote);					
					}
					else if (oldnote - oldernote == -1 && rhythmEnergy >= rhythms.length) { //last note is 1 step lower than previous note, can leap up
						currnote += Math.round(FlxRandom.float() * oldnote);					
					}
					else if (oldnote - oldernote > 1) { //Coming from a leap up, step down
						currnote--;
					}
					else if (oldnote - oldernote < -1) { //Coming from a leap down, step up
						currnote++;
					}
					else { //Step
						//currnote += Math.round(FlxRandom.nextNumber() * 2 - 1);
						//currnote += Math.round(FlxRandom.nextNumber() * (oldnote - oldernote) / Math.abs(oldnote - oldernote));	
						if (currnote > scale.length / 2 && FlxRandom.float() < 0.5) currnote -= Math.round(FlxRandom.float());
						else if (currnote < scale.length / 2 && FlxRandom.float() < 0.5) currnote += Math.round(FlxRandom.float());
						else currnote += Math.round(FlxRandom.float() * 2 - 1);
					}
					if (currnote < 0) {
						if (open <= -1) { //Lower limit octave
							currnote = 0;
						}
						else {
							currnote = scale.length + currnote;
							//m += '<';
							open--;
						}
					}
					else if (currnote >= scale.length) {
						if (open >= 1) { //Upper limit octave
							currnote = scale.length - 1;
						}
						else {
							currnote = currnote % scale.length;
							//m += '>';
							open++;
						}
					}
				}
			}
			for (i in 0 ... ((Math.round(Math.abs(open))))) {
				//if (open < 0) m += '>';
				//else if (open > 0) m += '<';
			}
			m += '; ';
			return m;
		}
	}

