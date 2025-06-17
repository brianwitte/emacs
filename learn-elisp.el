;; tutorial: learn emacs lisp quickly - today!
;;
;; WARNING: While this won't brick your system, throwing your machine in
;; frustration might. You've been warned.
;;
;; Core Concepts
;; ------------
;; 1. Everything happens in buffers, not files
;; 2. *scratch* is your default playground
;; 3. lisp-interaction-mode enables REPL functionality

;; Basic Syntax
;; -----------
;; Comments: Start with ;
;; S-expressions: Everything lives in (parentheses)
;; Evaluation: C-x C-e at end of expression

;; Math Operations
;; --------------
(+ 1 2 3 4)                    ; => 10
(- 10 5)                       ; => 5
(- 10)                         ; => -10
(* 2 3 4)                      ; => 24
(/ 10 2)                       ; => 5
(/ 10 3)                       ; => 3
(/ 10.0 3)                     ; => 3.3333333333333335
(% 10 3)                       ; => 1
(mod 10 3)                     ; => 1
(1+ 5)                         ; => 6
(1- 5)                         ; => 4
(abs -5)                       ; => 5
(random 10)                    ; => random number 0-9
(expt 2 3)                     ; => 8
(sqrt 16)                      ; => 4.0
(float 5)                      ; => 5.0
(truncate 5.6)                 ; => 5
(floor 5.6)                    ; => 5
(ceiling 5.4)                  ; => 6
(round 5.5)                    ; => 6
(max 1 2 3 4)                 ; => 4
(min 1 2 3 4)                 ; => 1

;; Numeric Predicates
(numberp 5)                    ; => t
(integerp 5)                  ; => t
(floatp 5.0)                  ; => t
(zerop 0)                     ; => t
(plusp 5)                     ; => t
(minusp -5)                   ; => t
(oddp 5)                      ; => t
(evenp 6)                     ; => t

;; Variable Operations
;; -----------------
(setq x 1)                    ; => 1
(setq y 2 z 3)               ; => 3
(setq counter 0               ; => 0
      max-count 100
      name "counter")

(let ((a 1)
      (b 2))
  (setq a (+ a b))           ; => 3
  a)

(defvar *global-var* 42)     ; => 42
(defconst MY-CONSTANT 3.14)  ; => 3.14

