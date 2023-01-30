/**
 *Submitted for verification at Etherscan.io on 2020-06-10
*/

pragma solidity >=0.4.24 <0.6.0;

contract Erc20StdI {
    uint256 public totalSupply;

    function balanceOf(address _owner) public view returns (uint256 balance);
    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    /**
    * @dev Multiplies two numbers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Adds two numbers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

/**
 * @title Roles
 * @dev Library for managing addresses assigned to a Role.
 */
library Roles {
    struct Role {
        mapping(address => bool) bearer;
    }

    /**
     * @dev give an account access to this role
     */
    function add(Role storage role, address account) internal {
        require(account != address(0));
        require(!has(role, account));

        role.bearer[account] = true;
    }

    /**
     * @dev remove an account's access to this role
     */
    function remove(Role storage role, address account) internal {
        require(account != address(0));
        require(has(role, account));

        role.bearer[account] = false;
    }

    /**
     * @dev check if an account has this role
     * @return bool
     */
    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}

contract SetterRole {
    using Roles for Roles.Role;

    event SetterAdded(address indexed account);
    event SetterRemoved(address indexed account);

    Roles.Role private _setters;

    constructor () internal {
        _addSetter(msg.sender);
    }

    modifier onlySetter() {
        require(isSetter(msg.sender));
        _;
    }

    function isSetter(address account) public view returns (bool) {
        return _setters.has(account);
    }

    function addSetter(address account) public onlySetter {
        _addSetter(account);
    }

    function _addSetter(address account) internal {
        _setters.add(account);
        emit SetterAdded(account);
    }

    function removeSetter(address account) public onlySetter {
        _removeSetter(account);
    }

    function _removeSetter(address account) internal {
        _setters.remove(account);
        emit SetterRemoved(account);
    }
}

contract MinterRole is SetterRole{
    using Roles for Roles.Role;

    event MinterAdded(address indexed account);
    event MinterRemoved(address indexed account);

    Roles.Role private _minters;

    constructor () internal {

    }

    modifier onlyMinter() {
        require(isMinter(msg.sender));
        _;
    }

    function isMinter(address account) public view returns (bool) {
        return _minters.has(account);
    }

    function addMinter(address account) public onlySetter {
        _addMinter(account);
    }

    function _addMinter(address account) internal {
        _minters.add(account);
        emit MinterAdded(account);
    }

    function removeMinter(address account) public onlySetter {
        _removeMinter(account);
    }

    function _removeMinter(address account) internal {
        _minters.remove(account);
        emit MinterRemoved(account);
    }
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Mint(address indexed sender, uint amount0, uint amount1);
    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;
}

contract Erc20BuyerDAO is Erc20StdI, MinterRole {
    using SafeMath for uint256;

    string constant public  name = "BuyerDAO";
    string constant public  symbol = "BDT";
    uint8  constant public  decimals = 18;
    address public team;
    uint public factor = 10 ** 18;
    uint public totalSupply = 0;

    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;// WETH
    uint8 public rateDecimal = 6;//support 2 ~ 9

    struct PairRate {
        uint priceCumulativeLast;
        uint blockTimestampLast;
        uint rate;
    }

    mapping(address => PairRate) public pairRates;
    mapping(address => uint256) balances;
    mapping(address => mapping(address => uint256)) allowed;

    event Mint(address indexed beneficiary, uint cost, uint amount);
    event Withdraw(address indexed holder, uint amount, uint divs);
    event SetPair(address indexed token, address tokenEthPair);


    constructor() public{
        team = msg.sender;
    }

    function() payable external {

    }

    function mint(address _beneficiary, uint _txAmount, address _pairAddress) public onlyMinter {
        uint _miningRevenue = 0;
        if (_txAmount > 0) {
            //non-ETH£¬Convert to ETH exchange rate value.
            if (_pairAddress != address(0)) {
                _txAmount = _txAmount * getRealTimeTokenRate(_pairAddress) / (10 ** uint(rateDecimal));
            }

            if (factor > 0) {
                _miningRevenue = _txAmount * factor / (10 ** 18);
                factor = factor * 9999999 / 10000000;
            }

            if (_miningRevenue > 0) {
                balances[_beneficiary] = balances[_beneficiary].add(_miningRevenue);
                balances[team] = balances[team].add(_miningRevenue);
                totalSupply = _miningRevenue.mul(2).add(totalSupply);

                emit Transfer(address(0), _beneficiary, _miningRevenue);
                emit Transfer(address(0), team, _miningRevenue);
            }
        }

        emit Mint(_beneficiary, _txAmount, _miningRevenue);
    }

    /**
     * @dev Burns the specified amount of tokens and exchange for the corresponding amount of ether.
     * @param value The amount of token to be burned.
     */
    function withdraw(uint value) public returns (uint divs){
        require(value > 0 && balances[msg.sender] >= value);
        require(address(this).balance > 0);

        divs = address(this).balance * value / totalSupply;
        _burn(msg.sender, value);
        msg.sender.transfer(divs);

        emit Withdraw(msg.sender, value, divs);
    }

    /**
     * @dev Get real-time token rate, this will update the rate.
     */
    function getRealTimeTokenRate(address _pairAddress) internal returns (uint rate) {
        PairRate storage pairRate = pairRates[_pairAddress];
        IUniswapV2Pair ethTokenPair = IUniswapV2Pair(_pairAddress);

        uint _blockTimestampLast1 = pairRate.blockTimestampLast;
        uint _priceCumulativeLast1 = pairRate.priceCumulativeLast;
        (, , uint _blockTimestampLast2) = ethTokenPair.getReserves();
        uint _priceCumulativeLast2;

        if (_blockTimestampLast2 > _blockTimestampLast1) {
            _priceCumulativeLast2 = ethTokenPair.token0() == WETH ? ethTokenPair.price1CumulativeLast() : ethTokenPair.price0CumulativeLast();
            pairRate.rate = (_priceCumulativeLast2 - _priceCumulativeLast1) / (_blockTimestampLast2 - _blockTimestampLast1) * (10 ** uint(rateDecimal)) / (2 ** 112);
            pairRate.priceCumulativeLast = _priceCumulativeLast2;
            pairRate.blockTimestampLast = _blockTimestampLast2;
        }

        rate = pairRate.rate;
    }


    /**
    * @dev Setup token and decentralized exchange
    **/
    function setTokenAndEthPair(address _tokenEthPairAddress) public onlySetter returns (uint rate){
        IUniswapV2Pair _tokenEthPair = IUniswapV2Pair(_tokenEthPairAddress);
        address _tokenAddress = _tokenEthPair.token0() == WETH ? _tokenEthPair.token1() : _tokenEthPair.token0();

        require(_tokenAddress != address(0), "_tokenAddress is invalid.");
        require(_tokenEthPairAddress != address(0), "_ethTokenPairAddress is invalid.");

        PairRate storage pairRate = pairRates[_tokenEthPairAddress];

        uint _ethReserve = Erc20StdI(WETH).balanceOf(_tokenEthPairAddress);
        uint _tokenReserve = Erc20StdI(_tokenAddress).balanceOf(_tokenEthPairAddress);

        require(_ethReserve > 0 && _tokenReserve > 0, "_ethTokenPairAddress is invalid");

        (,, pairRate.blockTimestampLast) = _tokenEthPair.getReserves();
        pairRate.priceCumulativeLast = _tokenAddress < WETH ? _tokenEthPair.price0CumulativeLast() : _tokenEthPair.price1CumulativeLast();
        pairRate.rate = _ethReserve * (10 ** uint(rateDecimal)) / _tokenReserve;

        emit SetPair(_tokenAddress, _tokenEthPairAddress);

        return pairRate.rate;
    }

    /**
    * Setting rate decimal
    **/
    function setRateDecimal(uint8 _decimal) public onlySetter {
        require(_decimal >= 2 && _decimal < 10, "decimal value is too small.");
        rateDecimal = _decimal;
    }

    function setTeamAddr(address _team) public onlySetter {
        require(_team != address(0), "_team is invalid.");
        team = _team;
    }

    /**************ERC20 Function*****************/

    function transfer(address _to, uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]);
        require(_to != address(0));
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value && allowed[_from][msg.sender] >= _value);
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    /**
     * @dev Internal function that burns an amount of the token of a given
     * account.
     * @param account The account whose tokens will be burnt.
     * @param value The amount that will be burnt.
     */
    function _burn(address account, uint256 value) internal {
        require(account != address(0));

        totalSupply = totalSupply.sub(value);
        balances[account] = balances[account].sub(value);
        emit Transfer(account, address(0), value);
    }
}