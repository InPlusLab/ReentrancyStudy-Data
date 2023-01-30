/**

 *Submitted for verification at Etherscan.io on 2018-09-30

*/



pragma solidity ^0.4.22;

/**

 * @title SafeMath

 * @dev Math operations with safety checks that revert on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, reverts on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (a == 0) {

      return 0;

    }



    uint256 c = a * b;

    require(c / a == b);



    return c;

  }



  /**

  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b > 0); // Solidity only automatically asserts when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold



    return c;

  }



  /**

  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b <= a);

    uint256 c = a - b;



    return c;

  }



  /**

  * @dev Adds two numbers, reverts on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a + b;

    require(c >= a);



    return c;

  }



  /**

  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),

  * reverts when dividing by zero.

  */

  function mod(uint256 a, uint256 b) internal pure returns (uint256) {

    require(b != 0);

    return a % b;

  }

}

// ���Ƽ���

library NameFilter {



function filter(string _input)

    internal

    pure

    returns(string)

    {

        bytes memory _temp = bytes(_input);

        uint256 _length = _temp.length;



        require (_length <= 256 && _length > 0, "string must be between 1 and 256 characters");

        require(_temp[0] != 0x20 && _temp[_length-1] != 0x20, "string cannot start or end with space");

        if (_temp[0] == 0x30)

        {

            require(_temp[1] != 0x78, "string cannot start with 0x");

            require(_temp[1] != 0x58, "string cannot start with 0X");

        }

        return _input;

    }

}







contract SimpleAuction {

    using NameFilter for string;

    using SafeMath for *;

    

    

    // ������

    address private boss;



    // fees

    uint public fees;



    address private top;



    address private loser;



    uint private topbid;



    uint private loserbid;





    //����ȡ�ص�֮ǰ�ĳ���

    mapping(address => uint) pendingReturns;



    mapping(address => string) giverNames;



    mapping(address => string) giverMessages;











    constructor(

        address _beneficiary

    ) public {

        boss = _beneficiary;

    }





    /// How much would you like to pay?

    function bid() public payable {

        // ������۲���0.0001ether

        require(

            msg.value > 0.0001 ether,

            "?????"

        );

        // ������۲����ߣ��������Ǯ

        require(

            msg.value > topbid,

            "loser fuck off."

        );

        // �������Ǳ�Ҫ�ġ���Ϊ���е���Ϣ�Ѿ��������˽����С�

        // �����ܽ�����̫�ҵĺ������ؼ��� payable �Ǳ���ġ�

        pendingReturns[msg.sender] += (msg.value.div(10).mul(9));

        fees+= msg.value.div(10);

        

        if(top != 0){

            loser = top;

            loserbid = topbid;

        }

        top = msg.sender;

        topbid = msg.value;



        if(bytes(giverNames[msg.sender]).length== 0) {

            giverNames[msg.sender] = "#Anonymous";

            giverMessages[msg.sender] = "#Nothing";

        }

    }



    function setInfo(string _name,string _message) public {

        

        giverNames[msg.sender] = _name.filter();

        giverMessages[msg.sender] = _message.filter();

    }



    function getMyInfo() public view returns (string,string){

        return getInfo(msg.sender);

    }

    

    function getFess() public view returns (uint){

        return fees;

    }







    function getWLInfo() public view returns (string,string,uint,string,string,uint){

return (giverNames[top],giverMessages[top],topbid,giverNames[loser],giverMessages[loser],loserbid);

    }







    function getInfo(address _add) public view returns (string,string){

        return (giverNames[_add],giverMessages[_add]);

    }





    /// ȡ��

    function withdraw() public returns (bool) {

        require(pendingReturns[msg.sender]>0,"Nothing left for you");

        uint amount = pendingReturns[msg.sender];

        pendingReturns[msg.sender] = 0;

        msg.sender.transfer(amount);

        if(msg.sender==top){

            loser = top;

            loserbid =topbid;

            top = 0;

            topbid = 0;

        }    

        return true;

    }



    /// shouqian

    function woyaoqianqian(uint fee) public {

                require(

            fee < fees,

            "loser fuck off."

        );

        fees = fees.sub(fee);

        // 3. ����

        boss.transfer(fee);

    }

}