module JavaMetrics::Volume

import IO;
import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;

int countCommentsInProject(loc project){
	M3 model = createM3FromEclipseProject(project);
	list[loc] classes = toList(classes(model));
	int numberOfLines = 0;
	for(c <- classes){
		src = readFileLines(c);
		numberOfLines += getSingleComments(src) + getMultiComments(src);
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
	list[str] comments = getSingleComments(src) + getMultiComments(src);
	return size(src) - size(blanks) - size(comments);	
}

list[str] getSingleComments(list[str] src){
	str single = "//";
	return for(str line <- src)
		if( /\s*<single>/ := line)
			append line;
}

list[str] getMultiComments(list[str] src){
	str multiStart = "/*";
	list[str] result = [];
	int i = 0;
	for(line <- src){
		if(/^\s*<multiStart>/ := line){
			list[str] cmt = getRestOfBlock(src[i+1..]);
			result += line;
			result += cmt;
		}
		i = i + 1;
	}
	return result;
}

list[str] getRestOfBlock(list[str] src){
	str multiEnd = "*/";
	str multiStart = "/*";
	str single = "//";
	int i = 0;
	return for(line <- src){
		// ignore nested comments
		if(/^\s*<multiStart>/ := line){
			break;
		}
		if(/^\s*$/ := line || /^\s*<single>/ := line){
			continue;
		}
		append line;
		// Stop when end symbol was found in a line.
		if(/<multiEnd>/ := line){
			break;
		}
	}
}
