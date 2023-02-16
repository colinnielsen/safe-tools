# Gnosis Safe Tools for Foundry
`SafeTestTools` is a friendly wrapper for deploying safes, executing transactions, performing EIP1271 signatures, and enabling/disabling modules. It manages `Safe` deployments, private keys, and transaction signing so you can simply call `_setupSafe()` and ensure your code works with Safe's as well as EOAs.

## Before -> After

<img width="2578" alt="Before after" src="https://user-images.githubusercontent.com/33375223/211921017-b57ae2f3-0d33-4265-a87d-945a69a77ba6.png">

# Basic Usage

## Quick Start 

```solidity 
import "safe-tools/SafeTest.sol";
import "forge-std/Test.sol";

contract Test is Test, SafeTestTools {
    using SafeTestLib for SafeInstance;

    setUp() public {
        SafeInstance memory safeInstance = _setupSafe();
        address alice = address(0xA11c3);

        safeInstance.execTransaction({
            to: alice,
            value: 0.5 ether,
            data: ""
        }); // send .5 eth to alice

        assertEq(alice.balance, 0.5 ether); // passes ✅
    }
}
```
## Basic Setup
Use the `_setupSafe();` method to setup a `SafeInstance` with the default initialization parameters.
```solidity
SafeInstance memory safeInstance = _setupSafe();
```

### Default Parameters:

1. Threshold: `2/3`
2. Signers: The owners are the first 3 signers from the standard `test test test test test test test test test test test junk` derived accounts. These accounts are `vm.label`'d as `SAFETEST: Signer 0-2:` for Forge's call tacing functionality.
3. Initial Balance: `10000 ether`
4. Salt nonce: `0xbff0e1d6be3df3bedf05c892f554fbea3c6ca2bb9d224bc3f3d3fbc3ec267d1c`

This will create a SafeInstance with the address of `0x4fFf49f984EFf15087e13d0176e13a5A5009bFaA`

(See setup options for more details)

## The Safe Instance Struct:
```solidity
struct SafeInstance {
    uint256 instanceId;
    uint256[] ownerPKs;
    address[] owners;
    uint256 threshold;
    DeployedSafe safe; 
}
```

A safe instance stores:
1. `instanceId`: a unique id
2. `ownerPKs`: an array of owner private keys (**NOTE! these PKs will be sorted by computed address for signing purposes**) 
3. `owners`: an array of owner addresses (**sorted to match the private keys**)
4. `threshold`: the signing threshold of the safe
5. `safe`: the address of the deployed safe wrapped in a custom interface `DeployedSafe` that includes: 
    - `GnosisSafe.sol` methods
    - `CompatibilityFallbackHandler.sol` methods (for EIP1271 signature validation, messaging hashing, token callbacks, etc)

## `SafeInstance` Methods
Wrap the `SafeInstance` with `SafeTestLib` methods to add access wrappers for signing methods for common Safe methods.
```solidity
using SafeTestLib for SafeInstance;
```

### API
```solidity
// EXEC FUNCTION VARIATIONS
function execTransaction(
    address to,
    uint256 value,
    bytes data
) public returns (bool);

function execTransaction(
    address to,
    uint256 value,
    bytes data,
    Enum.Operation operation
) public returns (bool);

function execTransaction(
    address to,
    uint256 value,
    bytes data,
    Enum.Operation operation,
    uint256 safeTxGas,
    uint256 baseGas,
    uint256 gasPrice,
    address gasToken,
    address refundReceiver,
    bytes memory signatures
) public returns (bool);

// MODULE FUNCTIONS

function enableModule(address module);

function disableModule(address module);

// MISC

function EIP1271Sign(bytes data);

function EIP1271Sign(bytes32 digest);

function incrementNonce() public returns (uint256 newNonce);

function signTransaction(
    uint256 privateKey,
    address to,
    uint256 value,
    bytes memory data,
    Enum.Operation operation,
    uint256 safeTxGas,
    uint256 baseGas,
    uint256 gasPrice,
    address gasToken,
    address refundReceiver
) public view returns (uint8 v, bytes32 r, bytes32 s)

```
# Advanced Usage
## Setup options TODO:

## License
License
MIT © Colin Nielsen