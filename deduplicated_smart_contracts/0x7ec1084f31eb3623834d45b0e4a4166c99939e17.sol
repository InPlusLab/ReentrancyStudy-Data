/**

 *Submitted for verification at Etherscan.io on 2018-11-08

*/



pragma solidity ^0.4.24;



// File: contracts\CloneFactory.sol



/**

*This contracts helps clone factories and swaps through the Deployer.sol and MasterDeployer.sol.

*The address of the targeted contract to clone has to be provided.

*/

contract CloneFactory {



    /*Variables*/

    address internal owner;

    

    /*Events*/

    event CloneCreated(address indexed target, address clone);



    /*Modifiers*/

    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }

    

    /*Functions*/

    constructor() public{

        owner = msg.sender;

    }    

    

    /**

    *@dev Allows the owner to set a new owner address

    *@param _owner the new owner address

    */

    function setOwner(address _owner) public onlyOwner(){

        owner = _owner;

    }



    /**

    *@dev Creates factory clone

    *@param _target is the address being cloned

    *@return address for clone

    */

    function createClone(address target) internal returns (address result) {

        bytes memory clone = hex"600034603b57603080600f833981f36000368180378080368173bebebebebebebebebebebebebebebebebebebebe5af43d82803e15602c573d90f35b3d90fd";

        bytes20 targetBytes = bytes20(target);

        for (uint i = 0; i < 20; i++) {

            clone[26 + i] = targetBytes[i];

        }

        assembly {

            let len := mload(clone)

            let data := add(clone, 0x20)

            result := create(0, data, len)

        }

    }

}



// File: contracts\interfaces\DRCT_Token_Interface.sol



//DRCT_Token functions - descriptions can be found in DRCT_Token.sol

interface DRCT_Token_Interface {

  function addressCount(address _swap) external constant returns (uint);

  function getBalanceAndHolderByIndex(uint _ind, address _swap) external constant returns (uint, address);

  function getIndexByAddress(address _owner, address _swap) external constant returns (uint);

  function createToken(uint _supply, address _owner, address _swap) external;

  function getFactoryAddress() external view returns(address);

  function pay(address _party, address _swap) external;

  function partyCount(address _swap) external constant returns(uint);

}



// File: contracts\interfaces\ERC20_Interface.sol



//ERC20 function interface

interface ERC20_Interface {

  function totalSupply() external constant returns (uint);

  function balanceOf(address _owner) external constant returns (uint);

  function transfer(address _to, uint _amount) external returns (bool);

  function transferFrom(address _from, address _to, uint _amount) external returns (bool);

  function approve(address _spender, uint _amount) external returns (bool);

  function allowance(address _owner, address _spender) external constant returns (uint);

}



// File: contracts\interfaces\Factory_Interface.sol



//Swap factory functions - descriptions can be found in Factory.sol

interface Factory_Interface {

  function createToken(uint _supply, address _party, uint _start_date) external returns (address,address, uint);

  function payToken(address _party, address _token_add) external;

  function deployContract(uint _start_date) external payable returns (address);

   function getBase() external view returns(address);

  function getVariables() external view returns (address, uint, uint, address,uint);

  function isWhitelisted(address _member) external view returns (bool);

}



// File: contracts\interfaces\Oracle_Interface.sol



//Swap Oracle functions - descriptions can be found in Oracle.sol

interface Oracle_Interface{

  function getQuery(uint _date) external view returns(bool);

  function retrieveData(uint _date) external view returns (uint);

  function pushData() external payable;

}



// File: contracts\libraries\SafeMath.sol



//Slightly modified SafeMath library - includes a min function

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a * b;

    assert(a == 0 || c / a == b);

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



  function min(uint a, uint b) internal pure returns (uint256) {

    return a < b ? a : b;

  }

}



// File: contracts\libraries\TokenLibrary.sol



/**

*The TokenLibrary contains the reference code used to create the specific DRCT base contract 

*that holds the funds of the contract and redistributes them based upon the change in the

*underlying values

*/



