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
	println("Analysis started at: <st.hour>:<st.minute>.<st.second> (UTC)");
	
	list[str] stars = ["--", "-", "o", "+", "++"];

	num analysis = userTime();
	println("Creating M3 Model for project...");
	M3 project = createM3FromEclipseProject(projectLoc);
	println("\tDuration <usertimeToMin(userTime() - analysis)> minutes");
	
	println();
	println("Acquiring SLoC...");
	analysis = userTime();
	int totalLoc = countLinesInProject(project);
	println("\tProject SLoC: <totalLoc> lines");
	println("\tDuration <usertimeToMin(userTime() - analysis)> minutes");
	
	println();
	println("Acquiring Cyclomatic Complexity per unit...");
	analysis = userTime();
	lrel[loc mloc, int complexity] unitCc = calculateUnitComplexity(project);
	println("\tLargest unit complexity: <max(unitCc<complexity>)> paths");
	println("\tDuration <usertimeToMin(userTime() - analysis)> minutes");
	
	println();
	println("Acquiring SLoC per unit...");
	analysis = userTime();
	lrel[loc mloc, int size] unitLoc = countUnitLines(unitCc<mloc>);
	println("\tLargest unit size: <max(unitLoc<size>)> lines");
	println("\tDuration <usertimeToMin(userTime() - analysis)> minutes");
	
	println();
	println("Acquiring duplicates... (this might take a while)");
	analysis = userTime();
	int dupCount = code_Duplication(getSource());
	println("Duration <usertimeToMin(userTime() - analysis)> minutes");
	
	println();
	println("Volume: <stars[calculateLocRating(totalLoc)]>");
	println("Unit Risk: <stars[calculateUnitSizeRating(unitLoc<size>, totalLoc)]>");
	println("Complexity: <stars[calculateComplexityRating(unitLoc, unitCc, totalLoc)]>");
	println("Duplication: <toReal(dupCount) * 100 / totalLoc>");
	
	println();
	st = now();
	println("Analysis done at: <st.hour>:<st.minute>.<st.second> (UTC)");
	println("Time elapsed: <usertimeToMin(userTime() - totalTime)> minutes.");
}

real usertimeToMin(num ut){
	return (toReal(ut) / pow(10, 9) / 60);
}