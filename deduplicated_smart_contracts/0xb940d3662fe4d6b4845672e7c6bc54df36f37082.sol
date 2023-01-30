pragma solidity 0.5.17;

import "./ERC20Interface.sol";
import "./TreasuryBase.sol";

/**
 * @author Quant Network
 * @title Allows the treasury deposit to be held in escrow to be either returned or slashed according to defined rules
 * The treasury can withdraw from its deposit by firstly adding a request to withdraw, waiting the speed bump time period and then adding another tx  to finalise the withdrawal
 */
contract EscrowedDeposit  is UpgradeableProxy {

    // the treasury contract address;
    bytes constant private treasuryAddress1 = '1.treasuryaddress';
    // how much QNT to withdraw via this circuit breaker
    bytes constant private speedBumpQNTToWithdraw1 = '1.speedBump.QNTToWithdraw';
    // what time this SpeedBump was created at
    bytes constant private speedBumpTimeCreated1 = '1.speedBump.timeCreated';
    // how long after the SpeedBump was created that this can be used
    bytes constant private speedBumpWaitingHours1 = '1.speedBump.waitingHours';
    //mainnet QNT address
    ERC20Interface constant private QNTContract = ERC20Interface(0x4a220E6096B25EADb88358cb44068A3248254675); 
 
    // The event fired when the deposit contract's deposit is deducted:
    event depositDeducted(uint256 claimedQNT, address receiver, uint256 remainingQNT, address ruleAddress);
    // The event fired when the deposit contract's deposit is returned:
    event depositReturned(uint256 returnedQNT);
    // The event fired when a speed bump has been created:
    event updatedSpeedBump(uint256 QNTToWithdraw,uint16 speedBumpHours);

    
    /**
    * Initialises the variables
    * @param linkedTreasuryContract - the address of the linked treasury contract
    */ 
    function initialize(address linkedTreasuryContract) external {
        require(!initialized(),"contract can only be initialised once");
        addressStorage[keccak256(treasuryAddress1)] = linkedTreasuryContract;
        initializeNow(); //sets this contract to initialized
    }
    
    /**
     * The rule list contract can deduct QNT from this escrow and send it to the receiver (without closing the escrow)
     * @param tokenAmount - the amount to deduct
     * @param ruleAddress - the contract address detailing the specific rule the treasury has broken
     * @param receiver - who will receive the deducted deposit
     */
    function deductDeposit(uint256 tokenAmount, address ruleAddress, address receiver) external {
        TreasuryBase t = TreasuryBase(treasuryAddress());
        require(msg.sender == t.treasurysRuleList(), "This function can only be called by the associated rule list contract");
        // Transfer the escrowed QNT:
        uint256 startingBalance = QNTBalance();
        if (tokenAmount > startingBalance){
            //transfer as much as possible:
            QNTContract.transfer(receiver, startingBalance);   
            // Emit event
            emit depositDeducted(startingBalance,receiver,0,ruleAddress);
        } else {
            //transfer required amount
            QNTContract.transfer(receiver, tokenAmount);
            // Emit event
            emit depositDeducted(tokenAmount,receiver,QNTBalance(),ruleAddress);
        }
    }

    /**
     * Withdraws QNT from the deposit, as detailed in the speedBump only after the waiting time of the speed bump has completed
     */
    function withdrawDeposit() external {
        TreasuryBase t = TreasuryBase(treasuryAddress());
        uint256 sBTimeCreated = speedBumpTimeCreated();
      require(msg.sender == t.operatorAddress(), "Can only be called by the treasury operator");
      require(sBTimeCreated > 0, "Time created must be >0 (to stop replays of the speed bump)");
      require(now > sBTimeCreated + (speedBumpWaitingHours()*1 hours), "The speed bump time period must have passed");
      uint256 QNTToWithdraw = speedBumpQNTToWithdraw();
      if (QNTToWithdraw > 0){
          //wipe the speed bump
          speedBumpQNTToWithdraw(0);
          speedBumpTimeCreated(0);
          speedBumpWaitingHours(0);
          // Transfer the escrowed QNT:
          address receiver = t.QNTAddress();
          uint256 startingBalance = QNTBalance();
          if (QNTToWithdraw > startingBalance){ 
            //this would occur if the treasury has been slashed since the SpeedBump was created
            //transfer as much as possible:
            QNTContract.transfer(receiver, startingBalance);  
            //emits event
            emit depositReturned(startingBalance); 
          } else {
            //transfer required amount
            QNTContract.transfer(receiver, QNTToWithdraw);     
            //emits event
            emit depositReturned(QNTToWithdraw); 
          }
      }
    }
    
    /**
     * Creates a SpeedBump request to withdraw some (non-slashed) QNT
     * @param QNTToWithdraw - the desired QNT to withdraw
     */
    function updateSpeedBump(uint256 QNTToWithdraw) external {
        TreasuryBase t = TreasuryBase(treasuryAddress());
        require(msg.sender == t.operatorAddress(), "This function can only be called by the treasury operator");
        require(QNTBalance() >= QNTToWithdraw, "There is not enough QNT in the escrowed deposit");
        //set the speed bump variables
        speedBumpQNTToWithdraw(QNTToWithdraw);
        speedBumpTimeCreated(now);
        uint16 sbHours = t.speedBumpHours();
        speedBumpWaitingHours(sbHours);
        emit updatedSpeedBump(QNTToWithdraw,sbHours);
    }
    
    /**
     * sets a QNT to withdraw amount for the speed bump
     */        
    function speedBumpQNTToWithdraw(uint256 QNTToWithdraw) internal {
        uint256Storage[keccak256(speedBumpQNTToWithdraw1)] = QNTToWithdraw;
    }
    
    /**
     * sets the time the speed bump was created
     */        
    function speedBumpTimeCreated(uint256 timeCreated) internal {
        uint256Storage[keccak256(speedBumpTimeCreated1)] = timeCreated;
    }
    
    /**
     * Sets the number of hours before the speed bump can be used
     */       
    function speedBumpWaitingHours(uint16 currentSBHours) internal {
        uint16Storage[keccak256(speedBumpWaitingHours1)] = currentSBHours;
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
     * Reads the current QNT balance of this contract by checking the linked treasury
     * @return - the QNT balance
     */
    function QNTBalance() public view returns (uint256) {
        return QNTContract.balanceOf(address(this));
    }
    
    /**
     * Reads the linked ERC20 address
     * @return - the ERC20 contract
     */       
    function ERC20Address() external pure returns (address) {
        return address(QNTContract);
    }
    
    /**
     * Reads the linked treasury contract address
     * @return - the treasury contract
     */         
    function treasuryAddress() public view returns (address) {
        return addressStorage[keccak256(treasuryAddress1)];
    }
    
    /**
     * Reads the requested QNT of the SpeedBump
     * @return - the QNT
     */        
    function speedBumpQNTToWithdraw() public view returns (uint256) {
        return uint256Storage[keccak256(speedBumpQNTToWithdraw1)];
    }
    
    /**
     * Reads the time the speedBump was created at
     * @return - the creation time
     */        
    function speedBumpTimeCreated() public view returns (uint256) {
        return uint256Storage[keccak256(speedBumpTimeCreated1)];
    }
    
    /**
     * Reads the number of hours until the SpeedBump can be used
     * @return - the number of hours
     */        
    function speedBumpWaitingHours() public view returns (uint16) {
        return uint16Storage[keccak256(speedBumpWaitingHours1)];
    }


}