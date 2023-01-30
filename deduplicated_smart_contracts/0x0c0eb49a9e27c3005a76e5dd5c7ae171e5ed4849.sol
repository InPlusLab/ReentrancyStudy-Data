/**

 *Submitted for verification at Etherscan.io on 2018-11-01

*/



pragma solidity ^0.4.25;





// File: openzeppelin-solidity\contracts\math\SafeMath.sol



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {



  /**

  * @dev Multiplies two numbers, throws on overflow.

  */

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {

    // Gas optimization: this is cheaper than asserting 'a' not being zero, but the

    // benefit is lost if 'b' is also tested.

    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522

    if (a == 0) {

      return 0;

    }



    c = a * b;

    assert(c / a == b);

    return c;

  }



  /**

  * @dev Integer division of two numbers, truncating the quotient.

  */

  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    // uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return a / b;

  }



  /**

  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).

  */

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

    assert(b <= a);

    return a - b;

  }



  /**

  * @dev Adds two numbers, throws on overflow.

  */

  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {

    c = a + b;

    assert(c >= a);

    return c;

  }

}



// File: openzeppelin-solidity\contracts\token\ERC20\ERC20Basic.sol



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * See https://github.com/ethereum/EIPs/issues/179

 */

contract ERC20Basic {

  function totalSupply() public view returns (uint256);

  function balanceOf(address who) public view returns (uint256);

  function transfer(address to, uint256 value) public returns (bool);

  event Transfer(address indexed from, address indexed to, uint256 value);

}



// File: openzeppelin-solidity\contracts\token\ERC20\ERC20.sol



/**

 * @title ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/20

 */

contract ERC20 is ERC20Basic {

  function allowance(address owner, address spender)

    public view returns (uint256);



  function transferFrom(address from, address to, uint256 value)

    public returns (bool);



  function approve(address spender, uint256 value) public returns (bool);

  event Approval(

    address indexed owner,

    address indexed spender,

    uint256 value

  );

}





// File: openzeppelin-solidity\contracts\token\ERC20\SafeERC20.sol



/**

 * @title SafeERC20

 * @dev Wrappers around ERC20 operations that throw on failure.

 * To use this library you can add a `using SafeERC20 for ERC20;` statement to your contract,

 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.

 */

library SafeERC20 {

  function safeTransfer(ERC20Basic token, address to, uint256 value) internal {

    require(token.transfer(to, value));

  }



  function safeTransferFrom(

    ERC20 token,

    address from,

    address to,

    uint256 value

  )

    internal

  {

    require(token.transferFrom(from, to, value));

  }



  function safeApprove(ERC20 token, address spender, uint256 value) internal {

    require(token.approve(spender, value));

  }

}



// File: contracts\DecentralizedExchanges2.sol



contract SpecialERC20 {

    function transfer(address to, uint256 value) public;

}



contract RedEnvelope {

    

    using SafeMath for uint;

    using SafeERC20 for ERC20;

    

    struct Info {

        address token;

        address owner;

        uint amount;

        uint count;

        address[] limitAddress;

        bool isRandom;

        bool isSpecialERC20;

        uint expires;

        uint created;

        string desc;

        uint fill;

    }

    

    string public name = "RedEnvelope";

    

    mapping(bytes32 => Info) public infos;

    

    struct SnatchInfo {

        address user;

        uint amount;

        uint time;

    }

    

    mapping(bytes32 => SnatchInfo[]) public snatchInfos;

    

    constructor() public {

        

    }

    

    event RedEnvelopeCreated(bytes32 hash);

    

    // �������

    function create(

        bool isSpecialERC20, 

        address token, 

        uint amount, 

        uint count, 

        uint expires, 

        address[] limitAddress, 

        bool isRandom, 

        string desc, 

        uint nonce

    ) public payable {

        if (token == address(0)) {

            require(msg.value >= amount);

        } else {

            ERC20(token).transferFrom(msg.sender, this, amount);

        }

        

        bytes32 hash = sha256(abi.encodePacked(this, isSpecialERC20, token, amount, expires, nonce));

        infos[hash] = Info(token, msg.sender, amount, count, limitAddress, isRandom, isSpecialERC20, expires, now, desc, 0);

     

        emit RedEnvelopeCreated(hash);   

    }

    

    event Snatch(bytes32 hash, address user, uint amount, uint time);



    // �����

    function snatch(bytes32 hash) public {

        Info storage info = infos[hash];

        require(info.created > 0);

        require(info.amount >= info.fill);

        require(info.expires >= now);

        

        

        if (info.limitAddress.length > 0) {

            bool find = false;

            for (uint i = 0; i < info.limitAddress.length; i++) {

                if (info.limitAddress[i] == msg.sender) {

                    find = true;

                    break;

                }

            }

            require(find);

        }



        SnatchInfo[] storage curSnatchInfos = snatchInfos[hash];

        require(info.count > curSnatchInfos.length);

        for (i = 0; i < curSnatchInfos.length; i++) {

            require (curSnatchInfos[i].user != msg.sender);

        }

        

        if (info.isRandom) {

            

        } else {

            uint per = info.amount / info.count;

            snatchInfos[hash].push(SnatchInfo(msg.sender, per, now));

            if (info.token == address(0)) {

                msg.sender.transfer(per);

            } else {

                if (info.isSpecialERC20) {

                    SpecialERC20(info.token).transfer(msg.sender, per);

                } else {

                    ERC20(info.token).transfer(msg.sender, per);

                }

            }

            info.fill += per;

            

            emit Snatch(hash, msg.sender, per, now);

        }

    }

    

    event RedEnvelopeSendBack(bytes32 hash, address owner, uint amount);

    

    function sendBack(bytes32 hash) public {

        Info storage info = infos[hash];

        require(info.expires < now);

        require(info.fill < info.amount);

        require(info.owner == msg.sender);

        

        uint back = info.amount - info.fill;

        info.fill = info.amount;

        if (info.token == address(0)) {

            msg.sender.transfer(back);

        } else {

            if (info.isSpecialERC20) {

                SpecialERC20(info.token).transfer(msg.sender, back);

            } else {

                ERC20(info.token).transfer(msg.sender, back);

            }

        }

        

        emit RedEnvelopeSendBack(hash, msg.sender, back);

    }

    

    function getInfo(bytes32 hash) public view returns(

        address token, 

        address owner, 

        uint amount, 

        uint count, 

        address[] limitAddress, 

        bool isRandom, 

        bool isSpecialERC20, 

        uint expires, 

        uint created, 

        string desc

    ) {

        Info storage info = infos[hash];

        return (info.token, 

            info.owner, 

            info.amount, 

            info.count, 

            info.limitAddress, 

            info.isRandom, 

            info.isSpecialERC20, 

            info.expires, 

            info.created, 

            info.desc

        );

    }

    

    function getSnatchInfo(bytes32 hash) public view returns (address[] user, uint[] amount, uint[] time) {

        SnatchInfo[] storage info = snatchInfos[hash];

        

        address[] memory _user = new address[](info.length);

        uint[] memory _amount = new uint[](info.length);

        uint[] memory _time = new uint[](info.length);

        

        for (uint i = 0; i < info.length; i++) {

            _user[i] = info[i].user;

            _amount[i] = info[i].amount;

            _time[i] = info[i].time;

        }

        

        return (_user, _amount, _time);

    }

    

}