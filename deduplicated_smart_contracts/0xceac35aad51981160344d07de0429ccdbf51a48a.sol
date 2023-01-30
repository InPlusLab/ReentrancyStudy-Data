pragma solidity ^0.6.3;

import "./TokenEXD.sol";

contract Ownable {
    address payable public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "caller is not owner");
        _;
    }

    function transferOwnership(address payable newOwner) public onlyOwner {
        require(newOwner != address(0), "new owner must be a valid address");
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

}

contract TokenHolder is Ownable {

    function withdrawTokens(HumanStandardToken _token, address _to, uint256 _amount)
        public
        onlyOwner
    {
        require(_to != address(0));
        require(_to != address(this));
        assert(_token.transfer(_to, _amount));
    }
}

contract ExodusExchanger is TokenHolder {
    uint256 public price = 1;
    HumanStandardToken public tokenContract;

    constructor(uint256 _price, HumanStandardToken _tokenContract) public {
        price = _price;
        tokenContract = _tokenContract;

    }

    function setPrice(uint256 newPrice) public onlyOwner {
        require(newPrice > 0, "inva1id price");
        price = newPrice;
    }

    receive() external payable {
        require(msg.value > 0, "no eth received");
        exchangeToken(msg.sender);
    }

    // from safemath
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function exchangeToken(address _buyer) public payable {
        uint256 amount = mul(msg.value, price);
        tokenContract.transfer(_buyer, amount);
    }
    
    function withdrawETH() public onlyOwner {
        owner.transfer(address(this).balance);
    }

}

