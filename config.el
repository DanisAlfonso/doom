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
    (setq doom-theme 'doom-tomorrow-day)

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
