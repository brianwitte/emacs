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


;; =======================
;; Helm Configuration
;; =======================

(use-package helm
  :diminish helm-mode
  :init
  (setq helm-command-prefix-key "C-c h"
        helm-split-window-inside-p nil
        helm-split-window-default-side 'below
        helm-always-two-windows t
        helm-move-to-line-cycle-in-source t
        helm-ff-search-library-in-sexp t
        helm-scroll-amount 8
        helm-ff-file-name-history-use-recentf t
        helm-echo-input-in-header-line t
        helm-autoresize-max-height 30
        helm-autoresize-min-height 10
        helm-buffers-fuzzy-matching t
        helm-recentf-fuzzy-match t
        helm-locate-fuzzy-match t
        helm-M-x-fuzzy-match t
        helm-semantic-fuzzy-match t
        helm-imenu-fuzzy-match t
        helm-completion-in-region-fuzzy-match t
        helm-candidate-number-limit 150
        helm-boring-file-regexp-list
        '("\\.git$" "\\.hg$" "\\.svn$" "\\.CVS$" "\\._darcs$" "\\.la$" "\\.o$" "\\.i$")
        helm-ff-skip-boring-files t)
  
  :config
  (helm-mode 1)
  (helm-autoresize-mode 1)
  
  ;; Force all helm buffers to bottom
  (add-to-list 'display-buffer-alist
               '("\\*helm.*\\*"
                 (display-buffer-in-side-window)
                 (side . bottom)
                 (window-height . 0.3)))
  
  ;; Hide header line in helm minibuffer
  (defun helm-hide-minibuffer-maybe ()
    (when (with-helm-buffer helm-echo-input-in-header-line)
      (let ((ov (make-overlay (point-min) (point-max) nil nil t)))
        (overlay-put ov 'window (selected-window))
        (overlay-put ov 'face (let ((bg-color (face-background 'default nil)))
                                `(:background ,bg-color :foreground ,bg-color)))
        (setq-local cursor-type nil))))
  (add-hook 'helm-minibuffer-set-up-hook 'helm-hide-minibuffer-maybe)
  
  ;; Better helm-find-files navigation
  (define-key helm-find-files-map (kbd "C-h") 'helm-find-files-up-one-level)
  (define-key helm-find-files-map (kbd "C-l") 'helm-execute-persistent-action))

(use-package helm-projectile
  :after (helm projectile)
  :config
  (helm-projectile-on))

(use-package helm-ag
  :after helm
  :config
  (setq helm-ag-base-command "ag --nocolor --nogroup --ignore-case"
        helm-ag-command-option "--all-text"
        helm-ag-insert-at-point 'symbol
        helm-ag-fuzzy-match t))

(use-package helm-swoop
  :after helm
  :config
  (setq helm-multi-swoop-edit-save t
        helm-swoop-split-with-multiple-windows nil
        helm-swoop-split-direction 'split-window-vertically
        helm-swoop-speed-or-color nil
        helm-swoop-move-to-line-cycle t
        helm-swoop-use-line-number-face t
        helm-swoop-use-fuzzy-match t))


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
  (evil-set-initial-state 'dashboard-mode 'normal)
  (evil-set-initial-state 'helm-major-mode 'emacs))

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
    ":" 'helm-M-x
    "SPC" 'helm-projectile-find-file
    "." 'embark-act
    "," 'helm-buffers-list

    ;; Files
    "ff" 'helm-find-files
    "fs" 'save-buffer
    "fr" 'helm-recentf

    ;; Buffers
    "bb" 'helm-buffers-list
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
    "pp" 'helm-projectile-switch-project
    "pb" 'helm-projectile-switch-to-buffer
    "pc" 'projectile-compile-project
    "pk" 'projectile-kill-buffers
    "pd" 'projectile-dired
    "pr" 'projectile-replace
    "pf" 'helm-projectile-find-file
    "pg" 'helm-projectile-grep

    ;; VTERM
    "ot" 'vterm

    ;; Search & Navigation
    "ss" 'helm-swoop
    "sS" 'helm-multi-swoop-all
    "sp" 'helm-multi-swoop-current-mode
    "sf" 'helm-find
    "sg" 'helm-ag
    "sG" 'helm-ag-project-root
    "sl" 'helm-locate
    "sm" 'helm-all-mark-rings
    "sr" 'helm-resume
    "so" 'helm-occur
    "si" 'helm-imenu
    "sI" 'helm-imenu-in-all-buffers

    ;; Tools
    "op" 'treemacs
    "dl" 'downcase-current-line

    ;; Helm specific
    "hh" 'helm-help
    "hm" 'helm-man-woman
    "hc" 'helm-colors
    "hf" 'helm-apropos
    "hy" 'helm-show-kill-ring
    "hx" 'helm-register
    "hz" 'helm-complex-command-history))

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

(use-package consult)

(use-package projectile
  :diminish projectile-mode
  :config
  (projectile-mode +1)
  (setq projectile-completion-system 'helm
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
;; C/C++ Development
;; =======================

;; LSP Mode for C/C++
(use-package lsp-mode
  :hook ((c-mode c++-mode) . lsp-deferred)
  :commands (lsp lsp-deferred)
  :config
  (setq lsp-idle-delay 0.1              ; clangd is fast
        lsp-completion-provider :capf
        lsp-headerline-breadcrumb-enable t
        lsp-modeline-code-actions-enable t
        lsp-modeline-diagnostics-enable t
        lsp-signature-auto-activate nil)  ; Use eldoc instead
  
  ;; Performance optimizations
  (setq read-process-output-max (* 1024 1024)
        lsp-log-io nil
        lsp-keep-workspace-alive nil)
  
  ;; Integration with which-key
  (with-eval-after-load 'which-key
    (lsp-enable-which-key-integration)))

;; LSP UI enhancements
(use-package lsp-treemacs
  :after (lsp-mode treemacs)
  :commands lsp-treemacs-errors-list
  :config
  (lsp-treemacs-sync-mode 1))

;; LSP Helm integration
(use-package helm-lsp
  :after (lsp-mode helm)
  :commands helm-lsp-workspace-symbol)

;; Debug Adapter Protocol
(use-package dap-mode
  :after lsp-mode
  :config
  (dap-auto-configure-mode)
  (require 'dap-cpptools)
  
  ;; Default debug configuration template
  (dap-register-debug-template
   "C/C++ Debug"
   (list :type "cppdbg"
         :request "launch"
         :name "Debug"
         :program (expand-file-name "a.out" (projectile-project-root))
         :args []
         :stopAtEntry :json-false
         :cwd (projectile-project-root)
         :environment []
         :externalConsole :json-false
         :MIMode "gdb")))

;; C/C++ specific keybindings
(defun setup-c-cpp-keybindings ()
  "Setup C/C++ development keybindings."
  (my-local-leader-def
    :keymaps 'local
    
    ;; LSP Navigation
    "gd" 'lsp-find-definition
    "gD" 'lsp-find-declaration  
    "gr" 'lsp-find-references
    "gi" 'lsp-find-implementation
    "gt" 'lsp-find-type-definition
    "gb" 'xref-pop-marker-stack
    "gh" 'lsp-describe-thing-at-point
    
    ;; LSP Actions
    "aa" 'lsp-execute-code-action
    "ar" 'lsp-rename
    "af" 'lsp-format-buffer
    "aF" 'lsp-format-region
    "ai" 'lsp-organize-imports
    
    ;; LSP Workspace
    "wr" 'lsp-workspace-restart
    "ws" 'lsp-workspace-shutdown
    "wf" 'lsp-workspace-folders-add
    "wF" 'lsp-workspace-folders-remove
    "wb" 'lsp-workspace-blacklist-remove
    
    ;; Documentation & Help
    "hh" 'lsp-describe-thing-at-point
    "hs" 'lsp-signature-activate
    "hi" 'lsp-ui-imenu
    
    ;; Symbol Search
    "ss" 'helm-lsp-workspace-symbol
    "sS" 'helm-lsp-global-workspace-symbol
    "si" 'lsp-ui-imenu
    
    ;; Diagnostics & Errors
    "el" 'lsp-treemacs-errors-list
    "en" 'flycheck-next-error
    "ep" 'flycheck-previous-error
    "ec" 'flycheck-clear
    "ev" 'flycheck-verify-setup
    
    ;; Debugging
    "dd" 'dap-debug
    "db" 'dap-breakpoint-toggle
    "dB" 'dap-breakpoint-delete-all
    "dc" 'dap-continue
    "dn" 'dap-next
    "ds" 'dap-step-in
    "do" 'dap-step-out
    "dr" 'dap-restart
    "dq" 'dap-disconnect
    "du" 'dap-ui-mode
    "dl" 'dap-ui-locals
    "dt" 'dap-ui-sessions
    "dw" 'dap-ui-expressions-add
    
    ;; Compilation
    "cc" 'compile
    "cr" 'recompile
    "ck" 'kill-compilation
    "cp" 'projectile-compile-project
    "ct" 'projectile-test-project
    
    ;; Code Generation & Snippets
    "iy" 'yas-insert-snippet
    "in" 'yas-new-snippet
    "iv" 'yas-visit-snippet-file))

;; Apply keybindings to C/C++ modes
(add-hook 'c-mode-hook 'setup-c-cpp-keybindings)
(add-hook 'c++-mode-hook 'setup-c-cpp-keybindings)

;; C/C++ mode configuration
(use-package cc-mode
  :ensure nil  ; Built-in package
  :config
  ;; Style configuration
  (setq c-default-style '((java-mode . "java")
                          (awk-mode . "awk")
                          (other . "linux"))
        c-basic-offset 4
        c-tab-always-indent t)
  
  ;; Auto-completion for headers
  (setq c-electric-flag t
        c-auto-newline nil
        c-hungry-delete-key t))

;; Modern C++ font-lock
(use-package modern-cpp-font-lock
  :diminish modern-c++-font-lock-mode
  :hook (c++-mode . modern-c++-font-lock-mode))

;; CMake support  
(use-package cmake-mode
  :mode (("\\.cmake\\'" . cmake-mode)
         ("CMakeLists\\.txt\\'" . cmake-mode)))

;; Add to global leader bindings for quick access
(my-leader-def
  ;; Quick C/C++ actions (extends existing bindings)
  "cd" 'dap-debug
  "cb" 'dap-breakpoint-toggle
  "cl" 'lsp-treemacs-errors-list)

;; =======================
;; Clojure Setup - 20 Essential Keybindings
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
;; Common Lisp Setup
;; =======================

;; Common Lisp with SLIME
(use-package slime
  :config
  (setq inferior-lisp-program "sbcl") ; or your preferred Lisp implementation
  (setq slime-contribs '(slime-fancy))
  
  (defun setup-common-lisp-keybindings ()
    "Setup comprehensive Common Lisp/SLIME specific keybindings."
    (my-local-leader-def
      :keymaps 'local
      ;; REPL Connection & Management
      "'" 'slime
      "rq" 'slime-quit-lisp
      "rr" 'slime-restart-inferior-lisp
      "rb" 'slime-switch-to-output-buffer
      "rB" 'slime-repl-clear-buffer
      "rn" 'slime-repl-set-package
      "rc" 'slime-repl-clear-output
      "rl" 'slime-load-file-set-package
      "rp" 'slime-pprint-eval-last-expression
      "rP" 'slime-pprint-eval-region

      ;; Evaluation
      "eb" 'slime-eval-buffer
      "ed" 'slime-eval-defun
      "ee" 'slime-eval-last-expression
      "er" 'slime-eval-region
      "eE" 'slime-interactive-eval
      "el" 'slime-eval-load-file
      "ef" 'slime-load-file
      "ep" 'slime-pprint-eval-last-expression
      "eP" 'slime-pprint-eval-region
      "em" 'slime-macroexpand-1
      "eM" 'slime-macroexpand-all
      "ex" 'slime-expand-1

      ;; Compilation
      "cb" 'slime-compile-file
      "cc" 'slime-compile-defun
      "cr" 'slime-compile-region
      "cl" 'slime-load-file
      "cL" 'slime-compile-and-load-file

      ;; Navigation & Finding
      "gd" 'slime-edit-definition
      "gD" 'slime-edit-definition-other-window
      "gb" 'slime-pop-find-definition-stack
      "gn" 'slime-next-note
      "gN" 'slime-previous-note
      "gc" 'slime-list-callers
      "gC" 'slime-list-callees
      "gr" 'slime-who-references
      "gw" 'slime-who-calls
      "gs" 'slime-who-sets
      "gb" 'slime-who-binds
      "gm" 'slime-who-macroexpands
      "gu" 'slime-disassemble-symbol

      ;; Help & Documentation
      "hd" 'slime-describe-symbol
      "hf" 'slime-describe-function
      "ha" 'slime-apropos
      "hA" 'slime-apropos-all
      "hp" 'slime-apropos-package
      "hH" 'slime-hyperspec-lookup
      "h~" 'common-lisp-hyperspec

      ;; Testing
      "tt" 'slime-toggle-trace-fdefinition
      "tT" 'slime-untrace-all
      "tf" 'slime-toggle-fancy-trace

      ;; Debugging
      "db" 'slime-toggle-break-on-signals
      "dc" 'slime-debug-continue
      "da" 'slime-debug-abort
      "dq" 'slime-debug-quit
      "dr" 'slime-debug-restart
      "ds" 'slime-debug-step
      "dd" 'slime-debug-details
      "di" 'slime-inspect
      "dI" 'slime-inspect-definition

      ;; Profiling
      "pb" 'slime-profile-by-substring
      "pf" 'slime-profile-functions
      "pp" 'slime-profile-package
      "pr" 'slime-profile-report
      "pR" 'slime-profile-reset
      "pu" 'slime-unprofile-all

      ;; Packages
      "pd" 'slime-describe-package
      "ps" 'slime-set-package
      "pf" 'slime-find-package

      ;; Xref
      "xc" 'slime-list-callers
      "xC" 'slime-list-callees
      "xr" 'slime-who-references
      "xb" 'slime-who-binds
      "xs" 'slime-who-sets
      "xm" 'slime-who-macroexpands

      ;; Inspector
      "id" 'slime-inspect-definition
      "ii" 'slime-inspect
      "in" 'slime-inspector-next
      "ip" 'slime-inspector-previous
      "iq" 'slime-inspector-quit
      "ir" 'slime-inspector-reinspect
      "iw" 'slime-inspector-copy-down

      ;; Scratch/Notes
      "ns" 'slime-scratch
      "nS" 'slime-scratch-buffer

      ;; System interaction
      "sy" 'slime-sync-package-and-default-directory
      "sp" 'slime-set-default-directory

      ;; Miscellaneous
      "mb" 'slime-macroexpand-1
      "mB" 'slime-macroexpand-all
      "mi" 'slime-inspect-definition
      "mI" 'slime-inspect
      "mc" 'slime-calls-who
      "mv" 'slime-toggle-trace-fdefinition))

  (add-hook 'lisp-mode-hook 'setup-lisp-sexp-keybindings)
  (add-hook 'lisp-mode-hook 'setup-common-lisp-keybindings)
  (add-hook 'slime-mode-hook 'setup-common-lisp-keybindings))

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
;; Lua Development
;; =======================

;; Lua mode
(use-package lua-mode
  :mode "\\.lua\\'"
  :config
  (setq lua-indent-level 2
        lua-indent-string-contents t
        lua-prefix-key nil))  ; We'll use our own keybindings

;; LSP support for Lua
(use-package lsp-mode
  :hook (lua-mode . lsp-deferred)
  :config
  ;; Configure lua-language-server settings
  (lsp-register-custom-settings
   '(("Lua.telemetry.enable" nil t)
     ("Lua.completion.enable" t t)
     ("Lua.completion.callSnippet" "Both" t)
     ("Lua.completion.keywordSnippet" "Both" t)
     ("Lua.diagnostics.globals" ["vim" "awesome" "client" "root" "screen"] t)
     ("Lua.workspace.checkThirdParty" nil t))))

;; Company backend for Lua
(use-package company-lua
  :after (company lua-mode)
  :config
  (add-to-list 'company-backends 'company-lua))

;; Lua REPL integration
(use-package lua-mode
  :config
  (defun lua-send-current-line ()
    "Send current line to Lua REPL."
    (interactive)
    (lua-send-region (line-beginning-position) (line-end-position)))
  
  (defun lua-send-buffer ()
    "Send entire buffer to Lua REPL."
    (interactive)
    (lua-send-region (point-min) (point-max)))
  
  (defun lua-send-defun ()
    "Send current function to Lua REPL."
    (interactive)
    (save-excursion
      (lua-beginning-of-proc)
      (let ((start (point)))
        (lua-end-of-proc)
        (lua-send-region start (point))))))

;; Lua-specific keybindings
(defun setup-lua-keybindings ()
  "Setup Lua development keybindings."
  (my-local-leader-def
    :keymaps 'local
    
    ;; LSP Navigation
    "gd" 'lsp-find-definition
    "gD" 'lsp-find-declaration  
    "gr" 'lsp-find-references
    "gi" 'lsp-find-implementation
    "gt" 'lsp-find-type-definition
    "gb" 'xref-pop-marker-stack
    "gh" 'lsp-describe-thing-at-point
    
    ;; LSP Actions
    "aa" 'lsp-execute-code-action
    "ar" 'lsp-rename
    "af" 'lsp-format-buffer
    "aF" 'lsp-format-region
    "ai" 'lsp-organize-imports
    
    ;; LSP Workspace
    "wr" 'lsp-workspace-restart
    "ws" 'lsp-workspace-shutdown
    "wf" 'lsp-workspace-folders-add
    "wF" 'lsp-workspace-folders-remove
    
    ;; Documentation & Help
    "hh" 'lsp-describe-thing-at-point
    "hs" 'lsp-signature-activate
    "hi" 'lsp-ui-imenu
    "hd" 'lua-search-documentation
    
    ;; Symbol Search
    "ss" 'helm-lsp-workspace-symbol
    "sS" 'helm-lsp-global-workspace-symbol
    "si" 'lsp-ui-imenu
    
    ;; Diagnostics & Errors
    "el" 'lsp-treemacs-errors-list
    "en" 'flycheck-next-error
    "ep" 'flycheck-previous-error
    "ec" 'flycheck-clear
    "ev" 'flycheck-verify-setup
    
    ;; REPL & Evaluation
    "'" 'lua-show-process-buffer
    "sb" 'lua-send-buffer
    "sd" 'lua-send-defun
    "sl" 'lua-send-current-line
    "sr" 'lua-send-region
    "si" 'lua-start-process
    "sq" 'lua-kill-process
    "ss" 'lua-restart-with-whole-file
    
    ;; Code Navigation
    "gf" 'lua-forward-sexp
    "gb" 'lua-backward-sexp
    "gn" 'lua-next-func-name
    "gp" 'lua-prev-func-name
    "ga" 'lua-beginning-of-proc
    "ge" 'lua-end-of-proc
    
    ;; Compilation & Syntax Check
    "cc" 'lua-send-buffer
    "cf" 'lua-send-current-line
    "cs" 'lua-check-syntax
    
    ;; Code Generation & Snippets
    "iy" 'yas-insert-snippet
    "in" 'yas-new-snippet
    "iv" 'yas-visit-snippet-file
    
    ;; Indentation & Formatting
    "=l" 'lua-indent-line
    "=r" 'indent-region
    "=b" 'lsp-format-buffer
    "fb" 'lsp-format-buffer
    "fr" 'lsp-format-region))

;; Apply keybindings to Lua mode
(add-hook 'lua-mode-hook 'setup-lua-keybindings)

;; Enhanced Lua development setup
(add-hook 'lua-mode-hook
          (lambda ()
            ;; Enable eldoc for function signatures
            (eldoc-mode 1)
            ;; Set up indentation
            (setq-local tab-width lua-indent-level)
            (setq-local indent-tabs-mode nil)
            ;; Enable auto-pairing
            (electric-pair-local-mode 1)))

;; Lua syntax checking with flycheck
(use-package flycheck
  :config
  (flycheck-define-checker lua-luacheck
    "A Lua syntax checker using luacheck."
    :command ("luacheck" "--formatter" "plain" "--codes" source)
    :error-patterns
    ((warning line-start (file-name) ":" line ":" column ": " (message) line-end))
    :modes lua-mode)
  
  (add-to-list 'flycheck-checkers 'lua-luacheck))

;; Love2D game development support
(use-package love-minor-mode
  :hook (lua-mode . love-minor-mode)
  :config
  (defun setup-love2d-keybindings ()
    "Additional keybindings for Love2D development."
    (when love-minor-mode
      (my-local-leader-def
        :keymaps 'local
        ;; Love2D specific commands
        "lr" 'love-start
        "lq" 'love-stop
        "ll" 'love-reload
        "lf" 'love-run-file)))
  
  (add-hook 'love-minor-mode-hook 'setup-love2d-keybindings))

;; Add to global leader bindings for quick access
(my-leader-def
  ;; Quick Lua actions (extends existing bindings)
  "lr" 'lua-send-region
  "lb" 'lua-send-buffer
  "li" 'lua-start-process)

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
(set-face-background 'hl-line "#228B22")  ; Forest green


;; =======================
;; Final Setup
;; =======================

;; Dired integration with Evil
(with-eval-after-load 'dired
  (evil-define-key 'normal dired-mode-map (kbd "SPC") nil))

;; Ensure helm works well with evil
(with-eval-after-load 'helm
  (define-key helm-map (kbd "C-j") 'helm-next-line)
  (define-key helm-map (kbd "C-k") 'helm-previous-line)
  (define-key helm-map (kbd "C-h") 'helm-next-source)
  (define-key helm-map (kbd "C-l") 'helm-previous-source))

(message "Configuration loaded successfully!")
