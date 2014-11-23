//#define OUT 0

#ifdef OUT
#include<stdio.h>
#endif

void swap(int *p, int *q);
void shift(int *a, int *b, int *c, char *mask);
void doop(int *a, int *b, int *c, char *mask);


int main(void)
{
  char mask[2] = {0x0,0x0};
  int a=5;
  int b=9;
  int c=0;
  int adiv = 3;
  int bdiv = 12;

// Store bytes
  mask[0] = 0xf;
  mask[1] = 0x2;

#ifdef OUT
  printf("orig: a: %d, b: %d, c: %d\n", a, b, c);
#endif

  shift(&a,&b, &c, &mask[0]);
  //  b = b << 2; //  36
  //  a = a >> 1; // 2

#ifdef OUT
  printf("shift_orig: a: %d, b: %d, c: %d\n", a, b, c);
#endif
  int *p ;
  int *q ;
  p = &a;
  q = &b;
  swap(p,q);
  // v0 should have a = 36
  a = *p;
  // v1 should have b = 2
  b = *q;
  // v0 stores the sum 36
#ifdef OUT
  printf("swap: a: %d, b: %d, c: %d\n", a, b,c);
#endif

  // Now test for loops and branches.
  // b = 2; c = 87
  while (b >= 0) {
    c = c - b;
    --b;
  }
  // b = -1; c = 84
  if (b < 3) {
    b = 48;
  }
  // b = 48

#ifdef OUT
  printf("final: a: %d, b: %d, c: %d\n", a, b,c);
#endif
  // a = 36; b = 48; c = 84;

  // Test for div
  //a = a / adiv; // 12
  //a = b / bdiv ; // 4
#ifdef OUT
  printf("final div: a: %d, b: %d, c: %d\n", a, b,c);
#endif
  return a + b + c; // 36 + 48 + 84 = 168
}

void swap(int *p, int *q)
{
  int temp;
  temp = *p;
  *p=*q;
  *q=temp;
}

void shift(int  *a, int *b, int *c, char *mask) {
  char l = *(++mask);
  char v = *(--mask);
  int comp = 2;
  if (l <= comp) 
    *b = *b << comp; //  36

  *a = *a >> 1; // 2
  doop(a, b, c, &v);

}

void doop(int *a, int *b, int *c, char *mask) {
  *c = (*a * *b)  + *mask; // 87
}
