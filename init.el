;;; -*- lexical-binding: t -*-
;;; init.el --- Clean and pragmatic Emacs configuration
;; =======================
;; Package Management
;; =======================

(defvar bootstrap-version)
(let ((bootstrap-file
       (expand-file-name
        "straight/repos/straight.el/bootstrap.el"
        (or (bound-and-true-p straight-base-dir)
            user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent 'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

;; =======================
;; Core Settings
;; =======================

;; Performance optimizations
(setq gc-cons-threshold 50000000
      load-prefer-newer t
      large-file-warning-threshold 100000000
      confirm-kill-processes nil)

;; UI cleanup
(setq inhibit-startup-screen t
      initial-scratch-message
      (concat ";;      _________\n"
              ";;     / ======= \\\n"
              ";;    / __________\\\n"
              ";;   | ___________ |\n"
              ";;   | |e        | |\n"
              ";;   | |         | |\n"
              ";;   | |_________| |______________________________\n"
              ";;   \\_____________/   ==== _  _  __   __  __     )\n"
              ";;   /\\\\\\\\\\\\\\\\\\\\\\\\\\\\   |__  |\\/| |__| |   [__    \\/\n"
              ";;  / ::::::::::::: \\  |    |||| |  | |__  __]  /\n"
              ";; (_________________) ====                    /\n"
              ";;                                         =D-'\n"
              ";; Emacs Version: " emacs-version "\n"
              ";;\n"
              "(message \"Welcome to Emacs!\")\n\n"))

;; Better defaults
(setq-default
 indent-tabs-mode nil
 tab-width 4
 fill-column 80
 truncate-lines t)

;; File handling
(setq backup-directory-alist '(("." . "~/.emacs.d/backups"))
      backup-by-copying t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t)

;; Built-in enhancements
(recentf-mode 1)
(setq recentf-max-saved-items 1000)
(show-paren-mode 1)
(electric-pair-mode 1)
(savehist-mode 1)
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; Minibuffer settings
(setq enable-recursive-minibuffers t
      read-extended-command-predicate #'command-completion-default-include-p
      minibuffer-prompt-properties
      '(read-only t cursor-intangible t face minibuffer-prompt))

;; Hide warnings buffer
(add-to-list 'display-buffer-alist
             '("^\\*Warnings\\*" . (display-buffer-no-window)))

;; =======================
;; System Integration
;; =======================

(use-package vterm)
(use-package multi-vterm)

(use-package exec-path-from-shell
  :config
  (when (or (daemonp) (memq window-system '(mac ns x)))
    (exec-path-from-shell-initialize)))

(use-package sudo-edit
  :commands sudo-edit)

(use-package xclip
  :config
  (xclip-mode 1))

;; Enable Vertico.
(use-package vertico
  :custom
  ;; (vertico-scroll-margin 0) ;; Different scroll margin
  (vertico-count 20) ;; Show more candidates
  ;; (vertico-resize t) ;; Grow and shrink the Vertico minibuffer
  ;; (vertico-cycle t) ;; Enable cycling for `vertico-next/previous'
  :init
  (vertico-mode))

;; Persist history over Emacs restarts. Vertico sorts by history position.
(use-package savehist
  :init
  (savehist-mode))

;; Emacs minibuffer configurations.
(use-package emacs
  :custom
  ;; Enable context menu. `vertico-multiform-mode' adds a menu in the minibuffer
  ;; to switch display modes.
  (context-menu-mode t)
  ;; Support opening new minibuffers from inside existing minibuffers.
  (enable-recursive-minibuffers t)
  ;; Hide commands in M-x which do not work in the current mode.  Vertico
  ;; commands are hidden in normal buffers. This setting is useful beyond
  ;; Vertico.
  (read-extended-command-predicate #'command-completion-default-include-p)
  ;; Do not allow the cursor in the minibuffer prompt
  (minibuffer-prompt-properties
   '(read-only t cursor-intangible t face minibuffer-prompt)))

;; Optionally use the `orderless' completion style.
(use-package orderless
  :custom
  ;; Configure a custom style dispatcher (see the Consult wiki)
  ;; (orderless-style-dispatchers '(+orderless-consult-dispatch orderless-affix-dispatch))
  ;; (orderless-component-separator #'orderless-escapable-split-on-space)
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

;; Marginalia: Rich annotations in the minibuffer
(use-package marginalia
  :init
  (marginalia-mode))

;; Embark: Act on targets
(use-package embark
  :bind
  (("C-." . embark-act)         ;; pick some comfortable binding
   ("C-;" . embark-dwim)        ;; good alternative: M-.
   ("C-h B" . embark-bindings)) ;; alternative for `describe-bindings'
  :init
  ;; Optionally replace the key help with a completing-read interface
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  ;; Hide the mode line of the Embark live/completions buffers
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

;; Consult users will also want the embark-consult package.
(use-package embark-consult
  :hook
  (embark-collect-mode . consult-preview-at-point-mode))

;; Consult: Consulting completing-read
(use-package consult
  :bind (;; C-c bindings in `mode-specific-map'
         ("C-c M-x" . consult-mode-command)
         ("C-c h" . consult-history)
         ("C-c k" . consult-kmacro)
         ("C-c m" . consult-man)
         ("C-c i" . consult-info)
         ([remap Info-search] . consult-info)
         ;; C-x bindings in `ctl-x-map'
         ("C-x M-:" . consult-complex-command)     ;; orig. repeat-complex-command
         ("C-x b" . consult-buffer)                ;; orig. switch-to-buffer
         ("C-x 4 b" . consult-buffer-other-window) ;; orig. switch-to-buffer-other-window
         ("C-x 5 b" . consult-buffer-other-frame)  ;; orig. switch-to-buffer-other-frame
         ("C-x t b" . consult-buffer-other-tab)    ;; orig. switch-to-buffer-other-tab
         ("C-x r b" . consult-bookmark)            ;; orig. bookmark-jump
         ("C-x p b" . consult-project-buffer)      ;; orig. project-switch-to-buffer
         ;; Custom M-# bindings for fast register access
         ("M-#" . consult-register-load)
         ("M-'" . consult-register-store)          ;; orig. abbrev-prefix-mark (unrelated)
         ("C-M-#" . consult-register)
         ;; Other custom bindings
         ("M-y" . consult-yank-pop)                ;; orig. yank-pop
         ;; M-g bindings in `goto-map'
         ("M-g e" . consult-compile-error)
         ("M-g f" . consult-flymake)               ;; Alternative: consult-flycheck
         ("M-g g" . consult-goto-line)             ;; orig. goto-line
         ("M-g M-g" . consult-goto-line)           ;; orig. goto-line
         ("M-g o" . consult-outline)               ;; Alternative: consult-org-heading
         ("M-g m" . consult-mark)
         ("M-g k" . consult-global-mark)
         ("M-g i" . consult-imenu)
         ("M-g I" . consult-imenu-multi)
         ;; M-s bindings in `search-map'
         ("M-s d" . consult-find)                  ;; Alternative: consult-fd
         ("M-s c" . consult-locate)
         ("M-s g" . consult-grep)
         ("M-s G" . consult-git-grep)
         ("M-s r" . consult-ripgrep)
         ("M-s l" . consult-line)
         ("M-s L" . consult-line-multi)
         ("M-s k" . consult-keep-lines)
         ("M-s u" . consult-focus-lines)
         ;; Isearch integration
         ("M-s e" . consult-isearch-history)
         :map isearch-mode-map
         ("M-e" . consult-isearch-history)         ;; orig. isearch-edit-string
         ("M-s e" . consult-isearch-history)       ;; orig. isearch-edit-string
         ("M-s l" . consult-line)                  ;; needed by consult-line to detect isearch
         ("M-s L" . consult-line-multi)            ;; needed by consult-line to detect isearch
         ;; Minibuffer history
         :map minibuffer-local-map
         ("M-s" . consult-history)                 ;; orig. next-matching-history-element
         ("M-r" . consult-history))                ;; orig. previous-matching-history-element
  :hook (completion-list-mode . consult-preview-at-point-mode)
  :init
  ;; Optionally configure the register formatting. This improves the register
  ;; preview for `consult-register', `consult-register-load',
  ;; `consult-register-store' and the Emacs built-ins.
  (setq register-preview-delay 0.5
        register-preview-function #'consult-register-format)

  ;; Optionally tweak the register preview window.
  ;; This adds thin lines, sorting and hides the mode line of the window.
  (advice-add #'register-preview :override #'consult-register-window)

  ;; Use Consult to select xref locations with preview
  (setq xref-show-xrefs-function #'consult-xref
        xref-show-definitions-function #'consult-xref)

  :config
  ;; Optionally configure preview. The default value
  ;; is 'any, such that any key triggers the preview.
  ;; (setq consult-preview-key 'any)
  ;; (setq consult-preview-key "M-.")
  ;; (setq consult-preview-key '("S-<down>" "S-<up>"))
  ;; For some commands and buffer sources it is useful to configure the
  ;; :preview-key on a per-command basis using the `consult-customize' macro.
  (consult-customize
   consult-theme :preview-key '(:debounce 0.2 any)
   consult-ripgrep consult-git-grep consult-grep
   consult-bookmark consult-recent-file consult-xref
   consult--source-bookmark consult--source-file-register
   consult--source-recent-file consult--source-project-recent-file
   ;; :preview-key "M-."
   :preview-key '(:debounce 0.4 any))

  ;; Optionally configure the narrowing key.
  ;; Both < and C-+ work reasonably well.
  (setq consult-narrow-key "<") ;; "C-+"

  ;; Optionally make narrowing help available in the minibuffer.
  ;; You may want to use `embark-prefix-help-command' or which-key instead.
  ;; (define-key consult-narrow-map (vconcat consult-narrow-key "?") #'consult-narrow-help)

  ;; By default `consult-project-function' uses `project-root' from project.el.
  ;; Optionally configure a different project root function.
  ;; There are multiple reasonable alternatives to chose from.
  ;;;; 1. project.el (the default)
  ;; (setq consult-project-function #'consult--default-project--function)
  ;;;; 2. vc.el (vc-root-dir)
  ;; (setq consult-project-function (lambda (_) (vc-root-dir)))
  ;;;; 3. locate-dominating-file
  ;; (setq consult-project-function (lambda (_) (locate-dominating-file "." ".git")))
  ;;;; 4. projectile.el (projectile-project-root)
  (setq consult-project-function (lambda (_) (projectile-project-root)))
  ;;;; 5. No project support
  ;; (setq consult-project-function nil)
)

;; =======================
;; Evil Mode & Keybindings
;; =======================

(use-package evil
  :init
  (setq evil-want-keybinding nil
        evil-want-integration t
        evil-want-C-u-scroll t
        evil-want-C-i-jump nil
        evil-undo-system 'undo-redo)
  :config
  (evil-mode 1)

  ;; Visual line motions
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

  ;; Navigation bindings
  (evil-define-key 'normal 'global (kbd "gd") 'xref-find-definitions)
  (evil-define-key 'normal 'global (kbd "gD") 'xref-find-definitions-other-window)

  ;; Initial states
  (evil-set-initial-state 'messages-buffer-mode 'normal)
  (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package evil-surround
  :after evil
  :config
  (global-evil-surround-mode 1))

(use-package evil-nerd-commenter
  :after evil
  :bind ("M-;" . evilnc-comment-or-uncomment-lines))

(use-package general
  :after evil
  :config
  ;; Define leader key functions
  (general-create-definer my-leader-def
    :keymaps '(normal insert visual emacs)
    :prefix "SPC"
    :global-prefix "C-SPC")

  (general-create-definer my-local-leader-def
    :states '(normal visual)
    :keymaps 'override
    :prefix ",")

  ;; Global leader bindings
  (my-leader-def
    ;; Core commands
    ":" 'execute-extended-command
    "SPC" 'project-find-file
    "." 'embark-act
    "," 'consult-buffer

    ;; Files
    "ff" 'find-file
    "fs" 'save-buffer
    "fr" 'consult-recent-file

    ;; Buffers
    "bb" 'consult-buffer
    "bd" 'kill-buffer
    "bi" 'ibuffer
    "bn" 'next-buffer
    "bp" 'previous-buffer

    ;; Windows
    "ws" 'split-window-below
    "wv" 'split-window-right
    "wh" 'evil-window-left
    "wj" 'evil-window-down
    "wk" 'evil-window-up
    "wl" 'evil-window-right
    "wd" 'delete-window
    "wD" 'kill-buffer-and-window
    "wmm" 'delete-other-windows
    "wr" 'my/resize-window

    ;; Projects
    "pp" 'projectile-switch-project
    "pb" 'consult-project-buffer
    "pc" 'projectile-compile-project
    "pk" 'projectile-kill-buffers
    "pd" 'projectile-dired
    "pr" 'projectile-replace
    "pf" 'project-find-file
    "pg" 'consult-ripgrep

    ;; VTERM
    "ot" 'vterm

    ;; Search & Navigation
    "ss" 'consult-line
    "sS" 'consult-line-multi
    "sp" 'consult-line-multi
    "sf" 'consult-find
    "sg" 'consult-grep
    "sG" 'consult-git-grep
    "sr" 'consult-ripgrep
    "sl" 'consult-locate
    "sm" 'consult-mark
    "sR" 'consult-resume
    "so" 'consult-outline
    "si" 'consult-imenu
    "sI" 'consult-imenu-multi

    ;; Tools
    "op" 'treemacs
    "dl" 'downcase-current-line

    ;; Consult specific
    "hh" 'describe-function
    "hm" 'consult-man
    "hc" 'list-colors-display
    "hf" 'describe-function
    "hy" 'consult-yank-pop
    "hx" 'consult-register
    "hz" 'consult-complex-command))

;; =======================
;; Completion & Navigation
;; =======================

(use-package avy
  :demand t
  :general
  (general-def '(normal motion)
    "s" 'evil-avy-goto-char-timer
    "f" 'evil-avy-goto-char-in-line
    "gl" 'evil-avy-goto-line
    ";" 'avy-resume)
  :init
  ;; Avy actions
  (defun my/avy-action-insert-newline (pt)
    (save-excursion (goto-char pt) (newline))
    (select-window (cdr (ring-ref avy-ring 0))))

  (defun my/avy-action-kill-whole-line (pt)
    (save-excursion (goto-char pt) (kill-whole-line))
    (select-window (cdr (ring-ref avy-ring 0))))

  (defun my/avy-action-embark (pt)
    (unwind-protect
        (save-excursion (goto-char pt) (embark-act))
      (select-window (cdr (ring-ref avy-ring 0))))
    t)
  :config
  (setf (alist-get ?. avy-dispatch-alist) 'my/avy-action-embark
        (alist-get ?i avy-dispatch-alist) 'my/avy-action-insert-newline
        (alist-get ?K avy-dispatch-alist) 'my/avy-action-kill-whole-line))

(use-package projectile
  :diminish projectile-mode
  :config
  (projectile-mode +1)
  (setq projectile-completion-system 'default
        projectile-enable-caching t))

(use-package treemacs)
(use-package ripgrep)

;; =======================
;; Development Tools
;; =======================

(use-package company
  :diminish company-mode
  :hook (after-init . global-company-mode)
  :config
  (setq company-idle-delay 0.3
        company-minimum-prefix-length 2
        company-selection-wrap-around t))

(use-package flycheck
  :diminish flycheck-mode
  :hook (after-init . global-flycheck-mode)
  :config
  (setq flycheck-emacs-lisp-load-path 'inherit))

;; =======================
;; Language Configurations
;; =======================

;; Common S-expression keybindings for all Lisp modes
(defun setup-lisp-sexp-keybindings ()
  "Setup common S-expression keybindings for all Lisp modes."
  (my-local-leader-def
    :keymaps 'local
    "k=" 'sp-reindent
    "kW" 'sp-unwrap-sexp
    "kb" 'sp-forward-barf-sexp
    "kB" 'sp-backward-barf-sexp
    "kd" 'sp-kill-sexp
    "kr" 'sp-raise-sexp
    "ks" 'sp-forward-slurp-sexp
    "kS" 'sp-backward-slurp-sexp
    "kt" 'sp-transpose-sexp
    "kw" 'sp-wrap-sexp
    "ky" 'sp-copy-sexp))

;; Emacs Lisp
(defun setup-emacs-lisp-keybindings ()
  "Setup comprehensive Emacs Lisp specific keybindings."
  (my-local-leader-def
    :keymaps 'local
    ;; Evaluation
    "eb" 'eval-buffer
    "ed" 'eval-defun
    "ee" 'eval-last-sexp
    "er" 'eval-region
    "eE" 'eval-expression
    "eI" 'edebug-instrument-function
    "eU" 'edebug-remove-instrumentation
    "ep" 'pp-eval-last-sexp
    "eP" 'pp-eval-expression
    "el" 'load-library
    "eL" 'load-file
    "ef" 'eval-defun-and-go
    "em" 'eval-print-last-sexp
    "eM" 'pp-macroexpand-last-sexp

    ;; Navigation & Finding
    "gf" 'find-function
    "gF" 'find-function-other-window
    "gv" 'find-variable
    "gV" 'find-variable-other-window
    "gl" 'find-library
    "gL" 'find-library-other-window
    "gk" 'find-function-on-key
    "gK" 'describe-key-briefly

    ;; Help & Documentation
    "hf" 'describe-function
    "hv" 'describe-variable
    "hk" 'describe-key
    "hm" 'describe-mode
    "hp" 'describe-package
    "ht" 'describe-theme
    "hF" 'describe-face
    "hb" 'describe-bindings
    "hc" 'describe-char
    "hs" 'describe-syntax
    "ha" 'apropos
    "hA" 'apropos-command
    "hw" 'where-is
    "hi" 'info-apropos

    ;; Debugging
    "db" 'edebug-set-breakpoint
    "dB" 'edebug-unset-breakpoint
    "dc" 'edebug-continue
    "dn" 'edebug-next-mode
    "ds" 'edebug-step-mode
    "dg" 'edebug-go-mode
    "dG" 'edebug-Go-nonstop-mode
    "dt" 'edebug-trace-mode
    "dT" 'edebug-Trace-fast-mode
    "dq" 'top-level
    "dd" 'debug-on-entry
    "dD" 'cancel-debug-on-entry

    ;; Macros
    "me" 'macroexpand
    "mE" 'macroexpand-all
    "m1" 'macroexpand-1
    "mp" 'pp-macroexpand-last-sexp
    "mP" 'pp-macroexpand-expression

    ;; Testing
    "tt" 'ert
    "tr" 'ert-run-tests-batch
    "td" 'ert-describe-test
    "tD" 'ert-delete-test

    ;; Compilation & Building
    "cc" 'compile
    "cr" 'recompile
    "cb" 'byte-compile-file
    "cB" 'byte-recompile-directory
    "cd" 'disassemble

    ;; Package Management
    "pl" 'list-packages
    "pi" 'package-install
    "pd" 'package-delete
    "pr" 'package-refresh-contents
    "pu" 'package-list-packages-no-fetch

    ;; Buffer & File Operations
    "bf" 'byte-compile-file
    "bb" 'eval-buffer
    "br" 'eval-region
    "bR" 'revert-buffer

    ;; Customization
    "cu" 'customize-group
    "cv" 'customize-variable
    "cf" 'customize-face
    "ct" 'customize-themes
    "ca" 'customize-apropos))

(add-hook 'emacs-lisp-mode-hook 'setup-lisp-sexp-keybindings)
(add-hook 'emacs-lisp-mode-hook 'setup-emacs-lisp-keybindings)

;; =======================
;; Clojure Setup 
;; =======================
;; Clojure with CIDER
(use-package cider
  :config
  (defun setup-clojure-keybindings ()
    "Setup essential Clojure/CIDER keybindings modeled after SLIME."
    (my-local-leader-def
      :keymaps 'local
      ;; REPL Connection & Management (4 bindings)
      "'" 'cider-jack-in                    ; Start REPL (like slime)
      "rq" 'cider-quit                      ; Quit REPL
      "rr" 'cider-restart                   ; Restart REPL
      "rB" 'cider-repl-clear-buffer        ; Clear REPL buffer
      
      ;; Evaluation (6 bindings)
      "eb" 'cider-eval-buffer              ; Eval buffer
      "ed" 'cider-eval-defun-at-point      ; Eval defun
      "ee" 'cider-eval-last-sexp           ; Eval last expression
      "er" 'cider-eval-region              ; Eval region
      "eE" 'cider-read-and-eval            ; Interactive eval
      "ep" 'cider-pprint-eval-last-sexp    ; Pretty print eval
      
      ;; Navigation & Finding (4 bindings)
      "gd" 'cider-find-var                 ; Go to definition
      "gD" 'cider-find-var-other-window    ; Go to def other window
      "gb" 'cider-pop-back                 ; Pop back from definition
      "gr" 'cider-find-references-at-point ; Find references
      
      ;; Help & Documentation (3 bindings)
      "hd" 'cider-doc                      ; Show documentation
      "ha" 'cider-apropos                  ; Apropos search
      "hj" 'cider-javadoc                  ; Java documentation
      
      ;; Testing (2 bindings)
      "tt" 'cider-test-run-test            ; Run test at point
      "ta" 'cider-test-run-all-tests       ; Run all tests
      
      ;; Debugging (1 binding)
      "di" 'cider-inspect-last-result))    ; Inspect last result
  
  (add-hook 'clojure-mode-hook 'setup-clojure-keybindings)
  (add-hook 'cider-mode-hook 'setup-clojure-keybindings))

(use-package reformatter
  :ensure t
  :config
  (reformatter-define cljfmt
    :program "cljfmt"
    :args '("fix" "-")
    :stdin t
    :stdout t
    :lighter " cljfmt"))

;; =======================
;; Fennel Setup
;; =======================

;; Fennel with fennel-mode
(use-package fennel-mode
  :config
  (defun setup-fennel-keybindings ()
    "Setup essential Fennel specific keybindings."
    (my-local-leader-def
      :keymaps 'local
      ;; REPL & Evaluation
      "'" 'fennel-repl
      "eb" 'fennel-eval-buffer
      "ee" 'fennel-eval-last-sexp
      "er" 'fennel-eval-region
      "el" 'fennel-load-file

      ;; Compilation
      "cb" 'fennel-compile-buffer
      "cf" 'fennel-compile-file

      ;; Navigation
      "gd" 'fennel-find-definition
      "gb" 'xref-pop-marker-stack

      ;; Help & Documentation
      "hd" 'fennel-describe-symbol
      "ha" 'fennel-apropos

      ;; Development
      "mb" 'fennel-macroexpand-1
      "mM" 'fennel-macroexpand-all
      "rf" 'fennel-format-buffer
      "rb" 'switch-to-fennel-repl))

  ;; Add hooks for both fennel-mode and potential lua-mode when editing compiled output
  (add-hook 'fennel-mode-hook 'setup-lisp-sexp-keybindings)
  (add-hook 'fennel-mode-hook 'setup-fennel-keybindings)
  
  ;; Optional: configure fennel-mode settings
  (setq fennel-mode-switch-to-repl-after-reload nil
        fennel-mode-auto-detect-repl-type t))

;; =======================
;; LSP Mode Setup
;; =======================

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook ((go-mode . lsp-deferred)
         (go-ts-mode . lsp-deferred))
  :init
  ;; Performance tuning
  (setq lsp-idle-delay 0.5
        lsp-log-io nil
        read-process-output-max (* 1024 1024)
        lsp-completion-provider :none  ; Use company-capf
        lsp-prefer-flymake nil)         ; Use flycheck
  
  :config
  ;; LSP UI settings
  (setq lsp-eldoc-enable-hover t
        lsp-eldoc-render-all nil
        lsp-signature-auto-activate t
        lsp-signature-render-documentation t
        lsp-modeline-diagnostics-enable t
        lsp-modeline-code-actions-enable t
        lsp-diagnostics-provider :flycheck
        lsp-enable-file-watchers t
        lsp-file-watch-threshold 2000)
  
  ;; Go specific LSP settings
  (setq lsp-go-analyses '((fieldalignment . t)
                          (nilness . t)
                          (shadow . t)
                          (unusedparams . t)
                          (unusedwrite . t)
                          (useany . t)
                          (unusedvariable . t))
        lsp-go-codelenses '((gc_details . t)
                           (generate . t)
                           (regenerate_cgo . t)
                           (test . t)
                           (tidy . t)
                           (upgrade_dependency . t)
                           (vendor . t))
        lsp-go-use-gofumpt t
        lsp-go-goimports-local ""
        lsp-go-link-target "pkg.go.dev"))

(use-package lsp-ui
  :after lsp-mode
  :config
  (setq lsp-ui-doc-enable t
        lsp-ui-doc-position 'at-point
        lsp-ui-doc-show-with-cursor nil
        lsp-ui-doc-show-with-mouse t
        lsp-ui-doc-delay 1
        lsp-ui-sideline-enable t
        lsp-ui-sideline-show-diagnostics t
        lsp-ui-sideline-show-hover nil
        lsp-ui-sideline-show-code-actions t
        lsp-ui-sideline-delay 0.5
        lsp-ui-peek-enable t
        lsp-ui-peek-list-width 60
        lsp-ui-peek-peek-height 25
        lsp-ui-imenu-enable t))

;; =======================
;; Go Mode Setup
;; =======================

(use-package go-mode
  :mode "\\.go\\'"
  :config
  ;; Format on save
  (setq gofmt-command "goimports")
  (add-hook 'before-save-hook 'gofmt-before-save nil t)
  
  ;; Go specific settings
  (setq go-test-verbose t
        compile-command "go build -v && go test -v && go vet"))

;; Additional Go tools
(use-package go-tag
  :after go-mode)

(use-package go-fill-struct
  :after go-mode)

(use-package go-impl
  :after go-mode)

(use-package go-gen-test
  :after go-mode)

(use-package gotest
  :after go-mode)

(use-package go-playground
  :after go-mode)

;; =======================
;; DAP Mode (Debugging)
;; =======================

(use-package dap-mode
  :after lsp-mode
  :config
  (dap-auto-configure-mode)
  (require 'dap-go)
  (dap-go-setup))

;; =======================
;; Go Keybindings
;; =======================

(defun setup-go-keybindings ()
  "Setup comprehensive Go specific keybindings matching your style."
  (my-local-leader-def
    :keymaps 'local
    
    ;; === Build & Run ===
    "cc" 'compile                        ; Compile project
    "cr" 'recompile                      ; Recompile
    "cb" 'go-build                       ; Build current package
    "cB" 'go-build-project               ; Build entire project
    "cx" 'go-run                         ; Run current file
    "cX" 'go-run-main                    ; Run main package
    
    ;; === Testing ===
    "tt" 'go-test-current-test           ; Test at point
    "tf" 'go-test-current-file           ; Test current file
    "tp" 'go-test-current-project        ; Test project
    "ta" 'go-test-all                    ; Test all
    "tT" 'go-test-current-test-cache     ; Test at point (cached)
    "tF" 'go-test-current-file-cache     ; Test file (cached)
    "tb" 'go-test-current-benchmark      ; Run benchmark at point
    "tc" 'go-test-coverage               ; Test with coverage
    "tg" 'go-gen-test-dwim               ; Generate test for function
    "tG" 'go-gen-test-all                ; Generate all tests
    
    ;; === Navigation & Finding (LSP) ===
    "gd" 'lsp-find-definition            ; Go to definition
    "gD" 'lsp-find-definition-other-window ; Definition other window
    "gr" 'lsp-find-references            ; Find references
    "gi" 'lsp-find-implementation        ; Find implementation
    "gt" 'lsp-find-type-definition       ; Find type definition
    "gb" 'xref-pop-marker-stack          ; Go back
    "gn" 'lsp-ui-find-next-reference     ; Next reference
    "gp" 'lsp-ui-find-prev-reference     ; Previous reference
    "gs" 'consult-lsp-symbols            ; Search symbols
    "gS" 'consult-lsp-file-symbols       ; Search file symbols
    "ge" 'lsp-treemacs-errors-list       ; Show errors
    "gc" 'lsp-treemacs-call-hierarchy    ; Call hierarchy
    "gC" 'lsp-treemacs-type-hierarchy    ; Type hierarchy
    
    ;; === Help & Documentation ===
    "hd" 'lsp-describe-thing-at-point    ; Describe at point
    "hD" 'godoc-at-point                 ; Go documentation
    "hh" 'lsp-ui-doc-show                ; Show hover doc
    "hH" 'lsp-ui-doc-glance              ; Glance documentation
    "hs" 'lsp-signature-activate         ; Show signature
    "ha" 'consult-lsp-diagnostics        ; Show all diagnostics
    "hf" 'lsp-ui-doc-focus-frame         ; Focus doc frame
    
    ;; === Code Actions & Refactoring ===
    "aa" 'lsp-execute-code-action        ; Code action
    "ar" 'lsp-rename                     ; Rename symbol
    "ao" 'lsp-organize-imports           ; Organize imports
    "af" 'lsp-format-buffer              ; Format buffer
    "aF" 'lsp-format-region              ; Format region
    "ai" 'go-import-add                  ; Add import
    "aI" 'go-remove-unused-imports       ; Remove unused imports
    "at" 'go-tag-add                     ; Add struct tags
    "aT" 'go-tag-remove                  ; Remove struct tags
    "as" 'go-fill-struct                 ; Fill struct fields
    "aS" 'lsp-ui-sideline-apply-code-actions ; Apply sideline actions
    "ae" 'go-if-err-check                ; Add error check
    "ag" 'go-goto-imports                ; Go to imports
    "am" 'go-impl                        ; Implement interface
    
    ;; === Workspace ===
    "wA" 'lsp-workspace-folders-add      ; Add workspace folder
    "wR" 'lsp-workspace-folders-remove   ; Remove workspace folder
    "wS" 'lsp-workspace-shutdown         ; Shutdown workspace
    "wr" 'lsp-workspace-restart          ; Restart workspace
    "ws" 'lsp-workspace-folders-switch   ; Switch workspace
    "wD" 'lsp-disconnect                 ; Disconnect from LSP
    
    ;; === Debugging (DAP) ===
    "dd" 'dap-debug                      ; Start debugging
    "dD" 'dap-debug-last                 ; Debug last configuration
    "db" 'dap-breakpoint-toggle          ; Toggle breakpoint
    "dB" 'dap-breakpoint-delete-all      ; Delete all breakpoints
    "dc" 'dap-continue                   ; Continue
    "dn" 'dap-next                       ; Step over
    "di" 'dap-step-in                    ; Step in
    "do" 'dap-step-out                   ; Step out
    "dr" 'dap-restart-frame              ; Restart frame
    "de" 'dap-eval                       ; Evaluate expression
    "dE" 'dap-eval-region                ; Evaluate region
    "dq" 'dap-disconnect                 ; Quit debugging
    "dl" 'dap-ui-locals                  ; Show locals
    "ds" 'dap-ui-sessions                ; Show sessions
    "dh" 'dap-hydra                      ; Debug hydra
    
    ;; === Go Playground ===
    "pp" 'go-playground                  ; Open playground
    "pr" 'go-playground-exec             ; Execute playground
    "ps" 'go-playground-download         ; Download as file
    "pu" 'go-playground-upload           ; Upload to play.golang.org
    
    ;; === Module Management ===
    "mt" 'go-mod-tidy                    ; Run go mod tidy
    "mi" 'go-mod-init                    ; Initialize module
    "md" 'go-mod-download                ; Download dependencies
    "mu" 'go-mod-upgrade                 ; Upgrade dependencies
    "mv" 'go-mod-vendor                  ; Vendor dependencies
    
    ;; === Peek (UI) ===
    "pd" 'lsp-ui-peek-find-definitions   ; Peek definitions
    "pr" 'lsp-ui-peek-find-references    ; Peek references
    "pi" 'lsp-ui-peek-find-implementation ; Peek implementation
    "ps" 'lsp-ui-peek-find-workspace-symbol ; Peek symbols
    
    ;; === Misc ===
    "=" 'gofmt                           ; Format with gofmt
    "'" 'run-go-repl                     ; Start Go REPL (gore)
    "ed" 'go-download-play               ; Download from playground
    "xx" 'lsp-treemacs-quick-fix         ; Quick fix
    "xX" 'lsp-ui-flycheck-list))         ; Flycheck error list

;; === General LSP Keybindings (for all LSP modes) ===
(defun setup-lsp-keybindings ()
  "Setup general LSP keybindings for any LSP-enabled mode."
  (my-local-leader-def
    :keymaps 'local
    ;; These will be available in all LSP modes
    "l" '(:ignore t :which-key "lsp")
    "la" 'lsp-execute-code-action
    "lf" 'lsp-format-buffer
    "lF" 'lsp-format-region
    "lr" 'lsp-rename
    "lR" 'lsp-workspace-restart
    "ls" 'consult-lsp-symbols
    "lS" 'consult-lsp-file-symbols
    "ld" 'consult-lsp-diagnostics
    "lD" 'lsp-describe-thing-at-point
    "lh" 'lsp-ui-doc-show
    "lH" 'lsp-ui-doc-glance
    "li" 'lsp-ui-imenu
    "ll" 'lsp-lens-mode
    "lL" 'lsp-lens-show
    "le" 'lsp-treemacs-errors-list))

;; Hook everything up
(add-hook 'go-mode-hook 'setup-go-keybindings)
(add-hook 'lsp-mode-hook 'setup-lsp-keybindings)

;; =======================
;; Helper Functions
;; =======================

(defun go-build ()
  "Build the current Go package."
  (interactive)
  (compile "go build -v"))

(defun go-build-project ()
  "Build the entire Go project."
  (interactive)
  (compile "go build -v ./..."))

(defun go-run ()
  "Run the current Go file."
  (interactive)
  (compile (concat "go run " (buffer-file-name))))

(defun go-run-main ()
  "Run the main package."
  (interactive)
  (compile "go run ."))

(defun go-test-all ()
  "Run all Go tests in the project."
  (interactive)
  (compile "go test -v ./..."))

(defun go-test-coverage ()
  "Run Go tests with coverage."
  (interactive)
  (compile "go test -v -coverprofile=coverage.out ./... && go tool cover -html=coverage.out"))

(defun go-mod-tidy ()
  "Run go mod tidy."
  (interactive)
  (compile "go mod tidy"))

(defun go-mod-download ()
  "Run go mod download."
  (interactive)
  (compile "go mod download"))

(defun go-mod-vendor ()
  "Run go mod vendor."
  (interactive)
  (compile "go mod vendor"))

(defun go-mod-upgrade ()
  "Upgrade all Go dependencies."
  (interactive)
  (compile "go get -u ./..."))

(defun go-if-err-check ()
  "Insert if err != nil check."
  (interactive)
  (let ((indent (current-indentation)))
    (end-of-line)
    (newline)
    (indent-to indent)
    (insert "if err != nil {")
    (newline)
    (indent-to (+ indent tab-width))
    (insert "return err")
    (newline)
    (indent-to indent)
    (insert "}")
    (forward-line -2)
    (end-of-line)))

(defun run-go-repl ()
  "Run gore (Go REPL) if available."
  (interactive)
  (if (executable-find "gore")
      (term "gore")
    (message "gore not found. Install with: go install github.com/x-motemen/gore/cmd/gore@latest")))

;; =======================
;; Additional Integrations
;; =======================

;; Company backend for Go
(use-package company-go
  :after (company go-mode)
  :config
  (add-to-list 'company-backends 'company-go))

;; Flycheck Go checkers
(use-package flycheck-golangci-lint
  :after flycheck
  :hook (go-mode . flycheck-golangci-lint-setup)
  :config
  (setq flycheck-golangci-lint-enable-all t))


;; =======================
;; LSP Consult Integration
;; =======================

;; Add consult-lsp for better LSP symbol search
(use-package consult-lsp
  :after (consult lsp-mode)
  :config
  ;; Define custom consult source for LSP symbols if needed
  (setq consult-lsp-symbols-narrow
        '((?f . "Function")
          (?v . "Variable") 
          (?c . "Class")
          (?t . "Type")
          (?m . "Module")
          (?n . "Namespace")
          (?p . "Package")
          (?s . "Struct")
          (?e . "Enum")
          (?i . "Interface")
          (?o . "Object")
          (?k . "Key")
          (?r . "Reference"))))

;; =======================
;; Theme
;; =======================

(use-package leuven-theme
  :config
  (load-theme 'leuven-dark t))

;; =======================
;; Utility Functions
;; =======================

(defun downcase-current-line ()
  "Downcase the entire current line."
  (interactive)
  (let ((start (line-beginning-position))
        (end (line-end-position)))
    (downcase-region start end)))

(defun my/resize-window (&optional arg)
  "Resize window interactively."
  (interactive "p")
  (if (one-window-p) (error "Cannot resize sole window"))
  (or arg (setq arg 1))
  (let (c)
    (catch 'done
      (while t
        (message
         "h=heighten, s=shrink, w=widen, n=narrow (by %d); 1-9=unit, q=quit"
         arg)
        (setq c (read-char))
        (condition-case ()
            (cond
             ((= c ?h) (enlarge-window arg))
             ((= c ?s) (shrink-window arg))
             ((= c ?w) (enlarge-window-horizontally arg))
             ((= c ?n) (shrink-window-horizontally arg))
             ((= c ?\^G) (keyboard-quit))
             ((= c ?q) (throw 'done t))
             ((and (> c ?0) (<= c ?9)) (setq arg (- c ?0)))
             (t (beep)))
          (error (beep)))))
    (message "Done.")))

(global-hl-line-mode 1)

;; =======================
;; Final Setup
;; =======================

;; Dired integration with Evil
(with-eval-after-load 'dired
  (evil-define-key 'normal dired-mode-map (kbd "SPC") nil))

(message "Configuration loaded successfully!")
