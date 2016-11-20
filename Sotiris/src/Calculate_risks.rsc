module Calculate_risks

import IO;

public void calcRisks(int numoflines, set[tuple[str,str]] cc,set[tuple[str,int]] us, int duplication) {
	str volumeRisk = calcVolumeRisk(numoflines);
	str ccRisk = calcCC(cc, us, numoflines);
	str dup = duplicationRisk(duplication, numoflines);
	println("volume: <volumeRisk> cc: <ccRisk> duplication: <dup>");
}

private str calcVolumeRisk(int numoflines) {
	if (numoflines <= 66) {
		return("++");
	} else if (numoflines <= 246) {
		return("+");
	} else if (numoflines <= 665) {
		return("o");
	} else if (numoflines <= 1310) {
		return("-");
	}else {
		return("--");
	}
}

private str calcCC(set[tuple[str,str]] cc,set[tuple[str,int]] us, int totalnumoflines) {

	num linesformed=0.0;
	num linesforhigh=0.0;
	num linesforveryhigh=0.0;
	
	for (tuple[str fir,str sec] i<-cc) {
			if (i.sec == "moderate risk") {
				for (tuple[str first,int second] method<-us) {
					if (i.fir == method.first) { linesformed = linesformed + method.second; break;}
				}
			}else if (i.sec == "high risk") {
				for (tuple[str first,int second] method<-us) {
					if (i.fir == method.first) {linesforhigh = linesforhigh + method.second; break;}
				}
			}else if (i.sec == "highly unstable method") {
				
				for (tuple[str first,int second] method<-us) {
					if (i.fir == method.first) {linesforveryhigh = linesforveryhigh + method.second; break;}
				}
			}
			
	}
	list[num] percentage = [0,0,0];
	percentage[0]=(linesformed*100)/totalnumoflines;
	percentage[1]=(linesforhigh*100)/totalnumoflines;
	percentage[2]=(linesforveryhigh*100)/totalnumoflines;
	println("<linesformed> <linesforhigh> <linesforveryhigh> <percentage>");
	
	if (percentage[0] <= 25.0 && percentage[1] <= 0.0 && percentage[2] <= 0.0) {
		return("++");
	} else if (percentage[0] <= 30.0 && percentage[1] <= 5.0 && percentage[2] <= 0.0) {
		return("+");
	} else if (percentage[0] <= 40.0 && percentage[1] <= 10.0 && percentage[2] <= 0.0) {
		return("o");
	} else if (percentage[0] <= 50.0 && percentage[1] <= 15.0 && percentage[2] <= 5.0) {
		return("-");
	}else {
		return("--");
	}
}

private str duplicationRisk(int duplication, int totalnumoflines) {
	num dup = (duplication*100.0)/totalnumoflines;
	if (dup <= 3) {
		return("++");
	} else if (dup <= 5) {
		return("+");
	} else if (dup <= 10) {
		return("o");
	} else if (dup <= 20) {
		return("-");
	}else {
		return("--");
	}
}