/**
 *Submitted for verification at Etherscan.io on 2019-06-27
*/

pragma solidity ^0.5.7;


library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}


interface Storage {
    function allowOnlyDappContracts(address caller) external returns (bool);
}


interface SecondStorage {
    function onlyProjectControllers(address caller, uint256 pid) external view returns (bool);
}


////////////////////////////
//  RefundEther *** RETH
///////////////////////////


interface ERC20 {
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  function allowance(address owner, address spender) external view returns (uint256);
  function transfer(address to, uint256 value) external returns (bool);
  function approve(address spender, uint256 value) external returns (bool);
  function transferFrom(address from, address to, uint256 value) external returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/* Internal non-tradable token of the dApp used as an indicator for a secured amount of funds.
It¡¯s pegged at 1:1 ratio to Ether - 1 ETH = 1 rETH and 1 wei = 1 rwei. The total supply when
deployed is 1 rwei and the only way to mint new tokens is by the creation of new insurance.

The internal RefundEther token is used ONLY as an indication unit, meaning that at no point
in the dApp¡¯s functionality there is a conversion of funds from ETH to rETH. All funds are stored
and refunded only in Ether. */

contract RefundEther is ERC20 {
    using SafeMath for uint256;

    Storage data;
    SecondStorage secondStorage;

    string private  _name;
    string private  _symbol;
    uint8 private   _decimals;
    uint256 private _totalSupply;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowed;

    mapping (address => uint256) private frozenAmount;

    mapping (address => mapping(uint256 => uint256)) private protectedAmount;

    constructor(address dataStorage, address secondStorageAddr) public {
        _decimals = 18;
        _totalSupply = 1;
        _name = "RefundEther";
        _symbol = "RETH";

        _balances[msg.sender] = _totalSupply;
        data = Storage(dataStorage);
        secondStorage = SecondStorage(secondStorageAddr);
    }

    modifier onlyValidControllers(uint256 pid) {
        require(secondStorage.onlyProjectControllers(msg.sender, pid), "Not a valid controller");
        _;
    }

    modifier onlyNetworkContracts {
        if (data.allowOnlyDappContracts(msg.sender)) {
            _;
        } else {
            revert("Only network contracts allowed");
        }
    }

    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowed[owner][spender];
    }

    function balanceOf(address owner) public view returns (uint256) {
        return _balances[owner];
    }

    function transfer(address to, uint value)
        external
        onlyNetworkContracts
        returns (bool success)
    {
        _transfer(msg.sender, to, value);
        return true;
    }


    function transferFrom(address from, address to, uint value)
        external
        onlyNetworkContracts
        returns (bool success)
    {
        require (_allowed[from][msg.sender] >= value, "Insufficient RefundEther allowance");
        _allowed[from][msg.sender] = _allowed[from][msg.sender].sub(value);
        _transfer(from, to, value);
        return true;
    }

    function approve(address spender, uint value)
        external
        onlyNetworkContracts
        returns (bool success)
    {
        require(_freeRefundEtherTokens(msg.sender) >= value, "Insufficient RefundEther balance");
        _allowed[msg.sender][spender] = value;
        emit Approval(msg.sender, spender, value);
        return true;
    }

    function getAmountOfSecuredEther(
        address investor,
        uint256 projectId
    )
        external
        view
        returns (uint256)
    {
        if (investor != address(0)) {
            return protectedAmount[investor][projectId];
        } else {
            return protectedAmount[msg.sender][projectId];
        }
    }

    function setAmountOfSecuredEther(
        address investor,
        uint256 projectId,
        uint256 amount
    )
        external
        onlyValidControllers(projectId)
        returns (bool success)
    {
        protectedAmount[investor][projectId] = amount;
        frozenAmount[msg.sender] = frozenAmount[msg.sender].add(amount);
        return true;
    }

    function mint(address to, uint256 mintedAmount) external onlyNetworkContracts {
        _balances[to] = _balances[to].add(mintedAmount);
        _totalSupply = _totalSupply.add(mintedAmount);
    }

    function burn(address _tokensOwner, uint256 _value)
        public
        onlyNetworkContracts
        returns (bool success)
    {
        require(_balances[_tokensOwner] >= _value, "Insufficient RefundEther balance");
        _balances[_tokensOwner] = _balances[_tokensOwner].sub(_value);
        _totalSupply = _totalSupply.sub(_value);
        return true;
    }

    function _transfer(address _from, address _to, uint _value) internal {
        require (_freeRefundEtherTokens(_from) >= _value, "Insufficient RefundEther balance");
        _balances[_from] = _balances[_from].sub(_value);
        _balances[_to] = _balances[_to].add(_value);
        emit Transfer(_from, _to, _value);
    }

    function _freeRefundEtherTokens(address owner)
        internal
        view
        returns (uint256)
    {
        return _balances[owner].sub(frozenAmount[owner]);
    }
}