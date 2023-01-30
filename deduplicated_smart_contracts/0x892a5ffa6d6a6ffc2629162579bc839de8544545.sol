/**
 *Submitted for verification at Etherscan.io on 2019-08-29
*/

pragma solidity ^0.4.26;

//这个接口，是用于对接 其它合约的--对接  常用的 如锁仓合约
interface tokenRecipient {
  function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external;
}

/**  函数库
 * @title SafeMath --安全的数学运算
 * @dev  Math operations with safety checks that throw on error//数学运算与安全检查发生错误
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.//将两个数字相乘，在溢出时抛出。
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    if (a == 0) {
      return 0;
    }
    c = a * b;
    assert(c / a == b);
    return c;
  }



  /**
  * @dev Integer division of two numbers, truncating the quotient.//两个数的整数除法，截断商。
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0);   // Solidity automatically throws when dividing by 0  //分母为0时，自动抛出
    // uint256 c = a / b;
    // assert(a == b * c + a % b);   // There is no case in which this doesn't hold //没有这种情况不成立。
    return a / b;
  }




  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  //减去两个数字，在溢出时抛出（即如果减数大于被减数）。
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }



  /**
  * @dev Adds two numbers, throws on overflow.//添加两个数字，在溢出时抛出。
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a + b;
    assert(c >= a);
    return c;
  }
}




contract Ownable {

  address public owner;//合约拥有者的地址变量
  address public COO; //设立首席运营官
  address public CTO; //设立首席技术官

//更换新的合约拥有者--事件通知
  event OwnershipTransferred(address indexed _owner, address indexed _newAddress);
//更换首席运营官--事件通知
  event COOTransferred(address indexed _COO, address indexed _newAddress);
//更换首席技术官--事件通知
  event CTOTransferred(address indexed _CTO, address indexed _newAddress);

  //永久取消合约拥有者的权限--事件通知
  event OwnershipRenounced(address indexed previousOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender account.
   *
   * 可拥有的构造函数将合同的原始“所有者”设置为发送方帐户。
   */
  constructor() public {
    owner = msg.sender;  //把合约创建者的地址赋给 合约拥有者变量 owner
    COO = msg.sender;    //把合约创建者的地址赋给 首席运营官变量 COO
    CTO = msg.sender;    //把合约创建者的地址赋给 首席技术官变量 CTO
  }




  /**
   * @dev Throws if called by any account other than the owner.
   * // 如果由所有者以外的任何帐户调用，则抛出。
   */
      modifier onlyOwner() {
        require(msg.sender == owner);  //判断当前消息发送者，是否为合约拥有者
        _;  //替换符，发起者的函数代码，是放在这的
      }


      modifier onlyCOO() {
        //判断当前消息发送者，是否为首席运营官
        require(msg.sender == COO);
        _;  //替换符，发起者的函数代码，是放在这的
      }


      modifier onlyCTO() {
        //判断当前消息发送者，是否为首席技术官
        require(msg.sender == CTO);
        _;  //替换符，发起者的函数代码，是放在这的
      }


  /**
   //允许当前所有者将合同的控制转移给新所有者。
   */

   function transferAddress(address _newAddress,uint _type) public onlyOwner returns (bool) {
     require(_newAddress != address(0) && _type > 0  && _type < 4);                //判断是否为以太坊地址
         if( _type == 1 ){
               owner = _newAddress;                              //新的合约拥有者
               emit OwnershipTransferred(owner, _newAddress);    //事件通知
         }
         if ( _type == 2 ){
              COO = _newAddress;                              //新的首席运营官
              emit COOTransferred(COO, _newAddress);          //事件通知
         }
         if( _type == 3 ){
              CTO = _newAddress;                              //新的 首席技术官
              emit CTOTransferred(CTO, _newAddress);           //事件通知
         }
         return true;
   }



//永久取消合约拥有者的权限--不可逆的
  function renounceOwnership() public onlyOwner returns (bool){
    owner = address(0);   //把合约拥有者的地址变为 0x000000000格式的
    emit OwnershipRenounced(owner);   //事件通知

    return true;
    }


}








