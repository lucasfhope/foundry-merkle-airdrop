// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";

contract ClaimAirdropAnvil is Script {
    address CLAIMING_ADDRESS = 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266;
    uint256 CLAIMING_AMOUNT = 25 ether;
    bytes32 PROOF1 = 0x793b52ec15707df3a079b9bef9182e21cd445f1b169bcafad1115c4ab97b2010;
    bytes32 PROOF2 = 0xfc19450a5dbe7ef4a90490449e69ce9c9d67497f2e8e4d521d4ff9850937b153;
    bytes32[] PROOF = [PROOF1, PROOF2];
    bytes private SIGNATURE = hex"fbd2270e6f23fb5fe9248480c0f4be8a4e9bd77c3ad0b1333cc60b5debc511602a2a06c24085d8d7c038bad84edc53664c8ce0346caeaa3570afec0e61144dc11c";

    function claimAirdrop(address airdrop) public  {
        vm.startBroadcast();
        (uint8 v, bytes32 r, bytes32 s) = SignatureUtils.splitSignature(SIGNATURE);
        MerkleAirdrop(airdrop).claim(CLAIMING_ADDRESS, CLAIMING_AMOUNT, PROOF, v, r, s);
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment("MerkleAirdrop", block.chainid);
        claimAirdrop(mostRecentlyDeployed);
    }
}

contract SplitSignature is Script {
    function run(bytes calldata sig) external {
        (uint8 v, bytes32 r, bytes32 s) = SignatureUtils.splitSignature(sig);
        console2.log("v value:");
        console2.logUint(v);
        console2.log("r value:");
        console2.logBytes32(r);
        console2.log("s value:");
        console2.logBytes32(s);
    }
}

library SignatureUtils {
    error SignatureUtils__InvalidSignatureLength();

    function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        if (sig.length != 65) revert SignatureUtils__InvalidSignatureLength();
        assembly {
            r := mload(add(sig, 0x20))
            s := mload(add(sig, 0x40))
            v := byte(0, mload(add(sig, 0x60)))
        }
    }
}