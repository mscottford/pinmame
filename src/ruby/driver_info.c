#include "../driver.h"

int driver_count() {
	int num_games = 0;
	while (drivers[num_games] != NULL) {
		num_games++;
	}
	return num_games;
}

char** driver_names() {
	int num_games = driver_count();
	char* names[num_games];
	
	int index;
	for (index = 0; index < num_games; index++) {
		names[index] = drivers[index]->name;
	}
	
	return names;
}

struct GameDriver* driver_at_index(int index) {
	return drivers[index];
}