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
    "hi" 'consult-imenu
    
    ;; Symbol Search
    "ss" 'consult-lsp-symbols
    "sS" 'consult-lsp-symbols
    "si" 'consult-imenu
    
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
    "hi" 'consult-imenu
    "hd" 'lua-search-documentation
    
    ;; Symbol Search
    "ss" 'consult-lsp-symbols
    "sS" 'consult-lsp-symbols
    "si" 'consult-imenu
    
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
