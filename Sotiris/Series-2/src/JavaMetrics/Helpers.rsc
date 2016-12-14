module JavaMetrics::Helpers

import lang::java::jdt::m3::AST;

// Taken from of "demo::common::Crawl" 
public list[loc] crawl(loc dir, str suffix){
  res = [];
  for(str entry <- listEntries(dir)){
      loc sub = dir + entry;
      if(isDirectory(sub)) {
          res += crawl(sub, suffix);
      } else {
	      if(endsWith(entry, suffix)) { 
	         res += [sub]; 
	      }
      }
  };
  return res;
}

@doc {
	.Synopsis
	Get all the names (str), locations (loc) and ASTs (Declaration) of java methods in a directory.
}
public rel[str name, loc location, Declaration ast] getMethods(loc projectDir){
	set[loc] methodLocs = {};
	
	for(f <- crawl(projectDir, "*.java")){
		classAst = createAstFromFile(f, false);
		visit(classAst){
			 case x:\method(_,str name,_,_): methodLocs +=      <name, x@src, x>;
			 case x:\method(_,str name,_,_,_): methodLocs +=    <name, x@src, x>;
			 case x:\constructor(str name,_,_,_): methodLocs += <name, x@src, x>;
		}
	}
	return methodLocs;
}
