
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
// uint64_t requires stdint
// 1 ULL one unsigned long long 64 bits 

// can we show a grid
// how do we arrange for an 8x8 grid ?
// what about a different size ?
// place a queen on empty board - we then dominate the board mark everywhere with 1 bit set 1u << 1 
// on next row [j+1][1] ask is it an empty square = ie has value 0
// if so place 2nd queen there set 1u << 2
// how do we distinguish between a queen or a mask ?? -- answer is ?? 
// we could set a global flag says - solution found !!
//



// prototypes
static void clear_grid();
static void show_grid();
static void dominate(int queen , int x , int y);
static void un_dominate(int queen , int x , int y);
static void brute(int nqueen);

// an 8x8 grid initially 
#define SIZE  40

#define CUSHION 3
#define WIDTH  (SIZE + CUSHION)
#define HEIGHT (SIZE + CUSHION)

static uint64_t grid[HEIGHT][WIDTH];

// just need to know what column the nth queen is on  , since its row is fixed it on nth row always
static int queen_column[WIDTH];

static int solution_no = 0;

static void show_grid(){
  int i =0;
  int j =0;
  for(j = 1; j <= SIZE; j++){
    for (i = 1; i <= SIZE; i ++){
      int val = grid[j][i];
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

static void un_dominate(int queen , int x , int y) {
  int i = 0;
  int x2 = 0;
  int y2 = 0;

  // we can label this grid square at (y,x) Y X as this queen was here 
  grid[y][x] &= ~(1ULL << queen) ;
  
  // although we are placing queens on independent rows never going to have two queens on same row
  // so we could in theory eliminate bit settings for East and West entirely
  // might have a array to represent columns , if a queen is there we put a number
  // no queen can be at same column
  // might also have an array to represent rows , if a queen is there we put a number
  // no queen can be at same column
  // diagonals more involved
  // perhaps we could somehow figure out that as a rotation transform somehow ?
  // or simply memoise squares that would conflict if
   
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



// if we get to row 

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

    // just take any solution 
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


int main(){
  /*
  printf("my first c program\n");

  
  test1();
  test2();
  test3();
  test4();
  */
  // clean slate
  clear_grid();
  solution_no = 0;
  
  
  /*
  int a = 0;
  a |= (1ULL << 3);
  printf("OR with queen 3 : %d",a);
  a &= ~(1ULL << 3);
  printf("AND ~ with queen 3 : %d",a);

  printf("random uninitialised grid\n");
  show_grid();
  
  printf("setting row = 2 col = 3 to 42 , notice YAxis in 1st position\n");
  grid[2][3] = 42;
  printf("%d\n", grid[2][3]);
  show_grid();

  printf("cleared grid\n");
  clear_grid();
  show_grid();
  */


  printf("starting search\n");
  brute(1);
  
  
    
  return 0;
}


