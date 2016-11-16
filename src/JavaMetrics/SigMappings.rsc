module JavaMetrics::SigMappings

int calculateLocRating(int LoC){
	int kloc = LoC / 1000;
	if(kloc < 66){
		return 5;
	} else if(kloc < 246){
		return 4;
	} else if (kloc < 665){
		return 3;
	} else if (kloc < 1310){
		return 2;
	} else {
		return 1;
	}
}

int calculateUnitSizeRating(loc project){

}

int calculateComplexityRating(rel[loc src, int cc] complexities){
	tuple[int low, int moderate, int high, int veryHigh] risk
		= <0, 0, 0, 0>;
	int numberOfMethods = size(complexities);
	for(complexity <- complexities<cc>){
		if(complexity < 11){
			risk.low += 1;
		} else if(complexity < 21){
			risk.moderate += 1;
		} else if(complexity < 50){
			risk.high += 1;
		} else {
			risk.veryHigh += 1;
		}
	}
	// TODO: calculate threshold values
	
}
