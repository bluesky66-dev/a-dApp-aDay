// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/token/ERC721/ERC721.sol";
import "@openzeppelin/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/access/Ownable.sol";
import "@openzeppelin/utils/Counters.sol";

contract ProofNFT is ERC721, ERC721Enumerable, ERC721Burnable, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;
    Counters.Counter public _userCounter;

    struct User {
        address userAddress; // user address
        uint raceId; // the race they are currently on
        uint completedTasks; // completed tasks
        uint performance; // a percentage based on previous task performance
        bytes32 nickname;
        bytes bio;
    }

    struct WarmUpNFT {
        address userAddress;
        uint currentTaskId;
        uint tokenId;
        bytes32 submittedAnswers; // submitted answers by the user      
}

    struct RaceNFT {
        bytes32 submittedAnswers; // submitted answers by the user
        bytes32 answer;
        uint performance; // performance of the user out of 100
        uint tokenId;
        address userAddress;
    }

    mapping(address=>User) public userMap;

    mapping(address=>WarmUpNFT) private warmUpNFTs;
    mapping(address=>RaceNFT) private raceNFTs;

    mapping(uint=>RaceNFT) public finalRaceNfts;

    mapping(uint=>bool) private graduatedNFTs;

    User[] public users;

    error IncorrectSubmission();
    event UserCreated(address indexed who, uint indexed id);

    constructor(bytes32[] memory dunno) ERC721("ProofNFT", "PNFT") payable {
        uint len = dunno.length;
        for(uint x = 0; x < len; x++){
            finalRaceNfts[x] = RaceNFT({
                submittedAnswers: bytes32('0x'),
                answer: dunno[x],
                performance: 0,
                tokenId: x,
                userAddress: address(0)
            });
        }
    }

    function addRaces(bytes32[] memory races, uint length) external onlyOwner {
        uint len = races.length - 1;
        uint newlen = length + len;
        for(uint x = length;newlen > len; --x){
            finalRaceNfts[x] = RaceNFT({
                submittedAnswers: bytes32('0x'),
                answer: races[x],
                performance: 0,
                tokenId: x,
                userAddress: address(0)
            });
        }
    }

    function _baseURI() internal override pure returns (string memory) {
        return 'ipfs://sdasddasdsadasf/';
    }

    function tokenURI(uint id) public view override returns (string memory) {
        require(_exists(id), "ERC721Metadata: URI query for nonexistent token");
        address owner = ownerOf(id);
        if(warmUpNFTs[owner].userAddress == address(0) && !graduatedNFTs[id]){
            return string(abi.encodePacked(_baseURI(), "RaceNFT.json"));
        }else{
            return string(abi.encodePacked(_baseURI(), "WarmUpNFT.json"));
        }
    }

    function createUser(address who, bytes32 name, bytes memory bio) external {
        uint id = _userCounter.current();
        _userCounter.increment();

        User memory user = User(
            who,
            0,
            0,
            0,
            name,
            bio
        );

        users.push(user);
        userMap[who] = user;

        emit UserCreated(who, id);
    }

    function startNextRace() external {
        require(userMap[msg.sender].userAddress != address(0) , "No User Account");
        require(msg.sender == userMap[msg.sender].userAddress, "Not your account");
        User memory user = userMap[msg.sender];
        uint currentRace = user.raceId;
        WarmUpNFT memory warmUp = WarmUpNFT({
            userAddress: msg.sender,
            currentTaskId: currentRace,
            submittedAnswers: bytes32('0x'),
            tokenId: _tokenIdCounter.current()
        });
        warmUpNFTs[msg.sender] = warmUp;
        safeMint(msg.sender);
    }


    function submitCompletedTask(bytes32 answers, uint perf) external {
        User storage user = userMap[msg.sender];
        require(user.userAddress != address(0) , "No User Account");
        require(balanceOf(msg.sender) != 0 , "cannot submit a task without the warmUp NFT");
        
        WarmUpNFT memory warmUp = warmUpNFTs[msg.sender];

        RaceNFT memory raceNFT = finalRaceNfts[warmUp.currentTaskId];

        warmUp.submittedAnswers = answers;

        if(answers != raceNFT.answer) {
            revert IncorrectSubmission();
        }else{
            delete warmUpNFTs[msg.sender];
            graduatedNFTs[warmUp.tokenId] == true;
            user.raceId += 1;
            user.completedTasks++;

            uint currentPerformance = user.performance;
            uint newPerformance = (currentPerformance + perf) / user.completedTasks;
            user.performance = newPerformance;

            raceNFTs[msg.sender] = RaceNFT({
                submittedAnswers: answers,
                answer: answers,
                performance: perf,
                tokenId: warmUp.tokenId,
                userAddress: msg.sender
            });
        }
    }

    function safeMint(address to) internal {
        _tokenIdCounter.increment();
        uint256 tokenId = _tokenIdCounter.current();
        _safeMint(to, tokenId);
    }
    
    // The following functions are overrides required by Solidity.

    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}