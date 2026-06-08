# nqueens

this was all sparked from not being able to complete haskell - mooc - fi set 9b.hs exercise on nqueen 
could not understand the final exercise 

## ideas 

how might we think about placing queens ? 

already reduced it to a question of what column the next queen should go , what linear patterns are there ?

- [rule 1] placing next queen in same column as previous queen will always be in conflict.
- [rule 2] placing next queen in next column as previous queen will always be in conflict.
- [rule 3] placing next queen in next but one column is entirely feasible , causes no conflict 

why might the linear pattern be broken , if we always follow rule 3 what happens , how far can it take us 

- [hyp 1] use rule 3 top down and bottom up alternately , queen at top left then queen at bottom next left, queen top , followed by queen at bottom , slowly converging towards each other 


## implementation 

uses fixed grid , with some stack growth due to recursive calls 

```
difficulty remembering if it is grid[y][x] or grid[x][y] 
```

## combinatorics 

if we just threw queens onto the board in any order , how many ways could we get it wrong ?

```
n queens 

first  queen has a choice of n-0 squares 
second queen has a choice of n-1 squares 
third  queen has a choice of n-2 squares 
fourth queen has a choice of n-3 squares 
  n    queen has a choice of n-(n-1) squares or 1 
  
the last queen of a square board n x n where each queen occupies a row by itself has only one 

combinatorics of n x n board is n factorial 

3 x 3 is 3 x 2 x 1 or 6 
```

## brute force 

```
static void brute(int nqueen){
  if (nqueen > SIZE){
    solution_no ++; 
    printf("\nsolution [ %d ] for nqueens = [%d]\n",solution_no , SIZE);
    int nq = 0;
    // nth queen
    printf("[");
    for (nq = 1; nq <= SIZE ; nq ++){
      printf("(%d,%d)", nq, queen_column[nq]);
      if (nq == SIZE){ // no comma
      }else{
	printf(",");
      }
    }
    printf("]\n");
    show_solution_grid();
    printf("\n");

    // just take any solution -- the first one 
    exit(0);
    return ;
  }
  int i = 0;
  for (i = 1; i <= SIZE ; i ++){
    if (!grid[nqueen][i]){
      
      // place queen 
      dominate( nqueen , i , nqueen);
      queen_column[nqueen] = i;

      //show_grid();
      //getchar(); // wait for key press 
      
      // go try place next queen 
      brute(nqueen+1);
      
      // retract 
      un_dominate(nqueen, i, nqueen);
      queen_column[nqueen] = 0;
    }
  }
}

```

later version under queen-c directory in plain c using a static grid and binary bit twiddling to 
denote if a square is occupied or not , 

```
  // although we are placing queens on independent rows never going to have two queens on same row
  // so we could in theory eliminate bit settings for East and West entirely
  // might have a array to represent columns , if a queen is there we put a number
  // no queen can be at same column
  // might also have an array to represent rows , if a queen is there we put a number
  // no queen can be at same column
  // diagonals more involved
  // perhaps we could somehow figure out that as a rotation transform somehow ?
  // or simply memoise squares that would conflict if
```
 

## headers 

```
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
// uint64_t requires stdint
// 1 ULL one unsigned long long 64 bits 
```

## definition of the grid 

```
// an 8x8 grid initially 
#define SIZE  40

#define CUSHION 3
#define WIDTH  (SIZE + CUSHION)
#define HEIGHT (SIZE + CUSHION)

static uint64_t grid[HEIGHT][WIDTH];

// just need to know what column the nth queen is on 
// since its row is fixed it on nth row always
static int queen_column[WIDTH];

static int solution_no = 0;
```

## dominate the grid 

placing a queen affects the square and any other reachable square by placing nth queen bit at each cell

this is the shorthand notation 

```
	// an assignment with OR'd bitshift 
	grid[y2][x2] |= (1ULL << queen) ; 
```

the full horror going in all directions from 1 to SIZE.

