

#|
chicken scheme

queens in a list
(1 1)(2 2) etc ...
solved if for size of grid there is that many queens and none are in conflict with each other

true = #t
false = #f

position (x y) or can be (y x) makes no difference 

|#


(import (chicken format))
(import srfi-1)
(import srfi-2)
(import bindings)


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
(define (queen-n n i sz sk qlim)  
  (cond
   ((> n qlim)
    (format #t "~a~%" sk)
    (show-board sz sk))
   ((> i sz) #f)
   (#t ;; can i place a queen at (n,i) and not be in conflict with sk
    (when (not (conflict-list-rec (list n i) sk))
      (queen-n (+ n 1) 1 sz (cons (list n i) sk) qlim))
    (queen-n n (+ i 1) sz sk qlim))))
  
(define (show-board sz sk)
  (define (show-board-rec i j)
    (cond
     ((> j sz) #f)
     ((> i sz)
      (format #t "~%")
      (show-board-rec 1 (+ j 1)))
     (#t (cond
	  ((member (list i j) sk) (format #t "Q"))
	  (#t (format #t ".")))
	 (show-board-rec (+ i 1) j))))
  (format #t "~%")
  (show-board-rec 1 1)
  (format #t "~%"))

  
(define (find-solutions size-board)  
  (let* (
	 (first-queen 1)
	 (last-queen size-board)
	 (queens '())
	 (first-column 1)
	 )
    (queen-n first-queen first-column size-board queens last-queen)))


;; demo - solutions to board size 8 
(define (demo)
  (find-solutions 8))
