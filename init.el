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
        (or (bound-and-true-p straight-base-dir) user-emacs-directory)))
      (bootstrap-version 7))
  (unless (file-exists-p bootstrap-file)
    (with-current-buffer
        (url-retrieve-synchronously
         "https://raw.githubusercontent.com/radian-software/straight.el/develop/install.el"
         'silent
         'inhibit-cookies)
      (goto-char (point-max))
      (eval-print-last-sexp)))
  (load bootstrap-file nil 'nomessage))

(straight-use-package 'use-package)
(setq straight-use-package-by-default t)

;; Allow straight.el to install newer versions of built-in packages
(setq straight-built-in-pseudo-packages '())

;; Keep transient up-to-date (it's a built-in but we want the latest)
(use-package transient)

;; ============================================================================
;; Core Settings
;; ============================================================================

;; Performance
(setq
 gc-cons-threshold 50000000
 large-file-warning-threshold 100000000
 read-process-output-max (* 1024 1024))

;; UI
(setq
 inhibit-startup-screen t
 use-short-answers t
 ring-bell-function 'ignore)

(menu-bar-mode -1)
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))

;; Editing
(setq-default
 indent-tabs-mode nil
 tab-width 4
 fill-column 80)

;; Files
(setq
 backup-directory-alist '(("." . "~/.config/emacs/backups"))
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
(winner-mode 1)
(add-hook 'prog-mode-hook 'display-line-numbers-mode)

;; Minibuffer
(setq
 enable-recursive-minibuffers t
 minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt))
(add-hook 'minibuffer-setup-hook 'cursor-intangible-mode)

;; Dired - macOS ls compatibility (must be set before dired loads)
(when (eq system-type 'darwin)
  (setq dired-use-ls-dired nil))

;; ============================================================================
;; Evil Mode
;; ============================================================================

(use-package
 evil
 :demand t
 :init
 (setq
  evil-want-keybinding nil
  evil-want-integration t
  evil-want-C-u-scroll t
  evil-want-C-i-jump nil
  evil-undo-system 'undo-redo
  evil-respect-visual-line-mode t)
 :config (evil-mode 1)

 ;; Visual line navigation
 (evil-global-set-key 'motion "j" 'evil-next-visual-line)
 (evil-global-set-key 'motion "k" 'evil-previous-visual-line)

 ;; Initial states
 (evil-set-initial-state 'messages-buffer-mode 'normal)
 (evil-set-initial-state 'dashboard-mode 'normal))

(use-package evil-collection :after evil :config (evil-collection-init))

(use-package evil-surround :after evil :config (global-evil-surround-mode 1))

(use-package evil-nerd-commenter :after evil :config (evilnc-default-hotkeys))

;; ============================================================================
;; my/custom-functions
;; ============================================================================

(defun my/find-file-from-home ()
  "Open find-file starting from the home directory."
  (interactive)
  (let ((default-directory "~/"))
    (call-interactively 'find-file)))

;; ============================================================================
;; General - Keybinding Framework
;; ============================================================================

(use-package
 general
 :demand t
 :config
 ;; ===========================================================================
 ;; Leader Key Definitions
 ;; ===========================================================================

 ;; Global leader (SPC in normal/visual, C-SPC everywhere)
 (general-create-definer
  my-leader
  :states '(normal visual insert emacs)
  :keymaps 'override
  :prefix "SPC"
  :global-prefix "C-SPC")

 ;; Local leader (comma in normal/visual, C-, in insert/emacs)
 (general-create-definer
  my-local-leader
  :states '(normal visual)
  :prefix ","
  :non-normal-prefix "C-,")

 ;; ===========================================================================
 ;; Global Keybindings (SPC prefix)
 ;; ===========================================================================

 (my-leader
  ;; ---------------------------------------------------------------------------
  ;; Top-level quick access
  ;; ---------------------------------------------------------------------------
  "SPC"
  '(project-find-file :wk "find file in project")
  ":"
  '(execute-extended-command :wk "M-x")
  "."
  '(find-file :wk "find file")
  ","
  '(consult-buffer :wk "switch buffer")
  "'"
  '(multi-vterm :wk "terminal")
  "`"
  '(evil-switch-to-windows-last-buffer :wk "last buffer")
  "u"
  '(universal-argument :wk "universal arg")
  "x"
  '(scratch-buffer :wk "scratch buffer")
  "/"
  '(consult-ripgrep :wk "search project")
  "*"
  '(my/search-symbol-at-point :wk "search symbol at point")
  ";"
  '(eval-expression :wk "eval expression")
  "TAB"
  '(evil-switch-to-windows-last-buffer :wk "last buffer")

  ;; ---------------------------------------------------------------------------
  ;; b - Buffers
  ;; ---------------------------------------------------------------------------
  "b"
  '(:ignore t :wk "buffers")
  "bb"
  '(consult-buffer :wk "switch buffer")
  "bd"
  '(kill-current-buffer :wk "kill buffer")
  "bD"
  '(kill-buffer :wk "kill buffer (choose)")
  "bi"
  '(bufler :wk "bufler")
  "bk"
  '(kill-current-buffer :wk "kill buffer")
  "bn"
  '(next-buffer :wk "next buffer")
  "bp"
  '(previous-buffer :wk "previous buffer")
  "br"
  '(revert-buffer :wk "revert buffer")
  "bs"
  '(save-buffer :wk "save buffer")
  "bS"
  '(save-some-buffers :wk "save all buffers")
  "bm"
  '(bookmark-set :wk "set bookmark")
  "bM"
  '(consult-bookmark :wk "consult bookmark")
  "bN"
  '(my/new-empty-buffer :wk "new empty buffer")
  "bY"
  '(my/yank-buffer-contents :wk "yank buffer contents")
  "bz"
  '(bury-buffer :wk "bury buffer")

  ;; ---------------------------------------------------------------------------
  ;; c - Code/LSP actions
  ;; ---------------------------------------------------------------------------
  "c"
  '(:ignore t :wk "code")
  "ca"
  '(lsp-execute-code-action :wk "code action")
  "cd"
  '(lsp-find-definition :wk "find definition")
  "cD"
  '(lsp-find-declaration :wk "find declaration")
  "ce"
  '(flycheck-list-errors :wk "list errors")
  "cf"
  '(lsp-format-buffer :wk "format buffer")
  "cF"
  '(lsp-format-region :wk "format region")
  "ci"
  '(lsp-find-implementation :wk "find implementation")
  "cn"
  '(flycheck-next-error :wk "next error")
  "cp"
  '(flycheck-previous-error :wk "previous error")
  "cr"
  '(lsp-rename :wk "rename symbol")
  "cR"
  '(lsp-find-references :wk "find references")
  "ct"
  '(lsp-find-type-definition :wk "find type definition")
  "cx"
  '(lsp-workspace-restart :wk "restart LSP")

  ;; ---------------------------------------------------------------------------
  ;; f - Files
  ;; ---------------------------------------------------------------------------
  "f"
  '(:ignore t :wk "files")
  "fd"
  '(dirvish :wk "dirvish (ranger)")
  "fD"
  '(dirvish-dwim :wk "dirvish dwim")
  "fe"
  '(sudo-edit :wk "sudo edit")
  "ff"
  '(find-file :wk "find file")
  "fh"
  '(my/find-file-from-home :wk "find file from home")
  "fj"
  '(dirvish-quick-access :wk "quick access")
  "fp"
  '(project-find-file :wk "find in project")
  "fr"
  '(consult-recent-file :wk "recent files")
  "fs"
  '(save-buffer :wk "save file")
  "fS"
  '(write-file :wk "save as")
  "fy"
  '(my/copy-file-path :wk "copy file path")
  "fR"
  '(my/rename-current-file :wk "rename file")
  "fC"
  '(copy-file :wk "copy file")
  "fX"
  '(my/delete-current-file :wk "delete file")
  "fl"
  '(consult-locate :wk "locate file")
  "fn"
  '(my/copy-file-name :wk "copy file name")
  "fP"
  '(my/open-init-file :wk "open config")
  "fE"
  '(my/sudo-find-file :wk "sudo find file")

  ;; ---------------------------------------------------------------------------
  ;; g - Git
  ;; ---------------------------------------------------------------------------
  "g"
  '(:ignore t :wk "git")
  "gb"
  '(magit-blame :wk "blame")
  "gB"
  '(blamer-mode :wk "toggle inline blame")
  "gc"
  '(magit-commit :wk "commit")
  "gd"
  '(magit-diff :wk "diff")
  "gf"
  '(magit-file-dispatch :wk "file dispatch")
  "gg"
  '(magit-status :wk "status")
  "gG"
  '(magit-dispatch :wk "dispatch")
  "gh"
  '(:ignore t :wk "hunk")
  "ghn"
  '(git-gutter:next-hunk :wk "next hunk")
  "ghp"
  '(git-gutter:previous-hunk :wk "prev hunk")
  "ghr"
  '(git-gutter:revert-hunk :wk "revert hunk")
  "ghs"
  '(git-gutter:stage-hunk :wk "stage hunk")
  "gl"
  '(magit-log :wk "log")
  "gL"
  '(magit-log-buffer-file :wk "log file")
  "gp"
  '(magit-push :wk "push")
  "gP"
  '(magit-pull :wk "pull")
  "gr"
  '(magit-rebase :wk "rebase")
  "gs"
  '(magit-stage-file :wk "stage file")
  "gt"
  '(git-timemachine :wk "time machine")
  "gU"
  '(magit-unstage-file :wk "unstage file")

  ;; ---------------------------------------------------------------------------
  ;; h - Help
  ;; ---------------------------------------------------------------------------
  "h"
  '(:ignore t :wk "help")
  "ha"
  '(apropos :wk "apropos")
  "hb"
  '(embark-bindings :wk "bindings")
  "hf"
  '(describe-function :wk "function")
  "hF"
  '(describe-face :wk "face")
  "hi"
  '(info :wk "info")
  "hk"
  '(describe-key :wk "key")
  "hm"
  '(describe-mode :wk "mode")
  "hp"
  '(describe-package :wk "package")
  "hv"
  '(describe-variable :wk "variable")
  "hw"
  '(where-is :wk "where is")

  ;; ---------------------------------------------------------------------------
  ;; j - Jump/Navigation
  ;; ---------------------------------------------------------------------------
  "j"
  '(:ignore t :wk "jump")
  "jd"
  '(dumb-jump-go :wk "dumb jump")
  "jD"
  '(dumb-jump-go-other-window :wk "dumb jump other window")
  "ji"
  '(consult-imenu :wk "imenu")
  "jI"
  '(consult-imenu-multi :wk "imenu multi")
  "jj"
  '(evil-avy-goto-char-timer :wk "avy char")
  "jl"
  '(evil-avy-goto-line :wk "avy line")
  "jm"
  '(consult-mark :wk "marks")
  "jo"
  '(consult-outline :wk "outline")

  ;; ---------------------------------------------------------------------------
  ;; o - Open/Toggle
  ;; ---------------------------------------------------------------------------
  "o"
  '(:ignore t :wk "open/toggle")
  "od"
  '(dirvish-side :wk "dirvish sidebar")
  "oD"
  '(dirvish :wk "dirvish full")
  "oi"
  '(imenu-list-smart-toggle :wk "imenu sidebar")
  "op"
  '(treemacs :wk "treemacs")
  "oP"
  '(treemacs-select-window :wk "treemacs focus")
  "ot"
  '(multi-vterm :wk "terminal")
  "oT"
  '(multi-vterm-project :wk "project terminal")
  "oe"
  '(eshell :wk "eshell")
  "oc"
  '(calendar :wk "calendar")

  ;; ---------------------------------------------------------------------------
  ;; p - Project
  ;; ---------------------------------------------------------------------------
  "p"
  '(:ignore t :wk "project")
  "pa"
  '(projectile-add-known-project :wk "add project")
  "pb"
  '(consult-project-buffer :wk "project buffers")
  "pc"
  '(projectile-compile-project :wk "compile")
  "pd"
  '(projectile-dired :wk "project dired")
  "pf"
  '(project-find-file :wk "find file")
  "pg"
  '(consult-ripgrep :wk "ripgrep")
  "pk"
  '(projectile-kill-buffers :wk "kill buffers")
  "pp"
  '(projectile-switch-project :wk "switch project")
  "pr"
  '(projectile-recentf :wk "recent files")
  "pR"
  '(projectile-replace :wk "replace in project")
  "ps"
  '(consult-ripgrep :wk "search project")
  "pt"
  '(multi-vterm-project :wk "project terminal")

  ;; ---------------------------------------------------------------------------
  ;; q - Quit/Session
  ;; ---------------------------------------------------------------------------
  "q"
  '(:ignore t :wk "quit")
  "qf"
  '(delete-frame :wk "delete frame")
  "qq"
  '(save-buffers-kill-terminal :wk "quit emacs")
  "qQ"
  '(kill-emacs :wk "kill emacs")
  "qr"
  '(restart-emacs :wk "restart emacs")

  ;; ---------------------------------------------------------------------------
  ;; r - Ripgrep/Search (dedicated)
  ;; ---------------------------------------------------------------------------
  "r"
  '(:ignore t :wk "ripgrep")
  "rd"
  '(deadgrep :wk "deadgrep")
  "rp"
  '(projectile-ripgrep :wk "project ripgrep")
  "rr"
  '(ripgrep-regexp :wk "ripgrep regexp")
  "rs"
  '(consult-ripgrep :wk "consult ripgrep")

  ;; ---------------------------------------------------------------------------
  ;; s - Search
  ;; ---------------------------------------------------------------------------
  "s"
  '(:ignore t :wk "search")
  "sb"
  '(consult-line :wk "search buffer")
  "sB"
  '(consult-line-multi :wk "search all buffers")
  "sd"
  '(deadgrep :wk "deadgrep")
  "sf"
  '(consult-find :wk "find files")
  "sg"
  '(consult-grep :wk "grep")
  "si"
  '(consult-imenu :wk "imenu")
  "sI"
  '(consult-imenu-multi :wk "imenu multi")
  "sm"
  '(consult-mark :wk "marks")
  "so"
  '(consult-outline :wk "outline")
  "sp"
  '(consult-ripgrep :wk "ripgrep project")
  "sr"
  '(consult-ripgrep :wk "ripgrep")
  "sR"
  '(consult-resume :wk "resume search")
  "ss"
  '(consult-line :wk "search line")

  ;; ---------------------------------------------------------------------------
  ;; t - Toggle
  ;; ---------------------------------------------------------------------------
  "t"
  '(:ignore t :wk "toggle")
  "tb"
  '(blamer-mode :wk "git blame")
  "tc"
  '(display-fill-column-indicator-mode :wk "fill column")
  "tf"
  '(toggle-frame-fullscreen :wk "fullscreen")
  "tg"
  '(git-gutter-mode :wk "git gutter")
  "th"
  '(hl-line-mode :wk "highlight line")
  "ti"
  '(imenu-list-smart-toggle :wk "imenu list")
  "tl"
  '(display-line-numbers-mode :wk "line numbers")
  "tn"
  '(display-line-numbers-mode :wk "line numbers")
  "tt"
  '(consult-theme :wk "choose theme")
  "tw"
  '(whitespace-mode :wk "whitespace")
  "tz"
  '(writeroom-mode :wk "zen mode")
  "tT"
  '(toggle-truncate-lines :wk "truncate lines")
  "ts"
  '(flyspell-mode :wk "flyspell")
  "tp"
  '(electric-pair-mode :wk "electric pairs")
  "tv"
  '(visual-line-mode :wk "visual line mode")
  "tr"
  '(read-only-mode :wk "read only")

  ;; ---------------------------------------------------------------------------
  ;; w - Windows
  ;; ---------------------------------------------------------------------------
  "w"
  '(:ignore t :wk "windows")
  "w="
  '(balance-windows :wk "balance windows")
  "wd"
  '(delete-window :wk "delete window")
  "wD"
  '(kill-buffer-and-window :wk "kill buffer & window")
  "wh"
  '(evil-window-left :wk "window left")
  "wH"
  '(evil-window-move-far-left :wk "move window left")
  "wj"
  '(evil-window-down :wk "window down")
  "wJ"
  '(evil-window-move-very-bottom :wk "move window down")
  "wk"
  '(evil-window-up :wk "window up")
  "wK"
  '(evil-window-move-very-top :wk "move window up")
  "wl"
  '(evil-window-right :wk "window right")
  "wL"
  '(evil-window-move-far-right :wk "move window right")
  "wm"
  '(delete-other-windows :wk "maximize")
  "wn"
  '(evil-window-new :wk "new window")
  "wo"
  '(other-window :wk "other window")
  "wr"
  '(evil-window-rotate-downwards :wk "rotate windows")
  "ws"
  '(split-window-below :wk "split horizontal")
  "wv"
  '(split-window-right :wk "split vertical")
  "ww"
  '(other-window :wk "other window")
  "wu"
  '(winner-undo :wk "winner undo")
  "wU"
  '(winner-redo :wk "winner redo")

  ;; ---------------------------------------------------------------------------
  ;; j - Jump additions
  ;; ---------------------------------------------------------------------------
  "jb"
  '(consult-bookmark :wk "bookmark")

  ;; ---------------------------------------------------------------------------
  ;; n - Notes
  ;; ---------------------------------------------------------------------------
  "n"
  '(:ignore t :wk "notes")
  "na"
  '(org-agenda :wk "agenda")
  "nc"
  '(org-capture :wk "capture")
  "nl"
  '(org-store-link :wk "store link"))

 ;; ===========================================================================
 ;; Non-leader Global Keybindings
 ;; ===========================================================================

 ;; General keys available without SPC prefix
 (general-define-key
  :states '(normal visual) "C-n" 'next-buffer "C-p" 'previous-buffer)

 ;; Insert state bindings
 (general-define-key :states 'insert "C-g" 'evil-normal-state))

;; ============================================================================
;; System Integration
;; ============================================================================

(use-package
 exec-path-from-shell
 :config
 (when (or (daemonp) (memq window-system '(mac ns x)))
   (exec-path-from-shell-initialize)))

(use-package xclip :config (xclip-mode 1))

(use-package vterm :defer t)

(use-package multi-vterm :defer t)

(use-package bufler)

;; ============================================================================
;; Completion Framework
;; ============================================================================

(use-package
 vertico
 :init (vertico-mode)
 :custom
 (vertico-count 20)
 (vertico-cycle t))

(use-package
 orderless
 :custom
 (completion-styles '(orderless basic))
 (completion-category-defaults nil)
 (completion-category-overrides '((file (styles partial-completion)))))

(use-package marginalia :init (marginalia-mode))

(use-package
 consult
 :bind
 (("C-x b" . consult-buffer)
  ("M-y" . consult-yank-pop)
  ("M-g g" . consult-goto-line)
  ("M-g i" . consult-imenu)
  ("M-s l" . consult-line))
 :config (setq consult-project-function (lambda (_) (projectile-project-root))))

(use-package
 embark
 :bind
 (("C-." . embark-act) ("C-;" . embark-dwim) ("C-h B" . embark-bindings))
 :init (setq prefix-help-command #'embark-prefix-help-command))

(use-package
 embark-consult
 :after (embark consult)
 :hook (embark-collect-mode . consult-preview-at-point-mode))

;; ============================================================================
;; Navigation
;; ============================================================================

(use-package
 avy
 :general
 (general-define-key
  :states
  '(normal motion)
  "s"
  'evil-avy-goto-char-timer
  "f"
  'evil-avy-goto-char-in-line
  "gl"
  'evil-avy-goto-line
  ";"
  'avy-resume)
 :config
 (setq
  avy-all-windows nil
  avy-background t))

(use-package
 projectile
 :init (projectile-mode +1)
 :custom (projectile-completion-system 'default) (projectile-enable-caching t)
 (projectile-project-root-files
  '("compile_commands.json" "Makefile" "CMakeLists.txt" ".git")))

(use-package
 treemacs
 :defer t
 :config
 (treemacs-follow-mode t)
 (treemacs-filewatch-mode t))

(use-package treemacs-evil :after (treemacs evil))

(use-package treemacs-projectile :after (treemacs projectile))

;; Dirvish - Ranger-like file navigator
(use-package
 dirvish
 :init (dirvish-override-dired-mode)
 :custom
 (dirvish-quick-access-entries
  '(("h" "~/" "Home")
    ("d" "~/Downloads/" "Downloads")
    ("p" "~/projects/" "Projects")
    ("c" "~/.config/" "Config"))))

(use-package dirvish-side :straight nil :after dirvish)

(use-package all-the-icons :if (display-graphic-p))

(use-package all-the-icons-dired :hook (dired-mode . all-the-icons-dired-mode))

;; imenu-list - Side panel for code structure
(use-package
 imenu-list
 :defer t
 :custom
 (imenu-list-focus-after-activation t)
 (imenu-list-auto-resize t))

;; ============================================================================
;; Development Tools
;; ============================================================================

(use-package
 company
 :hook (after-init . global-company-mode)
 :custom
 (company-idle-delay 0.3)
 (company-minimum-prefix-length 2)
 (company-selection-wrap-around t)
 (company-tooltip-align-annotations t)
 (company-show-numbers t))

(use-package company-box :hook (company-mode . company-box-mode))

(use-package
 flycheck
 :hook
 ((after-init . global-flycheck-mode)
  (ruby-mode . (lambda () (flycheck-mode -1))))
 :custom
 (flycheck-check-syntax-automatically '(save mode-enabled))
 (flycheck-display-errors-delay 0.3))

(use-package
 lsp-mode
 :commands (lsp lsp-deferred)
 :hook
 (
  ;;  (c-mode . lsp-deferred)
  (c++-mode . lsp-deferred)
  (rustic-mode . lsp-deferred)
  (ruby-mode . lsp-deferred)
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

(use-package
 lsp-ui
 :after lsp-mode
 :custom
 (lsp-ui-doc-enable t)
 (lsp-ui-doc-position 'at-point)
 (lsp-ui-doc-delay 0.5)
 (lsp-ui-sideline-enable t)
 (lsp-ui-sideline-show-diagnostics t)
 (lsp-ui-peek-enable t))

(use-package
 dap-mode
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

(use-package
 emacs
 :straight nil
 :general
 (my-local-leader
  :keymaps
  'emacs-lisp-mode-map
  "'"
  'ielm

  ;; Eval
  "e"
  '(:ignore t :wk "eval")
  "eb"
  'eval-buffer
  "ed"
  'eval-defun
  "ee"
  'eval-last-sexp
  "er"
  'eval-region
  "eE"
  'eval-expression
  "el"
  'load-library

  ;; Goto
  "g"
  '(:ignore t :wk "goto")
  "gf"
  'find-function
  "gv"
  'find-variable
  "gl"
  'find-library
  "gb"
  'xref-pop-marker-stack

  ;; Help
  "h"
  '(:ignore t :wk "help")
  "hf"
  'describe-function
  "hv"
  'describe-variable
  "hk"
  'describe-key
  "hm"
  'describe-mode

  ;; Debug
  "d"
  '(:ignore t :wk "debug")
  "dd"
  'edebug-defun
  "db"
  'edebug-set-breakpoint
  "dB"
  'edebug-unset-breakpoint

  ;; Macro
  "m"
  '(:ignore t :wk "macro")
  "me"
  'macroexpand
  "mE"
  'macroexpand-all
  "m1"
  'macroexpand-1

  ;; Compile
  "c"
  '(:ignore t :wk "compile")
  "cc"
  'compile
  "cb"
  'byte-compile-file
  "cB"
  'byte-recompile-directory))

(use-package elisp-autofmt)

;; ============================================================================
;; Language: Clojure
;; ============================================================================

(use-package clojure-mode :defer t)

(use-package
 cider
 :after clojure-mode
 :general
 (my-local-leader
  :keymaps
  'clojure-mode-map
  "'"
  'cider-jack-in

  ;; Eval
  "e"
  '(:ignore t :wk "eval")
  "eb"
  'cider-eval-buffer
  "ed"
  'cider-eval-defun-at-point
  "ee"
  'cider-eval-last-sexp
  "er"
  'cider-eval-region
  "ep"
  'cider-pprint-eval-last-sexp

  ;; Goto
  "g"
  '(:ignore t :wk "goto")
  "gd"
  'cider-find-var
  "gb"
  'cider-pop-back
  "gr"
  'cider-find-references-at-point

  ;; Help
  "h"
  '(:ignore t :wk "help")
  "hd"
  'cider-doc
  "ha"
  'cider-apropos
  "hj"
  'cider-javadoc

  ;; REPL
  "r"
  '(:ignore t :wk "repl")
  "rr"
  'cider-restart
  "rq"
  'cider-quit
  "rB"
  'cider-repl-clear-buffer

  ;; Test
  "t"
  '(:ignore t :wk "test")
  "tt"
  'cider-test-run-test
  "ta"
  'cider-test-run-all-tests))

;; ============================================================================
;; Language: Common Lisp
;; ============================================================================

(use-package
 sly
 :defer t
 :general
 (my-local-leader
  :keymaps
  'lisp-mode-map
  "'"
  'sly

  ;; Eval
  "e"
  '(:ignore t :wk "eval")
  "eb"
  'sly-eval-buffer
  "ed"
  'sly-eval-defun
  "ee"
  'sly-eval-last-expression
  "er"
  'sly-eval-region
  "ep"
  'sly-pprint-eval-last-expression

  ;; Goto
  "g"
  '(:ignore t :wk "goto")
  "gd"
  'sly-edit-definition
  "gb"
  'sly-pop-find-definition-stack
  "gr"
  'sly-who-references

  ;; Help
  "h"
  '(:ignore t :wk "help")
  "hd"
  'sly-describe-symbol
  "ha"
  'sly-apropos
  "hH"
  'sly-hyperspec-lookup

  ;; REPL
  "r"
  '(:ignore t :wk "repl")
  "rr"
  'sly-restart-inferior-lisp
  "rq"
  'sly-quit-lisp
  "rB"
  'sly-mrepl-clear-repl

  ;; Compile
  "c"
  '(:ignore t :wk "compile")
  "cc"
  'sly-compile-file
  "cC"
  'sly-compile-and-load-file
  "cd"
  'sly-compile-defun
  "cr"
  'sly-compile-region

  ;; Stickers (debugging)
  "s"
  '(:ignore t :wk "stickers")
  "sb"
  'sly-stickers-dwim
  "sc"
  'sly-stickers-clear-defun-stickers
  "sC"
  'sly-stickers-clear-buffer-stickers

  ;; Trace
  "t"
  '(:ignore t :wk "trace")
  "tt"
  'sly-toggle-trace-fdefinition
  "tu"
  'sly-untrace-all)

 :custom (inferior-lisp-program "sbcl"))

;; ============================================================================
;; Language: Fennel
;; ============================================================================

(use-package
 fennel-mode
 :mode "\\.fnl\\'"
 :general
 (my-local-leader
  :keymaps
  'fennel-mode-map
  "'"
  'fennel-repl

  ;; Eval
  "e"
  '(:ignore t :wk "eval")
  "eb"
  'fennel-eval-buffer
  "ee"
  'fennel-eval-last-sexp
  "er"
  'fennel-eval-region
  "el"
  'fennel-load-file

  ;; Compile
  "c"
  '(:ignore t :wk "compile")
  "cb"
  'fennel-compile-buffer
  "cf"
  'fennel-compile-file

  ;; Goto
  "g"
  '(:ignore t :wk "goto")
  "gd"
  'fennel-find-definition
  "gb"
  'xref-pop-marker-stack

  ;; Help
  "h"
  '(:ignore t :wk "help")
  "hd"
  'fennel-describe-symbol
  "ha"
  'fennel-apropos

  ;; Macro
  "m"
  '(:ignore t :wk "macro")
  "mb"
  'fennel-macroexpand-1
  "mM"
  'fennel-macroexpand-all))

(with-eval-after-load 'eglot
  (add-to-list 'eglot-server-programs '(fennel-mode . ("fennel-ls"))))

;; ============================================================================
;; Language: C/C++
;; ============================================================================

(use-package
 cc-mode
 :straight nil
 :mode
 (("\\.c\\'" . c-mode)
  ("\\.h\\'" . c-mode)
  ("\\.cpp\\'" . c++-mode)
  ("\\.hpp\\'" . c++-mode))
 :general
 (my-local-leader
  :keymaps '(c-mode-map c++-mode-map)

  ;; Goto
  "g"
  '(:ignore t :wk "goto")
  "gd"
  'lsp-find-definition
  "gD"
  'lsp-find-declaration
  "gi"
  'lsp-find-implementation
  "gt"
  'lsp-find-type-definition
  "gr"
  'lsp-find-references
  "gb"
  'xref-pop-marker-stack
  "gp"
  'lsp-ui-peek-find-definitions
  "gP"
  'lsp-ui-peek-find-references

  ;; Help
  "h"
  '(:ignore t :wk "help")
  "hh"
  'lsp-describe-thing-at-point
  "hd"
  'lsp-ui-doc-show
  "hs"
  'lsp-signature-activate

  ;; Refactor
  "r"
  '(:ignore t :wk "refactor")
  "rr"
  'lsp-rename
  "ra"
  'lsp-execute-code-action
  "rf"
  'lsp-format-buffer
  "rF"
  'lsp-format-region

  ;; Workspace
  "w"
  '(:ignore t :wk "workspace")
  "wr"
  'lsp-workspace-restart
  "ws"
  'lsp-workspace-shutdown

  ;; Errors
  "e"
  '(:ignore t :wk "errors")
  "el"
  'lsp-ui-flycheck-list
  "en"
  'flycheck-next-error
  "ep"
  'flycheck-previous-error
  "ee"
  'flycheck-list-errors

  ;; Debug
  "d"
  '(:ignore t :wk "debug")
  "dd"
  'dap-debug
  "db"
  'dap-breakpoint-toggle
  "dB"
  'dap-breakpoint-delete-all
  "dc"
  'dap-continue
  "dn"
  'dap-next
  "di"
  'dap-step-in
  "do"
  'dap-step-out
  "dr"
  'dap-debug-restart
  "dq"
  'dap-disconnect

  ;; Compile
  "c"
  '(:ignore t :wk "compile")
  "cc"
  'compile
  "cr"
  'recompile
  "ck"
  'kill-compilation)

  :config
  (setq c-default-style '((c-mode . "linux")
                          (java-mode . "java")
                          (awk-mode . "awk")
                          (other . "k&r")))

  (defun my/c-mode-linux-kernel-style ()
    "Set up Linux kernel coding style per Documentation/process/coding-style.rst."
    (when (derived-mode-p 'c-mode)
      ;; Indentation: hard tabs, 8-wide
      (setq c-basic-offset 8
            tab-width 8
            indent-tabs-mode t)

      ;; Enforce kernel brace/indent rules
      (c-set-offset 'substatement-open 0)   ; braces on same column as control
      (c-set-offset 'statement-case-open 0) ; case braces not indented
      (c-set-offset 'case-label '+)         ; case labels indented one level
      (c-set-offset 'arglist-intro '+)      ; continued function args
      (c-set-offset 'arglist-cont-nonempty '+)
      (c-set-offset 'arglist-close 0)       ; closing paren at column of open
      (c-set-offset 'inextern-lang 0)       ; no indent inside extern "C"
      (c-set-offset 'label 1)              ; goto labels nearly at column 0
      (c-set-offset 'cpp-macro 0)           ; preprocessor at column 0

      ;; 80-column rule
      (setq fill-column 80)
      (display-fill-column-indicator-mode 1)

      ;; Trailing whitespace visibility
      (setq show-trailing-whitespace t)

      ;; Don't indent inside namespaces (for any C-adjacent code)
      (c-set-offset 'innamespace 0)))

  (add-hook 'c-mode-hook #'my/c-mode-linux-kernel-style))

(use-package
 cmake-mode
 :mode
 (("CMakeLists\\.txt\\'" . cmake-mode) ("\\.cmake\\'" . cmake-mode)))

(use-package
 ccls
 :defer t
 :custom
 (ccls-executable "ccls")
 (ccls-sem-highlight-method 'font-lock))

(use-package modern-cpp-font-lock :hook (c++-mode . modern-c++-font-lock-mode))


;; ============================================================================
;; Language: Poke
;; ============================================================================

(use-package poke-mode)

;; ============================================================================
;; Language: Rust
;; ============================================================================

(use-package
 rustic
 :mode ("\\.rs\\'" . rustic-mode)
 :general
 (my-local-leader
  :keymaps
  'rustic-mode-map
  "'"
  'rustic-repl

  ;; Goto
  "g"
  '(:ignore t :wk "goto")
  "gd"
  'lsp-find-definition
  "gD"
  'lsp-find-declaration
  "gi"
  'lsp-find-implementation
  "gt"
  'lsp-find-type-definition
  "gr"
  'lsp-find-references
  "gb"
  'xref-pop-marker-stack

  ;; Help
  "h"
  '(:ignore t :wk "help")
  "hh"
  'lsp-describe-thing-at-point
  "hd"
  'lsp-ui-doc-show

  ;; Refactor
  "r"
  '(:ignore t :wk "refactor")
  "rr"
  'lsp-rename
  "ra"
  'lsp-execute-code-action
  "rf"
  'rustic-format-buffer

  ;; Cargo
  "c"
  '(:ignore t :wk "cargo")
  "cc"
  'rustic-cargo-build
  "cC"
  'rustic-cargo-clean
  "ck"
  'rustic-cargo-check
  "cr"
  'rustic-cargo-run
  "ct"
  'rustic-cargo-test
  "cd"
  'rustic-cargo-doc
  "cf"
  'rustic-cargo-fmt
  "cl"
  'rustic-cargo-clippy

  ;; Test
  "t"
  '(:ignore t :wk "test")
  "tt"
  'rustic-cargo-test
  "ta"
  'rustic-cargo-test-all
  "tc"
  'rustic-cargo-current-test

  ;; Debug
  "d"
  '(:ignore t :wk "debug")
  "dd"
  'dap-debug
  "db"
  'dap-breakpoint-toggle
  "dc"
  'dap-continue
  "dn"
  'dap-next
  "di"
  'dap-step-in
  "do"
  'dap-step-out

  ;; Macro
  "m"
  '(:ignore t :wk "macro")
  "mm"
  'rustic-macro-expand
  "mM"
  'rustic-macro-expand-all)

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

(use-package
 ruby-mode
 :straight nil
 :mode "\\.rb\\'"
 :general
 (my-local-leader
  :keymaps
  'ruby-mode-map
  "'"
  'inf-ruby

  ;; Goto (LSP)
  "g"
  '(:ignore t :wk "goto")
  "gd"
  'lsp-find-definition
  "gD"
  'lsp-find-declaration
  "gi"
  'lsp-find-implementation
  "gt"
  'lsp-find-type-definition
  "gr"
  'lsp-find-references
  "gb"
  'xref-pop-marker-stack

  ;; Help (LSP)
  "h"
  '(:ignore t :wk "help")
  "hh"
  'lsp-describe-thing-at-point
  "hd"
  'lsp-ui-doc-show
  "hs"
  'lsp-signature-activate

  ;; Eval
  "e"
  '(:ignore t :wk "eval")
  "eb"
  'ruby-send-buffer
  "er"
  'ruby-send-region
  "el"
  'ruby-send-line
  "ed"
  'ruby-send-definition

  ;; REPL
  "r"
  '(:ignore t :wk "repl")
  "rr"
  'ruby-send-region
  "rb"
  'ruby-send-buffer
  "rs"
  'inf-ruby

  ;; Refactor (LSP)
  "R"
  '(:ignore t :wk "refactor")
  "Rr"
  'lsp-rename
  "Ra"
  'lsp-execute-code-action
  "Rf"
  'lsp-format-buffer
  "RF"
  'lsp-format-region

  ;; Test
  "t"
  '(:ignore t :wk "test")
  "tt"
  'ruby-test-run-at-point
  "ta"
  'ruby-test-run

  ;; Workspace
  "w"
  '(:ignore t :wk "workspace")
  "wr"
  'lsp-workspace-restart
  "ws"
  'lsp-workspace-shutdown)

 :config (setq ruby-insert-encoding-magic-comment nil))

;; Robe - commented out in favor of LSP/Solargraph
;; (use-package robe
;;   :hook (ruby-mode . robe-mode)
;;   :config
;;   (eval-after-load 'company
;;     '(push 'company-robe company-backends)))

(use-package inf-ruby :hook (ruby-mode . inf-ruby-minor-mode))

(use-package
 rbenv
 :hook (ruby-mode . rbenv-use-corresponding)
 :init (setq rbenv-show-active-ruby-in-modeline nil)
 :config (global-rbenv-mode))

;; ============================================================================
;; Language: TypeScript
;; ============================================================================

(use-package
 typescript-mode
 :mode "\\.ts\\'"
 :hook (typescript-mode . lsp-deferred)
 :custom (typescript-indent-level 2))

(use-package
 tsx-ts-mode
 :straight nil
 :mode "\\.tsx\\'"
 :hook (tsx-ts-mode . lsp-deferred))

(use-package
 web-mode
 :mode ("\\.tsx\\'" . web-mode)
 :hook (web-mode . lsp-deferred)
 :custom
 (web-mode-markup-indent-offset 2)
 (web-mode-code-indent-offset 2)
 (web-mode-css-indent-offset 2)
 :config
 ;; Use TypeScript LSP for TSX files in web-mode
 (add-to-list 'lsp-language-id-configuration '(web-mode . "typescriptreact")))

;; Local leader keybindings for TypeScript
(with-eval-after-load 'general
  (my-local-leader
   :keymaps '(typescript-mode-map web-mode-map)

   ;; Goto
   "g"
   '(:ignore t :wk "goto")
   "gd"
   'lsp-find-definition
   "gD"
   'lsp-find-declaration
   "gi"
   'lsp-find-implementation
   "gt"
   'lsp-find-type-definition
   "gr"
   'lsp-find-references
   "gb"
   'xref-pop-marker-stack
   "gp"
   'lsp-ui-peek-find-definitions
   "gP"
   'lsp-ui-peek-find-references

   ;; Help
   "h"
   '(:ignore t :wk "help")
   "hh"
   'lsp-describe-thing-at-point
   "hd"
   'lsp-ui-doc-show
   "hs"
   'lsp-signature-activate

   ;; Refactor
   "r"
   '(:ignore t :wk "refactor")
   "rr"
   'lsp-rename
   "ra"
   'lsp-execute-code-action
   "rf"
   'lsp-format-buffer
   "rF"
   'lsp-format-region
   "ro"
   'lsp-organize-imports

   ;; Workspace
   "w"
   '(:ignore t :wk "workspace")
   "wr"
   'lsp-workspace-restart
   "ws"
   'lsp-workspace-shutdown

   ;; Errors
   "e"
   '(:ignore t :wk "errors")
   "el"
   'lsp-ui-flycheck-list
   "en"
   'flycheck-next-error
   "ep"
   'flycheck-previous-error
   "ee"
   'flycheck-list-errors

   ;; Import/Organize
   "i"
   '(:ignore t :wk "import")
   "io"
   'lsp-organize-imports
   "ia"
   'lsp-execute-code-action))

;; ============================================================================
;; Additional Packages
;; ============================================================================

(use-package
 which-key
 :init (which-key-mode)
 :custom
 (which-key-idle-delay 0.5)
 (which-key-sort-order 'which-key-key-order-alpha))

(use-package ripgrep :defer t :commands (ripgrep-regexp projectile-ripgrep))

(use-package deadgrep :defer t :commands deadgrep)

(use-package
 wgrep
 :defer t
 :custom
 (wgrep-auto-save-buffer t)
 (wgrep-change-readonly-file t))

(use-package sudo-edit :defer t)

(use-package
 dumb-jump
 :defer t
 :config
 (setq dumb-jump-prefer-searcher 'rg)
 (add-hook 'xref-backend-functions #'dumb-jump-xref-activate))

;; ============================================================================
;; Git Integration
;; ============================================================================

(use-package
 magit
 :defer t
 :custom
 (magit-display-buffer-function
  #'magit-display-buffer-same-window-except-diff-v1)
 (magit-diff-refine-hunk 'all))

(use-package git-timemachine :defer t)

(use-package
 git-gutter
 :hook (prog-mode . git-gutter-mode)
 :custom (git-gutter:update-interval 0.5))

(use-package
 git-gutter-fringe
 :after git-gutter
 :config
 (define-fringe-bitmap 'git-gutter-fr:added [224] nil nil '(center repeated))
 (define-fringe-bitmap 'git-gutter-fr:modified [224] nil nil '(center repeated))
 (define-fringe-bitmap 'git-gutter-fr:deleted [128 192 224 240]
   nil
   nil
   'bottom))

(use-package
 blamer
 :defer t
 :custom
 (blamer-idle-time 0.5)
 (blamer-min-offset 40))

;; ============================================================================
;; Additional Utilities
;; ==========================================================t=================

(use-package
 writeroom-mode
 :defer t
 :custom
 (writeroom-width 100)
 (writeroom-mode-line t))

(use-package restart-emacs :defer t)

(use-package yaml-mode :defer t)

;; ============================================================================
;; Theme
;; ============================================================================

(add-to-list
 'custom-theme-load-path (expand-file-name "themes" user-emacs-directory))
(load-theme 'jemarch t)

;;(use-package leuven-theme
;;  :config
;;  (load-theme 'leuven-dark t))


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
    (compile
     (format "gcc -Wall -g %s -o %s && %s" file executable executable))))

(defun my/copy-file-path ()
  "Copy the current buffer's file path to the kill ring."
  (interactive)
  (if buffer-file-name
      (progn
        (kill-new buffer-file-name)
        (message "Copied: %s" buffer-file-name))
    (message "Buffer is not visiting a file")))

(defun my/rename-current-file ()
  "Rename the current file and buffer."
  (interactive)
  (let ((filename (buffer-file-name)))
    (unless filename
      (user-error "Buffer is not visiting a file"))
    (let ((new-name (read-file-name "Rename to: " (file-name-directory filename))))
      (rename-file filename new-name 1)
      (set-visited-file-name new-name t t)
      (message "Renamed to %s" new-name))))

(defun my/delete-current-file ()
  "Delete the current file and kill its buffer."
  (interactive)
  (let ((filename (buffer-file-name)))
    (unless filename
      (user-error "Buffer is not visiting a file"))
    (when (yes-or-no-p (format "Really delete %s? " filename))
      (delete-file filename t)
      (kill-buffer)
      (message "Deleted %s" filename))))

(defun my/copy-file-name ()
  "Copy the current buffer's filename (without directory) to the kill ring."
  (interactive)
  (if buffer-file-name
      (let ((name (file-name-nondirectory buffer-file-name)))
        (kill-new name)
        (message "Copied: %s" name))
    (message "Buffer is not visiting a file")))

(defun my/new-empty-buffer ()
  "Create a new empty buffer."
  (interactive)
  (let ((buf (generate-new-buffer "untitled")))
    (switch-to-buffer buf)
    (funcall initial-major-mode)))

(defun my/sudo-find-file ()
  "Open a file with sudo via TRAMP."
  (interactive)
  (find-file (concat "/sudo::" (read-file-name "Find file (sudo): "))))

(defun my/search-symbol-at-point ()
  "Search for the symbol at point in the current project using ripgrep."
  (interactive)
  (consult-ripgrep nil (thing-at-point 'symbol t)))

(defun my/yank-buffer-contents ()
  "Copy the entire buffer contents to the kill ring."
  (interactive)
  (kill-new (buffer-substring-no-properties (point-min) (point-max)))
  (message "Buffer contents copied to kill ring"))

(defun my/open-init-file ()
  "Open the Emacs init file."
  (interactive)
  (find-file user-init-file))

;; ============================================================================
;; Final Setup
;; ============================================================================

;; GUD configuration
(setq
 gdb-many-windows t
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
