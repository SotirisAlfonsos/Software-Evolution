module JavaMetrics::Duplication

import JavaMetrics::SourceTransformer;
import lang::java::jdt::m3::Core;
import Prelude;
import util::Math;
import Map;
import JavaMetrics::Volume;
import JavaMetrics::Helpers;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import Exception;

int code_Duplication(list[list[int]] filesinstr, int totalLinesOfCode) {
	list[loc] sourceLocs = getLocs();
	list[tuple[int,int,int]] duplicatedparts = [];
	int possibleDuplicate =0;
	int duplication=0;
	int fstposition=-1;
	int lstposition=-1;
	int sourceSize = size(filesinstr);
	 
	for (int i <- [0..sourceSize]) {
		print("<precision(toReal(i * 100) / sourceSize, 3)>%     \r");
		list[int] fileone = filesinstr[i];
		for (int x <- [0..size(fileone)]) { 
			if (size(fileone) - x < 6){
				break;
			}
			
			fstposition = -1;
			list[int] bl = fileone[x .. x+6];
			for (int j <- [i..size(filesinstr)]) {
				list[int] filetwo = filesinstr[j];
				if (size(filetwo) < 6 || [_*, bl, _*] !:= filetwo){
					continue;
				}
				// position of line x in file two
				fstposition = indexOf(filetwo, fileone[x]);
				// if the matching line is the line itself (same file)
				if (i == j && x == fstposition){
					// search the rest of the file for a match
					int tempfstposition = indexOf(filetwo[(fstposition + 1)..], fileone[x]);

					if (tempfstposition == -1) fstposition = -1;
					else fstposition = fstposition + 1 + tempfstposition;
				}
				if (fstposition == -1 || fstposition >= size(fileone) - 1) {
					// if match position is invalid, search for match in next file
					continue;
				}
				do { 
					int temp = x; // position of matching line in fileone
					int temp2 = fstposition; // position of matching line in filetwo
					
					int startstri = x;
					int startstry = fstposition;
					
					// find whole matching block
					while (
					 temp < size(fileone)
					 && temp2 < size(filetwo)
					 && fileone[temp] == filetwo[temp2] 
					) {
						temp  = temp + 1;
						temp2 = temp2 + 1;
											
						possibleDuplicate = possibleDuplicate + 1;
					}
					int endstri = temp - 1;
					int endstry = temp2 - 1;
					
					// check if duplicates were found before
					// otherwise add them
					bool flagPrevDup = false;
					bool flagPrevDup2 = false;
					if (possibleDuplicate >= 6) {
						for (tuple[int f, int xi, int yi] dup <- duplicatedparts) {
							flagPrevDup  = flagPrevDup  || (startstri >= dup.xi && endstri <= dup.yi && dup.f == i);
							flagPrevDup2 = flagPrevDup2 || (startstry >= dup.xi && endstry <= dup.yi && dup.f == j);
						}
						if (flagPrevDup && flagPrevDup2);
						else if (flagPrevDup){
							duplicatedparts = duplicatedparts + <j, startstry, endstry>;
						}
						else if (flagPrevDup2){
							duplicatedparts = duplicatedparts + <i, startstri, endstri>;
						}
						else{
							duplicatedparts = duplicatedparts + <i, startstri, endstri> + <j, startstry, endstry>;
						}
						
					}
					possibleDuplicate = 0;
					
					// find next match between files
					int tempfstposition = indexOf(filetwo[(fstposition+1)..], fileone[x]);
					
					if (tempfstposition != -1) fstposition = fstposition + 1 + tempfstposition;
					else fstposition=-1;
					
					if (i == j && x == fstposition){
						int tempfstposition = indexOf(filetwo[(fstposition+1)..], fileone[x]);
								
						if (tempfstposition == -1) fstposition = -1;
						else fstposition = fstposition + 1 + tempfstposition;
					}
				}while (fstposition != -1 && fstposition < size(filesinstr) - 1);
			}
		}
	}
	
	int numberofduplicatedcode =0;
	list[int] actualFileLineLoc = [];
	list[loc] locationsMethods = getLocs();
	list[loc] newLocs = [];
	list[tuple[real,int,loc]] dupLines = [];
	list[tuple[real,int,loc]] tryit = [];
	for (tuple[int f,int x,int y] dup<-duplicatedparts) {
		actualFileLineLoc = getActualLines (dup.f, dup.x, dup.y);
		println(actualFileLineLoc);
		dupLines += <dup.y - dup.x + 1.0, dup.f, locationsMethods[dup.f](actualFileLineLoc[2],actualFileLineLoc[3])>;
		//locationsMethods[dup.f](actualFileLineLoc[2],actualFileLineLoc[3]);
		//tryit = addInAMap(dup.f, dup.x, dup.y, tryit, l );
		numberofduplicatedcode = numberofduplicatedcode + dup.y - dup.x + 1;
	}
	if(!isEmpty(dupLines)){
		makeGraph(dupLines);
	}
	return numberofduplicatedcode;
	
}

