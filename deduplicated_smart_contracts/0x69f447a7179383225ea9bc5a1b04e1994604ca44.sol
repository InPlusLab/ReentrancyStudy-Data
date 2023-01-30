pragma solidity ^0.4.21;
import "./ERC20Interface.sol";

contract MultiTransfer {
  event Deposited(address from, uint value, bytes data);
  event Transacted(
    address msgSender, // 트랜잭션을 시작한 메시지의 발신자 주소
    address toAddress, // 트랜잭션이 전송된 주소
    uint value // 주소로 보낸 Wei 금액
  );

/**
* 메서드를 호출하지 않고 트랜잭션을 받으면 호출됩니다.
*/
  function() public payable {
    if (msg.value > 0) {
      emit Deposited(msg.sender, msg.value, msg.data);
    }
  }

/**
* @param toAddress1 대상 주소
* @param toAddress2 대상 주소
* @param value1 전송할 웨이의 양
* @param value2 전송할 웨이의 양
*/
  function multiTransferETH(
      address fromAddress,
      address toAddress1,
      address toAddress2,
      uint value1,
      uint value2
  ) public payable {
    if (msg.sender != fromAddress) {
        revert();
    }

    if (msg.value != value1 + value2) {
        revert();
    }

    toAddress1.transfer(value1);
    toAddress2.transfer(value2);
    
    emit Transacted(msg.sender, toAddress1, value1);
    emit Transacted(msg.sender, toAddress2, value2);
  }
  
/**
* @param toAddress1 대상 주소
* @param toAddress2 대상 주소
* @param value1 전송할 웨이의 양
* @param value2 전송할 웨이의 양
* @param tokenContractAddress erc20 토큰 계약의 주소
*/
  function multiTransferToken(
      address fromAddress,
      address toAddress1,
      address toAddress2,
      uint value1,
      uint value2,
      address tokenContractAddress
  ) public payable {
    ERC20Interface instance = ERC20Interface(tokenContractAddress);

    instance.approve(fromAddress, value1 + value2); // 토큰 전송 허가

    instance.transferFrom(fromAddress, toAddress1, value1);
    instance.transferFrom(fromAddress, toAddress2, value2);
    
    emit Transacted(fromAddress, toAddress1, value1);
    emit Transacted(fromAddress, toAddress2, value2);
  }
  
}
