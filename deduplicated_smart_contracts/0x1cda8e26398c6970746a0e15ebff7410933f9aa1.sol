/**
 *Submitted for verification at Etherscan.io on 2019-10-17
*/

// File: openzeppelin-solidity/contracts/ownership/Ownable.sol

pragma solidity ^0.5.2;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor () internal {
        _owner = msg.sender;
        emit OwnershipTransferred(address(0), _owner);
    }

    /**
     * @return the address of the owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner());
        _;
    }

    /**
     * @return true if `msg.sender` is the owner of the contract.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Allows the current owner to relinquish control of the contract.
     * It will not be possible to call the functions with the `onlyOwner`
     * modifier anymore.
     * @notice Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0));
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.2;

/**
 * @title SafeMath
 * @dev Unsigned math operations with safety checks that revert on error
 */
library SafeMath {
    /**
     * @dev Multiplies two unsigned integers, reverts on overflow.
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
     * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Adds two unsigned integers, reverts on overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
     * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
     * reverts when dividing by zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

// File: ../smart-contracts/contracts/ERC20Interface.sol

pragma solidity ^0.5.2;


// https://github.com/ethereum/EIPs/issues/20
interface ERC20 {
    function totalSupply() external view returns (uint supply);
    function balanceOf(address _owner) external view returns (uint balance);
    function transfer(address _to, uint _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint _value) external returns (bool success);
    function approve(address _spender, uint _value) external returns (bool success);
    function allowance(address _owner, address _spender) external view returns (uint remaining);
    function decimals() external view returns(uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

// File: ../smart-contracts/contracts/KyberNetworkProxyInterface.sol

pragma solidity ^0.5.2;



/// @title Kyber Network interface
interface KyberNetworkProxyInterface {
    function maxGasPrice() external view returns(uint);
    function getUserCapInWei(address user) external view returns(uint);
    function getUserCapInTokenWei(address user, ERC20 token) external view returns(uint);
    function enabled() external view returns(bool);
    function info(bytes32 id) external view returns(uint);

    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) external view
        returns (uint expectedRate, uint slippageRate);

    function tradeWithHint(ERC20 src, uint srcAmount, ERC20 dest, address destAddress, uint maxDestAmount,
        uint minConversionRate, address walletId, bytes calldata hint) external payable returns(uint);
}

// File: contracts/KyberConverter.sol

pragma solidity ^0.5.2;





contract KyberConverter is Ownable {
    using SafeMath for uint256;
    ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);

    KyberNetworkProxyInterface public kyberNetworkProxyContract;
    address public walletId;

    // Events
    event Swap(address indexed sender, ERC20 srcToken, ERC20 destToken);

    /**
     * @dev Payable fallback to receive ETH while converting
     **/
    function() external payable {
    }

    constructor (KyberNetworkProxyInterface _kyberNetworkProxyContract, address _walletId) public {
        kyberNetworkProxyContract = _kyberNetworkProxyContract;
        walletId = _walletId;
    }

    /**
     * @dev Gets the conversion rate for the destToken given the srcQty.
     * @param srcToken source token contract address
     * @param srcQty amount of source tokens
     * @param destToken destination token contract address
     */
    function getConversionRates(
        ERC20 srcToken,
        uint srcQty,
        ERC20 destToken
    ) public
    view
    returns (uint, uint)
    {
        return kyberNetworkProxyContract.getExpectedRate(srcToken, destToken, srcQty);

    }

    /**
     * @dev Swap the user's ERC20 token to ETH and donates to the community.
     * Note: requires 'approve' srcToken first!
     * @param srcToken source token contract address
     * @param srcQty amount of source tokens
     * @param maxDestAmount address to send swapped tokens to
     * @param community address of the donation community
     */
    function executeSwapAndDonate(
        ERC20 srcToken,
        uint srcQty,
        uint maxDestAmount,
        IDonationCommunity community
    ) public {
        uint minConversionRate;

        // Save prev src token balance
        uint256 prevSrcBalance = srcToken.balanceOf(address(this));

        // Check that the token transferFrom has succeeded
        require(srcToken.transferFrom(msg.sender, address(this), srcQty));

        // Mitigate ERC20 Approve front-running attack, by initially setting
        // allowance to 0
        require(srcToken.approve(address(kyberNetworkProxyContract), 0));

        // Set the spender's token allowance to tokenQty
        require(srcToken.approve(address(kyberNetworkProxyContract), srcQty));

        // Get the minimum conversion rate
        (minConversionRate,) = kyberNetworkProxyContract.getExpectedRate(srcToken, ETH_TOKEN_ADDRESS, srcQty);

        // Swap the ERC20 token and send to 'this' contract address
        bytes memory hint;
        uint256 amount = kyberNetworkProxyContract.tradeWithHint(
            srcToken,
            srcQty,
            ETH_TOKEN_ADDRESS,
            address(this),
            maxDestAmount,
            minConversionRate,
            walletId,
            hint
        );

        // Clean kyber to use _srcTokens on belhalf of this contract
        require(
            srcToken.approve(address(kyberNetworkProxyContract), 0),
            "Could not clear approval of kyber to use srcToken on behalf of this contract"
        );

        // Return the change of src token
        uint256 change = srcToken.balanceOf(address(this)).sub(prevSrcBalance);

        if (change > 0) {
            require(
                srcToken.transfer(msg.sender, change),
                "Could not transfer change to sender"
            );
        }

        // donate ETH to the community
        community.donateDelegated.value(amount)(msg.sender);


        // Log the event
        emit Swap(msg.sender, srcToken, ETH_TOKEN_ADDRESS);
    }

    /**
     * @dev Recovery for change funds
     */
    function withdraw() public onlyOwner {
        require(address(this).balance > 0, "Insufficient funds to withdraw");
        msg.sender.transfer(address(this).balance);
    }

}

interface IDonationCommunity {

    function donateDelegated(address payable _donator) external payable;
}