pragma solidity ^0.4.25;





//import "./ownable.sol";

//import "./safemath.sol";

//import "./TokenERC20.sol";







import "./owned.sol";

import "./safemath.sol";

import "./erc20.sol";









contract GoldCash is owned, ERC20 {

    using SafeMath for uint256;

    //coin details

    string public name = "GoldCash";  

    string public symbol = "GOC";

    uint256 public totalSupply;

    address public contractAddress = this; 

    uint8 public decimals = 18;

    // This creates an array with all balances

    mapping (address => uint256) public balanceOf;

    mapping (address => mapping (address => uint256)) public allowance;

    

    constructor (uint256 initialSupply, uint256 ownerSupply) public owned(){

        require(initialSupply >= ownerSupply);

        totalSupply = initialSupply.mul(10 ** uint256(decimals));  // Update total supply with the decimal amount

        uint256 ownertotalSupply = ownerSupply.mul(10 ** uint256(decimals));

        balanceOf[contractAddress] = totalSupply.sub(ownertotalSupply);

        balanceOf[msg.sender] = ownertotalSupply;

    }

    /*

        For coin transaction implementing ERC20

    */

    function totalSupply() public view returns (uint256){

        return totalSupply;

    }

    function allowance(address _giver, address _spender) public view returns (uint256){

        return allowance[_giver][_spender];

    }

    function balanceOf(address who) public view returns (uint256){

        return balanceOf[who];

    }

    //the transfer function core

    function _transfer(address _from, address _to, uint _value) internal {

        // Prevent transfer to 0x0 address. Use burn() instead

        require(_to != 0x0);

        // Check if the sender has enough

        require(balanceOf[_from] >= _value);

        // Check for overflows

        require(balanceOf[_to] + _value >= balanceOf[_to]);

        // Save this for an assertion in the future

        uint previousBalances = balanceOf[_from] + balanceOf[_to];

        // Subtract from the sender

        balanceOf[_from] -= _value;

        // Add the same to the recipient

        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);

        // Asserts are used to use static analysis to find bugs in your code. They should never fail

        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);

    }

    //user can transfer from an address that allowed

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(_value <= allowance[_from][msg.sender]);     // Check allowance

        allowance[_from][msg.sender] -= _value;

        _transfer(_from, _to, _value);

        return true;

    }



    //user can transfer from their balance

    function transfer(address _to, uint256 _value) public returns (bool success) {

        emit Transfer(msg.sender, _to, _value);

        _transfer(msg.sender, _to, _value);        

        emit noted_transfer(msg.sender, _to, _value, "", now);

        return true;

    }

    //transfer+note

    function notedTransfer (address _to, uint256 _value, string _note) public returns (bool success){

        _transfer(msg.sender, _to, _value);

        emit Transfer(msg.sender, _to, _value);

        emit noted_transfer(msg.sender, _to, _value, _note, now);

        return true;

    }

    event noted_transfer(address indexed from, address indexed to, uint256 value, string note, uint256 time);

    //give allowance for transfer to a user (spender)

    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }

}

