pragma solidity 0.5.17;

import "./TreasuryBase.sol";

/**
 * @author Quant Network
 * @title This contract holds a specific treasury's information
 */
contract Treasury is TreasuryBase {

        // The addresses variables in the speed bump
        bytes constant private speedBumpAddresses1 = '1.speedBump.addresses';
        // The uint variables  in  the speed bump
        bytes constant private speedBumpUint16s1 = '1.speedBump.uint16s';
        // If this speed bump wants to pause the contract
        bytes constant private speedBumpCircuitBreaker1 = '1.speedBump.circuitBreaker';
        // What time this SpeedBump was created at
        bytes constant private speedBumpTimeCreated1 = '1.speedBump.timeCreated';
        // this contract's pending speedBumpHours
        bytes constant private speedBumpNextSBHours1 = '1.speedBump.nextSBHours';
        // this contract's current speed bump time period
        bytes constant private speedBumpCurrentSBHours1 = '1.speedBump.currentSBHours';

        // The event fired when other contracts have been connected:
        event connectedContracts(address factory, address ruleList, address escrowedDeposit);
        // The event fired when the treasury's variables have been updated:
        event updatedTreasuryVariables(uint16 mappDisputeFeeMultipler, uint16 commissionDivider, uint16 gatewayPenaltyMultipler, uint16 treasuryPenaltyMultipler);
        // The event fired when the treasury's key variables have been updated:
        event updatedTreasuryMainVariables(address newWithdrawalAddress, address newOperator, bool circuitBreaker);
        // The event fired when new information on the verification has been added:
        event updatedTreasuryFunctionVerification(string verificationDetails, string locationOfDetails);
        // The event fired when a speed bump has been created:
        event updatedSpeedBump(uint speedBumpIndex,uint256 timeCreated,uint256 speedBumpHours);
        
        /**
         * All functions with this modifier can only be called by the current treasury operator
         */    
        modifier onlyOperator(){
            if (msg.sender != operatorAddress()){
                revert("Only the operator address of this contract can modify its associated storage");
            } else {
                _; //means carry on with the computation
            }
        }
        
        /**
         * Sets the treasury's initial variables
         * @param thisQNTAddress  - the QNT address associated to this contract (can be a cold wallet)
         * @param thisOperatorAddress  - the operator address of this contract
         * @param mappDisputeFee - the fee the mapp has to pay for any dispute raised, chargeable per gateway
         * @param commission - the commission divider charged for every mapp to gateway transaction. 
         * The divider is used with the original fee of the function.
         * I.e a commission divider of 2 is equal to 50% commission
         * @param treasuryPenalty - the penalty multiplier the treasury has to pay if it has been found in breach of 
         * one of its verification rules. The mulitipication is used with the original fee of the function.
         * I.e. a treasuryPenalty of 5 is equal to a 5x penalty
         * @param gatewayPenalty - the penalty multiplier a gateway has to pay if it has be found in breach of
         * one of its verification rules. The mulitipication is used with the original fee of the function
         * I.e. a gatewayPenalty of 10 is equal to a 10x penalty.
         */ 
        function initialize (address thisQNTAddress, address thisOperatorAddress, uint16 mappDisputeFee, uint16 commission, uint16 treasuryPenalty, uint16 gatewayPenalty, uint16 speedBumpTime) external {
            require(!initialized(),"contract can only be initialised once");
            QNTAddress(thisQNTAddress);
            operatorAddress(thisOperatorAddress);
            circuitBreakerOn(false);
            mappDisputeFeeMultipler(mappDisputeFee);
            commissionDivider(commission);
            treasuryPenaltyMultipler(treasuryPenalty);
            gatewayPenaltyMultipler(gatewayPenalty);
            speedBumpHours(speedBumpTime);
            //set the admin who can upgrade:
            addressStorage[keccak256('proxy.admin')] = thisOperatorAddress;
            initializeNow(); //sets this contract to initialized
        }

        /**
         * Connect the treasury to its subcontracts, as detailed in speedBump[0], 
         * which should have been added via the updateSpeedBump function below
         * param: speedBump[0].addresses[0] - the linked treasurysFactory contract
         * param: speedBump[0].addresses[1] - the linked treasurysRuleList contract
         * param: speedBump[0].addresses[2] - the linked treasuryDeposit contract
         */
        function updateTreasuryContracts() external onlyOperator() {
            uint8 sb = 0;
            uint256 sBTimeCreated = speedBumpTimeCreated(sb);
            require(sBTimeCreated > 0, "Time created must be >0 (to stop replays of the speed bump)");
            require(now > sBTimeCreated + (speedBumpCurrentSBHours(sb)*1 hours), "The speed bump time period must have passed");
            // make the key state changes
            treasurysFactory(speedBumpAddresses(sb, 0));
            treasurysRuleList(speedBumpAddresses(sb, 1));
            treasurysDeposit(speedBumpAddresses(sb, 2));
            // wipe the speed bump
            speedBumpAddresses(sb, 0, address(0));
            speedBumpAddresses(sb, 1, address(0));
            speedBumpAddresses(sb, 2, address(0));
            speedBumpTimeCreated(sb,0);
            speedBumpCurrentSBHours(sb,0);
            //emit event
            emit connectedContracts(treasurysFactory(), treasurysRuleList(), treasurysDeposit());
        }
        
        /**
         * Updates the treasury's fee variables, as detailed in speedBump[1]
         * param: speedBump[1].uint16s[0] - the fee the mapp has to pay for any dispute raised, chargeable per gateway
         * param: speedBump[1].uint16s[1] - the commission divider charged for every mapp to gateway transaction. 
         * param: speedBump[1].uint16s[2] - the penalty multiplier for the treasury has  to pay if it has be found in breach of one of its verification rules.
         * param: speedBump[1].uint16s[3] - the penalty multiplier a gateway has to pay if it has be found in breach of one of its verification rules. 
         */
        function updateTreasuryFeeVariables() external onlyOperator() {
            uint8 sb = 1;
            uint256 sBTimeCreated = speedBumpTimeCreated(sb);
            require(sBTimeCreated > 0, "Time created must be >0 (to stop replays of the speed bump)");
            require(now > sBTimeCreated + (speedBumpCurrentSBHours(sb)*1 hours), "The speed bump time period must have passed");
            // make the key state changes
            mappDisputeFeeMultipler(speedBumpUint16s(sb, 0));
            commissionDivider(speedBumpUint16s(sb, 1));
            treasuryPenaltyMultipler(speedBumpUint16s(sb, 2));
            gatewayPenaltyMultipler(speedBumpUint16s(sb, 3));
            // wipe the speed bump
            speedBumpUint16s(sb, 0, 0);
            speedBumpUint16s(sb, 1, 0);
            speedBumpUint16s(sb, 2, 0);
            speedBumpUint16s(sb, 3, 0);
            speedBumpTimeCreated(sb,0);
            speedBumpCurrentSBHours(sb,0);
            //emit event
            emit updatedTreasuryVariables(mappDisputeFeeMultipler(),commissionDivider(),gatewayPenaltyMultipler(),treasuryPenaltyMultipler());
        }
        
        /**
         * Updates the treasury's QNT address, operator and circuitBreaker, as detailed in speedBump[2]
         * param: speedBump[2].addresses[0] - the treasury's new QNT Address
         * param: speedBump[2].addresses[1] - the treasury's new operator address
         * param: speedBump[2].circuitBreaker - if this treasury circuitBreaker has been activated 
         * param: speedBump[2].nextSBHours - the next speed bump time  to use
         */
        function updateTreasuryMainVariables() external onlyOperator() {
            uint8 sb = 2;
            uint256 sBTimeCreated = speedBumpTimeCreated(sb);
            require(sBTimeCreated > 0, "Time created must be >0 (to stop replays of the speed bump)");
            require(now > sBTimeCreated + (speedBumpCurrentSBHours(sb)*1 hours), "The speed bump time period must have passed");            
            //make the key state changes
            QNTAddress(speedBumpAddresses(sb, 0));
            operatorAddress(speedBumpAddresses(sb, 1));
            circuitBreakerOn(speedBumpCircuitBreaker(sb));
            speedBumpHours(speedBumpNextSBHours(sb));
            //wipe the speed bump
            speedBumpAddresses(sb, 0, address(0));
            speedBumpAddresses(sb, 1, address(0));
            speedBumpCircuitBreaker(sb,false);
            speedBumpTimeCreated(sb,0);
            speedBumpCurrentSBHours(sb,0);
            speedBumpNextSBHours(sb,0);
            //emit event
            emit updatedTreasuryMainVariables(QNTAddress(),operatorAddress(),circuitBreakerOn());
        }

        /**
         * adds a new speed bump for the updateTreasuryMainVariables function
         * @param addresses - the address variables for the function (QNT address and operator)
         * @param newSpeedBumpHours - the new requested speed bump time 
         * @param circuitBreaker - whether this treasury should pause operations
         */
        function speedBumpMain(address[] calldata addresses, uint16 newSpeedBumpHours, bool circuitBreaker) external onlyOperator() {
            uint8 sb = 2;
            addressStorage[keccak256(abi.encodePacked(speedBumpAddresses1,sb, int8(0)))] = addresses[0];
            addressStorage[keccak256(abi.encodePacked(speedBumpAddresses1,sb, int8(1)))] = addresses[1];
            uint16Storage[keccak256(abi.encodePacked(speedBumpNextSBHours1,sb))] = newSpeedBumpHours;
            boolStorage[keccak256(abi.encodePacked(speedBumpCircuitBreaker1,sb))] = circuitBreaker;
            // set the time as now
            uint256Storage[keccak256(abi.encodePacked(speedBumpTimeCreated1,sb))] = now;
            // set the speedBump hours as they are now
            uint16Storage[keccak256(abi.encodePacked(speedBumpCurrentSBHours1,sb))] = speedBumpHours();
            // emit event
            emit updatedSpeedBump(sb,now,speedBumpHours());
        }
 
        /**
         * adds a new speed bump for the updateTreasuryFeeVariables function
         * @param uint16s - the uint16s variables for the function (see function description for full list)
         */
        function speedBumpFee(uint16[] calldata uint16s) external onlyOperator() {
            uint8 sb = 1;
            uint16Storage[keccak256(abi.encodePacked(speedBumpUint16s1,sb,int8(0)))] = uint16s[0];
            uint16Storage[keccak256(abi.encodePacked(speedBumpUint16s1,sb,int8(1)))] = uint16s[1];
            uint16Storage[keccak256(abi.encodePacked(speedBumpUint16s1,sb,int8(2)))] = uint16s[2];
            uint16Storage[keccak256(abi.encodePacked(speedBumpUint16s1,sb,int8(3)))] = uint16s[3];
            // set the time as now
            uint256Storage[keccak256(abi.encodePacked(speedBumpTimeCreated1,sb))] = now;
            // set the speedBump hours as they are now
            uint16Storage[keccak256(abi.encodePacked(speedBumpCurrentSBHours1,sb))] = speedBumpHours();
            // emit event
            emit updatedSpeedBump(sb,now,speedBumpHours());
        }
        
        /**
         * adds a new speed bump for the updateTreasuryContracts function
         * @param addresses - the addresses of the new contracts (see function description for a full list)
         */
        function speedBumpContract(address[] calldata addresses) external onlyOperator() {
            uint8 sb = 0;
            addressStorage[keccak256(abi.encodePacked(speedBumpAddresses1,sb, int8(0)))] = addresses[0];
            addressStorage[keccak256(abi.encodePacked(speedBumpAddresses1,sb, int8(1)))] = addresses[1];
            addressStorage[keccak256(abi.encodePacked(speedBumpAddresses1,sb, int8(2)))] = addresses[2];
            // set the time as now
            uint256Storage[keccak256(abi.encodePacked(speedBumpTimeCreated1,sb))] = now;
            // set the speedBump hours as they are now
            uint16Storage[keccak256(abi.encodePacked(speedBumpCurrentSBHours1,sb))] = speedBumpHours();
            // emit event
            emit updatedSpeedBump(sb,now,speedBumpHours());
        }
        
        /**
         * Gets the function penalty multipler
         * @return - the penalty amount
         */
        function readFunctionPenaltyMultipler(bool gateway) external view returns (uint256) {
            if (gateway == true){
                return gatewayPenaltyMultipler();
            } else {
                return treasuryPenaltyMultipler();
            }
        }
        
        /**
        * Sets an address variable in a SpeedBump
        * @param index - the speed bump to modify
        * @param addressIndex - the address to modify
        * @param newAddress - the new address
         */        
        function speedBumpAddresses(uint8 index, uint8 addressIndex, address newAddress) internal {
            addressStorage[keccak256(abi.encodePacked(speedBumpAddresses1,index, addressIndex))] = newAddress;
        }
        
        /**
         * Sets an uint16 variable in a SpeedBump
         * @param index - the speed bump to modify 
         * @param uint16Index - the uint16 to modify
         * @param newUint16 - the new uint16 to save
         */         
        function speedBumpUint16s(uint8 index, uint8 uint16Index, uint16 newUint16) internal {
            uint16Storage[keccak256(abi.encodePacked(speedBumpUint16s1,index,uint16Index))] = newUint16;
        } 
        
        /**
         * Sets the circuitBreaker variable in a SpeedBump
         * @param index - the speed bump to modify 
         * @param newCircuitBreaker - the new circuitBreaker 
         */       
        function speedBumpCircuitBreaker(uint8 index, bool newCircuitBreaker) internal {
            boolStorage[keccak256(abi.encodePacked(speedBumpCircuitBreaker1,index))] = newCircuitBreaker;
        } 
        
        /**
         * Reads the time the speedBump was created at
         * @param index - the speed bump to modify
         * @param timeCreated - the time the speed bump was created
         */      
        function speedBumpTimeCreated(uint8 index, uint256 timeCreated) internal {
            uint256Storage[keccak256(abi.encodePacked(speedBumpTimeCreated1,index))] = timeCreated;
        } 
        
        /**
         * Sets the number of hours that this contract's SpeedBump will be updated to
         * @param index - the speed bump to read
         * @param newSpeedBumpHours - the number of hours
         */       
        function speedBumpNextSBHours(uint8 index, uint16 newSpeedBumpHours) internal {
            uint16Storage[keccak256(abi.encodePacked(speedBumpNextSBHours1,index))] = newSpeedBumpHours;
        }

        /**
         * Sets the number of hours until the SpeedBump can be used
         * @param index - the speed bump to read
         * @param newCurrentSBHours - the number of hours
         */       
        function speedBumpCurrentSBHours(uint8 index, uint16 newCurrentSBHours) internal {
            uint16Storage[keccak256(abi.encodePacked(speedBumpCurrentSBHours1,index))] = newCurrentSBHours;
        }
        
        
        /**
        * Reads an address variable in a SpeedBump
        * @param index - the speed bump to read 
        * @param addressIndex - the address to read
        * @return - the specific address
         */        
        function speedBumpAddresses(uint8 index, uint8 addressIndex) public view returns (address){
            return addressStorage[keccak256(abi.encodePacked(speedBumpAddresses1,index,addressIndex))];
        }
        
        /**
         * Reads an uint16 variable in a SpeedBump
         * @param index - the speed bump to read 
         * @param uint16Index - the uint16 to read
         * @return - the specific uint16
         */     
        function speedBumpUint16s(uint8 index, uint8 uint16Index) public view returns (uint16){
            return uint16Storage[keccak256(abi.encodePacked(speedBumpUint16s1,index,uint16Index))];
        } 
        
        /**
         * Reads the circuitBreaker variable in a SpeedBump
         * @param index - the speed bump to read 
         * @return - the specific circuitBreaker 
         */       
        function speedBumpCircuitBreaker(uint8 index) public view returns (bool){
            return boolStorage[keccak256(abi.encodePacked(speedBumpCircuitBreaker1,index))];
        } 

        /**
         * Reads the time the speedBump was created at
         * @param index - the speed bump to read
         * @return - the creation time
         */ 
        function speedBumpTimeCreated(uint8 index) public view returns (uint256){
            return uint256Storage[keccak256(abi.encodePacked(speedBumpTimeCreated1,index))];
        } 
        
       /**
         * @return - this contract's pending speedBumpHours
         */
        function speedBumpNextSBHours(uint8 index) public view returns (uint16){
            return uint16Storage[keccak256(abi.encodePacked(speedBumpNextSBHours1,index))];
        }
    
       /**
         * @return - the time this contract's pending request was created
         */
        function speedBumpCurrentSBHours(uint8 index) public view returns (uint16){
            return uint16Storage[keccak256(abi.encodePacked(speedBumpCurrentSBHours1,index))];
        }

}