## Deployment and Interactions on ZKSync Sepolia

1. Deploy the ERC20 token
```bash
forge create src/SixSevenToken.sol:SixSevenToken --rpc-url ${ZKSYNC_SEPOLIA_RPC_URL} --account dev --legacy --zksync --broadcast
```
```
Deployer: 0xbB6476B878B28965969F63720E0269A48132d9e3
Deployed to: 0x3Ec1689Eb776aE7c1185fEE542Efca2c71504142
Transaction hash: 0x6d727afd72b090fcc1ee1ea7d321c2465d86abd984bf3a2fb17da7122cc9ea86
```

2. Deploy the MerkleAirdrop contract 
```bash
forge create src/MerkleAirdrop.sol:MerkleAirdrop --account dev --zksync --legacy --rpc-url ${ZKSYNC_SEPOLIA_RPC_URL} --broadcast --constructor-args 0x2ebf589aa3d849d56a3257485a403392e739d782d14b5bf57de023be04963b9f ${TOKEN_ADDRESS}
```
```
Deployer: 0xbB6476B878B28965969F63720E0269A48132d9e3
Deployed to: 0x437bBa1546D6C92204A183d197e1dEB20d9d43Ee
Transaction hash: 0xe865d0b9034d6feddcf2ff26ce2cd0e2a845882a6a79c342b1710fc0edeee44e
```

3. Get the message hash of the claimer and how much they are claiming
```bash
cast call ${AIRDROP_ADDRESS} "getEIP712MessageHash(address,uint256)" 0xbB6476B878B28965969F63720E0269A48132d9e3 25000000000000000000 --rpc-url ${ZKSYNC_SEPOLIA_RPC_URL}  
```                             
```
0x63f2c36f07d5e67e0dfbe65930e67723ea98122f2d235058649014ff15b97d46
```

4. Claimer signs with the message hash
```bash
cast wallet sign --no-hash 0x63f2c36f07d5e67e0dfbe65930e67723ea98122f2d235058649014ff15b97d46 --account dev
```
```
0x9f47d774fdc913b09d5a98c9a8977ef1abd3ee788d6c6b1de447bb104a80c400113307e29cdf8eade0b019fabb4c435e9f25917afb23b8348645dc733e773dfa1c
```

5. Split the signature 
```bash
forge script script/Interactions.s.sol:SplitSignature --rpc-url ${ZKSYNC_SEPOLIA_RPC_URL} --account dev --broadcast \
--sig "run(bytes)" 9f47d774fdc913b09d5a98c9a8977ef1abd3ee788d6c6b1de447bb104a80c400113307e29cdf8eade0b019fabb4c435e9f25917afb23b8348645dc733e773dfa1c
```
```
== Logs ==
  v value:
  28
  r value:
  0x9f47d774fdc913b09d5a98c9a8977ef1abd3ee788d6c6b1de447bb104a80c400
  s value:
  0x113307e29cdf8eade0b019fabb4c435e9f25917afb23b8348645dc733e773dfa
```

6. Mint ERC20 tokens and transfer them to the airdrop contract
```bash
cast send ${TOKEN_ADDRESS} "mint(address,uint256)" 0xbB6476B878B28965969F63720E0269A48132d9e3 75000000000000000000 --account dev --rpc-url ${ZKSYNC_SEPOLIA_RPC_URL}

cast send ${TOKEN_ADDRESS} "transfer(address,uint256)" ${AIRDROP_ADDRESS} 75000000000000000000 --rpc-url ${ZKSYNC_SEPOLIA_RPC_URL} --account dev
```

7. Anyone can submit the transaction and pay the gas on behalf of the claimer. Merkle proofs for the claimer are in bytes32[].
```bash
cast send ${AIRDROP_ADDRESS} "claim(address,uint256,bytes32[],uint8,bytes32,byte
s32)" 0xbB6476B878B28965969F63720E0269A48132d9e3 25000000000000000000 "[0x0fd7c981d39bece61f7499702bf59b3114a90e66b51ba2c53abdf7b62986c00a,0xfc19450a5dbe7ef4a90490449e69ce9c9d67497f2e8e4d521d4ff9850937b153]" ${V} ${R} ${S} --account dev --rpc-url ${ZKSYNC_SEPOLIA_RPC_URL}
```
---

The airdrop tokens can also be claimed by:
- 0xf39Fd6e51aad88F6F4ce6aB8827279cffFb92266   (Anvil #1)
- 0x6CA6d1e2D5347Bfab1d91e883F1915560e09129D.  (makeAddr("user))