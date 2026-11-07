;;; init.el --- Emacs configuration -*- lexical-binding: t -*-
;;; Commentary:
;; Evil + general leader keys, vertico/consult completion, projectile,
;; lsp-mode/dap-mode, magit.  One tool per job:
;;   search: consult-ripgrep (+ embark-export/wgrep to edit results)
;;   files:  treemacs, dired       project:  projectile
;;   git:    magit, diff-hl        format:   apheleia (`my/format-buffer')
;;   debug:  dap-mode              terminal: vterm
;;
;; Keys: SPC = global leader, `,' = local leader.  Every LSP buffer gets the
;; same local g/h/w/d groups (bound on `lsp-mode-map'); language sections only
;; add what is specific to them: ' REPL, e eval, t test, x run, c build,
;; m macro, R restart REPL, q quit REPL.

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

;; Keep transient up-to-date (it's a built-in but magit wants the latest)
(use-package transient)

;; ============================================================================
;; Core Settings
;; ============================================================================

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror 'nomessage)

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
 backup-directory-alist `(("." . ,(expand-file-name "backups" user-emacs-directory)))
 backup-by-copying t
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 version-control t
 auto-save-default nil
 global-auto-revert-non-file-buffers t)

;; Built-in modes
(electric-pair-mode 1)
(show-paren-mode 1)
(global-hl-line-mode 1)
(recentf-mode 1)
(savehist-mode 1)
(save-place-mode 1)
(winner-mode 1)
(global-auto-revert-mode 1)
(editorconfig-mode 1)
(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'prog-mode-hook #'hs-minor-mode) ; zc / zo / za folding

;; Minibuffer
(setq
 enable-recursive-minibuffers t
 minibuffer-prompt-properties '(read-only t cursor-intangible t face minibuffer-prompt))
(add-hook 'minibuffer-setup-hook #'cursor-intangible-mode)

;; Dired - macOS ls compatibility (must be set before dired loads)
(when (eq system-type 'darwin)
  (setq dired-use-ls-dired nil))

;; Compilation
(setq
 compilation-scroll-output 'first-error
 compilation-ask-about-save nil
 compilation-always-kill t)
(add-to-list 'display-buffer-alist
             '("\\*compilation\\*"
               (display-buffer-reuse-window display-buffer-at-bottom)
               (window-height . 0.3)))

(require 'ansi-color)
(add-hook 'compilation-filter-hook #'ansi-color-compilation-filter)

(defun my/strip-terminal-control-sequences ()
  "Strip terminal control sequences that compilation buffers cannot render."
  (let ((inhibit-read-only t))
    (save-excursion
      (goto-char compilation-filter-start)
      (while (re-search-forward
              (rx (or
                   ;; Synchronized output, cursor visibility, etc.
                   (seq "\e[?" (+ digit) (any "hlHLsu"))
                   ;; Alternate character set switches
                   (seq "\e(" (any "0B"))
                   ;; Reverse line feed
                   "\eM"
                   ;; Erase display/line
                   (seq "\e[" (* digit) (any "JK"))
                   ;; OSC sequences (e.g. \e]9;...)
                   (seq "\e]" (* (not "\\")) "\e\\")
                   ;; Carriage return (progress bar redraws)
                   "\r"))
              nil t)
        (replace-match "")))))
(add-hook 'compilation-filter-hook #'my/strip-terminal-control-sequences)

;; Tree-sitter grammars (only TypeScript/TSX use them).  Install once with
;; M-x my/treesit-install-grammars.  v0.20.3 matches Emacs 30's ts modes.
(setq treesit-language-source-alist
      '((typescript "https://github.com/tree-sitter/tree-sitter-typescript" "v0.20.3" "typescript/src")
        (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "v0.20.3" "tsx/src")))

(defun my/treesit-install-grammars ()
  "Install every grammar in `treesit-language-source-alist' that is missing."
  (interactive)
  (dolist (lang (mapcar #'car treesit-language-source-alist))
    (unless (treesit-language-available-p lang)
      (treesit-install-language-grammar lang))))

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
 (evil-set-initial-state 'messages-buffer-mode 'normal))

(use-package evil-collection :after evil :config (evil-collection-init))

(use-package evil-surround :after evil :config (global-evil-surround-mode 1))

;; gc{motion} comments, gcc comments the line.
(use-package evil-nerd-commenter :after evil) ; gc operator: see general section

;; "jf" typed quickly in insert state returns to normal state (also in vterm).
(defun my/jf-escape ()
  "Exit insert mode when 'jf' is typed quickly."
  (interactive)
  (let ((ch (read-char-exclusive nil nil 0.2)))
    (cond
     ((eq ch ?f) (evil-normal-state))
     (ch (my/insert-or-vterm-send "j")
         (push ch unread-command-events))
     (t (my/insert-or-vterm-send "j")))))

(defun my/insert-or-vterm-send (str)
  "Insert STR normally, or send it via vterm if in a vterm buffer."
  (if (derived-mode-p 'vterm-mode)
      (vterm-send-string str)
    (insert str)))

;; ============================================================================
;; General - Keybinding Framework
;; ============================================================================

(use-package
 general
 :demand t
 :config
 ;; Global leader (SPC in normal/visual, C-SPC everywhere)
 (general-create-definer
  my-leader
  :states '(normal visual insert emacs treemacs)
  :keymaps 'override
  :prefix "SPC"
  :global-prefix "C-SPC")

 ;; Local leader (comma in normal/visual, C-, in insert/emacs)
 (general-create-definer
  my-local-leader
  :states '(normal visual)
  :prefix ","
  :non-normal-prefix "C-,")

 (my-leader
  ;; Top level: the only keys that duplicate a group binding.
  "SPC" '(projectile-find-file :wk "find file in project")
  ","   '(consult-buffer :wk "switch buffer")
  "/"   '(consult-ripgrep :wk "search project")
  "TAB" '(evil-switch-to-windows-last-buffer :wk "last buffer")
  "*"   '(my/search-symbol-at-point :wk "search symbol")
  "'"   '(projectile-run-vterm :wk "project terminal")
  ":"   '(execute-extended-command :wk "M-x")
  ";"   '(eval-expression :wk "eval expression")
  "x"   '(scratch-buffer :wk "scratch")
  "u"   '(universal-argument :wk "universal arg")

  "b"  '(:ignore t :wk "buffers")
  "bd" '(kill-current-buffer :wk "kill")
  "bi" '(ibuffer :wk "ibuffer")
  "bn" '(next-buffer :wk "next")
  "bp" '(previous-buffer :wk "previous")
  "br" '(revert-buffer :wk "revert")
  "bS" '(save-some-buffers :wk "save all")
  "bN" '(my/new-empty-buffer :wk "new empty")
  "bY" '(my/yank-buffer-contents :wk "yank contents")

  "c"  '(:ignore t :wk "code/build")
  "ca" '(lsp-execute-code-action :wk "code action")
  "cr" '(lsp-rename :wk "rename")
  "co" '(lsp-organize-imports :wk "organize imports")
  "cf" '(my/format-buffer :wk "format buffer")
  "ce" '(flycheck-list-errors :wk "list errors")
  "cn" '(next-error :wk "next error")
  "cp" '(previous-error :wk "previous error")
  "cc" '(projectile-compile-project :wk "compile")
  "cC" '(recompile :wk "recompile")
  "ck" '(kill-compilation :wk "kill compilation")
  "cb" '(my/show-compilation :wk "compilation buffer")
  "ct" '(projectile-test-project :wk "test")
  "cx" '(projectile-run-project :wk "run")

  "f"  '(:ignore t :wk "files")
  "ff" '(find-file :wk "find file")
  "fr" '(consult-recent-file :wk "recent")
  "fs" '(save-buffer :wk "save")
  "fS" '(write-file :wk "save as")
  "fR" '(my/rename-current-file :wk "rename")
  "fX" '(my/delete-current-file :wk "delete")
  "fC" '(copy-file :wk "copy")
  "fy" '(my/copy-file-path :wk "copy path")
  "fn" '(my/copy-file-name :wk "copy name")
  "fE" '(my/sudo-edit :wk "sudo edit")
  "fP" '(my/open-init-file :wk "config")
  "fK" '(my/open-glove80-keymap :wk "glove80 keymap")

  "g"   '(:ignore t :wk "git")
  "gg"  '(magit-status :wk "status")
  "gb"  '(magit-blame :wk "blame")
  "gd"  '(magit-diff :wk "diff")
  "gf"  '(magit-file-dispatch :wk "file dispatch")
  "gl"  '(magit-log :wk "log")
  "gL"  '(magit-log-buffer-file :wk "log file")
  "gG"  '(magit-dispatch :wk "dispatch")
  "gh"  '(:ignore t :wk "hunk")
  "ghn" '(diff-hl-next-hunk :wk "next")
  "ghp" '(diff-hl-previous-hunk :wk "previous")
  "ghs" '(diff-hl-stage-dwim :wk "stage")
  "ghr" '(diff-hl-revert-hunk :wk "revert")
  "ghv" '(diff-hl-show-hunk :wk "view")

  "h"  '(:ignore t :wk "help")
  "ha" '(apropos :wk "apropos")
  "hb" '(embark-bindings :wk "bindings")
  "hf" '(describe-function :wk "function")
  "hF" '(describe-face :wk "face")
  "hi" '(info :wk "info")
  "hk" '(describe-key :wk "key")
  "hK" '(describe-keymap :wk "keymap")
  "hl" '(view-lossage :wk "recent keys")
  "hm" '(describe-mode :wk "mode")
  "ho" '(describe-symbol :wk "symbol")
  "hp" '(describe-package :wk "package")
  "hv" '(describe-variable :wk "variable")
  "hw" '(where-is :wk "where is")

  "j"  '(:ignore t :wk "jump")
  "jj" '(evil-avy-goto-char-timer :wk "avy char")
  "jl" '(evil-avy-goto-line :wk "avy line")
  "ji" '(consult-imenu :wk "imenu")
  "jI" '(consult-imenu-multi :wk "imenu (project)")
  "jo" '(consult-outline :wk "outline")
  "jm" '(consult-mark :wk "marks")
  "jb" '(consult-bookmark :wk "bookmark (jump/set)")

  "n"  '(:ignore t :wk "notes")
  "na" '(org-agenda :wk "agenda")
  "nc" '(org-capture :wk "capture")
  "nl" '(org-store-link :wk "store link")

  "o"  '(:ignore t :wk "open")
  "op" '(treemacs :wk "treemacs")
  "oP" '(treemacs-select-window :wk "focus treemacs")
  "ot" '(vterm :wk "terminal")

  "p"  '(:ignore t :wk "project")
  "pp" '(projectile-switch-project :wk "switch")
  "pf" '(projectile-find-file :wk "find file")
  "pb" '(consult-project-buffer :wk "buffers")
  "pd" '(projectile-dired :wk "dired root")
  "po" '(projectile-find-other-file :wk "other file")
  "pr" '(projectile-recentf :wk "recent files")
  "pR" '(projectile-replace :wk "replace")
  "pk" '(projectile-kill-buffers :wk "kill buffers")
  "pa" '(projectile-add-known-project :wk "add project")

  "q"  '(:ignore t :wk "quit")
  "qq" '(save-buffers-kill-terminal :wk "quit")
  "qQ" '(kill-emacs :wk "kill emacs")
  "qr" '(restart-emacs :wk "restart")
  "qf" '(delete-frame :wk "delete frame")

  "s"  '(:ignore t :wk "search")
  "ss" '(consult-line :wk "buffer")
  "sS" '(consult-line-multi :wk "all buffers")
  "sp" '(consult-ripgrep :wk "project")
  "sr" '(vertico-repeat :wk "repeat last search")

  "t"  '(:ignore t :wk "toggle")
  "tc" '(display-fill-column-indicator-mode :wk "fill column")
  "tf" '(toggle-frame-fullscreen :wk "fullscreen")
  "tl" '(display-line-numbers-mode :wk "line numbers")
  "tr" '(read-only-mode :wk "read only")
  "ts" '(flyspell-mode :wk "flyspell")
  "tt" '(consult-theme :wk "theme")
  "tT" '(toggle-truncate-lines :wk "truncate lines")
  "tv" '(visual-line-mode :wk "visual line")
  "tw" '(whitespace-mode :wk "whitespace")

  "w"  '(:ignore t :wk "windows")
  "w=" '(balance-windows :wk "balance")
  "wd" '(delete-window :wk "delete")
  "wD" '(kill-buffer-and-window :wk "kill buffer & window")
  "wh" '(evil-window-left :wk "left")
  "wj" '(evil-window-down :wk "down")
  "wk" '(evil-window-up :wk "up")
  "wl" '(evil-window-right :wk "right")
  "wH" '(evil-window-move-far-left :wk "move left")
  "wJ" '(evil-window-move-very-bottom :wk "move down")
  "wK" '(evil-window-move-very-top :wk "move up")
  "wL" '(evil-window-move-far-right :wk "move right")
  "wm" '(delete-other-windows :wk "maximize")
  "wr" '(evil-window-rotate-downwards :wk "rotate")
  "ws" '(split-window-below :wk "split below")
  "wv" '(split-window-right :wk "split right")
  "ww" '(other-window :wk "other")
  "wu" '(winner-undo :wk "winner undo")
  "wU" '(winner-redo :wk "winner redo"))

 (general-define-key :states 'insert "C-g" 'evil-normal-state "j" 'my/jf-escape)
 ;; gc{motion} comments, gcc comments the line.
 (general-define-key :states '(normal visual) "gc" 'evilnc-comment-operator))

;; ============================================================================
;; System Integration
;; ============================================================================

(use-package
 exec-path-from-shell
 :config
 (when (or (daemonp) (memq window-system '(mac ns x)))
   (exec-path-from-shell-initialize)))

(use-package vterm :defer t)

;; ============================================================================
;; Completion Framework
;; ============================================================================

(use-package
 vertico
 :init (vertico-mode)
 :custom
 (vertico-count 20)
 (vertico-cycle t)
 :config
 (require 'vertico-directory)
 (require 'vertico-repeat)
 ;; Backspace/M-DEL in file prompts delete a whole path component.
 (define-key vertico-map (kbd "DEL") #'vertico-directory-delete-char)
 (define-key vertico-map (kbd "M-DEL") #'vertico-directory-delete-word)
 (add-hook 'rfn-eshadow-update-overlay-hook #'vertico-directory-tidy)
 (add-hook 'minibuffer-setup-hook #'vertico-repeat-save))

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

;; Edit search results in place: SPC / ... C-. E (embark-export), then `i'.
(use-package
 wgrep
 :defer t
 :custom
 (wgrep-auto-save-buffer t)
 (wgrep-change-readonly-file t))

;; ============================================================================
;; Navigation
;; ============================================================================

;; `s' jumps with avy; `f'/`t' and `;'/`,' keep their vim meaning
;; (`,' in normal state is the local leader, so use `;' to repeat f/t).
(use-package
 avy
 :general (:states '(normal motion) "s" 'evil-avy-goto-char-timer)
 :custom
 (avy-all-windows nil)
 (avy-background t))

(use-package
 projectile
 :init (projectile-mode +1)
 :custom
 (projectile-completion-system 'default)
 (projectile-enable-caching t)
 (projectile-project-root-files
  '("compile_commands.json" "Makefile" "CMakeLists.txt" ".git")))

(use-package
 treemacs
 :defer t
 :config
 (treemacs-follow-mode t)
 (treemacs-filewatch-mode t))

(use-package
 treemacs-evil
 :after (treemacs evil)
 :config
 ;; dap-ui buffers inherit treemacs-mode, whose evil state binds SPC and
 ;; `w' (treemacs-set-width); free them so leader keys work there too.
 (evil-define-key 'treemacs evil-treemacs-state-map (kbd "SPC") nil)
 (define-key evil-treemacs-state-map (kbd "w") nil)
 (define-key evil-treemacs-state-map (kbd "W") #'treemacs-set-width))

(use-package treemacs-projectile :after (treemacs projectile))

;; Fallback go-to-definition (via xref) where no language server runs.
(use-package
 dumb-jump
 :init (add-hook 'xref-backend-functions #'dumb-jump-xref-activate)
 :custom (dumb-jump-prefer-searcher 'rg))

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
 (company-show-quick-access t))

(use-package
 flycheck
 :hook
 ((after-init . global-flycheck-mode)
  (ruby-mode . (lambda () (flycheck-mode -1))))
 :custom
 (flycheck-check-syntax-automatically '(save mode-enabled))
 (flycheck-display-errors-delay 0.3))

(use-package yasnippet :config (yas-global-mode 1))

;; Formatting: apheleia for everything.  Format-on-save only where the
;; language's formatter is the norm; elsewhere use SPC c f.
(use-package
 apheleia
 :hook ((python-mode go-mode rustic-mode zig-mode) . apheleia-mode)
 :config
 (setf (alist-get 'python-mode apheleia-mode-alist) 'ruff
       (alist-get 'python-ts-mode apheleia-mode-alist) 'ruff
       (alist-get 'go-mode apheleia-mode-alist) 'goimports
       (alist-get 'ruby-mode apheleia-mode-alist) 'rubocop))

(defun my/format-buffer ()
  "Format the buffer with apheleia, else the language server, else indent."
  (interactive)
  (require 'apheleia)
  (let* ((formatter (car (ensure-list (apheleia--get-formatters))))
         (program (car-safe (alist-get formatter apheleia-formatters))))
    (cond
     ((and formatter (or (not (stringp program)) (executable-find program)))
      (apheleia-format-buffer formatter))
     ((bound-and-true-p lsp-mode) (lsp-format-buffer))
     (t (indent-region (point-min) (point-max))))))

(defun my/show-compilation ()
  "Show the *compilation* buffer."
  (interactive)
  (pop-to-buffer (or (get-buffer "*compilation*")
                     (user-error "No compilation buffer"))))

(use-package
 lsp-mode
 :after yasnippet
 :commands (lsp lsp-deferred)
 :hook
 ((c-mode . my/c-maybe-lsp)
  (c++-mode . lsp-deferred)
  (rustic-mode . lsp-deferred)
  (go-mode . lsp-deferred)
  (ruby-mode . lsp-deferred)
  (sql-mode . lsp-deferred)
  (clojure-mode . lsp-deferred)
  (clojurec-mode . lsp-deferred)
  (clojurescript-mode . lsp-deferred)
  (typescript-ts-mode . lsp-deferred)
  (tsx-ts-mode . lsp-deferred)
  (lsp-mode . lsp-enable-which-key-integration))
 :custom
 (lsp-keymap-prefix "C-c l")
 (lsp-idle-delay 0.500)
 (lsp-log-io nil)
 (lsp-completion-provider :capf)
 (lsp-headerline-breadcrumb-enable t)
 (lsp-modeline-diagnostics-enable t)
 (lsp-signature-auto-activate t)
 (lsp-auto-guess-root t)
 (lsp-enable-suggest-server-download nil)
 (lsp-clients-clangd-args
  '("--header-insertion=never"
    "--clang-tidy"
    "--completion-style=detailed"
    "--suggest-missing-includes"
    "--cross-file-rename"))
 :config
 ;; Local leader shared by every LSP buffer (debug keys: see dap-mode).
 (my-local-leader
  :keymaps 'lsp-mode-map
  "g"  '(:ignore t :wk "goto")
  "gd" '(lsp-find-definition :wk "definition")
  "gD" '(lsp-find-declaration :wk "declaration")
  "gi" '(lsp-find-implementation :wk "implementation")
  "gt" '(lsp-find-type-definition :wk "type definition")
  "gr" '(lsp-find-references :wk "references")
  "h"  '(:ignore t :wk "help")
  "hh" '(lsp-describe-thing-at-point :wk "describe")
  "hd" '(lsp-ui-doc-show :wk "doc popup")
  "hs" '(lsp-signature-activate :wk "signature")
  "w"  '(:ignore t :wk "workspace")
  "wr" '(lsp-workspace-restart :wk "restart")
  "ws" '(lsp-workspace-shutdown :wk "shutdown"))
 ;; lsp-lua only accepts a server downloaded into `lsp-server-install-dir'
 ;; (it checks for main.lua there); use the Homebrew wrapper on PATH instead.
 (with-eval-after-load 'lsp-lua
   (defun lsp-clients-lua-language-server-test ()
     (executable-find "lua-language-server"))
   (setq lsp-clients-lua-language-server-command '("lua-language-server"))
   ;; Defaults for projects without a .luarc.json (which takes precedence).
   ;; Most Lua here targets LÖVE, which runs LuaJIT.
   (setq lsp-lua-runtime-version "LuaJIT"
         lsp-lua-diagnostics-globals ["love"]
         lsp-lua-hint-enable t)))

(use-package
 lsp-ui
 :after lsp-mode
 :custom
 (lsp-ui-doc-enable t)
 (lsp-ui-doc-position 'at-point)
 (lsp-ui-doc-delay 0.5)
 (lsp-ui-sideline-enable t)
 (lsp-ui-sideline-show-diagnostics t)
 (lsp-ui-peek-enable nil))

;; Debug keys for every LSP buffer, plus C/C++ (which may run without LSP).
;; Not on dap-mode's own map: dap-mode is global and would shadow elisp's
;; edebug keys.
(my-local-leader
 :keymaps '(lsp-mode-map c-mode-map c++-mode-map)
 "d"  '(:ignore t :wk "debug")
 "dd" '(dap-debug :wk "debug (pick template)")
 "db" '(dap-breakpoint-toggle :wk "toggle breakpoint")
 "dB" '(dap-breakpoint-delete-all :wk "delete all breakpoints")
 "dc" '(dap-continue :wk "continue")
 "dn" '(dap-next :wk "next")
 "di" '(dap-step-in :wk "step in")
 "do" '(dap-step-out :wk "step out")
 "dr" '(dap-debug-restart :wk "restart")
 "dq" '(dap-disconnect :wk "disconnect")
 "de" '(dap-eval :wk "eval")
 "dE" '(dap-eval-region :wk "eval region")
 "dh" '(dap-hydra :wk "hydra"))

;; C/C++ debugging: one template, native debugger per platform.  Both speak
;; DAP themselves and take the same launch arguments (program/args/cwd).
;;   Linux: gdb -i dap   (GDB 14+, built with Python)
;;   macOS: lldb-dap     (Xcode command-line tools; gdb doesn't run on
;;                        Apple Silicon)
(defvar my/c-debugger (if (eq system-type 'darwin) 'lldb 'gdb)
  "Debugger for C/C++: `gdb' or `lldb'.")

(defun my/c-debug-adapter ()
  "Return the command line that starts the DAP server for `my/c-debugger'."
  (pcase my/c-debugger
    ('gdb
     (let* ((out (and (executable-find "gdb")
                      (shell-command-to-string "gdb --version")))
            (major (and out (string-match "\\([0-9]+\\)\\.[0-9]+" out)
                        (string-to-number (match-string 1 out)))))
       (unless (and major (>= major 14))
         (user-error "gdb 14+ is needed for DAP (found: %s)"
                     (if out (car (split-string out "\n")) "no gdb")))
       '("gdb" "-i" "dap")))
    ('lldb
     (let ((path (string-trim (shell-command-to-string "xcrun -f lldb-dap 2>/dev/null"))))
       (unless (file-executable-p path)
         (user-error "lldb-dap not found; install Xcode command-line tools"))
       (list path)))))

(defvar my/c-debug-executable nil
  "Executable chosen for the last C/C++ debug session.")

(defun my/c-debug-executable ()
  "Ask for the compiled executable to debug, defaulting to the last one."
  (setq my/c-debug-executable
        (expand-file-name
         (read-file-name "Executable to debug: "
                         (or (and my/c-debug-executable
                                  (file-name-directory my/c-debug-executable))
                             (projectile-project-root)
                             default-directory)
                         my/c-debug-executable t nil
                         (lambda (f) (or (file-directory-p f) (file-executable-p f)))))))

(defun my/dap-c--populate (conf)
  "Fill CONF for a native C/C++ debug session."
  (dap--put-if-absent conf :dap-server-path (my/c-debug-adapter))
  (dap--put-if-absent conf :program (my/c-debug-executable))
  (dap--put-if-absent conf :cwd (or (projectile-project-root) default-directory))
  (dap--put-if-absent conf :args [])
  conf)

(use-package
 dap-mode
 :defer t
 :commands
 (dap-breakpoint-toggle dap-breakpoint-delete-all dap-continue dap-next
  dap-step-in dap-step-out dap-debug-restart dap-disconnect dap-eval
  dap-eval-region)
 :init (with-eval-after-load 'lsp-mode (require 'dap-mode))
 :config
 (dap-mode 1)
 (dap-ui-mode 1)
 (dap-tooltip-mode 1)
 (dap-register-debug-provider "c-native" #'my/dap-c--populate)
 (dap-register-debug-template
  "C/C++ :: debug executable"
  (list :type "c-native" :request "launch" :name "C/C++"))
 (require 'dap-python)
 (setq dap-python-debugger 'debugpy)
 (setq dap-python-executable "python3")
 ;; Set dap-python-executable to .venv python before each debug session
 (advice-add 'dap-python--populate-start-file-args :before
             (lambda (&rest _)
               (let ((root (locate-dominating-file default-directory ".venv")))
                 (when root
                   (setq dap-python-executable
                         (expand-file-name ".venv/bin/python" root))))))
 (dap-register-debug-template
  "Python :: Run Current File"
  (list :type "python"
        :args ""
        :request "launch"
        :name "Run Current File"))
 (require 'dap-dlv-go)
 (require 'dap-ruby)
 (dap-ruby-setup)
 (dap-register-debug-template
  "Ruby :: Run Current File"
  (list :type "Ruby"
        :request "launch"
        :name "Run Current File"))
 ;; Auto-show locals/breakpoints/repl on debug session start
 (setq dap-auto-configure-features
       '(sessions locals breakpoints expressions controls tooltip repl)))

;; ============================================================================
;; Language: Emacs Lisp
;; ============================================================================

(use-package
 emacs
 :straight nil
 :general
 (my-local-leader
  :keymaps 'emacs-lisp-mode-map
  "'"  '(ielm :wk "ielm")
  "e"  '(:ignore t :wk "eval")
  "eb" '(eval-buffer :wk "buffer")
  "ed" '(eval-defun :wk "defun")
  "ee" '(eval-last-sexp :wk "last sexp")
  "er" '(eval-region :wk "region")
  "el" '(load-library :wk "load library")
  "g"  '(:ignore t :wk "goto")
  "gf" '(find-function :wk "function")
  "gv" '(find-variable :wk "variable")
  "gl" '(find-library :wk "library")
  "d"  '(:ignore t :wk "edebug")
  "dd" '(edebug-defun :wk "instrument defun")
  "db" '(edebug-set-breakpoint :wk "set breakpoint")
  "dB" '(edebug-unset-breakpoint :wk "unset breakpoint")
  "m"  '(:ignore t :wk "macro")
  "mm" '(emacs-lisp-macroexpand :wk "expand at point")
  "mM" '(pp-macroexpand-last-sexp :wk "expand last sexp (pp)")
  "c"  '(:ignore t :wk "compile")
  "cb" '(byte-compile-file :wk "byte-compile file")
  "cB" '(byte-recompile-directory :wk "recompile directory")))

;; ============================================================================
;; Language: Clojure
;; ============================================================================

(use-package clojure-mode :defer t)

(use-package
 cider
 :after clojure-mode
 :general
 (my-local-leader
  :keymaps 'clojure-mode-map
  "'"  '(cider-jack-in :wk "jack in")
  "R"  '(cider-restart :wk "restart REPL")
  "q"  '(cider-quit :wk "quit REPL")
  "e"  '(:ignore t :wk "eval")
  "eb" '(cider-eval-buffer :wk "buffer")
  "ed" '(cider-eval-defun-at-point :wk "defun")
  "ee" '(cider-eval-last-sexp :wk "last sexp")
  "er" '(cider-eval-region :wk "region")
  "ep" '(cider-pprint-eval-last-sexp :wk "pprint last sexp")
  "h"  '(:ignore t :wk "help")
  "ha" '(cider-apropos :wk "apropos")
  "hj" '(cider-javadoc :wk "javadoc")
  "t"  '(:ignore t :wk "test")
  "tt" '(cider-test-run-test :wk "test at point")
  "tn" '(cider-test-run-ns-tests :wk "namespace")
  "ta" '(cider-test-run-project-tests :wk "project")))

;; ============================================================================
;; Language: Common Lisp
;; ============================================================================

(use-package
 sly
 :defer t
 :custom (inferior-lisp-program "sbcl")
 :general
 (my-local-leader
  :keymaps 'lisp-mode-map
  "'"  '(sly :wk "sly")
  "R"  '(sly-restart-inferior-lisp :wk "restart REPL")
  "q"  '(sly-quit-lisp :wk "quit REPL")
  "e"  '(:ignore t :wk "eval")
  "eb" '(sly-eval-buffer :wk "buffer")
  "ed" '(sly-eval-defun :wk "defun")
  "ee" '(sly-eval-last-expression :wk "last expression")
  "er" '(sly-eval-region :wk "region")
  "ep" '(sly-pprint-eval-last-expression :wk "pprint last expression")
  "g"  '(:ignore t :wk "goto")
  "gd" '(sly-edit-definition :wk "definition")
  "gb" '(sly-pop-find-definition-stack :wk "back")
  "gr" '(sly-who-references :wk "references")
  "h"  '(:ignore t :wk "help")
  "hd" '(sly-describe-symbol :wk "describe symbol")
  "ha" '(sly-apropos :wk "apropos")
  "hH" '(sly-hyperspec-lookup :wk "hyperspec")
  "c"  '(:ignore t :wk "compile")
  "cc" '(sly-compile-file :wk "file")
  "cC" '(sly-compile-and-load-file :wk "file and load")
  "cd" '(sly-compile-defun :wk "defun")
  "cr" '(sly-compile-region :wk "region")
  "s"  '(:ignore t :wk "stickers")
  "sb" '(sly-stickers-dwim :wk "sticker dwim")
  "sc" '(sly-stickers-clear-defun-stickers :wk "clear defun")
  "sC" '(sly-stickers-clear-buffer-stickers :wk "clear buffer")
  "t"  '(:ignore t :wk "trace")
  "tt" '(sly-toggle-trace-fdefinition :wk "toggle trace")
  "tu" '(sly-untrace-all :wk "untrace all")))

;; ============================================================================
;; Language: Fennel
;; ============================================================================

(use-package
 fennel-mode
 :mode "\\.fnl\\'"
 :general
 (my-local-leader
  :keymaps 'fennel-mode-map
  "'"  '(fennel-repl :wk "REPL")
  "e"  '(:ignore t :wk "eval")
  "ee" '(fennel-eval-last-sexp :wk "last sexp")
  "ed" '(fennel-eval-toplevel-form :wk "toplevel form")
  "er" '(fennel-eval-region :wk "region")
  "eb" '(fennel-reload :wk "reload module")
  "h"  '(:ignore t :wk "help")
  "hd" '(fennel-show-documentation :wk "documentation")
  "hv" '(fennel-show-variable-documentation :wk "variable documentation")
  "c"  '(fennel-view-compilation :wk "view compiled Lua")
  "m"  '(fennel-macroexpand :wk "macroexpand")))

;; ============================================================================
;; Language: C/C++
;; ============================================================================

(defun my/c-maybe-lsp ()
  "Start LSP for C only when a compilation database exists.
Without one (e.g. an unconfigured kernel tree) clangd is mostly noise;
dumb-jump still provides go-to-definition through xref."
  (when (locate-dominating-file default-directory "compile_commands.json")
    (lsp-deferred)))

(use-package
 cc-mode
 :straight nil
 :mode
 (("\\.c\\'" . c-mode)
  ("\\.h\\'" . c-mode)
  ("\\.cpp\\'" . c++-mode)
  ("\\.hpp\\'" . c++-mode))
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
     (c-set-offset 'label 1)               ; goto labels nearly at column 0
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

;; ============================================================================
;; Language: Python
;; ============================================================================

(use-package
 lsp-pyright
 :custom
 (lsp-pyright-langserver-command "basedpyright")
 (lsp-pyright-venv-path nil)
 :hook
 (python-mode
  .
  (lambda ()
    (require 'lsp-pyright)
    ;; Auto-detect .venv in project root (created by uv)
    (let ((venv (locate-dominating-file default-directory ".venv")))
      (when venv
        (setq-local lsp-pyright-venv-directory
                    (expand-file-name ".venv" venv))))
    (lsp-deferred))))

;; Flycheck checker for ruff
(with-eval-after-load 'flycheck
  (flycheck-define-checker python-ruff
    "A Python syntax and style checker using ruff."
    :command ("ruff" "check" "--output-format=concise" "--stdin-filename" source-original "-")
    :standard-input t
    :error-patterns
    ((warning line-start
              (file-name) ":" line ":" (optional column ":") " "
              (id (one-or-more (not (any " ")))) " "
              (message) line-end))
    :modes (python-mode python-ts-mode))
  (add-to-list 'flycheck-checkers 'python-ruff)
  ;; Disable default python checkers in favor of ruff
  (setq-default flycheck-disabled-checkers
                (append flycheck-disabled-checkers
                        '(python-flake8 python-pylint python-pycompile))))

(defun my/dap-python-run-with-args ()
  "Debug current Python file, prompting for CLI arguments."
  (interactive)
  (dap-debug
   (list :type "python"
         :args (read-string "Args: ")
         :cwd (file-name-directory (buffer-file-name))
         :program (buffer-file-name)
         :request "launch"
         :name "Run with Args")))

(my-local-leader
 :keymaps '(python-mode-map python-ts-mode-map)
 "da" '(my/dap-python-run-with-args :wk "debug with args"))

;; ============================================================================
;; Language: Rust
;; ============================================================================

(use-package
 rustic
 :mode ("\\.rs\\'" . rustic-mode)
 :custom
 (rustic-format-on-save nil) ; apheleia formats on save
 (rustic-lsp-client 'lsp-mode)
 (rustic-lsp-server 'rust-analyzer)
 (lsp-rust-analyzer-server-display-inlay-hints t)
 (lsp-rust-analyzer-display-chaining-hints t)
 (lsp-rust-analyzer-display-closure-return-type-hints t)
 :general
 (my-local-leader
  :keymaps 'rustic-mode-map
  "c"  '(:ignore t :wk "cargo")
  "cc" '(rustic-cargo-build :wk "build")
  "ck" '(rustic-cargo-check :wk "check")
  "cl" '(rustic-cargo-clippy :wk "clippy")
  "cd" '(rustic-cargo-doc :wk "doc")
  "cf" '(rustic-cargo-fmt :wk "fmt project")
  "cC" '(rustic-cargo-clean :wk "clean")
  "x"  '(rustic-cargo-run :wk "run")
  "t"  '(:ignore t :wk "test")
  "tt" '(rustic-cargo-test :wk "all")
  "tc" '(rustic-cargo-current-test :wk "at point")
  "hS" '(rustic-doc-search :wk "search docs")
  "m"  '(:ignore t :wk "macro")
  "mm" '(lsp-rust-analyzer-expand-macro :wk "expand at point")
  "mM" '(rustic-cargo-expand :wk "cargo expand")))

;; ============================================================================
;; Language: Zig
;; ============================================================================

(use-package
 zig-mode
 :mode "\\.zig\\'"
 :hook (zig-mode . lsp-deferred)
 :custom
 (zig-format-on-save nil) ; apheleia formats on save
 (lsp-zig-zls-executable (expand-file-name "~/.local/bin/zls"))
 :general
 (my-local-leader
  :keymaps 'zig-mode-map
  "c" '(zig-compile :wk "build")
  "t" '(zig-test-buffer :wk "test buffer")))

;; ============================================================================
;; Language: Go
;; ============================================================================

(use-package
 go-mode
 :mode "\\.go\\'"
 :hook
 (go-mode . (lambda ()
              (setq-local tab-width 4)
              (setq-local indent-tabs-mode t)))
 :custom
 (lsp-go-analyses
  '((fieldalignment . t)
    (nilness . t)
    (shadow . t)
    (unusedparams . t)
    (unusedwrite . t)))
 :general
 (my-local-leader
  :keymaps 'go-mode-map
  "c"  '(:ignore t :wk "build")
  "cb" '(my/go-build :wk "build")
  "cv" '(my/go-vet :wk "vet")
  "cl" '(my/go-lint :wk "staticcheck")
  "x"  '(:ignore t :wk "run")
  "xx" '(my/go-run :wk "package")
  "xf" '(my/go-run-file :wk "file")
  "t"  '(:ignore t :wk "test")
  "tt" '(go-test-current-test :wk "at point")
  "tf" '(go-test-current-file :wk "file")
  "tp" '(go-test-current-project :wk "project")
  "tb" '(go-test-current-benchmark :wk "benchmark")
  "tc" '(go-test-current-coverage :wk "coverage")
  "tv" '(my/go-test-verbose :wk "verbose")
  "tr" '(my/go-test-run-regex :wk "by regex")
  "i"  '(:ignore t :wk "imports")
  "ia" '(go-import-add :wk "add")
  "ir" '(go-remove-unused-imports :wk "remove unused")
  "hg" '(godoc-at-point :wk "godoc")
  "da" '(my/dap-go-run-with-args :wk "debug with args")
  "dt" '(my/dap-go-debug-test :wk "debug test")
  "G"  '(:ignore t :wk "generate")
  "Gt" '(go-tag-add :wk "add tags")
  "GT" '(go-tag-remove :wk "remove tags")
  "Gi" '(go-impl :wk "implement interface")))

(use-package gotest :after go-mode)

(use-package
 go-tag
 :after go-mode
 :custom (go-tag-args '("-transform" "camelcase")))

(use-package go-impl :after go-mode)

(defun my/go-build ()
  "Run go build in the project root."
  (interactive)
  (compile "go build ./..."))

(defun my/go-vet ()
  "Run go vet in the project root."
  (interactive)
  (compile "go vet ./..."))

(defun my/go-lint ()
  "Run staticcheck in the project root."
  (interactive)
  (compile "staticcheck ./..."))

(defun my/go-run ()
  "Run the current Go package."
  (interactive)
  (compile "go run ."))

(defun my/go-run-file ()
  "Run the current Go file."
  (interactive)
  (compile (concat "go run " (shell-quote-argument (buffer-file-name)))))

(defun my/go-test-verbose ()
  "Run tests for the current file with verbose output."
  (interactive)
  (compile (concat "go test -v -run "
                   (shell-quote-argument (go-test--get-current-test-info))
                   " " (go-test--get-current-file-testing-args))))

(defun my/go-test-run-regex ()
  "Run Go tests matching a prompted regex."
  (interactive)
  (let ((regex (read-string "Test regex: ")))
    (compile (concat "go test -v -run " (shell-quote-argument regex) " ./..."))))

(defun my/dap-go-run-with-args ()
  "Debug current Go package, prompting for CLI arguments."
  (interactive)
  (dap-debug
   (list :type "go"
         :request "launch"
         :name "Run with Args"
         :mode "auto"
         :program (file-name-directory (buffer-file-name))
         :args (vconcat (split-string (read-string "Args: "))))))

(defun my/dap-go-debug-test ()
  "Debug the Go test at point using Delve."
  (interactive)
  (dap-debug
   (list :type "go"
         :request "launch"
         :name "Debug Test"
         :mode "test"
         :program (file-name-directory (buffer-file-name))
         :args (vconcat (list "-test.run"
                              (go-test--get-current-test-info))))))

;; ============================================================================
;; Language: Ruby
;; ============================================================================

(use-package
 ruby-mode
 :straight nil
 :mode "\\.rb\\'"
 :config (setq ruby-insert-encoding-magic-comment nil)
 :general
 (my-local-leader
  :keymaps 'ruby-mode-map
  "'"  '(inf-ruby :wk "REPL")
  "e"  '(:ignore t :wk "eval")
  "eb" '(ruby-send-buffer :wk "buffer")
  "er" '(ruby-send-region :wk "region")
  "el" '(ruby-send-line :wk "line")
  "ed" '(ruby-send-definition :wk "definition")
  "da" '(my/dap-ruby-run-with-args :wk "debug with args")))

(defun my/dap-ruby-run-with-args ()
  "Debug current Ruby file, prompting for CLI arguments."
  (interactive)
  (dap-debug
   (list :type "Ruby"
         :args (vconcat (split-string (read-string "Args: ")))
         :cwd (file-name-directory (buffer-file-name))
         :program (buffer-file-name)
         :request "launch"
         :name "Run with Args")))

(use-package inf-ruby :hook (ruby-mode . inf-ruby-minor-mode))

(use-package
 rbenv
 :hook (ruby-mode . rbenv-use-corresponding)
 :init (setq rbenv-show-active-ruby-in-modeline nil)
 :config (global-rbenv-mode))

(use-package rbs-mode :mode "\\.rbs\\'")

;; ============================================================================
;; Language: Lua
;; ============================================================================

(use-package
 lua-mode
 :mode "\\.lua\\'"
 :interpreter "lua"
 :hook (lua-mode . my/lua-setup)
 :custom (lua-indent-level 2)
 :init
 (defun my/lua-stylua-config ()
   "Return the nearest stylua config file for this buffer, or nil."
   (let ((dir (locate-dominating-file
               default-directory
               (lambda (d)
                 (or (file-exists-p (expand-file-name "stylua.toml" d))
                     (file-exists-p (expand-file-name ".stylua.toml" d)))))))
     (when dir
       (let ((f (expand-file-name "stylua.toml" dir)))
         (if (file-exists-p f) f (expand-file-name ".stylua.toml" dir))))))

 (defun my/lua-apply-stylua-indent (config)
   "Match buffer indentation to stylua CONFIG (stylua defaults: Tabs, 4)."
   (with-temp-buffer
     (insert-file-contents config)
     (let ((width 4) (tabs t))
       (goto-char (point-min))
       (when (re-search-forward "^[ \t]*indent_width[ \t]*=[ \t]*\\([0-9]+\\)" nil t)
         (setq width (string-to-number (match-string 1))))
       (goto-char (point-min))
       (when (re-search-forward "^[ \t]*indent_type[ \t]*=[ \t]*\"\\([A-Za-z]+\\)\"" nil t)
         (setq tabs (string= (match-string 1) "Tabs")))
       (list width tabs))))

 (defun my/lua-setup ()
   "Indentation, formatting and LSP setup for Lua buffers.
In projects with a stylua config, indent to match it and format on save."
   (when-let* ((config (my/lua-stylua-config)))
     (pcase-let ((`(,width ,tabs) (my/lua-apply-stylua-indent config)))
       (setq-local lua-indent-level width
                   tab-width width
                   indent-tabs-mode tabs))
     (apheleia-mode 1))
   (setq-local lsp-inlay-hint-enable t)
   (lsp-deferred))
 :general
 (my-local-leader
  :keymaps 'lua-mode-map
  "'"  '(lua-show-process-buffer :wk "REPL")
  "R"  '(lua-restart-with-whole-file :wk "restart REPL with file")
  "q"  '(lua-kill-process :wk "quit REPL")
  "e"  '(:ignore t :wk "eval")
  "eb" '(lua-send-buffer :wk "buffer")
  "er" '(lua-send-region :wk "region")
  "el" '(lua-send-current-line :wk "line")
  "ed" '(lua-send-defun :wk "defun")
  "l"  '(:ignore t :wk "love")
  "ll" '(love/run :wk "run")
  "lk" '(love/stop :wk "stop")
  "lr" '(love/restart :wk "restart")))

;; love-minor-mode's autoload adds `love/possibly-enable-mode' to
;; `lua-mode-hook', which enables it only in buffers that use `love.*'.
(use-package love-minor-mode
  :defer t
  :init
  (defconst my/love-buffer-name "*love*")

  (defun love/run ()
    "Run the Love2D project in its own buffer, replacing any running instance."
    (interactive)
    (let* ((root (or (locate-dominating-file default-directory "main.lua")
                     default-directory))
           (default-directory root)
           (compilation-always-kill t))
      (compilation-start
       (concat "love " (shell-quote-argument (expand-file-name root)))
       nil
       (lambda (_mode) my/love-buffer-name))))

  (defun love/stop ()
    "Stop the running Love2D process, if any."
    (interactive)
    (when-let* ((buf (get-buffer my/love-buffer-name))
                (proc (get-buffer-process buf)))
      (interrupt-process proc)))

  (defalias 'love/restart #'love/run
    "Restart the Love2D project (`love/run' kills any running instance)."))

;; Lua debugging: dap-mode + local-lua-debugger-vscode (Tom Blind), v0.3.3
;; unpacked from Open VSX into `my/lua-debugger-dir'. The adapter runs on Node.
;; Plain Lua needs no code changes. LÖVE games must start the debugger
;; themselves; put this at the top of main.lua:
;;   if os.getenv("LOCAL_LUA_DEBUGGER_VSCODE") == "1" then
;;     require("lldebugger").start()
;;   end
;; and keep `t.console = false' in conf.lua.
(defconst my/lua-debugger-dir
  (expand-file-name "debug-adapters/local-lua-debugger-vscode" user-emacs-directory))

(defun my/lua-debugger-node ()
  "Return a stable node executable.
The fnm multishell path that exec-path-from-shell imports goes away when that
shell exits, so prefer fnm's default alias."
  (let ((fnm (expand-file-name "~/.local/share/fnm/aliases/default/bin/node")))
    (cond ((file-executable-p fnm) fnm)
          ((executable-find "node"))
          (t (user-error "Lua debugger needs Node.js on exec-path")))))

(defun my/dap-lua--populate (conf)
  "Fill in what VS Code normally supplies to local-lua-debugger in CONF."
  (let* ((program (plist-get conf :program))
         (custom (plist-get program :command)) ; e.g. love
         (file (buffer-file-name))
         (root (directory-file-name
                (expand-file-name
                 (if custom
                     (or (locate-dominating-file default-directory "main.lua")
                         default-directory)
                   (file-name-directory (or file default-directory)))))))
    (unless (or custom file)
      (user-error "Visit a Lua file to debug it"))
    (unless (file-exists-p (expand-file-name "extension/debugAdapter.js" my/lua-debugger-dir))
      (user-error "Lua debug adapter not found in %s" my/lua-debugger-dir))
    (when (and (not custom) (not (plist-get program :file)))
      (setq conf (plist-put conf :program (append program (list :file file)))))
    (dap--put-if-absent conf :dap-server-path
                        (list (my/lua-debugger-node)
                              (expand-file-name "extension/debugAdapter.js"
                                                my/lua-debugger-dir)))
    (dap--put-if-absent conf :extensionPath my/lua-debugger-dir)
    (dap--put-if-absent conf :workspacePath root)
    (dap--put-if-absent conf :cwd root)
    (dap--put-if-absent conf :args (if custom (vector root) []))
    conf))

(with-eval-after-load 'dap-mode
  (dap-register-debug-provider "lua-local" #'my/dap-lua--populate)
  (dap-register-debug-template
   "Lua :: Run Current File (lua)"
   (list :type "lua-local" :request "launch" :name "Lua: current file"
         :program (list :lua "lua")))
  (dap-register-debug-template
   "Lua :: Run Current File (luajit)"
   (list :type "lua-local" :request "launch" :name "LuaJIT: current file"
         :program (list :lua "luajit")))
  (dap-register-debug-template
   "LÖVE :: Run Project"
   (list :type "lua-local" :request "launch" :name "LÖVE: project"
         :program (list :command "love"))))

;; ============================================================================
;; Language: TypeScript (built-in tree-sitter modes; see `my/treesit-install-grammars')
;; ============================================================================

(add-to-list 'auto-mode-alist '("\\.ts\\'" . typescript-ts-mode))
(add-to-list 'auto-mode-alist '("\\.tsx\\'" . tsx-ts-mode))
(setq typescript-ts-mode-indent-offset 2)

;; ============================================================================
;; Language: SQL
;; ============================================================================

(my-local-leader
 :keymaps 'sql-mode-map
 "'"  '(sql-postgres :wk "psql REPL")
 "s"  '(:ignore t :wk "send")
 "ss" '(sql-send-paragraph :wk "paragraph")
 "sr" '(sql-send-region :wk "region")
 "sb" '(sql-send-buffer :wk "buffer")
 "sl" '(sql-send-line-and-next :wk "line"))

;; ============================================================================
;; Other Languages
;; ============================================================================

(use-package poke-mode)
(use-package rec-mode :mode "\\.rec\\'")
(use-package yaml-mode :defer t)

;; ============================================================================
;; Git
;; ============================================================================

(use-package
 magit
 :defer t
 :custom
 (magit-display-buffer-function
  #'magit-display-buffer-same-window-except-diff-v1)
 (magit-diff-refine-hunk 'all))

(use-package
 diff-hl
 :hook
 ((after-init . global-diff-hl-mode)
  (after-init . diff-hl-flydiff-mode)
  (magit-pre-refresh . diff-hl-magit-pre-refresh)
  (magit-post-refresh . diff-hl-magit-post-refresh)))

;; ============================================================================
;; UI
;; ============================================================================

(use-package
 which-key
 :straight nil
 :init (which-key-mode)
 :custom
 (which-key-idle-delay 0.5)
 (which-key-sort-order 'which-key-key-order-alpha))

(use-package leuven-theme :config (load-theme 'leuven-dark t))

;; ============================================================================
;; Utility Functions
;; ============================================================================

(defun my/copy-file-path ()
  "Copy the current buffer's file path to the kill ring."
  (interactive)
  (if buffer-file-name
      (progn
        (kill-new buffer-file-name)
        (message "Copied: %s" buffer-file-name))
    (message "Buffer is not visiting a file")))

(defun my/copy-file-name ()
  "Copy the current buffer's filename (without directory) to the kill ring."
  (interactive)
  (if buffer-file-name
      (let ((name (file-name-nondirectory buffer-file-name)))
        (kill-new name)
        (message "Copied: %s" name))
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

(defun my/sudo-edit ()
  "Reopen the current file as root, or prompt for a file to open as root."
  (interactive)
  (if buffer-file-name
      (find-alternate-file (concat "/sudo::" buffer-file-name))
    (find-file (concat "/sudo::" (expand-file-name (read-file-name "Find file (sudo): "))))))

(defun my/new-empty-buffer ()
  "Create a new empty buffer."
  (interactive)
  (let ((buf (generate-new-buffer "untitled")))
    (switch-to-buffer buf)
    (funcall initial-major-mode)))

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

(defun my/open-glove80-keymap ()
  "Open the Glove80 keymap file."
  (interactive)
  (find-file (expand-file-name "glove80-keymap.rst" user-emacs-directory)))

;;; init.el ends here
