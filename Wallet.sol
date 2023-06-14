pragma solidity ^0.8.20;

interface IERC20 {
    function transfer(address to, uint256 amount) external returns (bool);
}

interface IERC721 {
    function transferFrom(address from, address to, uint256 tokenId) external;
    function balanceOf(address owner) external view returns (uint256);
}

contract Wallet {
    address public owner;
    address public keyTokenAddress;
    
    struct ERC721Token {
        address tokenAddress;
        uint256 tokenId;
    }
    
    mapping(uint256 => ERC721Token) private erc721Tokens;
    
    constructor(address _keyTokenAddress) {
        owner = msg.sender;
        keyTokenAddress = _keyTokenAddress;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function.");
        _;
    }
    
    modifier onlyWithKeyToken() {
        IERC721 keyToken = IERC721(keyTokenAddress);
        require(keyToken.balanceOf(msg.sender) > 0, "Key token is required for this operation.");
        _;
    }
    
    function transferEther(address payable to, uint256 amount) external payable onlyWithKeyToken {
        require(address(this).balance >= amount, "Insufficient balance in the wallet.");
        to.transfer(amount);
    }
    
    function transferERC20(address tokenAddress, address to, uint256 amount) external onlyWithKeyToken {
        IERC20 token = IERC20(tokenAddress);
        require(token.transfer(to, amount), "ERC20 transfer failed.");
    }
    
    function addERC721Token(address tokenAddress, uint256 tokenId) external onlyWithKeyToken {
        erc721Tokens[tokenId] = ERC721Token(tokenAddress, tokenId);
    }
    
    function removeERC721Token(uint256 tokenId) external onlyWithKeyToken {
        delete erc721Tokens[tokenId];
    }
    
    function transferERC721(uint256 tokenId, address to) external onlyWithKeyToken {
        ERC721Token memory tokenData = erc721Tokens[tokenId];
        require(tokenData.tokenAddress != address(0), "ERC721 token not found in the wallet.");
        
        IERC721 token = IERC721(tokenData.tokenAddress);
        token.transferFrom(address(this), to, tokenId);
    }
}
