module JavaMetrics::Duplication

import JavaMetrics::SourceTransformer;
import lang::java::jdt::m3::AST;
import Prelude;
import util::Math;
import Map;
import JavaMetrics::Volume;
import JavaMetrics::Helpers;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import Exception;

int code_Duplication(list[list[int]] filesinstr, int totalLinesOfCode, list[str] methodNames) {
	list[loc] sourceLocs = getLocs();
	list[tuple[int,int,int]] duplicatedparts = [];
	int possibleDuplicate = 0;
	int duplication = 0;
	int fstposition = -1;
	int lstposition = -1;
	int sourceSize = size(filesinstr);
	
	rel[int, int] relatedMethods = {};
	 
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
						
						relatedMethods += <i, j>;
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
	list[tuple[real,int]] tryit = [];
	for (tuple[int f,int x,int y] dup<-duplicatedparts) {
		tryit = addInAMap(dup.f,dup.x,dup.y,tryit);
		numberofduplicatedcode = numberofduplicatedcode + dup.y - dup.x + 1;
	}
	if(!isEmpty(tryit)){
		makeBarGraph(tryit, sourceLocs);
	}
	if(!isEmpty(tryit)){
		makeRelationGraph(relatedMethods, sourceLocs, methodNames);
	}
	return numberofduplicatedcode;
	
}

private list[tuple[real,int]] addInAMap(f,x,y,list[tuple[real,int]] tryit) {
	for (tuple[real b,int a] t<-tryit) {
		if (t.a==f) {
			tryit=tryit-t;
			tryit += <t.b+y-x+1.0,f>;
			return tryit;
		}
	}
	return (tryit+<y-x+1.0,f>);
}

private void makeBarGraph (tryit,locationsMethods) {
	tuple[real a,int b] h=max(tryit);
	tryit = tryit -h;
	tryit = reverse(sort(tryit));
	list[Figure] b1 =[box(vshrink(h.a/h.a),
		mouseOver(text("<toInt(h.a)>")), 
		onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
			edit(locationsMethods[h.b]);
			return true;
		}),
		fillColor("Red"))];
		
	for (tuple[real b,int a] t<-tryit) {
		b1 += box(vshrink(t.b /h.a),
			mouseOver(text("<toInt(t.b)>")),
			onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
				edit(locationsMethods[t.a]);
				return true;
			}),
			fillColor("Red"));
		
	}
	b0 = box(hcat(b1,std(bottom())), fillColor("lightGray"));
	render(b0);
}

private void makeRelationGraph(rel[int x, int y] methodIndex, list[loc] methodLocs, list[str] methodNames){
	set[int] seenNodes = {};
	list[Figure] nodes = [];
	list[Edge] edges = [];
	for(<x, y> <- methodIndex){
		idX = toString(x);
		idY = toString(y);
		if(!(x in seenNodes)){
			str name = methodNames[x];
			loc methodLoc = methodLocs[x];
			nodes += box(
				text(name),
				id(idX),
				onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
					edit(methodLoc);
					return true;
				}), 
				fillColor("lightGray")
			);
			seenNodes += x;
		}
		if(!(y in seenNodes)){
			str name = methodNames[y];
			loc methodLoc = methodLocs[x];
			nodes += box(
				text(name),
				id(idY),
				onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
					edit(methodLoc);
					return true;
				}), 
				fillColor("lightGray")
			);
			seenNodes += y;
		}
		edges += edge(idX, idY);
	}
	render(graph(nodes, edges, hint("layered"), gap(50)));
}