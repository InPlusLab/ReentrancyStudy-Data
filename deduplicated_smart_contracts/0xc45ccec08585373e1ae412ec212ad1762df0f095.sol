/**

 *Submitted for verification at Etherscan.io on 2018-10-19

*/



pragma solidity ^0.4.25;

/****

This is an interesting project. 

&#x5C0F;&#x8D4C;&#x4F24;&#x795E;&#xFF0C;&#x5927;&#x8D4C;&#x4F24;&#x8D22;

****/





library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a * b;

    assert(a == 0 || c / a == b);

    return c;

  }



  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a / b;

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



contract ETHDice{

    

    using SafeMath for *;

    

    constructor() public {

        nonce = 3000e8;

        owner = msg.sender;

        RandNonce = uint(keccak256(abi.encodePacked(now)));

        RandNonce = RandNonce**10;

    }

    

    address owner = msg.sender;

    bool internal EndPlay = false;

    uint256 StartEth = 0.002 ether;

    uint256 nonce;

    uint256 private RandNonce;

    

    modifier canPlay() {

        require(!EndPlay);

        _;

    }

    

    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }

    

    function finishDistribution() onlyOwner canPlay public returns (bool) {

        EndPlay = true;

        return true;

    }

    function startDistribution() onlyOwner  public returns (bool) {

        EndPlay = false;

        return true;

    }

    

    function () external payable {

            play();

    }  

    

    function isContract(address _addr) private view returns (bool is_contract) {

        uint length;

        assembly {

            //retrieve the size of the code on target address, this needs assembly

            length := extcodesize(_addr)

        }

        return (length > 0);

    }

     

    function play() payable canPlay public {

        if (nonce < 5e8) {

            nonce = 3000e8;

        }

        uint256 etherValue=msg.value;

        address sender = msg.sender;

        require(sender == tx.origin && !isContract(sender));

        address myAddress = this;

        uint256 etherBalance = myAddress.balance;

        if(sender == owner){

            

        }else{

            if(etherValue>StartEth){

                RandNonce = RandNonce.add(nonce);

                uint256 random1 = uint(keccak256(abi.encodePacked(blockhash(RandNonce % 100),RandNonce,sender))) % 10;

                RandNonce = RandNonce.add(random1);

                if(random1 < 5) {

                    etherValue = etherValue.add(etherValue);

                    nonce = nonce.div(100000).mul(99999);

                    if(etherValue <= etherBalance.mul(5).div(100)){

                        msg.sender.transfer(etherValue);

                    }else{

                        etherValue = etherValue.div(2);

                        msg.sender.transfer(etherBalance.mul(5).div(100).add(etherValue));

                    }

                }



            }else{

                msg.sender.transfer(etherValue);

            }

        }

    }

    

    function withdraw() onlyOwner public {

        address myAddress = this;

        uint256 etherBalance = myAddress.balance;

        owner.transfer(etherBalance);

    }

    

    function destroy() onlyOwner public{

        selfdestruct(owner);

    }

    

}