/**

 *Submitted for verification at Etherscan.io on 2019-05-22

*/



pragma solidity ^0.5.8;





/// @title ERC20 Token Interface

/// @author Hoard Team

/// @notice See https://github.com/ethereum/EIPs/issues/20

contract ERC20Token {



    // PUBLIC INTERFACE



    // /// @dev Returns total amount of tokens

    // /// @notice params -> (uint256 totalSupply)

    // It's implamented as a variable which doesn't override this method. Commented to prevent compilation error.

    // function totalSupply    () constant public returns (uint256);



    /// @dev Returns balance of specified account

    /// @notice params -> (address _owner)

    function balanceOf      (address) view public returns (uint256);



    /// @dev  Transfers tokens from msg.sender to a specified address

    /// @notice params -> (address _to, uint256 _value)

    function transfer       (address, uint256) public returns (bool);



    /// @dev  Allowance mechanism - delegated transfer

    /// @notice params -> (address _from, address _to, uint256 _value)

    function transferFrom   (address, address, uint256) public returns (bool);



    /// @dev  Allowance mechanism - approve delegated transfer

    /// @notice params -> (address _spender, uint256 _value)

    function approve        (address, uint256) public returns (bool);



    /// @dev  Allowance mechanism - set allowance for specified address

    /// @notice params -> (address _owner, address _spender)

    function allowance      (address, address) public view returns (uint256);





    // EVENTS



    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);



}





/// @title Safe Math

/// @author Open Zeppelin

/// @notice implementation from - https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/math/SafeMath.sol

library SafeMath {

  function safeMul(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a * b;

    assert(a == 0 || c / a == b);

    return c;

  }



  function safeDiv(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;

  }



  function safeSub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  function safeAdd(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    assert(c >= a);

    return c;

  }

  

  function max256(uint256 a, uint256 b) internal pure returns (uint256) {

    return a >= b ? a : b;

  }



  function min256(uint256 a, uint256 b) internal pure returns (uint256) {

    return a < b ? a : b;

  }



}







/// @title Standard ERC20 compliant token

/// @author Hoard Team

/// @notice Original taken from https://github.com/ethereum/EIPs/issues/20

/// @notice SafeMath used as specified by OpenZeppelin

/// @notice Comments and additional approval code from https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/token

contract StandardToken is ERC20Token {



    using SafeMath for uint256;



    mapping (address => uint256) balances;



    mapping (address => mapping (address => uint256)) allowed;



    uint256 public totalSupply;



   /// @dev transfer token for a specified address

   /// @param _to The address to transfer to.

   /// @param _value The amount to be transferred.

   function transfer(address _to, uint256 _value) public returns (bool) {

        balances[msg.sender] = balances[msg.sender].safeSub(_value);

        balances[_to] = balances[_to].safeAdd(_value);



        emit Transfer(msg.sender, _to, _value);            



        return true;

    }



    /// @dev Transfer tokens from one address to another

    /// @param _from address The address which you want to send tokens from

    /// @param _to address The address which you want to transfer to

    /// @param _value uint256 the amount of tokens to be transferred

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {

        uint256 _allowance = allowed[_from][msg.sender];



        // Check is not needed because sub(_allowance, _value) will already throw if this condition is not met

        // require (_value <= _allowance);        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {



        balances[_to] = balances[_to].safeAdd(_value);

        balances[_from] = balances[_from].safeSub(_value);

        allowed[_from][msg.sender] = _allowance.safeSub(_value);



        emit Transfer(_from, _to, _value);

            

        return true;

    }



    /// @dev Gets the balance of the specified address.

    /// @param _owner The address to query the the balance of. 

    /// @return An uint256 representing the amount owned by the passed address.

    function balanceOf(address _owner) view public returns (uint256) {

        return balances[_owner];

    }



   /// @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.

   /// @param _spender The address which will spend the funds.

   /// @param _value The amount of tokens to be spent.

   function approve(address _spender, uint256 _value) public returns (bool) {

        // To change the approve amount you first have to reduce the addresses`

        //  allowance to zero by calling `approve(_spender, 0)` if it is not

        //  already 0 to mitigate the race condition described here:

        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729

        require((_value == 0) || (allowed[msg.sender][_spender] == 0));

        

        allowed[msg.sender][_spender] = _value;



        emit Approval(msg.sender, _spender, _value);



        return true;

    }



   /// @dev Function to check the amount of tokens that an owner allowed to a spender.

   /// @param _owner address The address which owns the funds.

   /// @param _spender address The address which will spend the funds.

   /// @return A uint256 specifying the amount of tokens still available for the spender.

   function allowance(address _owner, address _spender) view public returns (uint256) {

        return allowed[_owner][_spender];

    }



    /// @notice approve should be called when allowed[_spender] == 0. To increment

    /// allowed value it is better to use this function to avoid 2 calls (and wait until 

    /// the first transaction is mined)

    function increaseApproval (address _spender, uint256 _addedValue) public returns (bool) {

        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].safeAdd(_addedValue);



        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);



        return true;

    }



    /// @notice approve should be called when allowed[_spender] == 0. To decrement

    /// allowed value it is better to use this function to avoid 2 calls (and wait until 

    /// the first transaction is mined)

    function decreaseApproval (address _spender, uint256 _subtractedValue) public returns (bool) {

        uint256 oldValue = allowed[msg.sender][_spender];

        

        if (_subtractedValue > oldValue) {

            allowed[msg.sender][_spender] = 0;

        } else {

            allowed[msg.sender][_spender] = oldValue - _subtractedValue;

        }



        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);



        return true;

    }



}





