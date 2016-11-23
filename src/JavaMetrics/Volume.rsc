module JavaMetrics::Volume

import JavaMetrics::SourceTransformer;
import IO;
import Prelude;
import lang::java::jdt::m3::Core;
import util::ValueUI;

// save method sources for code duplication analysis
list[list[str]] totalSource = [];

list[list[str]] getSource(){
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

lrel[loc location, int size] countUnitLines(list[loc] methodLocations){
	rel[loc mloc, loc floc] fs = { <l, |<l.scheme>://<l.path>|> | l <- methodLocations };
	generateFileModels(fs<floc>);
	lrel[loc, int] counts = [];
	for(f <- fs){
		counts += <f.mloc, countLinesInMethod(f)>;
	}
	text(sort(counts, bool(a, b){ return a[1] < b[1]; }));
	return counts;
}

map[loc, M3] fileModels = ();
void generateFileModels(set[loc] methodLocations){
	set[loc] fileLocations = {|file://<l.path>| | l <- methodLocations};
	for(floc <- fileLocations){
		if(!(floc in fileModels)){
			fileModels[floc] = createM3FromFile(floc);
		}
	}
}

int countLinesInMethod(tuple[loc mloc, loc floc] methodFile){
	M3 fileModel = fileModels[|file://<methodFile.floc.path>|];
	str src = readFile(|file://<methodFile.mloc.path>|(methodFile.mloc.offset, methodFile.mloc.length)); 
	for(commentLoc <- fileModel@documentation<comments>){
		comment = readFile(commentLoc);
		src = replaceFirst(src, comment, "");
	}
	list[str] srcLines = filterBlankLines(splitLines(src));
	totalSource += [mapper(srcLines, trim)];
	return size(srcLines);
}

void example(){
	loc p = |project://smallsql0.21_src|;
	text(sort(countUnitLines(p), bool(a, b){ return a[1] < b[1]; }));
}
