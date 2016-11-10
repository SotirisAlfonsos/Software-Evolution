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
		inBlock = inBlock || /<blockStart>/ := endParts[-1];
		inBlock = inBlock && !(/<blockEnd>/ := startParts[-1]);
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

str stringConcat([], str _) = "";
str stringConcat([str x, *str xs], str delim) = x + delim + stringConcat(xs, delim);

void debug(){
	loc mainClass = |project://MetricTest/src/Main.java|;
	list[str] srcLines = readFileLines(mainClass);
	//println(getSingleComments(srcLines));
	println(stringConcat(getAllComments(srcLines), "\r\n"));
}

void debug2(){
	line = "/* test */";
	str blockStart = "/*";
	str blockEnd = "*/";
	str single = "//";
	list[str] startParts = split(blockStart, line);
	list[str] endParts = split(blockEnd, line);
	println(startParts);
	println(endParts);
	println(/^<blockStart>/ := line);
	println(/<blockEnd>$/ := line);
	println(isSingleComment(endParts[-1]));
}
