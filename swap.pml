#define N (3)
#define LOCK(x) atomic { (!x) -> x = true; }
#define UNLOCK(x) x = false;
bool initialized;
int vals[N];
int nProcs;
bool procMutex;
bool locks[N];
//ltl liveness { eventually (always (nProcs == 0)) }
proctype doWork(int idx) {
	int randVal = 0;	// randVal should be in the range from [0, N)
	do
		:: (randVal < N-1) -> randVal++
		:: break
	od;
	int min;
	int max;
	if
		:: (randVal < idx) ->
				min = randVal;
				max = idx;
		:: else ->
				min = idx;
				max = randVal;
	fi;
	if
		:: (randVal == idx) -> skip;
		:: else ->
			LOCK(locks[min]);
			LOCK(locks[max]);
			LOCK(procMutex);
			nProcs++;
			UNLOCK(procMutex);
			int temp = vals[min];
			vals[min] = vals[max];
			vals[max] = temp
			LOCK(procMutex);
			nProcs--;
			UNLOCK(procMutex);
			UNLOCK(locks[min]);
			UNLOCK(locks[max]);
	fi;
}
init {
	int i;
	// Init values array
	for(i: 0 .. N-1) {
		vals[i] = i;
	}
	initialized = true;
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
		assert(found)
	}
}
