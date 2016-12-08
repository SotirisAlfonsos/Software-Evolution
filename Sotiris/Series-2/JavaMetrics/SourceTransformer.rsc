module JavaMetrics::SourceTransformer

import lang::java::jdt::m3::Core;
import Prelude;
import IO;
import util::Math;

list[str] splitLines(str source) = split("\n", source);
str concatLines(list[str] source) = intercalate("\n", source);
list[str] filterBlankLines(list[str] source) = [l | l <- source, !(/^\s*$/ := l)];

list[str] simpleChars = split(" ", "{ } ( ) [ ]");
list[str] removeSimpleLines(list[str] source) = [ l | l <- source, !(/^[<simpleChars>]$/ := trim(l)) ];

str removeComments(loc file){
	str src = readFile(file);
	M3 model = createM3FromFile(file);
	list[str] comments = mapper(toList(model@documentation<comments>), readFile);
	for(comment <- comments){
		src = replaceFirst(src, comment, "");
	}
	return src;
}

str unifyLocation(loc l){
	str file = "";
	if(l.scheme == "java+compilationUnit"){
		file = l.file;
	} else if (/java\+(constructor|method)/ := l.scheme){
		file = l.parent.file + ".java";
	} else {
		throw Exception("Unsupported scheme");
	}
	return "<file>+<toString(hash(readFile(l)))>";
}
