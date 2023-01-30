pragma solidity ^0.4.2;

/*
 *
 * This file is part of Pass DAO.
 *
 * The Token Manager smart contract is used for the management of tokens
 * by a client smart contract (the Dao). Defines the functions to set new funding rules,
 * create or reward tokens, check token balances, send tokens and send
 * tokens on behalf of a 3rd party and the corresponding approval process.
 *
*/

/// @title Token Manager smart contract of the Pass Decentralized Autonomous Organisation
contract PassTokenManagerInterface {
    
    struct fundingData {
        // True if public funding without a main partner
        bool publicCreation; 
        // The address which sets partners and manages the funding in case of private funding
        address mainPartner;
        // The maximum amount (in wei) of the funding
        uint maxAmountToFund;
        // The actual funded amount (in wei)
        uint fundedAmount;
        // A unix timestamp, denoting the start time of the funding
        uint startTime; 
        // A unix timestamp, denoting the closing time of the funding
        uint closingTime;  
        // The price multiplier for a share or a token without considering the inflation rate
        uint initialPriceMultiplier;
        // Rate per year in percentage applied to the share or token price 
        uint inflationRate; 
        // Index of the client proposal
        uint proposalID;
    } 

    // Address of the creator of the smart contract
    address public creator;
    // Address of the Dao    
    address public client;
    // Address of the recipient;
    address public recipient;
    
    // The token name for display purpose
    string public name;
    // The token symbol for display purpose
    string public symbol;
    // The quantity of decimals for display purpose
    uint8 public decimals;

    // Total amount of tokens
    uint256 totalSupply;

    // Array with all balances
    mapping (address => uint256) balances;
    // Array with all allowances
    mapping (address => mapping (address => uint256)) allowed;

    // Map of the result (in wei) of fundings
    mapping (uint => uint) fundedAmount;
    
    // If true, the shares or tokens can be transfered
    bool public transferable;
    // Map of blocked Dao share accounts. Points to the date when the share holder can transfer shares
    mapping (address => uint) public blockedDeadLine; 

    // Rules for the actual funding and the contractor token price
    fundingData[2] public FundingRules;
    
    /// @return The total supply of shares or tokens 
    function TotalSupply() constant external returns (uint256);

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
     function balanceOf(address _owner) constant external returns (uint256 balance);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Quantity of remaining tokens of _owner that _spender is allowed to spend
    function allowance(address _owner, address _spender) constant external returns (uint256 remaining);

    /// @param _proposalID The index of the Dao proposal
    /// @return The result (in wei) of the funding
    function FundedAmount(uint _proposalID) constant external returns (uint);

    /// @param _saleDate in case of presale, the date of the presale
    /// @return the share or token price divisor condidering the sale date and the inflation rate
    function priceDivisor(uint _saleDate) constant internal returns (uint);
    
    /// @return the actual price divisor of a share or token
    function actualPriceDivisor() constant external returns (uint);

    /// @return The maximal amount a main partner can fund at this moment
    /// @param _mainPartner The address of the main parner
    function fundingMaxAmount(address _mainPartner) constant external returns (uint);

    // Modifier that allows only the client to manage this account manager
    modifier onlyClient {if (msg.sender != client) throw; _;}

    // Modifier that allows only the main partner to manage the actual funding
    modifier onlyMainPartner {if (msg.sender !=  FundingRules[0].mainPartner) throw; _;}
    
    // Modifier that allows only the contractor propose set the token price or withdraw
    modifier onlyContractor {if (recipient == 0 || (msg.sender != recipient && msg.sender != creator)) throw; _;}
    
    // Modifier for Dao functions
    modifier onlyDao {if (recipient != 0) throw; _;}
    
    /// @dev The constructor function
    /// @param _creator The address of the creator of the smart contract
    /// @param _client The address of the client or Dao
    /// @param _recipient The recipient of this manager
    //function TokenManager(
        //address _creator,
        //address _client,
        //address _recipient
    //);

    /// @param _tokenName The token name for display purpose
    /// @param _tokenSymbol The token symbol for display purpose
    /// @param _tokenDecimals The quantity of decimals for display purpose
    /// @param _initialSupplyRecipient The recipient of the initial supply (not mandatory)
    /// @param _initialSupply The initial supply of tokens for the recipient (not mandatory)
    /// @param _transferable True if allows the transfer of tokens
    function initToken(
        string _tokenName,
        string _tokenSymbol,
        uint8 _tokenDecimals,
        address _initialSupplyRecipient,
        uint256 _initialSupply,
        bool _transferable
       );

    /// @param _initialPriceMultiplier The initial price multiplier of contractor tokens
    /// @param _inflationRate If 0, the contractor token price doesn&#39;t change during the funding
    /// @param _closingTime The initial price and inflation rate can be changed after this date
    function setTokenPriceProposal(        
        uint _initialPriceMultiplier, 
        uint _inflationRate,
        uint _closingTime
    );

    /// @notice Function to set a funding. Can be private or public
    /// @param _mainPartner The address of the smart contract to manage a private funding
    /// @param _publicCreation True if public funding
    /// @param _initialPriceMultiplier Price multiplier without considering any inflation rate
    /// @param _maxAmountToFund The maximum amount (in wei) of the funding
    /// @param _minutesFundingPeriod Period in minutes of the funding
    /// @param _inflationRate If 0, the token price doesn&#39;t change during the funding
    /// @param _proposalID Index of the client proposal (not mandatory)
    function setFundingRules(
        address _mainPartner,
        bool _publicCreation, 
        uint _initialPriceMultiplier, 
        uint _maxAmountToFund, 
        uint _minutesFundingPeriod, 
        uint _inflationRate,
        uint _proposalID
    ) external;
    
    /// @dev Internal function for the creation of shares or tokens
    /// @param _recipient The recipient address of shares or tokens
    /// @param _amount The funded amount (in wei)
    /// @param _saleDate In case of presale, the date of the presale
    /// @return Whether the creation was successful or not
    function createToken(
        address _recipient, 
        uint _amount,
        uint _saleDate
    ) internal returns (bool success);

    /// @notice Function used by the main partner to set the start time of the funding
    /// @param _startTime The unix start date of the funding 
    function setFundingStartTime(uint _startTime) external;

    /// @notice Function used by the main partner to reward shares or tokens
    /// @param _recipient The address of the recipient of shares or tokens
    /// @param _amount The amount (in Wei) to calculate the quantity of shares or tokens to create
    /// @param _date The unix date to consider for the share or token price calculation
    /// @return Whether the transfer was successful or not
    function rewardToken(
        address _recipient, 
        uint _amount,
        uint _date
        ) external;

    /// @dev Internal function to close the actual funding
    function closeFunding() internal;
    
    /// @notice Function used by the main partner to set the funding fueled
    function setFundingFueled() external;

    /// @notice Function to able the transfer of Dao shares or contractor tokens
    function ableTransfer();

    /// @notice Function to disable the transfer of Dao shares
    function disableTransfer();

    /// @notice Function used by the client to block the transfer of shares from and to a share holder
    /// @param _shareHolder The address of the share holder
    /// @param _deadLine When the account will be unblocked
    function blockTransfer(address _shareHolder, uint _deadLine) external;

    /// @dev Internal function to send `_value` token to `_to` from `_From`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The quantity of shares or tokens to be transferred
    /// @return Whether the function was successful or not 
    function transferFromTo(
        address _from,
        address _to, 
        uint256 _value
        ) internal returns (bool);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The quantity of shares or tokens to be transferred
    function transfer(address _to, uint256 _value);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The quantity of shares or tokens to be transferred
    function transferFrom(
        address _from, 
        address _to, 
        uint256 _value
        ) returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on its behalf
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success);

    event TokensCreated(address indexed Sender, address indexed TokenHolder, uint Quantity);
    event FundingRulesSet(address indexed MainPartner, uint indexed FundingProposalId, uint indexed StartTime, uint ClosingTime);
    event FundingFueled(uint indexed FundingProposalID, uint FundedAmount);
    event TransferAble();
    event TransferDisable();

}    

