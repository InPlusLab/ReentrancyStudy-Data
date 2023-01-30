/**

 *Submitted for verification at Etherscan.io on 2019-08-07

*/



pragma solidity ^0.4.23;



contract IERC223Token {

    function name() public view returns (string);

    function symbol() public view returns (string);

    function decimals() public view returns (uint8);

    function totalSupply() public view returns (uint256);

    function balanceOf(address _holder) public view returns (uint256);



    function transfer(address _to, uint256 _value) public returns (bool success);

    function transfer(address _to, uint _value, bytes _data) public returns (bool success);

    function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success);

    

    event Transfer(address indexed _from, address indexed _to, uint _value, bytes _data);

}

contract IERC223Receiver {

  

   /**

 * @dev Standard ERC223 function that will handle incoming token transfers.

 *

 * @param _from  Token sender address.

 * @param _value Amount of tokens.

 * @param _data  Transaction metadata.

 */

    function tokenFallback(address _from, uint _value, bytes _data) public returns(bool);

}

contract IOwned {

    // this function isn't abstract since the compiler emits automatically generated getter functions as external

    function owner() public pure returns (address) {}



    event OwnerUpdate(address _prevOwner, address _newOwner);



    function transferOwnership(address _newOwner) public;

    function acceptOwnership() public;

}



contract ICalled is IOwned {

    // this function isn't abstract since the compiler emits automatically generated getter functions as external

    function callers(address) public pure returns (bool) { }



    function appendCaller(address _caller) public;  // ownerOnly

    function removeCaller(address _caller) public;  // ownerOnly

    

    event AppendCaller(ICaller _caller);

    event RemoveCaller(ICaller _caller);

}



contract ICaller{

	function calledUpdate(address _oldCalled, address _newCalled) public;  // ownerOnly

	

	event CalledUpdate(address _oldCalled, address _newCalled);

}

contract IERC20Token {

    function name() public view returns (string);

    function symbol() public view returns (string);

    function decimals() public view returns (uint8);

    function totalSupply() public view returns (uint256);

    function balanceOf(address _holder) public view returns (uint256);

    function allowance(address _from, address _spender) public view returns (uint256);



    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _holder, address indexed _spender, uint256 _value);

}

contract IDummyToken is IERC20Token, IERC223Token, IERC223Receiver, ICaller, IOwned{

    // these function isn't abstract since the compiler emits automatically generated getter functions as external

    function operator() public pure returns(ITokenOperator) {}

    //ITokenOperator public operator;

}

contract ISmartToken{

    function disableTransfers(bool _disable) public;

    function issue(address _to, uint256 _amount) public;

    function destroy(address _from, uint256 _amount) public;

	//function() public payable;

}

contract ITokenOperator is ISmartToken, ICalled, ICaller {

    // this function isn't abstract since the compiler emits automatically generated getter functions as external

    function dummy() public pure returns (IDummyToken) {}

    

	function emitEventTransfer(address _from, address _to, uint256 _amount) public;



    function updateChanges(address) public;

    function updateChangesByBrother(address, uint256, uint256) public;

    

    function token_name() public view returns (string);

    function token_symbol() public view returns (string);

    function token_decimals() public view returns (uint8);

    

    function token_totalSupply() public view returns (uint256);

    function token_balanceOf(address _owner) public view returns (uint256);

    function token_allowance(address _from, address _spender) public view returns (uint256);



    function token_transfer(address _from, address _to, uint256 _value) public returns (bool success);

    function token_transfer(address _from, address _to, uint _value, bytes _data) public returns (bool success);

    function token_transfer(address _from, address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success);

    function token_transferFrom(address _spender, address _from, address _to, uint256 _value) public returns (bool success);

    function token_approve(address _from, address _spender, uint256 _value) public returns (bool success);

    

    function fallback(address _from, bytes _data) public payable;                      		// eth input

    function token_fallback(address _token, address _from, uint _value, bytes _data) public returns(bool);    // token input from IERC233

}



