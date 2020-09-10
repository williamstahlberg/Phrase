//
//  C_ffind.c
//  Phrase
//
//  Created by subli on 3/2/19.
//  Copyright © 2019 subli. All rights reserved.
//

#define DEBUG_SLOW 0

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#if DEBUG_SLOW
#include <unistd.h>
#endif

#define BUF_SIZE 1024*1024 /* 1 MB */
#define MAX_WIDTH 200

#define ERR_FOPEN 1

static double *Global_file_prog = NULL;
static int *Global_results_prog = NULL;

static void init_globals() {
	if (Global_file_prog == NULL)
		Global_file_prog = malloc(sizeof(double));
	if (Global_results_prog == NULL)
		Global_results_prog = malloc(sizeof(int));

	*Global_file_prog = 0;
	*Global_results_prog = 0;
}

static void set_globals(double file_prog, int results_prog) {
	*Global_file_prog = file_prog;
	*Global_results_prog = results_prog;
}

void C_ffind_get_globals(double *file_prog, int *results_prog) {
	*file_prog = *Global_file_prog;
	*results_prog = *Global_results_prog;
}

/* C_ffind:
 Reads file into the buffer in sections and scans it for any matches. If a text
 line is cut in the middle at the end of the buffer, the file pointer seeks back
 to the end of the last complete line. */
char *C_ffind(const char *haystack_path, const char *needle, int result_limit, int *N_approx, int *error) {
	/* Initialize globals. */
	init_globals();
	
	FILE *fp = fopen(haystack_path, "r");
	if (fp == NULL) {
		*error = ERR_FOPEN;
		return NULL;
	}

	fseek(fp, 0L, SEEK_END);
	off_t f_size = ftello(fp);
	fseek(fp, 0L, SEEK_SET);
	
	char *buf = malloc(sizeof(char) * (BUF_SIZE + 1)); /* Freed in here. */
	size_t output_len = result_limit*MAX_WIDTH;
	char *output = malloc(sizeof(char) * (output_len + 1)); /* Freed in Swift. */
	char *o = output;
	
	size_t buf_len;
	int j = 0;
	while ((buf_len = fread(buf, sizeof(char), BUF_SIZE, fp))) {
		/* Backtrack to the last \n in the buffer (if there is one). */
		char *last_ln = strrchr(buf, '\n');
		if (last_ln != NULL) {
			*last_ln = '\0';
			size_t back_len = buf_len - (last_ln-buf) - 1;
			fseek(fp, -back_len, SEEK_CUR);
		}
		
		char *b = buf;
		char *s;
		while (*b && (s = strstr(b, needle))) {
			/* Find the start of the line.*/
			char *s_start = s;
			while (s_start > buf) {
				if (*(--s_start) == '\n')
					break;
			}
			s_start++;
			
			/* Find the end of the line.*/
			char *next_ln = strchr(s, '\n');
			if (next_ln == NULL)
				next_ln = strchr(s, '\0');
			int line_len = (int)(next_ln-s_start);
			size_t output_left = output_len - (output-o);
			
			/* Check if we are done. */
			if (output_left <= 0 || j >= result_limit) {
				/* Approximate the number of total results
				 (we assume we are not using a pipe, etc.) */
				size_t pos = ftell(fp);
				fseek(fp, 0, SEEK_END);
				size_t total = ftell(fp);
				
				size_t buf_left = buf_len - (b-buf);
				float ratio = (float) (pos-buf_left)/total;
				*N_approx = (int) j/ratio;
				
				free(buf);
				fclose(fp);
				return output;
			}
			
			if (line_len <= MAX_WIDTH) { /* Skip really long entries. */
				snprintf(o, output_left, "%.*s\n", line_len, s_start);
				o += line_len+1;
				j++;
			}
			
			b = next_ln;

#if DEBUG_SLOW
			usleep((int)(0.05*1000000));
#endif
		}
		
		/* Update the progress every buf read. */
		off_t f_pos = ftello(fp);
		set_globals((double)f_pos/f_size, j);
		
	}
	
	/* We have gone through the whole file. */
	*N_approx = j;
	
	free(buf);
	fclose(fp);
	return output;
}