private list[tuple[real,int,loc]] addInAMap(f,x,y,list[tuple[real,int,loc]] tryit, loc locationRefact) {
	for (tuple[real b,int a, loc _] t<-tryit) {
		if (t.a==f) {
			tryit=tryit-t;
			tryit += <t.b+y-x+1.0,f,locationRefact>;
			return tryit;
		}
	}
	return (tryit+<y-x+1.0, f, locationRefact>);
}

private void makeGraph (dupLines) {
	tuple[real a,int b, loc locRef] h=max(dupLines);
	dupLines = dupLines -h;
	dupLines = reverse(sort(dupLines));
	list[Figure] b1 =[box(vshrink(h.a/h.a),
		mouseOver(text("<toInt(h.a)>")), 
		onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
			edit(h.locRef);
			return true;
		}),
		fillColor("Red"))];
	int counter = 1;
	for (tuple[real b,int a,loc locRef] t<-dupLines) {
		b1 += box(vshrink(t.b /h.a),
			mouseOver(text("<toInt(t.b)>")),
			onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
				edit(t.locRef);
				return true;
			}),
			fillColor("Red"));
		
	}
	b0 = box(hcat(b1,std(bottom())), fillColor("lightGray"));
	render(b0);
}

rel[loc, loc] relatedMethods(list[loc] sourceLocs, list[list[value]] sourceLines){
	map[tuple[int, int], bool] mapping = ();
	for(<i, xs> <- enumerate(sourceLines)){
		for(<j, ys> <- enumerate(sourceLines[i+1..])){
			if(i == j) continue;
			key = <i, j>;
			if(key in mapping) continue;
			mapping[key] = compareLines(xs, ys);
		} 
	}
	rs = {};
	for(<i,j> <- mapping){
		if(mapping[<i,j>]){
			rs += <sourceLocs[i], sourceLocs[j]>;
		}
	} 
	return rs;
}

bool compareLines(list[value] xs, list[value] ys){
	for(x <- xs){
		for(y <- ys){
			if(x == y) return true;
		}
	}
	return false;
}

private list[int] getActualLines (fileNumber, startline, endline) {
	list[str] duplLines = []; 
	
	list[list[str]] storedLines = getSource();
	list[loc] locationLines = getLocs();
	duplLines = storedLines[fileNumber];
	list[str] actualLines = readFileLines(locationLines[fileNumber]);

	int actStart =0;
	int actEnd =0;
	int counter =startline;
	int i =0;
	//do {
	for (actLines<-actualLines) {
			

			str testi = escape(duplLines[counter], ("{": "", "}": ""));
			//println("<testi>   <actLines>");
			if ( /.*<testi>.*/ := actLines) {
				//println("<i> hi");
				if (counter == 0) actStart = i;
				else if (counter == endline) { actEnd = i; break;}
				counter += 1;
				//break;
			}else if (counter>0) {
				for (dLines <- duplLines[counter+1..size(duplLines)]) {
					//println("<dLines>   <actLines>");
					dLines = escape(dLines, ("{": "", "}": ""));
					if (/.*<dLines>.*/ := actLines) {
						counter=startline;
						break;
					}
				}
			}
		i += 1;
	}
	int charsBeforeBlock =0;
	int charsWithBlock =0;
	int j =0;
	for (charcount <- actualLines) {
		if (j<actStart) {
			println(size(charcount));
			charsBeforeBlock += size(charcount);
			charsWithBlock += size(charcount);
		} else if(j<actEnd) {
			charsWithBlock += size(charcount);
			
		}else break;
		j += 1;
	}
	//}while(counter==size(dupLines));
	return [actStart, actEnd, charsBeforeBlock, charsWithBlock-charsBeforeBlock];
}