// SPDX-License-Identifier: MIT
pragma solidity >=0.7.0 <0.9.0;

import "forge-std/Test.sol";
import "solady/utils/LibSort.sol";
import "safe-contracts/GnosisSafe.sol";
import "safe-contracts/proxies/GnosisSafeProxyFactory.sol";
import "safe-contracts/handler/CompatibilityFallbackHandler.sol";
// import "safe-contracts/examples/SignMessage.sol";

address constant VM_ADDR = 0x7109709ECfa91a80626fF3989D68f67F5b1DD12D;

function getAddr(uint256 pk) returns (address) {
    return Vm(VM_ADDR).addr(pk);
}

library Sort {
    function sort(address[] memory arr) public pure returns (address[] memory) {
        LibSort.sort(arr);
        return arr;
    }
}

function sortPKsByComputedAddress(uint256[] memory _pks)
    returns (uint256[] memory)
{
    uint256[] memory sortedPKs = new uint256[](_pks.length);

    address[] memory addresses = new address[](_pks.length);
    bytes32[2][] memory accounts = new bytes32[2][](_pks.length);

    for (uint256 i; i < _pks.length; i++) {
        address signer = getAddr(_pks[i]);
        addresses[i] = signer;
        accounts[i][0] = bytes32(abi.encode(signer));
        accounts[i][1] = bytes32(_pks[i]);
    }

    addresses = Sort.sort(addresses);

    uint256 found;
    for (uint256 j; j < addresses.length; j++) {
        address signer = addresses[j];
        uint256 pk;
        for (uint256 k; k < accounts.length; k++) {
            if (address(uint160(uint256(accounts[k][0]))) == signer) {
                pk = uint256(accounts[k][1]);
                found++;
            }
        }

        sortedPKs[j] = pk;
    }

    if (found < _pks.length)
        revert(
            "issue with private key sorting, please open a ticket on github"
        );
    return sortedPKs;
}

struct AdvancedSafeInitParams {
    uint256[] ownerPKs;
    uint256 threshold;
    uint256 initialBalance;
    bool includeFallbackHandler;
    bytes initData;
    uint256 saltNonce;
    address setupModulesCall_to;
    bytes setupModulesCall_data;
    uint256 refundAmount;
    address refundToken;
    address payable refundReceiver;
}

struct SafeTest {
    uint256[] ownerPKs;
    address[] owners;
    uint256 threshold;
    GnosisSafe safe;
    GnosisSafe singleton;
    GnosisSafeProxyFactory proxyFactory;
    CompatibilityFallbackHandler handler;
}

contract SafeTestTools {
    SafeTest internal safeTest;

    /// takes in private keys, stores computed address?
    function _setupSafe(
        uint256[] memory ownerPKs,
        uint256 threshold,
        uint256 initialBalance,
        AdvancedSafeInitParams memory advancedParams
    ) public {
        //TODO: require ownerPKs.length > 0 || safeTest.ownerPKs.length > 0
        uint256[] memory sortedPKs = sortPKsByComputedAddress(ownerPKs);
        address[] memory owners;
        for (uint256 i; i < sortedPKs.length; i++)
            owners[i] = getAddr(sortedPKs[i]);

        // store the initialization parameters
        safeTest.ownerPKs = sortedPKs;
        safeTest.owners = owners;
        safeTest.threshold = threshold;
        // setup safe ecosystem, singleton, proxy factory, fallback handler, and create a new safe
        safeTest.singleton = new GnosisSafe();
        safeTest.proxyFactory = new GnosisSafeProxyFactory();
        safeTest.handler = new CompatibilityFallbackHandler();
        safeTest.safe = GnosisSafe(
            payable(
                advancedParams.saltNonce != 0
                    ? safeTest.proxyFactory.createProxyWithNonce(
                        address(safeTest.singleton),
                        advancedParams.initData,
                        advancedParams.saltNonce
                    )
                    : safeTest.proxyFactory.createProxy(
                        address(safeTest.singleton),
                        advancedParams.initData
                    )
            )
        );

        Vm(VM_ADDR).deal(address(safeTest.safe), initialBalance);
        safeTest.safe.setup({
            _owners: safeTest.owners,
            _threshold: safeTest.threshold,
            to: advancedParams.setupModulesCall_to, //address(0),
            data: advancedParams.setupModulesCall_data, // "",
            fallbackHandler: advancedParams.includeFallbackHandler
                ? address(safeTest.handler)
                : address(0),
            paymentToken: advancedParams.refundToken, //address(0),
            payment: advancedParams.refundAmount, //0,
            paymentReceiver: advancedParams.refundReceiver
        });
    }
}
