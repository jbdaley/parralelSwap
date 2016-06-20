#define N (3)
int vals[N];
proctype doWork(int idx) {
	int nr = 0;	/* pick random value  */
	do
		:: (nr < N-1) -> nr++		/* randomly increment */
		:: break	/* or stop            */
	od;
	// TODO: Replace this atomic block
	atomic {
		int temp = vals[idx];
		vals[idx] = vals[nr];
		vals[nr] = temp
	}
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
		assert(found)
	}
}