contract PassTokenManager is PassTokenManagerInterface {
    
    function TotalSupply() constant external returns (uint256) {
        return totalSupply;
    }

     function balanceOf(address _owner) constant external returns (uint256 balance) {
        return balances[_owner];
     }

    function allowance(address _owner, address _spender) constant external returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    function FundedAmount(uint _proposalID) constant external returns (uint) {
        return fundedAmount[_proposalID];
    }

    function priceDivisor(uint _saleDate) constant internal returns (uint) {
        uint _date = _saleDate;
        
        if (_saleDate > FundingRules[0].closingTime) _date = FundingRules[0].closingTime;
        if (_saleDate < FundingRules[0].startTime) _date = FundingRules[0].startTime;

        return 100 + 100*FundingRules[0].inflationRate*(_date - FundingRules[0].startTime)/(100*365 days);
    }
    
    function actualPriceDivisor() constant external returns (uint) {
        return priceDivisor(now);
    }

    function fundingMaxAmount(address _mainPartner) constant external returns (uint) {
        
        if (now > FundingRules[0].closingTime
            || now < FundingRules[0].startTime
            || _mainPartner != FundingRules[0].mainPartner) {
            return 0;   
        } else {
            return FundingRules[0].maxAmountToFund;
        }
        
    }

    function PassTokenManager(
        address _creator,
        address _client,
        address _recipient
    ) {
        
        if (_creator == 0 
            || _client == 0 
            || _client == _recipient 
            || _client == address(this) 
            || _recipient == address(this)) throw;

        creator = _creator; 
        client = _client;
        recipient = _recipient;
        
    }
   
    function initToken(
        string _tokenName,
        string _tokenSymbol,
        uint8 _tokenDecimals,
        address _initialSupplyRecipient,
        uint256 _initialSupply,
        bool _transferable) {
           
        if (_initialSupplyRecipient == address(this)
            || decimals != 0
            || msg.sender != creator
            || totalSupply != 0) throw;
            
        name = _tokenName;
        symbol = _tokenSymbol;
        decimals = _tokenDecimals;
          
        if (_transferable) {
            transferable = true;
            TransferAble();
        } else {
            transferable = false;
            TransferDisable();
        }
        
        balances[_initialSupplyRecipient] = _initialSupply; 
        totalSupply = _initialSupply;
        TokensCreated(msg.sender, _initialSupplyRecipient, _initialSupply);
           
    }
    
    function setTokenPriceProposal(        
        uint _initialPriceMultiplier, 
        uint _inflationRate,
        uint _closingTime
    ) onlyContractor {
        
        if (_closingTime < now 
            || now < FundingRules[1].closingTime) throw;
        
        FundingRules[1].initialPriceMultiplier = _initialPriceMultiplier;
        FundingRules[1].inflationRate = _inflationRate;
        FundingRules[1].startTime = now;
        FundingRules[1].closingTime = _closingTime;
        
    }
    
    function setFundingRules(
        address _mainPartner,
        bool _publicCreation, 
        uint _initialPriceMultiplier,
        uint _maxAmountToFund, 
        uint _minutesFundingPeriod, 
        uint _inflationRate,
        uint _proposalID
    ) external onlyClient {

        if (now < FundingRules[0].closingTime
            || _mainPartner == address(this)
            || _mainPartner == client
            || (!_publicCreation && _mainPartner == 0)
            || (_publicCreation && _mainPartner != 0)
            || (recipient == 0 && _initialPriceMultiplier == 0)
            || (recipient != 0 
                && (FundingRules[1].initialPriceMultiplier == 0
                    || _inflationRate < FundingRules[1].inflationRate
                    || now < FundingRules[1].startTime
                    || FundingRules[1].closingTime < now + (_minutesFundingPeriod * 1 minutes)))
            || _maxAmountToFund == 0
            || _minutesFundingPeriod == 0
            ) throw;

        FundingRules[0].startTime = now;
        FundingRules[0].closingTime = now + _minutesFundingPeriod * 1 minutes;
            
        FundingRules[0].mainPartner = _mainPartner;
        FundingRules[0].publicCreation = _publicCreation;
        
        if (recipient == 0) FundingRules[0].initialPriceMultiplier = _initialPriceMultiplier;
        else FundingRules[0].initialPriceMultiplier = FundingRules[1].initialPriceMultiplier;
        
        if (recipient == 0) FundingRules[0].inflationRate = _inflationRate;
        else FundingRules[0].inflationRate = FundingRules[1].inflationRate;
        
        FundingRules[0].fundedAmount = 0;
        FundingRules[0].maxAmountToFund = _maxAmountToFund;

        FundingRules[0].proposalID = _proposalID;

        FundingRulesSet(_mainPartner, _proposalID, FundingRules[0].startTime, FundingRules[0].closingTime);
            
    } 
    
    function createToken(
        address _recipient, 
        uint _amount,
        uint _saleDate
    ) internal returns (bool success) {

        if (now > FundingRules[0].closingTime
            || now < FundingRules[0].startTime
            ||_saleDate > FundingRules[0].closingTime
            || _saleDate < FundingRules[0].startTime
            || FundingRules[0].fundedAmount + _amount > FundingRules[0].maxAmountToFund) return;

        uint _a = _amount*FundingRules[0].initialPriceMultiplier;
        uint _multiplier = 100*_a;
        uint _quantity = _multiplier/priceDivisor(_saleDate);
        if (_a/_amount != FundingRules[0].initialPriceMultiplier
            || _multiplier/100 != _a
            || totalSupply + _quantity <= totalSupply 
            || totalSupply + _quantity <= _quantity) return;

        balances[_recipient] += _quantity;
        totalSupply += _quantity;
        FundingRules[0].fundedAmount += _amount;

        TokensCreated(msg.sender, _recipient, _quantity);
        
        if (FundingRules[0].fundedAmount == FundingRules[0].maxAmountToFund) closeFunding();
        
        return true;

    }

    function setFundingStartTime(uint _startTime) external onlyMainPartner {
        if (now > FundingRules[0].closingTime) throw;
        FundingRules[0].startTime = _startTime;
    }
    
    function rewardToken(
        address _recipient, 
        uint _amount,
        uint _date
        ) external onlyMainPartner {

        uint _saleDate;
        if (_date == 0) _saleDate = now; else _saleDate = _date;

        if (!createToken(_recipient, _amount, _saleDate)) throw;

    }

    function closeFunding() internal {
        if (recipient == 0) fundedAmount[FundingRules[0].proposalID] = FundingRules[0].fundedAmount;
        FundingRules[0].closingTime = now;
    }
    
    function setFundingFueled() external onlyMainPartner {
        if (now > FundingRules[0].closingTime) throw;
        closeFunding();
        if (recipient == 0) FundingFueled(FundingRules[0].proposalID, FundingRules[0].fundedAmount);
    }
    
    function ableTransfer() onlyClient {
        if (!transferable) {
            transferable = true;
            TransferAble();
        }
    }

    function disableTransfer() onlyClient {
        if (transferable) {
            transferable = false;
            TransferDisable();
        }
    }
    
    function blockTransfer(address _shareHolder, uint _deadLine) external onlyClient onlyDao {
        if (_deadLine > blockedDeadLine[_shareHolder]) {
            blockedDeadLine[_shareHolder] = _deadLine;
        }
    }
    
    function transferFromTo(
        address _from,
        address _to, 
        uint256 _value
        ) internal returns (bool) {  

        if (transferable
            && now > blockedDeadLine[_from]
            && now > blockedDeadLine[_to]
            && _to != address(this)
            && balances[_from] >= _value
            && balances[_to] + _value > balances[_to]
            && balances[_to] + _value >= _value
        ) {
            balances[_from] -= _value;
            balances[_to] += _value;
            return true;
        } else {
            return false;
        }
        
    }

    function transfer(address _to, uint256 _value) {  
        if (!transferFromTo(msg.sender, _to, _value)) throw;
    }

    function transferFrom(
        address _from, 
        address _to, 
        uint256 _value
        ) returns (bool success) { 
        
        if (allowed[_from][msg.sender] < _value
            || !transferFromTo(_from, _to, _value)) throw;
            
        allowed[_from][msg.sender] -= _value;

    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        return true;
    }

}    
  