/// @title Migration Agent interface

/// @author Hoard Team

/// @notice Based on GNT implementation - https://github.com/golemfactory/golem-crowdfunding/blob/master/contracts/Token.sol

contract MigrationAgent {



    /// @dev migrates tokens or other "assets" from one contract to another (not yet specified)

    /// @notice parameters -> (address _from, uint _value)

    function migrateFrom(address, uint256) public;

}





/// @title Mintable token interface

/// @author Hoard Team

contract Mintable {



    /// @dev Mint new tokens  

    /// @notice params -> (address _recipient, uint256 _amount)

    function mintTokens         (address, uint256) public;

}





/// @title Migratable entity interface

/// @author Hoard Team

contract Migratable {



    /// @dev Migrates tokens for msg.sender  

    /// @notice params -> (uint256 _value)

    function migrate            (uint256) public;





    // EVENTS



    event Migrate               (address indexed _from, address indexed _to, uint256 _value);

}





/// @title Standard ERC20 compliant token

/// @author Hoard Team

contract ExtendedStandardToken is StandardToken, Migratable, Mintable {



    address public migrationAgent;

    uint256 public totalMigrated;





    // MODIFIERS



    modifier migrationAgentSet {

        require(migrationAgent != address(0));

        _;

    }



    modifier migrationAgentNotSet {

        require(migrationAgent == address(0));

        _;

    }



    /// @dev Internal constructor to prevent bare instances of this contract

    constructor () internal {

    }



    // MIGRATION LOGIC



    /// @dev Migrates tokens for msg.sender and burns them

    /// @param _value amount of tokens to migrate

    function migrate            (uint256 _value) public {



        // Validate input value

        require(_value > 0);

    

        //require(_value <= balances[msg.sender]);

        //not necessary as safeSub throws in case the above condition does not hold

    

        balances[msg.sender] = balances[msg.sender].safeSub(_value);

        totalSupply = totalSupply.safeSub(_value);

        totalMigrated = totalMigrated.safeAdd(_value);



        MigrationAgent(migrationAgent).migrateFrom(msg.sender, _value);



        emit Migrate(msg.sender, migrationAgent, _value);

    }





    // MINTING LOGIC



    /// @dev Mints additional tokens

    /// @param _recipient owner of new tokens 

    /// @param _amount amount of tokens to mint

    function mintTokens         (address _recipient, uint256 _amount) public {

        require(_amount > 0);



        balances[_recipient] = balances[_recipient].safeAdd(_amount);

        totalSupply = totalSupply.safeAdd(_amount);



        // Log token creation event

        emit Transfer(address(0), msg.sender, _amount);

    }





    // CONTROL LOGIC



    /// @dev Sets address of a new migration agent

    /// @param _address address of new migration agent 

    function setMigrationAgent  (address _address) public {

        migrationAgent = _address; 

    }



}







/// @title Hoard Token (HRD) - crowdfunding code for Hoard token

/// @author Hoard Team

/// @notice Based on MLN implementation - https://github.com/melonproject/melon/blob/master/contracts/tokens/MelonToken.sol

/// @notice Based on GNT implementation - https://github.com/golemfactory/golem-crowdfunding/blob/master/contracts/Token.sol

