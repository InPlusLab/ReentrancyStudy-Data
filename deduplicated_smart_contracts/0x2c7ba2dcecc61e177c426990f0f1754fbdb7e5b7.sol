/**
 *Submitted for verification at Etherscan.io on 2019-08-02
*/

/*
-----------------------------------------------------------------
FILE INFORMATION
-----------------------------------------------------------------

file:       Owned.sol
version:    1.1
author:     Anton Jurisevic
            Dominic Romanowski

date:       2018-2-26

-----------------------------------------------------------------
MODULE DESCRIPTION
-----------------------------------------------------------------

An Owned contract, to be inherited by other contracts.
Requires its owner to be explicitly set in the constructor.
Provides an onlyOwner access modifier.

To change owner, the current owner must nominate the next owner,
who then has to accept the nomination. The nomination can be
cancelled before it is accepted by the new owner by having the
previous owner change the nomination (setting it to 0).

-----------------------------------------------------------------
*/

pragma solidity 0.4.25;

/**
 * @title A contract with an owner.
 * @notice Contract ownership can be transferred by first nominating the new owner,
 * who must then accept the ownership, which prevents accidental incorrect ownership transfers.
 */
contract Owned {
    address public owner;
    address public nominatedOwner;

    /**
     * @dev Owned Constructor
     */
    constructor(address _owner)
        public
    {
        require(_owner != address(0), "Owner address cannot be 0");
        owner = _owner;
        emit OwnerChanged(address(0), _owner);
    }

    /**
     * @notice Nominate a new owner of this contract.
     * @dev Only the current owner may nominate a new owner.
     */
    function nominateNewOwner(address _owner)
        external
        onlyOwner
    {
        nominatedOwner = _owner;
        emit OwnerNominated(_owner);
    }

    /**
     * @notice Accept the nomination to be owner.
     */
    function acceptOwnership()
        external
    {
        require(msg.sender == nominatedOwner, "You must be nominated before you can accept ownership");
        emit OwnerChanged(owner, nominatedOwner);
        owner = nominatedOwner;
        nominatedOwner = address(0);
    }

    modifier onlyOwner
    {
        require(msg.sender == owner, "Only the contract owner may perform this action");
        _;
    }

    event OwnerNominated(address newOwner);
    event OwnerChanged(address oldOwner, address newOwner);
}


contract ISynthetixState {
    // A struct for handing values associated with an individual user's debt position
    struct IssuanceData {
        // Percentage of the total debt owned at the time
        // of issuance. This number is modified by the global debt
        // delta array. You can figure out a user's exit price and
        // collateralisation ratio using a combination of their initial
        // debt and the slice of global debt delta which applies to them.
        uint initialDebtOwnership;
        // This lets us know when (in relative terms) the user entered
        // the debt pool so we can calculate their exit price and
        // collateralistion ratio
        uint debtEntryIndex;
    }

    uint[] public debtLedger;
    uint public issuanceRatio;
    mapping(address => IssuanceData) public issuanceData;

    function debtLedgerLength() external view returns (uint);
    function hasIssued(address account) external view returns (bool);
    function incrementTotalIssuerCount() external;
    function decrementTotalIssuerCount() external;
    function setCurrentIssuanceData(address account, uint initialDebtOwnership) external;
    function lastDebtLedgerEntry() external view returns (uint);
    function appendDebtLedgerValue(uint value) external;
    function clearIssuanceData(address account) external;
}


interface ISynth {
  function burn(address account, uint amount) external;
  function issue(address account, uint amount) external;
  function transfer(address to, uint value) public returns (bool);
  function triggerTokenFallbackIfNeeded(address sender, address recipient, uint amount) external;
  function transferFrom(address from, address to, uint value) public returns (bool);
}


/**
 * @title SynthetixEscrow interface
 */
interface ISynthetixEscrow {
    function balanceOf(address account) public view returns (uint);
    function appendVestingEntry(address account, uint quantity) public;
}


