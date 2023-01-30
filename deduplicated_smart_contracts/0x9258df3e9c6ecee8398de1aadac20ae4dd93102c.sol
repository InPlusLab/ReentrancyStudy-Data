/**

 *Submitted for verification at Etherscan.io on 2018-11-12

*/



pragma solidity ^0.4.24;





/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (_a == 0) {

      return 0;

    }



    c = _a * _b;

    assert(c / _a == _b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {

    // assert(_b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = _a / _b;

    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return _a / _b;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {

    assert(_b <= _a);

    return _a - _b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 _a, uint256 _b) internal pure returns (uint256 c) {

    c = _a + _b;

    assert(c >= _a);

    return c;

  }

}





/**

 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

  address public owner;





  event OwnershipRenounced(address indexed previousOwner);

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

   * @dev Allows the current owner to relinquish control of the contract.

   * @notice Renouncing to ownership will leave the contract without an owner.

   * It will not be possible to call the functions with the `onlyOwner`

   * modifier anymore.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);

    owner = address(0);

  }



  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param _newOwner The address to transfer ownership to.

   */

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);

  }



  /**

   * @dev Transfers control of the contract to a newOwner.

   * @param _newOwner The address to transfer ownership to.

   */

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));

    emit OwnershipTransferred(owner, _newOwner);

    owner = _newOwner;

  }

}





contract AerumCrowdsaleInterface {

    uint256 public tokensSold;

    uint256 public usdRaised;

    uint256 public weiRaised;

}



/**

 * @title Aerum crowdsale statistics contract

 */

contract AerumCrowdsaleStatistics is Ownable {

    using SafeMath for uint256;



    /**

     * @dev crowdsale Aerum crowdsale contract

     * @dev offchainTokensSold Off-chain tokens sold

     * @dev offchainUsdRaised Off-chain USD raised

     * @dev offchainWeiRaised Off-chain wei raised

     */

    AerumCrowdsaleInterface public crowdsale;

    uint256 public offchainTokensSold;

    uint256 public offchainUsdRaised;

    uint256 public offchainWeiRaised;



    /**

     * @param _crowdsale Aerum crowdsale contract

     * @param _offchainTokensSold Off-chain tokens sold

     * @param _offchainUsdRaised Off-chain USD raised

     * @param _offchainWeiRaised Off-chain wei raised

     */

    constructor(

        AerumCrowdsaleInterface _crowdsale,

        uint256 _offchainTokensSold,

        uint256 _offchainUsdRaised,

        uint256 _offchainWeiRaised)

    public {

        require(_crowdsale != address(0));



        crowdsale = _crowdsale;

        offchainTokensSold = _offchainTokensSold;

        offchainUsdRaised = _offchainUsdRaised;

        offchainWeiRaised = _offchainWeiRaised;

    }



    function setOffchainTokensSold(uint256 _tokens) external onlyOwner {

        offchainTokensSold = _tokens;

    }



    function setOffchainUsdRaised(uint256 _usd) external onlyOwner {

        offchainUsdRaised = _usd;

    }



    function setOffchainWeiRaised(uint256 _wei) external onlyOwner {

        offchainWeiRaised = _wei;

    }



    function setOffchainStatistics(uint256 _tokens, uint256 _usd, uint256 _wei) external onlyOwner {

        offchainTokensSold = _tokens;

        offchainUsdRaised = _usd;

        offchainWeiRaised = _wei;

    }



    function getTotalTokensSold() public view returns (uint256) {

        return offchainTokensSold.add(crowdsale.tokensSold());

    }



    function getTotalUsdRaised() public view returns (uint256) {

        return offchainUsdRaised.add(crowdsale.usdRaised());

    }



    function getTotalWeiRaised() public view returns (uint256) {

        return offchainWeiRaised.add(crowdsale.weiRaised());

    }



    function getTotalStatistics() external view returns (uint256, uint256, uint256) {

        return (getTotalTokensSold(), getTotalUsdRaised(), getTotalWeiRaised());

    }

}