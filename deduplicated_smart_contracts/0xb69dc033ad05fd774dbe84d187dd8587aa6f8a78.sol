/**

 *Submitted for verification at Etherscan.io on 2018-11-08

*/



pragma solidity ^0.4.0;



contract BidInterface {

  struct BidMsg {

    address account;

    uint256 stake;

    uint256 gasPrice;

    bytes votePubKey;

  }

  function bid(address account, uint256 stake, uint256 gasPrice, bytes votePubKey) public;

}



// SingleVault is used to stake-in for a committee.

contract SingleVault {

    address owner;

    address operator;

    address cstpc = 0x250;

    address cetpc = 0x251;



    constructor(address ownerAccount) public {

        owner = ownerAccount;

        operator = msg.sender;

    }



    // allow deposits

    function() public payable { }



    modifier isoperator() {

        require(operator == msg.sender);

        _;

    }



    modifier isowner() {

        require(owner == msg.sender);

        _;

    }



    function withdraw(uint amount) external isowner() {

        owner.transfer(amount);

    }



    function reset(address operationalAccount) external isowner() {

      operator = operationalAccount;

    }



    function bid(address account, uint256 stake, uint256 gasPrice, bytes votePubKey) external isoperator() {

        BidInterface(cstpc).bid(account, stake, gasPrice, votePubKey);

    }

}



contract Proxy {

    address public owner;

    address public operator;

    mapping(address=>bool) public children;

    

    address[] public vaults;

    

    constructor(address ownerAccount) public {

        owner = ownerAccount;

        operator = msg.sender;

    }



    // allow deposits

    function() public payable { }



    modifier isoperator() {

        require(operator == msg.sender);

        _;

    }



    modifier isowner() {

        require(owner == msg.sender);

        _;

    }



    function withdraw(uint amount) external isowner() {

        owner.transfer(amount);

    }



    function reset(address operationalAccount) external isowner() {

        operator = operationalAccount;

    }



    function create() external isoperator() {

        SingleVault child = new SingleVault(this);

        children[child] = true;

    }



    function fund(address child, uint amount) external isoperator() {

        require(children[child]);

        child.transfer(amount);    

    }



    function refund(address child, uint amount) external isoperator() {

        require(children[child]);

        SingleVault(child).withdraw(amount);

    }

}