contract HoardToken is ExtendedStandardToken {



    // Token description fields

    string public constant name = "Hoard Token";

    string public constant symbol = "HRD";

    uint256 public constant decimals = 18;  // 18 decimal places, the same as ETH



    // contract supervision variables

    address public creator;

    address public hoard;

    address public migrationMaster;





    // MODIFIERS



    modifier onlyCreator {

        require(msg.sender == creator);

        _;

    }



    modifier onlyHoard {

        require(msg.sender == hoard);

        _;

    }



    modifier onlyMigrationMaster {

        require(msg.sender == migrationMaster);

        _;

    }



    // CONSTRUCTION



    /// @param _hoard Hoard multisig contract

    /// @param _migrationMaster migration master

    constructor (address _hoard, address _migrationMaster) public {

        require(_hoard != address(0));

        require(_migrationMaster != address(0));



        creator = msg.sender;

        hoard = _hoard;

        migrationMaster = _migrationMaster;

    }





    // BASE CLASS IMPLEMENTATION



    /// @notice ExtendedStandardToken is StandardToken

    function transfer               (address _to, uint256 _value) public

        returns (bool) 

    {

        return super.transfer(_to, _value);

    }





    /// @notice ExtendedStandardToken is StandardToken

    function transferFrom           (address _from, address _to, uint256 _value) public 

        returns (bool)

    {

        return super.transferFrom(_from, _to, _value);

    }





    /// @notice ExtendedStandardToken is Migratable

    function migrate                (uint256 _value) public migrationAgentSet {

        super.migrate(_value);    

    }



    /// @notice ExtendedStandardToken

    function setMigrationAgent      (address _address) public onlyMigrationMaster migrationAgentNotSet {

        require(_address != address(0));



        super.setMigrationAgent(_address);

    }



    /// @notice ExtendedStandardToken is Mintable

    function mintTokens             (address _recipient, uint256 _amount) public onlyCreator {

        super.mintTokens(_recipient, _amount);

    }



    // CONTROL LOGIC



    /// @dev changes Hoard multisig address to another one

    function changeHoardAddress     (address _address) onlyHoard external { hoard = _address; }



    /// @dev changes migration master address to another one

    function changeMigrationMaster  (address _address) onlyHoard external { migrationMaster = _address; }



}







/// @title HRD Allocation - time-locked vault of tokens allocated to developers and Hoard

/// @notice Based on GNT implementation - https://github.com/golemfactory/golem-crowdfunding/blob/master/contracts/GNTAllocation.sol

