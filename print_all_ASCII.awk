#!/bin/awk -f
BEGIN{
	for (i=33; i < 127; i++){
		if (i%32 == 0)
			printf("\n");
		printf("%c", i)
	}
	printf("\n");
}
