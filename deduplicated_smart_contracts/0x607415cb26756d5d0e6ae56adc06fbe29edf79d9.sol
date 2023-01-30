/**

 *Submitted for verification at Etherscan.io on 2019-05-13

*/



pragma solidity ^0.5.8;



/**

 * @title IENETChain Token - Artificial Tntelligence Sharing Economic Network.

 * @author Wang Yi - <[email protected]>

 */



contract SafeMath {

    function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a * b;

        assert(a == 0 || c / a == b);

        return c;

    }



    function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b > 0);

        uint256 c = a / b;

        assert(a == b * c + a % b);

        return c;

    }



    function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }



    function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        assert(c >= a && c >= b);

        return c;

    }

}



contract IECT is SafeMath {

    string constant tokenName = 'IENETChain';

    string constant tokenSymbol = 'IECT';

    uint8 constant decimalUnits = 8;



    string public name;

    string public symbol;

    uint8 public decimals;



    uint256 public totalSupply = 20 * (10**8) * (10**8); // 20 yi



    address public owner;

    

    mapping(address => bool) restrictedAddresses;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;



    /* This generates a public event on the blockchain that will notify clients */

    event Transfer(address indexed from, address indexed to, uint256 value);



    event Approval(address indexed _owner, address indexed _spender, uint256 _value);



    modifier onlyOwner {

        assert(owner == msg.sender);

        _;

    }



    /* Initializes contract with initial supply tokens to the creator of the contract */

    constructor() public {

        balanceOf[msg.sender] = totalSupply;                // Give the creator all tokens

        name = tokenName;                                   // Set the name for display purposes

        symbol = tokenSymbol;                               // Set the symbol for display purposes

        decimals = decimalUnits;                            // Amount of decimals for display purposes

        owner = msg.sender;

    }



    function transfer(address _to, uint256 _value) public returns (bool success) {

        require(_value > 0);

        require(balanceOf[msg.sender] >= _value);              // Check if the sender has enough

        require(balanceOf[_to] + _value >= balanceOf[_to]);    // Check for overflows

        require(!restrictedAddresses[msg.sender]);

        require(!restrictedAddresses[_to]);

        balanceOf[msg.sender] = SafeMath.safeSub(balanceOf[msg.sender], _value);   // Subtract from the sender

        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);                 // Add the same to the recipient

        emit Transfer(msg.sender, _to, _value);                  // Notify anyone listening that this transfer took place

        return true;

    }



    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowance[msg.sender][_spender] = _value;            // Set allowance

        emit  Approval(msg.sender, _spender, _value);              // Raise Approval event

        return true;

    }



    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

        require(balanceOf[_from] >= _value);                  // Check if the sender has enough

        require(balanceOf[_to] + _value >= balanceOf[_to]);   // Check for overflows

        require(_value <= allowance[_from][msg.sender]);      // Check allowance

        require(!restrictedAddresses[_from]);

        require(!restrictedAddresses[msg.sender]);

        require(!restrictedAddresses[_to]);

        balanceOf[_from] = SafeMath.safeSub(balanceOf[_from], _value);    // Subtract from the sender

        balanceOf[_to] = SafeMath.safeAdd(balanceOf[_to], _value);        // Add the same to the recipient

        allowance[_from][msg.sender] = SafeMath.safeSub(allowance[_from][msg.sender], _value);

        emit Transfer(_from, _to, _value);

        return true;

    }





    function() external payable {

        revert();

    }



    /* Owner can add new restricted address or removes one */

    function editRestrictedAddress(address _newRestrictedAddress) public onlyOwner {

        restrictedAddresses[_newRestrictedAddress] = !restrictedAddresses[_newRestrictedAddress];

    }



    function isRestrictedAddress(address _querryAddress) view public returns (bool answer) {

        return restrictedAddresses[_querryAddress];

    }

}