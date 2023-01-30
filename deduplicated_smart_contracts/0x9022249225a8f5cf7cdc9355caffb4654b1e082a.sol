/**

 *Submitted for verification at Etherscan.io on 2018-11-14

*/



pragma solidity ^0.4.25;



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error.

 */

library SafeMath {

    // Multiplies two numbers, throws on overflow./

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

        if (a == 0) return 0;

        c = a * b;

        assert(c / a == b);

        return c;

    }

    // Integer division of two numbers, truncating the quotient.

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        return a / b;

    }

    // Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }

    // Adds two numbers, throws on overflow.

    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

        c = a + b;

        assert(c >= a);

        return c;

    }

}





/**

 * @title Smart-Mining 'team distribution'-contract - https://smart-mining.io - [email protected]

 */

contract SmartMining_Team {

    using SafeMath for uint256;

    

    // -------------------------------------------------------------------------

    // Variables

    // -------------------------------------------------------------------------

    

    struct Member {

        uint256 share;                            // Percent of mining profits

        uint256 unpaid;                           // Available Wei for withdrawal, + 1 in storage for gas optimization

    }                                              

    mapping (address => Member) private members;  // All contract members as 'Member'-struct

    

    uint16    public memberCount;                 // Count of all members

    address[] public memberIndex;                 // Lookuptable of all member addresses to iterate on deposit over and assign unpaid Ether to members

    address   public withdrawer;                  // Allowed executor of automatic processed member whitdrawals (SmartMining-API)

    address   public owner;                       // Owner of this contract

    

    

    // -------------------------------------------------------------------------

    // Private functions, can only be called by this contract

    // -------------------------------------------------------------------------

    

    function _addMember (address _member, uint256 _share) private {

        emit AddMember(_member, _share);

        members[_member].share = _share;

        members[_member].unpaid = 1;

        memberIndex.push(_member);

        memberCount++;

    }

    

    

    // -------------------------------------------------------------------------

    // Constructor

    // -------------------------------------------------------------------------

    

    constructor (address _owner) public {

        require(_owner != 0x0);

        

        // Initialize contract owner and trigger 'SetOwner'-event

        owner = _owner;

        emit SetOwner(owner);

        

        // Initialize withdrawer and trigger 'SetWithdrawer'-event

        withdrawer = msg.sender;

        emit SetWithdrawer(msg.sender);

        

        // Initialize members with their share (total 100) and trigger 'AddMember'-event

        _addMember(0xa440dC315E53d66a52828be147470f2A00Fc0cF4, 40);

        _addMember(0xE517CB63e4dD36533C26b1ffF5deB893E63c3afA, 40);

        _addMember(0x829381286b382E4597B02A69bAb5a74f73A1Ab75, 20);

    }

    

    

    // -------------------------------------------------------------------------

    // Events

    // -------------------------------------------------------------------------

    

    event SetOwner(address indexed owner);

    event SetWithdrawer(address indexed withdrawer);

    event AddMember(address indexed member, uint256 share);

    event Withdraw(address indexed member, uint256 value);

    event Deposit(address indexed from, uint256 value);

    

    

    // -------------------------------------------------------------------------

    // OWNER ONLY external maintenance interface

    // -------------------------------------------------------------------------

    

    modifier onlyOwner () {

        require(msg.sender == owner);

        _;

    }

    

    function setOwner (address _newOwner) external onlyOwner {

        if( _newOwner != 0x0 ) { owner = _newOwner; } else { owner = msg.sender; }

        emit SetOwner(owner);

    }

    

    function setWithdrawer (address _newWithdrawer) external onlyOwner {

        withdrawer = _newWithdrawer;

        emit SetWithdrawer(_newWithdrawer);

    }

    

    

    // -------------------------------------------------------------------------

    // Public external interface

    // -------------------------------------------------------------------------

    

    function () external payable {

        // Distribute deposited Ether to all members related to their profit-share

        for (uint i=0; i<memberIndex.length; i++) {

            members[memberIndex[i]].unpaid = 

                // Adding current deposit to members unpaid Wei amount

                members[memberIndex[i]].unpaid.add(

                    // MemberShare * DepositedWei / 100 = WeiAmount of member-share to be added to members unpaid holdings

                    members[memberIndex[i]].share.mul(msg.value).div(100)

                );

        }

        

        // Trigger 'Deposit'-event

        emit Deposit(msg.sender, msg.value);

    }

    

    function withdraw   ()                     external { _withdraw(msg.sender); }

    function withdrawOf (address _beneficiary) external { _withdraw(_beneficiary); }

    

    

    // -------------------------------------------------------------------------

    // Private functions, can only be called by this contract

    // -------------------------------------------------------------------------

    

    function _withdraw (address _beneficiary) private {

        // Pre-validate withdrawal

        if(msg.sender != _beneficiary) {

            require(msg.sender == owner || msg.sender == withdrawer, "Only 'owner' and 'withdrawer' can withdraw for other members.");

        }

        require(members[_beneficiary].unpaid >= 1, "Not a member account.");

        require(members[_beneficiary].unpaid > 1, "No unpaid balance on account.");

        

        // Remember members unpaid amount but remove it from his contract holdings before initiating the withdrawal for security reasons

        uint256 unpaid = members[_beneficiary].unpaid.sub(1);

        members[_beneficiary].unpaid = 1;

        

        // Trigger 'Withdraw'-event

        emit Withdraw(_beneficiary, unpaid);

        

        // Transfer the unpaid Wei amount to member address

        _beneficiary.transfer(unpaid);

    }

    

    function shareOf (address _member) public view returns (uint256) {

        // Get share percentage of member

        return members[_member].share;

    }

    

    function unpaidOf (address _member) public view returns (uint256) {

        // Get unpaid Wei amount of member

        return members[_member].unpaid.sub(1);

    }

    

    

}