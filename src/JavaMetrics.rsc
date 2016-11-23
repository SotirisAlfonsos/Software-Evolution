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

void main(loc projectLoc){
	num totalTime = userTime();
	st = now();
	println("Analysis started at: <printTime(st, "HH:mm:ss")> (UTC)");
	
	list[str] stars = ["--", "-", "o", "+", "++"];

	num analysis = userTime();
	print("Creating M3 Model for project. ");
	M3 project = createM3FromEclipseProject(projectLoc);
	println("(<usertimeToMin(userTime() - analysis)> minutes)");
	
	println();
	print("Acquiring SLoC...");
	analysis = userTime();
	int totalLoc = countLinesInProject(project);
	println("(<usertimeToMin(userTime() - analysis)> minutes)");
	println(" - Project SLoC: <totalLoc> lines");
	
	println();
	print("Acquiring Cyclomatic Complexity per unit...");
	analysis = userTime();
	lrel[loc mloc, int complexity] unitCc = calculateUnitComplexity(project);
	println("(<usertimeToMin(userTime() - analysis)> minutes)");
	println(" - Largest unit complexity: <max(unitCc<complexity>)> paths");
	
	println();
	print("Acquiring SLoC per unit...");
	analysis = userTime();
	lrel[loc mloc, int size] unitLoc = countUnitLines(unitCc<mloc>);
	println("(<usertimeToMin(userTime() - analysis)> minutes)");
	println(" - Largest unit size: <max(unitLoc<size>)> lines");
	
	println();
	print("Acquiring duplicates...");
	analysis = userTime();
	int dupCount = code_Duplication(getSource());
	println("(<usertimeToMin(userTime() - analysis)> minutes)");
	println(" - Duplication: <toReal(dupCount * 100)/totalLoc>%");
	
	volumeRating      = calculateLocRating(totalLoc);
	duplicationRating = calculateDuplicationRating(dupCount, totalLoc);
	<unitRating, unitSizes, unitPercent>      = calculateUnitSizeRating(unitLoc<size>, totalLoc);
	<complexityRating, ccSizes, ccPercent>    = calculateComplexityRating(unitLoc, unitCc, totalLoc);
	
	analysability = round(toReal(sum([volumeRating, duplicationRating, unitRating])) / 3);
	changeability = sum([complexityRating, duplicationRating, 1]) / 2;
	testability   = sum([complexityRating, unitRating, 1]) / 2;
	
	println();
	println("================ Metrics ================");
	println("= Volume:\t<stars[volumeRating]>");
	println("= Unit Risk:\t<stars[unitRating]>");
	println("= Complexity:\t<stars[complexityRating]>");
	println("= Duplication:\t<stars[duplicationRating]>");
	println("= - - - - - - - - - - - - - - - - - - - -");
	println("= Analysability: <stars[analysability]>");
	println("= Changeability: <stars[changeability]>");
	println("= Stability:\t N/A");
	println("= Testability:\t <stars[testability]>");
	println("=========================================");
	println();
	println("================ Details ================");
	println("= Unit Size: (Category | Percentage | # of lines)");
	println("= - Small:\t<unitPercent[0]>%\t(<unitSizes[0]>)");
	println("= - Medium:\t<unitPercent[1]>%\t(<unitSizes[1]>)");
	println("= - Large:\t<unitPercent[2]>%\t(<unitSizes[2]>)");
	println("= - Very large:\t<unitPercent[3]>%\t(<unitSizes[3]>)");
	println("= - - - - - - - - - - - - - - - - - - - -");
	println("= Unit Complexity: (Category | Percentage | McCabe Complexity)");
	println("= - Simple:\t<ccPercent[0]>\t(<ccSizes[0]>)");
	println("= - Moderate:\t<ccPercent[1]>\t(<ccSizes[1]>)");
	println("= - Complex:\t<ccPercent[2]>\t(<ccSizes[2]>)");
	println("= - Very complex:\t<ccPercent[3]>\t(<ccSizes[3]>)");
	println("=========================================");
	println();
	println("=========== Biggest Culprits ============");
	println("= Unit Size:");
	for(<mloc, metric> <- sort(unitLoc, bool(a,b){ return a[1] > b[1]; })[..5]){
		println("= <metric>\t<mloc>");
	}
	println("= - - - - - - - - - - - - - - - - - - - -");
	println("= Unit Complexity:");
	for(<mloc, metric> <- sort(unitCc, bool(a,b){ return a[1] > b[1]; })[..5]){
		println("= <metric>\t<mloc>");
	}
	println("=========================================");
	
	println();
	st = now();
	println("Analysis done at: <printTime(st, "HH:mm:ss")> (UTC)");
	println("Time elapsed: <usertimeToMin(userTime() - totalTime)> minutes.");
}

real usertimeToMin(num ut){
	return (toReal(ut) / pow(10, 9) / 60);
}