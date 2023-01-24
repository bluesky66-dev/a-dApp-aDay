pragma solidity ^0.8.0;

import {ERC721} from "@openzeppelin/token/ERC721/ERC721.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {AccessControl} from "@openzeppelin/access/AccessControl.sol";
import {EIP712} from "@openzeppelin/utils/cryptography/draft-EIP712.sol";
import {ECDSA} from "@openzeppelin/utils/cryptography/ECDSA.sol";
import {IERC165} from "@openzeppelin/utils/introspection/IERC165.sol";
import {ERC721URIStorage} from "@openzeppelin/token/ERC721/extensions/ERC721URIStorage.sol";
import {Counters} from "@openzeppelin/utils/Counters.sol";
import {Strings} from "@openzeppelin/utils/Strings.sol";

/**
 * @title SilverPass Premint
 * @dev SilverPass contract mints Deviants SilverPass NFTs
 */

contract SilverPass is ERC721, ERC721URIStorage, EIP712, AccessControl {
    using Strings for uint256;
    using Counters for Counters.Counter;
    using ECDSA for bytes32;
    Counters.Counter private _tokenIdCounter;


    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public constant MAX_SUPPLY = 5555;
    uint256 public constant MAX_MINT = 2;
    uint256 public constant PRICE = 0.0035 ether;

    uint256 internal genesis;
    uint256 internal openSeason;

    address public TEAM;

    function safeMint(address to)
        internal
    {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
        _setTokenURI(tokenId, tokenId.toString());
    }

    constructor()
        ERC721("Deviants Silver Pass", "DSP")
        EIP712("Deviants Silver Pass", "1")
    {
        genesis = block.timestamp;
        openSeason = block.timestamp + 86400; //Genesis + 24hrs
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MINTER_ROLE, TEAM);
        TEAM = msg.sender;
    }

    modifier isUser() {
        require(tx.origin == msg.sender, "The caller is another contract");
        _;
    }

    function redeem(
        address account,
        bytes calldata signature
    ) public returns(bool){
        require(
            _verify(signature),
            "Invalid signature"
        );
        assert(msg.sender == account);
        safeMint(account);
        return true;
    }


    function _verify( bytes memory signature)
        internal
        view
        returns (bool)
    {
        bytes32 digest = _hashTypedDataV4(
                keccak256(
                abi.encode(
                    keccak256("NFT(address account)"),
                    tx.origin
                )
            )
        );
        return ECDSA.recover(digest, signature) == TEAM;
    }

    function withdraw() public {
        payable(TEAM).transfer(address(this).balance);
    }

    function setBaseURI(string memory baseURI_) internal {
        setBaseURI(baseURI_);
    }

    function ERC20Rescue(IERC20 _token) public {
        require(msg.sender == TEAM);
        _token.transfer(TEAM, _token.balanceOf(address(this)));
    }

    // The following functions are overrides required by Solidity.

       function _burn(uint256 tokenId) internal override(ERC721, ERC721URIStorage) {
        super._burn(tokenId);
    }

    function tokenURI(uint256 tokenId)
        public
        view
        override(ERC721, ERC721URIStorage)
        returns (string memory)
    {
        return super.tokenURI(tokenId);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, AccessControl)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }


    receive() external payable {}

    fallback() external payable {}
}
