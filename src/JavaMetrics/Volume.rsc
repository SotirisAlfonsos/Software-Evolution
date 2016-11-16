module JavaMetrics::Volume

import JavaMetrics::SourceTransformer;
import IO;
import Prelude;
import lang::java::jdt::m3::Core;
import util::ValueUI;

int countLinesInProject(loc project){
	M3 projectModel = createM3FromEclipseProject(project);
	set[loc] fs = files(projectModel);
	int lines = 0;
	for(f <- fs){
		lines += countLinesInFile(f);
	}
	return lines;
}

int countLinesInFile(loc file){
	str src = removeComments(file);
	return size(filterBlankLines(splitLines(src)));
}

lrel[loc, int] countUnitLines(loc project){
	M3 projectModel = createM3FromEclipseProject(project);
	set[loc] fs = files(projectModel);
	lrel[loc, int] counts = [];
	for(f <- fs){
		counts += countLinesInMethods(f);
	}
	return counts;
}

lrel[loc, int] countLinesInMethods(loc file){
	M3 fileModel = createM3FromFile(file);
	set[loc] ms = methods(fileModel);
	return for(m <- ms){
		str src = readFile(m);
		for(commentLoc <- fileModel@documentation<comments>){
			comment = readFile(commentLoc);
			src = replaceFirst(src, comment, "");
		}
		append <m, size(filterBlankLines(splitLines(src)))>;
	}
}

void example(){
	loc p = |project://smallsql0.21_src|;
	//println(countLinesInProject(p));
	text(sort(countUnitLines(p), bool(a, b){ return a[1] < b[1]; }));
}