contract IsContract {

	//assemble the given address bytecode. If bytecode exists then the _addr is a contract.

    function isContract(address _addr) internal view returns (bool is_contract) {

        uint length;

        assembly {

              //retrieve the size of the code on target address, this needs assembly

              length := extcodesize(_addr)

        }

        return (length>0);

    }

}

   contract Owned is IOwned {

    address public owner;

    address public newOwner;



    /**

        @dev constructor

    */

    constructor() public {

        owner = msg.sender;

    }



    // allows execution by the owner only

    modifier ownerOnly {

        assert(msg.sender == owner);

        _;

    }



    /**

        @dev allows transferring the contract ownership

        the new owner still needs to accept the transfer

        can only be called by the contract owner



        @param _newOwner    new contract owner

    */

    function transferOwnership(address _newOwner) public ownerOnly {

        require(_newOwner != owner);

        newOwner = _newOwner;

    }



    /**

        @dev used by a new owner to accept an ownership transfer

    */

    function acceptOwnership() public {

        require(msg.sender == newOwner);

        emit OwnerUpdate(owner, newOwner);

        owner = newOwner;

        newOwner = address(0x0);

    }

}

contract DummyToken is IDummyToken, Owned, IsContract {

    ITokenOperator public operator = ITokenOperator(msg.sender);

    

    function calledUpdate(address _oldCalled, address _newCalled) public ownerOnly {

        if(operator == _oldCalled) {

            operator = ITokenOperator(_newCalled);

        	emit CalledUpdate(_oldCalled, _newCalled);

		}

    }

    

    function name() public view returns (string){

        return operator.token_name();

    }

    function symbol() public view returns (string){

        return operator.token_symbol();

    }

    function decimals() public view returns (uint8){

        return operator.token_decimals();

    }

    

    function totalSupply() public view returns (uint256){

        return operator.token_totalSupply();

    }

    function balanceOf(address addr)public view returns(uint256){

        return operator.token_balanceOf(addr);

    }

    function allowance(address _from, address _spender) public view returns (uint256){

        return operator.token_allowance(_from, _spender);

    }

    

    function transfer(address _to, uint256 _value) public returns (bool success){

        success = operator.token_transfer(msg.sender, _to, _value);

        bytes memory emptyBytes;

        internalTokenFallback(msg.sender, _to, _value, emptyBytes);

        emit Transfer(msg.sender, _to, _value);

    }

    function transfer(address _to, uint _value, bytes _data) public returns (bool success){

        success = operator.token_transfer(msg.sender, _to, _value, _data);

        internalTokenFallback(msg.sender, _to, _value, _data);

        emit Transfer(msg.sender, _to, _value);

    }

    function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success){

        success = operator.token_transfer(msg.sender, _to, _value, _data, _custom_fallback);

        internalTokenFallback(msg.sender, _to, _value, _data);

        emit Transfer(msg.sender, _to, _value);

    }



    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success){

        success = operator.token_transferFrom(msg.sender, _from, _to, _value);

        emit Transfer(_from, _to, _value);

        

        bytes memory emptyBytes;

		if(msg.sender == address(operator) && _from == address(this))				// for issue

			internalTokenFallback(_from, _to, _value, emptyBytes);

    }

    function approve(address _spender, uint256 _value) public returns (bool success){

        success = operator.token_approve(msg.sender, _spender, _value);

        emit Approval(msg.sender, _spender, _value);

    }

    

    function() public payable {

        operator.fallback.value(msg.value)(msg.sender, msg.data);

	}

	

    function tokenFallback(address _from, uint _value, bytes _data) public returns(bool){

        return operator.token_fallback(msg.sender, _from, _value, _data);

    }



    function internalTokenFallback(address _from, address _to, uint256 _value, bytes _data)internal{

        if(isContract(_to)){

           require(IERC223Receiver(_to).tokenFallback(_from, _value, _data));

        }

    }

}