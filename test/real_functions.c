#include "real_functions.h"

int real_wrapvoidfunc0_called = 0;
void wrapvoidfunc0()
{
  real_wrapvoidfunc0_called++;
}

void wrapvoidfunc20(int a, int b, int c, int d, int e, int f, int g, int h, int i, int j, int k, int l, int m, int n, int o, int p, int q, int r, int s, int t)
{
}

int wrapvaluefunc20(int a, int b, int c, int d, int e, int f, int g, int h, int i, int j, int k, int l, int m, int n, int o, int p, int q, int r, int s, int t)
{
    return a + b + c + d + e + f + g + h + i + j + k + l + m + n + o + p + q + r + s + t;
}

int wrapvalue0()
{
    return 42;
}
