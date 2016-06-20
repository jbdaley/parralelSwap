#define N (3)
#define LOCK(x) atomic { (!x) -> x = true; }
#define UNLOCK(x) x = false;
int vals[N];
int nProcs;
bool procMutex;
bool locks[N];
ltl liveness { eventually (always (nProcs == 0)) }
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
			LOCK(locks[min])
			LOCK(locks[max])
			int temp = vals[min];
			vals[min] = vals[max];
			vals[max] = temp
			UNLOCK(locks[min])
			UNLOCK(locks[max])
	fi;
	LOCK(procMutex)
	nProcs--;
	UNLOCK(procMutex)
}
init {
	int i; // rhs is a const expression
	// Init values array
	for(i: 0 .. N-1) {
		vals[i] = i;
	}
	nProcs = N;
	// Start processes
	for(i: 0 .. N-1) {
		run doWork( i );
	}

	// Wait for process termination
	(_nr_pr == 1) // Alternatively "(nProcs == 0)"

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
