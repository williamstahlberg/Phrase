//
//  C_combine.c
//  Phrase
//
//  Created by subli on 5/28/20.
//  Copyright © 2020 subli. All rights reserved.
//

#define DEBUG_SLOW 0

#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdbool.h>
#include <ctype.h>
#if DEBUG_SLOW
#include <unistd.h>
#endif

#define BUF_SIZE 1024*1024 /* Assume no line is longer than 1 MB. */

static double *Global_file_prog = NULL;

static void init_globals() {
	if (Global_file_prog == NULL)
		Global_file_prog = malloc(sizeof(double));
}

static void set_globals(double file_prog) {
	*Global_file_prog = file_prog;
}

void C_combine_get_globals(double *file_prog) {
	*file_prog = *Global_file_prog;
}

void C_combine(const char *path_A, const char *path_B, const char *output_path, int max_width) {
	init_globals();
	
	FILE *fp_A = fopen(path_A, "r");
	FILE *fp_B = fopen(path_B, "r");
	FILE *fp_output = fopen(output_path, "w+");

	printf("\n------------------\n");
	printf("C: %s\n", path_A);
	printf("C: %s\n", path_B);
	printf("C: %s\n", output_path);
	printf("------------------\n");

	fseek(fp_A, 0L, SEEK_END);
	off_t f_A_size = ftello(fp_A);
	fseek(fp_A, 0L, SEEK_SET);
	
	char *buf_A = malloc(sizeof(char) * (BUF_SIZE + 1)); /* Freed in here. */
	char *buf_B = malloc(sizeof(char) * (BUF_SIZE + 1)); /* Freed in here. */
	char *buf_output = malloc(sizeof(char) * (BUF_SIZE + 1)); /* Freed in here. */
	
	int prog = 0;
	while (1) {
		
		char *s_A = fgets(buf_A, BUF_SIZE + 1, fp_A);
		char *s_B = fgets(buf_B, BUF_SIZE + 1, fp_B);
		
		if (s_A == NULL && s_B == NULL) {
			break;
		} else if (s_A == NULL || s_B == NULL) {
			printf("Error: Line count is different (is there a line longer than %d bytes?).\n", BUF_SIZE);
			break;
		}
		
		sprintf(buf_output, "%.*s\x1f%.*s\n", (int)strlen(buf_B)-1, buf_B, (int)strlen(buf_A)-1, buf_A);
		if (strlen(buf_output) <= max_width) {
			char *p = buf_output;
			for ( ; *p; ++p)
				*p = tolower(*p);
			fprintf(fp_output, "%s", buf_output);
		}
		
		if (prog % 10000 == 0) {
			off_t f_A_pos = ftello(fp_A);
			set_globals((double)f_A_pos/f_A_size);
		#if DEBUG_SLOW
			usleep((int)(0.01*1000000));
		#endif
		}
		prog++;
	}
}