(makunbound 'x)              ; Unbind x
(boundp 'x)                  ; => nil

;; Variable Increment/Decrement
(setq counter 0)             ; => 0
(setq counter (1+ counter))  ; => 1
(cl-incf counter)           ; => 2
(cl-decf counter)           ; => 1


;; Numeric Conversions
(number-to-string 42)        ; => "42"
(string-to-number "42")      ; => 42
(format "%d" 42)             ; => "42"
(format "%04d" 42)           ; => "0042"
(format "%.2f" 3.14159)      ; => "3.14"

;; Compound Operations
(setq count 0)
(while (< count 5)
  (insert (format "Count: %d\n" count))
  (setq count (1+ count)))

(dotimes (i 5)
  (insert (format "Index: %d\n" i)))

(let ((numbers '(1 2 3 4 5)))
  (dolist (num numbers)
    (insert (format "Number: %d\n" num))))

;; Point Management
(let ((start (point)))
  (insert "Hello")
  (push-mark)
  (insert " World")
  (delete-region start (point)))

;; Basic Operations
;; --------------
;; Math:
(+ 2 2)         ; => 4
(+ 2 (+ 1 1))   ; => 4    ; Nesting works as expected

;; Variables:
(setq var "value")      ; Sets variable
(insert "text")         ; Writes at cursor
(insert str1 str2)      ; Multiple args work

;; Functions & Functional Programming
;; -----------------------------
;; Functions are first-class citizens in Elisp. This isn't just academic
;; bullshit - it's the core of how Elisp works. Everything is either data
;; or a function that transforms data. Period.

;; Function Basics
;; ------------
;; Basic function definition. Nothing fancy.
(defun square (x)
  "Square a number because apparently that's useful."
  (* x x))

;; Interactive functions - can be called via M-x
(defun greet (name)
  "Greet someone or stay silent on nil."
  (interactive "sName: ")          ; 's' means string prompt
  (when name                       ; guard against nil
    (message "Hello, %s" name)))

;; Function Arguments
;; ---------------
;; Required args must be provided. Optional args can fuck off.
(defun full-name (first &optional last)  ; last is optional
  (if last
      (format "%s %s" first last)
    first))

;; Rest args - grab everything else
(defun sum (&rest numbers)
  (apply '+ numbers))              ; '+ is the function, not operator

;; Keyword arguments - when you need named params
(defun make-person (&key name age location)
  (list :name name :age age :location location))
;; Call it: (make-person :name "Bob" :age 42)

;; Lexical Scope & Closures
;; ---------------------
;; Lexical scope is default since Emacs 24.1. Dynamic scope is old news.
(let ((x 1))
  (let ((y 2))
    (let ((z 3))
      (message "x:%d y:%d z:%d" x y z))))  ; All visible here

;; Closures capture their environment
(defun make-counter ()
  "Create a counter. Each call increments."
  (let ((count 0))                ; Private state
    (lambda ()                    ; Return function
      (setq count (1+ count)))))

(setq c1 (make-counter))
(funcall c1)                      ; => 1
(funcall c1)                      ; => 2

;; Advanced Closure Example
;; --------------------
(defun make-adder (x)
  "Create a function that adds X to its argument."
  (lambda (y) (+ x y)))

(setq add5 (make-adder 5))
(funcall add5 10)                 ; => 15

;; Lambda Expressions
;; ---------------
;; Anonymous functions - use them, love them
(mapcar (lambda (x) (* x x)) '(1 2 3))  ; => (1 4 9)

;; Shorthand lambda reader macro
(mapcar #'(lambda (x) (* x x)) '(1 2 3))  ; Same thing

;; Function Composition
;; ----------------
(defun compose (f g)
  "Compose functions F and G."
  (lambda (x) (funcall f (funcall g x))))

(setq times2 (lambda (x) (* 2 x)))
(setq plus3 (lambda (x) (+ 3 x)))
(setq times2-plus3 (compose plus3 times2))

;; Higher-order Functions
;; ------------------
;; Functions that take/return functions
(defun apply-twice (f x)
  "Apply F to X twice."
  (funcall f (funcall f x)))

(apply-twice #'1+ 0)              ; => 2

;; Partial Application
;; ----------------
(defun partial (fn &rest args)
  "Partially apply FN with ARGS."
  (lambda (&rest more-args)
    (apply fn (append args more-args))))

(setq add10 (partial '+ 10))
(funcall add10 5)                 ; => 15

;; Advanced Scope Tricks
;; -----------------
;; let* for sequential binding
(let* ((x 5)
       (y (* x 2))                ; x is visible here
       (z (+ x y)))               ; both x and y visible
  z)

;; letrec for recursive bindings
(defun letrec (bindings &rest body)
  (let ((values (mapcar (lambda (x) nil) bindings)))
    (prog1
        (let (bindings)
          (mapcar (lambda (v b) (set v (eval b))) values bindings)
          (eval (cons 'progn body)))
      (mapcar 'makunbound values))))

;; Dynamic Scope (when you need it)
;; ---------------------------
;; Use special variables (dynamic scope) sparingly
(defvar *debug-enabled* nil)      ; Special variable
(let ((*debug-enabled* t))        ; Dynamic binding
  (should-i-debug))               ; Sees t

;; Multiple Value Binding
;; ------------------
(cl-multiple-value-bind (a b)
    (values 1 2)
  (list a b))                     ; => (1 2)

;; Functional Programming Patterns
;; --------------------------
;; Mapping
(mapcar #'1+ '(1 2 3))           ; => (2 3 4)
(mapcan #'list '(1 2 3))         ; Flatten results

;; Reduction
(reduce #'+ '(1 2 3 4))          ; => 10
(reduce #'cons '(1 2 3) :from-end t)  ; Build list

;; Filtering
(cl-remove-if-not #'evenp '(1 2 3 4))  ; => (2 4)

;; Real-world Example: Function Factory
;; ------------------------------
(defun make-incrementor (n)
  "Create a function that increments by N."
  (lambda (x) (+ x n)))

(defun make-checker (predicate transform)
  "Create validator that transforms value if predicate passes."
  (lambda (x)
    (if (funcall predicate x)
        (funcall transform x)
      x)))

;; Extended Example: Data Pipeline
;; --------------------------
(defun pipeline (&rest functions)
  "Compose multiple functions right to left."
  (lambda (x)
    (reduce #'funcall
            (reverse functions)
            :initial-value x)))

(setq process-data
      (pipeline
       #'string-to-number        ; Convert to number
       (lambda (x) (* x 2))      ; Double it
       #'number-to-string))      ; Back to string

;; Remember:
;; 1. Functions are values - treat them that way
;; 2. Closures capture their environment perfectly
;; 3. Lexical scope is your friend
;; 4. Dynamic scope is occasionally useful, mostly dangerous
;; 5. Composition > inheritance
;; 6. Pure functions > side effects


;; Lists: The Foundation
;; ------------------
;; If you don't understand lists, you don't understand Lisp.
;; Everything in Elisp is either an atom or a list. Yes, everything.
;; Your code? Lists. Your data? Lists. Get used to it.

;; List Creation
;; -----------
;; Quote prevents evaluation. Without it, Elisp tries to call first element
;; as function. Don't be that person.
(setq basic-list '(1 2 3))              ; Standard list
(setq nested-list '((1 2) (3 4)))       ; Lists within lists
(list 1 2 3)                            ; Dynamic list creation
(make-list 5 'x)                        ; => (x x x x x)

;; List Access - The Building Blocks
;; -----------------------------
;; car/cdr aren't cute names - they're fundamental operations.
(car '(1 2 3))                          ; => 1
(cdr '(1 2 3))                          ; => (2 3)
(car (cdr '(1 2 3)))                    ; => 2
(nth 1 '(1 2 3))                        ; => 2 (zero-based)

;; Composition Shortcuts
;; -----------------
;; Learn these. Use these. Love these.
(cadr lst)                              ; Same as (car (cdr lst))
(caddr lst)                             ; Third element
(last lst)                              ; Last cons cell
(butlast lst)                           ; All but last element

;; List Mutation
;; -----------
;; Mutation changes lists in place. Side effects ahead.
(setq my-list '(1 2 3))
(push 0 my-list)                        ; => (0 1 2 3)
(pop my-list)                           ; => 0, my-list now (1 2 3)
(setf (nth 1 my-list) 'changed)         ; Destructive change

;; List Operations
;; ------------
;; Higher-order functions are your friends
(mapcar '1+ '(1 2 3))                   ; => (2 3 4)
(remove 3 '(1 2 3 2 1))                 ; => (1 2 2 1)
(member 'needle '(hay needle stack))     ; => (needle stack)
(append '(1 2) '(3 4))                  ; => (1 2 3 4)

;; Association Lists (alists)
;; ----------------------
;; Poor man's hash table, but sometimes exactly what you need
(setq my-alist '((key1 . value1)
                 (key2 . value2)))
(assoc 'key1 my-alist)                  ; => (key1 . value1)
(rassoc 'value2 my-alist)               ; => (key2 . value2)

;; String Operations
;; --------------
;; Strings aren't lists, but they're sequences. Different rules apply.

;; String Creation and Basics
;; ----------------------
(make-string 5 ?x)                      ; => "xxxxx"
(substring "hello" 1 3)                 ; => "el"
(concat "hello" " " "world")            ; => "hello world"

;; String Formatting
;; --------------
;; Format specifiers that don't suck
(format "Int: %d String: %s Char: %c" 42 "foo" ?x)
(format-time-string "%Y-%m-%d")         ; Current date
(message "%S" complex-data-structure)    ; Debug printing

;; Search and Replace
;; --------------
;; Return value matters. Check it.
(string-match "pattern" "test pattern")  ; => 5 (position)
(replace-regexp-in-string "old" "new" "old text")

;; Case Operations
;; ------------
(upcase "hello")                        ; => "HELLO"
(downcase "HELLO")                      ; => "hello"
(capitalize "hello world")              ; => "Hello World"

;; Regular Expressions
;; ----------------
;; More powerful than you need, until you need more power

;; Basic Patterns
;; -----------
;; \\{n}    ; Exactly n times
;; \\{n,m}  ; n to m times
;; \\w      ; Word character
;; \\s-     ; Whitespace
;; \\(?:    ; Non-capturing group

;; Real-world Examples
;; ---------------
(string-match "\\([0-9]+\\)" "abc123def")  ; Captures "123"
(match-string 1 "abc123def")               ; Gets captured group

;; Common Patterns
(defvar number-regex "\\([0-9]+\\(?:\\.[0-9]*\\)?\\)")
(defvar email-regex "\\([^@]+\\)@\\([^@]+\\)")

;; Search with Context
;; ---------------
(save-excursion
  (save-match-data
    (while (re-search-forward pattern nil t)
      (replace-match replacement))))

;; Text Properties
;; -------------
;; Every character can have properties. Use them wisely.

;; Basic Properties
;; -------------
(put-text-property start end 'face 'bold)
(put-text-property start end 'invisible t)
(put-text-property start end 'read-only t)

;; Multiple Properties
;; ---------------
(add-text-properties start end
                     '(face bold
                            mouse-face highlight
                            help-echo "Click me"))

;; Property Lists
;; -----------
(setq props '(face bold keyboard-help "Press to activate"))
(add-text-properties start end props)

;; Examining Properties
;; ----------------
(get-text-property pos 'face)
(text-properties-at pos)
(next-property-change pos)

;; Advanced Text Properties
;; --------------------
;; Create clickable text
(insert-text-button "Click me"
                    'action (lambda (button)
                              (message "Clicked!"))
                    'follow-link t
                    'help-echo "Click for action")

;; Real-world Example: Syntax Highlighting
;; ---------------------------------
(defun highlight-numbers ()
  "Highlight all numbers in buffer"
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "\\([0-9]+\\)" nil t)
      (add-text-properties
       (match-beginning 1) (match-end 1)
       '(face (:foreground "red" :weight bold))))))

;; Remember:
;; 1. Lists are immutable unless you mutate them
;; 2. Text properties are buffer-local
;; 3. Regular expressions are greedy by default
;; 4. Always use save-match-data for regex operations

;; Basic Buffer Creation & Navigation
;; -------------------------------
;; Create a new buffer or switch to existing one. Don't be an idiot -
;; use meaningful names.
(get-buffer-create "*test*")  ; Returns buffer, creates if needed

;; Switch to buffer in current window. Simple but sometimes wrong.
(switch-to-buffer "*test*")   ; Potentially destructive

;; The right way - preserve window state:
(switch-to-buffer-other-window "*test*")  ; Safe, creates split

;; Traverse window layout. Count matters - negative goes backward.
(other-window 1)              ; Forward one window
(other-window -1)             ; Backward one window

;; Buffer State Management
;; --------------------
;; Don't just create buffers willy-nilly. Clean up after yourself.
(progn
  (switch-to-buffer-other-window "*test*")
  (erase-buffer)              ; Nuke contents. No undo. No whining.
  (insert "Fresh slate\n")
  (other-window 1))           ; Return to origin

;; Buffer isn't responding? Force it:
(kill-buffer "*test*")        ; Kills buffer. No questions asked.

;; Buffer Content Operations
;; ---------------------
;; Your buffer is empty. Fill it with something useful.
(insert "Hello")                         ; Basic insertion
(insert "Hello" " " "World")            ; Multiple args
(insert (format "%d bottles" 99))        ; Formatted text

;; Formatted insertions - because plain text is boring
(insert (propertize "Bold" 'face 'bold)) ; Styled text
(insert ?\n)                            ; Raw characters
(insert-char ?\s 5)                     ; Repeat chars
(insert (make-string 40 ?-))            ; Line separators

;; Structured content insertion
(let ((start (point)))
  (insert "Important text")
  (put-text-property start (point)
                     'face '(:foreground "red")))

;; Multi-line content - keep it organized
(insert (concat "Section 1\n"
                "  Subsection A\n"
                "  Subsection B\n"))

;; Buffer Position & Movement
;; ----------------------
;; Point = cursor position. Learn it. Love it. Stop using arrow keys.
(goto-char (point-min))       ; Start of buffer
(goto-char (point-max))       ; End of buffer
(point)                       ; Current position (integer)

;; Move relatively because hardcoding positions is moronic:
(forward-char 5)              ; Forward 5 chars
(backward-char 3)             ; Backward 3 chars
(forward-line 1)              ; Next line
(forward-line -1)             ; Previous line

;; Advanced Buffer Operations
;; ----------------------
;; Want to do something to all buffers? Use iteration:
(defun nuke-all-buffers ()
  "Kill all buffers. Period. Use with caution."
  (interactive)
  (mapc 'kill-buffer (buffer-list)))

;; Buffer Local Variables
;; -------------------
;; Each buffer has its own variable namespace. Use it.
(make-local-variable 'my-special-var)     ; Create buffer-local var
(setq-local my-special-var 42)            ; Set buffer-local value

;; Check if buffer exists before doing stupid things:
(when (get-buffer "*test*")
  (with-current-buffer "*test*"
    (erase-buffer)
    (insert "Buffer exists, nuking contents\n")))

;; Temporary Buffer Operations
;; -----------------------
;; Need to do something in a buffer without side effects?
;; Use with-temp-buffer. Always.
(with-temp-buffer
  (insert "This buffer will self-destruct\n")
  (buffer-string))            ; Get contents as string

;; Real Buffer Power
;; --------------
;; Want to see why buffers matter? Try this:
(defun buffer-stats ()
  "Get stats about all buffers because why not."
  (interactive)
  (let ((total-size 0)
        (buffer-count 0))
    (dolist (buffer (buffer-list))
      (with-current-buffer buffer
        (setq total-size (+ total-size (buffer-size)))
        (setq buffer-count (1+ buffer-count))))
    (message "Total: %d buffers, %d chars"
             buffer-count total-size)))

;; Buffer Marks & Regions
;; -------------------
;; Marks are positions you care about. Don't lose them.
(push-mark)                   ; Set mark at point
(pop-mark)                    ; Pop mark ring
(mark)                        ; Get current mark
(exchange-point-and-mark)     ; Swap point and mark

;; The Golden Rule of Buffers
;; -----------------------
;; Every buffer operation should be:
;; 1. Intentional   - Know what you're changing
;; 2. Reversible    - Unless explicitly destructive
;; 3. Efficient     - Don't loop when mapcar will do
;; 4. Self-contained - Clean up your mess

;; Advanced Real-World Example
;; -----------------------
;; Here's how you'd implement a buffer snapshot system:
(defun snapshot-buffer ()
  "Create a snapshot of current buffer because paranoia is good."
  (interactive)
  (let ((snap-name (format "*snapshot-%s-%s*"
                           (buffer-name)
                           (format-time-string "%H:%M:%S"))))
    (with-current-buffer (get-buffer-create snap-name)
      (insert-buffer-substring (current-buffer))
      (setq buffer-read-only t)           ; Lock it
      (message "Snapshot created: %s" snap-name))))

;; Want to make your buffer operations bulletproof? Wrap them:
(defmacro with-safe-buffer-ops (buffer-name &rest body)
  "Execute BODY in BUFFER-NAME with error handling because stuff happens."
  `(condition-case err
       (with-current-buffer ,buffer-name
         ,@body)
     (error (message "Buffer operation failed: %s" err)
            nil)))

;; Use it like this:
(with-safe-buffer-ops "*test*"
                      (erase-buffer)
                      (insert "Safe operations\n"))


;; Help System
;; ---------
;; C-h v VAR    ; Variable docs
;; C-h f FUNC   ; Function docs
;; C-h i m elisp ; Manual
;;
;; RTFM: https://www.gnu.org/software/emacs/manual/html_node/eintr/index.html

;; Remember:
;; - Parentheses are your friends (until they're not)
;; - Everything is an expression
;; - Side effects will bite you
;; - The buffer is your universe
