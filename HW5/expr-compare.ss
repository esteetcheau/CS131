#lang racket
(provide expr-compare)

(define (lambda? x) (member x '(lambda λ)))

(define (getlambda x y argx argy exprx expry)
  (let ([check (if (and (equal? (car x) 'lambda) (equal? (car y) 'lambda)) 'lambda 'λ)])
    (cons check (cons (expr-compare argx argy) (cons (expr-compare exprx expry) '() )))
))

(define (variabletranslate var dict) (cond[(null? var) var][#t
    (cons (hash-ref dict (car var) "checker") (variabletranslate (cdr var) dict))]
))

(define (expressiontranslate expr dict loop)
  (cond[(null? expr) expr][(not (list? expr))
    (if (equal? (hash-ref dict expr "checker") "checker") expr
	(hash-ref dict expr "checker"))][(equal? (car expr) 'quote)
    (cons (car expr) (cons (cadr expr) (expressiontranslate (cddr expr) dict loop)))]

   [(and (list? (car expr)) (not loop))(cons (expressiontranslate (car expr) dict loop) 
   (expressiontranslate (cdr expr) dict loop))][#t
    (let ([transform (hash-ref dict (car expr) "checker")])(cond[(equal? transform "checker")
	(if (lambda? (car expr))(cons (car expr) (expressiontranslate (cdr expr) dict #t))
	    (cons (car expr) (expressiontranslate (cdr expr) dict loop)))][(lambda? transform)
	(cons transform (expressiontranslate (cdr expr) dict #t))][#t
	(cons transform (expressiontranslate (cdr expr) dict loop))]))]
))

(define (headl x y)(let ([varx (cadr x)] [vary (cadr y)])(cond
     [(not (equal? (length varx) (length vary)))(list 'if '% x y)][#t
      (let ([values (argsl varx vary)])
	(let ([dictx (getdict varx values)][dicty (getdict vary values)])
	  (getlambda x y(variabletranslate varx dictx)(variabletranslate vary dicty) 
	(expressiontranslate (caddr x) dictx #f)(expressiontranslate (caddr y) dicty #f))))]
)))

(define (getdict args values) (cond[(null? args) (hash)][#t
    (hash-set (getdict (cdr args) (cdr values)) (car args) (car values))]
))

(define (argsl x y) (cond[(null? x) x][(equal? (car x) (car y))
    (cons (car x) (argsl (cdr x) (cdr y)))][#t
    (cons (string->symbol (string-append (symbol->string (car x)) "!" (symbol->string (car y))))
	  (argsl (cdr x) (cdr y)))]
))
(define (head x y) (let ([headx (car x)] [heady (car y)])
    (cond[(or (lambda? headx) (lambda? heady))(if (not (and (lambda? headx) (lambda? heady)))
	  (list 'if '% x y)

	  (headl x y))][(or (equal? headx 'quote) (equal? heady 'quote))
      (list 'if '% x y)][(equal? headx heady)(body x y)]

     [(or (equal? headx 'if) (equal? heady 'if))(list 'if '% x y)]
     [(and (list? headx) (list? heady))
      (cons (expr-compare headx heady) (expr-compare (cdr x) (cdr y)))][#t(body x y)]
)))
(define (body x y) (if (null? x) x
      (let ([headx (car x)] [heady (car y)])(cond[(equal? headx heady)
	  (cons headx (body (cdr x) (cdr y)))][(and (boolean? headx) (boolean? heady)) 
	  (cons (if headx '% '(not %)) (body (cdr x) (cdr y)))]
	  [(and (list? headx) (list? heady))
	  (cons (expr-compare headx heady) (body (cdr x) (cdr y)))][#t
	  (cons (list 'if '% headx heady) (body (cdr x) (cdr y)))])
)))

(define (expr-compare x y)(cond[(equal? x y) x][(and (boolean? x) (boolean? y))
    (if x '% '(not %))][(or (not (list? x)) (not (list? y)))(list 'if '% x y)]
   [(not (equal? (length x) (length y)))(list 'if '% x y)][#t (head x y)]
))

(define (test-expr-compare x y) 
  (and (equal? (eval x)(eval (list 'let '([% #t]) (expr-compare x y))))
       (equal? (eval y)(eval (list 'let '([% #f]) (expr-compare x y))))
))


(define test-expr-x '(let ((a ((lambda (b c) (+ b c)) 1 2)) (d 3))
    ((lambda (x y) (let ((e (+ x 1))(f (+ y 1))) (equal? e f))) a d)))
    
(define test-expr-y '(let ((b ((lambda (a d) (+ a d)) 2 1)) (c 3))
    ((lambda (x y) (let ((e (+ x 1))(f (+ y 1))) (equal? e f))) b c)))




                