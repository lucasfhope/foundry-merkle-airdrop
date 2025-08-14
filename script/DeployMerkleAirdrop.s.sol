// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {MerkleAirdrop} from "src/MerkleAirdrop.sol";
import {SixSevenToken} from "src/SixSevenToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract DeployMerkleAirdrop is Script {
    bytes32 merkleRoot = 0x2ebf589aa3d849d56a3257485a403392e739d782d14b5bf57de023be04963b9f;
    uint256 numberOfRecipients = 3;
    uint256 amountToAirdropPerRecipient = 25 ether;
    uint256 totalAmountToAirdrop = amountToAirdropPerRecipient * numberOfRecipients;

    function deployMerkleAirdrop() public returns (MerkleAirdrop airdrop, SixSevenToken token) {
        vm.startBroadcast();
        token = new SixSevenToken();
        airdrop = new MerkleAirdrop(merkleRoot, IERC20(address(token)));
        token.mint(token.owner(), totalAmountToAirdrop);
        token.transfer(address(airdrop), totalAmountToAirdrop);
        vm.stopBroadcast();
    }

    function run() external returns (MerkleAirdrop, SixSevenToken) {
        return deployMerkleAirdrop();
    }
}
