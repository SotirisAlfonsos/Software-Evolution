module JavaMetrics

import JavaMetrics::CyclomaticComplexity;
import JavaMetrics::Duplication;
import JavaMetrics::Volume;
import JavaMetrics::SigMappings;
import JavaMetrics::Helpers;

import DateTime;
import IO;
import Prelude;

import lang::java::jdt::m3::Core;
import lang::java::m3::AST;

import util::Benchmark;
import util::Math;

void main(loc projectDir){
	num totalTime = userTime();
	st = now();
	println("Analysis started at: <printTime(st, "HH:mm:ss")> (UTC)");
	
	list[str] stars = ["--", "-", "o", "+", "++"];

	num analysis = userTime();

	println("Acquiring SLoC ");
	analysis = userTime();
	int totalLoc = countLinesInProject(projectDir);
	println("(<precision(usertimeToMin(userTime() - analysis), 4)> minutes)");
	println(" - Project SLoC: <totalLoc> lines");
	
	println("Creating method ASTs");
	analysis = userTime();
	lrel[loc location, Declaration ast, str name] projectMethods = getMethods(projectDir);
	println("(<precision(usertimeToMin(userTime() - analysis), 4)> minutes)");
	
	println();
	println("Acquiring SLoC per unit ");
	analysis = userTime();
	lrel[loc mloc, int size] unitLoc = countUnitLines(projectMethods<location>);
	println("(<precision(usertimeToMin(userTime() - analysis), 4)> minutes)");
	println(" - Largest unit size: <max(unitLoc<size>)> lines");
	
	println();
	println("Acquiring duplicates... ");
	analysis = userTime();
	int dupCount = code_Duplication(getHashes(),totalLoc, projectMethods<name>);
	println("(<precision(usertimeToMin(userTime() - analysis), 4)> minutes)");
	int size1 = 0;
	for (so <- getSource()) size1 = size1 + size(so);
	println(" - Lines of Duplication: <dupCount>");
	println(" - Duplication: <precision(toReal(dupCount * 100)/size1, 2)>%");
	println("Total elapsed time: (<precision(usertimeToMin(userTime() - totalTime), 4)> minutes)");
}

real usertimeToMin(num ut){
	return precision(toReal(ut) / pow(10, 9) / 60, 5);
}