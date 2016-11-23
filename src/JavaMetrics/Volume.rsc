module JavaMetrics::Volume

import JavaMetrics::SourceTransformer;
import IO;
import Prelude;
import lang::java::jdt::m3::Core;
import util::ValueUI;

// save method sources for code duplication analysis
list[list[str]] totalSource = [];

list[str] getSource(){
	return totalSource;
}

int countLinesInProject(M3 projectModel){
	set[loc] fs = files(projectModel);
	list[str] lines = [];
	for(f <- fs){
		lines += countLinesInFile(f);
	}
	return size(lines);
}

list[str] countLinesInFile(loc file){
	str src = removeComments(file);
	list[str] pureSrc = filterBlankLines(splitLines(src));
	return pureSrc;
}

lrel[str location, int size] countUnitLines(M3 projectModel){
	set[loc] fs = files(projectModel);
	lrel[str, int] counts = [];
	for(f <- fs){
		counts += countLinesInMethods(f);
	}
	return counts;
}

lrel[str, int] countLinesInMethods(loc file){
	M3 fileModel = createM3FromFile(file);
	set[loc] ms = methods(fileModel);
	return for(m <- ms){
		str src = readFile(m);
		for(commentLoc <- fileModel@documentation<comments>){
			comment = readFile(commentLoc);
			src = replaceFirst(src, comment, "");
		}
		list[str] srcLines = filterBlankLines(splitLines(src));
		totalSource += [srcLines];
		append <unifyLocation(m), size(srcLines)>;
	}
}

void example(){
	loc p = |project://smallsql0.21_src|;
	//println(countLinesInProject(p));
	text(sort(countUnitLines(p), bool(a, b){ return a[1] < b[1]; }));
}
