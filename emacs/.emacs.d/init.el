;;; -*- no-byte-compile: t -*-

;; turn off mouse interface early in startup to avoid momentary display

(if (display-graphic-p) (tool-bar-mode -1))
(if (display-graphic-p) (scroll-bar-mode -1))

(menu-bar-mode -1)

(setq frame-title-format
      '(:eval
        (if (buffer-file-name)
            (replace-regexp-in-string
             (concat "/home/" user-login-name) "~" buffer-file-name)
          "%b")))
(set-frame-font "Consolas-11")
(add-to-list 'default-frame-alist '(font . "Consolas-11"))

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")
(defvar zenburn-override-colors-alist
  `(("zenburn-bg" . nil)))
(load-theme 'zenburn t)

(defalias 'yes-or-no-p 'y-or-n-p)

(prefer-coding-system 'utf-8-unix)

(setq-default
 initial-major-mode 'text-mode
 bidi-display-reordering nil
 echo-keystrokes 0.1
 message-log-max t
 mouse-wheel-mode t
 xterm-mouse-mode t
 color-theme-is-global t
 delete-by-moving-to-trash t
 font-lock-maximum-decoration t
 blink-cursor-mode -1
 visible-bell nil
 inhibit-startup-screen t
 initial-scratch-message nil
 x-select-enable-clipboard t
 x-select-enable-primary t
 save-interprogram-paste-before-kill t
 apropos-do-all t
 mouse-yank-at-point t
 vc-make-backup-files t
 custom-file (concat user-emacs-directory "custom.el")
 backup-directory-alist `(("." . ,(concat user-emacs-directory "backups")))
 auto-save-file-name-transforms `((".*" ,temporary-file-directory t))
 create-lockfiles nil
 indent-tabs-mode nil
 tab-width 4
 js-indent-level 2
 fill-column 120
 global-auto-revert-mode t
 require-final-newline t
 fit-window-to-buffer-horizontally "only")

;; load local packages, then package.el dependencies
(defvar local-packages-path (concat user-emacs-directory "vendor"))
(let ((base local-packages-path))
  (add-to-list 'load-path base)
  (dolist (f (directory-files base))
    (let ((name (concat base "/" f)))
      (when (and (file-directory-p name)
                 (not (equal f ".."))
                 (not (equal f ".")))
        (add-to-list 'load-path name)))))

(load (concat user-emacs-directory "utils"))
(load (concat user-emacs-directory "dependencies"))
(dependencies-initialize)

;; set up use-package, miscellaneous config
(eval-when-compile (require 'use-package))
(setq use-package-verbose t)
(add-to-list 'backup-directory-alist (cons tramp-file-name-regexp nil))
(add-hook 'before-save-hook 'delete-trailing-whitespace)
(add-to-list 'auto-mode-alist '("\\.zsh\\'" . shell-script-mode))

;; hippie-expand: at times perhaps too hip
(delete 'try-expand-line hippie-expand-try-functions-list)
(delete 'try-expand-list hippie-expand-try-functions-list)

;; package-specific configs follow

(require 'magit)
(add-hook 'git-commit-setup-hook 'git-commit-turn-on-auto-fill)

(use-package lisp-mode
  :config
  (add-hook 'lisp-interaction-mode-hook 'turn-on-eldoc-mode)
  (add-hook 'lisp-interaction-mode-hook 'pretty-lambdas)
  (add-hook 'emacs-lisp-mode-hook 'turn-on-eldoc-mode)
  (add-hook 'emacs-lisp-mode-hook 'pretty-lambdas))

(use-package prog-mode
  :bind ("RET" . newline-and-indent)
  :init
  (add-hook 'prog-mode-hook 'display-line-numbers-mode)
  (add-hook 'prog-mode-hook 'electric-pair-mode)
  (add-hook 'prog-mode-hook 'electric-indent-mode))

(use-package comint
  :defer t
  :init
  ;; sets the current buffer process to not pop up an annoying notification on Emacs exit
  (add-hook
   'comint-exec-hook
   (lambda () (set-process-query-on-exit-flag (get-buffer-process (current-buffer)) nil))))

(use-package eldoc
  :defer t
  :diminish eldoc-mode
  :init
  (setq eldoc-idle-delay 0))

(use-package ido
  :init
  (setq
   ido-max-directory-size 100000
   ido-max-prospects 10
   ido-enable-flex-matching t
   ido-enable-prefix nil
   ido-enable-last-directory-history t
   ido-use-filename-at-point nil
   ido-use-url-at-point nil
   ido-use-virtual-buffers t
   ido-save-directory-list-file (concat user-emacs-directory "ido.hist")
   ido-ignore-buffers '("\\` " "*Messages*" "*Compile-Log*"))
  (ido-mode t)
  (ido-everywhere t)
  (flx-ido-mode 0)
  (setq magit-completing-read-function 'magit-ido-completing-read))

(use-package projectile
  :init
  (projectile-global-mode))

(use-package uniquify
  :init
  (setq-default
   uniquify-buffer-name-style 'forward
   uniquify-ignore-buffers-re "^\\*"))

(use-package saveplace
  :init
  (setq-default
   save-place-file (concat user-emacs-directory "places")
   save-place-mode 1))

(use-package recentf
  :init
  (setq-default
   recentf-max-saved-items 500
   recentf-max-menu-items 15
   recentf-save-file (concat user-emacs-directory "recentf"))
  (recentf-mode 1))

;; savehist keeps track of some history
(use-package savehist
  :init
  (setq-default
   savehist-additional-variables '(search ring regexp-search-ring)
   savehist-autosave-interval 60
   savehist-file (concat user-emacs-directory "savehist"))
  (savehist-mode 1))

(use-package paren
  :init
  (setq-default show-paren-style 'parenthesis)
  (show-paren-mode 1))

(use-package flycheck
  :config
  (global-flycheck-mode 1)
  (flycheck-add-mode 'javascript-eslint 'web-mode))

(use-package rust-mode
  :init
  (setq rust-match-angle-brackets nil)
  (add-hook 'flycheck-mode-hook #'flycheck-rust-setup))

(use-package elixir-mode
  :config
  (add-hook 'elixir-mode-hook 'subword-mode)
  (add-to-list 'auto-mode-alist '("\\.ex$" . elixir-mode))
  (add-to-list 'auto-mode-alist '("\\.exs$" . elixir-mode)))

(use-package geiser
  :defer t
  :config (setq geiser-active-implementations '(mit))
  :hook (scheme-mode . geiser-mode))

(use-package alchemist
  :init
  (add-hook 'elixir-mode-hook 'alchemist))

(use-package subword
  :defer t
  :diminish subword-mode)

(use-package clojure-mode
  :defer t
  :config
  (add-hook 'clojure-mode-hook 'turn-on-eldoc-mode)
  (add-hook 'clojure-mode-hook 'pretty-fn)
  (add-hook 'clojure-mode-hook 'subword-mode)
  ;; adjust indents for core.logic macros
  (put-clojure-indent 'run* 'defun)
  (put-clojure-indent 'run 'defun)
  (put-clojure-indent 'fresh 'defun))

(use-package company
  :config
  (setq company-idle-delay nil)
  (global-set-key (kbd "TAB") #'company-indent-or-complete-common))

(use-package ruby-mode :mode "\\.\\(arb\\|rabl\\)$")
(use-package dockerfile-mode :mode "Dockerfile")
(use-package php-mode :mode "\\.\\(php\\|inc\\)$")
(use-package scss-mode :mode "\\.scss$")
(use-package csharp-mode :mode "\\.cs$")
(use-package glsl-mode :mode "\\.\\(glsl\\|vert\\|frag\\)$")
(use-package markdown-mode :mode (("\\.md$" . markdown-mode)
                                  ("README\\.md$" . gfm-mode)))

(use-package fn-mode :defer t :commands fn-mode)

(use-package css-mode
  :defer t
  :config
  (setq css-indent-offset 2))

(use-package editorconfig
  :config
  (editorconfig-mode 1))

(use-package web-mode
  :mode "\\.\\(jsx\\|html\\)$"
  :config
  (setq web-mode-markup-indent-offset 2)
  (setq web-mode-css-indent-offset 2)
  (setq web-mode-ac-sources-alist
        '(("css" . (ac-source-css-property))
          ("html" . (ac-source-words-in-buffer ac-source-abbrev)))))

(use-package json-mode
  :mode "\\.json$"
  :config
  ;; disable json-jsonlist checking for json files
  (setq-default
   flycheck-disabled-checkers (append flycheck-disabled-checkers '(json-jsonlist))))

(use-package rjsx-mode
  :mode "\\.js$"
  :config
  (add-hook 'rjsx-mode-hook 'fn-mode)
  (add-hook 'rjsx-mode-hook 'subword-mode)
  ;; disable jshint since we prefer eslint checking
  (setq-default
   flycheck-disabled-checkers (append flycheck-disabled-checkers '(javascript-jshint))))

(use-package handlebars-mode)

(use-package haskell-mode
  :defer t
  :config
  (add-hook 'haskell-mode-hook 'turn-on-haskell-doc-mode)
  (add-hook 'haskell-mode-hook 'turn-on-haskell-indentation))

(use-package ssh-config-mode
  :mode ((".ssh/config\\'" . ssh-config-mode)
         ("sshd?_config\\'" . ssh-config-mode)
         ("known_hosts\\'" . ssh-known-hosts-mode)
         ("authorized_keys2?\\'" . ssh-authorized-keys-mode))
  :config
  (add-hook 'ssh-config-mode-hook 'turn-on-font-lock))

(load (concat user-emacs-directory "bindings/bindings-general"))
