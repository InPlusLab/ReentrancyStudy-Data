pragma solidity 0.5.17;

import "./ERC20Interface.sol";
import "./TreasuryBase.sol";
import "./TreasuryFactoryBase.sol";

/**
 * @author Quant Network
 * @title Allows child payment channel & escrow deposit contracts to be easily created for gateways and mapps. 
 */
contract TreasuryFactory is FactoryBase  {
    
    // the linked treasury contract
    bytes constant private treasuryAddress1 = '1.treasuryaddress';
    //mainnet QNT address
    ERC20Interface constant private QNTContract = ERC20Interface(0x4a220E6096B25EADb88358cb44068A3248254675);    
    
    // The event fired when a new mapp or gateway is stored here:
    event addedNewStakeholder(uint8 gateway, address newStakeholderQNTAddress, address newStakeholderOperatorAddress, uint256 QNTforChannel, uint256 QNTforDeposit, uint256 expirationTime);
    
    /**
     * All functions with this modifier can only be called by the current treasury smart contract owner
     * of the contract
     */
    modifier onlyTreasuryOperator(){
        TreasuryBase t = TreasuryBase(treasuryAddress());
        address operator = t.operatorAddress();
        if (msg.sender != operator){
            revert("Only the treasury address of this contract can modify its associated storage");
        } else {
            _; // otherwise carry on with the computation
        }
    }

    /**
     * Sets the linked treasury contract to the variable passed through
     * @param linkedTreasuryContract - the address of the linked treasury
     */ 
    function initialize (address linkedTreasuryContract) external {
        require(!initialized(),"contract can only be initialised once");
         addressStorage[keccak256(treasuryAddress1)] = linkedTreasuryContract;
         initializeNow(); //sets this contract to initialized
    }
    
    /**
     * Adds a new mapp or gateway to the treasury and creates the payment channel and escrow deposit contract
     * @param gateway - is this stakeholder a gateway (true) or a mapp (false)
     * @param newStakeholderQNTAddress - the Ethereum address associated to the stakeholder's (possibly cold) Wallet
     * @param newStakeholderOperatorAddress - the Ethereum address associated to the stakeholder's operator address
     * @param QNTForPaymentChannel - the QNT to be placed in this channel
     * @param QNTForDeposit - how much QNT is being deposited in the escrow
     * @param expirationTime - when the payment channel times out
     */
    function addNew(uint8 gateway, address newStakeholderQNTAddress,  address newStakeholderOperatorAddress, uint256 QNTForPaymentChannel, uint256 QNTForDeposit, uint256 expirationTime) external onlyTreasuryOperator() {
        if (gateway == 1){
            if (gatewayChannel(newStakeholderQNTAddress) != address(0x0)){
                revert("A stakeholder cannot be re-added"); //especially for a payment channel! Otherwise there maybe replay attacks (signed messages of the sender being used more than once)");
            }
            gatewayCount(gatewayCount()+1);
        } else {
            if (mappChannel(newStakeholderQNTAddress) != address(0x0)){
                revert("A stakeholder cannot be re-added"); //especially for a payment channel! Otherwise there maybe replay attacks (signed messages of the sender being used more than once)");
            }
            mappCount(mappCount()+1);
        }
        address newChannel = addChannel(gateway,newStakeholderQNTAddress,newStakeholderOperatorAddress,expirationTime);
        address newEscrow = addEscrowDeposit(gateway,newStakeholderQNTAddress,newStakeholderOperatorAddress,newChannel);
        //function will fail if the new gateway/mapp has not approved this contract to take the total QNT
        //transfer all QNT to this contract to distribute to the payment channel and escrowed deposit in the subsequent function calls
        QNTContract.transferFrom(newStakeholderQNTAddress,address(this),(QNTForPaymentChannel+QNTForDeposit));
        //transfers QNT from this contract to the payment channel:
        //(stakeholder's QNT has already been transferred to this contract)
        QNTContract.transfer(newChannel,QNTForPaymentChannel);
        //transfers QNT from this contract to the escrowed:
        //(stakeholder's QNT has already been transferred to this contract)
        QNTContract.transfer(newEscrow,QNTForDeposit);
        emit addedNewStakeholder(gateway,newStakeholderQNTAddress,newStakeholderOperatorAddress,QNTForPaymentChannel,QNTForDeposit,expirationTime);
    }
    
    /**
     * Adds a new payment channel
     * @param gateway - is this stakeholder a gateway (true) or a mapp (false)
     * @param MAPPorGatewayQNTAddress - the QNT address of the MAPP or gateway in this channel
     * @param MAPPorGatewayOperatorAddress - the operator address of the MAPP or gateway in this channel
     * @param expirationTime - when the payment channel times out
     */
    function addChannel(uint8 gateway, address MAPPorGatewayQNTAddress, address MAPPorGatewayOperatorAddress,uint256 expirationTime) internal returns (address){
        //creates a new instance of the payment channel
        PaymentChannel tpc = new PaymentChannel(MAPPorGatewayQNTAddress,MAPPorGatewayOperatorAddress,treasuryAddress(),gateway,expirationTime);
        address channel = address(tpc);
        //records the newly created contract address:
        if (gateway == 1){
            gatewayChannel(MAPPorGatewayOperatorAddress, channel);
        } else {
            mappChannel(MAPPorGatewayOperatorAddress, channel);
        }
        return channel;
    }
    
    /**
     * Adds a new escrowed deposit
     * @param gateway - is this stakeholder a gateway (true) or a mapp (false)
     * @param MAPPorGatewayQNTAddress - the Ethereum address associated to the mapp or gateway's coldWallet
     * @param MAPPorGatewayOperatorAddress - the Ethereum address associated to the mapp or gateway's operator address, able to call functions of the escrow deposit when permissioned to do so
     * @param paymentChannel - the linked payment channel
     */
    function addEscrowDeposit(uint8 gateway, address MAPPorGatewayQNTAddress,  address MAPPorGatewayOperatorAddress, address paymentChannel) internal returns (address) {
        //creates a new instance of the deposit contract
        EscrowedDeposit ued = new EscrowedDeposit(MAPPorGatewayQNTAddress,MAPPorGatewayOperatorAddress,treasuryAddress(),paymentChannel);
        address escrow = address(ued);
        //records the newly created contract address:
        if (gateway == 1){
            gatewayDeposit(MAPPorGatewayOperatorAddress,escrow);
        } else {
            mappDeposit(MAPPorGatewayOperatorAddress,escrow);
        }
        return escrow;
    }
    
    /**
     * Reads the linked treasury contract address
     * @return - the treasury contract
     */       
    function treasuryAddress() public view returns (address) {
        return addressStorage[keccak256(treasuryAddress1)];
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
    

}

/**
 * @author Quant Network
 * @title Allows QNT to be held in a payment channel either between mapp (sender) and treasury (receiver), or between treasury (sender) and gateway (receiver)
 */
contract PaymentChannel {
    
    // the current nonce of the payment channel, updated when a claim is made. It is required to stop replay attacks (signed messages of the sender being used more than once)
    uint256 public currentNonce;
    // The address who added the deposit
    address public MAPPorGatewayQNTAddress;
    // The address that can trigger functions of this channel on behalf of the MAPP or Gateway
    address public MAPPorGatewayOperatorAddress;
    // the linked treasury contract
    TreasuryBase t;
    // treasuryIsReceiver of channel (true) or not (false)
    uint8 public treasuryIsSender;
    // How long this channel is locked for
    uint256 public expiration;
    // Hardcoded link to the QNT contract:
    ERC20Interface private constant QNTContract = ERC20Interface(0x19Bc592A0E1BAb3AFFB1A8746D8454743EE6E838); 
 
     // The event fired when the payment channel's timeout variable is changed:
    event expirationChanged(uint256 expirationTime);
    // The event fired when the receiver has claimed some of the payment channel's balance:
    event QNTPaymentClaimed(uint256 claimedQNT, uint256 remainingQNT);
    // The event fired when the sender has re-claimed the remaining QNT after the payment channel has timed out:
    event QNTReclaimed(uint256 returnedQNT);

    /**
    * Deploys the contract and initialises the variables
    * @param thisMAPPorGatewayQNTAddress - the QNT address of the MAPP or gateway in this channel
    * @param thisMAPPorGatewayOperatorAddress - the operator address of the MAPP or gateway in this channel
    * @param thisTreasuryAddress - the address of the treasury smart contract
    * @param thisTreasuryIsSender - is the treasury the receiver (true) or sender (false) of this channel
    * @param thisExpirationTime - the expiry time of this channel
    */ 
    constructor(address thisMAPPorGatewayQNTAddress, address thisMAPPorGatewayOperatorAddress, address thisTreasuryAddress, uint8 thisTreasuryIsSender, uint256 thisExpirationTime) public {    
       MAPPorGatewayQNTAddress = thisMAPPorGatewayQNTAddress;
       MAPPorGatewayOperatorAddress = thisMAPPorGatewayOperatorAddress;
       t = TreasuryBase(thisTreasuryAddress);
       treasuryIsSender = thisTreasuryIsSender;
       expiration = thisExpirationTime; 
    }
    

    /**
     * The receiver of the payment channel can claim a QNT payment from it, 
     * if the receiver can produce a valid message from the sender authorising him to do so 
     * @param tokenAmount - the amount to claim
     * @param timeout - the timeout for the gateway to respond by to the last function request 
     * @param disputeTimeout - the timeout for any dispute on the last function call
     * @param signature - the signed message (which must include the above variables)
     * @param refund - any refund to the sender of the channel?
     */
     function claimQNTPayment(uint256 tokenAmount, uint256 timeout, uint256 disputeTimeout, bytes calldata signature, uint256 refund) external {
        //can be invoked by anyone who has the signed off-chain message in their possession
        //but only the receiver's operator address can refund the channel
        require(refund < tokenAmount,"Refund amount cannot cause an underflow");
        if (msg.sender != receiverAddress(true)){
            require(refund == 0, "Only the receiver can give refund the channel");
        }
        require(now < expiration, "This function must be called before the channel times out");
        // this recreates the message that was signed on the client, by the sender's operator address -> sent to the receiver's QNTAddress
        //address(this) is included for an additional replay attack protection
        bytes32 message = prefixed(keccak256(abi.encodePacked(receiverAddress(false), tokenAmount, currentNonce, timeout, disputeTimeout, address(this)))); 
        if(recoverSigner(message, signature) != senderAddress(true)){
            revert("Signed message does not match parameters passed in");
        }
        // update the nonce so no replay attacks can occur
        currentNonce += 1;
        // transfer the QNT
        // (it is up to the sender and/or receiver to check off-chain if the payment channel does not have enough value)
        // the receiver is allowed to refund the sender here if he chooses to take less than the off-chain signed for amount
        QNTContract.transfer(receiverAddress(false), tokenAmount-refund); 
        // emit event
        emit QNTPaymentClaimed(tokenAmount,QNTContract.balanceOf(address(this)));
    }

    /**
     * Increases the expiry time of the channel
     * @param newExpirationTime - the new expiration time
     */
    function updateExpirationTime(uint256 newExpirationTime) external {
        require(msg.sender == senderAddress(true), "Only the senders operator can increase the expiration time");
        require(expiration < newExpirationTime, "You must increase the expiration time");
        expiration = newExpirationTime;
        // emit event
        emit expirationChanged(newExpirationTime);

    }

    /**
     * Allows the sender to reclaim QNT from the channel, if this channel has expired
     */
    function reclaimQNT(uint256 tokenAmount) external {
      require(msg.sender == senderAddress(true), "Only the senders operator can reclaim the QNT");
      require(now >= expiration, "The channel must have expired");
        //transfer required amount
        QNTContract.transfer(senderAddress(false), tokenAmount);
        // Emit event
        emit QNTReclaimed(tokenAmount);
    }

    /**
     * Finds the signer of a message
     * @param message - the message
     * @param sig - the signed bytes
     * @return - the address of the signer
     */
    function recoverSigner(bytes32 message, bytes memory sig) internal pure returns (address) {
        (uint8 v, bytes32 r, bytes32 s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }
    
    /**
     * Finds the v, r and s value of the signature
     * @param sig - the signed bytes
     * @return - the v, r and s values
     */
    function splitSignature(bytes memory sig) internal pure returns (uint8 v, bytes32 r, bytes32 s) {
        require(sig.length == 65);
        assembly {
            // first 32 bytes, after the length prefix
            r := mload(add(sig, 32))
            // second 32 bytes
            s := mload(add(sig, 64))
            // final byte (first byte of the next 32 bytes)
            v := byte(0, mload(add(sig, 96)))
        }
        return (v, r, s);
    }

    /**
     * builds a prefixed hash to mimic the behavior of eth_sign.
     * @param hash - the hash of the message
     * @return - hash of the message mimicing the signing
     */
    function prefixed(bytes32 hash) internal pure returns (bytes32) {
        return keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", hash));
    }

    /**
     * Reads the receiver addresses of this payment channel 
     * @param operatorAddress - should the operator address be returned (true) or the QNTAddress (false)
     * @return - the chosen receiver address
     */       
    function receiverAddress(bool operatorAddress) public view returns (address) {
        if (treasuryIsSender == 0){
            //note that this code allows the treasury's current operator and QNT address to be connected to the channel
            if (operatorAddress == true){
                return t.operatorAddress();
            } else {
                return t.QNTAddress();
            }
        } else {
            if (operatorAddress == true){
                return MAPPorGatewayOperatorAddress;                
            } else {
                return MAPPorGatewayQNTAddress;
            }
        }
    }
    
    /**
     * Reads the sender addresses of this payment channel 
     * @param operatorAddress - should the operator address be returned (true) or the QNTAddress (false)
     * @return - the chosen sender address
     */        
    function senderAddress(bool operatorAddress) public view returns (address) {
        if (treasuryIsSender == 0){
            if (operatorAddress == true){
                return MAPPorGatewayOperatorAddress;                
            } else {
                return MAPPorGatewayQNTAddress;
            }
        } else {
            //note that this code allows the treasury's current operator and QNT address to be connected to the channel
            if (operatorAddress == true){
                return t.operatorAddress();
            } else {
                return t.QNTAddress();
            }
        }
    }
    
    /**
     * Reads the current QNT balance of this contract by checking the linked contract
     * @return - the QNT balance
     */
    function readQNTBalance() public view returns (uint256) {
        return QNTContract.balanceOf(address(this));
    }
    
    /**
     * Reads the linked treasury contract address
     * @return - the treasury contract
     */       
    function treasuryAddress() public view returns (address) {
        return address(t);
    }
    
}

/**
 * @author Quant Network
 * @title Allows a mapp or gateway OVL Network staked deposit to be held in escrow to either be returned or slashed according to the verification rules
 */
contract EscrowedDeposit {

    // @return - the connected payment channel
    PaymentChannel pc;
    // The QNT address of the MAPP or Gateway who added the deposit
    address public MAPPorGatewayQNTAddress;
    // The operator address that can trigger functions of this channel on behalf of the MAPP or Gateway
    address public MAPPorGatewayOperatorAddress;
    // the linked treasury contract
    TreasuryBase t;
    // Hardcoded link to the QNT contract:
    ERC20Interface private constant QNTContract = ERC20Interface(0x19Bc592A0E1BAb3AFFB1A8746D8454743EE6E838);

    // The event fired when the deposit is deducted:
    event depositDeducted(uint256 claimedQNT, uint256 remainingQNT, address ruleAddress);
    // The event fired when the deposit is returned:
    event depositReturned(uint256 returnedQNT);

    /**
    * Deploys the contract and initialises the variables
    * @param thisMAPPorGatewayQNTAddress - the QNT address of the MAPP or gateway in this escrow
    * @param thisMAPPorGatewayOperatorAddress - the operator address of the MAPP or gateway in this escrow
    * @param thisTreasuryAddress - the address of the treasury smart contract
    * @param thisChannelAddress - the corresponding payment channel
    */ 
    constructor(address thisMAPPorGatewayQNTAddress, address thisMAPPorGatewayOperatorAddress, address thisTreasuryAddress, address thisChannelAddress) public {    
       MAPPorGatewayQNTAddress = thisMAPPorGatewayQNTAddress;
       MAPPorGatewayOperatorAddress = thisMAPPorGatewayOperatorAddress;
       t = TreasuryBase(thisTreasuryAddress);
       pc = PaymentChannel(thisChannelAddress);
    }
    
    /**
     * The rule list contract can deduct QNT from this escrow and send it to the receiver (without closing the escrow)
     * @param tokenAmount - the amount to deduct
     * @param ruleAddress - the contract address detailing the specific rule the sender has broken
     */
    function deductDeposit(uint256 tokenAmount, address ruleAddress) external {
        address ruleList = t.treasurysRuleList();
        require(msg.sender == ruleList, "This function can only be called by the associated rule list contract");
        require(now >= expiration(), "The channel must have expired");
        // Transfer the escrowed QNT:
        uint256 startingBalance = readQNTBalance();
        if (tokenAmount > startingBalance){ 
            //transfer as much as possible:
            QNTContract.transfer(t.QNTAddress(), startingBalance);  
            //emits event
            emit depositDeducted(startingBalance,0,ruleAddress);
        } else {
            //transfer required amount
            QNTContract.transfer(t.QNTAddress(), tokenAmount);     
            //emits event
            emit depositDeducted(tokenAmount,readQNTBalance(),ruleAddress); 
        }
    }

    /**
     * After the expiration time, the sender of this deposit can withdraw it through this function
     */
    function WithdrawDeposit(uint256 tokenAmount) external {
      require(msg.sender == MAPPorGatewayOperatorAddress, "Can only be called by the MAPP/Gateway operator address after expiry");
        require(now >= expiration(), "Can only be called by the MAPP/Gateway operator address after expiry");
       //transfer required amount
       QNTContract.transfer(MAPPorGatewayQNTAddress, tokenAmount);
       // Emit event
       emit depositReturned(tokenAmount);
    }

    /**
     * Reads the current QNT balance of this contract by checking the linked ERC20 contract
     * @return - the QNT balance
     */
    function readQNTBalance() public view returns (uint256) {
        return QNTContract.balanceOf(address(this));
    }

    /**
     * Reads the current expiration time of this contract by checking the linked payment channel contract
     * @return - the expiration
     */
    function expiration() public view returns (uint256){
        return pc.expiration();
    }
    

    /**
     * Reads the linked treasury contract address
     * @return - the treasury contract
     */       
    function treasuryAddress() public view returns (address) {
        return address(t);
    }
    
    /**
     * Reads the corresponding payment channel address
     * @return - the payment channel contract
     */       
    function paymentChannelAddress() public view returns (address) {
        return address(pc);
    }
    
}
