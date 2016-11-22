module JavaMetrics

import JavaMetrics::CyclomaticComplexity;
import JavaMetrics::Duplication;
import JavaMetrics::Volume;
import JavaMetrics::SigMappings;

import IO;
import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;

import util::Benchmark;
import util::Math;

void main(loc project){
	list[str] stars = ["--", "-", "o", "+", "++"];

	println("Acquiring LoC");
	num analysis = userTime();
	int totalLoc = countLinesInProject(project);
	println("Duration <usertimeToMin(userTime() - analysis)> minutes");
	
	println("Acquiring Unit LoC");
	analysis = userTime();
	lrel[str, int] unitLoc = countUnitLines(project);
	println("Duration <usertimeToMin(userTime() - analysis)> minutes");
	
	println("Acquiring Unit Complexity");
	analysis = userTime();
	rel[str, int] unitCc   = calculateUnitComplexity(project);
	println("Duration <usertimeToMin(userTime() - analysis)> minutes");
	
	//println("Acquiring duplicates");
	//analysis = userTime();
	//int dupCount = countDuplicatesInString(getSource());
	//println("Duration <usertimeToMin(userTime() - analysis)> minutes");
	
	println("Volume: <stars[calculateLocRating(totalLoc)]>");
	println("Unit Risk: <stars[calculateUnitSizeRating([size | <_, size> <- unitLoc], totalLoc)]>");
	println("Complexity: <stars[calculateComplexityRating(unitLoc, unitCc, totalLoc)]>");
	//println("Duplication: <dupCount * 100 / totalLoc>");
}

real usertimeToMin(num ut){
	return (toReal(ut) / pow(10, 9) / 60);
}