module JavaMetrics::SourceTransformer

import lang::java::jdt::m3::Core;
import Prelude;

list[str] splitLines(str source) = split("\n", source);
str concatLines(list[str] source) = intercalate("\n", source);
list[str] filterBlankLines(list[str] source) = [l | l <- source, !(/^\s*$/ := l)];

str removeComments(loc file){
	str src = readFile(file);
	M3 model = createM3FromFile(file);
	list[str] comments = mapper(toList(model@documentation<comments>), readFile);
	for(comment <- comments){
		src = replaceFirst(src, comment, "");
	}
	return src;
}