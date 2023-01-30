/**
 *Submitted for verification at Etherscan.io on 2019-10-27
*/

pragma solidity ^0.5.11;

interface ERC20 {

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);
}

contract Ownable {
  address payable public owner;

  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address payable _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address payable _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}


contract Mortal is Ownable {
    /**
     * kills the contract 
     * */
    function kill() public onlyOwner{
        owner.transfer(address(this).balance);
        selfdestruct(owner);
    }
}



contract Cryptoman is Mortal{

    /**
     * deposit
     * */
    function deposit() public payable {
    }

    /**
     * withdraw 
     * */
    function withdraw(uint amount, address payable receiver) public onlyOwner {
      require(address(this).balance >= amount, "insufficient balance");
      receiver.transfer(amount);
    }
    
    /**
    * withdraw tokens
    * */
    function withdrawTokens(address tokenAddress, uint amount, address payable receiver) public payable onlyOwner {
      ERC20 token = ERC20(tokenAddress);
      require(token.balanceOf(address(this))>=amount,"insufficient funds");
      token.transfer(receiver, amount);
    }


}