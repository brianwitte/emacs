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
    "SPC" 'projectile-find-file
    "." 'embark-act
    "," 'consult-buffer

    ;; Files
    "ff" 'find-file
    "fs" 'save-buffer
    "fr" 'recentf-open-files

    ;; Buffers
    "bb" 'switch-to-buffer
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
    "pb" 'projectile-switch-to-buffer
    "pc" 'projectile-compile-project
    "pk" 'projectile-kill-buffers
    "pd" 'projectile-dired
    "pr" 'projectile-replace

    ;; VTERM
    "ot" 'vterm

    ;; Search & Navigation
    "ss" 'consult-line
    "rf" 'consult-find
    "rm" 'consult-mode-command
    "ro" 'consult-outline
    "ri" 'consult-imenu
    "rk" 'consult-flymake
    "rs" 'consult-locate
    "rg" 'ripgrep

    ;; Tools
    "op" 'treemacs
    "dl" 'downcase-current-line))

;; =======================
;; Completion & Navigation
;; =======================

(use-package orderless
  :custom
  (completion-styles '(orderless))
  (completion-category-defaults nil)
  (completion-category-overrides
   '((file (styles basic-remote orderless))))
  (orderless-component-separator 'orderless-escapable-split-on-space)
  (orderless-matching-styles
   '(orderless-literal orderless-prefixes orderless-initialism orderless-regexp))
  (orderless-style-dispatchers
   '(prot-orderless-literal-dispatcher
     prot-orderless-strict-initialism-dispatcher
     prot-orderless-flex-dispatcher))
  :init
  ;; Dispatcher functions
  (defun prot-orderless-literal-dispatcher (pattern _index _total)
    (when (string-suffix-p "=" pattern)
      `(orderless-literal . ,(substring pattern 0 -1))))

  (defun prot-orderless-strict-initialism-dispatcher (pattern _index _total)
    (when (string-suffix-p "," pattern)
      `(orderless-strict-initialism . ,(substring pattern 0 -1))))

  (defun prot-orderless-flex-dispatcher (pattern _index _total)
    (when (string-suffix-p "." pattern)
      `(orderless-flex . ,(substring pattern 0 -1)))))

(use-package vertico
  :demand t
  :straight (vertico :files (:defaults "extensions/*")
                     :includes (vertico-indexed vertico-flat vertico-grid
                               vertico-mouse vertico-quick vertico-buffer
                               vertico-repeat vertico-reverse vertico-directory
                               vertico-multiform vertico-unobtrusive))
  :general
  (:keymaps '(normal insert visual motion) "M-." 'vertico-repeat)
  (:keymaps 'vertico-map
            "<tab>" 'vertico-insert
            "<escape>" 'minibuffer-keyboard-quit
            "?" 'minibuffer-completion-help
            "C-M-n" 'vertico-next-group
            "C-M-p" 'vertico-previous-group
            "<backspace>" 'vertico-directory-delete-char
            "C-w" 'vertico-directory-delete-word
            "C-<backspace>" 'vertico-directory-delete-word
            "RET" 'vertico-directory-enter
            "C-i" 'vertico-quick-insert
            "C-o" 'vertico-quick-exit
            "M-o" 'kb/vertico-quick-embark
            "M-G" 'vertico-multiform-grid
            "M-F" 'vertico-multiform-flat
            "M-R" 'vertico-multiform-reverse
            "M-U" 'vertico-multiform-unobtrusive
            "C-l" 'kb/vertico-multiform-flat-toggle)
  :hook ((rfn-eshadow-update-overlay . vertico-directory-tidy)
         (minibuffer-setup . vertico-repeat-save))
  :custom
  (vertico-count 13)
  (vertico-resize nil)
  (vertico-cycle nil)
  (vertico-grid-separator "       ")
  (vertico-grid-lookahead 50)
  (vertico-buffer-display-action '(display-buffer-reuse-window))
  (vertico-multiform-categories
   '((file reverse)
     (consult-grep buffer)
     (consult-location)
     (imenu buffer)
     (library reverse indexed)
     (org-roam-node reverse indexed)
     (t reverse)))
  (vertico-multiform-commands
   '(("flyspell-correct-*" grid reverse)
     (org-refile grid reverse indexed)
     (consult-yank-pop indexed)
     (consult-flycheck)
     (consult-lsp-diagnostics)))
  :init
  ;; Helper functions
  (defun kb/vertico-multiform-flat-toggle ()
    (interactive)
    (vertico-multiform--display-toggle 'vertico-flat-mode)
    (if vertico-flat-mode
        (vertico-multiform--temporary-mode 'vertico-reverse-mode -1)
      (vertico-multiform--temporary-mode 'vertico-reverse-mode 1)))

  (defun kb/vertico-quick-embark (&optional arg)
    (interactive)
    (when (vertico-quick-jump)
      (embark-act arg)))

  ;; Tramp completion workaround
  (defun kb/basic-remote-try-completion (string table pred point)
    (and (vertico--remote-p string)
         (completion-basic-try-completion string table pred point)))

  (defun kb/basic-remote-all-completions (string table pred point)
    (and (vertico--remote-p string)
         (completion-basic-all-completions string table pred point)))

  (add-to-list 'completion-styles-alist
               '(basic-remote kb/basic-remote-try-completion
                 kb/basic-remote-all-completions nil))
  :config
  (vertico-mode)
  (vertico-multiform-mode)

  ;; Current candidate prefix
  (advice-add #'vertico--format-candidate :around
              (lambda (orig cand prefix suffix index _start)
                (setq cand (funcall orig cand prefix suffix index _start))
                (concat
                 (if (= vertico--index index)
                     (propertize "» " 'face 'vertico-current)
                   "  ")
                 cand))))

(use-package marginalia
  :general
  (:keymaps 'minibuffer-local-map "M-A" 'marginalia-cycle)
  :custom
  (marginalia-max-relative-age 0)
  (marginalia-align 'right)
  :init
  (marginalia-mode))

(use-package embark
  :demand t
  :general
  ("C-." 'embark-act)
  ("C-;" 'embark-dwim)
  (:keymaps 'vertico-map "C-." 'embark-act)
  (:keymaps 'embark-heading-map "l" 'org-id-store-link)
  :init
  (setq prefix-help-command #'embark-prefix-help-command)
  :config
  (add-to-list 'display-buffer-alist
               '("\\`\\*Embark Collect \\(Live\\|Completions\\)\\*"
                 nil
                 (window-parameters (mode-line-format . none)))))

(use-package embark-consult
  :hook (embark-collect-mode . consult-preview-at-point-mode))

(use-package corfu
  :custom
  (corfu-auto t)
  (completion-cycle-threshold 3)
  (tab-always-indent 'complete)
  :init
  (global-corfu-mode))

(use-package corfu-terminal
  :after corfu
  :straight (corfu-terminal :type git :repo "https://codeberg.org/akib/emacs-corfu-terminal.git")
  :init
  (unless (display-graphic-p) (corfu-terminal-mode +1)))

(use-package all-the-icons
  :if (display-graphic-p))

(use-package all-the-icons-completion
  :after (marginalia all-the-icons)
  :hook (marginalia-mode . all-the-icons-completion-marginalia-setup)
  :init
  (all-the-icons-completion-mode))

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

;; Clojure
(use-package clojure-mode
  :mode (("\\.clj\\'" . clojure-mode)
         ("\\.cljs\\'" . clojurescript-mode)
         ("\\.cljc\\'" . clojurec-mode)))

(use-package cider
  :hook ((clojure-mode clojurescript-mode clojurec-mode) . cider-mode)
  :config
  (defun setup-clojure-keybindings ()
    "Setup comprehensive Clojure/CIDER specific keybindings."
    (my-local-leader-def
      :keymaps 'local
      ;; REPL Connection & Management
      "'" 'cider-jack-in-clj
      "\"" 'cider-jack-in-cljs
      "c'" 'cider-jack-in-clj&cljs
      "cc" 'cider-connect-clj
      "cC" 'cider-connect-cljs
      "cx" 'cider-connect-clj&cljs
      "rq" 'cider-quit
      "rr" 'cider-restart
      "rR" 'cider-restart-clj&cljs-repls
      "rb" 'cider-switch-to-repl-buffer
      "rB" 'cider-switch-to-repl-buffer-other-window
      "rn" 'cider-repl-set-ns
      "rN" 'cider-repl-switch-to-other
      "rc" 'cider-find-and-clear-repl-output
      "rl" 'cider-load-buffer-and-switch-to-repl-buffer
      "rL" 'cider-find-ns-and-switch-to-repl
      "rp" 'cider-pprint-eval-last-sexp-to-repl
      "rP" 'cider-pprint-eval-defun-to-repl

      ;; Evaluation
      "eb" 'cider-eval-buffer
      "eB" 'cider-eval-buffer-and-go
      "ed" 'cider-eval-defun-at-point
      "eD" 'cider-eval-defun-at-point-and-go
      "ee" 'cider-eval-last-sexp
      "eE" 'cider-eval-last-sexp-and-go
      "er" 'cider-eval-region
      "eR" 'cider-eval-region-and-go
      "el" 'cider-eval-list-at-point
      "eL" 'cider-eval-sexp-at-point
      "ef" 'cider-eval-file
      "eF" 'cider-eval-all-files
      "en" 'cider-eval-ns-form
      "ew" 'cider-eval-last-sexp-and-replace
      "ep" 'cider-pprint-eval-last-sexp
      "eP" 'cider-pprint-eval-defun-at-point
      "em" 'cider-macroexpand-1
      "eM" 'cider-macroexpand-all
      "ex" 'cider-eval-last-sexp-in-context

      ;; Navigation & Finding
      "gd" 'cider-find-var
      "gD" 'cider-find-var-other-window
      "gb" 'cider-pop-back
      "gn" 'cider-find-ns
      "gN" 'cider-browse-ns
      "gr" 'cider-find-resource
      "gs" 'cider-browse-spec
      "gS" 'cider-browse-spec-all
      "gc" 'cider-classpath
      "gj" 'cider-javadoc
      "ga" 'cider-apropos
      "gA" 'cider-apropos-documentation
      "gw" 'cider-clojuredocs-web
      "gW" 'cider-clojuredocs

      ;; Help & Documentation
      "hd" 'cider-doc
      "hD" 'cider-clojuredocs
      "hj" 'cider-javadoc
      "ha" 'cider-apropos
      "hA" 'cider-apropos-documentation
      "hs" 'cider-apropos-select
      "hf" 'cider-describe-function
      "hm" 'cider-describe-macro
      "hc" 'cider-cheatsheet

      ;; Testing
      "tt" 'cider-test-run-test
      "tT" 'cider-test-rerun-test
      "tn" 'cider-test-run-ns-tests
      "tN" 'cider-test-rerun-ns-tests
      "tp" 'cider-test-run-project-tests
      "tP" 'cider-test-rerun-project-tests
      "tl" 'cider-test-run-loaded-tests
      "tL" 'cider-test-rerun-loaded-tests
      "tf" 'cider-test-run-focused-tests
      "tr" 'cider-test-show-report
      "ts" 'cider-auto-test-mode

      ;; Debugging
      "db" 'cider-debug-defun-at-point
      "di" 'cider-inspect
      "dI" 'cider-inspect-last-result
      "dr" 'cider-inspect-last-result
      "de" 'cider-enlighten-mode
      "dE" 'cider-enlighten-current-sexp

      ;; Profiling
      "pb" 'cider-profile-toggle
      "pc" 'cider-profile-clear
      "pr" 'cider-profile-ns-toggle
      "ps" 'cider-profile-samples
      "pS" 'cider-profile-summary

      ;; Refactoring
      "rt" 'cider-refactor-thread
      "rT" 'cider-refactor-thread-last
      "ru" 'cider-refactor-unwind
      "rU" 'cider-refactor-unwind-all
      "rp" 'cider-refactor-promote-function
      "rf" 'cider-refactor-move-form
      "re" 'cider-refactor-extract-function
      "ri" 'cider-refactor-introduce-let
      "rr" 'cider-refactor-rename-symbol

      ;; Namespace Operations
      "ns" 'cider-repl-set-ns
      "nS" 'cider-ns-refresh
      "nr" 'cider-ns-reload
      "nR" 'cider-ns-reload-all
      "nb" 'cider-browse-ns
      "nB" 'cider-browse-ns-all
      "nf" 'cider-find-ns

      ;; Format & Style
      "fl" 'cider-format-edn-last-sexp
      "fr" 'cider-format-edn-region
      "fb" 'cider-format-edn-buffer

      ;; ClojureScript specific
      "sf" 'cider-cljs-figwheel-start
      "sF" 'cider-cljs-figwheel-stop
      "sc" 'cider-create-cljs-repl
      "sC" 'cider-cljs-connect
      "sb" 'cider-switch-to-cljs-repl
      "sq" 'cider-quit-cljs-repl

      ;; Miscellaneous
      "mb" 'cider-macroexpand-1
      "mB" 'cider-macroexpand-all
      "mp" 'cider-pprint-eval-last-sexp
      "mP" 'cider-pprint-eval-defun-at-point
      "mi" 'cider-inspect-last-result
      "mI" 'cider-inspect
      "mc" 'cider-cheatsheet
      "mv" 'cider-toggle-trace-var
      "mV" 'cider-toggle-trace-ns))

  (dolist (mode '(clojure-mode-hook clojurescript-mode-hook clojurec-mode-hook))
    (add-hook mode 'setup-lisp-sexp-keybindings)
    (add-hook mode 'setup-clojure-keybindings)))

;; =======================
;; Lua Setup
;; =======================

;; Lua
(use-package lua-mode
  :mode "\\.lua\\'"
  :config
  (defun setup-lua-keybindings ()
    "Setup Lua specific keybindings."
    (my-local-leader-def
      :keymaps 'local
      "eb" 'lua-send-buffer
      "ed" 'lua-send-defun
      "ee" 'lua-send-current-line
      "er" 'lua-send-region
      "'" 'lua-show-process-buffer
      "rb" 'lua-restart-with-whole-file
      "rr" 'run-lua
      "rq" 'lua-kill-process))

  (add-hook 'lua-mode-hook 'setup-lua-keybindings))

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

;; =======================
;; Final Setup
;; =======================

;; Dired integration with Evil
(with-eval-after-load 'dired
  (evil-define-key 'normal dired-mode-map (kbd "SPC") nil))

(message "Configuration loaded successfully!")
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(eldoc-documentation-functions nil t nil "Customized with use-package lsp-mode")
 '(safe-local-variable-values
   '((eval progn
           (make-variable-buffer-local 'cider-custom-cljs-repl-init-form)
           (setq cider-custom-cljs-repl-init-form "(user/cljs-repl)")
           (make-variable-buffer-local 'cider-jack-in-nrepl-middlewares)
           (add-to-list 'cider-jack-in-nrepl-middlewares "shadow.cljs.devtools.server.nrepl/middleware"))
     (cider-ns-refresh-after-fn . "integrant.repl/resume")
     (cider-ns-refresh-before-fn . "integrant.repl/suspend"))))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
