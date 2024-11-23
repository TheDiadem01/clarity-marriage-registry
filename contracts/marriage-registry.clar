;; Digital Marriage Registry Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-already-married (err u101))
(define-constant err-not-married (err u102))
(define-constant err-invalid-partners (err u103))
(define-constant err-not-authorized (err u104))

;; Data Variables
(define-map marriages
    principal
    {
        partner: principal,
        date: uint,
        officiant: principal,
        status: bool
    }
)

(define-map authorized-officiants principal bool)

;; Add officiant - only contract owner can do this
(define-public (add-officiant (officiant principal))
    (begin
        (asserts! (is-eq tx-sender contract-owner) err-owner-only)
        (ok (map-set authorized-officiants officiant true))
    )
)

;; Register marriage
(define-public (register-marriage (partner1 principal) (partner2 principal))
    (let
        (
            (officiant tx-sender)
            (current-time (unwrap-panic (get-block-info? time (- block-height u1))))
        )
        (asserts! (is-some (map-get? authorized-officiants officiant)) err-not-authorized)
        (asserts! (not (is-some (map-get? marriages partner1))) err-already-married)
        (asserts! (not (is-some (map-get? marriages partner2))) err-already-married)
        (asserts! (not (is-eq partner1 partner2)) err-invalid-partners)
        
        (begin
            (map-set marriages partner1 
                {
                    partner: partner2,
                    date: current-time,
                    officiant: officiant,
                    status: true
                }
            )
            (map-set marriages partner2 
                {
                    partner: partner1,
                    date: current-time,
                    officiant: officiant,
                    status: true
                }
            )
            (ok true)
        )
    )
)

;; Dissolve marriage - only authorized officiant can do this
(define-public (dissolve-marriage (partner1 principal) (partner2 principal))
    (let
        (
            (officiant tx-sender)
            (marriage1 (unwrap! (map-get? marriages partner1) err-not-married))
            (marriage2 (unwrap! (map-get? marriages partner2) err-not-married))
        )
        (asserts! (is-some (map-get? authorized-officiants officiant)) err-not-authorized)
        (asserts! (and 
            (is-eq (get partner marriage1) partner2)
            (is-eq (get partner marriage2) partner1)
        ) err-invalid-partners)
        
        (begin
            (map-set marriages partner1 
                (merge marriage1 { status: false })
            )
            (map-set marriages partner2 
                (merge marriage2 { status: false })
            )
            (ok true)
        )
    )
)

;; Read only functions
(define-read-only (get-marriage-info (person principal))
    (map-get? marriages person)
)

(define-read-only (is-married (person principal))
    (match (map-get? marriages person)
        marriage (get status marriage)
        false
    )
)

(define-read-only (is-officiant (person principal))
    (default-to false (map-get? authorized-officiants person))
)
