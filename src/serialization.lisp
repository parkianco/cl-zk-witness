;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: BSD-3-Clause
;;;;
;;;; Witness serialization

(in-package :cl-zk-witness)

;;; ============================================================================
;;; Binary Serialization
;;; ============================================================================

(defun serialize-witness (witness)
  "Serialize witness to byte vector."
  (let ((bytes nil))
    ;; Header: magic + version
    (push #x57 bytes)  ; 'W'
    (push #x49 bytes)  ; 'I'
    (push #x54 bytes)  ; 'T'
    (push #x01 bytes)  ; version 1
    ;; Counts
    (let ((pub-count (assignment-map-size (witness-public witness)))
          (priv-count (assignment-map-size (witness-private witness)))
          (aux-count (assignment-map-size (witness-aux witness))))
      ;; 4-byte counts (big-endian)
      (dolist (count (list pub-count priv-count aux-count))
        (push (ldb (byte 8 24) count) bytes)
        (push (ldb (byte 8 16) count) bytes)
        (push (ldb (byte 8 8) count) bytes)
        (push (ldb (byte 8 0) count) bytes)))
    ;; Serialize each map
    (dolist (map (list (witness-public witness)
                       (witness-private witness)
                       (witness-aux witness)))
      (maphash (lambda (idx entry)
                 ;; 4-byte index
                 (push (ldb (byte 8 24) idx) bytes)
                 (push (ldb (byte 8 16) idx) bytes)
                 (push (ldb (byte 8 8) idx) bytes)
                 (push (ldb (byte 8 0) idx) bytes)
                 ;; 32-byte value (big-endian)
                 (let ((val (wire-assignment-value entry)))
                   (dotimes (i 32)
                     (push (ldb (byte 8 (* 8 (- 31 i))) val) bytes))))
               (assignment-map-entries map)))
    (coerce (nreverse bytes) '(vector (unsigned-byte 8)))))

(defun deserialize-witness (bytes)
  "Deserialize witness from byte vector."
  (let ((pos 0)
        (witness (make-empty-witness)))
    ;; Check header
    (unless (and (= (aref bytes 0) #x57)
                 (= (aref bytes 1) #x49)
                 (= (aref bytes 2) #x54)
                 (= (aref bytes 3) #x01))
      (error "Invalid witness format"))
    (setf pos 4)
    ;; Read counts
    (flet ((read-u32 ()
             (prog1
                 (logior (ash (aref bytes pos) 24)
                         (ash (aref bytes (+ pos 1)) 16)
                         (ash (aref bytes (+ pos 2)) 8)
                         (aref bytes (+ pos 3)))
               (incf pos 4)))
           (read-u256 ()
             (let ((val 0))
               (dotimes (i 32)
                 (setf val (logior (ash val 8) (aref bytes pos)))
                 (incf pos))
               val)))
      (let ((pub-count (read-u32))
            (priv-count (read-u32))
            (aux-count (read-u32)))
        ;; Read public
        (dotimes (i pub-count)
          (declare (ignorable i))
          (let ((idx (read-u32))
                (val (read-u256)))
            (assign-public witness idx val)))
        ;; Read private
        (dotimes (i priv-count)
          (declare (ignorable i))
          (let ((idx (read-u32))
                (val (read-u256)))
            (assign-private witness idx val)))
        ;; Read aux
        (dotimes (i aux-count)
          (declare (ignorable i))
          (let ((idx (read-u32))
                (val (read-u256)))
            (assign-aux witness idx val)))))
    witness))

;;; ============================================================================
;;; Vector Conversion
;;; ============================================================================

(defun witness-to-vector (witness)
  "Convert witness to flat vector of (1, public..., private..., aux...)."
  (let ((values (list 1)))  ; Wire 0 is always 1
    (dolist (entries (list (get-public-inputs witness)
                           (get-private-inputs witness)))
      (dolist (val entries)
        (push val values)))
    ;; Add aux values
    (let ((aux-entries nil))
      (maphash (lambda (k v)
                 (declare (ignore k))
                 (push v aux-entries))
               (assignment-map-entries (witness-aux witness)))
      (dolist (entry (sort aux-entries #'< :key #'wire-assignment-index))
        (push (wire-assignment-value entry) values)))
    (coerce (nreverse values) 'vector)))

(defun vector-to-witness (vec num-public num-private)
  "Convert vector back to witness structure."
  (let ((witness (make-empty-witness)))
    ;; Skip wire 0 (constant 1)
    (loop for i from 1 to num-public
          when (< i (length vec))
          do (assign-public witness (1- i) (aref vec i)))
    (loop for i from (1+ num-public) to (+ num-public num-private)
          when (< i (length vec))
          do (assign-private witness (- i num-public 1) (aref vec i)))
    (loop for i from (+ 1 num-public num-private) below (length vec)
          do (assign-aux witness (- i num-public num-private 1) (aref vec i)))
    witness))

;;; ============================================================================
;;; JSON Export/Import
;;; ============================================================================

(defun export-witness-json (witness stream)
  "Export witness as JSON to stream."
  (format stream "{~%")
  (format stream "  \"public\": [")
  (let ((first t))
    (dolist (val (get-public-inputs witness))
      (if first (setf first nil) (format stream ", "))
      (format stream "\"~a\"" val)))
  (format stream "],~%")
  (format stream "  \"private\": [")
  (let ((first t))
    (dolist (val (get-private-inputs witness))
      (if first (setf first nil) (format stream ", "))
      (format stream "\"~a\"" val)))
  (format stream "]~%")
  (format stream "}~%"))

(defun import-witness-json (string)
  "Import witness from JSON string (simplified parser)."
  (let ((witness (make-empty-witness))
        (pub-start (search "\"public\":" string))
        (priv-start (search "\"private\":" string)))
    (when pub-start
      (let* ((arr-start (position #\[ string :start pub-start))
             (arr-end (position #\] string :start arr-start)))
        (when (and arr-start arr-end)
          (let ((idx 0))
            (loop for pos = (1+ arr-start) then (1+ end)
                  for start = (position #\" string :start pos :end arr-end)
                  while start
                  for end = (position #\" string :start (1+ start) :end arr-end)
                  while end
                  do (let ((val (parse-integer (subseq string (1+ start) end))))
                       (assign-public witness idx val)
                       (incf idx)))))))
    (when priv-start
      (let* ((arr-start (position #\[ string :start priv-start))
             (arr-end (position #\] string :start arr-start)))
        (when (and arr-start arr-end)
          (let ((idx 0))
            (loop for pos = (1+ arr-start) then (1+ end)
                  for start = (position #\" string :start pos :end arr-end)
                  while start
                  for end = (position #\" string :start (1+ start) :end arr-end)
                  while end
                  do (let ((val (parse-integer (subseq string (1+ start) end))))
                       (assign-private witness idx val)
                       (incf idx)))))))
    witness))