pragma solidity ^0.4.2;

/*
 *
 * This file is part of Pass DAO.
 *
 * The Manager smart contract is used for the management of accounts and tokens.
 * Allows to receive or withdraw ethers and to buy Dao shares.
 * The contract derives to the Token Manager smart contract for the management of tokens.
 *
 * Recipient is 0 for the Dao account manager and the address of
 * contractor&#39;s recipient for the contractors&#39;s mahagers.
 *
*/

/// @title Manager smart contract of the Pass Decentralized Autonomous Organisation
contract PassManagerInterface is PassTokenManagerInterface {

    struct proposal {
        // Amount (in wei) of the proposal
        uint amount;
        // A description of the proposal
        string description;
        // The hash of the proposal&#39;s document
        bytes32 hashOfTheDocument;
        // A unix timestamp, denoting the date when the proposal was created
        uint dateOfProposal;
        // The sum amount (in wei) ordered for this proposal 
        uint orderAmount;
        // A unix timestamp, denoting the date of the last order for the approved proposal
        uint dateOfOrder;
    }
        
    // Proposals to work for the client
    proposal[] public proposals;
    
    /// @dev The constructor function
    /// @param _creator The address of the creator
    /// @param _client The address of the Dao
    /// @param _recipient The address of the recipient. 0 for the Dao
    //function PassManager(
        //address _creator,
        //address _client,
        //address _recipient
    //) PassTokenManager(
        //_creator,
        //_client,
        //_recipient);

    /// @notice Fallback function to allow sending ethers to this smart contract
    function () payable;
    
    /// @notice Function to update the recipent address
    /// @param _newRecipient The adress of the recipient
    function updateRecipient(address _newRecipient);

    /// @notice Function to buy Dao shares according to the funding rules 
    /// with `msg.sender` as the beneficiary
    function buyShares() payable;
    
    /// @notice Function to buy Dao shares according to the funding rules 
    /// @param _recipient The beneficiary of the created shares
    function buySharesFor(address _recipient) payable;

    /// @notice Function to make a proposal to work for the client
    /// @param _amount The amount (in wei) of the proposal
    /// @param _description String describing the proposal
    /// @param _hashOfTheDocument The hash of the proposal document
    /// @return The index of the contractor proposal
    function newProposal(
        uint _amount,
        string _description, 
        bytes32 _hashOfTheDocument
    ) returns (uint);
    
    /// @notice Function used by the client to order according to the contractor proposal
    /// @param _proposalID The index of the contractor proposal
    /// @param _amount The amount (in wei) of the order
    /// @return Whether the order was made or not
    function order(
        uint _proposalID,
        uint _amount
    ) external returns (bool) ;
    
    /// @notice Function used by the client to send ethers from the Dao manager
    /// @param _recipient The address to send to
    /// @param _amount The amount (in wei) to send
    /// @return Whether the transfer was successful or not
    function sendTo(
        address _recipient, 
        uint _amount
    ) external returns (bool);

    /// @notice Function to allow contractors to withdraw ethers
    /// @param _amount The amount (in wei) to withdraw
    function withdraw(uint _amount);
    
    event ProposalAdded(uint indexed ProposalID, uint Amount, string Description);
    event Order(uint indexed ProposalID, uint Amount);
    event Withdawal(address indexed Recipient, uint Amount);

}    

