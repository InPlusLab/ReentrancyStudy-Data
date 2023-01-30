pragma solidity 0.5.17;

import "./TreasuryBase.sol";
import "./TreasuryFactoryBase.sol";

/**
 * @author Quant Network
 * @title Allows contracts holding mapp, treasury and gateway rules to be easily found
 */
contract RuleLists is UpgradeableProxy {
    
    // the rules that the mapps needs to abide by
    bytes constant private mappRules1 = '1.mappRules';
    // the rules that the treasury needs to abide by
    bytes constant private treasuryRules1 = '1.treasuryRules';
    // the rules that the gateways needs to abide by
    bytes constant private gatewayRules1 = '1.gatewayRules';
    // the number of rules that the mapps needs to abide by
    bytes constant private mappRuleIndex1 = '1.mappRuleIndex';
    // the number of rules that the treasury needs to abide by
    bytes constant private treasuryRuleIndex1 = '1.treasuryRuleIndex';
    // the number of rules that the gateways needs to abide by
    bytes constant private gatewayRuleIndex1 = '1.gatewayRuleIndex';
    // the linked treasury contract
    bytes constant private treasuryAddress1 = '1.treasuryaddress';
    // this contract's current registered speed bumps. Array index [0] is for mapps, [1] for treasury and [2] for gateway.
    bytes constant private speedBumpRule1 = '1.speedBump.rule';
    bytes constant private speedBumpTimeCreated1 = '1.speedBump.timeCreated';
    bytes constant private speedBumpWaitingHours1 = '1.speedBump.waitingHours';
    
    // The event fired when a new rule is stored here:
    event addedRule(string stakeholder, uint256 index);
    // The event fired when a rule has been used:
    event usedRule(uint16 ruleIndex, address slashed, uint256 value);
    // The event fired when a speed bump has been updated
    event updatedSpeedBump(address rule, uint8 speedBumpIndex);
    
    /**
     * All functions with this modifier can only be called by the current treasury address
     * of the contract
     */
    modifier onlyTreasury(){
        TreasuryBase t = TreasuryBase(treasuryAddress());
        if (msg.sender != t.operatorAddress()){
            revert("Only the treasury contract's operator address can modify this contract's associated storage");
        } else {
            _; // otherwise carry on with the computation
        }
    }
    
    /**
    * Sets the contract and initialises the variables
    * @param linkedTreasuryContract - the address of the linked treasury contract
    */  
    function initialize (address linkedTreasuryContract) external {
        require(!initialized(),"contract can only be initialised once");
       addressStorage[keccak256(treasuryAddress1)] = linkedTreasuryContract;
        initializeNow(); //sets this contract to initialized
    }
    
    /**
     * Adds a rule to the correct stakeholder's list. All rules should follow the template code
     * @param speedBumpIndex - which speed bump to use: 0 for mapp, 1 for treasury, 2 for gateway
     * param: speedBumps[speedBumpIndex].rule - the address of a smart contract detailing this specific rule
     */
    function addRule(uint8 speedBumpIndex) external onlyTreasury() {
        require(((speedBumpIndex >= 0)&&(speedBumpIndex <= 2)), "Speed bump index must between 0 and 2 inclusive");
        require(speedBumpTimeCreated(speedBumpIndex) > 0, "Time created must be >0 (to stop replays of the speed bump)");
        require(now > speedBumpTimeCreated(speedBumpIndex) + (speedBumpWaitingHours(speedBumpIndex)*1 hours), "The speed bump time period must have passed");
        if (speedBumpIndex == 0){
            //add rule
            mappRules(speedBumpRule(0));
            //wipe speed bump
            deleteSpeedBump(0);
            //update rule
            emit addedRule("mapps", mappRuleIndex());
        } else if (speedBumpIndex == 1){
            //add rule
            treasuryRules(speedBumpRule(1));
            //wipe speed bump
            deleteSpeedBump(1);
            //update rule
            emit addedRule("treasury", treasuryRuleIndex());
        } else if (speedBumpIndex == 2){
            //add rule
            gatewayRules(speedBumpRule(2));
            //wipe speed bump
            deleteSpeedBump(2);
            //update rule
            emit addedRule("gateways", gatewayRuleIndex());
        }
    }
 
    /**
    * Creates a SpeedBump request for either a mapp, treasury or gateway update as defined by the stakeholder parameter
    * @param stakeholder - what will this speedBump be used for. 
    * Pass through "mapp" to subsequently use the addRule() function to add a rule for the mapps
    * Pass through "treasury" to subsequently use the addRule() function to add a rule for the treasury
    * Pass through "gateway" to subsequently use the addRule() function to add a rule for the gateways
    * @param rule - the address of a smart contract detailing this specific rule
    */ 
    function updateSpeedBump(string calldata stakeholder, address rule) external onlyTreasury() {
        if (keccak256(abi.encodePacked(stakeholder)) == keccak256(abi.encodePacked("mapp"))){
            addSpeedBump(rule, 0);
            //emit event
            emit updatedSpeedBump(rule,0);
        } else if (keccak256(abi.encodePacked(stakeholder)) == keccak256(abi.encodePacked("treasury"))){
            addSpeedBump(rule, 1);
            //emit event
            emit updatedSpeedBump(rule,1);
        } else if (keccak256(abi.encodePacked(stakeholder)) == keccak256(abi.encodePacked("gateway"))){
            addSpeedBump(rule, 2);
            //emit event
            emit updatedSpeedBump(rule,2);
        } else {
            revert("The rule needs to be for a mapp, treasury or gateway");
        }   
    }

    /**
     * Uses a rule. Only rule contracts themselves can invoke this function
     * @param toSlash - which address has broken the rule
     * @param multiple - what is the multiple for the slash used to calculate the final penalty. 
     * This will be the function fee for gateways and the number of gateways for mapps
     * @param ruleIndex - the index of the stakeholder rule broken (0 = mapp, 1 = treasury, 2 = gateway)
     */    
    function useRule(address toSlash, uint multiple, uint16 ruleIndex) external {
        uint256 multipler;
        require(((ruleIndex >= 0)&&(ruleIndex <= 2)), "Rule index must between 0 and 2 inclusive");
        //load the correct deposit contract
        TreasuryBase t = TreasuryBase(treasuryAddress());
        FactoryBase f = FactoryBase(t.treasurysFactory());
        address escrowedDepositAddr;
        if (ruleIndex == 0){
            require (mappRules(ruleIndex) == msg.sender, "Calling address must be a mapp rule");
            multipler = t.mappDisputeFeeMultipler();
            escrowedDepositAddr = f.mappDeposit(toSlash);
        } else if (ruleIndex == 1){
            require (treasuryRules(ruleIndex) == msg.sender, "Calling address must be a treasury rule"); 
            multipler = t.treasuryPenaltyMultipler();
            escrowedDepositAddr = t.treasurysDeposit();
        } else if (ruleIndex == 2){
            require (gatewayRules(ruleIndex) == msg.sender, "Calling address must be a gateway rule");
            multipler = t.gatewayPenaltyMultipler();
            escrowedDepositAddr = f.gatewayDeposit(toSlash);
        }
        //take the correct slashed amount from the deposit contract
        uint256 penalty = multipler*multiple;
        require(penalty > 0, "penalty <= 0");
        EscrowedDepositAbstract(escrowedDepositAddr).deductDeposit(penalty, msg.sender);
        //emit event
        emit usedRule(ruleIndex, toSlash, penalty);
    }

    /**
     * Adds a new mapp rule
     * @param newRule - the address describing the new rule
     */
    function mappRules(address newRule) internal {
        //get current index
        uint16 index = mappRuleIndex();
        index += 1;
        addressStorage[keccak256(abi.encodePacked(mappRules1,index))] = newRule;
        //increase index
        uint16Storage[keccak256(mappRuleIndex1)] = index; 
    }

    /**
     * Adds a new treasury rule
     * @param newRule - the address describing the new rule
     */
    function treasuryRules(address newRule) internal {
        //get current index
        uint16 index = treasuryRuleIndex();
        index += 1;
        addressStorage[keccak256(abi.encodePacked(treasuryRules1,index))] = newRule;
        //increase index
        uint16Storage[keccak256(treasuryRuleIndex1)] = index;
    }

    /**
     * Adds a new gateway rule
     * @param newRule - the address describing the new rule
     */
    function gatewayRules(address newRule) internal {
        //get current index
        uint16 index = gatewayRuleIndex();
        index += 1;
        addressStorage[keccak256(abi.encodePacked(gatewayRules1,index))] = newRule;
        //increase index
        uint16Storage[keccak256(treasuryRuleIndex1)] = index;
    }
 
    /**
     * Adds a new speed bump 
     * @param newRule - the address describing the new rule
     * @param speedBumpIndex - which speed bump is being added
     */    
    function addSpeedBump(address newRule, uint8 speedBumpIndex) internal {
        TreasuryBase t = TreasuryBase(treasuryAddress());
        addressStorage[keccak256(abi.encodePacked(speedBumpRule1,speedBumpIndex))] = newRule;
        uint256Storage[keccak256(abi.encodePacked(speedBumpTimeCreated1,speedBumpIndex))]  = now;
        uint16Storage[keccak256(abi.encodePacked(speedBumpWaitingHours1,speedBumpIndex))] = t.speedBumpHours();
    }

    /**
     * Deletes a speed bump 
     * @param speedBumpIndex - which speed bump is being deleted
     */
    function deleteSpeedBump(uint8 speedBumpIndex) internal {
        addressStorage[keccak256(abi.encodePacked(speedBumpRule1,speedBumpIndex))] = address(0x0);
        uint256Storage[keccak256(abi.encodePacked(speedBumpTimeCreated1,speedBumpIndex))]  = 0;
        uint16Storage[keccak256(abi.encodePacked(speedBumpWaitingHours1,speedBumpIndex))] = 0;
    }
    
    /**
    * @return - the admin of the proxy. Only the admin address can upgrade the smart contract logic
    */
    function admin() public view returns (address) {
        TreasuryBase t = TreasuryBase(treasuryAddress());
        return t.admin();   
    }
      
    /**
    * @return - the number of hours wait time for any critical update
    */        
    function speedBumpHours() public view returns (uint16){
        TreasuryBase t = TreasuryBase(treasuryAddress());
        return t.speedBumpHours();
    }
 
    /**
     * Reads the linked treasury contract address
     * @return - the treasury contract
     */       
    function treasuryAddress() public view returns (address) {
        return addressStorage[keccak256(treasuryAddress1)];
    }
    
    /**
     * Reads the contract rule address in a SpeedBump
     * @param speedBumpIndex - the speed bump to look up
     * @return - the specific rule
     */        
    function speedBumpRule(uint8 speedBumpIndex) public view returns (address) {
        return addressStorage[keccak256(abi.encodePacked(speedBumpRule1,speedBumpIndex))];
    }
    
    /**
     * Reads the time the speedBump was created at
     * @param speedBumpIndex - the speed bump to look up
     * @return - the creation time
     */         
    function speedBumpTimeCreated(uint8 speedBumpIndex) public view returns (uint256) {
        return uint256Storage[keccak256(abi.encodePacked(speedBumpTimeCreated1,speedBumpIndex))];
    }
    
    /**
     * Reads the number of hours until the SpeedBump can be used
     * @param speedBumpIndex - the speed bump to look up
     * @return - the number of hours
     */       
    function speedBumpWaitingHours(uint8 speedBumpIndex) public view returns (uint16) {
        return uint16Storage[keccak256(abi.encodePacked(speedBumpWaitingHours1,speedBumpIndex))];
    }

    /**
     * Reads a specific mapp rule smart  contract  address
     * @param index - the specific index of the rule to read
     * @return - the address
     */ 
    function mappRules(uint16 index) public view returns (address){
        return addressStorage[keccak256(abi.encodePacked(mappRules1,index))];
    }

    /**
     * Reads a specific treasury rule smart  contract  address
     * @param index - the specific index of the rule to read
     * @return - the address
     */ 
    function treasuryRules(uint16 index) public view returns (address){
        return addressStorage[keccak256(abi.encodePacked(treasuryRules1,index))];
    }

    /**
     * Reads a specific gateway rule smart  contract  address
     * @param index - the specific index of the rule to read
     * @return - the address
     */ 
    function gatewayRules(uint16 index) public view returns (address){
        return addressStorage[keccak256(abi.encodePacked(gatewayRules1,index))];
    }

    /**
     * Reads number of mapp rule smart contracts
     * @return - the number of mapp rules
     */ 
    function mappRuleIndex() public view returns (uint16){
        return uint16Storage[keccak256(mappRuleIndex1)];
    }

    /**
     * Reads number of treasury rule smart contracts
     * @return - the number of treasury rules
     */ 
    function treasuryRuleIndex() public view returns (uint16){
        return uint16Storage[keccak256(treasuryRuleIndex1)];
    }

    /**
     * Reads number of gateway rule smart contracts
     * @return - the number of gateway rules
     */ 
    function gatewayRuleIndex() public view returns (uint16){
        return uint16Storage[keccak256(gatewayRuleIndex1)];
    }
    
    
}