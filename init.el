;;; init.el --- Clean and minimal Emacs configuration -*- lexical-binding: t -*-
;;; Commentary:
;; A minimal, cohesive Emacs configuration with Evil, Vertico, and LSP support

;;; Code:

;; ============================================================================
;; Package Management - straight.el
;; ============================================================================

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

;; ============================================================================
;; Core Settings
;; ============================================================================

;; Performance
(setq gc-cons-threshold 50000000
      large-file-warning-threshold 100000000
      read-process-output-max (* 1024 1024))

;; UI
(setq inhibit-startup-screen t
      use-short-answers t
      ring-bell-function 'ignore)

(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))

;; Editing
(setq-default indent-tabs-mode nil
              tab-width 4
              fill-column 80)

;; Files
(setq backup-directory-alist '(("." . "~/.config/emacs/backups"))
      backup-by-copying t
      delete-old-versions t
      kept-new-versions 6
      kept-old-versions 2
      version-control t
      auto-save-default nil)

;; Built-in modes
(electric-pair-mode 1)
(show-paren-mode 1)
(global-hl-line-mode 1)
(recentf-mode 1)
(savehist-mode 1)
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; Minibuffer
(setq enable-recursive-minibuffers t
      minibuffer-prompt-properties
      '(read-only t cursor-intangible t face minibuffer-prompt))
(add-hook 'minibuffer-setup-hook 'cursor-intangible-mode)

;; ============================================================================
;; Evil Mode
;; ============================================================================

(use-package evil
  :demand t
  :init
  (setq evil-want-keybinding nil
        evil-want-integration t
        evil-want-C-u-scroll t
        evil-want-C-i-jump nil
        evil-undo-system 'undo-redo
        evil-respect-visual-line-mode t)
  :config
  (evil-mode 1)

  ;; Visual line navigation
  (evil-global-set-key 'motion "j" 'evil-next-visual-line)
  (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

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
  :after evil)

;; ============================================================================
;; General - Keybinding Framework
;; ============================================================================

(use-package general
  :demand t
  :config
  ;; Global leader (SPC in normal/visual, C-SPC everywhere)
  (general-create-definer my-leader
    :states '(normal visual insert emacs)
    :keymaps 'override
    :prefix "SPC"
    :global-prefix "C-SPC")

  ;; Local leader (comma in normal/visual)
  (general-create-definer my-local-leader
    :states '(normal visual)
    :prefix ","
    :non-normal-prefix "C-,")

  ;; Global leader bindings
  (my-leader
    ;; Core
    "SPC" 'project-find-file
    ":" 'execute-extended-command
    "." 'find-file
    "," 'consult-buffer

    ;; Files
    "f" '(:ignore t :wk "files")
    "ff" 'find-file
    "fr" 'consult-recent-file
    "fs" 'save-buffer
    "fS" 'write-file

    ;; Buffers
    "b" '(:ignore t :wk "buffers")
    "bb" 'consult-buffer
    "bd" 'kill-buffer
    "bi" 'ibuffer
    "bn" 'next-buffer
    "bp" 'previous-buffer
    "bR" 'revert-buffer

    ;; Windows
    "w" '(:ignore t :wk "windows")
    "ws" 'split-window-below
    "wv" 'split-window-right
    "wh" 'evil-window-left
    "wj" 'evil-window-down
    "wk" 'evil-window-up
    "wl" 'evil-window-right
    "wd" 'delete-window
    "wD" 'kill-buffer-and-window
    "wm" 'delete-other-windows

    ;; Projects
    "p" '(:ignore t :wk "project")
    "pp" 'projectile-switch-project
    "pf" 'project-find-file
    "pb" 'consult-project-buffer
    "pg" 'consult-ripgrep
    "pc" 'projectile-compile-project
    "pk" 'projectile-kill-buffers
    "pd" 'projectile-dired

    ;; Search
    "s" '(:ignore t :wk "search")
    "ss" 'consult-line
    "sS" 'consult-line-multi
    "sp" 'consult-ripgrep
    "sf" 'consult-find
    "sg" 'consult-grep
    "si" 'consult-imenu
    "sI" 'consult-imenu-multi
    "so" 'consult-outline
    "sm" 'consult-mark
    "sR" 'consult-resume

    ;; Open/Toggle
    "o" '(:ignore t :wk "open")
    "ot" 'multi-vterm
    "op" 'treemacs

    ;; Help
    "h" '(:ignore t :wk "help")
    "hf" 'describe-function
    "hv" 'describe-variable
    "hk" 'describe-key
    "hm" 'describe-mode
    "hp" 'describe-package))

;; ============================================================================
;; System Integration
;; ============================================================================

(use-package exec-path-from-shell
  :config
  (when (or (daemonp) (memq window-system '(mac ns x)))
    (exec-path-from-shell-initialize)))

(use-package xclip
  :config
  (xclip-mode 1))

(use-package vterm
  :defer t)

(use-package multi-vterm
  :defer t)

;; ============================================================================
;; Completion Framework
;; ============================================================================

(use-package vertico
  :init
  (vertico-mode)
  :custom
  (vertico-count 20)
  (vertico-cycle t))

(use-package orderless
  :custom
  (completion-styles '(orderless basic))
  (completion-category-defaults nil)
  (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia
  :init
  (marginalia-mode))

(use-package consult
  :bind (("C-x b" . consult-buffer)
         ("M-y" . consult-yank-pop)
         ("M-g g" . consult-goto-line)
         ("M-g i" . consult-imenu)
         ("M-s l" . consult-line))
  :config
  (setq consult-project-function (lambda (_) (projectile-project-root))))

(use-package embark
  :bind (("C-." . embark-act)
         ("C-;" . embark-dwim)
         ("C-h B" . embark-bindings))
  :init
  (setq prefix-help-command #'embark-prefix-help-command))

(use-package embark-consult
  :after (embark consult)
  :hook (embark-collect-mode . consult-preview-at-point-mode))

;; ============================================================================
;; Navigation
;; ============================================================================

(use-package avy
  :general
  (general-define-key
   :states '(normal motion)
   "s" 'evil-avy-goto-char-timer
   "f" 'evil-avy-goto-char-in-line
   "gl" 'evil-avy-goto-line
   ";" 'avy-resume)
  :config
  (setq avy-all-windows nil
        avy-background t))

(use-package projectile
  :init
  (projectile-mode +1)
  :custom
  (projectile-completion-system 'default)
  (projectile-enable-caching t)
  (projectile-project-root-files '("compile_commands.json" "Makefile" "CMakeLists.txt" ".git")))

(use-package treemacs
  :defer t)

;; ============================================================================
;; Development Tools
;; ============================================================================

(use-package company
  :hook (after-init . global-company-mode)
  :custom
  (company-idle-delay 0.3)
  (company-minimum-prefix-length 2)
  (company-selection-wrap-around t)
  (company-tooltip-align-annotations t)
  (company-show-numbers t))

(use-package company-box
  :hook (company-mode . company-box-mode))

(use-package flycheck
  :hook (after-init . global-flycheck-mode)
  :custom
  (flycheck-check-syntax-automatically '(save mode-enabled))
  (flycheck-display-errors-delay 0.3))

(use-package lsp-mode
  :commands (lsp lsp-deferred)
  :hook ((c-mode . lsp-deferred)
         (c++-mode . lsp-deferred)
         (rustic-mode . lsp-deferred)
         (lsp-mode . lsp-enable-which-key-integration))
  :custom
  (lsp-keymap-prefix "C-c l")
  (lsp-idle-delay 0.500)
  (lsp-log-io nil)
  (lsp-completion-provider :capf)
  (lsp-headerline-breadcrumb-enable t)
  (lsp-modeline-diagnostics-enable t)
  (lsp-signature-auto-activate t)
  ;; Clangd settings
  (lsp-clients-clangd-args
   '("--header-insertion=never"
     "--clang-tidy"
     "--completion-style=detailed"
     "--suggest-missing-includes"
     "--cross-file-rename")))

(use-package lsp-ui
  :after lsp-mode
  :custom
  (lsp-ui-doc-enable t)
  (lsp-ui-doc-position 'at-point)
  (lsp-ui-doc-delay 0.5)
  (lsp-ui-sideline-enable t)
  (lsp-ui-sideline-show-diagnostics t)
  (lsp-ui-peek-enable t))

(use-package dap-mode
  :after lsp-mode
  :config
  (dap-mode 1)
  (dap-ui-mode 1)
  (dap-tooltip-mode 1)
  (require 'dap-gdb-lldb)
  (dap-gdb-lldb-setup))

;; ============================================================================
;; Language: Emacs Lisp
;; ============================================================================

(use-package emacs
  :straight nil
  :general
  (my-local-leader
    :keymaps 'emacs-lisp-mode-map
    "'" 'ielm

    ;; Eval
    "e" '(:ignore t :wk "eval")
    "eb" 'eval-buffer
    "ed" 'eval-defun
    "ee" 'eval-last-sexp
    "er" 'eval-region
    "eE" 'eval-expression
    "el" 'load-library

    ;; Goto
    "g" '(:ignore t :wk "goto")
    "gf" 'find-function
    "gv" 'find-variable
    "gl" 'find-library
    "gb" 'xref-pop-marker-stack

    ;; Help
    "h" '(:ignore t :wk "help")
    "hf" 'describe-function
    "hv" 'describe-variable
    "hk" 'describe-key
    "hm" 'describe-mode

    ;; Debug
    "d" '(:ignore t :wk "debug")
    "dd" 'edebug-defun
    "db" 'edebug-set-breakpoint
    "dB" 'edebug-unset-breakpoint

    ;; Macro
    "m" '(:ignore t :wk "macro")
    "me" 'macroexpand
    "mE" 'macroexpand-all
    "m1" 'macroexpand-1

    ;; Compile
    "c" '(:ignore t :wk "compile")
    "cc" 'compile
    "cb" 'byte-compile-file
    "cB" 'byte-recompile-directory))

;; ============================================================================
;; Language: Clojure
;; ============================================================================

(use-package clojure-mode
  :defer t)

(use-package cider
  :after clojure-mode
  :general
  (my-local-leader
    :keymaps 'clojure-mode-map
    "'" 'cider-jack-in

    ;; Eval
    "e" '(:ignore t :wk "eval")
    "eb" 'cider-eval-buffer
    "ed" 'cider-eval-defun-at-point
    "ee" 'cider-eval-last-sexp
    "er" 'cider-eval-region
    "ep" 'cider-pprint-eval-last-sexp

    ;; Goto
    "g" '(:ignore t :wk "goto")
    "gd" 'cider-find-var
    "gb" 'cider-pop-back
    "gr" 'cider-find-references-at-point

    ;; Help
    "h" '(:ignore t :wk "help")
    "hd" 'cider-doc
    "ha" 'cider-apropos
    "hj" 'cider-javadoc

    ;; REPL
    "r" '(:ignore t :wk "repl")
    "rr" 'cider-restart
    "rq" 'cider-quit
    "rB" 'cider-repl-clear-buffer

    ;; Test
    "t" '(:ignore t :wk "test")
    "tt" 'cider-test-run-test
    "ta" 'cider-test-run-all-tests))

;; ============================================================================
;; Language: Fennel
;; ============================================================================

(use-package fennel-mode
  :mode "\\.fnl\\'"
  :general
  (my-local-leader
    :keymaps 'fennel-mode-map
    "'" 'fennel-repl

    ;; Eval
    "e" '(:ignore t :wk "eval")
    "eb" 'fennel-eval-buffer
    "ee" 'fennel-eval-last-sexp
    "er" 'fennel-eval-region
    "el" 'fennel-load-file

    ;; Compile
    "c" '(:ignore t :wk "compile")
    "cb" 'fennel-compile-buffer
    "cf" 'fennel-compile-file

    ;; Goto
    "g" '(:ignore t :wk "goto")
    "gd" 'fennel-find-definition
    "gb" 'xref-pop-marker-stack

    ;; Help
    "h" '(:ignore t :wk "help")
    "hd" 'fennel-describe-symbol
    "ha" 'fennel-apropos

    ;; Macro
    "m" '(:ignore t :wk "macro")
    "mb" 'fennel-macroexpand-1
    "mM" 'fennel-macroexpand-all))

;; ============================================================================
;; Language: C/C++
;; ============================================================================

(use-package cc-mode
  :straight nil
  :mode (("\\.c\\'" . c-mode)
         ("\\.h\\'" . c-mode)
         ("\\.cpp\\'" . c++-mode)
         ("\\.hpp\\'" . c++-mode))
  :general
  (my-local-leader
    :keymaps '(c-mode-map c++-mode-map)

    ;; Goto
    "g" '(:ignore t :wk "goto")
    "gd" 'lsp-find-definition
    "gD" 'lsp-find-declaration
    "gi" 'lsp-find-implementation
    "gt" 'lsp-find-type-definition
    "gr" 'lsp-find-references
    "gb" 'xref-pop-marker-stack
    "gp" 'lsp-ui-peek-find-definitions
    "gP" 'lsp-ui-peek-find-references

    ;; Help
    "h" '(:ignore t :wk "help")
    "hh" 'lsp-describe-thing-at-point
    "hd" 'lsp-ui-doc-show
    "hs" 'lsp-signature-activate

    ;; Refactor
    "r" '(:ignore t :wk "refactor")
    "rr" 'lsp-rename
    "ra" 'lsp-execute-code-action
    "rf" 'lsp-format-buffer
    "rF" 'lsp-format-region

    ;; Workspace
    "w" '(:ignore t :wk "workspace")
    "wr" 'lsp-workspace-restart
    "ws" 'lsp-workspace-shutdown

    ;; Errors
    "e" '(:ignore t :wk "errors")
    "el" 'lsp-ui-flycheck-list
    "en" 'flycheck-next-error
    "ep" 'flycheck-previous-error
    "ee" 'flycheck-list-errors

    ;; Debug
    "d" '(:ignore t :wk "debug")
    "dd" 'dap-debug
    "db" 'dap-breakpoint-toggle
    "dB" 'dap-breakpoint-delete-all
    "dc" 'dap-continue
    "dn" 'dap-next
    "di" 'dap-step-in
    "do" 'dap-step-out
    "dr" 'dap-debug-restart
    "dq" 'dap-disconnect

    ;; Compile
    "c" '(:ignore t :wk "compile")
    "cc" 'compile
    "cr" 'recompile
    "ck" 'kill-compilation)

  :config
  (setq c-default-style '((java-mode . "java")
                          (awk-mode . "awk")
                          (other . "k&r"))
        c-basic-offset 4))

(use-package cmake-mode
  :mode (("CMakeLists\\.txt\\'" . cmake-mode)
         ("\\.cmake\\'" . cmake-mode)))

(use-package ccls
  :defer t
  :custom
  (ccls-executable "ccls")
  (ccls-sem-highlight-method 'font-lock))

(use-package modern-cpp-font-lock
  :hook (c++-mode . modern-c++-font-lock-mode))

;; ============================================================================
;; Language: Rust
;; ============================================================================

(use-package rustic
  :mode ("\\.rs\\'" . rustic-mode)
  :general
  (my-local-leader
    :keymaps 'rustic-mode-map
    "'" 'rustic-repl

    ;; Goto
    "g" '(:ignore t :wk "goto")
    "gd" 'lsp-find-definition
    "gD" 'lsp-find-declaration
    "gi" 'lsp-find-implementation
    "gt" 'lsp-find-type-definition
    "gr" 'lsp-find-references
    "gb" 'xref-pop-marker-stack

    ;; Help
    "h" '(:ignore t :wk "help")
    "hh" 'lsp-describe-thing-at-point
    "hd" 'lsp-ui-doc-show

    ;; Refactor
    "r" '(:ignore t :wk "refactor")
    "rr" 'lsp-rename
    "ra" 'lsp-execute-code-action
    "rf" 'rustic-format-buffer

    ;; Cargo
    "c" '(:ignore t :wk "cargo")
    "cc" 'rustic-cargo-build
    "cC" 'rustic-cargo-clean
    "ck" 'rustic-cargo-check
    "cr" 'rustic-cargo-run
    "ct" 'rustic-cargo-test
    "cd" 'rustic-cargo-doc
    "cf" 'rustic-cargo-fmt
    "cl" 'rustic-cargo-clippy

    ;; Test
    "t" '(:ignore t :wk "test")
    "tt" 'rustic-cargo-test
    "ta" 'rustic-cargo-test-all
    "tc" 'rustic-cargo-current-test

    ;; Debug
    "d" '(:ignore t :wk "debug")
    "dd" 'dap-debug
    "db" 'dap-breakpoint-toggle
    "dc" 'dap-continue
    "dn" 'dap-next
    "di" 'dap-step-in
    "do" 'dap-step-out

    ;; Macro
    "m" '(:ignore t :wk "macro")
    "mm" 'rustic-macro-expand
    "mM" 'rustic-macro-expand-all)

  :custom
  (rustic-format-on-save nil)
  (rustic-lsp-client 'lsp-mode)
  (rustic-lsp-server 'rust-analyzer)
  (lsp-rust-analyzer-server-display-inlay-hints t)
  (lsp-rust-analyzer-display-chaining-hints t)
  (lsp-rust-analyzer-display-closure-return-type-hints t))

;; ============================================================================
;; Language: Ruby
;; ============================================================================

(use-package ruby-mode
  :mode "\\.rb\\'"
  :general
  (my-local-leader
    :keymaps 'ruby-mode-map
    "'" 'inf-ruby

    ;; Goto
    "g" '(:ignore t :wk "goto")
    "gd" 'robe-jump
    "gb" 'xref-pop-marker-stack
    "gm" 'robe-jump-to-module

    ;; Help
    "h" '(:ignore t :wk "help")
    "hh" 'robe-doc
    "hm" 'robe-ask

    ;; Eval
    "e" '(:ignore t :wk "eval")
    "eb" 'ruby-send-buffer
    "er" 'ruby-send-region
    "el" 'ruby-send-line
    "ed" 'ruby-send-definition

    ;; REPL
    "r" '(:ignore t :wk "repl")
    "rr" 'ruby-send-region
    "rb" 'ruby-send-buffer
    "rs" 'inf-ruby

    ;; Refactor
    "R" '(:ignore t :wk "refactor")
    "Rt" 'ruby-toggle-string-quotes
    "Rh" 'ruby-toggle-hash-syntax
    "Rb" 'ruby-toggle-block

    ;; Test
    "t" '(:ignore t :wk "test")
    "tt" 'ruby-test-run-at-point
    "ta" 'ruby-test-run)

  :config
  (setq ruby-insert-encoding-magic-comment nil))

(use-package robe
  :hook (ruby-mode . robe-mode)
  :config
  (eval-after-load 'company
    '(push 'company-robe company-backends)))

(use-package inf-ruby
  :hook (ruby-mode . inf-ruby-minor-mode))

(use-package rbenv
  :hook (ruby-mode . rbenv-use-corresponding)
  :init
  (setq rbenv-show-active-ruby-in-modeline nil)
  :config
  (global-rbenv-mode))

;; ============================================================================
;; Additional Packages
;; ============================================================================

(use-package which-key
  :init
  (which-key-mode)
  :custom
  (which-key-idle-delay 0.5)
  (which-key-sort-order 'which-key-key-order-alpha))

(use-package ripgrep
  :defer t)

(use-package sudo-edit
  :defer t)

(use-package dumb-jump
  :defer t)

;; ============================================================================
;; Theme
;; ============================================================================

(use-package leuven-theme
  :config
  (load-theme 'leuven-dark t))

;; ============================================================================
;; Utility Functions
;; ============================================================================

(defun my/insert-pry ()
  "Insert pry binding for Ruby debugging."
  (interactive)
  (beginning-of-line)
  (open-line 1)
  (insert "require 'pry-byebug'; binding.pry")
  (indent-according-to-mode))

(defun my/c-compile-and-run ()
  "Compile current C file and run the executable."
  (interactive)
  (let* ((file (buffer-file-name))
         (executable (file-name-sans-extension file)))
    (compile (format "gcc -Wall -g %s -o %s && %s" file executable executable))))

;; ============================================================================
;; Final Setup
;; ============================================================================

;; GUD configuration
(setq gdb-many-windows t
      gdb-use-separate-io-buffer t)

;; Dired with Evil
(with-eval-after-load 'dired
  (evil-define-key 'normal dired-mode-map (kbd "SPC") nil))

;; Automatically tangle and reload on save if needed
(defun my/reload-init-file ()
  "Reload init file after saving."
  (interactive)
  (load-file user-init-file))

(message "Configuration loaded successfully!")

;;; init.el ends here