```
static void dominate(int queen , int x , int y) {
  int i = 0;
  int x2 = 0;
  int y2 = 0;    

  // actually thinking about it - increasing Y is south , decreasing Y is north
  // but hey.
  
  // OR'ed sets that bit   
  grid[y][x] |= (1ULL << queen) ;
  
  for (i = 1; i <= SIZE ; i ++){
    x2 = x ; y2 = y + i ; // north 
    if (x2 >= 1 && x2 <= SIZE && y2 >= 1 && y2 <= SIZE){
      grid[y2][x2] |= (1ULL << queen) ;
    }
    x2 = x + i ; y2 = y + i ; // north east
    if (x2 >= 1 && x2 <= SIZE && y2 >= 1 && y2 <= SIZE){
      grid[y2][x2] |= (1ULL << queen) ;
    }
    x2 = x + i ; y2 = y ; // east 
    if (x2 >= 1 && x2 <= SIZE && y2 >= 1 && y2 <= SIZE){
      grid[y2][x2] |= (1ULL << queen) ;
    }
    x2 = x + i ; y2 = y - i ; // south east
    if (x2 >= 1 && x2 <= SIZE && y2 >= 1 && y2 <= SIZE){
      grid[y2][x2] |= (1ULL << queen) ;
    }
    x2 = x ; y2 = y - i ; // south 
    if (x2 >= 1 && x2 <= SIZE && y2 >= 1 && y2 <= SIZE){
      grid[y2][x2] |= (1ULL << queen) ;
    }
    x2 = x - i ; y2 = y - i ; // south west
    if (x2 >= 1 && x2 <= SIZE && y2 >= 1 && y2 <= SIZE){
      grid[y2][x2] |= (1ULL << queen) ;
    }
    x2 = x - i ; y2 = y ; // west
    if (x2 >= 1 && x2 <= SIZE && y2 >= 1 && y2 <= SIZE){
      grid[y2][x2] |= (1ULL << queen) ;
    }
    x2 = x - i ; y2 = y + i ; // north west
    if (x2 >= 1 && x2 <= SIZE && y2 >= 1 && y2 <= SIZE){
      grid[y2][x2] |= (1ULL << queen) ;
    }
  }
}
```

## removing a queen 

```
static void un_dominate(int queen , int x , int y) {
  int i = 0;
  int x2 = 0;
  int y2 = 0;

  // we can label this grid square at (y,x) Y X as this queen was here 
  grid[y][x] &= ~(1ULL << queen) ;

 for (i = 1; i <= SIZE ; i ++){
    x2 = x ; y2 = y + i ; // north
    if (x2 >= 1 && x2 <= SIZE && y2 >= 1 && y2 <= SIZE){
      grid[y2][x2] &= ~(1ULL << queen) ;      
    }
    x2 = x + i ; y2 = y + i ; // north east  
    if (x2 >= 1 && x2 <= SIZE && y2 >= 1 && y2 <= SIZE){
      grid[y2][x2] &= ~(1ULL << queen) ;      
    }
    x2 = x + i ; y2 = y ; // east 
    if (x2 >= 1 && x2 <= SIZE && y2 >= 1 && y2 <= SIZE){
      grid[y2][x2] &= ~(1ULL << queen) ;      
    }
    x2 = x + i ; y2 = y - i ; // south east
    if (x2 >= 1 && x2 <= SIZE && y2 >= 1 && y2 <= SIZE){
      grid[y2][x2] &= ~(1ULL << queen) ;      
    }
    x2 = x ; y2 = y - i ; // south 
    if (x2 >= 1 && x2 <= SIZE && y2 >= 1 && y2 <= SIZE){
      grid[y2][x2] &= ~(1ULL << queen) ;      
    }
    x2 = x - i ; y2 = y - i ; // south west
    if (x2 >= 1 && x2 <= SIZE && y2 >= 1 && y2 <= SIZE){
      grid[y2][x2] &= ~(1ULL << queen) ;      
    }
    x2 = x - i ; y2 = y ; // west
    if (x2 >= 1 && x2 <= SIZE && y2 >= 1 && y2 <= SIZE){
      grid[y2][x2] &= ~(1ULL << queen) ;      
    }
    x2 = x - i ; y2 = y + i ; // north west
    if (x2 >= 1 && x2 <= SIZE && y2 >= 1 && y2 <= SIZE){
      grid[y2][x2] &= ~(1ULL << queen) ;      
    }    
  }
}

```

