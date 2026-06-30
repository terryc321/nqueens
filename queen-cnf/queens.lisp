
(defpackage :queens
  (:use :cl))

(in-package :queens)

#|
configure slime already
need to track how many clauses we generated
this will be fed back into to make the header
p cnf <VARS-COUNT> <CLAUSE-COUNT>
c variables start from 1 .. n
c comment lines start with c lowercase ?

decide what is the size of n queens board you are going to create
for each clause we simply cons- onto *clauses* , this way we 


# give sbcl 16 gigs to do this 
$ sbcl --dynamic-space-size 16000
> (load "queens.lisp")
T
> (queens::generate-nqueen-out 300 "300queen.cnf")
NIL



|#

(defparameter *stream* t) 
(defparameter *clause-count* 0)
(defparameter *clauses* nil)
(defparameter *variables* nil)
(defparameter *nqueen* nil)
(defparameter *board* nil)

#|
example - generate 500x500 clause normal form for 500 nqueens 
(queens::generate-nqueen-out 500 "500queen.cnf")

simply generating the propositional logic puzzle takes 38 seconds ! 

(time (generate-nqueen-out 500 "500queen.cnf"))
Evaluation took:
  37.202 seconds of real time
  37.164928 seconds of total run time (36.408078 user, 0.756850 system)
  [ Real times consist of 0.060 seconds GC time, and 37.142 seconds non-GC time. ]
  [ Run times consist of 0.063 seconds GC time, and 37.102 seconds non-GC time. ]
  99.90% CPU
  137,143,776,320 processor cycles
  10,106,871,216 bytes consed


need to move line p cnf 250000 207834000
to top of 500queen.cnf file

since we dont know how many clauses there are until we have generated the file!

1000x1000 nqueens  -- then still need to move last line p cnf X Y  to top of file
p cnf 1000000 1664668000

echo "p cnf 1000000 1664668000" > 1000queen2.cnf
cat 1000queen.cnf >> 1000queen2.cnf
mv -v 1000queen2.cnf 1000queen.cnf



CL-USER> (time (queens::generate-nqueen-out 1000 "1000queen.cnf"))
Evaluation took:
  288.876 seconds of real time
  288.808333 seconds of total run time (283.794706 user, 5.013627 system)
  [ Real times consist of 0.415 seconds GC time, and 288.461 seconds non-GC time. ]
  [ Run times consist of 0.411 seconds GC time, and 288.398 seconds non-GC time. ]
  99.98% CPU
  1,064,895,688,838 processor cycles
  80,428,075,600 bytes consed
  
NIL



|#


(defun generate-nqueen-out (n filename)
  (with-open-file (*stream* filename :direction :output :if-exists :supersede)
    (generate-nqueen n)))


;; an n queen board nxn will use n^2 variables
(defun generate-nqueen (n)
  (let ((*nqueen* n)
	(*variables* (* n n))
	(*clause-count* 0)
	(*clauses* nil))
    ;; generate board just translates (x,y) pair into single integer
    (generate-board)

    (generate-clauses)
    (print-header)
    
    ;; (let ((*clause-count* (length (remove-if (lambda (x) (equalp (car x) "c")) *clauses*))))
    ;;   (print-header)
    ;;   (print-clauses)
    ;;   )
    )
  )

(defun print-header ()
  (format *stream*  "c you need to manually create a p cnf header")
  (format *stream*  "c p cnf ~a ~a~%" *variables* *clause-count*))


(defun print-clause (clause)
  (when (not (equalp (car clause) "c")) (incf *clause-count*))
  (dolist (c clause)
    (format *stream*  "~a " c))
  (format *stream*  "~%"))



(defun print-clauses ()
  (let ((actual (reverse *clauses*)))
    (format *stream*  "c the actual clauses~%")
    (dolist (clause actual)
      (dolist (c clause)
	(format *stream*  "~a " c))
      (format *stream*  "~%"))))


