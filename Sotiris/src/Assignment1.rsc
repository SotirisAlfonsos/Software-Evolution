module Assignment1

import IO;
import analysis::m3::AST;
import lang::java::jdt::m3::Core;
import Set;
import String;
import List;
import Calculate_risks;

public int counterInsideComment;
public int inSt;
public list[str] filesinstr =[];


public void main() {
	filesinstr =[];
	//myModel = createM3FromEclipseProject(|project://test-project|);
	myModel = createM3FromEclipseProject(|project://smallsql0.21_src|);	
	//myModel = createM3FromEclipseProject(|project://testingclassesfromsmallsql|);
	//myModel = createM3FromEclipseProject(|project://hsqldb-2.3.1|);
	int totalLinesOfCode = Volume_calc(myModel);
	set[tuple[str,str]] cyclomaticComplexitySet = Cyclomatic_Complexity(myModel);
	set[tuple[str,int]] unitSizeSet = Unit_size(myModel);
	int duplication = Code_DuplicationV2();
	calcRisks(totalLinesOfCode, cyclomaticComplexitySet, unitSizeSet, duplication);
	
	println (size(filesinstr));
	//println (totalLinesOfCode);
	//println (duplication);
}
/*-------------------------------------------------------------
IT IS READY.
--------------------------------------------------------------*/

public int Volume_calc(myModel) {
	int lineCount = 0;
	int totalLinesOfCode =0;
	for (i<-files(myModel)) {
		str string = readFile(i);
		int linecount = countWholeStr(string, 0);
		//filesinstr = filesinstr + T.fileinstr;
		totalLinesOfCode = totalLinesOfCode + linecount;
	}
	return (totalLinesOfCode);
}

/*-------------------------------------------------------------------------------------------------------------
* parse the code of each file in a string. if we find \/\*\*\/ , // we keep a counter to not take the content.
* for the rest of the cases we keep the code in a string that we are going to use for the other metrics.
* we dont count @Override when counting for unit size and we check what is in a string to handle some cases.
* This function is used for counting the volume and unit size. 
---------------------------------------------------------------------------------------------------------------*/

public int countWholeStr(str string, int callForUnitCount){
	inSt = 0;
	str codeDuplication = "";
	str overrideCheck = "";
	int ifitisaline =0;
	int linecomment =0;
	int retLineCount = 0;
	
	for (i <- [0..(size(string)-1)]) {
	
		if ( /\n/ := string[i]) {
			if (callForUnitCount==1) {
				if (ifitisaline==1 && !(/^[\t\n\r\ ]*\@Override[\t\n\r\ ]*$/ := overrideCheck ) ) {
					retLineCount=retLineCount + 1;
				}
				overrideCheck = "";
			}else if (callForUnitCount==0) {
				if (ifitisaline==1) {
					//codeDuplication=codeDuplication+string[i];
					filesinstr = filesinstr + codeDuplication;
					codeDuplication="";
					retLineCount=retLineCount + 1;
				}
			}
			ifitisaline=0;
			inSt = 0;
			linecomment =0;
		}else if ( /\/\// := string[i]+string[i+1]) {
			linecomment=1;
		}else if ( /\/\*/ := string[i]+string[i+1]) {
			if (inSt == 0 && linecomment==0) counterInsideComment = 1;
		}else if ( /\*\// := string[i]+string[i+1]) {
			counterInsideComment = 0;
		}else if ( /\"/ := string[i]) {
			if (inSt == 0 && counterInsideComment == 0 && linecomment==0) inSt=1;
			else inSt=0;
			codeDuplication=codeDuplication+string[i];
		}else if ( /[\t\n\r\ ]/ := string[i]) ;
		else if ( /\// := string[i]) ;
		else if (/[\w\W]/ := string[i]) {
			if (counterInsideComment==0 && linecomment==0 ){
				if (callForUnitCount==0) codeDuplication=codeDuplication+string[i];
				else if (callForUnitCount==1) overrideCheck=overrideCheck+string[i]; 
				ifitisaline=1;
			} 
		}
		
		if (i==(size(string)-2) && ifitisaline==1){
			retLineCount=retLineCount + 1;
			if (callForUnitCount==0) filesinstr = filesinstr + codeDuplication;
		}
	}
	
	if ( /[\t\n\r\ ]/ := string[size(string)-1]) ;
	else if (/[\w\W]/ := string[size(string)-1] && /\n/ := string[size(string)-2]) {
		if (counterInsideComment==0 && inSt==0 && linecomment==0 ) {
			retLineCount = retLineCount + 1;
			codeDuplication=codeDuplication+string[size(string)-1];
			filesinstr = filesinstr + codeDuplication;
			codeDuplication="";
		}
	}
	//for (str s<-filesinstr) println(s);
	return retLineCount;
}


public set[tuple[str,str]] Cyclomatic_Complexity(myModel) {
		set[tuple[str,str]] cc = {};	
		for (i <- methods(myModel) ) {
		
			int baseNumCC = 1;
			counterInsideComment = 0;
			for (str st <- readFileLines(i)) {
				list[int] temp = countCC(st);
				for (int temp2 <- temp, temp2>=1) {
					baseNumCC = baseNumCC + temp2;
				}
			}
			
			str risk = calcRisk(baseNumCC);
			//if (risk=="highly unstable method")
			 //println("<i.path> <baseNumCC>");
			//tuple with the name of the function and the calculated cc
			cc = cc + <i.path,risk>;
			
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
	int dontcountit=0;
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
		case /^\\\"/ : {
			dontcountit=1;
		}
		case /^\"/ : {
			if (dontcountit==0) {
				if (inSt == 0 && counterInsideComment == 0 && linecomment==0) inSt=1;
				else inSt=0;
			}else dontcountit=0;
		}
		case /^\"\"/ : {
			if (inSt == 1 && counterInsideComment == 0 && linecomment==0) inSt=0;
			else inSt=1;
		}
		case /^\Wif\W/ : {
			if (counterInsideComment==0 && inSt==0 && linecomment==0) myList[0]=myList[0]+1;
		}
		case /^\Wif$/ : {
			if (counterInsideComment==0 && inSt==0 && linecomment==0) myList[0]=myList[0]+1;
		}
		case /^\Wwhile\W/ : {
			if (counterInsideComment==0 && inSt==0 && linecomment==0) myList[1]=myList[1]+1;
		}
		case /^\Wwhile$/ : {
			if (counterInsideComment==0 && inSt==0 && linecomment==0) myList[1]=myList[1]+1;
		}
		case /^\Wfor\W/ : {
			if (counterInsideComment==0 && inSt==0 && linecomment==0) myList[2]=myList[2]+1;
		}
		case /^\Wfor$/ : {
			if (counterInsideComment==0 && inSt==0 && linecomment==0) myList[2]=myList[2]+1;
		}
		case /^\Wcase\W/ : {
			if (counterInsideComment==0 && inSt==0 && linecomment==0) myList[3]=myList[3]+1;
		}
		case /^\Wcase$/ : {
			if (counterInsideComment==0 && inSt==0 && linecomment==0) myList[3]=myList[3]+1;
		}
		case /^\Wcatch\W/ : {
			if (counterInsideComment==0 && inSt==0 && linecomment==0) myList[4]=myList[4]+1;
		}
		case /^\Wcatch$/ : {
			if (counterInsideComment==0 && inSt==0 && linecomment==0) myList[4]=myList[4]+1;
		}
		case /^\W&&\W/ : {
			if (counterInsideComment==0 && inSt==0 && linecomment==0) myList[5]=myList[5]+1;
		}
		case /^\W&&$/ : {
			if (counterInsideComment==0 && inSt==0 && linecomment==0) myList[5]=myList[5]+1;
		}
		case /^\W\|\|\W/ : {
			if (counterInsideComment==0 && inSt==0 && linecomment==0) myList[6]=myList[6]+1;
		}
		case /^\W\|\|$/ : {
			if (counterInsideComment==0 && inSt==0 && linecomment==0) myList[6]=myList[6]+1;
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
		for (i <- methods(myModel) ) {
			counterInsideComment = 0;
			str st = readFile(i);
			int lineNum = countWholeStr(st,1);
				
			//unicounter = unicounter + lineNum;
			us = us + <i.path,lineNum>;
		}
		//for (i<-us) {
		//	println(i);
		//}
		//println(unicounter);
		return(us);
}


public int Code_DuplicationV2() {
	
	list[tuple[int,int]] duplicatedparts = [];
	int possibleDuplicate =0;
	int duplication=0;
	int fstposition=-1;
	int lstposition=-1;
	
	for (int i <- [0..size(filesinstr)]) {
		
		if (/\}/ := filesinstr[i]);
		else { 
			int tempfstposition = indexOf(filesinstr[(i+1)..], filesinstr[i]);
			//int templstposition = lastIndexOf(filesinstr[(i+1)..], filesinstr[i]);
			
			if (tempfstposition != -1) fstposition = i+1+tempfstposition;
			else fstposition=-1;
			//if (templstposition != -1) lstposition = i+1+templstposition;
			//else lstposition=-1;
			
			if (fstposition!=-1 && fstposition < size(filesinstr)-1) {
			
				do { 
					int temp = i;
					int temp2 = fstposition;
					
					int startstri=i;
					int endstri=0;
					int startstry=fstposition;
					int endstry=0;
					
					while (filesinstr[temp] == filesinstr[temp2]) {
						println("<temp> / <size(filesinstr)>");
						temp=temp+1;
						temp2=temp2+1;
						
						possibleDuplicate=possibleDuplicate+1;
						
						endstri=temp-1;
						endstry=temp2-1;
						int flagDup=0;
						int flagDup2=0;
						if (possibleDuplicate==6){
												 
							for (tuple[int xi,int yi] dup<-duplicatedparts) {
								if (startstri>=dup.xi && endstri<=dup.yi) flagDup=1;
								else if (startstry>=dup.xi && endstry<=dup.yi) flagDup2=1;
								
							}
							if (flagDup==1 && flagDup2==1);
							else duplication=duplication+1;
						}
						if (temp==size(filesinstr) || temp2==size(filesinstr)) break;
						
					}
					
					int flagDup=0;
					int flagDup2=0;
					if (possibleDuplicate >= 6) {
						for (tuple[int xi,int yi] dup<-duplicatedparts) {
							if (startstri>=dup.xi && endstri<=dup.yi) flagDup=1;
							else if (startstry>=dup.xi && endstry<=dup.yi) flagDup2=1;
							
						}
						if (flagDup==1 && flagDup2==1);
						else duplicatedparts=duplicatedparts+<startstri,endstri>+<startstry,endstry>;
					}
					possibleDuplicate=0;
					
					tempfstposition = indexOf(filesinstr[(fstposition+1)..], filesinstr[i]);
					
					if (tempfstposition != -1) fstposition = fstposition+1+tempfstposition;
					else fstposition=-1;
					
				}while (fstposition != -1 && fstposition < size(filesinstr)-1);
				
			}
		}
	}
	int numberofduplicatedcode =0;
	for (tuple[int x,int y] dup<-duplicatedparts) {
		
		numberofduplicatedcode = numberofduplicatedcode + dup.y - dup.x + 1;
		
	}
	return numberofduplicatedcode;
	
}




