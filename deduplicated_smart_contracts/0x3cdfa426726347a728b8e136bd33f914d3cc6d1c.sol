/**
 *Submitted for verification at Etherscan.io on 2019-08-01
*/

pragma solidity ^0.4.25;
/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        assert(c >= a);
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
 * @title ERC20Basic
 */
contract ERC20Basic {
    uint256 public totalSupply;
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances. 
 */
contract BasicToken is ERC20Basic, Ownable {

    using SafeMath for uint256;

    mapping(address => uint256) balances;

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        // SafeMath.sub will throw if there is not enough balance.
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of. 
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return balances[_owner];
    }
    
}


/** Smart contract for controlling of where and when tokens are distributed duting crowdsale
 * Stores addresses of wallets which will receive tokens according to different parts of crowdsale for furthet distribution
 * Also it controls when certain number of tokens is unfrozen
 * */
contract PromTokenVault is Ownable{
    
    using SafeMath for uint256;

    // amount of seconds in 1 month
    // uint256 MONTH = 3;
    uint256 MONTH = 2592000;
    // address of token smart contract
    address token_;

    bytes4 publicKey = "0x1";
    bytes4 liquidityKey = "0x2";
    bytes4 teamKey = "0x3";
    bytes4 companyKey = "0x4";
    bytes4 privateKey = "0x5";
    bytes4 communityKey = "0x6";
    bytes4 ecosystemKey = "0x7";
    
    // these are addresses which will receive tokens according to respective parts of crowdsale    
    address liquidity_;
    address team_;
    address company_;
    address private_; 
    address community_;
    address ecosystem_;

    // stores data on the amount of tokens released according to different parts of crowdsale
    mapping (bytes4=>uint256) alreadyWithdrawn;

    // time when Token Generation Event occurs
    uint256 TGE_timestamp;
    ERC20 token;
    constructor(
                address _token, 
                address _private, 
                address _ecosystem,
                address _liquidity, 
                address _team, 
                address _company, 
                address _community
                ) public {
        token = ERC20(_token);
        private_ = _private;
        ecosystem_ = _ecosystem;
        liquidity_ = _liquidity;
        team_ = _team;
        company_ = _company; 
        community_ = _community;
        TGE_timestamp = block.timestamp;
    }
    
    /**
     * @dev Get the addresses to which tokens intended for respective part tokensale can be transferred;
    */
    function getLiqudityAddress() public view returns(address){
        return liquidity_;
    }
    
    function getTeamAddress() public view returns(address){
        return team_;
    }

    function getCompanyAddress() public view returns(address){
        return company_;
    }
    
    function getPrivateAddress() public view returns(address){
        return private_;
    }
    
    function getCommunityAddress() public view returns(address){
        return community_;
    }

    function getEcosystemAddress() public view returns(address){
        return ecosystem_;
    }

    /**
     * @dev Set the address to which tokens intended for part of tokensale can be transferred; Usable only by owner of smart contract;
    */
    function setLiqudityAddress(address _liquidity) public onlyOwner{
        liquidity_ = _liquidity;
    }

    function setTeamAddress(address _team) public onlyOwner{
        team_ = _team;
    }

    function setCompanyAddress(address _company) public onlyOwner{
        company_ = _company;
    }

    function setPrivateAddress(address _private) public onlyOwner{
        private_ = _private;
    }

    function setCommunityAddress(address _community) public onlyOwner{
        community_ = _community;
    }
    function setEcosystemAddress(address _ecosystem) public onlyOwner{
        ecosystem_ = _ecosystem;
    }


    /**
     * @dev Get how many tokens are still available for releaseal according to emmision rules of public part of tokensale
    */   
    function getLiquidityAvailable() public view returns(uint256){
        return getLiquidityReleasable().sub(alreadyWithdrawn[liquidityKey]);
    }    
    function getTeamAvailable() public view returns(uint256){
        return getTeamReleasable().sub(alreadyWithdrawn[teamKey]);
    }    
    function getCompanyAvailable() public view returns(uint256){
        return getCompanyReleasable().sub(alreadyWithdrawn[companyKey]);
    }    
    function getPrivateAvailable() public view returns(uint256){
        return getPrivateReleasable().sub(alreadyWithdrawn[privateKey]);
    }    
    function getCommunityAvailable() public view returns(uint256){
        return getCommunityReleasable().sub(alreadyWithdrawn[communityKey]);
    }    
    function getEcosystemAvailable() public view returns(uint256){
        return getEcosystemReleasable().sub(alreadyWithdrawn[ecosystemKey]);
    }    

    /**
     * @dev Get the total amount of tokens emitted which are intended for respective part of crowdsale 
    */

    function getPercentReleasable(uint256 _part, uint256 _full) internal pure returns(uint256){
        if(_part >= _full){
            _part = _full;
        }
        return _part;
    }
    
    function getMonthsPassed(uint256 _since) internal view returns(uint256){
        return (block.timestamp.sub(_since)).div(MONTH);
    }

    // LIQUIDITY TOKENSALE; 5.75% for liquidity sale; available after TGE
    function getLiquidityReleasable() public view returns(uint256){
        if(block.timestamp >= TGE_timestamp){
            return token.totalSupply().div(10000).mul(575) - (85000 + 3) * 10 ** uint256(18);
        }else{
            return 0;
        }
    }
    
    // TEAM & ADVISORS; 5% for team & advisors; 100% are locked for 12 month, then vesting 3% per month
    function getTeamReleasable() public view returns(uint256){
        uint256 unlockDate = TGE_timestamp.add(MONTH.mul(12));
        if(block.timestamp >= unlockDate){
            uint256 totalReleasable = token.totalSupply().div(100).mul(5);
            uint256 monthPassed = getMonthsPassed(unlockDate)+1;
            return totalReleasable.div(100).mul(getPercentReleasable((monthPassed.mul(3)),100));
        }else{
            return 0;
        }
    }

    // TODO: unlocks after 13 month, not 12
    // COMPANY; 15% for company reserve; 100% are locked for 12 month, then vesting 3% per month
    function getCompanyReleasable() public view returns(uint256){
        uint256 unlockDate = TGE_timestamp.add(MONTH.mul(12));
        if(now >= unlockDate){
            uint256 totalReleasable = token.totalSupply().div(100).mul(15);
            uint256 monthPassed = getMonthsPassed(unlockDate)+1;
            return totalReleasable.div(100).mul(getPercentReleasable(monthPassed.mul(3),100));
        }else{
            return 0;
        }
    }

    //PRIVATE SALE; 20% for private sale; 40% at listing, 60% of tokens are locked for 6 month, then vested by 10% per month
    function getPrivateReleasable() public view returns(uint256){
        uint256 totalReleasable = token.totalSupply().div(100).mul(20);
        uint256 firstPart = totalReleasable.div(100).mul(40);
        uint256 currentlyReleasable = firstPart;
        uint256 unlockDate = TGE_timestamp.add(MONTH.mul(6));

        if(now >= unlockDate){
            uint256 monthPassed = getMonthsPassed(unlockDate)+1;
            uint256 secondPart = totalReleasable.div(100).mul(getPercentReleasable(monthPassed.mul(10),60));
            currentlyReleasable = firstPart.add(secondPart);
        }
        return currentlyReleasable;
    }

    // COMMUNITY; 45% for community minting; frozen for 6 month
    function getCommunityReleasable() public view returns(uint256){
        uint256 unfreezeTimestamp = TGE_timestamp.add(MONTH.mul(6));
        if(now >= unfreezeTimestamp){
            return token.totalSupply().div(100).mul(45);
        }else{
            return 0;
        }
    }

    // ECOSYSTEM; 5% for ecosystem; 25% after TGE, then 25% per 6 month
    function getEcosystemReleasable() public view returns(uint256){
        uint256 currentlyReleasable = 0;
        if(block.timestamp >= TGE_timestamp){
            uint256 totalReleasable = token.totalSupply().div(100).mul(5);
            uint256 firstPart = totalReleasable.div(100).mul(25);
            uint256 monthPassed = getMonthsPassed(TGE_timestamp);
            uint256 releases = monthPassed.div(6); 
            uint256 secondPart = totalReleasable.div(100).mul(getPercentReleasable(releases.mul(25),75));
            currentlyReleasable = firstPart.add(secondPart);
        }
        return currentlyReleasable;
    }
    function incrementReleased(bytes4 _key, uint256 _amount) internal{
        alreadyWithdrawn[_key]=alreadyWithdrawn[_key].add(_amount);
    }
    /**
     * @dev Transfer all tokens intended for respective part of crowdsale to the wallet which will be distribute these tokens
     */ 
    function releaseLiqudity() public{
        require(token.balanceOf(address(this))>=getLiquidityAvailable(),'Vault does not have enough tokens');
        uint256 toSend = getLiquidityAvailable();
        incrementReleased(liquidityKey,toSend);
        require(token.transfer(liquidity_, toSend),'Token Transfer returned false');
    }
    function releaseTeam() public{
        require(token.balanceOf(address(this))>=getTeamAvailable(),'Vault does not have enough tokens');
        uint256 toSend = getTeamAvailable();
        incrementReleased(teamKey,toSend);
        require(token.transfer(team_, toSend),'Token Transfer returned false');
    }
    function releaseCompany() public{
        require(token.balanceOf(address(this))>=getCompanyAvailable(),'Vault does not have enough tokens');
        uint256 toSend = getCompanyAvailable();
        incrementReleased(companyKey,toSend);
        require(token.transfer(company_, toSend),'Token Transfer returned false');
    }
    function releasePrivate() public{
        require(token.balanceOf(address(this))>=getPrivateAvailable(),'Vault does not have enough tokens');
        uint256 toSend = getPrivateAvailable();
        incrementReleased(privateKey,toSend);
        require(token.transfer(private_, toSend),'Token Transfer returned false');
    }
    function releaseCommunity() public{
        require(token.balanceOf(address(this))>=getCommunityAvailable(),'Vault does not have enough tokens');
        uint256 toSend = getCommunityAvailable();
        incrementReleased(communityKey,toSend);
        require(token.transfer(community_, toSend),'Token Transfer returned false');
    }
    function releaseEcosystem() public{
        require(token.balanceOf(address(this))>=getEcosystemAvailable(),'Vault does not have enough tokens');
        uint256 toSend = getEcosystemAvailable();
        incrementReleased(ecosystemKey,toSend);
        require(token.transfer(ecosystem_, toSend),'Token Transfer returned false');
    }
    function getAlreadyWithdrawn(bytes4 _key) public view returns(uint256){
        return alreadyWithdrawn[_key];
    }
    // function testReduceTGEByMonth() public{
    //     TGE_timestamp=TGE_timestamp-MONTH;
    // }
    // function testIncreaseTGEByMonth() public{
    //     TGE_timestamp=TGE_timestamp+MONTH;
    // }

    // function testGetTGE() public view returns(uint256){
    //     return TGE_timestamp;
    // }
    // function testGetTimespan() public view returns(uint256){
    //     return getMonthsPassed(TGE_timestamp);
    // }
}