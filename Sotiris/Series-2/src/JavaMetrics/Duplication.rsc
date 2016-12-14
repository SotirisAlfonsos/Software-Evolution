module JavaMetrics::Duplication

import JavaMetrics::SourceTransformer;
import lang::java::jdt::m3::Core;
import Prelude;
import util::Math;
import Map;
import JavaMetrics::Volume;
import vis::Figure;
import vis::Render;
import vis::KeySym;
import util::Editors;
import Exception;

int code_Duplication(list[list[int]] filesinstr, int totalLinesOfCode) {
	list[loc] sourceLocs = getLocs();
	list[tuple[int,int,int]] duplicatedparts = [];
	int possibleDuplicate =0;
	int duplication=0;
	int fstposition=-1;
	int lstposition=-1;
	//filesinstr = mapper(removeSimpleLines, filesinstr);
	int sourceSize = size(filesinstr); 
	for (int i <- [0..sourceSize]) {
		print("<precision(toReal(i * 100) / sourceSize, 3)>%     \r");
		list[int] fileone = filesinstr[i];
		for (int x <- [0..size(fileone)]) { 
			fstposition=-1;
			if (size(fileone)-x<6) break;
			
			//else if ( /^\}$/ := fileone[x] || /^\{$/ := fileone[x] );
			else {
				list[int] bl = fileone[x .. x+6];
				for (int j <- [i..size(filesinstr)]) {
					list[int] filetwo = filesinstr[j];
					
					if (size(filetwo)<6) continue;
					else if ([_*, bl, _*] := filetwo) {
						//int posit =0;
						/*for (firstint <- [0..size(filetwo)]) {
							//println("<filetwo> \n <filetwo[firstint]>");
							if (firstint<size(filetwo)-5) {
								if (bl == filetwo[firstint..firstint+6]) { 
									if (i==j && x==firstint);
									else{
										fstposition=firstint; 
										break; 
									}
								}
							}else break;
							//posit += 6;
						}*/
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
								//int posit =fstposition+1;
								/*for (firstint <- [fstposition+1..size(filetwo)]) {
									//println("<filetwo> \n <filetwo[firstint]>");
									if (firstint<size(filetwo)-5) {
										if (bl == filetwo[firstint..firstint+6]) { 
											if (i==j && x==firstint);
											else{
												fstposition=firstint; 
												break; 
											}
										}
									}else {fstposition=-1; break; }
									//posit += 6;
								}*/
								
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
	list[loc] locationsMethods = getLocs();
	list[tuple[real,int]] tryit = [];
	for (tuple[int f,int x,int y] dup<-duplicatedparts) {
		//list[int] stri = filesinstr[dup.f];
		//str meth = toString(sourceLocs[f]);
		tryit = addInAMap(dup.f,dup.x,dup.y,tryit);
		//locationsMethods[dup.f];
		//println(dup.f);
		
			//onMouseEnter(void () { c = true; }), onMouseExit(void () { c = false ; }), fillColor("Red"));
		//println(sourceLocs[dup.f]);
		//println("------------------------------------");
		//for (i<-[dup.x..dup.y]) println(stri[i]);
		//println("<dup.x> <dup.y>");
		//println("------------------------------------");
		numberofduplicatedcode = numberofduplicatedcode + dup.y - dup.x + 1;
	}
	
	makeGraph(tryit, locationsMethods);

	//render(hcat(b1,std(bottom())));
	println(numberofduplicatedcode);
	return numberofduplicatedcode;
	
}

private list[tuple[real,int]] addInAMap(f,x,y,list[tuple[real,int]] tryit) {
	for (tuple[real b,int a] t<-tryit) {
		if (t.a==f) {
			tryit=tryit-t;
			tryit += <t.b+y-x+1.0,f>;
			return tryit;
		}
	}
	return (tryit+<y-x+1.0,f>);
}

private void myEdit(file,msg) {
	list[LineDecoration] ld = [];
	try (file.begin)
		ld = [info(l, msg) | l <- [file.begin.line..file.end.line+1]];
	catch UnavailableInformation() : 
		ld = [info(1, msg)];
		
	edit(file, ld);
		
}

private void makeGraph (tryit,locationsMethods) {
	tuple[real a,int b] h=max(tryit);
	tryit = tryit -h;
	tryit = reverse(sort(tryit));
	
	list[Figure] b1 =[box(vshrink(h.a/h.a),
		mouseOver(text("<toInt(h.a)>")), 
		onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
			myEdit(locationsMethods[h.b],"hi");
			return true;
		}),
		fillColor("Red"))];
		
	for (tuple[real b,int a] t<-tryit) {
		println(t.b);
		b1 += box(vshrink(t.b /h.a),
			mouseOver(text("<toInt(t.b)>")),
			onMouseDown(bool (int butnr, map[KeyModifier,bool] modifiers) {
				myEdit(locationsMethods[t.a],"hi");
				return true;
			}),
			fillColor("Red"));
		
	}
	b0 = box(hcat(b1,std(bottom())), fillColor("lightGray"));
	render(b0);
}