/*---------------------------------------------------------------
						OLD METHOD
---------------------------------------------------------------*/

public int Code_Duplication() {
	
	list[tuple[int,int,int]] duplicatedparts = [];
	int duplication =0;
	str linestr = "";
	str linestr2 ="";
	int startstrj =0;
	int endstrj =0;
	int startstry =0;
	int endstry =0;
	int possibleduplication = 0;
	int startcount=0;
	
	for (int i <- [0..size(filesinstr)]) {
		str stringj = filesinstr[i];
		
		for (int j <- [0..size(stringj)]) {
			
			int iter = j;
			
			if ( /\n/ := stringj[j]) {
				
				for (int x <- [i..size(filesinstr)]) {
					str linestrtemp = linestr;
					str stringy = filesinstr[x];
					
					if (x==i) startcount=j;
					else startcount=0;
					
					for (int y <- [startcount..size(stringy)]) {
						
						if ( /\n/ := stringy[y]) {
							
							if (x==i && j==y);
							else
								if (linestrtemp == linestr2) {
								
									linestrtemp="";
									endstrj = iter;
									endstry = y;
									for (iter1<-[(iter+1)..size(stringj)] ) {
										if (!(/\n/ := stringj[iter1])) {
											linestrtemp = linestrtemp+stringj[iter1];
										}else {
											iter=iter1; 
											break;
										}
									}
									
									possibleduplication = possibleduplication + 1;
									
									//parse the already count duplications and see if this one is a new one
									int flagDup=0;
									int flagDup2=0;
									if (possibleduplication==6){
										 
										for (tuple[int ii,int xi,int yi] dup<-duplicatedparts) {
											if (dup.ii==i && startstrj>=dup.xi && endstrj<=dup.yi) flagDup=1;
											else if (dup.ii==x && startstry>=dup.xi && endstry<=dup.yi) flagDup2=1;
											
										}
										if (flagDup==1 && flagDup2==1);
										else duplication=duplication+1;
									}
									
								}else {
								
									//gather the duplicate values that we have already count
									int flagDup=0;
									int flagDup2=0;
									if (possibleduplication >= 6) {
										for (tuple[int ii,int xi,int yi] dup<-duplicatedparts) {
											if (dup.ii==i && startstrj>=dup.xi && endstrj<=dup.yi) flagDup=1;
											else if (dup.ii==x && startstry>=dup.xi && endstry<=dup.yi) flagDup2=1;
											
										}
										if (flagDup==1 && flagDup2==1);
										else duplicatedparts=duplicatedparts+<i,startstrj,endstrj>+<x,startstry,endstry>;
									}
									
									iter=j;
									linestrtemp = linestr;
									possibleduplication=0;
									startstry=0;
								}
								linestr2 = "";
						}else {
							linestr2 = linestr2 + stringy[y];
							if (startstry==0) startstry=y;
						}
					}
					
					//gather the duplicate values that we have already count
					int flagDup=0;
					int flagDup2=0;
					if (possibleduplication >= 6) {
						for (tuple[int ii,int xi,int yi] dup<-duplicatedparts) {
							if (dup.ii==i && startstrj>=dup.xi && endstrj<=dup.yi) flagDup=1;
							else if (dup.ii==x && startstry>=dup.xi && endstry<=dup.yi) flagDup2=1;
						}
						if (flagDup==1 && flagDup2==1);
						else duplicatedparts=duplicatedparts+<i,startstrj,endstrj>+<x,startstry,endstry>;
						possibleduplication=0;
						startstry=0;
					}
									
				}
				linestr = "";
				startstrj=0;
			}else {
				linestr = linestr + stringj[j];
				if (startstrj==0) startstrj=j;
			}
			
			possibleduplication=0;
		}
		sixlinestrj ="";
		sixlinestry ="";
		ihavesixlinesj =0;
		ihavesixlinesy =0;
	} 
	/*str s="";
	for (tuple[int ii,int x,int y] dup<-duplicatedparts) {
		 s=filesinstr[dup.ii];
		for (ite<-[(dup.x)..(dup.y)]) {
			print(s[ite]);
		}
		println ("-----------------------------");
		println(" <dup.ii> <dup.x> <dup.y> ");
	}*/
	//println(duplication);
	return duplication;
}
