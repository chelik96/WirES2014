#include <sys/types.h>
#include <unistd.h>

int main ()
{
	pid_t pid;

	switch (pid = fork ()) {
		case -1:
			perror("fork error");
			return 1;
		case 0:
			execl("/bin/ls", "ls", "-l", (char *) 0);
			perror("exec error");
			return 1;
		default:
			wait((int *) 0);
			printf("program ls finished\n");
			return 0;
	}
}