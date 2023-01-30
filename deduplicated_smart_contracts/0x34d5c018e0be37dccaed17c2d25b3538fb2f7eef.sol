/**
 *Submitted for verification at Etherscan.io on 2019-07-17
*/

pragma solidity ^0.4.24;

library SafeMath {
    
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
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

contract Ownable {
    address public owner;

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner() { require(msg.sender == owner); _; }
}

contract MultiTransfer is Ownable {
    using SafeMath for uint256;
    
    event Transacted(
        address msgSender, // 트랜잭션을 시작한 메시지의 발신자 주소
        address toAddress, // 트랜잭션이 전송된 주소
        uint value // 주소로 보낸 Wei 금액
    );

/**
* @param _to 대상 주소
* @param _amount 전송할 wei의 양
*/
  function multiTransfer(address[] _to, uint256[] _amount) public payable onlyOwner returns (bool) {
    require(_to.length == _amount.length);

    uint256 ui;
    uint256 amountSum = 0;

    for (ui = 0; ui < _to.length; ui++) {
        require(_to[ui] != address(0));
        amountSum = amountSum.add(_amount[ui]);
    }

    require(amountSum <= msg.value);

    for (ui = 0; ui < _to.length; ui++) {
        _to[ui].transfer(_amount[ui]);
        emit Transacted(msg.sender, _to[ui], _amount[ui]);
    }

    return true;
  }
}