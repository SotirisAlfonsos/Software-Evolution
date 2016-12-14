module JavaMetrics::Helpers

import IO;
import String;

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
public rel[loc, Declaration] getMethods(loc projectDir){
	rel[loc, Declaration] methodLocs = {};
	
	for(f <- crawl(projectDir, ".java")){
		classAst = createAstFromFile(f, false);
		visit(classAst){
			 case x:\method(_,str name,_,_): methodLocs +=      <x@src, x>;
			 case x:\method(_,str name,_,_,_): methodLocs +=    <x@src, x>;
			 case x:\constructor(str name,_,_,_): methodLocs += <x@src, x>;
		}
	}
	return methodLocs;
}