(defun generate-board ()
  (setq *board* (make-hash-table :test 'equalp))
  (let ((i 1))
    (loop for y from 1 to *nqueen* do
      (loop for x from 1 to *nqueen* do
	(setf (gethash (list x y) *board*) i)
	;; (format *stream*  "~a : (~a,~a) <=> ~a ~%" i x y (gethash (list x y) *board* nil))	
	(incf i)))))

(defun lookup (x y)
  (assert (integerp x))
  (assert (integerp y))
  (let ((result (gethash (list x y) *board* nil)))
    (assert result)
    result))

;; generate clauses
(defun generate-clauses ()
  (generate-each-row-must-have-a-queen) ;; 4 
  (generate-each-row-only-one-queen) ;; 24 
  (generate-each-col-only-one-queen) ;; 24 
  (generate-each-diagonal-north-west-only-one-queen) ;; 14 
  (generate-each-diagonal-north-east-only-one-queen) ;; 14 
  )

(defun add-clause (c)
  (print-clause c))

;; we do not stack up clauses now !
;; (setq *clauses* (cons c *clauses*)))


;; we want to pair down each combination and make the negative
;; '(1 5 9 13)
;; -1 -5 0
;; -1 -9 0
;; -1 -13 0
;; -5 -9 0
;; -5 -13 0 
;; -9 -13 0 

(defun pairwise (xs)
  (cond
    ((null xs) nil)
    ((null (cdr xs)) nil)
    (t (assert (>= (length xs) 2))
       (let ((head (car xs))
	     (tail (cdr xs)))
	 (dolist (tt tail)
	   (add-clause (list head tt 0)))
	 (pairwise (cdr xs))))))


(defun onboardp (x y)
  (and (>= x 1) (<= x *nqueen*)
       (>= y 1) (<= y *nqueen*)))


;; how do we compute north-west diagonal ?
;;
;;      1 2 3 4 5 6 7 8 9 10 
;;    1      
;;    2          
;;    3           
;;    4         
;;    5         
;;    6 
;;    7 
;;    8 
;;

(defun generate-each-diagonal-north-west-only-one-queen ()
  (let ((n *nqueen*))
    (add-clause `("c" "each diagonal north west only one queen"))
    (loop for y from (- (* 2 n)) to (* 2 n) do
      (let ((diag nil)
	    (dy 0)
	    (dx 0))
	(loop for i from 1 to n do
	  (setq dx i)
	  (setq dy (- (+ y i) 1))
	  (when (onboardp dx dy)
	    ;;(setq diag (cons (list dx dy) diag))
	    (setq diag (cons (lookup dx dy) diag))
	    ))
	(setq diag (reverse diag))
	(when (> (length diag) 1)
	  ;;(format *stream*  "diagonal ~a ~%" diag)
	  (pairwise (mapcar (lambda (x) (- x)) diag))
	  )))))



;; how do we compute north-east diagonal ?
;;
;;      1 2 3 4 5 6 7 8 9 10 
;;    1 *     x       .      
;;    2     x       .         
;;    3   x       .           
;;    4 x     * .
;;    5       .
;;    6     .
;;    7   .
;;    8 .
;;
;; 
;;
;;
;;  such that x + y = N 
;;  if N from 3 to (2 * nqueen - 1) then
;;  nqueen = 4 then  N from 3 to 7 inclusive
;;  
(defun generate-each-diagonal-north-east-only-one-queen ()
  (let ((n *nqueen*))
    (add-clause `("c" "each diagonal north east only one queen"))
    (loop for y from 1 to (* 2 n) do
      (let ((diag nil)
	    (dy 0)
	    (dx 0))
	(loop for i from 1 to n do
	  (setq dx i)
	  (setq dy (+ 1 (- y i)))
	  (when (onboardp dx dy)
	    ;;(setq diag (cons (list dx dy) diag))
	    (setq diag (cons (lookup dx dy) diag))
	    ))
	;; (setq diag (reverse diag))
	(when (> (length diag) 1)
	  ;;(format *stream*  "diagonal ~a ~%" diag)
	  (pairwise (mapcar (lambda (x) (- x)) diag))
	  )))))







(defun generate-each-col-only-one-queen ()
  (let ((n *nqueen*))
    (add-clause `("c" "each col only one queen"))
    (loop for x from 1 to n do
      (let ((tmp nil))
	(loop for y from 1 to n do
	  (setq tmp (cons (lookup x y) tmp)))
	;; tmp contains e.g 1 5 9 13 for first row
	;; iterate over this and reduce tmp each time
	(setq tmp (reverse tmp))
	;;(add-clause (list "c" (format nil "~a" tmp)))
	(pairwise (mapcar (lambda (x) (- x)) tmp))
	))))


(defun generate-each-row-only-one-queen ()
  (let ((n *nqueen*))
    (add-clause `("c" "each row only one queen"))
    (loop for y from 1 to n do
      (let ((tmp nil))
	(loop for x from 1 to n do
	  (setq tmp (cons (lookup x y) tmp)))
	;; tmp contains e.g 1 5 9 13 for first row
	;; iterate over this and reduce tmp each time
	(setq tmp (reverse tmp))
	;;(add-clause (list "c" (format nil "~a" tmp)))
	(pairwise (mapcar (lambda (x) (- x)) tmp))
	))))


(defun generate-each-row-must-have-a-queen ()
  (let ((n *nqueen*))
    (add-clause `("c" "each row must have a queen"))
    (loop for y from 1 to n do
      (let ((tmp nil))
	(loop for x from 1 to n do
	  (setq tmp (cons (lookup x y) tmp)))
	(setq tmp (cons 0 tmp))
	(setq tmp (reverse tmp))
	(add-clause tmp)
	;; (format *stream*  "row ~a => ~a ~%" y tmp)
	t
	))))
       


;; (let ((i 0))     
;;   (loop while (< i 10) do (format *stream*  "i = ~a ~%" i) (incf i)))     
    

