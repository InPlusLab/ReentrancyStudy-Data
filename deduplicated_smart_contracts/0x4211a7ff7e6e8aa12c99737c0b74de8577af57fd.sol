/**

 *Submitted for verification at Etherscan.io on 2019-04-25

*/



/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

  address public owner;



  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);



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

   * @param newOwner The address to transfer ownership to.

   */

  function transferOwnership(address newOwner) public onlyOwner {

    require(newOwner != address(0));

    emit OwnershipTransferred(owner, newOwner);

    owner = newOwner;

  }

}



/**

 * @title Destructible

 * @dev Base contract that can be destroyed by owner. All funds in contract will be sent to the owner.

 */

contract Destructible is Ownable {



  constructor() public payable { }



  /**

   * @dev Transfers the current balance to the owner and terminates the contract.

   */

  function destroy() onlyOwner public {

    selfdestruct(owner);

  }



  function destroyAndSend(address _recipient) onlyOwner public {

    selfdestruct(_recipient);

  }

}



contract Registry is Destructible {



    // Authorized users in the system

    mapping (address => bool) users;



    // Authroized charities in the system

    mapping (address => bool) charities;



    /**

     * Event for authorizations

     * @param registrar address of the account to be authorized

     * @param role type of account either "user" or "charity"

     * @param enabled boolean value that denotes the authorization

     */

    event Authorize(address indexed registrar, string role, bool enabled);



    modifier validAddress(address _addr) {

        require(_addr != address(0), "0x0 is not a valid address");

        require(_addr != address(this), "Contract address is not a valid address");

        _;

    }



    /**

     * @dev Checks to see if a user is authorized in the system

     * @param _address the address of the user

     * @return A boolean value of the users authorization status

     */

    function checkUser(address _address) public view validAddress(_address) returns (bool) {

        return users[_address];

    }



    /**

     * @dev Checks to see if a charity is authorized in the system

     * @param _address the address of the charity

     * @return A boolean value of the charity's authorization status

     */

    function checkCharity(address _address) public view validAddress(_address) returns (bool) {

        return charities[_address];

    }



    /**

     * @dev Sets the authorization status of a user

     * @param _address the address of the user

     * @param _enable the authorization status of a user

     */

    function authorizeUser(address _address, bool _enable) public onlyOwner validAddress(_address) {

        users[_address] = _enable;

        emit Authorize(_address, "user", _enable);

    }



    /**

     * @dev Sets the authorization status of a charity

     * @param _address the address of the charity

     * @param _enable the authorization status of a charity

     */

    function authorizeCharity(address _address, bool _enable) public onlyOwner validAddress(_address) {

        charities[_address] = _enable;

        emit Authorize(_address, "charity", _enable);

    }

}