
#define N 1000
#include "foo.h"
#include "foo.h"


int main()
{
int A[N];
int i;
for (i=0; i<N; i++) {
A[i] = my_sqrt(i);
}

#undef N 
int total = array_sum(A, N);
// Our own I/O function:
write("The total is: ");
write(total);
write("\n");
return 0;
}
