// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test, console} from "forge-std/Test.sol";
import {MerkleAirdrop} from "../src/MerkleAirdrop.sol";
import {SixSevenToken} from "../src/SixSevenToken.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {ZkSyncChainChecker} from "lib/foundry-devops/src/ZkSyncChainChecker.sol";
import {DeployMerkleAirdrop} from "script/DeployMerkleAirdrop.s.sol";



contract MerkleAirdropTest is ZkSyncChainChecker, Test {
    MerkleAirdrop public merkleAirdrop;
    SixSevenToken public token;

    address user;
    address payer;
    uint256 userPrivateKey;

    bytes32 public ROOT = 0x2ebf589aa3d849d56a3257485a403392e739d782d14b5bf57de023be04963b9f;
    uint256 public AMOUNT_TO_CLAIM = 25 ether;
    uint256 public AMOUNT_TO_SEND = 4 * AMOUNT_TO_CLAIM;
    bytes32 proof1 = 0x0000000000000000000000000000000000000000000000000000000000000000;
    bytes32 proof2 = 0xba80d97a3ae1f95d682c1ecd232a7cc71fbf323beb47219b74bf5c820da7e419;
    bytes32[] public PROOF = [proof1, proof2];

    
    function setUp() public {
        if(!isZkSyncChain()) {
            DeployMerkleAirdrop deployer = new DeployMerkleAirdrop();
            (merkleAirdrop, token) = deployer.deployMerkleAirdrop();
        } else {
            token = new SixSevenToken();
            merkleAirdrop = new MerkleAirdrop(ROOT,IERC20(token));
            token.mint(token.owner(), AMOUNT_TO_SEND);
            token.transfer(address(merkleAirdrop), AMOUNT_TO_SEND);
        }
        (user, userPrivateKey) = makeAddrAndKey("user");
        payer = makeAddr("payer");
    }

    function testElligibleUsersCanClaim() public {
        uint256 startingBalance = token.balanceOf(user);
        bytes32 digest = merkleAirdrop.getEIP712MessageHash(user, AMOUNT_TO_CLAIM);

        // user signs a message
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(userPrivateKey, digest);

        // payer calls claim using the signed message
        // claims airdrop tokens for the user, paying the gas fees
        vm.prank(payer);
        merkleAirdrop.claim(user, AMOUNT_TO_CLAIM, PROOF, v, r, s);

        uint256 endingBalance = token.balanceOf(user);
        console.log("Ending balance: ", endingBalance);
        assertEq(endingBalance - startingBalance, AMOUNT_TO_CLAIM);
    }

}