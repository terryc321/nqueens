

(define (generate-primes max-limit)
  "Generate a list of prime numbers up to MAX-LIMIT."
  (if (< max-limit 2)
      '()
      ;; Create a list of all numbers from 2 to max-limit
      (let ((sieve (make-vector (+ max-limit 1) #t)))
        ;; Mark 0 and 1 as not prime (#f)
        (vector-set! sieve 0 #f)
        (vector-set! sieve 1 #f)
        
        ;; Sieve loop: cross out multiples of i
        (do ((i 2 (+ i 1)))
            ((> (* i i) max-limit))
          (when (vector-ref sieve i)
            (do ((j (* i i) (+ j i)))
                ((> j max-limit))
              (vector-set! sieve j #f))))
        
        ;; Collect all indices where the vector is #t
        (let loop ((n max-limit) (result '()))
          (cond
            ((< n 2) result)
            ((vector-ref sieve n) (loop (- n 1) (cons n result)))
            (else (loop (- n 1) result)))))))

(define primes (generate-primes 10000))

