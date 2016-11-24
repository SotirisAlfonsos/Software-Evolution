module JavaMetrics::SigMappings
import IO;
import Prelude;
import util::Math;

list[str] stars = ["--", "-", "o", "+", "++"];
int calculateLocRating(int LoC){
	int kloc = LoC / 1000;
	if(kloc < 66){
		return 4;
	} else if(kloc < 246){
		return 3;
	} else if (kloc < 665){
		return 2;
	} else if (kloc < 1310){
		return 1;
	} else {
		return 0;
	}
}

tuple[int rating, list[real] sizes, list[real] percentages] calculateUnitSizeRating(list[int] unitLoc, int totalLoc){
	list[real] sizes = [0.,0.,0.,0.];
	for(int unit <- unitLoc){
		if(unit <= 30) sizes[0]  += unit;
		else if(unit <= 45) sizes[1] += unit;
		else if(unit <= 75) sizes[2]  += unit;
		else sizes[3] += unit;
	}
	
	list[real] percentages = [precision(s * 100 / totalLoc, 4) | s <- sizes];

	int rating = 0;
	if(testSizePercentages(20, 11, 4, percentages)) rating = 4;
	else if(testSizePercentages(26, 16, 7, percentages)) rating = 3;
	else if(testSizePercentages(34, 22, 11, percentages)) rating = 2;
	else if(testSizePercentages(46, 31, 18, percentages)) rating = 1;

	return <rating, sizes, percentages>;
	
}

bool testSizePercentages(int m, int l, int vl, list[real] p){ 
	return p[1] <= m && p[2] <= l && p[3] <= vl;
}

tuple[int rating, list[real] sizes, list[real] percentages] calculateComplexityRating(lrel[loc mloc, int size] unitLoc, lrel[loc mloc, int complexity] unitCc, int totalLoc){
	list[real] sizes = [0.,0.,0.,0.];
	map[loc, int] cc = toMapUnique(unitCc);
	for(<loc l, int size> <- unitLoc){
		if(cc[l] <= 10) sizes[0]  += size;
		else if(cc[l] <= 20) sizes[1] += size;
		else if(cc[l] <= 50) sizes[2]  += size;
		else sizes[3] += size;
	}
	
	list[real] percentages = [precision(s * 100 / totalLoc, 4) | s <- sizes];

	int rating = 0;
	if(testPercentages(25, 0, 0, percentages)) rating = 4;
	else if(testPercentages(30, 5, 0, percentages)) rating = 3;
	else if(testPercentages(40, 10, 0, percentages)) rating = 2;
	else if(testPercentages(50, 15, 5, percentages)) rating = 1;
	
	return <rating, sizes, percentages>;	
}

bool testPercentages(int m, int l, int vl, list[real] p){ 
	return p[1] <= m && p[2] <= l && p[3] <= vl;
}

int calculateDuplicationRating(int dupCount, int totalLoc){
	// 3 5 10 20 100
	real percentage = toReal(dupCount * 100) / totalLoc;
	if(percentage < 3){
		return 4;
	} else if(percentage< 5){
		return 3;
	} else if (percentage < 10){
		return 2;
	} else if (percentage < 20){
		return 1;
	} else {
		return 0;
	}
}
