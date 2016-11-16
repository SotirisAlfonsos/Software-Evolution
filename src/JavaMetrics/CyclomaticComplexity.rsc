module JavaMetrics::CyclomaticComplexity

import lang::java::jdt::m3::Core;
import lang::java::jdt::m3::AST;
import Prelude;
import util::ValueUI;

rel[loc, int] calculateUnitComplexity(loc project){
	M3 projectModel = createM3FromEclipseProject(project);
	rel[loc, int] complexities = {};
	
	for(f <- files(projectModel)){
		classAst = createAstFromFile(f, true);
		println(classAst@src);
		visit(classAst){
			 case x:\method(_,_,_,_): complexities += <x@src, calculateComplexity(x)>;
			 case x:\method(_,_,_,_,_): complexities += <x@src, calculateComplexity(x)>;
		}
	}
	return complexities;
}

int calculateComplexity(Declaration d){
	// Borrowed from Landman et al. 
	// Empirical analysis of the relationship between CC and
	// SLOC in a large corpus of Java methods and C functions
	int result = 1;
	visit(d){
		case \case(_): result += 1;
		
		case \catch(_): result += 1;
		
		case \for(_,_,_): result += 1;
		case \for(_,_,_,_): result += 1;
		case \foreach(_,_,_): result += 1;
		
		case \if(_,_): result += 1;
		case \if(_,_,_): result += 1;
		
		case \do(_,_): result += 1;
		case \while(_,_): result += 1;
		
		case infix(_, "&&", _): result += 1;
		case infix(_, "||", _): result += 1;
	}
	return result;
}


public void example(){
	text(sort(calculateUnitComplexity(|project://smallsql0.21_src|), bool(a, b){ return a[1] < b[1]; }));
}