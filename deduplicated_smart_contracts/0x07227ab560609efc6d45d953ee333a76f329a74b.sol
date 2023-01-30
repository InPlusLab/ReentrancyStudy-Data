/**

 *Submitted for verification at Etherscan.io on 2018-08-22

*/



pragma solidity ^0.4.21;



contract Owned {

    

    /// 'owner' is the only address that can call a function with 

    /// this modifier

    address public owner;

    address internal newOwner;

    

    ///@notice The constructor assigns the message sender to be 'owner'

    function Owned() public {

        owner = msg.sender;

    }

    

    modifier onlyOwner() {

        require(msg.sender == owner);

        _;

    }

    

    event updateOwner(address _oldOwner, address _newOwner);

    

    ///change the owner

    function changeOwner(address _newOwner) public onlyOwner returns(bool) {

        require(owner != _newOwner);

        newOwner = _newOwner;

        return true;

    }

    

    /// accept the ownership

    function acceptNewOwner() public returns(bool) {

        require(msg.sender == newOwner);

        emit updateOwner(owner, newOwner);

        owner = newOwner;

        return true;

    }

}



contract SafeMath {

    function safeMul(uint a, uint b) pure internal returns (uint) {

        uint c = a * b;

        assert(a == 0 || c / a == b);

        return c;

    }

    

    function safeSub(uint a, uint b) pure internal returns (uint) {

        assert(b <= a);

        return a - b;

    }

    

    function safeAdd(uint a, uint b) pure internal returns (uint) {

        uint c = a + b;

        assert(c>=a && c>=b);

        return c;

    }



}



