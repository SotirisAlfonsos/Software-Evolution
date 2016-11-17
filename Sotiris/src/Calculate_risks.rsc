module Calculate_risks

import IO;

public void calcRisks(tuple[int,str] lines, set[tuple[str,str]] cc,set[tuple[str,int]] us) {
	for (i<-cc) {
		visit(i){
			case <str l,"without much risk"> : println(l);
		};
		
	}
}