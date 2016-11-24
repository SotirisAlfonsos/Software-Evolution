module JavaMetrics::Volume

import JavaMetrics::SourceTransformer;
import lang::java::jdt::m3::Core;
import IO;
import Prelude;
import util::Math;

// save method sources for code duplication analysis
list[list[str]] totalSource = [];

list[list[str]] getSource(){
	return totalSource;
}

int countLinesInProject(M3 projectModel){
	set[loc] fs = files(projectModel);
	list[str] lines = [];
	int sourceSize = size(fs);
	int i = 0;
	for(f <- fs){
		print("<precision(toReal(i * 100) / sourceSize, 3)>%     \r");
		lines += countLinesInFile(f);
		i += 1;
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
	totalSource = []; // empty aggregated source
	lrel[loc, int] counts = [];
	int sourceSize = size(fs);
	int i = 0;
	for(f <- fs){
		print("<precision(toReal(i * 100) / sourceSize, 3)>%     \r");
		counts += <f.mloc, countLinesInMethod(f)>;
		i += 1;
	}
	return counts;
}

map[loc, M3] fileModels = ();
void generateFileModels(set[loc] methodLocations){
	set[loc] fileLocations = {|file://<l.path>| | l <- methodLocations};
	int sourceSize = size(fileLocations);
	int i = 0;
	for(floc <- fileLocations){
		if(!(floc in fileModels)){
			print("Preprocessing: <precision(toReal(i * 100) / sourceSize, 3)>%     \r");
			fileModels[floc] = createM3FromFile(floc);
		}
		i += 1;
	}
	println("Preprocessing: 100%     ");
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