contract HRDAllocation {



    // Addresses of developer and the Hoard to allocations mapping.

    mapping (address => uint256) allocations;



    // Address of the token contract

    HoardToken hoardToken;



    // endowment accounts

    address public constant ADDR_01 = 0x7D4f9442659A85c64dBc0fcD73C163bbD7CcEf84;

    address public constant ADDR_02 = 0xa24697ff026a072acfBc2ad4baef3386deF89Fd9;

    address public constant ADDR_03 = 0x5472e965d2Fe689C5cF20d8E72C3f8d116E95d30;

    address public constant ADDR_04 = 0x90A62aa1f37f9B5A43E6768991dA1cd83526b89f;

    address public constant ADDR_05 = 0xd0a93607f75B8Cf378c6C06A15bd664541849768;

    address public constant ADDR_06 = 0xd0E1555b918f9b2E57b0fC8913C7181382ad9CB5;

    address public constant ADDR_07 = 0x20845469fF9DDc56F98A66419B88A5435739707a;

    address public constant ADDR_08 = 0x1AB9fc0928C80164B1bfE166527F82c759Ade114;

    address public constant ADDR_09 = 0x11c1c4f3c6c725455e48f862e59407e5db7bd7A8;

    address public constant ADDR_10 = 0x7165b273907F4Cc437224b5c50C50C70F8a355E0;

    address public constant ADDR_11 = 0x625186d75dea6f90B37C1f3fb70acBaDD251371D;

    address public constant ADDR_12 = 0xf2f6C59359958DB1C4dDD140c87C6a6e314f0267;

    address public constant ADDR_13 = 0x274A87EEe6321a0c62230B1087048EB40b2C628e;

    address public constant ADDR_14 = 0xB576274F6Be62Bb290F15a3B4D503a6c06f7cBbb;

    address public constant ADDR_15 = 0x3C4D5be2fd91BD2B2cF8E1D4D2C1B54E8d29C83D;

    address public constant ADDR_16 = 0x6803BcB68C0427d25B46a3ef7520F1460518C0Fb;

    address public constant ADDR_17 = 0x52F540BE7d494075dA30b1ED67BAf46FdE30B7d9;

    address public constant ADDR_18 = 0x0872dfA15E300496BadBB4c04c939F5E515DeedD;

    address public constant ADDR_19 = 0xC8EcfFEAc244099809BB1480689A7A36d21a6091;

    address public constant ADDR_20 = 0xE80b3ad9A170A608Eb07C460F231dA6c872dd5C4;

    address public constant ADDR_21 = 0x077656617C26074BD54Fa636142CAD91d633C8Ac;

    address public constant ADDR_22 = 0x572d0f9C8a2C783aDDfCaeAb68f2F60781edd5Df;

    address public constant ADDR_23 = 0xaD1FA44CfBA1a3ca7b4dE016F857aBB30131A513;

    address public constant ADDR_24 = 0x2A4331B02Ca0630b5f0C68ecB3E1732866864cc7;



    // endowment amounts

    uint256 public constant ALLOC_01  = 50000000 * 10 ** 18;

    uint256 public constant ALLOC_02  = 10000000 * 10 ** 18;

    uint256 public constant ALLOC_03  = 5000000 * 10 ** 18;

    uint256 public constant ALLOC_04  = 20000000 * 10 ** 18;

    uint256 public constant ALLOC_05  = 20000000 * 10 ** 18;

    uint256 public constant ALLOC_06  = 6000000 * 10 ** 18;

    uint256 public constant ALLOC_07  = 2000000 * 10 ** 18;

    uint256 public constant ALLOC_08  = 3000000 * 10 ** 18;

    uint256 public constant ALLOC_09  = 3000000 * 10 ** 18;

    uint256 public constant ALLOC_10  = 3000000 * 10 ** 18;

    uint256 public constant ALLOC_11  = 3000000 * 10 ** 18;

    uint256 public constant ALLOC_12  = 3000000 * 10 ** 18;

    uint256 public constant ALLOC_13  = 4000000 * 10 ** 18;

    uint256 public constant ALLOC_14  = 3000000 * 10 ** 18;

    uint256 public constant ALLOC_15  = 3000000 * 10 ** 18;

    uint256 public constant ALLOC_16  = 3000000 * 10 ** 18;

    uint256 public constant ALLOC_17  = 3000000 * 10 ** 18;

    uint256 public constant ALLOC_18  = 4000000 * 10 ** 18;

    uint256 public constant ALLOC_19  = 6000000 * 10 ** 18;

    uint256 public constant ALLOC_20  = 3000000 * 10 ** 18;

    uint256 public constant ALLOC_21  = 3000000 * 10 ** 18;

    uint256 public constant ALLOC_22  = 2000000 * 10 ** 18;

    uint256 public constant ALLOC_23  = 2000000 * 10 ** 18;

    uint256 public constant ALLOC_24  = 2000000 * 10 ** 18;



    // Vault configuration

    uint256 unlockedAt;

    uint256 tokensCreated = 0;





    // MODIFIERS



    modifier onlyIfUnlocked {

        require(now >= unlockedAt);

        _;

    }





    // CONSTRUCTION



    /// @param _hoard Hoard multisig address

    /// @param _hoardToken token address

    /// @param _lockIntervalDuration how long endowment tokens are going to be locked

    /// @notice Allow developer to unlock allocated tokens by transferring them

    /// from HRDAllocation to developer's address.

    constructor (address _hoard, address _hoardToken, uint256 _lockIntervalDuration, uint256 _totalHRD) public {

        // Make sure that basic input invariants are satisfied 

        require(_hoard != address(0));

        require(_hoardToken != address(0));

        require(_lockIntervalDuration > 0);



        // Sanity checks at the cost of slightly larger contract

        uint256 ALLOC_01_05 = ALLOC_01 + ALLOC_02 + ALLOC_03 + ALLOC_04 + ALLOC_05;

        uint256 ALLOC_06_10 = ALLOC_06 + ALLOC_07 + ALLOC_08 + ALLOC_09 + ALLOC_10;

        uint256 ALLOC_11_15 = ALLOC_11 + ALLOC_12 + ALLOC_13 + ALLOC_14 + ALLOC_15;

        uint256 ALLOC_16_20 = ALLOC_16 + ALLOC_17 + ALLOC_18 + ALLOC_19 + ALLOC_20;

        uint256 ALLOC_21_24 = ALLOC_21 + ALLOC_22 + ALLOC_23 + ALLOC_24;



        uint256 ALLOC_ALL = ALLOC_01_05 + ALLOC_06_10 + ALLOC_11_15 + ALLOC_16_20 + ALLOC_21_24;



        // Called here so that the contract is not constructed if invalid number of tokens is specified

        require(_totalHRD == ALLOC_ALL);



        hoardToken = HoardToken(_hoardToken);

        unlockedAt = 1556712000 + _lockIntervalDuration; // 05/01/2019 @ 12:00pm (UTC) + _lockIntervalDuration



        // For developers and advisors

        allocations[ADDR_01] = ALLOC_01;

        allocations[ADDR_02] = ALLOC_02;

        allocations[ADDR_03] = ALLOC_03;

        allocations[ADDR_04] = ALLOC_04;

        allocations[ADDR_05] = ALLOC_05;

        allocations[ADDR_06] = ALLOC_06;

        allocations[ADDR_07] = ALLOC_07;

        allocations[ADDR_08] = ALLOC_08;

        allocations[ADDR_09] = ALLOC_09;

        allocations[ADDR_10] = ALLOC_10;

        allocations[ADDR_11] = ALLOC_11;

        allocations[ADDR_12] = ALLOC_12;

        allocations[ADDR_13] = ALLOC_13;

        allocations[ADDR_14] = ALLOC_14;

        allocations[ADDR_15] = ALLOC_15;

        allocations[ADDR_16] = ALLOC_16;

        allocations[ADDR_17] = ALLOC_17;

        allocations[ADDR_18] = ALLOC_18;

        allocations[ADDR_19] = ALLOC_19;

        allocations[ADDR_20] = ALLOC_20;

        allocations[ADDR_21] = ALLOC_21;

        allocations[ADDR_22] = ALLOC_22;

        allocations[ADDR_23] = ALLOC_23;

        allocations[ADDR_24] = ALLOC_24;

    }



    /// @notice Allow developer to unlock allocated tokens by transferring them

    /// from HRDAllocation to developer's address.

    function unlock() external onlyIfUnlocked {



        // During first unlock attempt fetch total number of locked tokens.

        if (tokensCreated == 0) {

            tokensCreated = hoardToken.balanceOf(address(this));

        }



        uint256 hrdAllocation = allocations[msg.sender];

        

        require(hrdAllocation > 0);



        allocations[msg.sender] = 0;

        

        hoardToken.transfer(msg.sender, hrdAllocation);

    }

}







