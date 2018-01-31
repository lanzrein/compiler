
/*

Lexer test file.

Since it's just for the lexer, we won't even bother
to attempt correct C syntax.

*/


0                                                /* INTCONST */
47                                               /* INTCONST */
-3                                               /* MINUS INTCONST */
123456789012345678901234567890123456789012345678 /* INTCONST */
-65536                                           /* MINUS INTCONST */


4.0                                              /* REALCONST */
-0.5                                             /* MINUS REALCONST */
3.14159265358979323846264338327950288419716939937/* REALCONST */
4e10                                             /* REALCONST */
6.0221409E23                                     /* REALCONST */
1e-10                                            /* REALCONST */
-2E-2                                            /* MINUS REALCONST */
.1                                               /* REALCONST */
.1E+1                                            /* REALCONST */

$2.99                                            /* error then REALCONST */
