;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; ─── Identificación ───────────────────────────────────────────
(setq user-full-name "DNR"
      user-mail-address "danis.ramirez.hn@gmail.com")

;; ─── Tamaño de ventana por defecto (más grande) ────────────
;; Ajusta los valores según tu pantalla y preferencia
(add-to-list 'default-frame-alist '(width . 110))   ;; caracteres de ancho
(add-to-list 'default-frame-alist '(height . 39))   ;; líneas de alto

;; ─── Fuentes ────────────
    (setq doom-font (font-spec :family "FiraCode Nerd Font" :size 16)
      doom-variable-pitch-font (font-spec :family "SF Pro" :size 16)
      doom-big-font (font-spec :family "FiraCode Nerd Font" :size 24))

;; Otras fuentes mono que tienes (cambia "Fira Code" si quieres probar):
;;   - "JetBrains Mono"
;;   - "Maple Mono"
;;   - "Monaspice" (o el nombre exacto: haz M-x describe-font para ver)
;;   - "Roboto Mono"
;;   - "Victor Mono"

;; ─── Tema ─────────────────────────────────────────────────────
    (setq doom-theme 'doom-horizon)

;; ─── Números de línea relativos (ideal para evil) ────────────
(setq display-line-numbers-type 'relative)

;; ─── Variables personalizables ─────────────────────────────
(defcustom my/transparency-enabled t
  "Activar o no los efectos de transparencia/blur."
  :type 'boolean
  :group 'my)

(defcustom my/transparency-level 0.7
  "Opacidad (alpha-background) cuando la transparencia está activada.
  1.0 = totalmente opaco, 0.0 = completamente transparente."
  :type 'float
  :group 'my)

(defcustom my/blur-amount 30
  "Cantidad de desenfoque (ns-background-blur) cuando está activado.
  Un valor de 0 equivale a desactivar el blur."
  :type 'integer
  :group 'my)

(defcustom my/blur-last-nonzero 30
  "Valor de blur que se restaura al reactivarlo tras un toggle."
  :type 'integer
  :group 'my)

(defcustom my/transparency-step 0.05
  "Incremento/decremento para la opacidad."
  :type 'float
  :group 'my)

(defcustom my/blur-step 5
  "Incremento/decremento para el desenfoque."
  :type 'integer
  :group 'my)

;; ─── Funciones de aplicación ─────────────────────────────
(defun my/apply-frame-transparency (&optional frame)
  "Aplica los parámetros actuales de transparencia/blur a FRAME."
  (let ((f (or frame (selected-frame))))
    (if my/transparency-enabled
        (progn
          (set-frame-parameter f 'ns-alpha-elements '(ns-alpha-all))
          (set-frame-parameter f 'ns-background-blur my/blur-amount)
          (set-frame-parameter f 'alpha-background my/transparency-level))
      (progn
        (set-frame-parameter f 'alpha-background 1.0)
        (set-frame-parameter f 'ns-background-blur 0)
        (set-frame-parameter f 'ns-alpha-elements nil)))
    (redisplay)))

(defun my/sync-default-frame-alist ()
  "Sincroniza `default-frame-alist` con los valores actuales."
  (setq default-frame-alist
        (assq-delete-all 'ns-background-blur
         (assq-delete-all 'ns-alpha-elements
          (assq-delete-all 'alpha-background default-frame-alist))))
  (when my/transparency-enabled
    (push `(ns-alpha-elements . ns-alpha-all) default-frame-alist)
    (push `(ns-background-blur . ,my/blur-amount) default-frame-alist)
    (push `(alpha-background . ,my/transparency-level) default-frame-alist)))

;; ─── Comandos interactivos ────────────────────────────────

;; --- Encendido/Apagado general ---
(defun my/toggle-transparency ()
  "Alterna entre transparencia activada y desactivada."
  (interactive)
  (setq my/transparency-enabled (not my/transparency-enabled))
  (my/sync-default-frame-alist)
  (dolist (frame (frame-list))
    (my/apply-frame-transparency frame))
  (message "Transparencia %s" (if my/transparency-enabled "activada" "desactivada")))

;; --- Ajustar opacidad ---
(defun my/increase-transparency ()
  "Hace la ventana más transparente (reduce alpha-background)."
  (interactive)
  (setq my/transparency-level (max 0.1 (- my/transparency-level my/transparency-step)))
  (my/update-all-frames)
  (message "Transparencia: %.2f" my/transparency-level))

(defun my/decrease-transparency ()
  "Hace la ventana menos transparente (aumenta alpha-background)."
  (interactive)
  (setq my/transparency-level (min 1.0 (+ my/transparency-level my/transparency-step)))
  (my/update-all-frames)
  (message "Transparencia: %.2f" my/transparency-level))

;; --- Ajustar desenfoque ---
(defun my/increase-blur ()
  "Aumenta la cantidad de blur."
  (interactive)
  (setq my/blur-amount (+ my/blur-amount my/blur-step))
  (when (> my/blur-amount 0)
    (setq my/blur-last-nonzero my/blur-amount))
  (my/update-all-frames)
  (message "Blur: %d" my/blur-amount))

(defun my/decrease-blur ()
  "Reduce la cantidad de blur (mínimo 0)."
  (interactive)
  (setq my/blur-amount (max 0 (- my/blur-amount my/blur-step)))
  (when (> my/blur-amount 0)
    (setq my/blur-last-nonzero my/blur-amount))
  (my/update-all-frames)
  (message "Blur: %d" my/blur-amount))

;; --- Activar/desactivar solo el blur ---
(defun my/toggle-blur ()
  "Alterna el blur: si está >0 lo guarda y lo pone a 0; si está a 0 restaura el último valor."
  (interactive)
  (if (> my/blur-amount 0)
      (progn
        (setq my/blur-last-nonzero my/blur-amount)
        (setq my/blur-amount 0))
    (setq my/blur-amount my/blur-last-nonzero))
  (my/update-all-frames)
  (if (> my/blur-amount 0)
      (message "Blur activado (%d)" my/blur-amount)
    (message "Blur desactivado")))

;; --- Helper para refrescar todos los frames y el alist ---
(defun my/update-all-frames ()
  "Aplica los cambios a todos los frames existentes y sincroniza default-frame-alist."
  (my/sync-default-frame-alist)
  (when my/transparency-enabled
    (dolist (frame (frame-list))
      (my/apply-frame-transparency frame))))

;; ─── Combinaciones de teclas ────────────────────────────
(global-set-key (kbd "C-c C-t") #'my/toggle-transparency)   ; toggle general
(global-set-key (kbd "C-c b") #'my/toggle-blur)           ; toggle solo blur
(global-set-key (kbd "C-c =") #'my/decrease-transparency) ; menos transparente (más opaco)
(global-set-key (kbd "C-c -") #'my/increase-transparency) ; más transparente
(global-set-key (kbd "C-c >") #'my/increase-blur)         ; más blur
(global-set-key (kbd "C-c <") #'my/decrease-blur)         ; menos blur

;; ─── Configuración inicial ─────────────────────────────
;; Limpiar default-frame-alist y establecer valores por defecto
(setq default-frame-alist
      (assq-delete-all 'ns-background-blur
       (assq-delete-all 'ns-alpha-elements
        (assq-delete-all 'alpha-background default-frame-alist))))
(push '(ns-alpha-elements . ns-alpha-all) default-frame-alist)
(push `(ns-background-blur . ,my/blur-amount) default-frame-alist)
(push `(alpha-background . ,my/transparency-level) default-frame-alist)

;; Aplicar a nuevos frames
(add-hook 'after-make-frame-functions #'my/apply-frame-transparency)
(unless (daemonp)
  (add-hook 'window-setup-hook #'my/apply-frame-transparency))

;; Aplicar inmediatamente si es inicio gráfico no-daemon
(when (display-graphic-p)
  (my/apply-frame-transparency))
;; Remove the banner
(remove-hook '+dashboard-functions '+dashboard-widget-banner)

;; Centrar el frame al inicio
(defun my/center-frame ()
  "Centra el frame actual en la pantalla principal."
  (interactive)
  (let* ((frame (selected-frame))
         (workarea (assoc 'workarea (frame-monitor-attributes frame)))
         (w (nth 3 workarea))  ;; ancho del área de trabajo
         (h (nth 4 workarea))  ;; alto del área de trabajo
         (fw (frame-pixel-width frame))
         (fh (frame-pixel-height frame))
         (left (/ (- w fw) 2))
         ;; Dejamos un pequeño margen superior para el menú/dock
         (top (max 0 (/ (- h fh) 2))))
    (set-frame-position frame left top)))

;; Ejecutar después de cargar la interfaz gráfica
(add-hook 'window-setup-hook #'my/center-frame)

;; (add-to-list 'default-frame-alist '(undecorated-round . t))

;; ─── Syntax highlighting para archivos .inc (The Art of ARM Assembly) ──
;; Asocia .inc con asm-mode (ensamblador GAS ARM64)
(add-to-list 'auto-mode-alist '("\\.inc\\'" . asm-mode))

;; ─── Org mode ────────────────────────────────────────────────────
;; Configuración general de Org-mode. Los flags del módulo
;; (org +pretty +dragndrop +journal +roam2) ya están en init.el.

(after! org
  ;; ── Directorio base ──────────────────────────────────────────
  (setq org-directory "~/org"
        org-default-notes-file (expand-file-name "inbox.org" org-directory)
        org-archive-location (expand-file-name "archive/%s_archive" org-directory))

  ;; ── Apariencia / Lectura ─────────────────────────────────────
  (setq org-startup-folded 'content
        org-hide-emphasis-markers t
        org-fontify-whole-heading-line t
        org-fontify-done-headline t
        org-fontify-quote-and-verse-blocks t
        org-src-fontify-natively t
        org-src-tab-acts-natively t)

  ;; ── Imágenes ─────────────────────────────────────────────────
  (setq org-image-actual-width '(700)
        org-display-inline-images t
        org-redisplay-inline-images t)

  ;; ── TODO / Gestión de tareas ─────────────────────────────────
  (setq org-todo-keywords
        '((sequence "TODO(t)" "NEXT(n)" "WAIT(w@/!)" "|" "DONE(d!)" "CANCELLED(c@/!)")
          (sequence "|" "NOTE(N)")))
  (setq org-log-done 'time
        org-log-into-drawer t
        org-enforce-todo-dependencies t)

  ;; ── Agendas ──────────────────────────────────────────────────
  (setq org-agenda-files (list org-directory)
        org-agenda-start-with-log-mode t
        org-agenda-start-on-weekday nil
        org-agenda-span 7
        org-deadline-warning-days 7)

  ;; ── Captura (org-capture) ────────────────────────────────────
  (setq org-capture-templates
        '(("t" "Tarea" entry
           (file+headline org-default-notes-file "Tareas")
           "* TODO %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n%a\n")
          ("n" "Nota rápida" entry
           (file+headline org-default-notes-file "Notas")
           "* NOTE %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n")
          ("i" "Idea" entry
           (file+headline org-default-notes-file "Ideas")
           "* IDEA %?\n:PROPERTIES:\n:CREATED: %U\n:END:\n")
          ("w" "Enlace/web" entry
           (file+headline org-default-notes-file "Web")
           "* %?\n:PROPERTIES:\n:CREATED: %U\n:SOURCE: %c\n:END:\n%a\n")))

  ;; ── Refiling ─────────────────────────────────────────────────
  (setq org-refile-targets '((nil :maxlevel . 3)
                             (org-agenda-files :maxlevel . 3))
        org-refile-use-outline-path t
        org-outline-path-complete-in-steps nil)

  ;; ── Enlaces ──────────────────────────────────────────────────
  (setq org-link-descriptive t
        org-confirm-shell-link-function 'y-or-n-p
        org-confirm-elisp-link-function 'y-or-n-p)

  ;; ── Babel ────────────────────────────────────────────────────
  (setq org-confirm-babel-evaluate nil)

  ;; ── Exportación ──────────────────────────────────────────────
  (setq org-export-with-sub-superscripts '{}
        org-export-with-toc t
        org-export-with-tags 'not-in-toc
        org-export-headline-levels 8
        org-export-with-smart-quotes t))

;; ─── org-modern (post-config) ──────────────────────────────────
(use-package! org-modern
  :hook (org-mode . org-modern-mode)
  :config
  (setq org-modern-star '("▪" "◆" "●" "○" "▶" "▷")
        org-modern-label-border nil
        org-modern-table-vertical 1
        org-modern-table-horizontal 0.5
        org-modern-list '((?- . "–") (?* . "•") (?+ . "◦")))
  (org-modern-mode +1))

;; ─── org-roam v2 ───────────────────────────────────────────────
(use-package! org-roam
  :defer t
  :config
  (setq org-roam-directory (file-truename "~/org/roam")
        org-roam-dailies-directory "daily/"
        org-roam-index-file "index.org"
        org-roam-capture-templates
        '(("d" "default" plain
           "%?"
           :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags:\n")
           :unnarrowed t)
          ("p" "project" plain
           "* TODO %?\n"
           :if-new (file+head "%<%Y%m%d%H%M%S>-${slug}.org"
                              "#+title: ${title}\n#+date: %U\n#+filetags: project\n")
           :unnarrowed t))
        org-roam-dailies-capture-templates
        '(("d" "default" entry
           "* %?"
           :target (file+head "%<%Y-%m-%d>.org"
                              "#+title: %<%Y-%m-%d>\n"))))
  (org-roam-db-autosync-mode +1))

;; ─── org-journal ───────────────────────────────────────────────
(use-package! org-journal
  :defer t
  :config
  (setq org-journal-dir "~/org/journal"
        org-journal-date-format "%A, %Y-%m-%d"
        org-journal-file-format "%Y-%m-%d.org"
        org-journal-file-type 'daily
        org-journal-enable-agenda-integration t))

;; ─── Atajos para Org ───────────────────────────────────────────
(map! :map org-mode-map
      :n "C-c n" #'org-journal-new-entry
      :n "C-c r" #'org-roam-node-find
      :n "C-c i" #'org-roam-node-insert
      :n "C-c R" #'org-roam-random-note)

(map! :leader
      :desc "Org capture" "n c" #'org-capture
      :desc "Org agenda"  "n a" #'org-agenda
      :desc "Org roam"    "n r" #'org-roam-node-find
      :desc "Org journal" "n j" #'org-journal-new-entry)

;; ─── Favoritos: consult-theme solo con mis temas preferidos ──────────
;; Uso: SPC h d r
;;
;; La preview funciona igual que consult-theme gracias a que Doom ya tiene
;; configurado :preview-key '("C-SPC" :debounce 0.5 any) para consult-theme.
;; Al heredar esa configuración, la preview es automática al navegar.

(defvar my/favorite-themes
  '(doom-tomorrow-day        ;; tu tema actual
    doom-one-light
    doom-ayu-light
    doom-plain
    doom-earl-grey
    doom-opera-light
    doom-solarized-light

    doom-spacegrey
    doom-miramare
    doom-zenburn
    doom-gruvbox
    doom-sourcerer
    doom-lantern
    doom-1337
    doom-plain-dark
    doom-wilmersdorf
    doom-one
    doom-horizon
    doom-dracula
    doom-solarized-dark
    doom-city-lights
    doom-challenger-deep)     ;; oscuro (demo)
  "Lista de símbolos de temas para `my/consult-theme-favorites'.
Agrega o quita temas a tu gusto.")

(defun my/consult-theme-favorites ()
  "Como `consult-theme', pero limitado a `my/favorite-themes'.
Temporalmente filtra `custom-available-themes' con `cl-letf'."
  (interactive)
  (let ((orig-fn (symbol-function 'custom-available-themes)))
    (cl-letf (((symbol-function 'custom-available-themes)
               (lambda ()
                 (seq-filter
                  (lambda (theme) (memq theme my/favorite-themes))
                  (funcall orig-fn)))))
      (call-interactively #'consult-theme))))

;; ─── Atajo: SPC h d r para temas favoritos ───────────────────────────
;; SPC h t   → consult-theme  (todos los temas)
;; SPC h d r → my/consult-theme-favorites  (solo tus favoritos)
(map! :leader
      :desc "Temas favoritos (consult-theme limitado)"
      "h d r" #'my/consult-theme-favorites)