/// @title Hoard  Crowdfunding Logic 

/// @author Hoard Team

/// @notice Based roughly on MLN implementation - https://github.com/melonproject/melon/blob/master/contracts/tokens/MelonToken.sol

contract HoardDeployer {



    // configuration of time dependant logic

    uint256 public constant endowmentLockDuration = 12 * 30 days; // duration of HRD endowment lock period (1 year)



    // configuration of HRD generation logic

    uint256 public constant totalHRD           = 1000000000 * 10 ** 18;                    // Fixed amount of tokens to be generated (decimals == decimals in HoardToken)



    uint256 public constant totalDevHRD        = 166000000 * 10 ** 18;                     // Amount of tokens for the hoard company and the dev team

    uint256 public constant totalPublicHRD     = totalHRD - totalDevHRD;                   // Amount of tokens for the Hoard at the beginning



    // Hoard Token

    HoardToken      public hoardToken;

    HRDAllocation   public lockedAllocation;



    // CONSTRUCTION



    /// @param _hoard Hoard multisig contract

    /// @param _migrationMaster migration master

    /// @notice this is a two-phase process and after the contract is created, allocations have to be initialized

    /// via an additional call

    constructor (address _hoard, address _migrationMaster) public {

        require(_hoard != address(0));

        require(_migrationMaster != address(0));



        hoardToken = new HoardToken(_hoard, _migrationMaster);

        lockedAllocation = new HRDAllocation(_hoard, address(hoardToken), endowmentLockDuration, totalDevHRD);



        // Generate endowment HRD and store it in a time-locked contract

        hoardToken.mintTokens(address(lockedAllocation), totalDevHRD);



        // At the beginning all tokens except endowmnet go to hoard

        hoardToken.mintTokens(_hoard, totalPublicHRD);

    }

}