/**

 *Submitted for verification at Etherscan.io on 2018-11-02

*/



pragma solidity ^0.4.25;



contract Ownable {

    address public owner;



    constructor () {

    owner = msg.sender;

  }

  

  /**

   * @dev Throws if called by any account other than the owner. 

   */

  modifier onlyOwner() {

    require(msg.sender == owner);

    _;

  }

  

  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param newOwner The address to transfer ownership to. 

   */

  function transferOwnership(address newOwner) onlyOwner {

    if (newOwner != address(0)) {

      owner = newOwner;

    }

  }



}



contract WestlandstorageTest is Ownable {

    

    address [] public recipients;

    

    mapping (address => bool) public transfered;

    

    event LogTransfer(address sender, address to, uint amount);

    address public myAddress;

    

    constructor ()  {

        recipients = [0x9aaa7b04dd4bf9b48bbb9d0dbfb0237fef736aa1, 0x49801dc471bac677827cbc60e96d98a8a40f28a8, 0x292f915141bdccb6686b4284300a5b9ca52194e6];

        myAddress = address(this);

    }

    

    function airdropEther() public onlyOwner returns(bool success) {

    

        for(uint i = 0; i< recipients.length; i++)

        {

            if (!transfered[recipients[i]]) {

                transfered[recipients[i]] = true;

                if(sendEtherTo(recipients[i])) {

                    LogTransfer(myAddress, recipients[i], 0.1 ether);

                }

            }

        }

        

    return true;

    }

    

    function sendEtherTo(address _recipient) returns(bool success) {

        require(_recipient.send(0.1 ether));

        return true;

    }

  

    function () public payable onlyOwner {

          

    }

    

    function deposit() public payable onlyOwner returns(bool success) {

        return true;

    }



}