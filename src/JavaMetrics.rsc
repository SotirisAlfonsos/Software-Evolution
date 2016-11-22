module JavaMetrics

import JavaMetrics::Volume;
import JavaMetrics::CyclomaticComplexity;
import JavaMetrics::SigMappings;

import IO;
import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;

void main(loc project){
	list[str] stars = ["--", "-", "o", "+", "++"];

	int totalLoc = countLinesInProject(project);
	lrel[str, int] unitLoc = countUnitLines(project);
	rel[str, int] unitCc   = calculateUnitComplexity(project);
	// todo: duplication
	println("Volume: <stars[calculateLocRating(totalLoc)]>");
	println("Unit Risk: <stars[calculateUnitSizeRating([size | <_, size> <- unitLoc], totalLoc)]>");
	println("Complexity: <stars[calculateComplexityRating(unitLoc, unitCc, totalLoc)]>");
}

