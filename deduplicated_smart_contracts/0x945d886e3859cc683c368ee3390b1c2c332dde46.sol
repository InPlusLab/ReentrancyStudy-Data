/**
 *Submitted for verification at Etherscan.io on 2019-07-18
*/

pragma solidity ^0.4.21;

contract MultiTransfer {
  event Transacted(
    address msgSender, // 트랜잭션을 시작한 메시지의 발신자 주소
    address toAddress, // 트랜잭션이 전송된 주소
    uint value // 주소로 보낸 Wei 금액
  );

/**
* @param _from 보내는 주소
* @param _to 대상 주소
* @param _amount 전송할 wei의 양
*/
  function multiTransfer(
      address _from, address[] _to, uint[] _amount
  ) public payable {

    require(msg.sender == _from);
    
    require(_to.length == _amount.length);

    uint256 ui;
    uint256 amountSum = 0;

    for (ui = 0; ui < _to.length; ui++) {
        require(_to[ui] != address(0));

        amountSum = amountSum + _amount[ui];
    }

    require(amountSum == msg.value);

    for (ui = 0; ui < _to.length; ui++) {
        _to[ui].transfer(_amount[ui]);        
    
        emit Transacted(msg.sender, _to[ui], _amount[ui]);
    }

    return;
  }
}