contract TokenERC20 is Ownable {

  // 变量集
  using SafeMath for uint256;   //把函数库附加到 SafeMath变量中

  string public name;
  string public symbol;
  uint8 public decimals = 1;   // 表示，可以显示小数点后多少位数,上线时，改为18
  uint256 public totalSupply;  // 合约代币总量数

  mapping (address => uint256) public balanceOf;  //用户的代币余额
  mapping (address => mapping (address => uint256)) public allowance;  //储存某地址授权某地址多少代币
  mapping (address => bool) public frozenAccount;  // 保存冻结账户的冻结状态 ，默认为：false


// 事件集
    event Transfer(address indexed from, address indexed to, uint256 value);  //交易事件通知
    event Approval(address indexed owner, address indexed spender, uint256 value);  //授权某地址多少个代币-事件通知
    event Burn(address indexed from, uint256 value);  // 事件，用来通知客户端代币被消毁
    event FrozenFunds(address target, bool frozen);  // 冻结账户事件通知






// 构造函数
  constructor(uint256 _totalSupply,string _name,string tokenSymbol) public {
      totalSupply = _totalSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
      balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens
      name = _name;                                   // Set the name for display purposes
      symbol = tokenSymbol;                               // Set the symbol for display purposes
  }








//主要方法开始
/**代币转账功能--开始 **/
   function _transfer(address _from, address _to, uint _value) internal  returns (bool) {
         require(_to != address(0));                    //是否为以太坊地址
         require(_value <= balanceOf[_from]);            //要转出的代币数，必须要少于当前代币余额数

         balanceOf[_from] = balanceOf[_from].sub(_value); //扣减代币
         balanceOf[_to] = balanceOf[_to].add(_value);     //增加代币

         emit Transfer(_from, _to, _value);             //调用event事件，类似于log，web3可以回掉.
         return true;
       }

//代币转账功能
    function transfer(address _to, uint256 _value) public returns (bool){
           //require(_filters(0,msg.sender,_to,_value)); //函数开关要在关闭状态 + 发送者地址为非冻结状态 + 接收者地址为非冻结状态
           require( _transfer(msg.sender, _to, _value) );
           return true;
         }

/**代币转账功能--结束 **/







/** 代币授权功能--开始**/
//授权后的被接收方的余额是不会显示的，只能通过授权查询来显示
    function _approve(address _spender, uint256 _value) internal returns (bool) {
           allowance[msg.sender][_spender] = _value;
           emit Approval(msg.sender, _spender, _value);
           return true;
         }

//1--approve()-- 我授权某个地址可以用我多少个代币 --必须接口
    function approve(address _to, uint256 _value) public returns (bool){
           //require(_filters(1,msg.sender,_to,_value));
           require( _approve(_to, _value) );
           return true;
        }


/** 代币授权功能---结束 **/



/**代币授权转账功能---开始**/
        function _transferFrom(address _from, address _to, uint256 _value) internal returns (bool) {
           //从以下的代码，可以看出这个方法的意思是，我 从某人授权给我的代币账户中，转到多少代币给别人
            require(_to != address(0)  && _value <= balanceOf[_from] && _value <= allowance[_from][msg.sender]);

            allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);  //在 allowance[_from][msg.sender] 中扣减
            require( _transfer(_from, _to, _value) ); //在 _from 中扣减，在 _to 中增加

            emit Transfer(_from, _to, _value);
            return true;
          }

          function transferFrom(address _from, address _to, uint256 _value) public returns (bool){
                //require(_filters2(2,_from,_to,_value,msg.sender));  //过滤器
                require( _transferFrom(_from,_to,_value) );
                return true;
             }

/**代币授权转账功能---结束**/






/**追加扣减代币授权功能---开始**/
//3--increaseApproval()-- 我对某个地址追加授权的代币
      function _increaseApproval(address _spender, uint _addedValue) internal returns (bool) {
         allowance[msg.sender][_spender] = allowance[msg.sender][_spender].add(_addedValue);//在原来的余额基础上追加

         emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);
         return true;
         }

      function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
            //require(_filters(3,msg.sender,_spender,_addedValue));
            require( _increaseApproval(_spender,_addedValue) );
            return true;
         }


//4--decreaseApproval()-- 我对某个地址扣减授权的代币
      function _decreaseApproval(address _spender, uint _subtractedValue) internal returns (bool) {

          uint oldValue = allowance[msg.sender][_spender]; //获得当前旧授权账户的余额

          if (_subtractedValue > oldValue) {      //如果授权账户的余额不够 扣减
                 allowance[msg.sender][_spender] = 0;     //清0
           } else {
                 allowance[msg.sender][_spender] = oldValue.sub(_subtractedValue);  //在余额的基础上扣减
           }

           emit Approval(msg.sender, _spender, allowance[msg.sender][_spender]);//事件通知
           return true;
         }

       function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
             //require(_filters(4,msg.sender,_spender,_subtractedValue));
             require( _decreaseApproval(_spender,_subtractedValue) );
             return true;
         }
