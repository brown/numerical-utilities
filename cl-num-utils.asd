;;; Copyright Tamas Papp 2010.
;;;
;;; Distributed under the Boost Software License, Version 1.0.  (See
;;; accompanying file LICENSE_1_0.txt or copy at
;;; http://www.boost.org/LICENSE_1_0.txt)
;;;
;;; This copyright notice pertains to all files in this library.

(asdf:defsystem #:cl-num-utils
  :description "Numerical utilities for Common Lisp"
  :version "0.1"
  :author "Tamas K Papp <tkpapp@gmail.com>"
  :license "Boost Software License - Version 1.0"
  :encoding :utf-8
  :serial t
  :components
  ((:module
    "package-init"
    :pathname #P"src/"
    :components
    ((:file "package")))
   (:module
    "utilities"
    :pathname #P"src/"
    :serial t
    :components
    ((:file "macros")
     (:file "conditions")
     (:file "misc")
     (:file "arithmetic")
     (:file "elementwise")
     (:file "array")
     (:file "interval")
     (:file "pretty")
     (:file "bins")
     (:file "statistics")
     (:file "sub")
     (:file "data-frame")
     ;; (:file "interaction")
     (:file "optimization")
     (:file "differentiation")
     (:file "rootfinding")
     (:file "quadrature")
     (:file "chebyshev"))))
  :depends-on (#:anaphora #:alexandria #:extended-reals #:iterate #:let-plus))

(asdf:defsystem :cl-num-utils-tests
  :description "Unit tests for CL-NUM-UTILS.."
  :author "Tamas K Papp <tkpapp@gmail.com>"
  :license "Same as CL-NUM-UTILS -- this is part of the CL-NUM-UTILS library."
  :encoding :utf-8
  :serial t
  :components
  ((:module
    "package-init"
    :pathname #P"tests/"
    :components
    ((:file "package")))
   (:module
    "setup"
    :pathname #P"tests/"
    :components
    ((:file "setup")
     (:file "test-utilities")))
   (:module
    "tests"
    :pathname #P"tests/"
    :components
    ((:file "arithmetic")
     (:file "array")
     (:file "bins")
     (:file "sub")
     (:file "elementwise")
     (:file "statistics")
     (:file "interval")
     (:file "utilities")
     (:file "data-frame")
     ;; (:file "interactions")
     (:file "differentiation")
     (:file "rootfinding")
     (:file "quadrature")
     (:file "chebyshev"))))
  :depends-on (#:cl-num-utils #:lift))
