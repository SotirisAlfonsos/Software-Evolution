module Assignment1

import IO;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::ValueUI;
import Set;
import List;
import Map;

public int counterInsideComment;


public void Volume_calc() {
	int lineCount = 0;
	myModel = createM3FromEclipseProject(|project://test-project|);	
	set[loc] lo = { l | <l,class(l,_)> <- myModel@types};
	for (loc i <- lo ) {
		int lineNum = 0;
		counterInsideComment = 0;
		for (str st <- readFileLines(i)) {
			int temp = countInLine1(st);
			lineNum = lineNum + temp;
		}
		lineCount = lineCount + lineNum;
	}
	println (lineCount);
}

public int countInLine1(str S){
  int count=0;
  if ( /^[\t\n\r\ ]*\/\*+/ := S) {
  		count = 0;
  		counterInsideComment = 1;
  } else if ( /\*+\/+/ := S && counterInsideComment == 1) {
  		count = 0;
  		counterInsideComment = 0;
  } else if ( /^[\t\n\r\ ]*\/+\/+/ := S ) {
  		count = 0;
  }else if (counterInsideComment == 0) {
  		if ( /[\t\n\r\ ]*\/\*+/ := S) {
  			counterInsideComment = 1;
  		}
  		if ( !(/^[\t\n\r\ ]*$/ := S) ) {
	  		count = 1;
  		}
  }
 
  return count;
}

public void Cyclomatic_Complexity() {
		set[tuple[str,str]] cc = {};
		myModel = createM3FromEclipseProject(|project://test-project|);
		
		for (i <- methods(myModel) ) {
		
			int lineNum = 0;
			counterInsideComment = 0;
			for (str st <- readFileLines(i)) {
				int temp = countInLine1(st);
				lineNum = lineNum + temp;
			}
			str risk = calcRisk(lineNum);
			cc = cc + <i.path,risk>;
		}
		for (i<-cc) {
			println(i);
		}
}

public str calcRisk(int lineNum) {
	if (lineNum <= 10) {
		return("without much risk");
	} else if (lineNum <= 20) {
		return("moderate risk");
	}
}
