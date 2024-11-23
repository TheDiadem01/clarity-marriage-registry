# Digital Marriage Registry

A blockchain-based marriage registry system implemented on the Stacks blockchain using Clarity.

## Features

- Register marriages with authorized officiants
- Store marriage certificates on the blockchain
- Query marriage status and details
- Dissolve marriages through authorized officiants
- Maintain a list of authorized marriage officiants

## Contract Functions

- `add-officiant`: Add an authorized marriage officiant
- `register-marriage`: Register a new marriage between two partners
- `dissolve-marriage`: Dissolve an existing marriage
- `get-marriage-info`: Get details about a person's marriage
- `is-married`: Check if a person is currently married
- `is-officiant`: Check if an address is an authorized officiant

## Security Features

- Only contract owner can add officiants
- Only authorized officiants can register or dissolve marriages
- Prevents multiple marriages (no bigamy)
- Validates partner addresses
- Maintains complete marriage history on chain
