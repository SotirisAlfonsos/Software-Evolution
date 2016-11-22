module JavaMetrics

import JavaMetrics::CyclomaticComplexity;
import JavaMetrics::Duplication;
import JavaMetrics::Volume;
import JavaMetrics::SigMappings;

import IO;
import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;

void main(loc project){
	list[str] stars = ["--", "-", "o", "+", "++"];

	println("Acquiring LoC");
	int totalLoc = countLinesInProject(project);
	
	//println("Acquiring Unit LoC");
	//lrel[str, int] unitLoc = countUnitLines(project);
	
	//println("Acquiring Unit Complexity");
	//rel[str, int] unitCc   = calculateUnitComplexity(project);
	
	println("Acquiring duplicates");
	int dupCount = countDuplicatesInString(getSource());
	
	println("Volume: <stars[calculateLocRating(totalLoc)]>");
	//println("Unit Risk: <stars[calculateUnitSizeRating([size | <_, size> <- unitLoc], totalLoc)]>");
	//println("Complexity: <stars[calculateComplexityRating(unitLoc, unitCc, totalLoc)]>");
	println("Duplication: <dupCount>");
}