contract ERC20Token {

    /* This is a slight change to the ERC20 base standard.

    function totalSupply() constant returns (uint256 supply);

    is replaced with:

    uint256 public totalSupply;

    This automatically creates a getter function for the totalSupply.

    This is moved to the base contract since public getter functions are not

    currently recognised as an implementation of the matching abstract

    function by the compiler.

    */

    /// total amount of tokens

    uint256 public totalSupply;

    

    /// user tokens

    mapping (address => uint256) public balances;

    

    /// @param _owner The address from which the balance will be retrieved

    /// @return The balance

    function balanceOf(address _owner) constant public returns (uint256 balance);



    /// @notice send `_value` token to `_to` from `msg.sender`

    /// @param _to The address of the recipient

    /// @param _value The amount of token to be transferred

    /// @return Whether the transfer was successful or not

    function transfer(address _to, uint256 _value) public returns (bool success);

    

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`

    /// @param _from The address of the sender

    /// @param _to The address of the recipient

    /// @param _value The amount of token to be transferred

    /// @return Whether the transfer was successful or not

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);



    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens

    /// @param _spender The address of the account able to transfer the tokens

    /// @param _value The amount of tokens to be approved for transfer

    /// @return Whether the approval was successful or not

    function approve(address _spender, uint256 _value) public returns (bool success);



    /// @param _owner The address of the account owning tokens

    /// @param _spender The address of the account able to transfer the tokens

    /// @return Amount of remaining tokens allowed to spent

    function allowance(address _owner, address _spender) constant public returns (uint256 remaining);



    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



contract PUST is ERC20Token {

    

    string public name = "UST Put Option";

    string public symbol = "PUST12";

    uint public decimals = 4;

    

    uint256 public totalSupply = 0;

    uint256 public topTotalSupply = 1000 * 10**decimals;

    

    function transfer(address _to, uint256 _value) public returns (bool success) {

    //Default assumes totalSupply can't be over max (2^256 - 1).

    //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.

    //Replace the if with this one instead.

        if (balances[msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {

            balances[msg.sender] -= _value;

            balances[_to] += _value;

            emit Transfer(msg.sender, _to, _value);

            return true;

        } else { return false; }

    }

    

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {

    //same as above. Replace this line with the following if you want to protect against wrapping uints.

        if (balances[_from] >= _value && allowances[_from][msg.sender] >= _value && balances[_to] + _value >= balances[_to]) {

          balances[_to] += _value;

          balances[_from] -= _value;

          allowances[_from][msg.sender] -= _value;

          emit Transfer(_from, _to, _value);

          return true;

        } else { return false; }

    }

    

    function balanceOf(address _owner) constant public returns (uint256 balance) {

        return balances[_owner];

    }

    

    function approve(address _spender, uint256 _value) public returns (bool success) {

        allowances[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);

        return true;

    }

    

    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {

        return allowances[_owner][_spender];

    }

    

    mapping(address => uint256) public balances;

    

    mapping (address => mapping (address => uint256)) allowances;

}





contract ExchangeUST is SafeMath, Owned, PUST {

    

    // Exercise End Time 1/1/2019 0:0:0

    uint public ExerciseEndTime = 1546272000;

    uint public exchangeRate = 100000; //percentage times (1 ether)

    //mapping (address => uint) ustValue; //mapping of token addresses to mapping of account balances (token=0 means Ether)

    

    // UST address

    address public ustAddress = address(0xFa55951f84Bfbe2E6F95aA74B58cc7047f9F0644);

    

    // offical Address

    address public officialAddress = address(0x472fc5B96afDbD1ebC5Ae22Ea10bafe45225Bdc6);

    

    event Cancel(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s);

    event Deposit(address token, address user, uint amount, uint balance);

    event Withdraw(address token, address user, uint amount, uint balance);

    event exchange(address contractAddr, address reciverAddr, uint _pustBalance);

    event changeFeeAt(uint _exchangeRate);



    function chgExchangeRate(uint _exchangeRate) public onlyOwner {

        require (_exchangeRate != exchangeRate);

        require (_exchangeRate != 0);

        exchangeRate = _exchangeRate;

    }



    function exerciseOption(uint _pustBalance) public returns (bool) {

        require (now < ExerciseEndTime);

        require (_pustBalance <= balances[msg.sender]);

        

        // convert units from ether to wei

        uint _ether = safeMul(_pustBalance, 10 ** 14);

        require (address(this).balance >= _ether); 

        

        // UST amount

        uint _amount = safeMul(_pustBalance, exchangeRate * 10**14);

        require (PUST(ustAddress).transferFrom(msg.sender, officialAddress, _amount) == true);

        

        balances[msg.sender] = safeSub(balances[msg.sender], _pustBalance);

        balances[officialAddress] = safeAdd(balances[officialAddress], _pustBalance);

        //totalSupply = safeSub(totalSupply, _pustBalance);

        msg.sender.transfer(_ether);    

        emit exchange(address(this), msg.sender, _pustBalance);

    }

}



contract USTputOption is ExchangeUST {

    

    // constant 

    uint public initBlockEpoch = 40;

    uint public eachUserWeight = 10;

    uint public initEachPUST = 3358211 * 10**11 wei;

    uint public lastEpochBlock = block.number + initBlockEpoch;

    uint public price1=26865688 * 9995 * 10**10/10000;

    uint public price2=6716422 * 99993 * 10**10/100000;

    uint public eachPUSTprice = initEachPUST;

    uint public lastEpochTX = 0;

    uint public epochLast = 0;

    address public lastCallAddress;

    uint public lastCallPUST;



    event buyPUST (address caller, uint PUST);

    event Reward (address indexed _from, address indexed _to, uint256 _value);

    

    function () payable public {

        require (now < ExerciseEndTime);

        require (topTotalSupply > totalSupply);

        bool firstCallReward = false;

        uint epochNow = whichEpoch(block.number);

    

        if(epochNow != epochLast) {

            

            lastEpochBlock = safeAdd(lastEpochBlock, ((block.number - lastEpochBlock)/initBlockEpoch + 1)* initBlockEpoch);

            doReward();

            eachPUSTprice = calcpustprice(epochNow, epochLast);

            epochLast = epochNow;

            //reward _first

            firstCallReward = true;

            lastEpochTX = 0;

        }



        uint _value = msg.value;

        //uint _PUST = _value * 10**decimals  / eachPUSTprice;

        uint _PUST = safeMul(_value, 10**decimals)  / eachPUSTprice;

        require(_PUST >= 1*10**decimals);

        if (safeAdd(totalSupply, _PUST) > topTotalSupply) {

            _PUST = safeSub(topTotalSupply, totalSupply);

        }

        

        uint _refound = safeSub(_value, safeMul(_PUST, eachPUSTprice)/10**decimals);

        

        if(_refound > 0) {

            msg.sender.transfer(_refound);

        }

        

        officialAddress.transfer(safeSub(_value, _refound));

        

        balances[msg.sender] = safeAdd(balances[msg.sender], _PUST);

        totalSupply = safeAdd(totalSupply, _PUST);

        emit Transfer(address(this), msg.sender, _PUST);

        

        // alloc first reward in a new or init epoch

        if(lastCallAddress == address(0) && epochLast == 0) {

             firstCallReward = true;

        }

        

        if (firstCallReward) {

            uint _firstReward = 0;

            _firstReward = _PUST * 2 / 10;

            if (safeAdd(totalSupply, _firstReward) > topTotalSupply) {

                _firstReward = safeSub(topTotalSupply, totalSupply);

            }

            balances[msg.sender] = safeAdd(balances[msg.sender], _firstReward);

            totalSupply = safeAdd(totalSupply, _firstReward);

            emit Reward(address(this), msg.sender, _firstReward);

        }

        

        lastEpochTX += 1;

        

        // last call address info

        lastCallAddress = msg.sender;

        lastCallPUST = _PUST;

        

        // calc last epoch

        lastEpochBlock = safeAdd(lastEpochBlock, eachUserWeight);

    }

    

    // 

    function whichEpoch(uint _blocknumber) internal view returns (uint _epochNow) {

        if (lastEpochBlock >= _blocknumber ) {

            _epochNow = epochLast;

        } else {

            //lastEpochBlock = safeAdd(lastEpochBlock, thisEpochBlockCount);

            //thisEpochBlockCount = initBlockEpoch;

            _epochNow = epochLast + (_blocknumber - lastEpochBlock) / initBlockEpoch + 1;

        }

    }

    

    function calcpustprice(uint _epochNow, uint _epochLast) public returns (uint _eachPUSTprice) {

        require (_epochNow - _epochLast > 0);    

        uint dif = _epochNow - _epochLast;

        uint dif100 = dif/100;

        dif = dif - dif100*100;        

        for(uint i=0;i<dif100;i++)

        {

            price1 = price1-price1*5/100;

            price2 = price2-price2*7/1000;

        }

        price1 = price1 - price1*5*dif/10000;

        price2 = price2 - price2*7*dif/100000;

        

        _eachPUSTprice = price1+price2;    

    }

    

    function doReward() internal returns (bool) {

        if (lastEpochTX == 1) return false;

        uint _lastReward = 0;

        

        if(lastCallPUST > 0) {

            _lastReward = lastCallPUST * 2 / 10;

        }

        

        if (safeAdd(totalSupply, _lastReward) > topTotalSupply) {

            _lastReward = safeSub(topTotalSupply,totalSupply);

        }

        balances[lastCallAddress] = safeAdd(balances[lastCallAddress], _lastReward);

        totalSupply = safeAdd(totalSupply, _lastReward);

        emit Reward(address(this), lastCallAddress, _lastReward);

    }



    // only owner can deposit ether into put option contract

    function DepositETH(uint _PUST) payable public {

        // deposit ether

        require (msg.sender == officialAddress);

        topTotalSupply += _PUST * 10**decimals;

    }

    

    // only end time, onwer can transfer contract's ether out.

    function WithdrawETH() payable public onlyOwner {

        officialAddress.transfer(address(this).balance);

    } 

    

    // if this epoch is the last, then the reward called by the owner

    function allocLastTxRewardByHand() public onlyOwner returns (bool success) {

        lastEpochBlock = safeAdd(block.number, initBlockEpoch);

        doReward();

        success = true;

    }

}