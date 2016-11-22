module JavaMetrics::Duplication

import JavaMetrics::SourceTransformer;
import lang::java::jdt::m3::Core;
import Prelude;

int countDuplicatesInString(list[str] pureSrc, int length=6){
	list[str] src = removeSimpleLines(pureSrc);
	return sum(getDuplicateLines(src, length));
}

// todo: split this into two functions
list[int] getDuplicateLines(list[str] src, int length){
		int sourceSize = size(src);
		println("<sourceSize>"); //DEBUG
		list[int] sourceRange = [0..sourceSize];
		list[bool] mapping = [false | _ <- sourceRange];
		for(int i <- sourceRange){
			println("<i>"); //DEBUG
			if(mapping[i]) continue;
			for(int j <- [i + 1 .. sourceSize]){
				mapping[j] = mapping[j] || src[i] == src[j];
			}
		}
		int consecutiveCounter = 0;
		return for(int i <- sourceRange){
			if(mapping[i]){
				consecutiveCounter += 1;
			} else if(consecutiveCounter >= length){
				append consecutiveCounter;
				consecutiveCounter = 0;
			} else {
				consecutiveCounter = 0;
			}
		}
	}
