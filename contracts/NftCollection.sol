// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Minimal ERC-721–style NFT Collection (tests-driven)
/// @notice Implements the exact revert messages and behaviors required by the tests.
contract NftCollection {
    // Metadata
    string private _name;
    string private _symbol;
    string private _baseTokenURI;

    // Ownership
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;

    // Approvals
    mapping(uint256 => address) private _tokenApprovals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    // Supply + admin
    uint256 private _totalSupply;
    uint256 private _maxSupply;
    address private _admin;
    bool private _mintPaused;

    // Events
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    // -------------------------
    // Modifiers
    // -------------------------
    modifier onlyAdmin() {
        require(msg.sender == _admin, "Only admin");
        _;
    }

    // -------------------------
    // Constructor
    // -------------------------
    constructor(
        string memory name_,
        string memory symbol_,
        uint256 maxSupply_,
        string memory baseURI_
    ) {
        _name = name_;
        _symbol = symbol_;
        _maxSupply = maxSupply_;
        _baseTokenURI = baseURI_;
        _admin = msg.sender;
        _mintPaused = false;
        _totalSupply = 0;
    }

    // -------------------------
    // Metadata getters
    // -------------------------
    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    // -------------------------
    // Supply getters
    // -------------------------
    function maxSupply() public view returns (uint256) {
        return _maxSupply;
    }

    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }

    // -------------------------
    // Minting controls
    // -------------------------
    function pauseMinting() public onlyAdmin {
        _mintPaused = true;
    }

    function unpauseMinting() public onlyAdmin {
        _mintPaused = false;
    }

    // -------------------------
    // Internal helpers
    // -------------------------
    function _exists(uint256 tokenId) internal view returns (bool) {
        return _owners[tokenId] != address(0);
    }

    function balanceOf(address ownerAddr) public view returns (uint256) {
        require(ownerAddr != address(0), "Zero address");
        return _balances[ownerAddr];
    }

    function ownerOf(uint256 tokenId) public view returns (address) {
        address ownerAddr = _owners[tokenId];
        require(ownerAddr != address(0), "Nonexistent token");
        return ownerAddr;
    }

    // -------------------------
    // Minting
    // -------------------------
    /// @notice Mint a token with `tokenId` to `to`. Only admin.
    function safeMint(address to, uint256 tokenId) public onlyAdmin {
        require(!_mintPaused, "Minting paused");
        require(to != address(0), "Mint to zero");
        require(tokenId > 0 && tokenId <= _maxSupply, "tokenId out of range");
        require(!_exists(tokenId), "Already minted");
        require(_totalSupply < _maxSupply, "Max supply reached");

        _owners[tokenId] = to;
        _balances[to] += 1;
        _totalSupply += 1;

        emit Transfer(address(0), to, tokenId);
    }

    // -------------------------
    // Approvals
    // -------------------------
    function approve(address to, uint256 tokenId) public {
        address tokenOwner = _owners[tokenId];
        require(tokenOwner != address(0), "Nonexistent token");

        require(
            msg.sender == tokenOwner || _operatorApprovals[tokenOwner][msg.sender],
            "Not approved"
        );

        _tokenApprovals[tokenId] = to;
        emit Approval(tokenOwner, to, tokenId);
    }

    function getApproved(uint256 tokenId) public view returns (address) {
        require(_exists(tokenId), "Nonexistent token");
        return _tokenApprovals[tokenId];
    }

    function setApprovalForAll(address operator, bool approved) public {
        require(operator != msg.sender, "Operator is sender");
        _operatorApprovals[msg.sender][operator] = approved;
        emit ApprovalForAll(msg.sender, operator, approved);
    }

    function isApprovedForAll(address ownerAddr, address operator) public view returns (bool) {
        return _operatorApprovals[ownerAddr][operator];
    }

    function _isApprovedOrOwner(address spender, uint256 tokenId) internal view returns (bool) {
        address tokenOwner = _owners[tokenId];
        if (tokenOwner == address(0)) return false;
        return (spender == tokenOwner ||
            _tokenApprovals[tokenId] == spender ||
            _operatorApprovals[tokenOwner][spender]);
    }

    // -------------------------
    // Transfers
    // -------------------------
    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_exists(tokenId), "Nonexistent token");
        address tokenOwner = _owners[tokenId];
        require(tokenOwner == from, "Not approved");
        require(_isApprovedOrOwner(msg.sender, tokenId), "Not approved");
        require(to != address(0), "Mint to zero");

        // Clear approval
        if (_tokenApprovals[tokenId] != address(0)) {
            delete _tokenApprovals[tokenId];
        }

        // Update balances & ownership
        _balances[from] -= 1;
        _balances[to] += 1;
        _owners[tokenId] = to;

        emit Transfer(from, to, tokenId);
    }

    // -------------------------
    // Burn
    // -------------------------
    /// @notice Burn tokenId. Only token owner can burn.
    function burn(uint256 tokenId) public {
        address tokenOwner = _owners[tokenId];
        require(tokenOwner != address(0), "Nonexistent token");
        require(msg.sender == tokenOwner, "Not approved");

        // Clear approvals
        if (_tokenApprovals[tokenId] != address(0)) {
            delete _tokenApprovals[tokenId];
        }

        // Update balances & ownership & totalSupply
        _balances[tokenOwner] -= 1;
        delete _owners[tokenId];
        _totalSupply -= 1;

        emit Transfer(tokenOwner, address(0), tokenId);
    }

    // -------------------------
    // Metadata
    // -------------------------
    function tokenURI(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Nonexistent token");
        return string(abi.encodePacked(_baseTokenURI, _toString(tokenId)));
    }

    // -------------------------
    // Utilities
    // -------------------------
    /// @dev Convert uint256 to decimal string (robust implementation)
    function _toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OpenZeppelin's Strings.toString(uint256)
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits;
        temp = value;
        while (temp != 0) {
            index -= 1;
            uint8 digit = uint8(temp % 10);
            buffer[index] = bytes1(uint8(48 + digit));
            temp /= 10;
        }
        return string(buffer);
    }
}
