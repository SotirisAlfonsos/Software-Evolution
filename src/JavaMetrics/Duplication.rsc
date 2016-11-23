module JavaMetrics::Duplication

import JavaMetrics::SourceTransformer;
import lang::java::jdt::m3::Core;
import Prelude;

int code_Duplication(list[list[str]] filesinstr) {
	
	list[tuple[int,int,int]] duplicatedparts = [];
	int possibleDuplicate =0;
	int duplication=0;
	int fstposition=-1;
	int lstposition=-1;
	//filesinstr = mapper(removeSimpleLines, filesinstr);
	for (int i <- [0..size(filesinstr)]) {
		list[str] fileone = filesinstr[i];
		for (int x <- [0..size(fileone)]) { 
			if (size(fileone)-x<6) break;
			else if ( /^\}$/ := fileone[x] || /^\{$/ := fileone[x] );
			else {
				list[str] bl = fileone[x .. x+6];
				for (int j <- [i..size(filesinstr)]) {
					list[str] filetwo = filesinstr[j];
					
					if (size(filetwo)<6) continue;
					else if ([_*, bl, _*] := filetwo) {
						fstposition = indexOf(filetwo, fileone[x]);
						if (i==j && x==fstposition){
							int tempfstposition = indexOf(filetwo[(fstposition+1)..], fileone[x]);
									
							if (tempfstposition != -1) fstposition = fstposition+1+tempfstposition;
							else fstposition=-1;
						}
						
						if (fstposition!=-1 && fstposition < size(filesinstr)-1) {
							
							do { 
								int temp = x;
								int temp2 = fstposition;
								
								int startstri=x;
								int endstri=0;
								int startstry=fstposition;
								int endstry=0;
								
								while (fileone[temp] == filetwo[temp2]) {
									//println("<fileone[temp]> <i> / <size(filesinstr)>");
									//println("<i> / <size(filesinstr)>");
									temp=temp+1;
									temp2=temp2+1;
									
									possibleDuplicate=possibleDuplicate+1;
									
									endstri=temp-1;
									endstry=temp2-1;
									
									if (temp==size(fileone) || temp2==size(filetwo)) break;
									
								}
								
								int flagDup=0;
								int flagDup2=0;
								if (possibleDuplicate >= 6) {
									for (tuple[int f,int xi,int yi] dup<-duplicatedparts) {
										if (startstri>=dup.xi && endstri<=dup.yi && dup.f==i) flagDup=1;
										else if (startstry>=dup.xi && endstry<=dup.yi && dup.f==j) flagDup2=1;
										
									}
									if (flagDup==1 && flagDup2==1);
									else if (flagDup==1) duplicatedparts=duplicatedparts+<j,startstry,endstry>;
									else if (flagDup2==1) duplicatedparts=duplicatedparts+<i,startstri,endstri>;
									else duplicatedparts=duplicatedparts+<i,startstri,endstri>+<j,startstry,endstry>;
								}
								possibleDuplicate=0;
								
								int tempfstposition = indexOf(filetwo[(fstposition+1)..], fileone[x]);
								
								if (tempfstposition != -1) fstposition = fstposition+1+tempfstposition;
								else fstposition=-1;
								if (i==j && x==fstposition){
									int tempfstposition = indexOf(filetwo[(fstposition+1)..], fileone[x]);
											
									if (tempfstposition != -1) fstposition = fstposition+1+tempfstposition;
									else fstposition=-1;
								}
							}while (fstposition != -1 && fstposition < size(filesinstr)-1);
						}
					}
				}
			}
		}
	}
	int numberofduplicatedcode =0;
	for (tuple[int f,int x,int y] dup<-duplicatedparts) {
		list[str] stri = filesinstr[dup.f];
		//println("------------------------------------");
		//for (i<-[dup.x..dup.y]) println(stri[i]);
		//println(stri[dup.y]);
		//println("------------------------------------");
		numberofduplicatedcode = numberofduplicatedcode + dup.y - dup.x + 1;
	}
	println(numberofduplicatedcode);
	return numberofduplicatedcode;
	
}