contract PassManager is PassManagerInterface, PassTokenManager {

    function PassManager(
        address _creator,
        address _client,
        address _recipient
    ) PassTokenManager(
        _creator,
        _client,
        _recipient
        ) {
        proposals.length = 1;
    }

    function () payable {}

    function updateRecipient(address _newRecipient) onlyContractor {

        if (_newRecipient == 0 
            || _newRecipient == client) throw;

        recipient = _newRecipient;
    } 

    function buyShares() payable {
        buySharesFor(msg.sender);
    } 
    
    function buySharesFor(address _recipient) payable onlyDao {
        
        if (!FundingRules[0].publicCreation 
            || !createToken(_recipient, msg.value, now)) throw;

    }
   
    function newProposal(
        uint _amount,
        string _description, 
        bytes32 _hashOfTheDocument
    ) onlyContractor returns (uint) {

        uint _proposalID = proposals.length++;
        proposal c = proposals[_proposalID];

        c.amount = _amount;
        c.description = _description;
        c.hashOfTheDocument = _hashOfTheDocument; 
        c.dateOfProposal = now;
        
        ProposalAdded(_proposalID, c.amount, c.description);
        
        return _proposalID;
        
    }
    
    function order(
        uint _proposalID,
        uint _orderAmount
    ) external onlyClient returns (bool) {
    
        proposal c = proposals[_proposalID];
        
        uint _sum = c.orderAmount + _orderAmount;
        if (_sum > c.amount
            || _sum < c.orderAmount
            || _sum < _orderAmount) return; 

        c.orderAmount = _sum;
        c.dateOfOrder = now;
        
        Order(_proposalID, _orderAmount);
        
        return true;

    }

    function sendTo(
        address _recipient,
        uint _amount
    ) external onlyClient onlyDao returns (bool) {
    
        if (_recipient.send(_amount)) return true;
        else return false;

    }
   
    function withdraw(uint _amount) onlyContractor {
        if (!recipient.send(_amount)) throw;
        Withdawal(recipient, _amount);
    }
    
}    

