program sncSimple

option +r;
option -c;
option +s;

int val;
assign val to "val";
monitor val;

int statee;
assign statee to "state";

ss ss1 {
	state init {
		entry {
			printf("sncSimple: init\n");
			statee = 0;
			pvPut(statee);
		}

		when (val == 1) {} state s1
	}

	state s1 {
		entry {
			printf("sncSimple: switching to s1\n");
			statee = 1;
			pvPut(statee);
		}

		when (val == 2) {} state s2
	}

	state s2 {
		entry {
			printf("sncSimple: Changing to s2\n");
			statee = 2;
			pvPut(statee);
		}

		when (delay(5)) {} state end
	}

	state end {
		entry {
			printf("sncSimple: Changing to end\n");
			statee = 3;
			pvPut(statee);
		}

		// seq *needs* at least one transition in a state
		when (0) {} state end
	}
}
