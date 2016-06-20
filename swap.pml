#define N (3)
int vals[N];
bool locks[N];
proctype doWork(int idx) {
	int nr = 0;	/* pick random value  */
	do
		:: (nr < N-1) -> nr++		/* randomly increment */
		:: break	/* or stop            */
	od;
	int min;
	int max;
	if
		:: (nr < idx) ->
				min = nr;
				max = idx;
		:: else ->
				min = idx;
				max = nr;
	fi;
	if
		:: (nr == idx) -> skip;
		:: else ->
			atomic { 
				(!locks[min]) -> locks[min] = true;
			}
			atomic {
				(!locks[max]) -> locks[max] = true;
			}
			int temp = vals[min];
			vals[min] = vals[max];
			vals[max] = temp
			locks[min] = false;
			locks[max] = false;
	fi;
}
init {
	int i; // rhs is a const expression
	// Init values array
	for(i: 0 .. N-1) {
		vals[i] = i;
	}
	// Start processes
	for(i: 0 .. N-1) {
		run doWork( i );
	}

	// Wait for process termination
	(_nr_pr == 1)

	// Validate array is a permutation
	for(i: 0 .. N-1) {
		int j;
		bool found;
		found = false;
		for(j: 0 .. N-1) {
			if
				:: vals[j] == i ->
						found = true;
				:: else skip;
			fi;
		}
		printf("%d\n", vals[i]);
		assert(found)
	}
}
