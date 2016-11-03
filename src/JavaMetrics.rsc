module JavaMetrics

import JavaMetrics::LineCount;

import IO;
import Prelude;
import lang::java::jdt::m3::Core;
import lang::java::m3::AST;


void main(){
	loc project = |project://MetricTest/|;
	int LoC = countLinesInLocation(project);
	println("<project> has <LoC> lines of code.");	
}

