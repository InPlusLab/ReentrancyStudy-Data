/**
 *Submitted for verification at Etherscan.io on 2020-11-17
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.6.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }
    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}
contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }
    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface ILPMining {
    function add(address pool, uint256 index, uint256 allocP) external;
    function set(uint256 pid, uint256 allocPoint) external;
    function updateReferenceToken(uint256 pid, uint256 rIndex) external;
    function batchSharePools() external;
    function onTransferLiquidity(address from, address to, uint256 lpAmount) external;
    function claimUserShares(uint pid, address user) external;
    function claimLiquidityShares(address user, address[] calldata tokens, uint256[] calldata balances, uint256[] calldata weights, uint256 amount, bool _add) external;
}

contract PriceOracle is Ownable {

    struct PriceInfo {
        uint8 decimal;
        uint256 price;
    }

    // contract governors
    mapping(address => bool) private governors;
    modifier onlyGovernor{
        require(governors[_msgSender()], "PriceOracle: caller is not the governor");
        _;
    }

    mapping(address => bool) public tokenIn;
    // tokens price
    mapping(address => PriceInfo) public tokenPrice;

    // event
    event RequestTokenPrice(address token, uint256 oldPrice);
    event RespondTokenPrice(address token, uint256 oldPrice, uint256 newPrice);

    constructor() public{
        governors[_msgSender()] = true;
    }

    // add governor
    function addGovernor(address governor) onlyOwner external {
        governors[governor] = true;
    }

    // remove governor
    function removeGovernor(address governor) onlyOwner external {
        governors[governor] = false;
    }

    // add token price info
    function addTokenInfo(address token, uint8 _decimal, uint256 _price) onlyOwner public {
        require(!tokenIn[token], "PriceOracle: duplicate token info");
        tokenPrice[token] = PriceInfo({
            decimal : _decimal,
            price : _price
            });
        tokenIn[token] = true;
    }

    //
    function requestTokenPrice(address token) external returns (uint8 decimal, uint256 price){
        decimal = tokenPrice[token].decimal;
        price = tokenPrice[token].price;
        emit RequestTokenPrice(token, price);
    }


    function respondTokenPrice(address token, uint256 newPrice, ILPMining lpMine) onlyGovernor external {
        require(tokenIn[token], "PriceOracle: token not exist");
        uint256 oldPrice = tokenPrice[token].price;
        tokenPrice[token].price = newPrice;
        lpMine.batchSharePools();
        emit RespondTokenPrice(token, oldPrice, newPrice);
    }
}