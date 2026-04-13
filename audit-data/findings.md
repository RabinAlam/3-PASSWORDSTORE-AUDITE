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
