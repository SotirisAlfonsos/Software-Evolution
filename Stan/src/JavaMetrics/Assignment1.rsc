module JavaMetrics::Assignment1

import IO;
import analysis::m3::AST;
import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import util::ValueUI;
import Set;
import String;
import List;

public int counterInsideComment;
public int inSt;
public list[str] filesinstr =[];

public str blockStart = "/*";
public str blockEnd   = "*/";
public str single     = "//";


public void main() {
	myModel = createM3FromEclipseProject(|project://test-project|);
	//myModel = createM3FromEclipseProject(|project://smallsql0.21_src|);	
	//myModel = createM3FromEclipseProject(|project://testingclassesfromsmallsql|);
	//myModel = createM3FromEclipseProject(|project://hsqldb-2.3.1|);
	int totalLinesOfCode = Volume_calc(myModel);
	//set[tuple[str,str]] cyclomaticComplexitySet = Cyclomatic_Complexity(myModel);
	//set[tuple[str,int]] unitSizeSet = Unit_size(myModel);
	int duplication = Code_Duplication();
	//calcRisks(totalLinesOfCode, cyclomaticComplexitySet, unitSizeSet);
	//for (i<-[0..size(filesinstr)]) {
	//	println(filesinstr[i]);
	//}
}
/*-------------------------------------------------------------
IT IS READY.
--------------------------------------------------------------*/

public int Volume_calc(myModel) {
	int lineCount = 0;
	int totalLinesOfCode =0;
	str new="";
	//myModel = createM3FromEclipseProject(|project://test-project|);
	//myModel = createM3FromEclipseProject(|project://smallsql0.21_src|);	
	//myModel = createM3FromEclipseProject(|project://testingclassesfromsmallsql|);
	//myModel = createM3FromEclipseProject(|project://hsqldb-2.3.1|);
	for (i<-files(myModel)) {
		str string = readFile(i);
		tuple[int lineCount,str fileInStr] T = countWholeStr(string, 0);
		//println (i.path);
		//println(linecount);
		filesInStr += T.fileInStr;
		totalLinesOfCode += T.lineCount;
	}
	//println (totalLinesOfCode);
	return (totalLinesOfCode);
}

public tuple[int,str] countWholeStr(str string, int callForUnitCount){
	inSt = 0;
	str codeDuplication = "";
	str overrideCheck = "";
	int ifitisaline =0;
	int linecomment =0;
	int retLineCount = 0;
	for (i <- [0..size(string)-1]) {
	
		if ( /\n/ := string[i]) {
			if (callForUnitCount==1) {
				if (ifitisaline==1 && !(/^\s*\@Override\s*$/ := overrideCheck ) ) {
					retLineCount=retLineCount + 1;
				}
				overrideCheck = "";
			}else if (callForUnitCount==0) {
				if (ifitisaline==1) {
					codeDuplication=codeDuplication+string[i];
					retLineCount=retLineCount + 1;
				}
			}
			ifitisaline=0;
			inSt = 0;
			linecomment =0;
		}else if ( /<single>/ := string[i]+string[i+1]) {
			linecomment=1;
		}else if ( /<blockStart>/ := string[i]+string[i+1]) {
			if (inSt == 0 && linecomment==0) counterInsideComment = 1;
		}else if ( /<blockEnd>/ := string[i]+string[i+1]) {
			counterInsideComment = 0;
		}else if ( /\"/ := string[i]) {
			if (inSt == 0 && counterInsideComment == 0 && linecomment==0) inSt=1;
			else inSt=0;
			codeDuplication=codeDuplication+string[i];
		//}else if ( /\"\"/ := string[i]+string[i+1]) {
		//	if (inSt == 1 && counterInsideComment == 0 && linecomment==0) inSt=0;
		//	else inSt=1;
		}else if ( /\s/ := string[i]) ;
		else if ( /\// := string[i]) ;
		else if (/[\w\W]/ := string[i]) {
			if (counterInsideComment==0 && linecomment==0 ){
				if (callForUnitCount==0) codeDuplication=codeDuplication+string[i];
				else if (callForUnitCount==1) overrideCheck=overrideCheck+string[i]; 
				ifitisaline=1;
			} 
		}
		
		if (i==(size(string)-2) && ifitisaline==1) retLineCount=retLineCount + 1;
	
	}
	//println(overrideCheck);
	if ( /[\t\n\r\ ]/ := string[size(string)-1]) ;
	else if (/[\w\W]/ := string[size(string)-1] && /\n/ := string[size(string)-2]) {
		if (counterInsideComment==0 && inSt==0 && linecomment==0 ) {
			retLineCount = retLineCount + 1;
			codeDuplication=codeDuplication+string[size(string)-1];
		}
	}
	return <retLineCount,codeDuplication>;
}










/*-------------------------------------------------------------
old version
---------------------------------------------------------------*/
public str countInLine1(str S){

	inSt = 0;
	int linecomment =0;
	str retLine = "";
	
	visit(S) {
		case /^\/\// : {
			linecomment=1;
		}
		case /^\/\*/ : {
			if (inSt == 0 && linecomment==0) counterInsideComment = 1;
		}
		case /^\*\// : {
			counterInsideComment = 0;
		}
		case /^\"/ : {
			if (inSt == 0 && counterInsideComment == 0 && linecomment==0) inSt=1;
			else inSt=0;
		}
		case /^\"\"/ : {
			if (inSt == 1 && counterInsideComment == 0 && linecomment==0) inSt=0;
			else inSt=1;
		}
		case /^[\t\n\r\ ]*$/ : {
			if (retLine != "");
			else return "";
		}
		case /^[\t\n\r\ ]+/ : ;
		case /^\/[\t\n\r\ ]*$/ : ;
		case /^[\w+\W+]/ : {
			if (counterInsideComment==0 && inSt==0 && linecomment==0 ) retLine=S;
		}
		
	};
	return retLine;
}

