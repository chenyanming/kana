;;; kana.el --- Review hiragana and katakana -*- lexical-binding: t; -*-

;; Copyright (C) 2020 Damon Chan

;; Author: Damon Chan <elecming@gmail.com>
;; URL: https://github.com/chenyanming/kana
;; Keywords: tools
;; Created: 23 May 2020
;; Version: 1.0.0
;; Package-Requires: ((emacs "24.4"))

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <http://www.gnu.org/licenses/>.

;;; Commentary:

;; Learn Japanese Kana in Emacs.

;;; Code:

(defvar kana-mode-map
  (let ((map (make-sparse-keymap)))
    (define-key map "v" #'kana-validate)
    (define-key map "s" #'kana-say-question)
    (define-key map "p" #'kana-previous)
    (define-key map "n" #'kana-next)
    (define-key map "t" #'kana-toggle-kana)
    (define-key map "r" #'kana-toggle-random)
    (define-key map "l" #'kana-loop-toggle)
    (define-key map "]" #'kana-loop-inc)
    (define-key map "[" #'kana-loop-dec)
    (define-key map "a" #'kana-first)
    (define-key map "j" #'kana-jump)
    (define-key map "q" #'kana-quit)
    map)
  "Keymap for `kana-mode'.")

(defvar kana-hiragana-table
  '(
    "あ"  "い"  "う"  "え"  "お"
    "か"  "き"  "く"  "け"  "こ"  "きゃ"  "きゅ"  "きょ"
    "さ"  "し"  "す"  "せ"  "そ"  "しゃ"  "しゅ"  "しょ"
    "た"  "ち"  "つ"  "て"  "と"  "ちゃ"  "ちゅ"  "ちょ"
    "な"  "に"  "ぬ"  "ね"  "の"  "にゃ"  "にゅ"  "にょ"
    "は"  "ひ"  "ふ"  "へ"  "ほ"  "ひゃ"  "ひゅ"  "ひょ"
    "ま"  "み"  "む"  "め"  "も"  "みゃ"  "みゅ"  "みょ"
    "や"  "ゆ"  "よ"
    "ら"  "り"  "る"  "れ"  "ろ"  "りゃ"  "りゅ"  "りょ"
    "わ"  "を"
    "ん"
    "が"  "ぎ"  "ぐ"  "げ"  "ご"   "ぎゃ"  "ぎゅ"  "ぎょ"
    "ざ"  "じ"  "ず"  "ぜ"  "ぞ"   "じゃ"  "じゅ"  "じょ"
    "だ"  "ぢ"  "づ"  "で"  "ど"   "ぢゃ"  "ぢゅ"  "ぢょ"
    "ば"  "び"  "ぶ"  "べ"  "ぼ"   "びゃ"  "びゅ"  "びょ"
    "ぱ"  "ぴ"  "ぷ"  "ぺ"  "ぽ"   "ぴゃ"  "ぴゅ"  "ぴょ")
  "Hiragana table extracted from https://en.wikipedia.org/wiki/Hiragana.")


(defvar kana-hiragana-romaji-table
  '(
    "a"     "i"     "u"     "e"     "o"
    "ka"    "ki "   "ku"    "ke"    "ko"    "kya"    "kyu"   "kyo"
    "sa"    "shi"   "su"    "se"    "so"    "sha"    "shu"   "sho"
    "ta"    "chi"   "tsu"   "te"    "to"    "cha"    "chu"   "cho"
    "na"    "ni"    "nu"    "ne"    "no"    "nya"    "nyu"   "nyo"
    "ha"    "hi"    "fu"    "he"    "ho"    "hya"    "hyu"   "hyo"
    "ma"    "mi"    "mu"    "me"    "mo"    "mya"    "myu"   "myo"
    "ya"    "yu"    "yo"
    "ra"    "ri"    "ru"    "re"    "ro"    "rya"    "ryu"   "ryo"
    "wa"    "wo"
    "n"
    "ga"  "gi"  "gu"  "ge"  "go"  "gya"  "gyu"   "gyo"
    "za"  "ji"  "zu"  "ze"  "zo"  "ja"   "ju"   "jo"
    "da"  "ji"  "zu"  "de"  "do"  "ja"   "ju"   "jo"
    "ba"  "bi"  "bu"  "be"  "bo"  "bya"  "byu"   "byo"
    "pa"  "pi"  "pu"  "pe"  "po"  "pya"  "pyu"   "pyo")
  "Hiragana romaji table extracted from https://en.wikipedia.org/wiki/Hiragana.")


(defvar kana-katakana-table
  '(
    "ア"  "イ"   "ウ"   "エ"  "オ"
    "カ"  "キ"   "ク"   "ケ"  "コ"  "キャ"  "キュ"  "キョ"
    "サ"  "シ"   "ス"   "セ"  "ソ"  "シャ"  "シュ"  "ショ"
    "タ"  "チ"   "ツ"   "テ"  "ト"  "チャ"  "チュ"  "チョ"
    "ナ"  "ニ"   "ヌ"   "ネ"  "ノ"  "ニャ"  "ニュ"  "ニョ"
    "ハ"  "ヒ"   "フ"   "ヘ"  "ホ"  "ヒャ"  "ヒュ"  "ヒョ"
    "マ"  "ミ"   "ム"   "メ"  "モ"  "ミャ"  "ミュ"  "ミョ"
    "ヤ"  "ユ"   "ヨ"
    "ラ"  "リ"   "ル"   "レ"  "ロ"  "リャ"  "リュ"  "リョ"
    "ワ"  "を"
    "ン"
    "ガ"  "ギ"   "グ"   "ゲ"  "ゴ"  "ギャ"  "ギュ"  "ギョ"
    "ザ"  "ジ"   "ズ"   "ゼ"  "ゾ"  "ジャ"  "ジュ"  "ジョ"
    "ダ"  "ヂ"   "ヅ"   "デ"  "ド"  "ヂャ"  "ヂュ"  "ヂョ"
    "バ"  "ビ"   "ブ"   "ベ"  "ボ"  "ビャ"  "ビュ"  "ビョ"
    "パ"  "ピ"   "プ"   "ペ"  "ポ"  "ピャ"  "ピュ"  "ピョ")
  "Katakana table extracted from https://en.wikipedia.org/wiki/Katakana.")

(defvar kana-katakana-romaji-table
  '(
    "a"  "i"  "u"  "e"  "o"
    "ka"  "ki "  "ku "  "ke"  "ko"  "kya"   "kyu"   "kyo"
    "sa"  "shi"  "su "  "se"  "so"  "sha"   "shu"   "sho"
    "ta"  "chi"  "tsu"  "te"  "to"  "cha"   "chu"   "cho"
    "na"  "ni"  "nu"  "ne"  "no"  "nya"   "nyu"   "nyo"
    "ha"  "hi"  "fu"  "he"  "ho"  "hya"   "hyu"   "hyo"
    "ma"  "mi"  "mu"  "me"  "mo"  "mya"   "myu"   "myo"
    "ya"  "yu"  "yo"
    "ra"  "ri"  "ru"  "re"  "ro"  "rya"   "ryu"   "ryo"
    "wa"  "wo"
    "n"
    "ga"  "gi"  "gu"  "ge"  "go"  "gya"   "gyu"   "gyo"
    "za"  "ji"  "zu"  "ze"  "zo"  "ja "   "ju "   "jo"
    "da"  "ji"  "zu"  "de"  "do"  "ja "   "ju "   "jo"
    "ba"  "bi"  "bu"  "be"  "bo"  "bya"   "byu"   "byo"
    "pa"  "pi"  "pu"  "pe"  "po"  "pya"   "pyu"   "pyo")
  "Katakana romaji table extracted from https://en.wikipedia.org/wiki/Katakana.")

(defvar kana-header-function #'kana-header)
(defvar kana-toggle-kana t)
(defvar kana-loop-toggle nil)
(defvar kana-in-sequence nil)
(defvar kana-number 0)
(defvar kana-last-number 0)
(defvar kana-loop-speed 1.0)

(defface kana-question-face '((t :inherit default :height 4.0))
  "Face used for question"
  :group 'kana-faces)

(defface kana-romaji-face '((t :inherit font-lock-string-face :height 4.0))
  "Face used for romaji"
  :group 'kana-faces)

(defface kana-answer-face '((t :inherit font-lock-keyword-face :height 4.0))
  "Face used for answer"
  :group 'kana-faces)

(defun kana-mode ()
  "Major mode for kana.
\\{kana-mode-map}"
  (interactive)
  (kill-all-local-variables)
  (use-local-map kana-mode-map)
  (setq major-mode 'kana-mode
        mode-name "kana-mode"
        truncate-lines t
        buffer-read-only t
        header-line-format '(:eval (funcall kana-header-function)))
  (buffer-disable-undo)
  (add-hook 'kill-buffer-hook '(lambda () (when kana-loop-toggle (setq kana-loop-toggle nil) (kana-loop-stop))) nil :local)
  (run-mode-hooks 'kana-mode-hook))

(defun kana-header ()
  "Header function for *kana* buffer."
  (format "%s  %s  %s %s %s  %s  %s  %s  %s  %s"
          (concat (propertize "t" 'face 'bold) (if kana-toggle-kana ":Hiragana 平仮名" ":Katakana 片仮名"))
          (concat (propertize "r" 'face 'bold) (if kana-in-sequence ":in sequence" ":random"))
          (concat (propertize "l" 'face 'bold) (if kana-loop-toggle ":loop" ":normal"))
          (if kana-loop-toggle (concat "(+" (number-to-string kana-loop-speed) "s) ") "")
          (concat (propertize "v" 'face 'bold) "alidate")
          (concat (propertize "s" 'face 'bold) "ay")
          (concat (propertize "n" 'face 'bold) "ext")
          (concat (propertize "p" 'face 'bold) "revious")
          (concat (propertize "j" 'face 'bold) "ump")
          (concat (propertize "q" 'face 'bold) "uit")))

(defun kana-toggle-kana ()
  "Toggle hiragana or katakana."
  (interactive)
  (setq kana-toggle-kana (if kana-toggle-kana nil t))
  (kana kana-number))

(defun kana-toggle-random ()
  "Toggle kana show in random or in sequence."
  (interactive)
  (setq kana-in-sequence (if kana-in-sequence nil t))
  (kana kana-number))

(defun kana-previous ()
  "Previous kana."
  (interactive)
  (if kana-in-sequence
      (progn
       (if (> kana-number 0)
           (setq kana-number (1- kana-number))
         (setq kana-number (1- (length kana-hiragana-table))))
       (kana kana-number))
    (kana kana-last-number)))

(defun kana-next ()
  "Next kana."
  (interactive)
  (if kana-in-sequence
      (progn
       (if (< kana-number (1- (length kana-hiragana-table)))
           (setq kana-number (1+ kana-number))
         (setq kana-number 0))
       (kana kana-number))
    (kana)))

(defun kana-first ()
  "Go to first kana - あ."
  (interactive)
  (kana 0)
  (message "あ"))

(defun kana (&optional index)
  "Start to lean kana.
Optional argument INDEX is the number of kana in the list."
  (interactive)
  (switch-to-buffer (get-buffer-create "*kana*"))
  (setq buffer-read-only nil)
  (erase-buffer)
  (setq kana-last-number kana-number)
  (let* ((w (window-width))
         (h (window-height))
         (hsep (cond ((> w 26) "   ")
                     ((> w 20) " ")
                     (t "")))
         (vsep (cond ((> h 17) "\n\n")
                     (t "\n")))
         (indent (make-string (/ (- w 7 (* 6 (length hsep))) 2) ?\s))
         (temp-table (if kana-toggle-kana
                         kana-hiragana-table
                       kana-katakana-table))
         (number (or index (if kana-in-sequence
                               kana-number
                               (random (1- (length temp-table))))))
         (question (nth number temp-table))
         beg end)
    (setq kana-number number)
    (insert (make-string (/ (- h 7 (if (> h 12) 3 0)
                               (* 6 (1- (length vsep)))) 2) ?\n))
    (when (or (string= vsep "\n\n") (> h 12))
      (insert indent)
      (setq beg (point))
      (insert (format "%s " (propertize question
                                         'face 'kana-question-face
                                         'mouse-face 'mode-line-highlight
                                         'help-echo (format "https://en.wikipedia.org/wiki/%s" question))))
      (setq end (point))
      (put-text-property beg end 'question question)
      (put-text-property beg end 'indent indent))
    (let ((map (make-sparse-keymap)))
      (define-key map [mouse-1] 'kana-mouse-1)
      (define-key map [mouse-3] 'kana-mouse-3)
      (put-text-property beg end 'keymap map))
    (goto-char (point-min))             ; cursor is always in the (point-min)
    (kana-say-question))
  (setq buffer-read-only t)
  (unless (eq major-mode 'kana-mode)
    (kana-mode)))

(defun kana-mouse-1 (event)
  "Browser the url click on with eww.
Argument EVENT mouse event."
  (interactive "e")
  ;; (message "click mouse-3")
  (let ((window (posn-window (event-end event)))
        (pos (posn-point (event-end event))))
    (if (not (windowp window))
        (error "No URL chosen"))
    (with-current-buffer (window-buffer window)
      (goto-char pos)
      (eww-browse-url (get-text-property (point) 'help-echo)))))

(defun kana-mouse-3 (event)
  "Browser the url click on with browser.
Argument EVENT mouse event."
  (interactive "e")
  ;; (message "click mouse-3")
  (let ((window (posn-window (event-end event)))
        (pos (posn-point (event-end event))))
    (if (not (windowp window))
        (error "No URL chosen"))
    (with-current-buffer (window-buffer window)
      (goto-char pos)
      (browse-url (get-text-property (point) 'help-echo)))))

(defun kana-loop-toggle ()
  "Enter or quit Kana loop."
  (interactive)
  (if (setq kana-loop-toggle (if kana-loop-toggle nil t))
      (progn
        (kana kana-number)
        (kana-loop-start))
    (progn
      (kana kana-number)
      (kana-loop-stop))))

(defun kana-loop-start ()
  "Start kana loop."
  (when (eq major-mode 'kana-mode)
    (run-with-timer 0 kana-loop-speed 'kana-validate)
    (kana kana-number)
    (message "Start kana loop")))

(defun kana-loop-stop ()
  "Stop kana loop."
  (cancel-function-timers 'kana-validate)
  (message "Stop kana loop"))

(defun kana-loop-inc ()
  "Increse the repeat timer of kana loop."
  (interactive)
  (setq kana-loop-speed (+ kana-loop-speed 0.5))
  (message (number-to-string kana-loop-speed))
  (cancel-function-timers 'kana-validate)
  (kana-loop-start))

(defun kana-loop-dec ()
  "Decrease the repeat timer of kana loop."
  (interactive)
  (if (> kana-loop-speed 1)
      (setq kana-loop-speed (- kana-loop-speed 0.5)))
  (message (number-to-string kana-loop-speed))
  (cancel-function-timers 'kana-validate)
  (kana-loop-start))

(defun kana-validate ()
  "Validate the kana."
  (interactive)
  (let* ((buffer-read-only nil)
         (temp-table (if kana-toggle-kana
                         kana-hiragana-table
                       kana-katakana-table))
         (temp-table-other (if (not kana-toggle-kana)
                               kana-hiragana-table
                             kana-katakana-table))
         (temp-romaji-table (if kana-toggle-kana
                                kana-hiragana-romaji-table
                              kana-katakana-romaji-table))
         (question-location (text-property-not-all (point-min) (point-max) 'question nil))
         (question (save-excursion
                     (goto-char question-location)
                     (get-text-property (point) 'question)))
         (indent (save-excursion
                   (goto-char (text-property-not-all (point-min) (point-max) 'indent nil))
                   (get-text-property (point) 'indent)))
         (answer (save-excursion
                   (goto-char (or (text-property-not-all (point-min) (point-max) 'answer nil) (point)))
                   (get-text-property (point) 'answer)))
         (actual-answer (nth (-elem-index question temp-table) temp-romaji-table))
         (actual-answer-other (nth (-elem-index question temp-table) temp-table-other))
         beg end)
    (if (equal answer actual-answer)
        (if kana-in-sequence
            (kana-next)
          (kana))
      (save-excursion
        (progn
          (goto-char question-location)
          (forward-line 1)
          (insert "\n")
          (insert indent)
          (setq beg (point))
          (insert (propertize actual-answer 'face 'kana-romaji-face))
          (setq end (point))
          (put-text-property beg end 'answer actual-answer)
          (insert "\n")
          (insert indent)
          (insert (propertize actual-answer-other 'face 'kana-answer-face))
          (insert "\n")) ))))

(defun kana-say-question ()
  "Read the question out."
  (interactive)
  (let ((question (save-excursion
                (goto-char (text-property-not-all (point-min) (point-max) 'question nil))
                (get-text-property (point) 'question))))
    (if (eq system-type 'darwin)
        (call-process-shell-command
         (format "say -v Kyoko %s" question) nil 0)
      (let ((player (or (executable-find "mpv")
                        (executable-find "mplayer")
                        (executable-find "mpg123"))))
        (if player
            (start-process
             player
             nil
             player
             (format "http://dict.youdao.com/dictvoice?type=2&audio=%s" (url-hexify-string question)))
          (message "mpv, mplayer or mpg123 is needed to play word voice"))))))

(defun kana-quit ()
  "Quit kana."
  (interactive)
  (if (eq major-mode 'kana-mode)
      (if (get-buffer "*kana*")
          (kill-buffer "*kana*"))))

(defun kana-jump ()
  "Jump to kana."
  (interactive)
  (kana (if kana-toggle-kana
            (-elem-index
             (car (split-string
                   (completing-read
                    "Hiragana: "
                    (cl-mapcar
                     '(lambda (a b) (concat a " " b))
                     kana-hiragana-table
                     kana-hiragana-romaji-table)) " ") )
             kana-hiragana-table)
          (-elem-index
           (car (split-string
                 (completing-read
                  "Katakana: "
                  (cl-mapcar
                   '(lambda (a b) (concat a " " b))
                   kana-katakana-table
                   kana-katakana-romaji-table)) " ") )
           kana-katakana-table))))

(provide 'kana)

;;; kana.el ends here
