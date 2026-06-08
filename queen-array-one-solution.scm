

#|

we use a 2d array
place a queen at say (1,1)  we put Q there
then at all other locations we place X if it would be in conflict
then when comes to place next queen - we can immediately tell if there is a
conflict there - time is lookup in 2d array


|#


(import (chicken format))
(import srfi-1)
(import srfi-2)
(import srfi-63) ;; 2d arrays 
(import srfi-69) ;; hash
(import bindings)


(define *max-board-size* 100)

;; Create a regular 8x8 array (0-based internally)
;;; or use (vector) for general objects
;; lets make an array arbitrarily large -- unlikely we want to do 100x100 nqueens
(define *board* (let ((cushion (+ *max-board-size* 1)))
		  (make-array '#() cushion cushion)))

(define *queens* '())

(define (reset-board)
  (let loopx ((x 1))
    (when (<= x *max-board-size*)
      (let loopy ((y 1))
	(when (<= y *max-board-size*)
	  ;;(format #t "setting x => ~a : y => ~a ~%" x y)
	  (array-set! *board* #f x y)
	  (loopy (+ y 1))))
      (loopx (+ x 1)))))


;; display 
(define (show-board sz)
  (define (show-board-rec i j)
    (cond
     ((> j sz) #f)
     ((> i sz)
      (format #t "~%")
      (show-board-rec 1 (+ j 1)))
     (#t (cond
	  ((eq? (array-ref *board* i j) 'queen) (format #t "Q"))
	  (#t (format #t ".")))
	 (show-board-rec (+ i 1) j))))
  (format #t "~%")
  (show-board-rec 1 1)
  (format #t "~%"))

(define (spray-no! x y sz)
  (let loop ((n 1))
    (when (<= n sz)
      (stamp-no! (- x n)   y         sz)
      (stamp-no! (+ x n)   y         sz)
      (stamp-no! x         (- y n)   sz)
      (stamp-no! x         (+ y n)   sz)
      ;; now diagonals 
      (stamp-no! (- x n) (+ y n) sz)
      (stamp-no! (+ x n) (+ y n) sz)
      (stamp-no! (- x n) (- y n) sz)
      (stamp-no! (+ x n) (- y n) sz) 
      (loop (+ n 1)))))

(define (stamp-no! x y sz)
  (when (and (>= x 0) (>= y 0) (<= x sz) (<= y sz))
    (array-set! *board* 'no x y )))

(define (clear-nos!)
  (let loopx ((x 1))
    (when (<= x *max-board-size*)
      (let loopy ((y 1))
	(when (<= y *max-board-size*)
	  (let ((elem (array-ref *board* x y)))
	    (when (eq? elem 'no)
	      (array-set! *board* #f x y)))	  
	  (loopy (+ y 1))))
      (loopx (+ x 1)))))




;; when queen gets removed from board
;; all no squares get removed
;; scan through board to find queens
;; for each queen - fire off spray-no x y sz 
(define (queen-n n i sz sk qlim exit)  
  (cond
   ((> n qlim)
    (format #t "Solution : ~a~%" sk)
    (show-board sz)
    (exit #t)
    )
   ((> i sz) #f)
   (#t ;; can i place a queen at (n,i) and not be in conflict with sk
    (let ((elem (array-ref *board* i n)))
      ;;(format #t "elem at ~a ~a is ~a ~%" i n elem)
      (when (not (or (eq? elem 'queen)
		     (eq? elem 'no)))
	;;(format #t "queen ~a : placing queen at col ~a row ~a ~%" n i n )
	;; place queen at i n
	(array-set! *board* 'queen i n)
	;; go mad - in all 8 directions spray no 's to board
	(spray-no! i n sz)
	;; == debug ===
	;;(show-board sz)
	;; advance next row 
	(queen-n (+ n 1) 1 sz (cons (list i n) sk) qlim exit)
	;; remove queen
	(array-set! *board* #f i n )
	;; remove no s from board
	(clear-nos!)
	;; for all queens we do have - spray-no them
	(map (lambda (pt)
	       (bind (x y) pt
		     (spray-no! x y sz))) sk))	
      (queen-n n (+ i 1) sz sk qlim exit)))))




(define (find-solutions size-board exit)
  (reset-board)
  (show-board size-board)
  (let* (
	 (first-queen 1)
	 (last-queen size-board)
	 (queens '())
	 (first-column 1)
	 )
    (queen-n first-queen first-column size-board queens last-queen exit)))



(define (demo)
  (call/cc (lambda (exit)
	     (find-solutions 32 exit))))


(demo)


;; (define-syntax foo
;;   (syntax-rules ()
;;     ((_ var start stop) 


;; board square potentially is a list 
;; when we push a queen - it gets added to *queens* and array updated with Q
;; and all squares which would cause conflict
;; when we pop a queen we remove it from the board and remove any conflicts 
;;(define (push-queen! pt) ...)
;;(define (pop-queen! pt) ...)





;; ;; Create a 1-based view using make-shared-array
;; ;; map 1..8 -> 0..7
;; ;; new dimensions: 8x8 with indices 1..8
;; (define board
;;   (make-shared-array base-array
;;                      (lambda (i j) (list (- i 1) (- j 1)))
;;                      9 9))


;; ==========================================================
;; ; top-left
;; (array-set! board 'X 1 1)
;; ; bottom-right
;; (array-set! board 'O 8 8)     
;; (array-set! board 'A 4 5)

;; (array-ref board 1 1) ;;  => 'X
;; (array-ref board 8 8) ;;  => 'O
;; (array-ref board 4 5) ;;  => 'A

;; ;; Check dimensions (still reports the logical size)
;; (array-dimensions board) ;; => (8 8)

;; ============================================================


(define (valid-coord x)
  (assert (pair? x))
  (assert (= (length x) 2)))


(define (conflict-list-rec pt xs)
  "does pt conflict with xs ?
only check pt against all other xs ,
we do not enter xs and check their conflicts"
  (assert (valid-coord pt))
  (cond
   ((null? xs) #f)
   (#t (let ((pt2 (car xs))
	     (tail (cdr xs)))
	 (assert (valid-coord pt2))
	 (cond
	  ((conflict pt pt2) #t)
	  (else (conflict-list-rec pt tail)))))))

(define (conflict-list xs)
  "checks each item in xs is neither in conflict with rest of xs
   do this for each element in xs"
  (cond
   ((null? xs) #f)
   (#t (let ((pt (car xs))
	     (tail (cdr xs)))
	 (assert (valid-coord pt))
	 (cond
	  ((conflict-list-rec pt tail) #t)
	  (#t (conflict-list (cdr xs))))))))


(define (same-row pt pt2)
  (assert (valid-coord pt))
  (assert (valid-coord pt2))
  (bind (x y) pt
	(bind (x2 y2) pt2
	      (= y y2))))

(define (same-col pt pt2)
  (assert (valid-coord pt))
  (assert (valid-coord pt2))
  (bind (x y) pt
	(bind (x2 y2) pt2
	      (= x x2))))

(define (same-diag pt pt2)
  (assert (valid-coord pt))
  (assert (valid-coord pt2))
  (bind (x y) pt
	(bind (x2 y2) pt2
	      (let ((d1 (- x2 x))
		    (d2 (- y2 y)))
		(= d1 d2)))))

(define (same-antidiag pt pt2)
  (assert (valid-coord pt))
  (assert (valid-coord pt2))
  (bind (x y) pt
	(bind (x2 y2) pt2
	      (let ((d1 (- x2 x))
		    (d2 (- y2 y)))
		(= d1 (- d2))))))

(define (conflict pt pt2)
  (assert (valid-coord pt))
  (assert (valid-coord pt2))
  (or (same-row pt pt2)
      (same-col pt pt2)
      (same-diag pt pt2)
      (same-antidiag pt pt2)))


#|
(conflict-list '((1 1)))
brute try all for a given row until

sz size of chessboard
row , col attempting to place
sk current stack of queens -- conflict free by construction

if length sk == sz then solved it ? check by calling conflict-list 
if col > sz then no solution here
if conflict with placing queen at row col , then try next column 

|#

(define (brute sz row col sk)
  (format #t "trying to put queen at ~a ~a : ~a ~%" row col sk)
  (cond
   ((= sz (length sk)) (format #t "~a~%" sk))
   ((> col sz) #f) 
   ((conflict-list-rec (list row col) sk)
    (brute sz row (+ col 1) sk))
   (#t
    (brute sz (+ row 1) 1 (cons (list row col) sk)))))

#|

|#

