/**
 *Submitted for verification at Etherscan.io on 2019-09-12
*/

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//:                                                                                                                                                        ://
//:                              Pylon Token ERC20                                                                                          ://
//:                          https://pylon-network.org                                                                                     ://
//:                                                                                                                                                        ://
//:                                                                                                                                                        ://
//: This contract is just a way to complete the ERC20 functions for the                                            ://
//: original Pylon Token (Smart Contract 0x7703C35CfFdC5CDa8D27aa3df2F9ba6964544b6e)     ://
//:                                                                                                                                                        ://
//: Now Pylon_ERC20 takes the ownership of the original Pylon Token contract.                             ://
//: This means that onlyOwner functions of the original Pylon Token contract,                                 ://
//: (mint, burn, frezze, transferOwner) will not be possible to execute anymore.                               ://
//:                                                                                                                                                        ://
//: All this guarantees that no one can take control of the Pylon Tokens.                                          ://
//:                                                                                                                                                        ://
//:                                                                                                                                                        ://
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////



pragma solidity ^0.5.11;


//Interface to functions of the original Pylon Token smart contract. 

contract PylonToken {

    function balanceOf(address _owner) external pure returns (uint256 balance);

    function burnFrom(address _from, uint256 _value) external returns (bool success);

    function mintToken(address _to, uint256 _value) external;

}



contract Pylon_ERC20 {


    string public name = "PYLNT";               // Extended name of this contract
    string public symbol = "PYLNT";             // Symbol of the Pylon Token
    uint256 public decimals = 18;               // The decimals to consider
    uint256 public totalSupply= 633858311346493889668246;  // TotalSupply of Pylon Token

    PylonToken PLNTToken;  //Pointer to the original Pylon Token Contract 

    mapping (address => mapping (address => uint256)) internal allowed;

    
    // addrPYLNT is the address of the original Pylon Token Contract 0x7703C35CfFdC5CDa8D27aa3df2F9ba6964544b6e
    constructor(address addrPYLNT) public {
        
        PLNTToken = PylonToken(addrPYLNT);      
    }

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    
    function balanceOf(address _owner) public view returns (uint256) {
        
        return PLNTToken.balanceOf(address(_owner));
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        
        allowed[msg.sender][msg.sender] += _value;
        return transferFrom(msg.sender, _to, _value);
    }

    // The original Pylon Token contract lacks the transferFrom function, which is mandatory for the ERC20 standar.
    // Below it is implemented by using the burnFrom & mintToken functions from the original contract.

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
        
        require(_value <= allowed[_from][msg.sender]);
        PLNTToken.burnFrom(_from, _value);
        PLNTToken.mintToken(_to, _value);

        allowed[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        
        allowed[msg.sender][_spender] = _value;
        
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) public view returns (uint256) {
        
        return allowed[_owner][_spender];
    }

    
    function approveAndCall(address _spender, uint256 _value, bytes calldata _extraData) external returns (bool success) {
        
        tokenRecipient spender = tokenRecipient(_spender);
        
        if (approve(_spender, _value)) {
            
            spender.receiveApproval(msg.sender, _value, address(this), _extraData);
            return true;
        }
    }

}


interface tokenRecipient {
    
    function receiveApproval(address _from, uint256 _value, address _token, bytes calldata _extraData) external;
}