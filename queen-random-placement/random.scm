
#|
what is it we need for a nqueens to be placed randomly
this is half nqueens exposition and guile scheme refresher blended together
#t #f

diagonals

is solved ?

conflicts

how represent board

show board

show solution

how represent a queen , what is size of board ? 
size = number of queens on board 

how do i get lambda to display as \ lambda symbol ?
how do i insert unicode in emacs ?

should solution be functional ? copy board and move a queen ?
board is just its size , but then queens need to be mentioned , should we just have 3 queens on 12x12
and call it solved ?

(make-record-type "employee" '(name age salary))


(make-random 12)
make a random 12 x 12 nqueens board

get a vector with values
as a vector {0 1 2 3 4 5 ... n-1 }

(make-random 3)
choose from {0 1 2}

pick n -- where n is 3 ?? because there are 3 to choose from
then n will be 0 1 2
we pick n place it into another vector
then we shrink array , since we know the value we removed we simply start at n+1 position and move them
all down 

|#


;; take a list of queen positions in rows and convert to row columns
(define coords
  (lambda (queens)
    (let ((y 1))
      (map (lambda (x) (let ((result (list x y)))
			 (set! y (+ y 1))
			 result))
	   queens))))


(define show2
  (lambda (size queens)
    "print a nice board with queens positions
(col,row) column horizontal across
row vertically down"    
      (let loopy ((y 1))
	(let loopx ((x 1))
	  ;; meat
	  (cond
	   ((member (list x y) queens) (format #t "Q"))
	   (#t (format #t ".")))
	  ;; 
	  (when (< x size)
	    (loopx (+ x 1))))
        (format #t "~%")
	(when (< y size)
	  (loopy (+ y 1))))))



(define show
  (lambda (queens)
    "print a nice board with queens positions
(col,row) column horizontal across
row vertically down"
    (let ((size (length queens)))	  
      (let loopy ((y 1))
	(let loopx ((x 1))
	  ;; meat
	  (cond
	   ((member (list x y) queens) (format #t "Q"))
	   (#t (format #t ".")))
	  ;; 
	  (when (< x size)
	    (loopx (+ x 1))))
        (format #t "~%")
	(when (< y size)
	  (loopy (+ y 1)))))))


(define init
  (lambda (size)
    "this is a documentation string for make-random
we create a list of random queen positions
human readable ((_ 1)(_ 2)(_ 3)...(_ n)) for n queens
we use 1 based , 1 is the first !
"
    (let ((positions (cdr (iota (+ size 1))))
	  (result '()))
      (let loopn ((n 1))
	(let ((nth (random (length positions))))
	  (let ((pick (list-ref positions nth)))
	    (set! positions (filter (lambda (v) (not (= v pick))) positions))
	    (set! result (cons pick result))
	    (when (< n size)
	      (loopn (+ n 1)))
	    (coords result)))))))

;; what are the odds of generating a board at random and having 0 conflicts -- ie a fully solved n
;; queens board straight off the cuff ?

(define conflicts
  (lambda (queens)
    "conflicts queens
where queens is a list of coords ((1 1)(2 2)(3 3)...(n n)) example for n queens
we can map over a list of queens twice and determine if there is a conflict
"
    (define foo (lambda (v) (filter (lambda (r) (when (not (equal? v r)) (any-conflict? v r))) queens)))
    (let ((result (map foo queens)))      
      result)))


(define same-row
  (lambda (coord1 coord2)
    (let ((x1 (car coord1))
	  (y1 (car (cdr coord1)))
	  (x2 (car coord2))
	  (y2 (car (cdr coord2))))
      (= y1 y2))))

(define same-col
  (lambda (coord1 coord2)
    (let ((x1 (car coord1))
	  (y1 (car (cdr coord1)))
	  (x2 (car coord2))
	  (y2 (car (cdr coord2))))
      (= x1 x2))))

(define same-diagonal
  (lambda (coord1 coord2)
    (let ((x1 (car coord1))
	  (y1 (car (cdr coord1)))
	  (x2 (car coord2))
	  (y2 (car (cdr coord2))))
      (= (abs (- x1 x2)) (abs (- y1 y2))))))

(define any-conflict?
  (lambda (coord1 coord2)
    (let ((x1 (car coord1))
	  (y1 (car (cdr coord1)))
	  (x2 (car coord2))
	  (y2 (car (cdr coord2))))
      ;; same row / same col / on same diagonals
      (or (= y1 y2)
	  (= x1 x2)
	  (= (abs (- x1 x2)) (abs (- y1 y2)))))))
	  
(define solved?
  (lambda (queens)
    (let* ((cf (conflicts queens))
	   (any (filter (lambda (v) (> (length v) 1)) cf)))
      (null? any))))
      
(define all-distinct?
  (lambda (queens)
    (cond
     ((null? queens) #t)
     (else (if (member (car queens) (cdr queens))
	       #f
	       (all-distinct? (cdr queens)))))))


(define solved2?
  (lambda (size queens)
    (let* ((cf (conflicts queens))
	   (any (filter (lambda (v) (> (length v) 1)) cf)))
      (and (null? any)
	   (= size (length queens))
	   (all-distinct? queens)))))

;; explore 11 x 11 nqueens boards , zero attempts , zero solutions found so far 
;; (explore 11 0 0)
(define explore
  (lambda (size attempts solutions)
    "explore int
given a board size - create bd  "
    (let* ((bd (init size)))
      (cond
       ((solved? bd)
	(let ((cf (conflicts bd)))
	  ;;(format #t "~a~%" cf)
	  (format #t "~a~%" bd)
	  (show bd)
	  (format #t "solved after ~a attempts : ~a solutions found : ratio ~a~%" attempts solutions (* 100.0 (/ solutions attempts)))
	  (explore size attempts (+ solutions 1))))
       (#t (explore size (+ attempts 1) solutions))))))



;; move across right one place - wrap any larger than size of board
(define translate-x
  (lambda (queens)
    (let ((size (length queens)))
      (map (lambda (v)
	     (let ((x2 (+ 1 (car v)))
		   (y2 (car (cdr v))))
	       (cond
		((> x2 size) (list 1 y2))
		(else (list x2 y2)))))
	   queens))))

(define translate-y
  (lambda (queens)
    (let ((size (length queens)))
      (map (lambda (v)
	     (let ((x2 (car v))
		   (y2 (+ 1 (car (cdr v)))))
	       (cond
		((> y2 size) (list x2 1))
		(else (list x2 y2)))))
	   queens))))


(define staircase
  (lambda (size)
    (let ((queens '())
	  (x 1))
      (let loopy ((y 1))
	
	(cond
	 ((and (>= x 1) (<= x size)(>= y 1)(<= y size)) (set! queens (cons (list x y) queens))
	  (set! x (+ x 2)))
	 (else (set! x 2)(set! y (- y 1))))
	
	(when (< y size)
	  (loopy (+ y 1))))
      queens)))

;; so why ? 
;; staircase on prime 5 7 11 13 17 ... all lead to solved n queens
;; picked large prime 9973 from google --- checked --- yes .. it works !!
;; scheme@(guile-user)> (solved2? 9973 (staircase 9973))
;; $163 = #t
;;
;; so why does it not work on 9   ? 3
;;                            15  ? 3 5 factors
;;                            21  ? 3 7 


    

#|

want staircase to start at (1,1) increase x by 2 , y by 1 until we fall off board
want to continue on y + 1 at (2,y+1) again increase by 2 , y by 1 until we fall off board

scheme@(guile-user)> (show2 13 '((1 1)(3 2)(5 3)(7 4)(9 5)(11 6)(13 7)(2 8)(4 9)(6 10)(8 11)(10 12)(12 13)))
Q............
..Q..........
....Q........
......Q......
........Q....
..........Q..
............Q
.Q...........
...Q.........
.....Q.......
.......Q.....
.........Q...
...........Q.
scheme@(guile-user)> (solved2? 13 '((1 1)(3 2)(5 3)(7 4)(9 5)(11 6)(13 7)(2 8)(4 9)(6 10)(8 11)(10 12)(12 13)))
$141 = #t

|#

;; massively complicated sliding window 
;;
;; ;; (make-increase-sequence 3) => #(0 1 2)
;; (define make-increase-sequence
;;   (lambda (size)
;;     (let ((result (make-vector size #f)))
;;       (let loopn ((n 0))
;; 	(vector-set! result n n)
;; 	(when (< (+ n 1) size)
;; 	  (loopn (+ n 1)))
;; 	result))))
;;
;; ;; sliding window moves everything back one space
;; ;; although vector has an initial size say 12 , lim decreases by 1 each time slides down
;; ;; (slide-down-one-place! (list->vector '(0 1 2 3)) 0 3)
;; ;; (slide! v 0 3)
;; (define slide!
;;   (lambda (vec i lim)
;;     (let loopn ((j (+ i 1)))
;;       (when (< j (vector-length vec))
;; 	(vector-set! vec (- j 1) (vector-ref vec j))
;; 	)
;;       (when (< j lim)
;; 	(loopn (+ j 1)))      
;;       vec)))

#|

regularity

solved after 1429278 attempts : 88 solutions found : ratio 0.006156954770170674
((2 1) (11 2) (9 3) (7 4) (5 5) (3 6) (1 7) (10 8) (8 9) (6 10) (4 11))
.Q.........
..........Q
........Q..
......Q....
....Q......
..Q........
Q..........
.........Q.
.......Q...
.....Q.....
...Q.......

regularity - we moved {reg1} them all up - and checked still solved
(show '((2 11) (11 1) (9 2) (7 3) (5 4) (3 5) (1 6) (10 7) (8 8) (6 9) (4 10)))
..........Q
........Q..
......Q....
....Q......
..Q........
Q..........
.........Q.
.......Q...
.....Q.....
...Q.......
.Q.........

odd number n queen - can we just make this staircase solution ?


even case 12 - we cannot just continue staircase
(show2 12 '((1 1)(3 2)(5 3)(7 4)(9 5)(11 6)(2 7)(4 8)(6 9)(8 10)(10 11)(12 12)))
Q...........   NOT a solution !
..Q.........
....Q.......
......Q.....
........Q...
..........Q.
.Q..........
...Q........
.....Q......
.......Q....
.........Q..
...........Q  *corner conflict*
maybe exchange corner 12 12 -> 12 11 ; 10 11 -> 10 12 

heres a 9x9 almost a cross X shape
((8 1) (6 2) (1 3) (3 4) (5 5) (7 6) (9 7) (4 8) (2 9))
.......Q.
.....Q...
Q........
..Q......
....Q....
......Q..
........Q
...Q.....
.Q.......




solved after 1977860 attempts : 131 solutions found : ratio 0.006623320154105953
((3 1) (9 2) (4 3) (10 4) (5 5) (11 6) (6 7) (1 8) (7 9) (2 10) (8 11))
..Q........
........Q..
...Q.......
.........Q.
....Q......
..........Q
.....Q.....
Q..........
......Q....
.Q.........
.......Q...



|#
