module JavaMetrics::Hashing

import Prelude;

int hashSimple(str val){
	int p = 263;
	int h = 1;
	
	for(c <- chars(val)){
		h *= p;
		h += c;
	}
	
	return h;
}

tuple[real, int] hash(str val, real prevHash = 0., str prevValue = "", int hashLength = 0){
	assert (size(prevValue) <= hashLength) : "Previous value cannot be bigger than the hashlength.
	' Hash length:\t<hashLength>
	' Previous value: <prevValue>
	";
	int p = 263;
	//int q = 2147483647;
	
	int i = 0;
	for(c <- chars(prevValue)){
		i+= 1;
		prevHash -= c * pow(p, hashLength - i);
	}
	for(c <- chars(val)){
		prevHash *= p;
		prevHash += c;
	}
	hashLength = hashLength - i + size(val);

	return <prevHash, hashLength>;
}

test bool testRabinKarp(list[str] ls){
	int blockSize = 6;
	if(size(ls) < blockSize) return true;
	str initValue = intercalate("", ls[0..blockSize]);
	<h, l> = hash(initValue);
	int i = blockSize;
	int j = 0;
	for(line <- ls[0..-blockSize]){	
		str oldValue = line;
		<h, l> = hash(
			ls[i],
			prevHash = h,
			prevValue = oldValue,
			hashLength = l
		);
		j += 1;
		i += 1;
	}
	str tailValue = intercalate("", ls[-blockSize..]);
	println(h);
	return <h,l> := hash(tailValue);
}