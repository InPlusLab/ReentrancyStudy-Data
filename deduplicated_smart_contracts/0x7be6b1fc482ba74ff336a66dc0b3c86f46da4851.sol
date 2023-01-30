/**
 *Submitted for verification at Etherscan.io on 2021-09-08
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.2;

interface IUniswap {
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IERC721 {

    function mint(address to, uint32 _assetType, uint256 _value, uint32 _customDetails) external returns (bool success);
    function assetsByType(uint256 _typeId) external view returns (uint64 _maxAmount, uint64 _mintedAmount, uint64 _coinIndex, string memory copyright);
    function tradeCoins(uint256 coinIndex) external view returns (address _tokenAddress, string memory _symbol, string memory _name);

}
contract Ownable {

    address private owner;
    
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }

    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }


    function changeOwner(address newOwner) public onlyOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }

    function getOwner() external view returns (address) {
        return owner;
    }
}

contract POLN3DSeller is Ownable {
    
    address public nftAddress;
    IUniswap public uniswapRouter;
    address payable public sellingWallet;
    uint256 slippage = 2;
    
    mapping(uint => uint) public assets;
    
    constructor() {
        sellingWallet = payable(0xAD334543437EF71642Ee59285bAf2F4DAcBA613F);
        nftAddress = 0xB20217bf3d89667Fa15907971866acD6CcD570C8;
        uniswapRouter = IUniswap(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        assets[47] = 1000000000;

    }
    
    function getPrice(uint _assetType) public view returns (uint256) {
        address[] memory path = new address[](2);
        path[0] = 0xdAC17F958D2ee523a2206206994597C13D831ec7; // USDT
        path[1] = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // WETH
        uint256[] memory uprices = uniswapRouter.getAmountsOut(assets[_assetType], path);
        return uprices[1];
    }
    
    function calcMaxSlippage(uint256 _amount) public view returns (uint256) {
        return (_amount - ((_amount * slippage) / 100));
    }

    function buyWithEth(uint256 assetType, uint256 assetDetails) public payable returns (bool) {
        IERC721 nft = IERC721(nftAddress);
        (, , uint64 _coinIndex, ) = nft.assetsByType(assetType);
        require(_coinIndex == 1 , "Invalid coin");
        require(assets[assetType] != 0, "Invalid asset");
        uint256 sellingPrice = getPrice(assets[assetType]);
        require(msg.value >= (calcMaxSlippage(sellingPrice)), 'Invalid amount');
        require(sellingWallet.send(msg.value));
        require(nft.mint(msg.sender, uint32(assetType), sellingPrice, uint32(assetDetails)), "Not possible to mint this type of asset");
        return true;
    }
    
    function setPrice(uint256 _assetId, uint256 _newPrice) public onlyOwner {
        assets[_assetId] = _newPrice;
    }
    
    function setSlippage(uint256 _slippage) public onlyOwner {
        slippage = _slippage;
    }

    
    
}