---
title: "Protocol Audit Report"
author: "RABIN ALAM"
date: "March 7, 2026"
---

<!-- Your report starts here! -->

Prepared by: RABIN ALAM  
Lead Auditors: Smart Contract Security researchers 
- xxxxxxx

# Table of Contents
...

<!-- Your report starts here! -->

Prepared by:RABIN ALAM
Lead Auditors: Smart Contract Security researchers 
- xxxxxxx

# Table of Contents
- [Table of Contents](#table-of-contents)
- [Table of Contents](#table-of-contents-1)
- [Protocol Summary](#protocol-summary)
- [Disclaimer](#disclaimer)
- [Risk Classification](#risk-classification)
- [Audit Details](#audit-details)
  - [Scope](#scope)
- [- solc Version 0.8.13](#--solc-version-0813)
- [- Chai(s) to deploy contract to; Ethereum](#--chais-to-deploy-contract-to-ethereum)
  - [Roles](#roles)
- [Executive Summary](#executive-summary)
  - [Issues found](#issues-found)
  - [Findings](#findings)
  - [High](#high)
- [\[S-01\] Storing Password On-Chain Exposes It Publicly](#s-01-storing-password-on-chain-exposes-it-publicly)
  - [Description](#description)
  - [Impact](#impact)
  - [Proof of Concept](#proof-of-concept)
  - [Recommended Mitigation](#recommended-mitigation)
  - [](#)
  - [](#-1)
- [\[S-02\] Missing Access Control in `PasswordStore::setPassword`](#s-02-missing-access-control-in-passwordstoresetpassword)
  - [Description](#description-1)
  - [Impact](#impact-1)
  - [Proof of Concept](#proof-of-concept-1)
  - [Recommended Mitigation](#recommended-mitigation-1)
  - [Medium](#medium)
  - [Low](#low)
  - [Informational](#informational)
- [\[S-03\] Incorrect NatSpec Parameter in `PasswordStore::getPassword`natspec indicates a parameter that doesn't exist, causing the natspec to be incorrect](#s-03-incorrect-natspec-parameter-in-passwordstoregetpasswordnatspec-indicates-a-parameter-that-doesnt-exist-causing-the-natspec-to-be-incorrect)
  - [Description](#description-2)
  - [Impact](#impact-2)
  - [Recommended Mitigation](#recommended-mitigation-2)
  - [Gas](#gas)

# Protocol Summary

Protocol does X, Y, Z

# Disclaimer

The YOUR_NAME_HERE team makes all effort to find as many vulnerabilities in the code in the given time period, but holds no responsibilities for the findings provided in this document. A security audit by the team is not an endorsement of the underlying business or product. The audit was time-boxed and the review of the code was solely on the security aspects of the Solidity implementation of the contracts.

# Risk Classification

|            |        | Impact |        |     |
| ---------- | ------ | ------ | ------ | --- |
|            |        | High   | Medium | Low |
|            | High   | H      | H/M    | M   |
| Likelihood | Medium | H/M    | M      | M/L |
|            | Low    | M      | M/L    | L   |

We use the [CodeHawks](https://docs.codehawks.com/hawks-auditors/how-to-evaluate-a-finding-severity) severity matrix to determine severity. See the documentation for more details.

# Audit Details 
 Commit hash; 7d555682ddc4301ae9413095feffd9924566
## Scope 
   ```
   ./src/
  #-- PasswordStore.sol

 ```
# - solc Version 0.8.13
#  - Chai(s) to deploy contract to; Ethereum


## Roles
  - Ower: The user who can set  the password and read the password.
  - Outsiders: No one else should be able to set or read the password.


# Executive Summary

* Add some notes about how the audit went , types of things you found , etc *
* We spent X hours with Z auditors using Y tools 
* 
## Issues found
 | Severitity | Numbers of isssue found |
 |------------|-------------------------|
 | High       |2                        |
 |Medium      |0                        |
 |Low         |1                        |
 |Info        |                         |
 |Total       |3                        |


## Findings
## High
# [S-01] Storing Password On-Chain Exposes It Publicly



## Description

All data stored on-chain is inherently public and can be accessed by any external party. The variable:

```solidity
PasswordStore::s_password
```

is intended to remain private and only accessible to the contract owner through:

```solidity
PasswordStore::getPassword()
```

However, blockchain storage is fully transparent. Any user can directly read contract storage slots using publicly available tools, bypassing access control mechanisms.

## Impact

Anyone can retrieve the password, resulting in a complete loss of confidentiality and a critical breakdown of the protocol’s intended functionality.

**Severity:** High

## Proof of Concept

1. Start a local blockchain:

```bash
make anvil
```

2. Deploy the contract:

```bash
make deploy
```

3. Read the storage slot (`s_password` is stored at slot `1`):

```bash
cast storage <ADDRESS_HERE> 1 --rpc-url http://127.0.0.1:8545
```

Example output:

```bash
0x6d7950617373776f726400000000000000000000000000000000000000000014
```

4. Decode the value:

```bash
cast parse-bytes32-string 0x6d7950617373776f726400000000000000000000000000000000000000000014
```

Result:

```bash
myPassword
```

## Recommended Mitigation

Sensitive data such as passwords should not be stored on-chain. Instead:

* Store only hashed values (e.g., `keccak256`)
* Use off-chain encryption for sensitive information
* Remove any functions that expose sensitive data


##



##
# [S-02] Missing Access Control in `PasswordStore::setPassword`

## Description

The function `PasswordStore::setPassword` is declared as `external` but does not enforce any access control. This allows any address to modify the password, despite the intended restriction to the contract owner.

```solidity
function setPassword(string memory newPassword) external {
    s_password = newPassword;
    emit SetNewPassword();
}
```

## Impact

Any user can change the password, resulting in unauthorized state modification and loss of contract integrity.

**Severity:** High

## Proof of Concept

```solidity
function test_anyone_can_set_password(address randomAddress) public {
    vm.assume(randomAddress != owner);

    vm.prank(randomAddress);
    passwordStore.setPassword("hacked");

    vm.prank(owner);
    assertEq(passwordStore.getPassword(), "hacked");
}
```

## Recommended Mitigation

Restrict access to the owner:

```solidity
function setPassword(string memory newPassword) external {
    require(msg.sender == s_owner, "Not owner");

    s_password = newPassword;
    emit SetNewPassword();
}
```


## Medium
## Low 
## Informational
 # [S-03] Incorrect NatSpec Parameter in `PasswordStore::getPassword`natspec indicates a parameter that doesn't exist, causing the natspec to be incorrect

## Description

The NatSpec documentation for `PasswordStore::getPassword` incorrectly includes a parameter that does not exist in the function signature.

```solidity id="q8k2mn"
function getPassword() external view returns (string memory) {}
```

However, the NatSpec specifies a non-existent parameter:

```solidity id="n5xk0p"
/**
 * @notice This allows only the owner to retrieve the password.
 * @param newPassword The new password to set.
 */
```

This creates a mismatch between the function implementation and its documentation.

## Impact

* Incorrect documentation
* Misleading NatSpec for developers and auditors
* Reduced code clarity and maintainability

**Severity:** Low (Informational)

## Recommended Mitigation

Remove the incorrect `@param` entry from the NatSpec:

```diff id="k9p3ld"
 /*
  * @notice This allows only the owner to retrieve the password.
- * @param newPassword The new password to set.
  */
```


## Gas 
