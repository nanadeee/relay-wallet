# Relay Wallet Smart Contract

A dynamic gasless wallet contract built on Stacks that enables authorized relayers to process transactions on behalf of users without requiring direct gas payments.

## Overview

Relay Wallet is a smart contract that implements a gasless transaction system where:
- Users deposit STX into their wallet balance
- Authorized relayers can transfer funds between walances
- The contract owner manages relayer permissions
- All transfers happen without gas costs to end users

## Features

✅ **Relayer Management** - Owner can add and remove trusted relayers  
✅ **Balance Tracking** - Track user balances in contract storage  
✅ **Deposit System** - Users can deposit STX into their wallet  
✅ **Gasless Transfers** - Relayers execute transfers without charging senders  
✅ **Access Control** - Owner-only and relayer-only functions  

## Contract Functions

### Owner Controls
- `add-relayer (r: principal)` - Authorize a new relayer
- `remove-relayer (r: principal)` - Revoke relayer authorization

### User Functions
- `deposit ()` - Deposit STX into your wallet balance

### Relayer Functions
- `relay-transfer (from: principal) (to: principal) (amount: uint)` - Execute gasless transfer

### Read-Only Helpers
- `is-owner? (who: principal)` - Check if principal is owner
- `is-relayer? (who: principal)` - Check if principal is authorized relayer
- `get-balance (who: principal)` - Query wallet balance

## Error Codes

| Code | Error |
|------|-------|
| u10001 | Not contract owner |
| u10002 | Not authorized relayer |
| u10003 | Insufficient funds |
| u10004 | Transaction failed |

## Usage Example

```clarity
;; Add a relayer
(contract-call? .relay-wallet add-relayer 'SP1234...')

;; Deposit STX
(contract-call? .relay-wallet deposit)

;; Relayer executes gasless transfer
(contract-call? .relay-wallet relay-transfer 'FROM-ADDRESS' 'TO-ADDRESS' u1000)
