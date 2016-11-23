module JavaMetrics

import JavaMetrics::CyclomaticComplexity;
import JavaMetrics::Duplication;
import JavaMetrics::Volume;
import JavaMetrics::SigMappings;

import DateTime;
import IO;
import Prelude;

import lang::java::jdt::m3::Core;
import lang::java::m3::AST;

import util::Benchmark;
import util::Math;

void main(loc project){
	st = now();
	println("Analysis started at: <st.hour>:<st.minute>.<st.second> (UTC)");
	
	list[str] stars = ["--", "-", "o", "+", "++"];

	println();
	println("Acquiring SLoC...");
	num analysis = userTime();
	num totalTime = userTime();
	int totalLoc = countLinesInProject(project);
	println("\tProject SLoC: <totalLoc> lines");
	println("\tDuration <usertimeToMin(userTime() - analysis)> minutes");
	
	println();
	println("Acquiring SLoC per unit...");
	analysis = userTime();
	lrel[str hash, int size] unitLoc = countUnitLines(project);
	println("\tLargest unit size: <max(unitLoc<size>)> lines");
	println("\tDuration <usertimeToMin(userTime() - analysis)> minutes");
	
	println();
	println("Acquiring Cyclomatic Complexity per unit...");
	analysis = userTime();
	rel[str hash, int size] unitCc = calculateUnitComplexity(project);
	println("\tLargest unit complexity: <max(unitCc<size>)> paths");
	println("\tDuration <usertimeToMin(userTime() - analysis)> minutes");
	
	//println();
	//println("Acquiring duplicates... (this might take a while)");
	//analysis = userTime();
	//int dupCount = countDuplicatesInString(getSource());
	//println("Duration <usertimeToMin(userTime() - analysis)> minutes");
	
	println();
	println("Volume: <stars[calculateLocRating(totalLoc)]>");
	println("Unit Risk: <stars[calculateUnitSizeRating([size | <_, size> <- unitLoc], totalLoc)]>");
	println("Complexity: <stars[calculateComplexityRating(unitLoc, unitCc, totalLoc)]>");
	//println("Duplication: <dupCount * 100 / totalLoc>");
	
	println();
	println("Time elapsed: <usertimeToMin(userTime() - totalTime)> minutes.");
	st = now();
	println("Analysis done at: <st.hour>:<st.minute>.<st.second> (UTC)");
}

real usertimeToMin(num ut){
	return (toReal(ut) / pow(10, 9) / 60);
}