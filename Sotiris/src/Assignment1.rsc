module Assignment1

import IO;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::ValueUI;
import Set;
//import List;
//import Map;

public int counterInsideComment;

public void Volume_calc() {
	int lineCount = 0;
	//myModel = createM3FromEclipseProject(|project://test-project|);
	myModel = createM3FromEclipseProject(|project://smallsql0.21_src|);	
	set[loc] lo = { l | <l,class(l,_)> <- myModel@types};
	for (loc i <- lo ) {
		int lineNum = 0;
		counterInsideComment = 0;
		for (str st <- readFileLines(i)) {
			int countIfCode;
			str temp = countInLine1(st);
			
			if ("" == temp) countIfCode = 0;
			else {
				println(temp);
				countIfCode = 1;
			}
			lineNum = lineNum + countIfCode;
		}
		lineCount = lineCount + lineNum;
	}
	println (lineCount);
}

public str countInLine1(str S){
int count=0;
  
	if ( (/\w+.*\/\*+.*\*+\/+/ := S || /\/\*+.*\*+\/+.*\w+/ := S) && counterInsideComment == 0) {
  		return S;
  	}else if ( /^[\t\n\r\ ]*\/\*+/ := S) {   
  		//println(S);
  		if ( /\/+\*+.*\*\// := S) counterInsideComment = 0;
  		else counterInsideComment = 1;
  		count = 0;
  	} else if ( /\*+\/+/ := S && counterInsideComment == 1) { 
  		//println(S);
  		if ( /\*+\/+.*\w+/ := S) return S;
  		else count = 0;
  		counterInsideComment = 0;
  	} else if ( /^[\t\n\r\ ]*\/+\/+/ := S ) {  //starting with //
  		//println(S);
  		count = 0;
  	}else if (counterInsideComment == 0) {
  		if ( /[\t\n\r\ ]*\/\*+/ := S) {
  			if ( /\"+.*\/\*+.*\"/ := S);
  			else counterInsideComment = 1;
  		}
  		if ( !(/^[\t\n\r\ ]*$/ := S) ) {
	  		return S;
  		}
  	}
  	return "";
}

public void Cyclomatic_Complexity() {
		set[tuple[str,str]] cc = {};
		myModel = createM3FromEclipseProject(|project://test-project|);
		//myModel = createM3FromEclipseProject(|project://smallsql0.21_src|);	
		for (i <- methods(myModel) ) {
		
			int baseNumCC = 1;
			counterInsideComment = 0;
			for (str st <- readFileLines(i)) {
				str lineWithoutComments = countInLine1(st);
				if (lineWithoutComments != "" ) {
					list[int] temp = countCC(lineWithoutComments);
					for (int temp2 <- temp, temp2==1) {
						baseNumCC = baseNumCC + temp2;
					}
				}
			}
			str risk = calcRisk(baseNumCC);
			cc = cc + <i.path,risk>;
			println(i.path);
			println(baseNumCC);
		}
		for (i<-cc) {
			println(i);
		}
}

public str calcRisk(int ccCount) {
	if (ccCount <= 10) {
		return("without much risk");
	} else if (ccCount <= 20) {
		return("moderate risk");
	} else if (ccCount <= 50) {
		return("high risk");
	} else {
		return("highly unstable method");
	}
}

private list[int] countCC( str st ) {
	int inSt = 0;
	int commentstart =0;
	list[int] myList = [0,0,0,0,0,0,0];
	visit(st) {
		case /\/\*/ : {
			if (inSt == 0) commentstart = 1;
		}
		case /\*\// : {
			commentstart = 0;
		}
		case /\"/ : {
			if (inSt == 0 && commentstart == 0) inSt=1;
			else inSt=0;
		}
		case /\"\"/ : {
			if (inSt == 1 && commentstart == 0) inSt=0;
			else inSt=1;
		}
		case /if/ : {
			if (commentstart==0 && inSt==0) myList[0]=1;
		}
		case /while/ : {
			if (commentstart==0 && inSt==0) myList[1]=1;
		}
		case /for/ : {
			if (commentstart==0 && inSt==0) myList[2]=1;
		}
		case /case/ : {
			if (commentstart==0 && inSt==0) myList[3]=1;
		}
		case /catch/ : {
			if (commentstart==0 && inSt==0) myList[4]=1;
		}
		case /&&/ : {
			if (commentstart==0 && inSt==0) myList[5]=1;
		}
		case /\|\|/ : {
			if (commentstart==0 && inSt==0) myList[6]=1;
		}
	};
	return myList;
}
