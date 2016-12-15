module JavaMetrics::Volume

import JavaMetrics::SourceTransformer;
import JavaMetrics::Hashing;
import JavaMetrics::Helpers;
import lang::java::jdt::m3::Core;
import IO;
import Prelude;
import util::Math;

// save method sources for code duplication analysis
list[list[str]] totalSource = [];
list[list[int]] sourceHashes = [];
list[list[int]] linesOfCode = [];
list[loc] sourceLocs = [];

list[list[str]] getSource(){
	return totalSource;
}

list[list[int]] getHashes(){
	return sourceHashes;
}

list[list[int]] getLinesOfCode(){
	return linesOfCode;
}

list[loc] getLocs(){
	return sourceLocs;
}

int countLinesInProject(loc projectDir){
	list[loc] fs = crawl(projectDir, ".java");
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

lrel[loc location, int size] countUnitLines(set[loc] methodLocations){
	rel[loc mloc, loc floc] fs = { <l, |<l.scheme>://<l.authority><l.path>|> | l <- methodLocations };
	generateFileModels(fs<floc>);
	totalSource = []; // empty aggregated source
	sourceLocs = [];
	sourceHashes = [];
	linesOfCode = [];
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

map[loc floc, M3 model] fileModels = ();
void generateFileModels(set[loc] methodLocations){
	set[loc] fileLocations = {|project://<l.authority><l.path>| | l <- methodLocations};
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
	int lineN = 0;
	list[int] lineNumber = [];
	loc file = |project://<methodFile.floc.authority><methodFile.floc.path>|; 
	loc method = file(methodFile.mloc.offset, methodFile.mloc.length);
	M3 fileModel = fileModels[file];
	str src = readFile(method);
	for(commentLoc <- fileModel@documentation<comments>){
		comment = readFile(commentLoc);
		src = replaceFirst(src, comment, "");
	}
	//visit(methodFile.mloc) {
	//	case \variable x : println(x);
	//}
	list[str] srcLines = filterBlankLines(splitLines(src));
	srcLines = mapper(srcLines, trim);
	//srcLines = removeSimpleLines(srcLines);
	
	list[str] srcL = [];
	list[int] srcHashes = [];
	for(l <- srcLines){
		lineN += 1;
		if ( /^\}$/ := l || /^\{$/ := l ) continue;
		srcL += l; 
		srcHashes += hashSimple(l);
		lineNumber += lineN;
	}
	//list[int] srcHashes = mapper(srcLines, hashSimple);
	sourceHashes += [srcHashes];
	linesOfCode += [lineNumber];
	totalSource += [srcL];
	
	sourceLocs += method;
	return size(srcLines);
}