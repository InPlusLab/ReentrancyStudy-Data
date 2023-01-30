/**
 *Submitted for verification at Etherscan.io on 2020-07-16
*/

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

pragma solidity ^0.5.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

// File: contracts/MultisigVaultETH.sol

pragma solidity ^0.5.0;



/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract MultisigVaultETH {

    using SafeMath for uint256;

    struct Approval {
        uint32 nonce;
        uint8  coincieded;
        bool   skipFee;
        address[] coinciedeParties;
    }

    uint8 private participantsAmount;
    uint8 private signatureMinThreshold;
    uint32 private nonce;
    address public currencyAddress;
    uint16 private serviceFeeMicro;
    address private _owner;

    mapping(address => bool) public parties;

    mapping(
        // Destination
        address => mapping(
            // Amount
            uint256 => Approval
        )
    ) public approvals;

    mapping(uint256 => bool) public finished;

    event ConfirmationReceived(address indexed from, address indexed destination, address currency, uint256 amount);
    event ConsensusAchived(address indexed destination, address currency, uint256 amount);

    /**
      * @dev Construcor.
      *
      * Requirements:
      * - `_signatureMinThreshold` .
      * - `_parties`.
      */
    constructor(
        uint8 _signatureMinThreshold,
        address[] memory _parties
    ) public {
        require(_parties.length > 0 && _parties.length <= 10);
        require(_signatureMinThreshold > 0 && _signatureMinThreshold <= _parties.length);

        _owner = msg.sender;

        signatureMinThreshold = _signatureMinThreshold;

        for (uint256 i = 0; i < _parties.length; i++) parties[_parties[i]] = true;

        serviceFeeMicro = 5000; // Of a million or 0.5%
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(isOwner(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Returns the nonce number of releasing transaction by destination and amount.
     */
    function getNonce(
        address _destination,
        uint256 _amount
    ) public view returns (uint256) {
        Approval storage approval = approvals[_destination][_amount];

        return approval.nonce;
    }


    /**
     * @dev Returns boolean id party provided its approval.
     */
    function partyCoincieded(
        address _destination,
        uint256 _amount,
        uint256 _nonce,
        address _partyAddress
    ) public view returns (bool) {
        if ( finished[_nonce] ) {
          return true;
        } else {
          Approval storage approval = approvals[_destination][_amount];

          for (uint i=0; i<approval.coinciedeParties.length; i++) {
             if (approval.coinciedeParties[i] == _partyAddress) return true;
          }

          return false;
        }
    }

    function approve(
        address payable _destination,
        uint256 _amount
    ) public returns (bool) {
        approveAndRelease( _destination, _amount, false);
    }


    function regress(
        address payable _destination,
        uint256 _amount
    ) public onlyOwner() returns (bool) {
        approveAndRelease( _destination, _amount, true);
    }


    function approveAndRelease(
        address payable _destination,
        uint256 _amount,
        bool    _skipServiceFee
    ) internal returns (bool) {
       require(parties[msg.sender], "Release: not a member");
       address multisig = address(this);  // https://biboknow.com/page-ethereum/78597/solidity-0-6-0-addressthis-balance-throws-error-invalid-opcode
       require(multisig.balance >= _amount, "Release:  insufficient balance");

       Approval storage approval = approvals[_destination][_amount]; // Create new project

       bool coinciedeParties = false;
       for (uint i=0; i<approval.coinciedeParties.length; i++) {
          if (approval.coinciedeParties[i] == msg.sender) coinciedeParties = true;
       }

       require(!coinciedeParties, "Release: party already approved");

       if (approval.coincieded == 0) {
           nonce += 1;
           approval.nonce = nonce;
       }

       approval.coinciedeParties.push(msg.sender);
       approval.coincieded += 1;

       if (_skipServiceFee) {
           approval.skipFee = true;
       }

       emit ConfirmationReceived(msg.sender, _destination, currencyAddress, _amount);

       if ( approval.coincieded >= signatureMinThreshold ) {
           releaseFunds(_destination, _amount, approval.skipFee);
           finished[approval.nonce] = true;
           delete approvals[_destination][_amount];

           emit ConsensusAchived(_destination, currencyAddress, _amount);
       }

      return false;
    }

    function releaseFunds(
      address payable _destination,
      uint256 _amount,
      bool    _skipServiceFee
    ) internal {
        if (_skipServiceFee) {
            _destination.transfer(_amount); // Release funds
        } else {
            uint256 _amountToWithhold = _amount.mul(serviceFeeMicro).div(1000000);
            uint256 _amountToRelease = _amount.sub(_amountToWithhold);

            _destination.transfer(_amountToRelease); // Release funds
            address payable _serviceAddress = address(uint160(serviceAddress())); // convert service address to payable
            _serviceAddress.transfer(_amountToWithhold);   // Take service margin
        }
    }

    function etherAddress() public pure returns (address) {
        return address(0x1);
    }

    function serviceAddress() public pure returns (address) {
        return address(0x0A67A2cdC35D7Db352CfBd84fFF5e5F531dF62d1);
    }

    function () external payable {}
}