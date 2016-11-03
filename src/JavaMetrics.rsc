module JavaMetrics

import IO;
import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;

M3 getModel(loc p){
	return createM3FromEclipseProject(p);	
}

Declaration getAst(loc p){
	return createAstFromFile(p, true);
}

int countLines(list[str] src){
	list[str] blanks = [line | line <- src, /^\s*$/ := line];
	list[str] comments = getSingleComments(src) + getMultiComments(src);
	println(comments);
	return size(src) - size(blanks) - size(comments);	
}
list[str] getSingleComments(list[str] src){
	str single = "//";
	return for(str line <- src)
		if( /\s*<single>/ := line)
			append line;
}

list[str] getMultiComments([]) = [];
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

int getLOC(M3 model){
	// still include empty lines and comments.
	int LoC = 0;
	for(loc c <- classes(model)){
		str src = readFile(c);
		LoC += (1 | it + 1 | /\r\n/ := src); // start at one to include last line.
	}
	return LoC;
}

void main(){
	loc project = |project://MetricTest/|;
	M3 model = getModel(project);
	list[loc] cs = toList(classes(model));
	n = 0;
	for(c <- cs){
		src = readFileLines(c);
		n += countLines(src);
	}
	println("<project> has <n> lines of code.");
	
}