contract PassManagerCreator {
    event NewPassManager(address Creator, address Client, address Recipient, address PassManager);
    function createManager(
        address _client,
        address _recipient
        ) returns (PassManager) {
        PassManager _passManager = new PassManager(
            msg.sender,
            _client,
            _recipient
        );
        NewPassManager(msg.sender, _client, _recipient, _passManager);
        return _passManager;
    }
}

pragma solidity ^0.4.2;

/*
This file is part of Pass DAO.

Pass DAO is free software: you can redistribute it and/or modify
it under the terms of the GNU lesser General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

Pass DAO is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU lesser General Public License for more details.

You should have received a copy of the GNU lesser General Public License
along with Pass DAO.  If not, see <http://www.gnu.org/licenses/>.
*/

/*
Smart contract for a Decentralized Autonomous Organization (DAO)
to automate organizational governance and decision-making.
*/

/// @title Pass Decentralized Autonomous Organisation
contract PassDaoInterface {

    struct BoardMeeting {        
        // Address of the creator of the board meeting for a proposal
        address creator;  
        // Index to identify the proposal to pay a contractor or fund the Dao
        uint proposalID;
        // Index to identify the proposal to update the Dao rules 
        uint daoRulesProposalID; 
        // unix timestamp, denoting the end of the set period of a proposal before the board meeting 
        uint setDeadline;
        // Fees (in wei) paid by the creator of the board meeting
        uint fees;
        // Total of fees (in wei) rewarded to the voters or to the Dao account manager for the balance
        uint totalRewardedAmount;
        // A unix timestamp, denoting the end of the voting period
        uint votingDeadline;
        // True if the proposal&#39;s votes have yet to be counted, otherwise False
        bool open; 
        // A unix timestamp, denoting the date of the execution of the approved proposal
        uint dateOfExecution;
        // Number of shares in favor of the proposal
        uint yea; 
        // Number of shares opposed to the proposal
        uint nay; 
        // mapping to indicate if a shareholder has voted
        mapping (address => bool) hasVoted;  
    }

    struct Proposal {
        // Index to identify the board meeting of the proposal
        uint boardMeetingID;
        // The contractor manager smart contract
        PassManager contractorManager;
        // The index of the contractor proposal
        uint contractorProposalID;
        // The amount (in wei) of the proposal
        uint amount; 
        // True if the proposal foresees a contractor token creation
        bool tokenCreation;
        // True if public funding without a main partner
        bool publicShareCreation; 
        // The address which sets partners and manages the funding in case of private funding
        address mainPartner;
        // The initial price multiplier of Dao shares at the beginning of the funding
        uint initialSharePriceMultiplier; 
        // The inflation rate to calculate the actual contractor share price
        uint inflationRate;
        // A unix timestamp, denoting the start time of the funding
        uint minutesFundingPeriod;
        // True if the proposal is closed
        bool open; 
    }

    struct Rules {
        // Index to identify the board meeting that decides to apply or not the Dao rules
        uint boardMeetingID;  
        // The quorum needed for each proposal is calculated by totalSupply / minQuorumDivisor
        uint minQuorumDivisor;  
        // Minimum fees (in wei) to create a proposal
        uint minBoardMeetingFees; 
        // Period in minutes to consider or set a proposal before the voting procedure
        uint minutesSetProposalPeriod; 
        // The minimum debate period in minutes that a generic proposal can have
        uint minMinutesDebatePeriod;
        // The inflation rate to calculate the reward of fees to voters during a board meeting 
        uint feesRewardInflationRate;
        // True if the dao rules allow the transfer of shares
        bool transferable;
    } 

    // The creator of the Dao
    address creator;
    // The minimum periods in minutes 
    uint public minMinutesPeriods;
    // The maximum period in minutes for proposals (set+debate)
    uint public maxMinutesProposalPeriod;
    // The maximum funding period in minutes for funding proposals
    uint public maxMinutesFundingPeriod;
    // The maximum inflation rate for share price or rewards to voters
    uint public maxInflationRate;

    // The Dao manager smart contract
    PassManager public daoManager;
    
    // Map to allow the share holders to withdraw board meeting fees
    mapping (address => uint) public pendingFeesWithdrawals;

    // Board meetings to vote for or against a proposal
    BoardMeeting[] public BoardMeetings; 
    // Proposals to pay a contractor or fund the Dao
    Proposal[] public Proposals;
    // Proposals to update the Dao rules
    Rules[] public DaoRulesProposals;
    // The current Dao rules
    Rules public DaoRules; 
    
    /// @dev The constructor function
    //function PassDao();

    /// @dev Function to initialize the Dao
    /// @param _daoManager Address of the Dao manager smart contract
    /// @param _maxInflationRate The maximum inflation rate for contractor and funding proposals
    /// @param _minMinutesPeriods The minimum periods in minutes
    /// @param _maxMinutesFundingPeriod The maximum funding period in minutes for funding proposals
    /// @param _maxMinutesProposalPeriod The maximum period in minutes for proposals (set+debate)
    /// @param _minQuorumDivisor The initial minimum quorum divisor for the proposals
    /// @param _minBoardMeetingFees The amount (in wei) to make a proposal and ask for a board meeting
    /// @param _minutesSetProposalPeriod The minimum period in minutes before a board meeting
    /// @param _minMinutesDebatePeriod The minimum period in minutes of the board meetings
    /// @param _feesRewardInflationRate The inflation rate to calculate the reward of fees to voters during a board meeting
    function initDao(
        address _daoManager,
        uint _maxInflationRate,
        uint _minMinutesPeriods,
        uint _maxMinutesFundingPeriod,
        uint _maxMinutesProposalPeriod,
        uint _minQuorumDivisor,
        uint _minBoardMeetingFees,
        uint _minutesSetProposalPeriod,
        uint _minMinutesDebatePeriod,
        uint _feesRewardInflationRate
        );
    
    /// @dev Internal function to create a board meeting
    /// @param _proposalID The index of the proposal if for a contractor or for a funding
    /// @param _daoRulesProposalID The index of the proposal if Dao rules
    /// @param _minutesDebatingPeriod The duration in minutes of the meeting
    /// @return the index of the board meeting
    function newBoardMeeting(
        uint _proposalID, 
        uint _daoRulesProposalID, 
        uint _minutesDebatingPeriod
    ) internal returns (uint);
    
    /// @notice Function to make a proposal to pay a contractor or fund the Dao
    /// @param _contractorManager Address of the contractor manager smart contract
    /// @param _contractorProposalID Index of the contractor proposal of the contractor manager
    /// @param _amount The amount (in wei) of the proposal
    /// @param _tokenCreation True if the proposal foresees a contractor token creation
    /// @param _publicShareCreation True if public funding without a main partner
    /// @param _mainPartner The address which sets partners and manage the funding 
    /// in case of private funding (not mandatory)
    /// @param _initialSharePriceMultiplier The initial price multiplier of shares
    /// @param _inflationRate If 0, the share price doesn&#39;t change during the funding (not mandatory)
    /// @param _minutesFundingPeriod Period in minutes of the funding
    /// @param _minutesDebatingPeriod Period in minutes of the board meeting to vote on the proposal
    /// @return The index of the proposal
    function newProposal(
        address _contractorManager,
        uint _contractorProposalID,
        uint _amount, 
        bool _publicShareCreation,
        bool _tokenCreation,
        address _mainPartner,
        uint _initialSharePriceMultiplier, 
        uint _inflationRate,
        uint _minutesFundingPeriod,
        uint _minutesDebatingPeriod
    ) payable returns (uint);

    /// @notice Function to make a proposal to change the Dao rules 
    /// @param _minQuorumDivisor If 5, the minimum quorum is 20%
    /// @param _minBoardMeetingFees The amount (in wei) to make a proposal and ask for a board meeting
    /// @param _minutesSetProposalPeriod Minimum period in minutes before a board meeting
    /// @param _minMinutesDebatePeriod The minimum period in minutes of the board meetings
    /// @param _feesRewardInflationRate The inflation rate to calculate the reward of fees to voters during a board meeting
    /// @param _transferable True if the proposal foresees to allow the transfer of Dao shares
    /// @param _minutesDebatingPeriod Period in minutes of the board meeting to vote on the proposal
    function newDaoRulesProposal(
        uint _minQuorumDivisor, 
        uint _minBoardMeetingFees,
        uint _minutesSetProposalPeriod,
        uint _minMinutesDebatePeriod,
        uint _feesRewardInflationRate,
        bool _transferable,
        uint _minutesDebatingPeriod
    ) payable returns (uint);
    
    /// @notice Function to vote during a board meeting
    /// @param _boardMeetingID The index of the board meeting
    /// @param _supportsProposal True if the proposal is supported
    function vote(
        uint _boardMeetingID, 
        bool _supportsProposal
    );

    /// @notice Function to execute a board meeting decision and close the board meeting
    /// @param _boardMeetingID The index of the board meeting
    /// @return Whether the proposal was executed or not
    function executeDecision(uint _boardMeetingID) returns (bool);
    
    /// @notice Function to order a contractor proposal
    /// @param _proposalID The index of the proposal
    /// @return Whether the proposal was ordered and the proposal amount sent or not
    function orderContractorProposal(uint _proposalID) returns (bool);   

    /// @notice Function to withdraw the rewarded board meeting fees
    /// @return Whether the withdraw was successful or not    
    function withdrawBoardMeetingFees() returns (bool);

    /// @return The minimum quorum for proposals to pass 
    function minQuorum() constant returns (uint);
    
    event ProposalAdded(uint indexed ProposalID, address indexed ContractorManager, uint ContractorProposalID, 
            uint amount, address indexed MainPartner, uint InitialSharePriceMultiplier, uint MinutesFundingPeriod);
    event DaoRulesProposalAdded(uint indexed DaoRulesProposalID, uint MinQuorumDivisor, uint MinBoardMeetingFees, 
            uint MinutesSetProposalPeriod, uint MinMinutesDebatePeriod, uint FeesRewardInflationRate, bool Transferable);
    event SentToContractor(uint indexed ContractorProposalID, address indexed ContractorManagerAddress, uint AmountSent);
    event BoardMeetingClosed(uint indexed BoardMeetingID, uint FeesGivenBack, bool ProposalExecuted);
    
}

