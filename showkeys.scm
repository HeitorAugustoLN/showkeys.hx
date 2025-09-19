(require "helix/components.scm")
(require "helix/misc.scm")
(require "helix/editor.scm")
(require-builtin steel/strings)

(struct showkeys-state (keys timer-id) #:transparent)

(define *showkeys-state* (showkeys-state (box '()) (box 0)))

(define key-format
  (hash "<esc>" "Esc"
        "<bs>" "Backspace"
        "<cr>" "Enter"
        "<tab>" "Tab"
        "<left>" "Left"
        "<right>" "Right"
        "<up>" "Up"
        "<down>" "Down"
        "<space>" "Space"))

(define (key->string event)
  (if (key-event? event)
      (let ([char (key-event-char event)]
            [modifier (key-event-modifier event)])
        (if (and char (equal? modifier key-modifier-shift))
            (string (char-upcase char))
            (let ([mod-str
                   (cond
                     [(equal? modifier key-modifier-ctrl) "Ctrl"]
                     [(equal? modifier key-modifier-alt) "Alt"]
                     [(equal? modifier key-modifier-shift) "Shift"]
                     [(equal? modifier key-modifier-super) "Super"]
                     [else #f])]
                  [key-name
                   (cond
                     [(key-event-escape? event) "<esc>"]
                     [(key-event-backspace? event) "<bs>"]
                     [(key-event-enter? event) "<cr>"]
                     [(key-event-tab? event) "<tab>"]
                     [(key-event-left? event) "<left>"]
                     [(key-event-right? event) "<right>"]
                     [(key-event-up? event) "<up>"]
                     [(key-event-down? event) "<down>"]
                     [(and char (equal? char #\space)) "<space>"]
                     [char (string char)]
                     [else #f])])
              (when key-name
                (let ([formatted-key (or (hash-try-get key-format key-name) key-name)])
                  (if mod-str
                      (string-append mod-str " + " formatted-key)
                      formatted-key))))))
      #f))

(define (take-n lst n)
  (if (or (<= n 0) (null? lst))
      '()
      (cons (car lst) (take-n (cdr lst) (- n 1)))))

(define (showkeys-handle-event state event)
  (let ([key-str (key->string event)])
    (when key-str
      (let* ([current-keys (unbox (showkeys-state-keys *showkeys-state*))]
             [new-keys (cons key-str current-keys)]
             [trimmed-keys (if (> (length new-keys) 8)
                               (take-n new-keys 8)
                               new-keys)])
        (set-box! (showkeys-state-keys *showkeys-state*) trimmed-keys)

        (let ([timer-id (+ (unbox (showkeys-state-timer-id *showkeys-state*)) 1)])
          (set-box! (showkeys-state-timer-id *showkeys-state*) timer-id)
          (enqueue-thread-local-callback-with-delay
           3000
           (lambda ()
             (let ([current-timer-id (unbox (showkeys-state-timer-id *showkeys-state*))])
               (when (equal? current-timer-id timer-id)
                 (set-box! (showkeys-state-keys *showkeys-state*) '())))))))))
  event-result/ignore)

(define (showkeys-render state rect frame)
  (let ([keys (unbox (showkeys-state-keys *showkeys-state*))])
    (when (not (null? keys))
      (let* ([text (string-join (reverse keys) " ")]
             [width (+ (string-length text) 2)]
             [height 3]
             [x (quotient (- (area-width rect) width) 2)]
             [y (- (area-height rect) height 2)]
             [popup-style (theme-scope "ui.popup")]
             [text-style (theme-scope "ui.text")])
        (block/render frame (area x y width height) (make-block popup-style popup-style "all" "rounded"))
        (frame-set-string! frame (+ x 1) (+ y 1) text text-style)))))

(define (showkeys-cursor-handler state rect) #f)

(define *showkeys-component-active* #f)

(define (showkeys-toggle)
  (if *showkeys-component-active*
      (begin
        (pop-last-component-by-name! "showkeys")
        (set! *showkeys-component-active* #f))
      (begin
        (push-component!
         (new-component! "showkeys"
                         *showkeys-state*
                         showkeys-render
                         (hash "handle_event" showkeys-handle-event
                               "cursor" showkeys-cursor-handler)))
        (set! *showkeys-component-active* #t))))

(provide showkeys-toggle)
