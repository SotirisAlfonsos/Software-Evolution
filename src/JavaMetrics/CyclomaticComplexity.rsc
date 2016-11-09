module JavaMetrics::CyclomaticComplexity

import lang::java::jdt::m3::Core;
import lang::java::m3::AST;
 
import Prelude;

public int calculateCc(Declaration d){
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
	}
	return result;
}


public void debug(){
	m = createM3FromEclipseProject(|project://MetricTest|);
	cs = toList(classes(m));
	for(c <- cs){
		classAst = createAstFromFile(c, true);
		visit(classAst){
			case x:\method(_, str name, _, _): println("<name>, <calculateCc(x)>");
			case x:\method(_, str name, _, _,_): println("<name>, <calculateCc(x)>");
		}
	}
}