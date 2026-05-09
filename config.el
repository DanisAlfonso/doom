;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; ─── Identificación ───────────────────────────────────────────
(setq user-full-name "DNR"
      user-mail-address "tu@email.com")

;; ─── Tamaño de ventana por defecto (más grande) ────────────
;; Ajusta los valores según tu pantalla y preferencia
(add-to-list 'default-frame-alist '(width . 110))   ;; caracteres de ancho
(add-to-list 'default-frame-alist '(height . 39))   ;; líneas de alto

;; ─── Fuentes ────────────
    (setq doom-font (font-spec :family "Maple Mono NF" :size 16)
      doom-variable-pitch-font (font-spec :family "SF Pro" :size 16)
      doom-big-font (font-spec :family "Maple Mono NF" :size 24))

;; Otras fuentes mono que tienes (cambia "Fira Code" si quieres probar):
;;   - "JetBrains Mono"
;;   - "Maple Mono"
;;   - "Monaspice" (o el nombre exacto: haz M-x describe-font para ver)
;;   - "Roboto Mono"
;;   - "Victor Mono"

;; ─── Tema ─────────────────────────────────────────────────────
    (setq doom-theme 'doom-spacegrey)

;; ─── Números de línea relativos (ideal para evil) ────────────
(setq display-line-numbers-type 'relative)

(defun my/apply-frame-transparency (&optional frame)
  "Apply macOS transparency parameters to FRAME (defaults to selected frame)."
  (with-selected-frame (or frame (selected-frame))
    (set-frame-parameter nil 'alpha-background 0.7)
    (set-frame-parameter nil 'ns-background-blur 30)
    (set-frame-parameter nil 'ns-alpha-elements '(ns-alpha-all))))

;; ns-background-blur must be in default-frame-alist to configure the
;; NSWindow backing material at frame creation time (required for blur).
;; This ensures emacsclient frames inherit it automatically.
(add-to-list 'default-frame-alist '(ns-background-blur . 30))
(add-to-list 'default-frame-alist '(ns-alpha-elements ns-alpha-all))

(add-hook 'after-make-frame-functions #'my/apply-frame-transparency)
(unless (daemonp)
  (add-hook 'window-setup-hook #'my/apply-frame-transparency))

;; Apply transparency immediately for non-daemon graphical startup,
;; where neither after-make-frame-functions nor window-setup-hook fires.
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

(add-to-list 'default-frame-alist '(undecorated-round . t))
