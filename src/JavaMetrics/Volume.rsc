module JavaMetrics::Volume

import JavaMetrics::SourceTransformer;
import IO;
import Prelude;
import lang::java::jdt::m3::Core;
import util::ValueUI;

str totalSource = "";

int countLinesInProject(loc project){
	M3 projectModel = createM3FromEclipseProject(project);
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
	totalSource += intercalate("\r\n", pureSrc);
	return pureSrc;
}

lrel[str location, int size] countUnitLines(loc project){
	M3 projectModel = createM3FromEclipseProject(project);
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
		append <unifyLocation(m), size(filterBlankLines(splitLines(src)))>;
	}
}

void example(){
	loc p = |project://smallsql0.21_src|;
	//println(countLinesInProject(p));
	text(sort(countUnitLines(p), bool(a, b){ return a[1] < b[1]; }));
}