/*----------------------------------------------------------*/

public set[tuple[str,str]] Cyclomatic_Complexity(myModel) {
		set[tuple[str,str]] cc = {};
		//myModel = createM3FromEclipseProject(|project://testingclassesfromsmallsql|);
		//myModel = createM3FromEclipseProject(|project://smallsql0.21_src|);	
		for (i <- methods(myModel) ) {
		
			int baseNumCC = 1;
			counterInsideComment = 0;
			for (str st <- readFileLines(i)) {
					list[int] temp = countCC(st);
					for (int temp2 <- temp, temp2==1) {
						baseNumCC = baseNumCC + temp2;
					}
			}
			
			//println(i.path);
			//println(baseNumCC);
			str risk = calcRisk(baseNumCC);
			cc = cc + <i.path,risk>;
			//println(i.path);
			//println(baseNumCC);
		}
		//for (i<-cc) {
		//	println(i);
		//}
		return(cc);
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
	inSt = 0;
	int linecomment =0;
	list[int] myList = [0,0,0,0,0,0,0];
	visit(st) {
		case /^\/\// : {
			linecomment=1;
		}
		case /^\/\*/ : {
			if (inSt == 0 && linecomment==0) counterInsideComment = 1;
		}
		case /^\*\// : {
			if (counterInsideComment==1 && linecomment==0) counterInsideComment = 0;
		}
		case /^\"/ : {
			if (inSt == 0 && counterInsideComment == 0 && linecomment==0) inSt=1;
			else inSt=0;
		}
		case /^\"\"/ : {
			if (inSt == 1 && counterInsideComment == 0 && linecomment==0) inSt=0;
			else inSt=1;
		}
		case /^if/ : {
			if (counterInsideComment==0 && inSt==0 && linecomment==0) myList[0]=1;
		}
		case /^while/ : {
			if (counterInsideComment==0 && inSt==0 && linecomment==0) myList[1]=1;
		}
		case /^for/ : {
			if (counterInsideComment==0 && inSt==0 && linecomment==0) myList[2]=1;
		}
		case /^case/ : {
			if (counterInsideComment==0 && inSt==0 && linecomment==0) myList[3]=1;
		}
		case /^catch/ : {
			if (counterInsideComment==0 && inSt==0 && linecomment==0) myList[4]=1;
		}
		case /^&&/ : {
			if (counterInsideComment==0 && inSt==0 && linecomment==0) myList[5]=1;
		}
		case /^\|\|/ : {
			if (counterInsideComment==0 && inSt==0 && linecomment==0) myList[6]=1;
		}
	};
	return myList;
}

/*-------------------------------------------------------------
IT IS READY. Need to calculate risks
--------------------------------------------------------------*/

public set[tuple[str,int]] Unit_size(myModel) {
		set[tuple[str,int]] us = {};
		int unicounter =0;
		//myModel = createM3FromEclipseProject(|project://testingclassesfromsmallsql|);
		//myModel = createM3FromEclipseProject(|project://test-project|);
		//myModel = createM3FromEclipseProject(|project://smallsql0.21_src|);	
		for (i <- methods(myModel) ) {
			counterInsideComment = 0;
			str st = readFile(i);
			int lineNum = countWholeStr(st,1);
				
			unicounter = unicounter + lineNum;
			us = us + <i.path,lineNum>;
		}
		//for (i<-us) {
		//	println(i);
		//}
		//println(unicounter);
		return(us);
}

public int Code_Duplication() {
	//str linetocheck ="";
	int duplication =0;
	str linestr = "";
	str linestr2 ="";
	int ihavesixlinesj =0;
	int ihavesixlinesy =0;
	int possibleduplication = 0;
	int startcount=0;
	
	for (int i <- [0..size(filesinstr)]) {
		str stringj = filesinstr[i];
		
		for (int j <- [0..size(stringj)]) {
			//println(linestr);
			int iter = j;
			if ( /\n/ := stringj[j]) {
			
				for (int x <- [i..size(filesinstr)]) {
					str linestrtemp = linestr;
					str stringy = filesinstr[x];
					if (x==i) startcount=j;
					else startcount=0;
					//stringy = replaceFirst(stringy, linestrtemp, "");
					for (int y <- [startcount..size(stringy)]) {
						
						if ( /\n/ := stringy[y]) {
							
							if (x==i && j==y);
							else
								if (linestrtemp == linestr2) {
									println("temp "+linestrtemp+" <x> <i> <j> <y> ");
									println("2 "+linestr2);
									//linestr2 = "";
									linestrtemp="";
									for (iter1<-[(iter+1)..size(stringj)] ) {
										if (!(/\n/ := stringj[iter1])) {
											linestrtemp = linestrtemp+stringj[iter1];
												
										}else {
											iter=iter1; 
											break;
										}
									}
									
									//for (iter<-[(y+1)..size(stringy)]) {
									//	if (!(/\n/:=stringy[iter])) linestr2 = linestr2+stringy[iter];
									//}
									possibleduplication = possibleduplication + 1;
									if (possibleduplication==6) duplication=duplication+1;
									println("temp "+linestrtemp);
									println("2 "+linestr2);
									println(duplication);
								}else {
									iter=j;
									linestrtemp = linestr;
									possibleduplication=0;
								}
								linestr2 = "";
						}else {linestr2 = linestr2 + stringy[y];}
					}
				}
				linestr = "";
			}else {linestr = linestr + stringj[j];}
			
			possibleduplication=0;
		}
		sixlinestrj ="";
		sixlinestry ="";
		ihavesixlinesj =0;
		ihavesixlinesy =0;
	} 
	println(duplication);
	return duplication;
}
