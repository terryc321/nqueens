

open Domainslib

let found = Atomic.make false
let solution = Atomic.make None



type task =
{
  row     : int;
  path    : int list;
  columns : int;
  diag1   : int;
  diag2   : int;
}


let rec bit_to_col bit col =
  if bit = 1 then
    col
  else
    bit_to_col (bit lsr 1) (col + 1)


let initial_tasks n =
  let mask = (1 lsl n) - 1 in

  let rec loop available tasks =
    if available = 0 then
      List.rev tasks
    else
      let bit = available land (-available) in
      let available = available land (available - 1) in

      let col = bit_to_col bit 0 in

      let task =
      {
        row = 1;
        path = [col];
        columns = bit;
        diag1 = bit lsl 1;
        diag2 = bit lsr 1;
      }
      in

      loop available (task :: tasks)
  in

  loop mask []


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



let rec search n row path columns diag1 diag2 =
  if row = n then
    Some (List.rev path)
  else
    let mask = (1 lsl n) - 1 in
    let available =
      lnot (columns lor diag1 lor diag2) land mask
    in

    let rec loop available =
      if available = 0 then
        None
      else
        let bit = available land (-available) in
        let remaining = available land (available - 1) in

        let col = bit_to_col bit 0 in

        match search
                n
                (row + 1)
                (col :: path)
                (columns lor bit)
                ((diag1 lor bit) lsl 1)
                ((diag2 lor bit) lsr 1)
        with
        | Some solution ->
            Some solution
        | None ->
            loop remaining
    in

    loop available



let solve_parallel n =
  let tasks = Array.of_list (initial_tasks n) in

  let pool =
    Task.setup_pool
      ~num_domains:(Domain.recommended_domain_count () - 1)
      ()
  in

  let result =
    Task.run pool (fun () ->
      Task.parallel_find
	~chunk_size:1
	~start:0
	~finish:(Array.length tasks - 1)
	~body:(fun i ->
          let t = tasks.(i) in
          search
            n
            t.row
            t.path
            t.columns
            t.diag1
            t.diag2
	)
	pool
    )
  in

  Task.teardown_pool pool;

  match result with
  | None ->
    print_endline "No solution found."
  | Some sol ->
    print_solution sol


  (*
let solve_parallel n =
  let tasks = Array.of_list (initial_tasks n) in
  let pool =
    Task.setup_pool
      ~num_domains:(Domain.recommended_domain_count () - 1)
      ()
  in

  Task.run pool (fun () ->
    Task.parallel_for
      pool
      ~start:0
      ~finish:(Array.length tasks - 1)
      ~body:(fun i ->
        let t = tasks.(i) in
        search
          n
          t.row
          t.path
          t.columns
          t.diag1
          t.diag2
      )
  );

  Task.teardown_pool pool;

  match Atomic.get solution with
  | None ->
      print_endline "No solution found."
  | Some sol ->
    print_solution sol
    *)
    


let () =
  if Array.length Sys.argv <> 2 then begin
    Printf.eprintf "Usage: %s <n>\n" Sys.argv.(0);
    exit 1
  end;

  let n =
    try int_of_string Sys.argv.(1)
    with Failure _ ->
      Printf.eprintf "Error: '%s' is not an integer.\n" Sys.argv.(1);
      exit 1
  in

  solve_parallel n
