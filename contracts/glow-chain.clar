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

;; Public Functions

;; Create a new skincare routine
(define-public (create-routine (name (string-ascii 50)) (description (string-ascii 500)) (products (list 20 (string-ascii 50))) (is-public bool))
    (begin
        ;; Validate inputs - add any specific business rules
        (asserts! (> (len name) u0) (err u104)) ;; Name cannot be empty
        (asserts! (> (len description) u0) (err u105)) ;; Description cannot be empty
        
        (let
            ((new-routine-id (+ (var-get routine-id-nonce) u1)))
            (begin
                (asserts! (<= (len name) u50) (err u106)) ;; Name length exceeds limit
                (asserts! (<= (len description) u500) (err u107)) ;; Description length exceeds limit
                (asserts! (<= (len products) u20) (err u108)) ;; Products list exceeds limit
                (create-routine-internal new-routine-id name description products is-public)
            )
            (update-user-stats-routines tx-sender)
            (var-set routine-id-nonce new-routine-id)
            (ok new-routine-id)
        )
    )
)

;; Add a progress record
(define-public (add-progress-record (routine-id uint) (note (string-ascii 500)) (photo-hash (string-ascii 64)))
    (begin
        ;; Validate inputs
        (asserts! (> routine-id u0) (err u106)) ;; Invalid routine ID
        (asserts! (> (len photo-hash) u0) (err u107)) ;; Photo hash cannot be empty
        (asserts! (> (len note) u0) (err u109)) ;; Note cannot be empty
        (asserts! (<= (len note) u500) (err u110)) ;; Note length exceeds limit
        
        (let
            ((new-record-id (+ (var-get record-id-nonce) u1))
             (routine (get-routine routine-id)))
            (asserts! (is-some routine) err-not-found)
            (asserts! (is-eq (get owner (unwrap-panic routine)) tx-sender) err-unauthorized)
            
            (map-insert progress-records
                { record-id: new-record-id }
                {
                    owner: tx-sender,
                    routine-id: routine-id,
                    note: note,
                    photo-hash: photo-hash,
                    timestamp: stacks-block-height,
                    likes: u0
                }
            )
            (update-user-stats-records tx-sender)
            (var-set record-id-nonce new-record-id)
            (ok new-record-id)
        )
    )
)

;; Follow another user
(define-public (follow-user (user principal))
    (begin
        (asserts! (not (is-eq tx-sender user)) err-unauthorized)
        (map-insert follows
            { follower: tx-sender, following: user }
            { timestamp: stacks-block-height }
        )
        (update-follow-stats tx-sender user)
        (ok true)
    )
)

;; Like a routine
(define-public (like-routine (routine-id uint))
    (let
        (
            (routine (get-routine routine-id))
        )
        (asserts! (is-some routine) err-not-found)
        (map-insert routine-likes
            { user: tx-sender, routine-id: routine-id }
            { timestamp: stacks-block-height }
        )
        (increment-routine-likes routine-id)
        (ok true)
    )
)

;; Like a progress record
(define-public (like-record (record-id uint))
    (let
        (
            (record (get-progress-record record-id))
        )
        (asserts! (is-some record) err-not-found)
        (map-insert record-likes
            { user: tx-sender, record-id: record-id }
            { timestamp: stacks-block-height }
        )
        (increment-record-likes record-id)
        (ok true)
    )
)

;; Private Functions

(define-private (create-routine-internal (id uint) (name (string-ascii 50)) (description (string-ascii 500)) (products (list 20 (string-ascii 50))) (is-public bool))
    (map-insert routines
        { routine-id: id }
        {
            owner: tx-sender,
            name: name,
            description: description,
            products: products,
            created-at: stacks-block-height,
            is-public: is-public,
            likes: u0
        }
    )
)

(define-private (update-user-stats-routines (user principal))
    (let
        (
            (stats (default-to 
                { routines-created: u0, records-created: u0, followers: u0, following: u0 }
                (map-get? user-stats { user: user })
            ))
        )
        (map-set user-stats
            { user: user }
            (merge stats { routines-created: (+ (get routines-created stats) u1) })
        )
    )
)

(define-private (update-user-stats-records (user principal))
    (let
        (
            (stats (default-to
                { routines-created: u0, records-created: u0, followers: u0, following: u0 }
                (map-get? user-stats { user: user })
            ))
        )
        (map-set user-stats
            { user: user }
            (merge stats { records-created: (+ (get records-created stats) u1) })
        )
    )
)

(define-private (update-follow-stats (follower principal) (following principal))
    (let
        (
            (follower-stats (default-to
                { routines-created: u0, records-created: u0, followers: u0, following: u0 }
                (map-get? user-stats { user: follower })
            ))
            (following-stats (default-to
                { routines-created: u0, records-created: u0, followers: u0, following: u0 }
                (map-get? user-stats { user: following })
            ))
        )
        (map-set user-stats
            { user: follower }
            (merge follower-stats { following: (+ (get following follower-stats) u1) })
        )
        (map-set user-stats
            { user: following }
            (merge following-stats { followers: (+ (get followers following-stats) u1) })
        )
    )
)

(define-private (increment-routine-likes (routine-id uint))
    (let
        (
            (routine-opt (get-routine routine-id))
        )
        (if (is-some routine-opt)
            (let
                (
                    (routine (unwrap-panic routine-opt))
                )
                (map-set routines
                    { routine-id: routine-id }
                    (merge routine { likes: (+ (get likes routine) u1) })
                )
            )
            false
        )
    )
)

(define-private (increment-record-likes (record-id uint))
    (let
        (
            (record-opt (get-progress-record record-id))
        )
        (if (is-some record-opt)
            (let
                (
                    (record (unwrap-panic record-opt))
                )
                (map-set progress-records
                    { record-id: record-id }
                    (merge record { likes: (+ (get likes record) u1) })
                )
            )
            false
        )
    )
)

;; Read Only Functions

(define-read-only (get-routine (routine-id uint))
    (map-get? routines { routine-id: routine-id })
)

(define-read-only (get-progress-record (record-id uint))
    (map-get? progress-records { record-id: record-id })
)

(define-read-only (get-user-stats (user principal))
    (map-get? user-stats { user: user })
)

(define-read-only (is-following (follower principal) (following principal))
    (is-some (map-get? follows { follower: follower, following: following }))
)

(define-read-only (has-liked-routine (user principal) (routine-id uint))
    (is-some (map-get? routine-likes { user: user, routine-id: routine-id }))
)

(define-read-only (has-liked-record (user principal) (record-id uint))
    (is-some (map-get? record-likes { user: user, record-id: record-id }))
)