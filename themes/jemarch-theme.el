;; -*- lexical-binding: t; -*-
(deftheme jemarch
  "Far Manager-inspired theme using the actual Far Manager palette.")

;; Far Manager 16-color palette from colormix.cpp:
;;   0x0 Black        #000000    0x8 DarkGray      #808080
;;   0x1 Blue         #000080    0x9 LightBlue     #0000FF
;;   0x2 Green        #008000    0xA LightGreen    #00FF00
;;   0x3 Cyan         #008080    0xB LightCyan     #00FFFF
;;   0x4 Red          #800000    0xC LightRed      #FF0000
;;   0x5 Magenta      #800080    0xD LightMagenta  #FF00FF
;;   0x6 Brown        #808000    0xE Yellow         #FFFF00
;;   0x7 LightGray    #C0C0C0    0xF White          #FFFFFF
;;
;; Panel default:  LightCyan on Blue   (editor/viewer same)
;; Panel selected: Yellow on Blue
;; Panel cursor:   Black on Cyan
;; Mode/status:    Black on Cyan
;; Menus:          White on Cyan
;; Dialogs:        Black on LightGray
;; Warnings:       White on Red
;; Keybar:         Black on Cyan / LightGray on Black

(let (;; Far Manager base 16 colors
      (black        "#000000")
      (blue         "#000080")
      (green        "#008000")
      (cyan         "#008080")
      (red          "#800000")
      (magenta      "#800080")
      (brown        "#808000")
      (lightgray    "#C0C0C0")
      (darkgray     "#808080")
      (lightblue    "#0000FF")
      (lightgreen   "#00FF00")
      (lightcyan    "#00FFFF")
      (lightred     "#FF0000")
      (lightmagenta "#FF00FF")
      (yellow       "#FFFF00")
      (white        "#FFFFFF")
      ;; Extended colors for syntax (Far-inspired but visible on blue)
      (gold         "#FFD700")   ; warm yellow for strings
      (orange       "#FFA500")   ; builtins
      (skyblue      "#87CEEB")   ; constants (visible on dark blue)
      ;; A few tasteful tweaks for modern displays
      (blue-hl      "#000c99")   ; slightly lighter blue for hl-line
      (blue-sel     "#0a1a6a")   ; selection on blue bg
      (diff-green   "#003800")   ; diff added bg
      (diff-red     "#380000"))  ; diff removed bg

  (custom-theme-set-faces
   'jemarch

   ;; --- Base faces (Panel: LightCyan on Blue) --------------------------------
   `(default
     ((t (:family "Monospace" :background ,blue :foreground ,lightcyan
          :weight normal :slant normal :height 1 :width normal))))
   `(cursor ((t (:background ,yellow))))
   `(fixed-pitch ((t (:family "Monospace"))))
   `(variable-pitch ((t (:family "Monospace"))))
   `(shadow ((t (:foreground ,darkgray))))
   `(region ((t (:background ,cyan :foreground ,black))))
   `(highlight ((t (:background ,cyan :foreground ,black))))
   `(hl-line ((t (:background ,blue-hl))))
   `(secondary-selection ((t (:background ,blue-sel))))
   `(fringe ((t (:background ,blue :foreground ,lightcyan))))
   `(vertical-border ((t (:foreground ,lightcyan))))
   `(line-number ((t (:foreground ,lightgray :background ,blue))))
   `(line-number-current-line ((t (:foreground ,yellow :background ,blue :weight bold))))
   `(fill-column-indicator ((t (:foreground ,darkgray))))
   `(trailing-whitespace ((t (:background ,lightred))))
   `(escape-glyph ((t (:foreground ,lightmagenta))))
   `(tooltip ((t (:family "Monospace" :background ,lightgray :foreground ,black))))

   ;; --- Minibuffer / prompts ------------------------------------------------
   `(minibuffer-prompt ((t (:foreground ,yellow :weight bold))))

   ;; --- Font lock (syntax) --------------------------------------------------
   ;; Every face must be visually distinct from default lightcyan on blue.
   ;; Uses Far's bright colors + a few extended shades for visibility.
   `(font-lock-keyword-face ((t (:foreground ,white :weight bold))))
   `(font-lock-function-name-face ((t (:foreground ,yellow :weight bold))))
   `(font-lock-variable-name-face ((t (:foreground ,lightgreen))))
   `(font-lock-string-face ((t (:foreground ,gold))))
   `(font-lock-comment-face ((t (:foreground ,darkgray))))
   `(font-lock-comment-delimiter-face ((t (:inherit font-lock-comment-face))))
   `(font-lock-doc-face ((t (:foreground ,lightgray))))
   `(font-lock-type-face ((t (:foreground ,lightmagenta))))
   `(font-lock-constant-face ((t (:foreground ,skyblue))))
   `(font-lock-builtin-face ((t (:foreground ,orange))))
   `(font-lock-preprocessor-face ((t (:foreground ,lightred))))
   `(font-lock-warning-face ((t (:foreground ,yellow :weight bold))))
   `(font-lock-negation-char-face ((t (:foreground ,lightred))))
   `(font-lock-regexp-grouping-backslash ((t (:foreground ,lightmagenta :weight bold))))
   `(font-lock-regexp-grouping-construct ((t (:foreground ,lightmagenta :weight bold))))

   ;; --- Mode line (Status: Black on Cyan) -----------------------------------
   `(mode-line
     ((t (:family "Monospace" :background ,cyan :foreground ,black
          :box (:line-width -1 :color ,lightcyan)))))
   `(mode-line-inactive
     ((t (:family "Monospace" :background ,black :foreground ,lightgray
          :box (:line-width -1 :color ,darkgray)))))
   `(mode-line-buffer-id ((t (:foreground ,black :weight bold))))
   `(mode-line-emphasis ((t (:foreground ,black :weight bold))))
   `(mode-line-highlight ((t (:box (:line-width 2 :color ,white)))))
   `(header-line ((t (:background ,cyan :foreground ,black))))

   ;; --- Search / replace ----------------------------------------------------
   `(isearch ((t (:background ,yellow :foreground ,black :weight bold))))
   `(isearch-fail ((t (:background ,red :foreground ,white))))
   `(lazy-highlight ((t (:background ,cyan :foreground ,black))))
   `(match ((t (:background ,yellow :foreground ,black :weight bold))))
   `(query-replace ((t (:inherit isearch))))

   ;; --- Error / warning / success -------------------------------------------
   `(error ((t (:foreground ,lightred :weight bold))))
   `(warning ((t (:foreground ,yellow :weight bold))))
   `(success ((t (:foreground ,lightgreen :weight bold))))

   ;; --- Links / buttons -----------------------------------------------------
   `(link ((t (:foreground ,yellow :underline t))))
   `(link-visited ((t (:foreground ,lightmagenta :underline t))))
   `(button ((t (:inherit link))))

   ;; --- Completions (vertico, etc.) -- Menu: White on Cyan -------------------
   `(completions-common-part ((t (:foreground ,yellow :weight bold))))
   `(completions-first-difference ((t (:foreground ,yellow))))

   ;; --- Vertico (Menu style) ------------------------------------------------
   `(vertico-current ((t (:background ,black :foreground ,white))))

   ;; --- Marginalia ----------------------------------------------------------
   `(marginalia-documentation ((t (:foreground ,lightgray))))

   ;; --- Diff ----------------------------------------------------------------
   `(diff-added ((t (:background ,diff-green :foreground ,lightgreen))))
   `(diff-removed ((t (:background ,diff-red :foreground ,lightred))))
   `(diff-changed ((t (:background ,blue-sel :foreground ,yellow))))
   `(diff-header ((t (:background ,cyan :foreground ,black :weight bold))))
   `(diff-file-header ((t (:background ,cyan :foreground ,black :weight bold))))
   `(diff-hunk-header ((t (:background ,blue-sel :foreground ,lightcyan))))
   `(diff-refine-added ((t (:background ,green :foreground ,white :weight bold))))
   `(diff-refine-removed ((t (:background ,red :foreground ,white :weight bold))))

   ;; --- Flycheck / Flyspell ------------------------------------------------
   `(flycheck-error ((t (:underline (:color ,lightred :style wave)))))
   `(flycheck-warning ((t (:underline (:color ,yellow :style wave)))))
   `(flycheck-info ((t (:underline (:color ,lightcyan :style wave)))))
   `(flyspell-incorrect ((t (:underline (:color ,lightred :style wave)))))
   `(flyspell-duplicate ((t (:underline (:color ,yellow :style wave)))))

   ;; --- Magit ---------------------------------------------------------------
   `(magit-section-heading ((t (:foreground ,yellow :weight bold))))
   `(magit-section-highlight ((t (:background ,blue-hl))))
   `(magit-branch-local ((t (:foreground ,lightcyan))))
   `(magit-branch-remote ((t (:foreground ,lightgreen))))
   `(magit-tag ((t (:foreground ,yellow))))
   `(magit-hash ((t (:foreground ,darkgray))))
   `(magit-diff-added ((t (:background ,diff-green :foreground ,lightgreen))))
   `(magit-diff-added-highlight ((t (:background "#004400" :foreground ,lightgreen))))
   `(magit-diff-removed ((t (:background ,diff-red :foreground ,lightred))))
   `(magit-diff-removed-highlight ((t (:background "#440000" :foreground ,lightred))))
   `(magit-diff-context ((t (:foreground ,darkgray))))
   `(magit-diff-context-highlight ((t (:background ,blue-hl :foreground ,lightgray))))
   `(magit-diff-file-heading ((t (:foreground ,white :weight bold))))
   `(magit-diff-file-heading-highlight ((t (:background ,blue-hl :foreground ,white :weight bold))))
   `(magit-diff-hunk-heading ((t (:background ,cyan :foreground ,black))))
   `(magit-diff-hunk-heading-highlight ((t (:background ,lightcyan :foreground ,black))))
   `(magit-blame-heading ((t (:background ,cyan :foreground ,black))))

   ;; --- Git gutter ----------------------------------------------------------
   `(git-gutter:added ((t (:foreground ,lightgreen :weight bold))))
   `(git-gutter:modified ((t (:foreground ,lightcyan :weight bold))))
   `(git-gutter:deleted ((t (:foreground ,lightred :weight bold))))
   `(git-gutter-fr:added ((t (:foreground ,lightgreen))))
   `(git-gutter-fr:modified ((t (:foreground ,lightcyan))))
   `(git-gutter-fr:deleted ((t (:foreground ,lightred))))

   ;; --- Company (Dialog style: Black on LightGray) --------------------------
   `(company-tooltip ((t (:background ,lightgray :foreground ,black))))
   `(company-tooltip-selection ((t (:background ,black :foreground ,white))))
   `(company-tooltip-common ((t (:foreground ,yellow :weight bold))))
   `(company-tooltip-common-selection ((t (:foreground ,yellow :weight bold))))
   `(company-tooltip-annotation ((t (:foreground ,darkgray))))
   `(company-scrollbar-bg ((t (:background ,lightgray))))
   `(company-scrollbar-fg ((t (:background ,darkgray))))

   ;; --- LSP UI --------------------------------------------------------------
   `(lsp-ui-doc-background ((t (:background ,lightgray))))
   `(lsp-ui-peek-peek ((t (:background ,cyan))))
   `(lsp-ui-peek-list ((t (:background ,blue))))
   `(lsp-ui-peek-filename ((t (:foreground ,yellow :weight bold))))
   `(lsp-ui-peek-header ((t (:background ,cyan :foreground ,black :weight bold))))
   `(lsp-ui-peek-selection ((t (:background ,black :foreground ,white))))
   `(lsp-ui-peek-highlight ((t (:background ,cyan :foreground ,yellow))))
   `(lsp-ui-sideline-code-action ((t (:foreground ,yellow))))
   `(lsp-headerline-breadcrumb-path-face ((t (:foreground ,lightgray))))
   `(lsp-headerline-breadcrumb-symbols-face ((t (:foreground ,lightcyan))))
   `(lsp-headerline-breadcrumb-separator-face ((t (:foreground ,darkgray))))

   ;; --- Which-key -----------------------------------------------------------
   `(which-key-key-face ((t (:foreground ,yellow :weight bold))))
   `(which-key-separator-face ((t (:foreground ,darkgray))))
   `(which-key-command-description-face ((t (:foreground ,lightcyan))))
   `(which-key-group-description-face ((t (:foreground ,white))))

   ;; --- Avy -----------------------------------------------------------------
   `(avy-lead-face ((t (:background ,lightred :foreground ,white :weight bold))))
   `(avy-lead-face-0 ((t (:background ,lightblue :foreground ,white :weight bold))))
   `(avy-lead-face-1 ((t (:background ,cyan :foreground ,black :weight bold))))
   `(avy-lead-face-2 ((t (:background ,green :foreground ,white :weight bold))))

   ;; --- Dired / Dirvish ----------------------------------------------------
   `(dired-directory ((t (:foreground ,white :weight bold))))
   `(dired-symlink ((t (:foreground ,lightmagenta))))
   `(dired-marked ((t (:foreground ,yellow :weight bold))))
   `(dired-flagged ((t (:foreground ,lightred :weight bold))))
   `(dired-header ((t (:foreground ,yellow :weight bold))))

   ;; --- Treemacs ------------------------------------------------------------
   `(treemacs-directory-face ((t (:foreground ,white))))
   `(treemacs-file-face ((t (:foreground ,lightcyan))))
   `(treemacs-root-face ((t (:foreground ,yellow :weight bold))))
   `(treemacs-git-modified-face ((t (:foreground ,brown))))
   `(treemacs-git-added-face ((t (:foreground ,lightgreen))))
   `(treemacs-git-untracked-face ((t (:foreground ,darkgray))))

   ;; --- Org -----------------------------------------------------------------
   `(org-done ((t (:foreground ,lightgreen :weight bold))))
   `(org-todo ((t (:foreground ,yellow :weight bold))))

   ;; --- Calendar / diary ----------------------------------------------------
   `(calendar-weekend-header ((t (:foreground ,lightcyan :weight bold))))
   `(diary ((t (:foreground ,yellow :weight bold))))

   ;; --- Show paren ----------------------------------------------------------
   `(show-paren-match ((t (:background ,cyan :foreground ,yellow :weight bold))))
   `(show-paren-mismatch ((t (:background ,lightred :foreground ,white :weight bold))))

   ;; --- Misc built-in -------------------------------------------------------
   `(next-error ((t (:inherit region))))
   `(widget-field ((t (:background ,lightgray :foreground ,black))))
   ))

(provide-theme 'jemarch)
