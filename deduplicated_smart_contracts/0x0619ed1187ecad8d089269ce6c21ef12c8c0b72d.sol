pragma solidity 0.5.8;



import './ERC20.sol';

import './ECVerify.sol';

import './SafeMath64.sol';



/// @title Privatix Service Contract.

contract PrivatixServiceContract {

    using SafeMath64 for uint64;



    /*

     *  Data structures

     */



    // Number of blocks Agent must wait from last popupServiceOffering or from registerServiceOffering before

    // he can popupServiceOffering.

    uint32 public popup_period;



    // Number of blocks to wait from an uncooperativeClose initiated by the Client

    // in order to give the Agent a chance to respond with a balance proof

    // in case the sender cheats. After the remove period, the sender can settle

    // and delete the channel.

    uint32 public challenge_period;



    // Number of blocks Agent will wait from registerServiceOffering or from last popupServiceOffering before

    // he can delete service offering and receive Agent's deposit back.

    uint32 public remove_period;



    // Fee that goes to network_fee_address from each closed channel balance.

    uint32 public network_fee;

    

    // Address where network_fee is transferred.

    address public network_fee_address;



    // We temporarily limit total token deposits in a channel to 300 PRIX.

    // This is just for the bug bounty release, as a safety measure.

    uint64 public constant channel_deposit_bugbounty_limit = 10 ** 8 * 300;



    ERC20 public token;



    mapping (bytes32 => Channel) private channels;

    mapping (bytes32 => ClosingRequest) private closing_requests;

    mapping (address => uint64) private internal_balances;

    mapping(bytes32 => ServiceOffering) private service_offering_s;



    // 52 bytes

    struct ServiceOffering{

      uint64 min_deposit;  // bytes8 - Minimum deposit that Client should place to open state channel.

      address agent_address; //bytes20 - Address of Agent.

      uint16 max_supply; // bytes2 - Maximum supply of services according to service offerings.

      uint16 current_supply; // bytes2 - Currently remaining available supply.



      // bytes4 - Last block number when service offering was created, popped-up or channel opened.

      // If 0 - offering was removed.

      uint32 update_block_number;

    }



    // 28 bytes

    struct Channel {

        // uint64 is the maximum uint size needed for deposit based on a

        // log2(10^8 * 1275455 token totalSupply) = 46.85.

        uint64 deposit;



        // Block number at which the channel was opened. Used in creating

        // a unique identifier for the channel between a sender and receiver.

        // Supports creation of multiple channels between the 2 parties and prevents

        // replay of messages in later channels.

        uint32 open_block_number;

    }



    // 28 bytes

    struct ClosingRequest {

        // Number of tokens owed by the Client when closing the channel.

        uint64 closing_balance;



        // Block number at which the remove period ends, in case it has been initiated.

        uint32 settle_block_number;

    }



    /*

     *  Events

     */



    event LogChannelCreated(

        address indexed _agent,

        address indexed _client,

        bytes32 indexed _offering_hash,

        uint64 _deposit);

    event LogChannelToppedUp(

        address indexed _agent,

        address indexed _client,

        bytes32 indexed _offering_hash,

        uint32 _open_block_number,

        uint64 _added_deposit);

    event LogChannelCloseRequested(

        address indexed _agent,

        address indexed _client,

        bytes32 indexed _offering_hash,

        uint32 _open_block_number,

        uint64 _balance);

    event LogOfferingCreated(

        address indexed _agent,

        bytes32 indexed _offering_hash,

        uint64 indexed _min_deposit,

        uint16 _current_supply,

        uint8 _source_type,

        string _source);

    event LogOfferingDeleted(

      address indexed _agent,

      bytes32 indexed _offering_hash);

    event LogOfferingPopedUp(

      address indexed _agent,

      bytes32 indexed _offering_hash,

      uint64 indexed _min_deposit,

      uint16 _current_supply,

      uint8 _source_type,

      string _source);

    event LogCooperativeChannelClose(

      address indexed _agent,

      address indexed _client,

      bytes32 indexed _offering_hash,

      uint32 _open_block_number,

      uint64 _balance);

    event LogUnCooperativeChannelClose(

      address indexed _agent,

      address indexed _client,

      bytes32 indexed _offering_hash,

      uint32 _open_block_number,

      uint64 _balance);



    /*

     *  Modifiers

     */



    /*

     *  Constructor

     */



    /// @notice Constructor for creating the Privatix Service Contract.

    /// @param _token_address The address of the PTC (Privatix Token Contract)

    /// @param _popup_period A fixed number of blocks representing the pop-up period.

    /// @param _remove_period A fixed number of blocks representing the remove period.

    /// @param _challenge_period A fixed number of blocks representing the challenge period.

    /// We enforce a minimum of 500 blocks waiting period.

    /// after a sender requests the closing of the channel without the receiver's signature.

    constructor(

      address _token_address,

      address _network_fee_address,

      uint32 _popup_period,

      uint32 _remove_period,

      uint32 _challenge_period

      ) public {

        require(_token_address != address(0x0));

        require(addressHasCode(_token_address));

        require(_network_fee_address != address(0x0));

        require(_remove_period >= 100);

        require(_popup_period >= 500);

        require(_challenge_period >= 5000);



        token = ERC20(_token_address);



        // Check if the contract is indeed a token contract

        require(token.totalSupply() > 0);



        network_fee_address = _network_fee_address;

        popup_period = _popup_period;

        remove_period = _remove_period;

        challenge_period = _challenge_period;



    }



    /*

     *  External functions

     */



    /// @notice Creates a new internal balance by transferring from PTC ERC20 token.

    /// @param _value Token transfered to internal balance.

    function addBalanceERC20(uint64 _value) external {

      internal_balances[msg.sender] = internal_balances[msg.sender].add(_value);

      // transferFrom deposit from sender to contract

      // ! needs prior approval on token contract.

      require(token.transferFrom(msg.sender, address(this), _value));

    }



    /// @notice Transfers tokens from internal balance to PTC ERC20 token.

    /// @param _value Token amount to return.

    function returnBalanceERC20(uint64 _value) external {

      internal_balances[msg.sender] = internal_balances[msg.sender].sub(_value); // test S21

      require(token.transfer(msg.sender, _value));

    }



    /// @notice Returns user internal balance.

    function balanceOf(address _address) external view

    returns(uint64)

    {

      return (internal_balances[_address]); // test U1

    }



    /// @notice Change address where fee is transferred

    /// @param  _network_fee_address Address where network_fee is transferred.

    function setNetworkFeeAddress(address _network_fee_address) external { // test S24

        require(msg.sender == network_fee_address);

        network_fee_address = _network_fee_address;

    }



    /// @notice Change network fee value. It is limited from 0 to 10%.

    /// @param  _network_fee Fee that goes to network_fee_address from each closed channel balance.

    function setNetworkFee(uint32 _network_fee) external { // test S22

        require(msg.sender == network_fee_address);

        require(_network_fee <= 10000); // test S23

        network_fee = _network_fee;

    }



    /// @notice Creates a new channel between `msg.sender` (Client) and Agent and places

    /// the `_deposit` tokens from internal_balances to channel.

    /// @param _agent_address The address of Agent that receives tokens.

    /// @param _offering_hash Service Offering hash that uniquely identifies it.

    /// @param _deposit The amount of tokens that the Client escrows.

    function createChannel(address _agent_address, bytes32 _offering_hash, uint64 _deposit) external {

        require(_deposit >= service_offering_s[_offering_hash].min_deposit); // test S4

        require(internal_balances[msg.sender] >= _deposit); // test S5



        decreaseOfferingSupply(_agent_address, _offering_hash);

        createChannelPrivate(msg.sender, _agent_address, _offering_hash, _deposit);

        internal_balances[msg.sender] = internal_balances[msg.sender].sub(_deposit); //test S5

        emit LogChannelCreated(_agent_address, msg.sender, _offering_hash, _deposit); //test E1

    }



    /// @notice Increase the channel deposit with `_added_deposit`.

    /// @param _agent_address The address of Agent that receives tokens.

    /// @param _open_block_number The block number at which a channel between the

    /// Client and Agent was created.

    /// @param _offering_hash Service Offering hash that uniquely identifies it.

    /// @param _added_deposit The added token deposit with which the current deposit is increased.

    function topUpChannel(

        address _agent_address,

        uint32 _open_block_number,

        bytes32 _offering_hash,

        uint64 _added_deposit)

        external

    {

        updateInternalBalanceStructs(

            msg.sender,

            _agent_address,

            _open_block_number,

            _offering_hash,

            _added_deposit

        );



        internal_balances[msg.sender] = internal_balances[msg.sender].sub(_added_deposit);

    }



    /// @notice Function called by the Client or Agent, with all the needed

    /// signatures to close the channel and settle immediately.

    /// @param _agent_address The address of Agent that receives tokens.

    /// @param _open_block_number The block number at which a channel between the

    /// Client and Agent was created.

    /// @param _offering_hash Service Offering hash that uniquely identifies it.

    /// @param _balance The amount of tokens owed by the Client to the Agent.

    /// @param _balance_msg_sig The balance message signed by the Client.

    /// @param _closing_sig The Agent's signed balance message, containing the Client's address.

    function cooperativeClose(

        address _agent_address,

        uint32 _open_block_number,

        bytes32 _offering_hash,

        uint64 _balance,

        bytes calldata _balance_msg_sig,

        bytes calldata _closing_sig)

        external

    {

        // Derive Client address from signed balance proof

        address sender = extractSignature(_agent_address, _open_block_number, _offering_hash, _balance, _balance_msg_sig, true);



        // Derive Agent address from closing signature

        address receiver = extractSignature(sender, _open_block_number, _offering_hash, _balance, _closing_sig, false);

        require(receiver == _agent_address); // tests S6, I1a-I1f



        // Both signatures have been verified and the channel can be settled.

        settleChannel(sender, receiver, _open_block_number, _offering_hash, _balance);

        emit LogCooperativeChannelClose(receiver, sender, _offering_hash, _open_block_number, _balance); // test E7

    }



    /// @notice Client requests the closing of the channel and starts the remove period.

    /// This can only happen once.

    /// @param _agent_address The address of Agent that receives tokens.

    /// @param _open_block_number The block number at which a channel between

    /// the Client and Agent was created.

    /// @param _offering_hash Service Offering hash that uniquely identifies it.

    /// @param _balance The amount of tokens owed by the Client to the Agent.

    function uncooperativeClose(

        address _agent_address,

        uint32 _open_block_number,

        bytes32 _offering_hash,

        uint64 _balance)

        external

    {

        bytes32 key = getKey(msg.sender, _agent_address, _open_block_number, _offering_hash);



        require(channels[key].open_block_number > 0); // test S9

        require(closing_requests[key].settle_block_number == 0); // test S10

        require(_balance <= channels[key].deposit); // test S11



        // Mark channel as closed

        closing_requests[key].settle_block_number = uint32(block.number) + challenge_period;

        require(closing_requests[key].settle_block_number > block.number);

        closing_requests[key].closing_balance = _balance;



        emit LogChannelCloseRequested(_agent_address, msg.sender, _offering_hash, _open_block_number, _balance); // test E3

    }





    /// @notice Function called by the Client after the remove period has ended, in order to

    /// settle and delete the channel, in case the Agent has not closed the channel himself.

    /// @param _agent_address The address of Agent that receives tokens.

    /// @param _open_block_number The block number at which a channel between

    /// the Client and Agent was created.

    /// @param _offering_hash Service Offering hash that uniquely identifies it.

    function settle(address _agent_address, uint32 _open_block_number, bytes32 _offering_hash) external {

        bytes32 key = getKey(msg.sender, _agent_address, _open_block_number, _offering_hash);



        // Make sure an uncooperativeClose has been initiated

        require(closing_requests[key].settle_block_number > 0); // test S7



        // Make sure the challenge_period has ended

        require(block.number > closing_requests[key].settle_block_number); // test S8

        uint64 balance = closing_requests[key].closing_balance;

        settleChannel(msg.sender, _agent_address, _open_block_number, _offering_hash,

           closing_requests[key].closing_balance

        );



        emit LogUnCooperativeChannelClose(_agent_address, msg.sender, _offering_hash,

           _open_block_number, balance

        ); // test E9

    }



    /// @notice Function for retrieving information about a channel.

    /// @param _client_address The address of Client hat sends tokens.

    /// @param _agent_address The address of Agent that receives tokens.

    /// @param _open_block_number The block number at which a channel between the

    /// Client and Agent was created.

    /// @param _offering_hash Service Offering hash that uniquely identifies it.

    /// @return Channel information (unique_identifier, deposit, settle_block_number, closing_balance).

    function getChannelInfo(

        address _client_address,

        address _agent_address,

        uint32 _open_block_number,

        bytes32 _offering_hash)

        external

        view

        returns (uint64, uint32, uint64)

    {

        bytes32 key = getKey(_client_address, _agent_address, _open_block_number, _offering_hash);



        return (

            channels[key].deposit,

            closing_requests[key].settle_block_number,

            closing_requests[key].closing_balance

        );

    }



    function getOfferingInfo(bytes32 offering_hash)

        external

        view

        returns(address, uint64, uint16, uint16, uint32)

    {

        ServiceOffering memory offering = service_offering_s[offering_hash];

        return (offering.agent_address,

                offering.min_deposit,

                offering.max_supply,

                offering.current_supply,

                offering.update_block_number

        );

        // test U2

    }





    /*

     *  Public functions

     */



    /// @notice Called by Agent to register service offering

    /// @param _offering_hash Service Offering hash that uniquely identifies it.

    /// @param _min_deposit Minimum deposit that Client should place to open state channel.

    /// @param _max_supply Maximum supply of services according to service offerings.

    function registerServiceOffering (

     bytes32 _offering_hash,

     uint64 _min_deposit,

     uint16 _max_supply,

     uint8 _source_type,

     string calldata _source)

     external

    {

      // Service offering not exists, test S2

      require(service_offering_s[_offering_hash].update_block_number == 0);



      //Agent deposit greater than max allowed, test S1

      require(_min_deposit.mul(_max_supply) < channel_deposit_bugbounty_limit);

      require(_min_deposit > 0); // zero deposit is not allowed, test S3



      service_offering_s[_offering_hash] = ServiceOffering(_min_deposit,

                                                           msg.sender,

                                                           _max_supply,

                                                           _max_supply,

                                                           uint32(block.number)

                                                          );



      // Substitute deposit amount for each offering slot from agent's internal balance

      // Service provider internal balance must be not less then _min_deposit * _max_supply

      internal_balances[msg.sender] = internal_balances[msg.sender].sub(_min_deposit.mul(_max_supply)); // test S26



      emit LogOfferingCreated(msg.sender, _offering_hash, _min_deposit, _max_supply, _source_type, _source); // test E4

    }



    /// @notice Called by Agent to permanently deactivate service offering.

    /// @param _offering_hash Service Offering hash that uniquely identifies it.

    function removeServiceOffering (

     bytes32 _offering_hash)

     external

    {

      require(service_offering_s[_offering_hash].update_block_number > 0); // test S13

      // only creator can delete his offering

      assert(service_offering_s[_offering_hash].agent_address == msg.sender); // test S14

      // At least remove_period blocks were mined after last offering structure update

      require(service_offering_s[_offering_hash].update_block_number + remove_period < block.number); // test S15

      // return Agent's deposit back to his internal balance

      internal_balances[msg.sender] = internal_balances[msg.sender].add(



        // it's safe because it was checked in registerServiceOffering

        service_offering_s[_offering_hash].min_deposit * service_offering_s[_offering_hash].max_supply



      );

      // this marks offering as deleted

      service_offering_s[_offering_hash].update_block_number = 0;



      emit LogOfferingDeleted(msg.sender, _offering_hash); // test E5

    }



    /// @notice Called by Agent to signal that service offering is actual

    /// @param _offering_hash Service Offering hash that uniquely identifies it.

    function popupServiceOffering (

        bytes32 _offering_hash,

        uint8 _source_type,

        string calldata _source)

    external

    {

      require(service_offering_s[_offering_hash].update_block_number > 0); // Service offering already exists, test S16

      // At least popup_period blocks were mined after last offering structure update

      require(service_offering_s[_offering_hash].update_block_number + popup_period < block.number); // test S16a

      require(service_offering_s[_offering_hash].agent_address == msg.sender); // test S17

      // require(block.number > service_offering_s[_offering_hash].update_block_number);



      ServiceOffering memory offering = service_offering_s[_offering_hash];

      service_offering_s[_offering_hash].update_block_number = uint32(block.number);



      emit LogOfferingPopedUp(msg.sender,

                              _offering_hash,

                              offering.min_deposit,

                              offering.current_supply,

                              _source_type, _source

                             ); // test E8

    }



    /// @notice Returns the sender address extracted from the balance proof or closing signature.

    /// @param _address The address of Agent or Client that receives/sends tokens.

    /// @param _open_block_number The block number at which a channel between the

    /// Client and Agent was created.

    /// @param _offering_hash Service Offering hash that uniquely identifies it.

    /// @param _balance The amount of tokens owed by the Client to the Agent.

    /// @param _msg_sig The balance message signed by the Client or Agent (depends on _type).

    /// @param _type true - extract from BalanceProofSignature signed by Client,

    /// false - extract from ClosingSignature signed by Agent

    /// @return Address of the balance proof signer.

    function extractSignature(

        address _address,

        uint32 _open_block_number,

        bytes32 _offering_hash,

        uint64 _balance,

        bytes memory _msg_sig,

        bool _type)

        public

        view

        returns (address)

    {

        // The hashed strings should be kept in sync with this function's parameters

        // (variable names and types).

        bytes32 message_hash =

        keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",

            keccak256(abi.encodePacked(

                _type ? 'Privatix: sender balance proof signature' : 'Privatix: receiver closing signature',

                _address,

                _open_block_number,

                _offering_hash,

                _balance,

                address(this)

            ))

        ));



        // Derive address from signature

        address signer = ECVerify.ecverify(message_hash, _msg_sig);

        return signer;

    }



    /// @notice Returns the unique channel identifier used in the contract.

    /// @param _client_address The address of Client that sends tokens.

    /// @param _agent_address The address of Agent that receives tokens.

    /// @param _open_block_number The block number at which a channel between the

    /// Client and Agent was created.

    /// @param _offering_hash Service Offering hash that uniquely identifies it.

    /// @return Unique channel identifier.

    function getKey(

        address _client_address,

        address _agent_address,

        uint32 _open_block_number,

        bytes32 _offering_hash)

        public

        pure

        returns (bytes32 data)

    {

        return keccak256(abi.encodePacked(_client_address, _agent_address, _open_block_number, _offering_hash));

    }



    /*

     *  Private functions

     */



     /// @notice Increases available service offering supply.

     /// @param _agent_address The address of Agent that created service offering.

     /// @param _offering_hash Service Offering hash that uniquely identifies it.

     /// @return True in both case, when Service Offering still active or already deactivated.

     function increaseOfferingSupply(address _agent_address, bytes32 _offering_hash)

      private

      returns (bool)

    {

      require(service_offering_s[_offering_hash].current_supply < service_offering_s[_offering_hash].max_supply);

      // Verify that Agent owns this offering

      require(service_offering_s[_offering_hash].agent_address == _agent_address);

      // saving gas, as no need to update state

      if(service_offering_s[_offering_hash].update_block_number == 0) return true;



      service_offering_s[_offering_hash].current_supply = service_offering_s[_offering_hash].current_supply+1;



      return true;

    }



    /// @notice Decreases available service offering supply.

    /// @param _agent_address The address of Agent that created service offering.

    /// @param _offering_hash Service Offering hash that uniquely identifies it.



    function decreaseOfferingSupply(address _agent_address, bytes32 _offering_hash)

     private

   {

     require(service_offering_s[_offering_hash].update_block_number > 0);

     require(service_offering_s[_offering_hash].agent_address == _agent_address);

     require(service_offering_s[_offering_hash].current_supply > 0); // test I5



     service_offering_s[_offering_hash].current_supply = service_offering_s[_offering_hash].current_supply-1;



   }



    /// @dev Creates a new channel between a Client and a Agent.

    /// @param _client_address The address of Client that sends tokens.

    /// @param _agent_address The address of Agent that receives tokens.

    /// @param _offering_hash Service Offering hash that uniquely identifies it.

    /// @param _deposit The amount of tokens that the Client escrows.

    function createChannelPrivate(address _client_address,

                                  address _agent_address,

                                  bytes32 _offering_hash,

                                  uint64 _deposit) private {



        require(_deposit <= channel_deposit_bugbounty_limit);



        uint32 open_block_number = uint32(block.number);



        // Create unique identifier from sender, receiver and current block number

        bytes32 key = getKey(_client_address, _agent_address, open_block_number, _offering_hash);



        require(channels[key].deposit == 0);

        require(channels[key].open_block_number == 0);

        require(closing_requests[key].settle_block_number == 0);



        // Store channel information

        channels[key] = Channel({deposit: _deposit, open_block_number: open_block_number});

    }



    /// @dev Updates internal balance Structures when the sender adds tokens to the channel.

    /// @param _client_address The address that sends tokens.

    /// @param _agent_address The address that receives tokens.

    /// @param _open_block_number The block number at which a channel between the

    /// sender and receiver was created.

    /// @param _offering_hash Service Offering hash that uniquely identifies it.

    /// @param _added_deposit The added token deposit with which the current deposit is increased.

    function updateInternalBalanceStructs(

        address _client_address,

        address _agent_address,

        uint32 _open_block_number,

        bytes32 _offering_hash,

        uint64 _added_deposit)

        private

    {

        require(_added_deposit > 0);

        require(_open_block_number > 0);



        bytes32 key = getKey(_client_address, _agent_address, _open_block_number, _offering_hash);



        require(channels[key].deposit > 0);

        require(closing_requests[key].settle_block_number == 0);

        require(channels[key].deposit + _added_deposit <= channel_deposit_bugbounty_limit);



        channels[key].deposit += _added_deposit;

        assert(channels[key].deposit > _added_deposit);



        emit LogChannelToppedUp(_agent_address, _client_address, _offering_hash, _open_block_number, _added_deposit); // test E2

    }



    /// @dev Deletes the channel and settles by transferring the balance to the Agent

    /// and the rest of the deposit back to the Client.

    /// @param _client_address The address of Client that sends tokens.

    /// @param _agent_address The address of Agent that receives tokens.

    /// @param _open_block_number The block number at which a channel between the

    /// sender and receiver was created.

    /// @param _offering_hash Service Offering hash that uniquely identifies it.

    /// @param _balance The amount of tokens owed by the sender to the receiver.

    function settleChannel(

        address _client_address,

        address _agent_address,

        uint32 _open_block_number,

        bytes32 _offering_hash,

        uint64 _balance)

        private

    {

        bytes32 key = getKey(_client_address, _agent_address, _open_block_number, _offering_hash);

        Channel memory channel = channels[key];



        require(channel.open_block_number > 0);

        require(_balance <= channel.deposit);



        // Remove closed channel structures

        // channel.open_block_number will become 0

        delete channels[key];

        delete closing_requests[key];



        require(increaseOfferingSupply(_agent_address, _offering_hash));

        // Send _balance to the receiver, as it is always <= deposit

        uint64 fee = 0;

        if(network_fee > 0) {

            fee = (_balance/100000)*network_fee; // it's safe because network_fee can't be more than 10000

            internal_balances[network_fee_address] = internal_balances[network_fee_address].add(fee);

            _balance -= fee;

        }



        internal_balances[_agent_address] = internal_balances[_agent_address].add(_balance);



        // Send deposit - balance back to Client

        internal_balances[_client_address] = internal_balances[_client_address].add(channel.deposit - _balance - fee); // I4 test



    }



    /*

     *  Internal functions

     */



    /// @dev Check if a contract exists.

    /// @param _contract The address of the contract to check for.

    /// @return True if a contract exists, false otherwise

    function addressHasCode(address _contract) private view returns (bool) {

        uint size;

        assembly {

            size := extcodesize(_contract)

        }



        return size > 0;

    }

}

