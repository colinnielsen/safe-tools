// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

import "forge-std/Test.sol";
import "../src/SafeTest.sol";

contract TestSafeTestTools is Test, SafeTestTools {
    using TestSafeLib for SafeInstance;

    SafeInstance safe;
    SafeInstance safe2;

    address alice = address(0xA11c3);
    address bob = address(0xb0b);
    address carol = address(0xc4401);

    uint256[] public ownerPKs;
    bytes4 internal constant MAGICVALUE = 0x1626ba7e;

    function testAutoInit() public {
        ownerPKs.push(1);

        safe = _setupSafe({ownerPKs: ownerPKs, threshold: 1, initialBalance: 1 ether});
        // ownerPKs.push(2);
        console.log(address(safe.safe));
        // ownerPKs.push(encodeSmartContractWalletAsPK(address(safe.safe)));
        // safe2 = _setupSafe({ownerPKs: ownerPKs, threshold: 1, initialBalance: 1 ether});
        // safe.execTransaction()
        (uint8 v, bytes32 r, bytes32 s) = safe.signTransaction(1, alice, 0.5 ether, "", Enum.Operation.Call, 0, 0, 0, address(0), address(0));
        bytes memory signature = abi.encodePacked(r, s, v);
        safe.execTransaction(alice, 0.5 ether, "", Enum.Operation.Call, 0, 0, 0, address(0), address(0), signature);
        assertEq(alice.balance, .5 ether);
        // safe2.execTransaction(alice, .5 ether, "");

        // console.log("address(safe.safe)", address(safe.safe));

        // safe2.enableModule(carol);

        // assertTrue(safe2.safe.isModuleEnabled(carol));
    }
}
