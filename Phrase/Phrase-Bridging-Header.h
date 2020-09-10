//
//  Use this file to import your target's public headers that you would like to expose to Swift.
//

void C_ffind_get_globals(double *file_prog, int *results_prog);
char *C_ffind(const char *haystack_path, const char *needle, int result_limit, int *N_approx, int *error);

void C_combine_get_globals(double *file_prog);
void C_combine(const char *path_A, const char *path_B, const char *output_path, int max_width);