contract IFeePool {
    address public FEE_ADDRESS;
    uint public exchangeFeeRate;
    function amountReceivedFromExchange(uint value) external view returns (uint);
    function amountReceivedFromTransfer(uint value) external view returns (uint);
    function feePaid(bytes4 currencyKey, uint amount) external;
    function appendAccountIssuanceRecord(address account, uint lockedAmount, uint debtEntryIndex) external;
    function rewardsMinted(uint amount) external;
    function transferFeeIncurred(uint value) public view returns (uint);
}


/**
 * @title ExchangeRates interface
 */
interface IExchangeRates {
    function effectiveValue(bytes4 sourceCurrencyKey, uint sourceAmount, bytes4 destinationCurrencyKey) public view returns (uint);

    function rateForCurrency(bytes4 currencyKey) public view returns (uint);

    function anyRateIsStale(bytes4[] currencyKeys) external view returns (bool);

    function rateIsStale(bytes4 currencyKey) external view returns (bool);
}


/**
 * @title Synthetix interface contract
 * @dev pseudo interface, actually declared as contract to hold the public getters 
 */


contract ISynthetix {

    // ========== PUBLIC STATE VARIABLES ==========

    IFeePool public feePool;
    ISynthetixEscrow public escrow;
    ISynthetixEscrow public rewardEscrow;
    ISynthetixState public synthetixState;
    IExchangeRates public exchangeRates;

    // ========== PUBLIC FUNCTIONS ==========

    function balanceOf(address account) public view returns (uint);
    function transfer(address to, uint value) public returns (bool);
    function effectiveValue(bytes4 sourceCurrencyKey, uint sourceAmount, bytes4 destinationCurrencyKey) public view returns (uint);

    function synthInitiatedFeePayment(address from, bytes4 sourceCurrencyKey, uint sourceAmount) external returns (bool);
    function synthInitiatedExchange(
        address from,
        bytes4 sourceCurrencyKey,
        uint sourceAmount,
        bytes4 destinationCurrencyKey,
        address destinationAddress) external returns (bool);
    function exchange(
        bytes4 sourceCurrencyKey,
        uint sourceAmount,
        bytes4 destinationCurrencyKey,
        address destinationAddress) external returns (bool);
    function collateralisationRatio(address issuer) public view returns (uint);
    function totalIssuedSynths(bytes4 currencyKey)
        public
        view
        returns (uint);
    function getSynth(bytes4 currencyKey) public view returns (ISynth);
    function debtBalanceOf(address issuer, bytes4 currencyKey) public view returns (uint);
}


/*
-----------------------------------------------------------------
FILE INFORMATION
-----------------------------------------------------------------

file:       SynthetixAirdropper.sol
version:    1.0
author:     Jackson Chan
            Clinton Ennis
date:       2019-08-02

-----------------------------------------------------------------
MODULE DESCRIPTION
-----------------------------------------------------------------

This contract was adapted for use by the Synthetix project from the
airdropper contract that OmiseGO created here:
https://github.com/omisego/airdrop/blob/master/contracts/Airdropper.sol

It exists to save gas costs per transaction that'd otherwise be
incurred running airdrops individually.

Original license below.

-----------------------------------------------------------------

Copyright 2017 OmiseGO Pte Ltd

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/


contract SynthetixAirdropper is Owned {
    /* ========== CONSTRUCTOR ========== */

    /**
     * @dev Constructor
     * @param _owner The owner of this contract.
     */
    constructor (address _owner)
        Owned(_owner)
        public
    {}

    /**
     * @notice Multisend airdrops tokens to an array of destinations.
     */
    function multisend(address _tokenAddress, address[] _destinations, uint256[] _values)
        external
        onlyOwner
    {
        // Protect against obviously incorrect calls.
        require(_destinations.length == _values.length, "Dests and values mismatch");

        // Loop through each destination and perform the transfer.
        uint256 i = 0;
        while (i < _destinations.length) {
            ISynthetix(_tokenAddress).transfer(_destinations[i], _values[i]);
            i += 1;
        }
    }
}