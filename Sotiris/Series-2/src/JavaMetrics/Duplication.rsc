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
	list[loc] methodLocs = getLocs();
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
	
	int numberofduplicatedcode = 0;
	map[int, int] methodCounts = ();
	int maxCount = 0;
	list[tuple[real,int,loc]] dupLines = [];
	list[tuple[real,int,loc]] tryit = [];
	for (tuple[int fileNumber,int beginLine,int endLine] dup<-duplicatedparts) {
		loc blockLocation = getActualLines (dup.fileNumber, dup.beginLine, dup.endLine);
		methodCounts[dup.fileNumber] = dup.endLine - dup.beginLine + 1;
		dupLines += <methodCounts[dup.fileNumber] + 0.0, dup.fileNumber, blockLocation>;
		numberofduplicatedcode = numberofduplicatedcode + methodCounts[dup.fileNumber];
		
		if(methodCounts[dup.fileNumber] > maxCount) maxCount = methodCounts[dup.fileNumber];
	}
	println("Rendering graphs...");
	if(!isEmpty(dupLines)){
		makeBarGraph(dupLines);
	}
	if(!isEmpty(dupLines)){
		makeRelationGraph(relatedMethods, methodLocs, methodNames, methodCounts, maxCount);
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

private void makeBarGraph (dupLines) {
	tuple[real size, int fileNumber, loc locRef] biggest = max(dupLines);
	dupLines = reverse(sort(dupLines));
	b1 = [];
	int counter = 0;
	for (<dupSize, file, locRef> <- dupLines) {
		loc location = locRef;
		b1 += box(
			// shrink relative to max size
			vshrink(dupSize / biggest.size),
			//set min-height to 15
			hsize(15),
			// show size on hover
			mouseOver(text("<toInt(dupSize)>")),
			// goto location on click
			onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
				edit(location);
				return true;
			}),
			fillColor("red")
		);
	}
	Figure chart = box(hcat(b1, std(bottom())), fillColor("lightGray"));
	render("Duplication count per method", chart);
}

private void makeRelationGraph(rel[int x, int y] methodIndex, list[loc] methodLocs, list[str] methodNames, map[int, int] methodCounts, int maxCount){
	set[int] seenNodes = {};
	list[Figure] nodes = [];
	list[Edge] edges = [];
	for(<x, y> <- methodIndex){
		str idX = toString(x);
		str idY = toString(y);
		if(!(x in seenNodes)){
			str name = methodNames[x];
			loc methodLoc = methodLocs[x];
			int cloneSize = methodCounts[x];
			Color c = calculateColor(0, maxCount, cloneSize);
			nodes += box(
				text(name, fontColor("white")),
				id(idX), 
				onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
					edit(methodLoc);
					return true;
				}), 
				fillColor(c)
				);
			seenNodes += x;
		}
		if(!(y in seenNodes)){
			str name = methodNames[y];
			loc methodLoc = methodLocs[y];
			int cloneSize = methodCounts[y];
			Color c = calculateColor(0, maxCount, cloneSize); 
			nodes += box(
				text(name, fontColor("white")),
				id(idY), 
				onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
					edit(methodLoc);
					return true;
				}),
				fillColor(c)
				);
			seenNodes += y;
		}
		edges += edge(idX, idY);
	}
	Figure legend = createHeatmapLegend();
	Figure graph  = graph(nodes, edges, hint("layered"), gap(15));
	Figure graphWithLegend = hcat([legend, graph], gap(25));
	render("Relation graph", graphWithLegend);
	renderSave(graphWithLegend, |project://Series-2/output/relationGraph.png|);
}

private Figure createHeatmapLegend(int mapSize = 50){
	list[Figure] boxes = [];
	FProperty boxSize = size(10, 3);
	for(i <- [mapSize..-1]){
		Color c = calculateColor(0, mapSize, i);
		Figure b = box(
			fillColor(c),
			lineColor(c),
			boxSize
		);
		boxes += b;
	}
	return vcat(boxes, left());
}
private Color calculateColor(num minimum, num maximum, num val){
	<mini, maxi> = <minimum + 0.0, maximum + 0.0>;
	ratio = 2 * (val - mini) / (maxi - mini);
	int red   = toInt(max([0, 255 * (ratio - 1)]));
	int blue  = toInt(max([0, 255 * (1 - ratio)]));
	int green = 255 - blue - red;
	return rgb(red, green, blue); 
}

private loc getActualLines (fileNumber, startline, endline) {
	list[str] duplLines = []; 
	
	list[list[str]] storedLines = getSource();
	list[loc] locationLines = getLocs();
	duplLines = storedLines[fileNumber];
	
	loc methodLocation = locationLines[fileNumber];
	list[str] actualLines = readFileLines(methodLocation);

	int actStart = 0;
	int actEnd = 0;
	int counter = startline;

	for (<i, actLines> <- enumerate(actualLines[startline..], i=startline)) {
		str testi = escape(duplLines[counter], ("{": "", "}": ""));
		if ( /.*<testi>.*/ := actLines) {
			if (counter == startline) actStart = i;
			else if (counter == endline) { actEnd = i; break;}
			counter += 1;
		}else if (counter > 0) {
			for (dLines <- duplLines[counter+1..size(duplLines)]) {
				dLines = escape(dLines, ("{": "", "}": ""));
				if (/.*<dLines>.*/ := actLines) {
					counter=startline;
					break;
				}
			}
		}
	}
	int charsBeforeBlock = methodLocation.offset;
	int charsWithBlock = 0;
	for (<j, line> <- enumerate(actualLines)) {
		if (j < actStart) {
			// + 2 for \r\n
			charsBeforeBlock += size(line) + 2; 
		} else if(j <= actEnd) {
			// + 2 for \r\n
			charsWithBlock += size(line) + 2;
		} else{
			break;
		}
	}
	return methodLocation(charsBeforeBlock, charsWithBlock);
}