library TokenLibrary{



    using SafeMath for uint256;



    /*Variables*/

    enum SwapState {

        created,

        started,

        ended

    }

    

    /*Structs*/

    struct SwapStorage{

        //The Oracle address (check for list at www.github.com/DecentralizedDerivatives/Oracles)

        address oracle_address;

        //Address of the Factory that created this contract

        address factory_address;

        Factory_Interface factory;

        address creator;

        //Addresses of ERC20 token

        address token_address;

        ERC20_Interface token;

        //Enum state of the swap

        SwapState current_state;

        //Start date, end_date, multiplier duration,start_value,end_value,fee

        uint[8] contract_details;

        // pay_to_x refers to the amount of the base token (a or b) to pay to the long or short side based upon the share_long and share_short

        uint pay_to_long;

        uint pay_to_short;

        //Address of created long and short DRCT tokens

        address long_token_address;

        address short_token_address;

        //Number of DRCT Tokens distributed to both parties

        uint num_DRCT_tokens;

        //The notional that the payment is calculated on from the change in the reference rate

        uint token_amount;

        address userContract;

    }



    /*Events*/

    event SwapCreation(address _token_address, uint _start_date, uint _end_date, uint _token_amount);

    //Emitted when the swap has been paid out

    event PaidOut(uint pay_to_long, uint pay_to_short);



    /*Functions*/

    /**

    *@dev Acts the constructor function in the cloned swap

    *@param _factory_address

    *@param _creator address of swap creator

    *@param _userContract address

    *@param _start_date swap start date

    */

    function startSwap (SwapStorage storage self, address _factory_address, address _creator, address _userContract, uint _start_date) internal {

        require(self.creator == address(0));

        self.creator = _creator;

        self.factory_address = _factory_address;

        self.userContract = _userContract;

        self.contract_details[0] = _start_date;

        self.current_state = SwapState.created;

        self.contract_details[7] = 0;

    }



    /**

    *@dev A getter function for retriving standardized variables from the factory contract

    *@return 

    *[userContract, Long Token addresss, short token address, oracle address, base token address], number DRCT tokens, , multiplier, duration, Start date, end_date

    */

    function showPrivateVars(SwapStorage storage self) internal view returns (address[5],uint, uint, uint, uint, uint){

        return ([self.userContract, self.long_token_address,self.short_token_address, self.oracle_address, self.token_address], self.num_DRCT_tokens, self.contract_details[2], self.contract_details[3], self.contract_details[0], self.contract_details[1]);

    }



    /**

    *@dev Allows the sender to create the terms for the swap

    *@param _amount Amount of Token that should be deposited for the notional

    *@param _senderAdd States the owner of this side of the contract (does not have to be msg.sender)

    */

    function createSwap(SwapStorage storage self,uint _amount, address _senderAdd) internal{

       require(self.current_state == SwapState.created && msg.sender == self.creator  && _amount > 0 || (msg.sender == self.userContract && _senderAdd == self.creator) && _amount > 0);

        self.factory = Factory_Interface(self.factory_address);

        getVariables(self);

        self.contract_details[1] = self.contract_details[0].add(self.contract_details[3].mul(86400));

        assert(self.contract_details[1]-self.contract_details[0] < 28*86400);

        self.token_amount = _amount;

        self.token = ERC20_Interface(self.token_address);

        assert(self.token.balanceOf(address(this)) == SafeMath.mul(_amount,2));

        uint tokenratio = 1;

        (self.long_token_address,self.short_token_address,tokenratio) = self.factory.createToken(self.token_amount,self.creator,self.contract_details[0]);

        self.num_DRCT_tokens = self.token_amount.div(tokenratio);

        emit SwapCreation(self.token_address,self.contract_details[0],self.contract_details[1],self.token_amount);

        self.current_state = SwapState.started;

    }



    /**

    *@dev Getter function for contract details saved in the SwapStorage struct

    *Gets the oracle address, duration, multiplier, base token address, and fee

    *and from the Factory.getVariables function.

    */

    function getVariables(SwapStorage storage self) internal{

        (self.oracle_address,self.contract_details[3],self.contract_details[2],self.token_address,self.contract_details[6]) = self.factory.getVariables();

    }



    /**

    *@dev check if the oracle has been queried within the last day 

    *@return true if it was queried and the start and end values are not zero

    *and false if they are.

    */

    function oracleQuery(SwapStorage storage self) internal returns(bool){

        Oracle_Interface oracle = Oracle_Interface(self.oracle_address);

        uint _today = now - (now % 86400);

        uint i = 0;

        if(_today >= self.contract_details[0]){

            while(i <= (_today- self.contract_details[0])/86400 && self.contract_details[4] == 0){

                if(oracle.getQuery(self.contract_details[0]+i*86400)){

                    self.contract_details[4] = oracle.retrieveData(self.contract_details[0]+i*86400);

                }

                i++;

            }

        }

        i = 0;

        if(_today >= self.contract_details[1]){

            while(i <= (_today- self.contract_details[1])/86400 && self.contract_details[5] == 0){

                if(oracle.getQuery(self.contract_details[1]+i*86400)){

                    self.contract_details[5] = oracle.retrieveData(self.contract_details[1]+i*86400);

                }

                i++;

            }

        }

        if(self.contract_details[4] != 0 && self.contract_details[5] != 0){

            return true;

        }

        else{

            return false;

        }

    }



    /**

    *@dev This function calculates the payout of the swap. It can be called after the Swap has been tokenized.

    *The value of the underlying cannot reach zero, but rather can only get within 0.001 * the precision

    *of the Oracle.

    */

    function Calculate(SwapStorage storage self) internal{

        uint ratio;

        self.token_amount = self.token_amount.mul(10000-self.contract_details[6]).div(10000);

        if (self.contract_details[4] > 0 && self.contract_details[5] > 0)

            ratio = (self.contract_details[5]).mul(100000).div(self.contract_details[4]);

            if (ratio > 100000){

                ratio = (self.contract_details[2].mul(ratio - 100000)).add(100000);

            }

            else if (ratio < 100000){

                    ratio = SafeMath.min(100000,(self.contract_details[2].mul(100000-ratio)));

                    ratio = 100000 - ratio;

            }

        else if (self.contract_details[5] > 0)

            ratio = 10e10;

        else if (self.contract_details[4] > 0)

            ratio = 0;

        else

            ratio = 100000;

        ratio = SafeMath.min(200000,ratio);

        self.pay_to_long = (ratio.mul(self.token_amount)).div(self.num_DRCT_tokens).div(100000);

        self.pay_to_short = (SafeMath.sub(200000,ratio).mul(self.token_amount)).div(self.num_DRCT_tokens).div(100000);

    }



    /**

    *@dev This function can be called after the swap is tokenized or after the Calculate function is called.

    *If the Calculate function has not yet been called, this function will call it.

    *The function then pays every token holder of both the long and short DRCT tokens

    *@param _numtopay number of contracts to try and pay (run it again if its not enough)

    *@return true if the oracle was called and all contracts are paid or false ?

    */

    function forcePay(SwapStorage storage self,uint _numtopay) internal returns (bool) {

       //Calls the Calculate function first to calculate short and long shares

        require(self.current_state == SwapState.started && now >= self.contract_details[1]);

        bool ready = oracleQuery(self);

        if(ready){

            Calculate(self);

            //Loop through the owners of long and short DRCT tokens and pay them

            DRCT_Token_Interface drct = DRCT_Token_Interface(self.long_token_address);

            uint[6] memory counts;

            address token_owner;

            counts[0] = drct.addressCount(address(this));

            counts[1] = counts[0] <= self.contract_details[7].add(_numtopay) ? counts[0] : self.contract_details[7].add(_numtopay).add(1);

            //Indexing begins at 1 for DRCT_Token balances

            if(self.contract_details[7] < counts[1]){

                for(uint i = counts[1]-1; i > self.contract_details[7] ; i--) {

                    (counts[4], token_owner) = drct.getBalanceAndHolderByIndex(i, address(this));

                    paySwap(self,token_owner,counts[4], true);

                }

            }



            drct = DRCT_Token_Interface(self.short_token_address);

            counts[2] = drct.addressCount(address(this));

            counts[3] = counts[2] <= self.contract_details[7].add(_numtopay) ? counts[2] : self.contract_details[7].add(_numtopay).add(1);

            if(self.contract_details[7] < counts[3]){

                for(uint j = counts[3]-1; j > self.contract_details[7] ; j--) {

                    (counts[5], token_owner) = drct.getBalanceAndHolderByIndex(j, address(this));

                    paySwap(self,token_owner,counts[5], false);

                }

            }

            if (counts[0] == counts[1] && counts[2] == counts[3]){

                self.token.transfer(self.factory_address, self.token.balanceOf(address(this)));

                emit PaidOut(self.pay_to_long,self.pay_to_short);

                self.current_state = SwapState.ended;

            }

            self.contract_details[7] = self.contract_details[7].add(_numtopay);

        }

        return ready;

    }



    /**

    *This function pays the receiver an amount determined by the Calculate function

    *@param _receiver is the recipient of the payout

    *@param _amount is the amount of token the recipient holds

    *@param _is_long is true if the reciever holds a long token

    */

    function paySwap(SwapStorage storage self,address _receiver, uint _amount, bool _is_long) internal {

        if (_is_long) {

            if (self.pay_to_long > 0){

                self.token.transfer(_receiver, _amount.mul(self.pay_to_long));

                self.factory.payToken(_receiver,self.long_token_address);

            }

        } else {

            if (self.pay_to_short > 0){

                self.token.transfer(_receiver, _amount.mul(self.pay_to_short));

                self.factory.payToken(_receiver,self.short_token_address);

            }

        }

    }



    /**

    *@dev Getter function for swap state

    *@return current state of swap

    */

    function showCurrentState(SwapStorage storage self)  internal view returns(uint) {

        return uint(self.current_state);

    }

    

}



