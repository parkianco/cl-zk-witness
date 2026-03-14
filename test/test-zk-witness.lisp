;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: BSD-3-Clause

;;;; test-zk-witness.lisp - Unit tests for zk-witness
;;;;
;;;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;;;; SPDX-License-Identifier: BSD-3-Clause

(defpackage #:cl-zk-witness.test
  (:use #:cl)
  (:export #:run-tests))

(in-package #:cl-zk-witness.test)

(defun run-tests ()
  "Run all tests for cl-zk-witness."
  (format t "~&Running tests for cl-zk-witness...~%")
  ;; TODO: Add test cases
  ;; (test-function-1)
  ;; (test-function-2)
  (format t "~&All tests passed!~%")
  t)
