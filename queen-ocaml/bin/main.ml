
(*
  chatgpt nqueens assisted solution
  
         column 
         0  1  2  3
  row 0  .  .  .  .
  row 1  .  .  .  . 
  row 2  .  .  .  .
  row 3  .  .  .  .


  #show Int;;
  lsl logical shift left
  lsr logical shift right
  land logical and
  lor  logical or
  lnot 
  
  *)

type state =
{
    columns : int;
    diag1   : int;
    diag2   : int;
}

let size_board = 4

let mask = (1 lsl size_board) - 1

let init_board : state = {columns = 0 ; diag1 = 0 ; diag2 = 0 }

let get_columns (board : state) : int =  board.columns

let get_diag1 (board : state) : int =  board.diag1

let get_diag2 (board : state) : int =  board.diag2


  (*
let available (board : state) : int =
  lnot (board.columns lor board.diag1 lor board.diag2) land mask

let rec search (row : int) (board : state) : state =
  if row >= size_board then
    (*found one complete solution*)
    board
  else
    (*search all legal columns in this row *)
    board
    *)


let n = size_board 

exception Found of (int list)

let rec search n row path columns diag1 diag2 =
  if row = n then
    raise (Found path)
  else
    let mask = (1 lsl n) - 1 in
    let available =
      lnot (columns lor diag1 lor diag2) land mask
    in
    let rec bit_index bit i =
      if bit = 1 then i
      else bit_index (bit lsr 1) (i + 1)
    and loop available =
      if available = 0 then
        0
      else
        let bit = available land (-available) in
        let available = available land (available - 1) in
	let col = bit_index bit 0 in
        let count =
          search n (row + 1)
	    (col :: path)
            (columns lor bit)
            ((diag1 lor bit) lsl 1)
            ((diag2 lor bit) lsr 1)
        in
        count + loop available
    in
    loop available


let print_solution sol =
  let n = List.length sol in
  List.iter
    (fun queen_col ->
      for col = 0 to n - 1 do
        if col = queen_col then
          print_string "Q "
        else
          print_string ". "
      done;
      print_newline ()
    )
    sol
    

let example (n : int) =
  try
    let row = 0
                  and columns = 0
                  and diag1 = 0
                  and diag2 = 0
		  and path = []
       (*search n 0 [] 0 0 0 *)
    in (let _ = search n row path columns diag1 diag2
     in  print_solution [])
  with
  | Found sol ->
    print_solution sol
    

      (* here is the runner *)
let () =
  if Array.length Sys.argv <> 2 then begin
    Printf.eprintf "Usage: %s <n>\n" Sys.argv.(0);
    exit 1
  end;

  let n = int_of_string Sys.argv.(1) in

  Printf.printf "Solving %d-Queens\n" n;

  example n
