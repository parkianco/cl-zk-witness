;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: Apache-2.0
;;;;
;;;; Wire assignment operations

(in-package :cl-zk-witness)

;;; ============================================================================
;;; Wire Assignment Functions
;;; ============================================================================

(defun assign-wire (witness wire-index value &key (type :private) label)
  "Assign value to wire in witness."
  (let ((map (ecase type
               (:public (witness-public witness))
               (:private (witness-private witness))
               (:aux (witness-aux witness))))
        (normalized-value (mod value +field-prime+)))
    (assignment-map-set map wire-index normalized-value label)))

(defun assign-public (witness wire-index value &optional label)
  "Assign public input."
  (assign-wire witness wire-index value :type :public :label label))

(defun assign-private (witness wire-index value &optional label)
  "Assign private witness value."
  (assign-wire witness wire-index value :type :private :label label))

(defun assign-aux (witness wire-index value &optional label)
  "Assign auxiliary value."
  (assign-wire witness wire-index value :type :aux :label label))

;;; ============================================================================
;;; Wire Access Functions
;;; ============================================================================

(defun get-wire-value (witness wire-index)
  "Get value of wire from any section."
  (or (let ((entry (assignment-map-get (witness-public witness) wire-index)))
        (when entry (wire-assignment-value entry)))
      (let ((entry (assignment-map-get (witness-private witness) wire-index)))
        (when entry (wire-assignment-value entry)))
      (let ((entry (assignment-map-get (witness-aux witness) wire-index)))
        (when entry (wire-assignment-value entry)))))

(defun get-public-inputs (witness)
  "Get list of public input values in index order."
  (let ((entries nil))
    (maphash (lambda (k v)
               (declare (ignore k))
               (push v entries))
             (assignment-map-entries (witness-public witness)))
    (mapcar #'wire-assignment-value
            (sort entries #'< :key #'wire-assignment-index))))

(defun get-private-inputs (witness)
  "Get list of private input values in index order."
  (let ((entries nil))
    (maphash (lambda (k v)
               (declare (ignore k))
               (push v entries))
             (assignment-map-entries (witness-private witness)))
    (mapcar #'wire-assignment-value
            (sort entries #'< :key #'wire-assignment-index))))

;;; ============================================================================
;;; Bulk Assignment
;;; ============================================================================

(defun assign-public-vector (witness values &key (start-index 0))
  "Assign vector of values to public inputs starting at index."
  (loop for value in (coerce values 'list)
        for idx from start-index
        do (assign-public witness idx value))
  witness)

(defun assign-private-vector (witness values &key (start-index 0))
  "Assign vector of values to private inputs starting at index."
  (loop for value in (coerce values 'list)
        for idx from start-index
        do (assign-private witness idx value))
  witness)
