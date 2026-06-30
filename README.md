# nqueens

hypothesis

a randomly generated board of queens with adjustments is faster way to find a solution than a brute force
serial trial and error approach , discuss.

lets build a randomly generated board and see if it can find a solution to an nqueen puzzle . 

lets for first attempt just do no adjustment at all , see if it solves it by chance, what are probabilities of doing this ?




# scala3 

3000x3000 nqueens solved ! 

2000x2000 nqueens solved

just a question of how much memory can squeeze in ?

scala3 using google or-tools 



see queen-scala-or-tools/nqueens-solver

```
sbt new scala/scala3.g8
the terminal will prompt you for a name (e.g., nqueens-solver).

cd nqueens-solver

add dependencies to build.sbt
libraryDependencies += "com.google.ortools" % "ortools-java" % "9.12.4544"

```

the latest winner so far is cryptominisat5 

target is a 1000x1000 nqueens puzzle , the large file generated in CNF format is very very large

successs ! memory usage around 35 gig for 1000 nqueens puzzle 

can we go larger ? 


# enable swap

created 64 gig of swap to see if computation can proceed 

```
# 1. Allocate the space (64 GB)
sudo dd if=/dev/zero of=/swapfile_large bs=1G count=64 status=progress

# 2. Set the correct permissions for security
sudo chmod 600 /swapfile_large

# 3. Set up the file as Linux swap area
sudo mkswap /swapfile_large

# 4. Enable the swap file immediately
sudo swapon /swapfile_large
```

and to disable it

```
# 1. Disable the temporary swap
sudo swapoff /swapfile_large

# 2. Delete the file from your drive
sudo rm /swapfile_large
```

## directory structure 

this was all sparked from not being able to complete haskell - mooc - fi set 9b.hs exercise on nqueen 
could not understand the final exercise 

```
queen-c 
c implementation of an nqueens 

queen-ocaml 
ocaml implementation of nqueens ,uses multicore but not really sure
if it makes any difference whatever 

queen-ladr-prover9-mace4 
uses mace4 to try to build a model 

queen-cnf 
try using propositional logic and sat solver minisat , needs translation logic into clause normal form,
explosion of terms

```
## clause normal form 

DIMACS cnf format 

for propositional logic variables 1 .. n^2 

if we say 1 represents there is a queen at square 1 , and -1 to mean there is no queen there

```
1   2  3  4
5   6  7  8
9  10 11 12
13 14 15 16
```

aside for comments in .dnf file we can write comments prefix entire line with letter c

```
c this is a comment 
```

to say there is only one queen in row one , we also use suffix zero 0 to mean nothing more to follow
for each clause

```
c row1 must have a queen 
1 2 3 4 0
5 6 7 8 0
9 10 11 12 0
13 14 15 16 0
```

```
c one queen per row only - cannot both be 
c 1 x 2 .. n 
c 2 x 3 .. n
c 3 x 4 .. n etc ..
-1 -2 0
-1 -3 0
-1 -4 0
-2 -3 0
-2 -4 0
-3 -4 0
c repeat for { 5 6 7 8 }
c repeat for { 9 10 11 12 }
c repeat for { 13 14 15 16 }
```

```
c similarly one queen per column only
c for 1 5 9 13 
-1 -5 0 
-1 -9 0
-1 -13 0
-5 -9 0
-5 -13 0
-9 -13 0
c repeat for { 2 6 10 14 }
c repeat for { 3 7 11 15 }
c repeat for { 4 8 12 16 }
```

```
c only one queen per diagonal , north west - south east diagonals 
c for diagonal containing 1 6 11 16 no two squares can conflict
-1 -6 0
-1 -11 0
-1 -16 0
-6 -11 0
-6 -16 0
-11 -16 0 
c similarly for every other diagonal
```

```
c only one queen per diagonal , north east diagonals
c for diagonal containing 4 7 10 13 
-4 -7 0
-4 -10 0
-4 -13 0
-7 -10 0
-7 -13 0
-10 -13 0
c similarly for every other diagonal 
```

have we completely specified the nqueens into propositional logic for a 4x4 board now then ?

for a 40x40 board there are 1600 propositional variables .
for a 100x100 board there are 10000 variables .



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