contract PassDao is PassDaoInterface {

    function PassDao() {}
    
    function initDao(
        address _daoManager,
        uint _maxInflationRate,
        uint _minMinutesPeriods,
        uint _maxMinutesFundingPeriod,
        uint _maxMinutesProposalPeriod,
        uint _minQuorumDivisor,
        uint _minBoardMeetingFees,
        uint _minutesSetProposalPeriod,
        uint _minMinutesDebatePeriod,
        uint _feesRewardInflationRate
        ) {
            
        
        if (DaoRules.minQuorumDivisor != 0) throw;

        daoManager = PassManager(_daoManager);

        maxInflationRate = _maxInflationRate;
        minMinutesPeriods = _minMinutesPeriods;
        maxMinutesFundingPeriod = _maxMinutesFundingPeriod;
        maxMinutesProposalPeriod = _maxMinutesProposalPeriod;
        
        DaoRules.minQuorumDivisor = _minQuorumDivisor;
        DaoRules.minBoardMeetingFees = _minBoardMeetingFees;
        DaoRules.minutesSetProposalPeriod = _minutesSetProposalPeriod;
        DaoRules.minMinutesDebatePeriod = _minMinutesDebatePeriod;
        DaoRules.feesRewardInflationRate = _feesRewardInflationRate;

        BoardMeetings.length = 1; 
        Proposals.length = 1;
        DaoRulesProposals.length = 1;
        
    }
    
    function newBoardMeeting(
        uint _proposalID, 
        uint _daoRulesProposalID, 
        uint _minutesDebatingPeriod
    ) internal returns (uint) {

        if (msg.value < DaoRules.minBoardMeetingFees
            || DaoRules.minutesSetProposalPeriod + _minutesDebatingPeriod > maxMinutesProposalPeriod
            || now + ((DaoRules.minutesSetProposalPeriod + _minutesDebatingPeriod) * 1 minutes) < now
            || _minutesDebatingPeriod < DaoRules.minMinutesDebatePeriod
            || msg.sender == address(this)) throw;

        uint _boardMeetingID = BoardMeetings.length++;
        BoardMeeting b = BoardMeetings[_boardMeetingID];

        b.creator = msg.sender;

        b.proposalID = _proposalID;
        b.daoRulesProposalID = _daoRulesProposalID;

        b.fees = msg.value;
        
        b.setDeadline = now + (DaoRules.minutesSetProposalPeriod * 1 minutes);        
        b.votingDeadline = b.setDeadline + (_minutesDebatingPeriod * 1 minutes); 

        b.open = true; 

        return _boardMeetingID;

    }

    function newProposal(
        address _contractorManager,
        uint _contractorProposalID,
        uint _amount, 
        bool _tokenCreation,
        bool _publicShareCreation,
        address _mainPartner,
        uint _initialSharePriceMultiplier, 
        uint _inflationRate,
        uint _minutesFundingPeriod,
        uint _minutesDebatingPeriod
    ) payable returns (uint) {

        if ((_contractorManager != 0 && _contractorProposalID == 0)
            || (_contractorManager == 0 
                && (_initialSharePriceMultiplier == 0
                    || _contractorProposalID != 0)
            || (_tokenCreation && _publicShareCreation)
            || (_initialSharePriceMultiplier != 0
                && (_minutesFundingPeriod < minMinutesPeriods
                    || _inflationRate > maxInflationRate
                    || _minutesFundingPeriod > maxMinutesFundingPeriod)))) throw;

        uint _proposalID = Proposals.length++;
        Proposal p = Proposals[_proposalID];

        p.contractorManager = PassManager(_contractorManager);
        p.contractorProposalID = _contractorProposalID;
        
        p.amount = _amount;
        p.tokenCreation = _tokenCreation;

        p.publicShareCreation = _publicShareCreation;
        p.mainPartner = _mainPartner;
        p.initialSharePriceMultiplier = _initialSharePriceMultiplier;
        p.inflationRate = _inflationRate;
        p.minutesFundingPeriod = _minutesFundingPeriod;

        p.boardMeetingID = newBoardMeeting(_proposalID, 0, _minutesDebatingPeriod);   

        p.open = true;
        
        ProposalAdded(_proposalID, p.contractorManager, p.contractorProposalID, p.amount, p.mainPartner, 
            p.initialSharePriceMultiplier, _minutesFundingPeriod);

        return _proposalID;
        
    }

    function newDaoRulesProposal(
        uint _minQuorumDivisor, 
        uint _minBoardMeetingFees,
        uint _minutesSetProposalPeriod,
        uint _minMinutesDebatePeriod,
        uint _feesRewardInflationRate,
        bool _transferable,
        uint _minutesDebatingPeriod
    ) payable returns (uint) {
    
        if (_minQuorumDivisor <= 1
            || _minQuorumDivisor > 10
            || _minutesSetProposalPeriod < minMinutesPeriods
            || _minMinutesDebatePeriod < minMinutesPeriods
            || _minutesSetProposalPeriod + _minMinutesDebatePeriod > maxMinutesProposalPeriod
            || _feesRewardInflationRate > maxInflationRate
            ) throw; 
        
        uint _DaoRulesProposalID = DaoRulesProposals.length++;
        Rules r = DaoRulesProposals[_DaoRulesProposalID];

        r.minQuorumDivisor = _minQuorumDivisor;
        r.minBoardMeetingFees = _minBoardMeetingFees;
        r.minutesSetProposalPeriod = _minutesSetProposalPeriod;
        r.minMinutesDebatePeriod = _minMinutesDebatePeriod;
        r.feesRewardInflationRate = _feesRewardInflationRate;
        r.transferable = _transferable;
        
        r.boardMeetingID = newBoardMeeting(0, _DaoRulesProposalID, _minutesDebatingPeriod);     

        DaoRulesProposalAdded(_DaoRulesProposalID, _minQuorumDivisor, _minBoardMeetingFees, 
            _minutesSetProposalPeriod, _minMinutesDebatePeriod, _feesRewardInflationRate ,_transferable);

        return _DaoRulesProposalID;
        
    }
    
    function vote(
        uint _boardMeetingID, 
        bool _supportsProposal
    ) {
        
        BoardMeeting b = BoardMeetings[_boardMeetingID];

        if (b.hasVoted[msg.sender] 
            || now < b.setDeadline
            || now > b.votingDeadline) throw;

        uint _balance = uint(daoManager.balanceOf(msg.sender));
        if (_balance == 0) throw;
        
        b.hasVoted[msg.sender] = true;

        if (_supportsProposal) b.yea += _balance;
        else b.nay += _balance; 

        if (b.fees > 0 && b.proposalID != 0 && Proposals[b.proposalID].contractorProposalID != 0) {

            uint _a = 100*b.fees;
            if ((_a/100 != b.fees) || ((_a*_balance)/_a != _balance)) throw;
            uint _multiplier = (_a*_balance)/uint(daoManager.TotalSupply());

            uint _divisor = 100 + 100*DaoRules.feesRewardInflationRate*(now - b.setDeadline)/(100*365 days);

            uint _rewardedamount = _multiplier/_divisor;
            
            if (b.totalRewardedAmount + _rewardedamount > b.fees) _rewardedamount = b.fees - b.totalRewardedAmount;
            b.totalRewardedAmount += _rewardedamount;
            pendingFeesWithdrawals[msg.sender] += _rewardedamount;
        }

        daoManager.blockTransfer(msg.sender, b.votingDeadline);

    }

    function executeDecision(uint _boardMeetingID) returns (bool) {

        BoardMeeting b = BoardMeetings[_boardMeetingID];
        Proposal p = Proposals[b.proposalID];
        
        if (now < b.votingDeadline || !b.open) throw;
        
        b.open = false;
        if (p.contractorProposalID == 0) p.open = false;

        uint _fees;
        uint _minQuorum = minQuorum();

        if (b.fees > 0
            && (b.proposalID == 0 || p.contractorProposalID == 0)
            && b.yea + b.nay >= _minQuorum) {
                    _fees = b.fees;
                    b.fees = 0;
                    pendingFeesWithdrawals[b.creator] += _fees;
        }        

        if (b.fees - b.totalRewardedAmount > 0) {
            if (!daoManager.send(b.fees - b.totalRewardedAmount)) throw;
        }
        
        if (b.yea + b.nay < _minQuorum || b.yea <= b.nay) {
            p.open = false;
            BoardMeetingClosed(_boardMeetingID, _fees, false);
            return;
        }

        b.dateOfExecution = now;

        if (b.proposalID != 0) {
            
            if (p.initialSharePriceMultiplier != 0) {

                daoManager.setFundingRules(p.mainPartner, p.publicShareCreation, p.initialSharePriceMultiplier, 
                    p.amount, p.minutesFundingPeriod, p.inflationRate, b.proposalID);

                if (p.contractorProposalID != 0 && p.tokenCreation) {
                    p.contractorManager.setFundingRules(p.mainPartner, p.publicShareCreation, 0, 
                        p.amount, p.minutesFundingPeriod, maxInflationRate, b.proposalID);
                }

            }

        } else {

            Rules r = DaoRulesProposals[b.daoRulesProposalID];
            DaoRules.boardMeetingID = r.boardMeetingID;

            DaoRules.minQuorumDivisor = r.minQuorumDivisor;
            DaoRules.minMinutesDebatePeriod = r.minMinutesDebatePeriod; 
            DaoRules.minBoardMeetingFees = r.minBoardMeetingFees;
            DaoRules.minutesSetProposalPeriod = r.minutesSetProposalPeriod;
            DaoRules.feesRewardInflationRate = r.feesRewardInflationRate;

            DaoRules.transferable = r.transferable;
            if (r.transferable) daoManager.ableTransfer();
            else daoManager.disableTransfer();
        }
            
        BoardMeetingClosed(_boardMeetingID, _fees, true);

        return true;
        
    }
    
    function orderContractorProposal(uint _proposalID) returns (bool) {
        
        Proposal p = Proposals[_proposalID];
        BoardMeeting b = BoardMeetings[p.boardMeetingID];

        if (b.open || !p.open) throw;
        
        uint _amount = p.amount;

        if (p.initialSharePriceMultiplier != 0) {
            _amount = daoManager.FundedAmount(_proposalID);
            if (_amount == 0 && now < b.dateOfExecution + (p.minutesFundingPeriod * 1 minutes)) return;
        }
        
        p.open = false;   

        if (_amount == 0 || !p.contractorManager.order(p.contractorProposalID, _amount)) return;
        
        if (!daoManager.sendTo(p.contractorManager, _amount)) throw;
        SentToContractor(p.contractorProposalID, address(p.contractorManager), _amount);
        
        return true;

    }
    
    function withdrawBoardMeetingFees() returns (bool) {

        uint _amount = pendingFeesWithdrawals[msg.sender];

        pendingFeesWithdrawals[msg.sender] = 0;

        if (msg.sender.send(_amount)) {
            return true;
        } else {
            pendingFeesWithdrawals[msg.sender] = _amount;
            return false;
        }

    }

    function minQuorum() constant returns (uint) {
        return (uint(daoManager.TotalSupply()) / DaoRules.minQuorumDivisor);
    }
    
}