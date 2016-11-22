module JavaMetrics::SigMappings

list[int] totalLoc = [66, 246, 665, 1310];
list[int] unitLoc  = [15, 30, 60]; //20 15 5, 30 20 10, 40 25 15, 50 35 20
list[int] unitCc   = [10, 20, 50]; //25 0  0, 30 5 0, 40 10  0, 50 15 5

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

int calculateUnitSizeRating(list[int] unitLoc, int totalLoc){
	map[str, int] sizes = ("small": 0, "medium": 0, "large": 0, "veryLarge": 0);
	for(int unit <- unitLoc){
		if(unit <= 15) sizes["small"]  += unit;
		else if(unit <= 30) sizes["medium"] += unit;
		else if(unit <= 60) sizes["large"]  += unit;
		else sizes["veryLarge"] += unit;
	}
	
	map[str, int] percentages = (cat: sizes[cat] * 100 / totalLoc | cat <- sizes);
	//20 15 5, 30 20 10, 40 25 15, 50 35 20
	if(testSizePercentages(20, 15, 5, percentages)) return 4;
	else if(testSizePercentages(30, 20, 10, percentages)) return 3;
	else if(testSizePercentages(40, 25, 15, percentages)) return 2;
	else if(testSizePercentages(50, 35, 20, percentages)) return 1;
	else return 0;
	
}

bool testSizePercentages(int m, int l, int vl, map[str, int] p){ 
	return p["medium"] <= m && p["large"] <= l && p["veryLarge"] <= vl;
}

int calculateComplexityRating(lrel[str, int] unitLoc, rel[str, int] cc, int totalLoc){
	map[str, int] sizes = ("simple": 0, "moderate": 0, "high": 0, "veryHigh": 0);
	for(<str l, int size> <- unitLoc){
		if(cc[l] <= 10) sizes["simple"]  += size;
		else if(cc[l] <= 20) sizes["moderate"] += size;
		else if(cc[l] <= 50) sizes["high"]  += size;
		else sizes["veryHigh"] += size;
	}
	
	map[str, int] percentages = (cat: sizes[cat] * 100 / totalLoc | cat <- sizes);
	//25 0  0, 30 5 0, 40 10  0, 50 15 5
	if(testPercentages(25, 0, 0, percentages)) return 4;
	else if(testPercentages(30, 5, 0, percentages)) return 3;
	else if(testPercentages(40, 10, 0, percentages)) return 2;
	else if(testPercentages(50, 15, 5, percentages)) return 1;
	else return 0;	
}

bool testPercentages(int m, int l, int vl, map[str, int] p){ 
	return p["moderate"] <= m && p["high"] <= l && p["veryHigh"] <= vl;
}

int testCcPercentages(){

}
