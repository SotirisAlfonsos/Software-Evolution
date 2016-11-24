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
	println("(<precision(usertimeToMin(userTime() - analysis), 4)> minutes)");
	
	println();
	println("Acquiring SLoC ");
	analysis = userTime();
	int totalLoc = countLinesInProject(project);
	println("(<precision(usertimeToMin(userTime() - analysis), 4)> minutes)");
	println(" - Project SLoC: <totalLoc> lines");
	
	println();
	println("Acquiring Cyclomatic Complexity per unit ");
	analysis = userTime();
	lrel[loc mloc, int complexity] unitCc = calculateUnitComplexity(project);
	println("(<precision(usertimeToMin(userTime() - analysis), 4)> minutes)");
	println(" - Largest unit complexity: <max(unitCc<complexity>)> paths");
	
	println();
	println("Acquiring SLoC per unit ");
	analysis = userTime();
	lrel[loc mloc, int size] unitLoc = countUnitLines(unitCc<mloc>);
	println("(<precision(usertimeToMin(userTime() - analysis), 4)> minutes)");
	println(" - Largest unit size: <max(unitLoc<size>)> lines");
	
	println();
	println("Acquiring duplicates... ");
	analysis = userTime();
	int dupCount = code_Duplication(getSource());
	println("(<precision(usertimeToMin(userTime() - analysis), 4)> minutes)");
	println(" - Duplication: <precision(toReal(dupCount * 100)/totalLoc, 2)>%");
	
	volumeRating      = calculateLocRating(totalLoc);
	duplicationRating = calculateDuplicationRating(dupCount, totalLoc);
	<unitRating, unitSizes, unitPercent>      = calculateUnitSizeRating(unitLoc<size>, totalLoc);
	<complexityRating, ccSizes, ccPercent>    = calculateComplexityRating(unitLoc, unitCc, totalLoc);
	
	analysability   = round(toReal(sum([volumeRating, duplicationRating, unitRating])) / 3);
	changeability   = sum([complexityRating, duplicationRating, 1]) / 2;
	testability     = sum([complexityRating, unitRating, 1]) / 2;
	maintainability = sum([volumeRating, duplicationRating, unitRating, complexityRating, 2]) / 4; 
	
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
	println("= Maintainability:\t <stars[maintainability]>");
	println("=========================================");
	println();
	println("================ Details ================");
	println("= Unit Size: (Category | Percentage | # of lines)");
	println("= - Small:\t<unitPercent[0]>%\t(<unitSizes[0]>)");
	println("= - Medium:\t<unitPercent[1]>%\t(<unitSizes[1]>)");
	println("= - Large:\t<unitPercent[2]>%\t(<unitSizes[2]>)");
	println("= - Very large:\t<unitPercent[3]>%\t(<unitSizes[3]>)");
	println("= - - - - - - - - - - - - - - - - - - - -");
	println("= Unit Complexity: (Category | Percentage | # of lines)");
	println("= - Simple:\t  <ccPercent[0]>%\t(<ccSizes[0]>)");
	println("= - Moderate:\t  <ccPercent[1]>%\t(<ccSizes[1]>)");
	println("= - Complex:\t  <ccPercent[2]>%\t(<ccSizes[2]>)");
	println("= - Very complex: <ccPercent[3]>%\t(<ccSizes[3]>)");
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
	return precision(toReal(ut) / pow(10, 9) / 60, 5);
}