/**追加扣减代币授权功能---结束**/





/**销毁代币功能---开始**/
/**销毁某个地址的代币--内部方法(用户自已销毁)**/
         function _burn(address _who, uint256 _value) internal returns (bool){
              require(_value <= balanceOf[_who]);  //检查源账户是否额足够的代币

              balanceOf[_who] = balanceOf[_who].sub(_value);   //从源账户(刘德华的账户)中减去
              totalSupply = totalSupply.sub(_value);       //从合约总账户中减去

              emit Burn(_who, _value);                       //销毁事件通知
              emit Transfer(_who, address(0), _value);       //交易事件通知
              return true;
             }
//5--burn() -- 用户自已销毁自已的代币
        function burn(uint256 _value) public returns (bool) {
              //require(_filters0(5,msg.sender,_value));
              require( _burn(msg.sender, _value) );
              return true;
             }




/**被授权的用户，销毁 指定授权给自已的代币-并销毁代币**/
//举例：我   销毁 刘德华  授权 给我的代币
         function _burnFrom(address _from, uint256 _value) internal returns (bool){
               require(_value <= allowance[_from][msg.sender]);  //刘德华  授权 给我的代币数量，要大于 销毁 的数量
               //从刘德华 授权 给我的账户中扣减
               allowance[_from][msg.sender] = allowance[_from][msg.sender].sub(_value);
               //1. 判断刘德华的账户足够 ； 2. 销毁代币  3. 事件通知
               require( _burn(_from, _value) );  //调用销毁代币的内部方法
               return true;
           }

//6--burnFrom()-- 我销毁某人（如：刘德华）  授权 给我的代币
          function burnFrom(address _from, uint256 _value) public returns (bool) {
               //require(_filters(6,msg.sender,_from,_value));
               require( _burnFrom(_from,_value) );
               return true;
           }


/**销毁代币功能---结束**/





/**空投代币功能---开始**/
//无中生有--空投代币
     function _mintToken(address target, uint256 mintedAmount) onlyOwner internal returns (bool) {
         //注：totalSupply 是 代币的总数；  balanceOf[this] -- 是合约当前的代币余额，两者是不同的
            totalSupply = totalSupply.add(mintedAmount);       //合约总账户增加代币
            balanceOf[target] = balanceOf[target].add(mintedAmount);  //某地址增加代币

            emit Transfer(0, this, mintedAmount);       //合约总账户增加代币---事件通知
            emit Transfer(this, target, mintedAmount);  //某地址增加代币--事件通知
            return true;
         }

//7--mintToken()--对某个地址空投代币
    function mintToken(address _target, uint256 _mintedAmount) onlyOwner public returns (bool) {
            //require(_filters0(7,_target,_mintedAmount));
            require( _mintToken(_target,_mintedAmount) );
            return true;
         }




/**空投代币功能---结束**/





/**冻结账户功能---开始**/
/**冻结账户的方法**/
     function _freezeAccount(address target, bool freeze) onlyCTO internal  returns (bool) {
           frozenAccount[target] = freeze;     //值进来的参数是真或假
           emit  FrozenFunds(target, freeze);
           return true;
        }

//8--freezeAccount() --对某地址进行冻结或解冻
     function freezeAccount(address _target, bool _freeze) onlyCTO public returns (bool) {
           //require(values[8]==0 && frozenAccount[_target] != _freeze);
           require( _freezeAccount(_target,_freeze) );
           return true;
        }



/**冻结账户功能---结束**/









/**高级功能---开始**/
//15--意思是：发送者  授权某地址（是合约地址） ，可以使用自已多少代币，并传送数据--注：带数据，但不可接收ETH
//approve方法的升级版--传入的是一个别的合约地址--必须接口
//用法举例：比如，我先授权 A合约  1000个代币，接下来，调用 A合约 里的 receiveApproval() 方法，把这1000个代币转给 B
   function approveAndCall(address _spender, uint256 _value, bytes _extraData) public returns (bool) {
           //require(_filters(15,msg.sender,_spender,_value));
           require(_spender != address(this));   //排除传进来的是当前合约地址

           tokenRecipient spender = tokenRecipient(_spender); //获得合约对像
           if (approve(_spender, _value)) {  //我对前面定义的合约对像授权多少代币
               spender.receiveApproval(msg.sender, _value, this, _extraData);
               return true;
           }
       }




/**高级功能---开始**/






  }