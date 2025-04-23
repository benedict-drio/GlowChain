;; Title: GlowChain - Decentralized Skincare Journey Tracker
;;
;; Summary:
;; A Stacks blockchain smart contract for tracking skincare routines, progress, and
;; building a community of skincare enthusiasts on Bitcoin layer 2.
;;
;; Description:
;; This contract enables users to create personalized skincare routines, document their
;; progress with photos and notes, follow other users, and engage with the community
;; through likes and comments. Built on Stacks with Bitcoin's security foundations,
;; GlowChain provides transparent, decentralized tracking of skincare journeys.

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101)) 
(define-constant err-unauthorized (err u102))
(define-constant err-already-exists (err u103))

;; Data Variables
(define-map routines
    { routine-id: uint }
    {
        owner: principal,
        name: (string-ascii 50),
        description: (string-ascii 500),
        products: (list 20 (string-ascii 50)),
        created-at: uint,
        is-public: bool,
        likes: uint
    }
)

(define-map progress-records
    { record-id: uint }
    {
        owner: principal,
        routine-id: uint,
        note: (string-ascii 500),
        photo-hash: (string-ascii 64),
        timestamp: uint,
        likes: uint
    }
)

(define-map follows
    { follower: principal, following: principal }
    { timestamp: uint }
)

(define-map routine-likes
    { user: principal, routine-id: uint }
    { timestamp: uint }
)

(define-map record-likes
    { user: principal, record-id: uint }
    { timestamp: uint }
)

(define-map user-stats
    { user: principal }
    {
        routines-created: uint,
        records-created: uint,
        followers: uint,
        following: uint
    }
)

(define-data-var routine-id-nonce uint u0)
(define-data-var record-id-nonce uint u0)