;; Copyright (c) 2024-2026 Parkian Company LLC. All rights reserved.
;; SPDX-License-Identifier: Apache-2.0

(in-package #:cl-zk-witness)

;;; Core types for cl-zk-witness
(deftype cl-zk-witness-id () '(unsigned-byte 64))
(deftype cl-zk-witness-status () '(member :ready :active :error :shutdown))
