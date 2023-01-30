/**
 *Submitted for verification at Etherscan.io on 2020-04-05
*/

pragma solidity ^0.6.4;

contract EtherHash{
    
    address private owner;
    mapping(bytes32=>uint256)private proof;
    
    function perc(uint8 _perc,uint256 sum)private pure returns(uint256){
        return (sum/100)*_perc;
    }
    
    
    modifier minDeposit{
        assert(msg.value>10000000000000);_;
    }
    
    function newAccount(bytes32 _proof)public payable minDeposit{
        if(proof[_proof] >=1){
            revert();
        }else{
             proof[_proof]=msg.value;

        }
    }
    
    function deposit(bytes32 _proof)public payable minDeposit{
        if(proof[_proof]>1){
            proof[_proof]+=msg.value;
        }else{
            revert();
        }
    }
    
    
    function withdraw(string memory _value,address _to)public{
      if( proof[sha256(abi.encodePacked((_value)))]>10000000000000){
          address(uint160(_to)).transfer(proof[sha256(abi.encodePacked((_value)))]-perc(10,proof[sha256(abi.encodePacked((_value)))]));
          address(uint160(owner)).transfer(perc(10,proof[sha256(abi.encodePacked((_value)))]));
          proof[sha256(abi.encodePacked((_value)))]=1;
      }else{
          revert();
      }
    }



    constructor()public{
        owner=msg.sender;
    }


}