## show the solution grid 

```
static void show_solution_grid(){
  int i =0;
  int j =0;
  for(j = 1; j <= SIZE; j++){
    for (i = 1; i <= SIZE; i ++){
      int val = queen_column[j];
      // only ever one queen on a row j
      // lookup queen_column[nqueen == nth row ] we get column value of queen if present
      if (val == i){
	printf("Q");
      }
      else {
	printf(".");
      }      
    }
    printf("\n");    
  }
  printf("\n");
}
```


## show the grid

mainly used for debugging - no way to make it visually appealing

this code was written when we used an int to represent the grid , printing the grid out in true unsigned long long integer format would mean potentially each cell in grid takes up 20 characters .
show grid was more useful to debug the effect of placing a queen on a grid square , can check visually the lines in all directions queen moves are filled with OR'd bit shift

```
(- (expt 2 64) 1) ==> 18446744073709551615
// uint64_t max = UINT64_MAX;
// 18446744073709551615
(length "18446744073709551615") ==> 20 characters 
```

```

static void show_grid(){
  int i =0;
  int j =0;
  for(j = 1; j <= SIZE; j++){
    for (i = 1; i <= SIZE; i ++){
      int val = grid[j][i];
      //printf("%llu  ",val);
	  printf("%2d  ",val);
    }
    printf("\n");    
  }
  printf("\n");
}

static void clear_grid(){
  int i =0;
  int j =0;
  for (i = 0; i <= SIZE; i ++){
    // 0 meaning it has not been placed 
    queen_column[i] = 0 ; 
    for(j = 0; j <= SIZE; j++){
      grid[j][i] = 0;
    }
  }
}
```

## testing

this is to debug affect placing a queen has on the cell values , initially empty grid should have all zeros 

```
dominate (nqueen , column , row ) 
```

```
void test1(){  
  clear_grid();
  dominate(1,1,1);
  show_grid();
  printf("... press a key to continue ... \n");
  getchar();  
}

void test2(){  
  clear_grid();
  dominate(1,8,1);
  show_grid();
  printf("... press a key to continue ... \n");
  getchar();  
}

void test3(){  
  clear_grid();
  dominate(1,1,8);
  show_grid();
  printf("... press a key to continue ... \n");
  getchar();  
}

void test4(){  
  clear_grid();
  dominate(1,8,8);
  show_grid();
  printf("... press a key to continue ... \n");
  getchar();  
}

```


## placing a queen 

every nth-queen occupies nth row , so we only need to determine the column the nth queen will occupy.  we can have an array of size nqueens to hold what column the nth-queen occupies , if zero that nth queen has not been placed yet

every time a queen is placed down on the grid the square must be completely empty and free of conflicts - a grid value of 0 , the square itself and all horizontal , vertical and diagonals squares are mutated by bitwise OR'd with (1 << q) where q is nth queen .

the first queen (1ULL << 1) , the second (1ULL << 2) and so on . 1ULL means an unsigned long long or 64 bit unsigned integer.

in theory we could go up to 62 or 63 queens before we run out of bit positions .

## removing a queen 

if we backtrack and remove a queen each grid position that this queen can reach is AND negated with the nth queen shift

```
grid[y][x] &= ~(1ULL << qn) 
where qn is the int nth queen , 
the 3rd queen would yield (1ULL << 3) , 
the 5th queen would give (1ULL << 5) 
```

## eager placing

seems sufficient for boards up to 35 queens , we have been able to produce solutions .

we have no real insight into placement of queens as yet and have not looked at literature.


