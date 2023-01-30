/**
 *Submitted for verification at Etherscan.io on 2019-12-06
*/

pragma solidity ^0.5.0;

contract CrowdsaleToken {
    /* Public variables of the token */
    string public constant name = 'Rocketclock';
    string public constant symbol = 'RCLK';
    //uint256 public constant decimals = 6;
    address payable owner;
    address payable contractaddress;
    uint256 public constant totalSupply = 1000;

    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    //mapping (address => mapping (address => uint256)) public allowance;

    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address payable indexed from, address payable indexed to, uint256 value);
    //event LogWithdrawal(address receiver, uint amount);

    modifier onlyOwner() {
        // Only owner is allowed to do this action.
        if (msg.sender != owner) {
            revert();
        }
        _;
    }

    /* Initializes contract with initial supply tokens to the creator of the contract */
    constructor() public{
        contractaddress = address(this);
        owner = msg.sender;
        balanceOf[owner] = totalSupply;
        //balanceOf[contractaddress] = totalSupply;

    }

    /*ERC20*/
    /* Internal transfer, only can be called by this contract */
    function _transfer(address payable _from, address payable _to, uint256 _value) internal {
    //function _transfer(address _from, address _to, uint _value) public {
        require (_to != address(0x0));                               // Prevent transfer to 0x0 address. Use burn() instead
        require (balanceOf[_from] > _value);                // Check if the sender has enough
        require (balanceOf[_to] + _value > balanceOf[_to]); // Check for overflows
        balanceOf[_from] -= _value;                         // Subtract from the sender
        balanceOf[_to] += _value;                            // Add the same to the recipient
        emit Transfer(_from, _to, _value);
    }

    /// @notice Send `_value` tokens to `_to` from your account
    /// @param _to The address of the recipient
    /// @param _value the amount to send
    function transfer(address payable _to, uint256 _value) public returns (bool success) {

        _transfer(msg.sender, _to, _value);
        return true;

    }

    /*fallback function*/
    function () external payable onlyOwner{}


    function getBalance(address addr) public view returns(uint256) {
  		return balanceOf[addr];
  	}

    function getEtherBalance() public view returns(uint256) {
  		//return contract ether balance;
      return address(this).balance;
  	}

    function getOwner() public view returns(address) {
      return owner;
    }

}