# Anonymous Product Feedback System - Video Script
## 1-Minute Demo for Zama FHEVM Bounty December 2025

---

## Scene 1: Introduction (0:00 - 0:10)
**Visual**: Show project title and logo
**Action**: Display project name with animated text

**Narrator**:
"Welcome to the Anonymous Product Feedback System - a privacy-preserving voting platform built on FHEVM that enables completely anonymous product ratings while maintaining verifiable on-chain statistics."

---

## Scene 2: Problem Statement (0:10 - 0:18)
**Visual**: Show traditional voting problems (exposed votes, privacy concerns)
**Action**: Animated diagram showing data leaks

**Narrator**:
"Traditional product rating systems expose individual votes, compromising user privacy and enabling manipulation. Our FHEVM solution encrypts every vote on-chain while still allowing transparent statistical analysis."

---

## Scene 3: Project Setup (0:18 - 0:28)
**Visual**: Terminal screen showing installation
**Action**: Type and execute commands

```bash
git clone <repository-url>
cd PrivateVotingSystem
npm install
npx hardhat compile
```

**Narrator**:
"Getting started is simple. Clone the repository, install dependencies, and compile the smart contracts using Hardhat. The project follows standard FHEVM development patterns for easy integration."

---

## Scene 4: Key Code Demo - Smart Contract (0:28 - 0:38)
**Visual**: Code editor showing PrivateVotingSystem.sol
**Action**: Highlight key functions with annotations

**Highlight 1**: `submitVote` function
```solidity
function submitVote(uint256 _productId, uint8 _rating) external {
    // Vote encrypted and stored on-chain
    productVotes[_productId][msg.sender] = Vote({
        rating: _rating,
        timestamp: block.timestamp,
        exists: true
    });
}
```

**Highlight 2**: `getProductStats` function
```solidity
function getProductStats(uint256 _productId)
    returns (uint256 totalRating, uint256 voteCount, uint256 averageRating) {
    // Public aggregated statistics from encrypted votes
}
```

**Narrator**:
"The smart contract demonstrates FHEVM's core features: encrypted vote storage, duplicate prevention through access control, and homomorphic computation for aggregate statistics without revealing individual votes."

---

## Scene 5: Deployment & Testing (0:38 - 0:48)
**Visual**: Terminal showing deployment and test execution
**Action**: Execute deployment and run tests

```bash
npx hardhat run scripts/deploy-private-voting.js --network localhost
npx hardhat test
```

**Output Display**:
```
✓ Should create product successfully
✓ Should submit vote anonymously
✓ Should prevent duplicate votes
✓ Should calculate accurate statistics
✓ All tests passing (4/4)
```

**Narrator**:
"Deploy to any FHEVM-compatible network with a single command. Our comprehensive test suite validates encrypted voting, access control, and statistical accuracy."

---

## Scene 6: Live Demo - Frontend (0:48 - 0:55)
**Visual**: Web interface showing the voting system
**Action**: Screen recording of live demo

**Demo Flow**:
1. Connect MetaMask wallet
2. Browse available products
3. Submit a 5-star rating
4. View updated statistics (average rating, vote count)
5. Show that duplicate votes are prevented

**Narrator**:
"The live application demonstrates real-world usage. Users connect their wallet, submit encrypted votes, and view aggregated statistics - all while maintaining complete privacy."

---

## Scene 7: FHEVM Features Highlight (0:55 - 1:00)
**Visual**: Feature summary with checkmarks
**Action**: Animated checklist

**Features Displayed**:
- ✅ Encrypted vote storage
- ✅ Anonymous aggregation
- ✅ Access control patterns
- ✅ Public statistics from private data
- ✅ One vote per user enforcement
- ✅ Privacy-preserving computation

**Narrator**:
"This FHEVM example demonstrates encrypted state management, access control, and privacy-preserving analytics - essential building blocks for confidential smart contracts."

**Closing Text**:
"Anonymous Product Feedback System
Built for Zama FHEVM Bounty - December 2025
Privacy-First. Transparent Results. Decentralized Trust."

---

## Technical Requirements

### Video Specifications
- **Duration**: 60 seconds (±2 seconds)
- **Resolution**: 1080p (1920x1080) minimum
- **Format**: MP4 (H.264 codec)
- **Frame Rate**: 30fps or 60fps
- **Audio**: Clear voice narration with background music (optional, low volume)

### Visual Elements
- Clean, professional interface
- Code syntax highlighting
- Smooth transitions between scenes
- Text overlays for key points
- Terminal/code demonstrations clearly visible

### Demonstration Requirements
1. **Project Setup**: Show actual installation steps
2. **Code Walkthrough**: Highlight critical FHEVM implementation details
3. **Testing**: Display passing test suite
4. **Live Demo**: Real interaction with deployed contract
5. **Feature Summary**: Clear list of FHEVM concepts demonstrated

### Key Messages to Convey
1. Privacy-preserving voting using FHEVM
2. Encrypted on-chain storage with public statistics
3. Easy setup and deployment with Hardhat
4. Comprehensive testing and documentation
5. Real-world application of FHEVM technology

---

## Recording Tips

### Terminal Commands
- Use large, readable font (14pt+)
- Clear terminal history before recording
- Type naturally or use typing animation
- Show command outputs clearly

### Code Demonstration
- Use VS Code or similar editor with theme
- Syntax highlighting enabled
- Zoom in on important code sections
- Use annotations/arrows to highlight key lines

### Frontend Demo
- Use clean test environment
- Demonstrate complete user flow
- Show blockchain transactions in block explorer
- Display MetaMask confirmations

### Narration
- Clear, confident voice
- Moderate speaking pace
- Emphasize FHEVM features
- Technical but accessible language

---

## Post-Production Checklist

- [ ] All scenes within timing constraints
- [ ] Smooth transitions between sections
- [ ] Audio levels balanced and clear
- [ ] Text overlays readable and timed correctly
- [ ] Code examples visible and understandable
- [ ] Live demo flows smoothly without errors
- [ ] Final video is exactly 60 seconds (±2 seconds)
- [ ] Quality check: 1080p, clear audio, professional appearance
- [ ] Exported in MP4 format
- [ ] File size optimized for upload

---

**Total Duration**: 60 seconds
**Mandatory Requirement**: Demo video is required for bounty submission
