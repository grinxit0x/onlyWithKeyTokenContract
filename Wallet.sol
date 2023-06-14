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
    
    function transferERC721(address tokenAddress, address to, uint256 tokenId) external onlyWithKeyToken {
        IERC721 token = IERC721(tokenAddress);
        require(token.balanceOf(address(this)) > 0, "No ERC721 tokens in the wallet.");
        token.transferFrom(address(this), to, tokenId);
    }
}
