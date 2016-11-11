module JavaMetrics::Volume

import IO;
import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;

rel[loc, int] countSourceLinesPerMethod(loc project){
	M3 model = createM3FromEclipseProject(project);
	ms = toList(methods(model));
	rel[loc, int] methodCounts = {};
	for(m <- ms){
		src = readFileLines(m);
		methodCounts += <m, countSourceLines(src)>;
	}
	return methodCounts;
}

int countLinesInProject(loc project){
	M3 model = createM3FromEclipseProject(project);
	set[loc] files = files(model);
	return sum(mapper(files, countLinesInFile));
}

int countLinesInFile(loc file){
	// remember which lines are already looked at (multiple comments per line) !!
	str single = "//";
	str blockStart = "/*";
	str blockEnd = "*/";
	
	// filter blank ( lines
	int total = size([l | l <- readFileLines(file), !(/^\s*$/ := l)]);
	int commentCount = 0;
	
	M3 model = createM3FromFile(file);
	rel[loc definition, loc comments] docs = model@documentation;
	set[int] commentLines = {};
	set[int] codeLines = {};
	
	for(<_, cloc> <- docs){
		bool isSingle = /^<single>/ := readFile(cloc);
		bool startOfLine = cloc.begin.column == 0;
		loc beginLine = getStartOfLine(cloc);
		str beginSrc = trim(readFile(beginLine)); 
		
		if(startOfLine || (/^<blockStart>/ := beginSrc) || (/^<single>/ := beginSrc) || beginSrc == ""){
			commentLines += cloc.begin.line;
		}
		if(isSingle) continue;
		// else it's a block comment
		
		loc endLine = getEndOfLine(cloc);
		str endSrc = trim(readFile(endLine));
		
		// add comment body
		// don't count first and last line
		if(cloc.begin.line != cloc.end.line){
			commentLines += { l | l <- [cloc.begin.line + 1 .. cloc.end.line] };
		}
		
		if((/^<blockStart>/ := endSrc) || (/^<single>/ := endSrc) || "" == endSrc){
			commentLines += cloc.end.line;
		} else {
			codeLines += cloc.end.line;
		}
	}
	return total - size(commentLines - codeLines);
}

loc getStartOfLine(loc line){
	int bc = line.begin.column;
	return line(line.offset - bc, bc);
}

loc getEndOfLine(loc line){
	// ugly way by fetching the whole file
	loc file = |<line.scheme>://<line.authority><line.path>|;
	list[str] lines = readFileLines(file);
	str src = lines[line.end.line - 1]; // line numbers start at 1
	int offset = line.offset + line.length;
	return line(offset, size(src) - line.end.column);
}

int countCommentsInProject(loc project){
	M3 model = createM3FromEclipseProject(project);
	list[loc] classes = toList(classes(model));
	int numberOfLines = 0;
	for(c <- classes){
		src = readFileLines(c);
		numberOfLines += size(getAllComments(src));
	}
	return numberOfLines;
}

int countSourceLinesInProject(loc project){
	M3 model = createM3FromEclipseProject(project);
	list[loc] classes = toList(classes(model));
	int numberOfLines = 0;
	for(c <- classes){
		src = readFileLines(c);
		numberOfLines += countSourceLines(src);
	}
	return numberOfLines;
}

int countLinesInProject(loc project){
	M3 model = createM3FromEclipseProject(project);
	list[loc] classes = toList(classes(model));
	int numberOfLines = 0;
	for(c <- classes){
		src = readFileLines(c);
		numberOfLines += countLines(src);
	}
	return numberOfLines;
}

int countSourceLines(list[str] src){
	list[str] blanks = [line | line <- src, /^\s*$/ := line];
	list[str] comments = getAllComments(src);
	return size(src) - size(blanks) - size(comments);	
}

// do not use this in conjunction with getBlockComments, 
// any single comments inside block comments will be returned
// by both!
list[str] getSingleComments(list[str] src){
	str single = "//";
	return [l | l <- src, /^\s*<single>/ := l];
}

list[str] getBlockComments(list[str] src){
	str blockStart = "/*";
	str blockEnd = "*/";
	str single = "//";
	bool inBlock = false;
	return for(l <- src){
		str line = trim(l);
		list[str] startParts = split(blockStart, line);
		list[str] endParts = split(blockEnd, line);
		if(size(startParts) == 0) continue;
		if(size(endParts) == 0) {
			if(inBlock) append line;
			inBlock = false;
			continue;
		}
		// already in block OR block start symbol
		inBlock = inBlock || /<blockStart>/ := endParts[-1];
		
		// already in block and no end block symbol after a start symbol
		inBlock = inBlock && !(/<blockEnd>/ := startParts[-1]);
		
		// 
		if(inBlock || (/^<blockStart>/ := line && (/<blockEnd>$/ := line || isSingleComment(endParts[-1])))){
			append line;
		}
	}
}

list[str] getAllComments(list[str] src){
	str blockStart = "/*";
	str blockEnd = "*/";
	str single = "//";
	bool inBlock = false;
	return for(l <- src){
		str line = trim(l);
		list[str] startParts = split(blockStart, line);
		list[str] endParts = split(blockEnd, line);
		if(size(startParts) == 0) continue;
		if(size(endParts) == 0) {
			if(inBlock) append line;
			inBlock = false;
			continue;
		}
		inBlock = inBlock || /<blockStart>/ := endParts[-1];
		inBlock = inBlock && !(/<blockEnd>/ := startParts[-1]);
		if(isSingleComment(line) || inBlock || (/^<blockStart>/ := line && (/<blockEnd>$/ := line || isSingleComment(endParts[-1])))){
			append line;
		}
	}
}

bool isSingleComment(str l, str single="//") = /^<single>/ := trim(l);
