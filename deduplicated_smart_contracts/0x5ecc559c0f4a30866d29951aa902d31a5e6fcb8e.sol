/**
 *Submitted for verification at Etherscan.io on 2019-07-18
*/

pragma solidity ^0.4.21;

contract Ownable {
    address public owner;

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() { require(msg.sender == owner); _; }
}

contract MultiTransfer is Ownable {
  event Transacted(
    address msgSender, // 트랜잭션을 시작한 메시지의 발신자 주소
    address toAddress, // 트랜잭션이 전송된 주소
    uint value // 주소로 보낸 Wei 금액
  );

/**
* @param toAddress1 대상 주소
* @param toAddress2 대상 주소
* @param value1 전송할 wei의 양
* @param value2 전송할 wei의 양
*/
  function multiTransfer(
      address toAddress1,
      address toAddress2,
      uint value1,
      uint value2
  ) public payable onlyOwner {
    if (msg.value != value1 + value2) {
        revert();
    }

    toAddress1.transfer(value1);
    toAddress2.transfer(value2);
    
    emit Transacted(msg.sender, toAddress1, value1);
    emit Transacted(msg.sender, toAddress2, value2);
  }
}