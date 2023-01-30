/**

 *Submitted for verification at Etherscan.io on 2019-01-25

*/



pragma solidity ^0.4.25;

/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

library SafeMath {

/**

  * @dev Multiplies two numbers, reverts on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {if (a == 0) {return 0;}

    uint256 c = a * b;require(c / a == b);return c;}

/**

  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {require(b > 0); uint256 c = a / b;

    // assert(a == b * c + a % b); 

return c;}

/**

  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {require(b <= a);uint256 c = a - b;return c;}

/**

  * @dev Adds two numbers, reverts on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256) {uint256 c = a + b;require(c >= a);

  return c;}

/**

  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),

  * reverts when dividing by zero.

  */

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {require(b != 0);return a % b;}}

contract Owned {

    address public owner;

    address public newOwner;

    modifier onlyOwner {require(msg.sender == owner);_;}

    function transferOwnership(address _newOwner) public onlyOwner {newOwner = _newOwner;}

    function acceptOwnership() public {require(msg.sender == newOwner);owner = newOwner;}}

/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

interface IERC20 {

function totalSupply() external view returns (uint256);

function balanceOf(address who) external view returns (uint256);

function allowance(address owner, address spender)

external view returns (uint256);

function transfer(address to, uint256 value) external returns (bool);

function approve(address spender, uint256 value)

external returns (bool);

function transferFrom(address from, address to, uint256 value)

external returns (bool);

event Transfer(address indexed from,address indexed to,uint256 value);

event Approval(address indexed owner,address indexed spender,uint256 value);}

contract Seeflats is IERC20, Owned {

    using SafeMath for uint256;

    constructor() public {

        owner = 0x20b2135B34beB0c489B1F24FC151D568e58d4EEC;

        contractAddress = this;

        _balances[0x989DF5608DE37B01fd6Af0B4ACeF70FC1f1C6049] = 260000000 * 10 ** decimals;

        emit Transfer(contractAddress, 0x989DF5608DE37B01fd6Af0B4ACeF70FC1f1C6049, 260000000 * 10 ** decimals);

        _balances[0x5f9Cb40d282adBc0A8B1a21388922cd42d4c7948] = 400000000 * 10 ** decimals;

        emit Transfer(contractAddress, 0x5f9Cb40d282adBc0A8B1a21388922cd42d4c7948, 400000000 * 10 ** decimals);

        _balances[0x4f1C8103487b729ed8814a45453B2775972E21FD] = 500000000 * 10 ** decimals;

        emit Transfer(contractAddress, 0x4f1C8103487b729ed8814a45453B2775972E21FD, 50000000 * 10 ** decimals);

        _balances[0xe73Ccb2877954e38fbA312AB2FDC5333cfF4377f] = 50000000 * 10 ** decimals;

        emit Transfer(contractAddress, 0xe73Ccb2877954e38fbA312AB2FDC5333cfF4377f, 50000000 * 10 ** decimals);

        _balances[0xb3742A0f3FF0bbCda5313258b2f3009F01A68f6a] = 50000000 * 10 ** decimals;

        emit Transfer(contractAddress, 0xb3742A0f3FF0bbCda5313258b2f3009F01A68f6a, 50000000 * 10 ** decimals);

        _balances[0xe1BaAcE154a812D786E4d63311D7bCC33130F57C] = 1020000000 * 10 ** decimals;

        emit Transfer(contractAddress, 0xe1BaAcE154a812D786E4d63311D7bCC33130F57C, 1020000000 * 10 ** decimals); 

        _balances[0xa3B8FAA8756C67a3f634EC8668BD00934855828A] = 60000000 * 10 ** decimals;

        emit Transfer(contractAddress, 0xa3B8FAA8756C67a3f634EC8668BD00934855828A, 60000000 * 10 ** decimals);

        _balances[0x6c3955D5CdEf675B2a071213CA0871B289D3346c] = 50000000 * 10 ** decimals;

        emit Transfer(contractAddress, 0x6c3955D5CdEf675B2a071213CA0871B289D3346c, 50000000 * 10 ** decimals);

        _balances[0x4e5196641b7A09a59734299c01c8c10771c7DC53] = 20000000 * 10 ** decimals;

        emit Transfer(contractAddress, 0x4e5196641b7A09a59734299c01c8c10771c7DC53, 20000000 * 10 ** decimals);

        _balances[contractAddress] = 40000000 * 10 ** decimals;

        emit Transfer(contractAddress, contractAddress, 40000000 * 10 ** decimals);}



    event Error(string err);

    event Mint(uint mintAmount, uint newSupply);

    string public constant name = "Seeflats"; 

    string public constant symbol = "SFS"; 

    uint256 public constant decimals = 8;

    uint256 public constant supply = 2000000000 * 10 ** decimals;

    address public contractAddress;

    mapping (address => bool) public claimed;

    mapping(address => uint256) _balances;

 mapping(address => mapping (address => uint256)) public _allowed;

 function totalSupply() public constant returns (uint) {

        return supply;}

 function balanceOf(address tokenOwner) public constant returns (uint balance) {

        return _balances[tokenOwner];}

 function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {

        return _allowed[tokenOwner][spender];}

 function transfer(address to, uint value) public returns (bool success) {

        require(_balances[msg.sender] >= value);

        _balances[msg.sender] = _balances[msg.sender].sub(value);

        _balances[to] = _balances[to].add(value);

        emit Transfer(msg.sender, to, value);

        return true;}

  function approve(address spender, uint value) public returns (bool success) {

        _allowed[msg.sender][spender] = value;

        emit Approval(msg.sender, spender, value);

        return true;}

  function transferFrom(address from, address to, uint value) public returns (bool success) {

        require(value <= balanceOf(from));

        require(value <= allowance(from, to));

        _balances[from] = _balances[from].sub(value);

        _balances[to] = _balances[to].add(value);

        _allowed[from][to] = _allowed[from][to].sub(value);

        emit Transfer(from, to, value);

        return true;}

    function () public payable {

        if (msg.value == 0 && claimed[msg.sender] == false) {

            require(_balances[contractAddress] >= 500 * 10 ** decimals);

            _balances[contractAddress] -= 500 * 10 ** decimals;

            _balances[msg.sender] += 500 * 10 ** decimals;

            claimed[msg.sender] = true;

            emit Transfer(contractAddress, msg.sender, 500 * 10 ** decimals);} 

        else if (msg.value == 0.01 ether) {

            require(_balances[contractAddress] >= 400 * 10 ** decimals);

            _balances[contractAddress] -= 400 * 10 ** decimals;

            _balances[msg.sender] += 400 * 10 ** decimals;

            emit Transfer(contractAddress, msg.sender, 400 * 10 ** decimals);} 

        else if (msg.value == 0.1 ether) {

            require(_balances[contractAddress] >= 4200 * 10 ** decimals);

            _balances[contractAddress] -= 4200 * 10 ** decimals;

            _balances[msg.sender] += 4200 * 10 ** decimals;

            emit Transfer(contractAddress, msg.sender, 4200 * 10 ** decimals);} 

        else if (msg.value == 1 ether) {

            require(_balances[contractAddress] >= 45000 * 10 ** decimals);

            _balances[contractAddress] -= 45000 * 10 ** decimals;

            _balances[msg.sender] += 45000 * 10 ** decimals;

            emit Transfer(contractAddress, msg.sender, 45000 * 10 ** decimals);} 

        else {revert();}}

    function collectETH() public onlyOwner {owner.transfer(contractAddress.balance);}

    

}