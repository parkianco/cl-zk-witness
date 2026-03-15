;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: Apache-2.0

(in-package #:cl-zk-witness)

(define-condition cl-zk-witness-error (error)
  ((message :initarg :message :reader cl-zk-witness-error-message))
  (:report (lambda (condition stream)
             (format stream "cl-zk-witness error: ~A" (cl-zk-witness-error-message condition)))))
