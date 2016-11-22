module JavaMetrics::Duplication

import JavaMetrics::SourceTransformer;
import lang::java::jdt::m3::Core;
import Prelude;

// incorrect and slow
int countDuplicatesInString(list[str] pureSrc, int length=6){
	list[str] src = removeSimpleLines(pureSrc);
	return getDuplicateCountInMethod(src);
}

int getDuplicateCountInMethod(list[str] src, int length = 6){
	int sourceSize = size(src);
	if(sourceSize < 2 * length){
		return 0;
	}
	list[int] sourceRange = [0..sourceSize];
	list[bool] mapping = [false | _ <- sourceRange];
	
	for(int i <- [0..sourceSize - length]){
		list[str] slice = src[i..i + length];
		if(mapping[i]) continue;
		for(int j <- [i + length .. sourceSize - length]){
			mapping[j] = mapping[j] || slice == src[j .. j + length];
		}
	}
	int duplicateCounter = 0;
	int previousMapping = -1;
	for(int i <- sourceRange){
		if(!mapping[i]){
			if(previousMapping > -1 && i - previousMapping < length){
				duplicateCounter += i - previousMapping;
			} else {
				duplicateCounter += length;
			}
			previousMapping = i;
		}
	}
	return duplicateCounter;
}

int getDuplicateCount(list[str] srcA, list[str] srcB, int length = 6){
	tuple[int A, int B] sizes = <size(srcA), size(srcB)>;
	if(sizes.A < length || sizes.B < length) return 0;
	
	list[bool] mapping = [false | _ <- [0..sizes.B]];
	
	for(int i <- [0 .. sizes.A - length]){
		list[str] slice = srcA[i.. i + length];
		if(mapping[i]) continue;
		for(int j <- [0 .. sizes.B - length]){
			mapping[j] = mapping[j] || slice == srcB[j .. j + length];
		}
	}
	
	int duplicateCounter = 0;
	int previousMapping = -1;
	for(int i <- [0..sizes.B]){
		if(!mapping[i]){
			if(previousMapping > -1 && i - previousMapping < length){
				duplicateCounter += i - previousMapping;
			} else {
				duplicateCounter += length;
			}
			previousMapping = i;
		}
	}
	return duplicateCounter;
}