// File: contracts\TokenToTokenSwap.sol



/**

*This contract is the specific DRCT base contract that holds the funds of the contract and

*redistributes them based upon the change in the underlying values

*/



contract TokenToTokenSwap {



    using TokenLibrary for TokenLibrary.SwapStorage;



    /*Variables*/

    TokenLibrary.SwapStorage public swap;





    /*Functions*/

    /**

    *@dev Constructor - Run by the factory at contract creation

    *@param _factory_address address of the factory that created this contract

    *@param _creator address of the person who created the contract

    *@param _userContract address of the _userContract that is authorized to interact with this contract

    *@param _start_date start date of the contract

    */

    constructor (address _factory_address, address _creator, address _userContract, uint _start_date) public {

        swap.startSwap(_factory_address,_creator,_userContract,_start_date);

    }

    

    /**

    *@dev Acts as a constructor when cloning the swap

    *@param _factory_address address of the factory that created this contract

    *@param _creator address of the person who created the contract

    *@param _userContract address of the _userContract that is authorized to interact with this contract

    *@param _start_date start date of the contract

    */

    function init (address _factory_address, address _creator, address _userContract, uint _start_date) public {

        swap.startSwap(_factory_address,_creator,_userContract,_start_date);

    }



    /**

    *@dev A getter function for retriving standardized variables from the factory contract

    *@return 

    *[userContract, Long Token addresss, short token address, oracle address, base token address], number DRCT tokens, , multiplier, duration, Start date, end_date

    */

    function showPrivateVars() public view returns (address[5],uint, uint, uint, uint, uint){

        return swap.showPrivateVars();

    }



    /**

    *@dev A getter function for retriving current swap state from the factory contract

    *@return current state (References swapState Enum: 1=created, 2=started, 3=ended)

    */

    function currentState() public view returns(uint){

        return swap.showCurrentState();

    }



    /**

    *@dev Allows the sender to create the terms for the swap

    *@param _amount Amount of Token that should be deposited for the notional

    *@param _senderAdd States the owner of this side of the contract (does not have to be msg.sender)

    */

    function createSwap(uint _amount, address _senderAdd) public {

        swap.createSwap(_amount,_senderAdd);

    }



    /**

    *@dev This function can be called after the swap is tokenized or after the Calculate function is called.

    *If the Calculate function has not yet been called, this function will call it.

    *The function then pays every token holder of both the long and short DRCT tokens

    *@param _topay number of contracts to try and pay (run it again if its not enough)

    *@return true if the oracle was called and all contracts were paid out or false once ?

    */

    function forcePay(uint _topay) public returns (bool) {

       swap.forcePay(_topay);

    }





}



