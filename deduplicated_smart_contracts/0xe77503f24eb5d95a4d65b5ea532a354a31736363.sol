/**
 *Submitted for verification at Etherscan.io on 2019-10-25
*/

// File: openzeppelin-solidity/contracts/ownership/Secondary.sol

pragma solidity ^0.5.2;

/**
 * @title Secondary
 * @dev A Secondary contract can only be used by its primary account (the one that created it)
 */
contract Secondary {
    address private _primary;

    event PrimaryTransferred(
        address recipient
    );

    /**
     * @dev Sets the primary account to the one that is creating the Secondary contract.
     */
    constructor () internal {
        _primary = msg.sender;
        emit PrimaryTransferred(_primary);
    }

    /**
     * @dev Reverts if called from any account other than the primary.
     */
    modifier onlyPrimary() {
        require(msg.sender == _primary);
        _;
    }

    /**
     * @return the address of the primary.
     */
    function primary() public view returns (address) {
        return _primary;
    }

    /**
     * @dev Transfers contract to a new primary.
     * @param recipient The address of new primary.
     */
    function transferPrimary(address recipient) public onlyPrimary {
        require(recipient != address(0));
        _primary = recipient;
        emit PrimaryTransferred(_primary);
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

    function decimals() external view returns (uint digits);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

// File: contracts/CharityVault.sol

pragma solidity ^0.5.2;




/**
 * @title CharityVault
 * @dev Vault which holds the assets until the community leader(s) decide to transfer
 * them to the actual charity destination.
 * Deposit and withdrawal calls come only from the actual community contract
 */
contract CharityVault is Secondary {
    using SafeMath for uint256;

    mapping(address => uint256) private deposits;
    CurrencyConverterInterface public currencyConverter;
    ERC20 public stableToken;
    uint256 public sumStats;

    event LogStableTokenReceived(
        uint256 amount,
        address indexed account
    );
    event LogStableTokenSent(
        uint256 amount,
        address indexed account
    );

    /**
    * @dev not allowed, can't store ETH
    **/
    function() external {
        //no 'payable' here
    }

    function setCurrencyConverter(address _converter) public onlyPrimary {
        currencyConverter = CurrencyConverterInterface(_converter);
        stableToken = ERC20(currencyConverter.getStableToken());
    }

    /**
     * @dev Receives it's part in ETH, converts it to a stablecoin and stores it.
     * @param _payee The destination address of the funds.
     */
    function deposit(address _payee) public onlyPrimary payable {
        uint256 _amount = currencyConverter.executeSwapMyETHToStable.value(msg.value)();
        deposits[_payee] = deposits[_payee].add(_amount);
        sumStats = sumStats.add(_amount);
        emit LogStableTokenReceived(_amount, _payee);
    }

    /**
     * @dev Withdraw some of accumulated balance for a _payee.
     */
    function withdraw(address payable _payee, uint256 _payment) public onlyPrimary {
        require(_payment > 0 && stableToken.balanceOf(address(this)) >= _payment, "Insufficient funds in the charity fund");
        stableToken.transfer(_payee, _payment);
        emit LogStableTokenSent(_payment, _payee);
    }

    function depositsOf(address payee) public view returns (uint256) {
        return deposits[payee];
    }
}

interface CurrencyConverterInterface {
    function executeSwapMyETHToStable() external payable returns (uint256);

    function getStableToken() external view returns (address);
}