# Gnosis Safe Tools for Foundry

## Usage

```solidity 

import "safe-tools/SafeTest.sol";
import "forge-std/Test.sol";

contract Test is Test, SafeTest {
    uint256 user1PK = uint256(0xA11c3);
    uint256 user2PK = uint256(0xB0b);

    setUp() public {
        safeTest.ownerPKs.push(user1PK);
        safeTest.ownerPKs.push(user2PK);
        _setupSafe({threshold: 1});
        // your test code here
    }
}
```

### Setup options:
```

```