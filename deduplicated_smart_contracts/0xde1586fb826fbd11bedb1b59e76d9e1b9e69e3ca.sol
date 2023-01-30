/**
 *Submitted for verification at Etherscan.io on 2019-07-22
*/

pragma solidity >=0.4.25 <0.6.0;


contract TransferController {
    
    
    
    event CurrencyTransferred(address from, address to, uint256 value,
        address currencyCt, uint256 currencyId);

    
    
    
    function isFungible()
    public
    view
    returns (bool);

    function standard()
    public
    view
    returns (string memory);

    
    function receive(address from, address to, uint256 value, address currencyCt, uint256 currencyId)
    public;

    
    function approve(address to, uint256 value, address currencyCt, uint256 currencyId)
    public;

    
    function dispatch(address from, address to, uint256 value, address currencyCt, uint256 currencyId)
    public;

    

    function getReceiveSignature()
    public
    pure
    returns (bytes4)
    {
        return bytes4(keccak256("receive(address,address,uint256,address,uint256)"));
    }

    function getApproveSignature()
    public
    pure
    returns (bytes4)
    {
        return bytes4(keccak256("approve(address,uint256,address,uint256)"));
    }

    function getDispatchSignature()
    public
    pure
    returns (bytes4)
    {
        return bytes4(keccak256("dispatch(address,address,uint256,address,uint256)"));
    }
}

interface IERC20 {
    
    function totalSupply() external view returns (uint256);

    
    function balanceOf(address account) external view returns (uint256);

    
    function transfer(address recipient, uint256 amount) external returns (bool);

    
    function allowance(address owner, address spender) external view returns (uint256);

    
    function approve(address spender, uint256 amount) external returns (bool);

    
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    
    event Transfer(address indexed from, address indexed to, uint256 value);

    
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract ERC20TransferController is TransferController {
    
    
    
    string constant _standard = "ERC20";

    
    
    
    function isFungible()
    public
    view
    returns (bool)
    {
        return true;
    }

    function standard()
    public
    view
    returns (string memory)
    {
        return _standard;
    }

    
    function receive(address from, address to, uint256 amount, address currencyCt, uint256 currencyId)
    public
    {
        require(msg.sender != address(0), "Message sender is null address [ERC20TransferController.sol:47]");
        require(amount > 0, "Amount is strictly positive [ERC20TransferController.sol:48]");
        require(currencyId == 0, "Currency ID is not 0 [ERC20TransferController.sol:49]");

        require(IERC20(currencyCt).transferFrom(from, to, amount), "Transfer not successful [ERC20TransferController.sol:51]");

        
        emit CurrencyTransferred(from, to, amount, currencyCt, currencyId);
    }

    
    function approve(address to, uint256 amount, address currencyCt, uint256 currencyId)
    public
    {
        require(amount > 0, "Amount is strictly positive [ERC20TransferController.sol:61]");
        require(currencyId == 0, "Currency ID is not 0 [ERC20TransferController.sol:62]");

        require(IERC20(currencyCt).approve(to, amount), "Approval not successful [ERC20TransferController.sol:64]");
    }

    
    function dispatch(address from, address to, uint256 amount, address currencyCt, uint256 currencyId)
    public
    {
        require(amount > 0, "Amount is strictly positive [ERC20TransferController.sol:71]");
        require(currencyId == 0, "Currency ID is not 0 [ERC20TransferController.sol:72]");

        require(IERC20(currencyCt).approve(from, amount), "Approval not successful [ERC20TransferController.sol:74]");
        require(IERC20(currencyCt).transferFrom(from, to, amount), "Transfer not successful [ERC20TransferController.sol:75]");

        
        emit CurrencyTransferred(from, to, amount, currencyCt, currencyId);
    }
}