;;; -*- Mode:Lisp; Syntax:ANSI-Common-Lisp; Coding:utf-8 -*-

(in-package #:cl-num-utils)

;;;; An interval is an ordered pair of real numbers.  It is not
;;;; necessarily decreasing, as there can be negative intervals (eg
;;;; for reverse plots), but some functions (eg interval-containing
;;;; and interval-intersection) return positive intervals by
;;;; construction.

(defstruct interval
  "A pair of numbers designating an interval on the real line.  Using the
constructor INTERVAL, LEFT <= RIGHT is enforced."
  (left 0 :type real :read-only t)
  (right 0 :type real :read-only t))

(define-structure-let+ (interval) left right)

(declaim (inline interval))

(defun interval (left right)
  "Create an INTERVAL."
  (assert (<= left right) ())
  (make-interval :left left :right right))

(defun interval-length (interval)
  "Difference between left and right."
  (- (interval-right interval) (interval-left interval)))

(defun interval-midpoint (interval &optional (alpha 1/2))
  "Convex combination of left and right, with alpha (defaults to 0.5)
weight on right."
  (let+ (((&interval left right) interval))
    (+ (* (- 1 alpha) left) (* alpha right))))

(defun in-interval? (interval number)
  "Test if NUMBER is in INTERVAL (which can be NIL, designating the empty
set)."
  (and interval
       (let+ (((&interval left right) interval))
         (<= left number right))))

(defgeneric extend-interval (interval object)
  (:documentation "Return an interval that includes INTERVAL and OBJECT.  NIL
stands for the empty set.")
  (:method ((interval null) (object null))
    nil)
  (:method ((interval null) (number real))
    (interval number number))
  (:method ((interval interval) (number real))
    (let+ (((&interval left right) interval))
      (if (<= left number right)
          interval
          (interval (min left number) (max right number)))))
  (:method (interval (object interval))
    (let+ (((&interval left right) object))
      (extend-interval (extend-interval interval left) right)))
  (:method (interval (list list))
    (reduce #'extend-interval list :initial-value interval))
  (:method (interval (array array))
    (reduce #'extend-interval (flatten-array array) :initial-value interval)))

(defun interval-hull (object)
  "Return the smallest connected interval that contains (elements in) OBJECT."
  (extend-interval nil object))

;;; Interval manipulations

(defstruct (relative (:constructor relative (fraction)))
  "Relative sizes are in terms of width."
  ;; MAKE-RELATIVE is not exported
  (fraction nil :type (real 0) :read-only t))

(defstruct (spacer (:constructor spacer (&optional weight)))
  "Spacers divide the leftover portion of an interval."
  (weight 1 :type (real 0) :read-only t))

(defun split-interval (interval divisions)
  "Return a vector of subintervals (same length as DIVISIONS), splitting the
interval using the sequence DIVISIONS, which can be nonnegative real
numbers (or RELATIVE specifications) and SPACERs which divide the leftover
proportionally.  If there are no spacers and the divisions don't fill up the
interval, and error is signalled."
  (let+ ((length (interval-length interval))
	 (spacers 0)
	 (absolute 0)
         ((&flet absolute (x)
            (incf absolute x)
            x))
	 (divisions
          (map 'vector
               (lambda (div)
                 (etypecase div
                   (real (absolute div))
                   (relative (absolute (* length (relative-fraction div))))
                   (spacer (incf spacers (spacer-weight div))
                    div)))
               divisions))
	 (rest (- length absolute)))
    (when (minusp rest)
      (error "Length of divisions exceeds the width of the interval."))
    (assert (not (and (zerop spacers) (plusp rest))) ()
            "Divisions don't use up the interval.")
    (let* ((left (interval-left interval))
           (spacer-unit (/ rest spacers)))
      (map 'vector (lambda (div)
		     (let* ((step (etypecase div
                                    (number div)
                                    (spacer (* spacer-unit
                                               (spacer-weight div)))))
                            (right (+ left step)))
		       (prog1 (interval left right)
			 (setf left right))))
	   divisions))))

(defun shrink-interval (interval left 
                        &optional (right left)
                                  (check-flip? t))
  "Shrink interval by given magnitudes (which may be REAL or RELATIVE).  When
check-flip?, the result is checked for endpoints being in a different order
than the original.  Negative LEFT and RIGHT extend the interval."
  (let+ (((&interval l r) interval)
         (d (- r l))
         ((&flet absolute (ext)
            (etypecase ext
              (relative (* d (relative-fraction ext)))
              (real ext))))
         (l2 (+ l (absolute left)))
         (r2 (- r (absolute right))))
    (when check-flip?
      (assert (= (signum d) (signum (- r2 l2)))))
    (interval l2 r2)))
