# 📘 NftCollection — ERC-721 NFT Smart Contract 

This repository contains a fully functioning ERC-721–style NFT smart contract implemented completely from scratch (no OpenZeppelin).  
It includes:

- Custom ERC-721 logic  
- Full 21-test Hardhat test suite  
- Dockerized reproducible environment  
- Minting, approvals, transfers, metadata & burning  


File Structure:

- contracts/
  - NftCollection.sol     -> Main NFT smart contract

- test/
  - NftCollection.test.js -> Full automated test suite (21 tests)

- Dockerfile              -> Runs Hardhat tests inside Docker
- .dockerignore           -> Excludes unnecessary files from Docker build
- hardhat.config.js       -> Hardhat configuration
- package.json            -> Project dependencies and scripts
- package-lock.json       -> Locked dependency versions
- README.md               -> Project documentation
- node_modules/           -> Auto-generated dependencies folder

## ⚙️ Features Implemented

### 🏷 ERC-721 Metadata
- name()
- symbol()
- tokenURI(tokenId)

### 🛠 Admin-controlled Minting
- Only admin can mint
- Rejects:
  - zero-address mint  
  - token already minted  
  - minting paused  
  - tokenId > maxSupply  

### 🔐 Approvals
- approve(address, tokenId)
- getApproved(tokenId)
- setApprovalForAll(operator, bool)
- isApprovedForAll(owner, operator)
- Prevents self-approval

### 🔄 Transfers
Supports:
- Owner transfer  
- Approved transfer  
- Operator transfer  

Rejects:
- unauthorized calls  
- nonexistent tokens  

### 🔥 Burn
- Token owner can burn  
- totalSupply decreases  

### ⏸ Pause/Unpause Minting
- Admin-controlled  
- Reverts with "Minting paused"  

###  Supply Management
- maxSupply  
- totalSupply  
- tokenId range checks  

---

##  Test Suite (21 Tests)

Covers:

- Initialization  
- Minting (valid & invalid)  
- Pause system  
- Transfers  
- Approvals  
- Metadata  
- Edge cases  
- Burn  

**Final result:**

21 passing (6s)


##  Docker Usage

### **Build the image**

docker build -t nft-contract .


### **Run tests inside container**

docker run --rm nft-contract


Expected:

21 passing

##  Local Development

### Install dependencies

npm install


### Compile contracts

npx hardhat compile


### Run tests

npx hardhat test

## Technologies Used
- Solidity 0.8.20  
- Hardhat  
- Ethers.js v5  
- Chai + Mocha  
- Waffle matchers  
- Docker (Node 18 Alpine)  

## Conclusion

This project delivers:

- A full custom ERC-721 implementation  
- Accurate revert messages  
- Complete test coverage  
- Docker-based reproducibility  

All requirements are successfully completed.