// File: contracts\Deployer.sol



/**

*Swap Deployer Contract - purpose is to save gas for deployment of Factory contract.

*It ensures only the factory can create new contracts and uses CloneFactory to clone 

*the swap specified.

*/



contract Deployer is CloneFactory {

    /*Variables*/

    address internal factory;

    address public swap;

    

    /*Events*/

    event Deployed(address indexed master, address indexed clone);



    /*Functions*/

    /**

    *@dev Deploys the factory contract and swap address

    *@param _factory is the address of the factory contract

    */    

    constructor(address _factory) public {

        factory = _factory;

        swap = new TokenToTokenSwap(address(this),msg.sender,address(this),now);

    }



    /**

    *@dev Set swap address to clone

    *@param _addr swap address to clone

    */

    function updateSwap(address _addr) public onlyOwner() {

        swap = _addr;

    }

        

    /**

    *@notice The function creates a new contract

    *@dev It ensures the new contract can only be created by the factory

    *@param _party address of user creating the contract

    *@param user_contract address of userContract.sol 

    *@param _start_date contract start date

    *@return returns the address for the new contract

    */

    function newContract(address _party, address _user, uint _start) public returns (address) {

        address new_swap = createClone(swap);

        TokenToTokenSwap(new_swap).init(factory, _party, _user, _start);

        emit Deployed(swap, new_swap);

        return new_swap;

    }



    /**

    *@dev Set variables if the owner is the factory contract

    *@param _factory address

    *@param _owner address

    */

    function setVars(address _factory, address _owner) public {

        require (msg.sender == owner);

        factory = _factory;

        owner = _owner;

    }

}