;; ============================================================
;; Contract: relay-wallet.clar
;; Purpose : Dynamic gasless wallet with authorized relayers
;; ============================================================

;; -------------------------
;; ERRORS
;; -------------------------
(define-constant ERR-NOT-OWNER          (err u10001))
(define-constant ERR-NOT-RELAYER        (err u10002))
(define-constant ERR-INSUFFICIENT-FUNDS (err u10003))
(define-constant ERR-TX-FAILED          (err u10004))

;; -------------------------
;; STORAGE
;; -------------------------

;; Authorized relayers
(define-map relayers
  principal
  bool
)

;; Wallet balances
(define-map balances
  principal
  uint
)

;; -------------------------
;; READ-ONLY HELPERS
;; -------------------------

(define-read-only (is-owner? (who principal))
  (is-eq tx-sender who)
)

(define-read-only (is-relayer? (who principal))
  (default-to false (map-get? relayers who))
)

(define-read-only (get-balance (who principal))
  (default-to u0 (map-get? balances who))
)

;; Private helpers
(define-private (edit-relayer (r principal) (status bool))
  (begin
    (map-set relayers r status)
    true
  )
)

(define-private (edit-balance (who principal) (new-balance uint))
  (begin
    (map-set balances who new-balance)
    true
  )
)

;; -------------------------
;; OWNER CONTROLS
;; -------------------------

(define-public (add-relayer (r principal))
  (if (is-owner? tx-sender)
    (ok (edit-relayer r true))
    ERR-NOT-OWNER
  )
)

(define-public (remove-relayer (r principal))
  (if (is-owner? tx-sender)
    (ok (begin
      (edit-relayer r false)
      true
    ))
    ERR-NOT-OWNER
  )
)

;; -------------------------
;; DEPOSIT & FUND MANAGEMENT
;; -------------------------

(define-public (deposit)
  (begin
    (try! (stx-transfer? (stx-get-balance tx-sender) tx-sender (as-contract tx-sender)))
    (let ((current (default-to u0 (map-get? balances tx-sender))))
      (edit-balance tx-sender (+ current (stx-get-balance tx-sender)))
    )
    (ok true)
  )
)

;; -------------------------
;; GASLESS TRANSFER / RELAY
;; -------------------------

(define-public (relay-transfer
  (from principal)
  (to principal)
  (amount uint)
)
  (if (not (is-relayer? tx-sender))
    ERR-NOT-RELAYER
    (let (
      (sender-balance (default-to u0 (map-get? balances from)))
      (receiver-balance (default-to u0 (map-get? balances to)))
    )
      (if (< sender-balance amount)
        ERR-INSUFFICIENT-FUNDS
        (ok (begin
          (edit-balance from (- sender-balance amount))
          (edit-balance to (+ receiver-balance amount))
          true
        ))
      )
    )
  )
)
