/**

 *Submitted for verification at Etherscan.io on 2018-11-16

*/



pragma solidity ^0.4.11;



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



contract SKWLock3Token {

    

    using SafeMath for uint256;

    

    address operatorAddress = 0x0;//操作地址

    

    address lockAddress = 0x0;//锁定地址

    

    uint256 public lockBalcnce;//锁定数量

    

    uint public lockDay;//锁定天数

    

    uint256 public unBalcnce;//解锁数量

    

    uint256 public unLockTime_1;

    

    uint256 public unLockTime_2;

    

    uint256 public unLockTime_3;

    

    uint256 public unLockTime_4;

    

    uint256 public unLockTime_5;

    

    uint256 public unLockTime_6;

    

    uint256 public put_balance;//已经提现数量



    event UnLock(address indexed _address, uint256 _value);

    

    event PutBalance(address indexed _address, uint256 _value);

    

    constructor() public {

       operatorAddress = 0x091A9bb16286C8772a6309e8B303EC4F1e03Ff57;

       lockAddress = 0x5CcB3AD9Cc3dcc7D8Bda0F1BF21f273F498F645A;

       lockBalcnce = 5000000000000000;// 50000000.00000000 8个0

       unLockTime_1 = 1543075200;//2018-11-25 00:00:00

       unLockTime_2 = 1545667200;//2018-12-25 00:00:00

       unLockTime_3 = 1548345600;//2019-1-25 00:00:00

       unLockTime_4 = 1551024000;//2019-2-25 00:00:00

       unLockTime_5 = 1553443200;//2019-3-25 00:00:00

       unLockTime_6 = 1556121600;//2019-4-25 00:00:00

       unBalcnce = 0;

    }

    

    function unLock() public returns (bool success){

        unBalcnce = canUnBalance();

        emit UnLock(msg.sender, unBalcnce);

        return true;

    }

    

    function putBalance() public returns (bool success){//提现

        uint256 b = unBalcnce.sub(put_balance);

        require(b > 0);

        put_balance = put_balance.add(b);

        emit PutBalance(msg.sender, b);

        return true;

    }

    

    

    function canUnBalance() public view returns (uint256){

        uint num = getUnLockNum();

        return lockBalcnce.div(6).mul(num);

    }

    

    

    function getOperatorAddress() public view returns (address){

        return operatorAddress;

    }

    

    function getLockAddress() public view returns (address){

        return lockAddress;

    }



    function getBalance() public view returns (uint256){

        return unBalcnce.sub(put_balance);

    }

    

    function getUnLockNum() public view returns (uint){

        uint256 n = now;

        if(n < unLockTime_1){

            return 0;

        }else if(n >= unLockTime_1 && n < unLockTime_2){

            return 1;

        }else if(n >= unLockTime_2 && n < unLockTime_3){

            return 2;

        }else if(n >= unLockTime_3 && n < unLockTime_4){

            return 3;

        }else if(n >= unLockTime_4 && n < unLockTime_5){

            return 4;

        }else if(n >= unLockTime_5 && n < unLockTime_6){

            return 5;

        }else {

            return 6;

        }

    }

}