/**

 *Submitted for verification at Etherscan.io on 2018-10-22

*/



pragma solidity ^0.4.18;



library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {

    uint256 c = a * b;

    assert(a == 0 || c / a == b);

    return c;

  }



  function div(uint256 a, uint256 b) internal pure returns (uint256) {

    // assert(b > 0); // Solidity automatically throws when dividing by 0

    uint256 c = a / b;

    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

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



contract Control {

	address public owner;

    bool public paused = false;//暂停交易

    uint256 constant internal _totalSupply  = (10 ** 9) * (10 ** 18);   // 1 billion YOU, decimals set to 18



    event Pause();

    event Unpause();



	function Control() public {

		owner = msg.sender;

	}



	modifier onlyOwner() {

		require(msg.sender == owner);

		_;

	}



	modifier whenNotPaused() {

	    require(!paused);

        _;

	}



    modifier whenPaused {

	    require(paused);

	    _;

    }



    function pause() public onlyOwner whenNotPaused returns (bool) {

        paused = true;

        Pause();

        return true;

    }



    function unpause() public onlyOwner whenPaused returns (bool) {

        paused = false;

        Unpause();

        return true;

    }



	function setOwner(address newOwner) public onlyOwner {

		require(newOwner != address(0));

		owner = newOwner;

	}

}



contract ERC20 {

    function totalSupply() public constant returns (uint);

	function balanceOf(address who) public view returns (uint256);

	function transfer(address to, uint256 value) public returns (bool);

	function allowance(address owner, address spender) public view returns (uint256);

	function transferFrom(address from, address to, uint256 value) public returns (bool);

	function approve(address spender, uint256 value) public returns (bool);

	event Approval(address indexed owner, address indexed spender, uint256 value);

	event Transfer(address indexed from, address indexed to, uint256 value);

}



contract BasicToken is ERC20, Control {

    using SafeMath for uint256;



    uint8 constant public decimals = 18;

    string constant public name = "Younus.org Token";

    string constant public symbol = "YOU";



	mapping(address => uint256) balances;

	mapping(address => mapping (address => uint256)) internal allowed;



	function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {

		require(_to != address(0));

		require(_value <= balances[msg.sender]);



		balances[msg.sender] = balances[msg.sender].sub(_value);

		balances[_to] = balances[_to].add(_value);

		Transfer(msg.sender, _to, _value);

		return true;

	}



	function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {

		require(_to != address(0));

		require(_value <= balances[_from]);

		require(_value <= allowed[_from][msg.sender]);



		balances[_from] = balances[_from].sub(_value);

		balances[_to] = balances[_to].add(_value);

		allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);

		Transfer(_from, _to, _value);

		return true;

	}



	function balanceOf(address _owner) public view returns (uint256 balance) {

		return balances[_owner];

	}



   function totalSupply() public constant returns (uint256){

        return _totalSupply;

   }



	function approve(address _spender, uint256 _value) public returns (bool) {

		allowed[msg.sender][_spender] = _value;

		Approval(msg.sender, _spender, _value);

		return true;

	}



	function allowance(address _owner, address _spender) public view returns (uint256) {

		return allowed[_owner][_spender];

	}



}



contract YOUToken is BasicToken {



    using SafeMath for uint256;



	Option[] options;

	mapping (uint256 => address) internal optionIndexToOwner;

    mapping (address => uint256[]) ownershipOptions;



    event LogCreateOption(address indexed _buyer, uint256 _value, uint32 _firstDate, uint32 _optionDays);//分配期权事件



	struct Option{

	    uint256 _optionValue;         //期权总额

	    uint32 _unfreezeDate;         //开始解冻日期

	    uint32  _optionDays;          //期权天数

        uint256 _eachDayValue;        //每天可解冻金额

	    uint256 _unlockedValue;       //已解冻的金额

	}



	function YOUToken() public {

        balances[msg.sender] = _totalSupply;

        Transfer(address(0), msg.sender, _totalSupply);

	}



	//所有期权统计

    function viewOptions() public view returns (uint optionCount, uint lockedValue, uint lockedRate){

        optionCount = options.length;// 已有期权笔数

        // 被冻结中的tokens

        for(uint32 optionId = 0; optionId < options.length; optionId ++){

            lockedValue = lockedValue.add(options[optionId]._optionValue.sub(options[optionId]._unlockedValue));

        }

        lockedValue = lockedValue.add(balances[owner]);  // 统计由销售合约代持部分

        lockedRate = (lockedValue * 100) / _totalSupply; // 冻结比例(%)

    }



	//某个token详情

    function viewOption(uint32 optionId) external view returns (address holder,

            uint256 optionValue,

            uint256 lockedValue,

            uint256 unlockedValue,

            uint256 eachUnfreezeValue,

            uint32 unfreezeDate,

            uint32 optionDays,

            uint256 releasableValue){

        holder = optionIndexToOwner[optionId];                                                        //期权拥有者

        optionValue = options[optionId]._optionValue;                                                 //期权总额

	    lockedValue = options[optionId]._optionValue.sub(options[optionId]._unlockedValue);           //已解冻的金额

	    unlockedValue = options[optionId]._unlockedValue;                                             //已解冻的金额

        eachUnfreezeValue = options[optionId]._eachDayValue;                                          //每天可解冻金额

	    unfreezeDate = options[optionId]._unfreezeDate;                                               //开始解冻日期

	    optionDays = options[optionId]._optionDays;                                                   //冻结天数

	    releasableValue = freeValue(optionId);                                                        //可释放额度

    }



    //指定账户的期权总额(token)

	function optionOfAddress(address who) public view returns (uint256 optionCount, uint256[] optionIds, uint256 optionValue, uint256 lockedValue, uint256 unlockedValue, uint256 releasableValue){

        optionIds = ownershipOptions[who];

        optionCount = optionIds.length;

        for(uint32 optionId = 0; optionId < options.length; optionId++){

            if(optionIndexToOwner[optionId] == who){

                if(options[optionId]._optionValue > options[optionId]._unlockedValue){

                    optionValue = optionValue.add(options[optionId]._optionValue);// 期权总额

                    unlockedValue = unlockedValue.add(options[optionId]._unlockedValue);// 已行权总额



                    //可解冻期权

                    uint256 _freeValue = freeValue(optionId);

                    if(_freeValue > 0){

                        releasableValue = releasableValue.add(_freeValue);// 可解冻总额

                    }

                }

            }

        }

        lockedValue = optionValue.sub(unlockedValue);// 冻结中的期权

	}



	function freeValue(uint32 optionId) internal view returns (uint256){

	    if(options[optionId]._optionValue == options[optionId]._unlockedValue)

	        return 0;

	    uint32 _today = uint32(block.timestamp);

    	if(options[optionId]._unfreezeDate >=  _today){

    	    return 0;

    	}

	    uint32 _days = uint32((_today - options[optionId]._unfreezeDate) / 86400);//可解冻天数:86400 = 24 * 60 * 60;



	    if(options[optionId]._optionDays <= _days){

	        return options[optionId]._optionValue.sub(options[optionId]._unlockedValue);

	    }else{

	        return options[optionId]._eachDayValue.mul(_days).sub(options[optionId]._unlockedValue);

	    }

	}



    //分配期权

	function createOption(address holder, uint256 optionValue, uint32 unfreezeDate, uint32 optionDays) public onlyOwner whenNotPaused returns (uint) {

	    //请求参数校验

		address seller = msg.sender;

		require(optionValue <= balances[seller]);

		require(holder != 0x0);

        require(optionDays > 0);



        //扣除tokens

		balances[seller] = balances[seller].sub(optionValue);

        uint256 eachDayValue = optionValue.div(optionDays);



        //设置期权

        Option memory _option = Option({

                              _optionValue : optionValue,

                              _optionDays : optionDays,

                              _eachDayValue : eachDayValue,

                              _unlockedValue : 0,

                              _unfreezeDate : unfreezeDate

                              });



        uint256 optionId = options.push(_option) - 1;

        require(optionId == uint256(uint32(optionId)));

        optionIndexToOwner[optionId] = holder;

        uint256[] storage optionIds = ownershipOptions[holder];

        optionIds.push(optionId);

        LogCreateOption(holder, optionValue, unfreezeDate, optionDays);//分配期权事件

		return optionId;

	}



    function unfreezeOption(uint32 optionId) public whenNotPaused returns (bool) {

        require(options[optionId]._optionValue > options[optionId]._unlockedValue);//有待解冻tokens

        uint32 _today = uint32(block.timestamp);

        require(_today > options[optionId]._unfreezeDate);//可以解冻



        uint256 _freeValue = freeValue(optionId);//预估可解冻金额

        require(_freeValue > 0);



        //解冻

        address _buyer = optionIndexToOwner[optionId];

        balances[_buyer] = balances[_buyer].add(_freeValue);

        Transfer(owner, _buyer, _freeValue);

        options[optionId]._unlockedValue = options[optionId]._unlockedValue.add(_freeValue);

        return true;

    }



    function claim() public whenNotPaused returns (bool) {

        return claimOfAddress(msg.sender);

    }



    function claimOfAddress(address holder) public whenNotPaused returns (bool) {

        uint256[] memory optionIds = ownershipOptions[holder];

        for(uint256 i = 0; i < optionIds.length; i++){

            unfreezeOption(uint32(i));

        }

    }

}



// Contract to sell and distribute YOU tokens

contract YOUSale is Control{



    using SafeMath for uint256;



    /// chart of stage transition

    ///

    /// deploy   initialize      startTime                            endTime                 finalize

    ///                              | <-earlyStageLasts-> |             | <- closedStageLasts -> |

    ///  O-----------O---------------O---------------------O-------------O------------------------O------------>

    ///     Created     Initialized     Early(cornerstone)     Normal(VC)           Closed            Finalized

    enum Stage {

        NotCreated,

        Created,

        Initialized,

        Early,

        Normal,

        Closed,

        Finalized

    }



    uint256 constant earlyInvestorSupply        = _totalSupply * 92 / 1000;  // 9.2% for 早期投资者

    uint256 constant marketSupply               = _totalSupply * 5 / 100;    // 5% for 交易所

    uint256 constant reservedForTeam            = _totalSupply * 20 / 100;   // 20% for team团队

    uint256 constant reservedForOperations      = _totalSupply * 40 / 100;   // 40 for operations运营



    uint256 constant cornerstoneSupply          = _totalSupply * 9 / 100;    // 9% for 基石轮

    uint256 constant vcSupply                   = _totalSupply * 168 / 1000; // 16.8% for 风险投资轮



    // 74.2%

    uint256 public constant nonPublicSupply     = earlyInvestorSupply + marketSupply + reservedForTeam + reservedForOperations;

    // 25.8%

    uint256 public constant publicSupply        = _totalSupply - nonPublicSupply;



    struct SoldOut {

        uint16 placeholder;                                          // placeholder to make struct pre-alloced

        uint256 cornerstoneValue;

        uint256 vcValue;

    }



    SoldOut soldOut;

    uint256 constant youPerEth = 10000;                              // per exchange rate

    uint256 constant cornerstoneStage = youPerEth  * 150 / 100;      // early stage has 50% bonus

    uint256 constant vcStage = youPerEth  * 120 / 100;               // normal stage has 20% bonus



    YOUToken you;                                  // YOU token contract follows ERC20 standard

    address ethVault;                              // the account to keep received ether

    address youVault;                              // the account to keep non-public offered YOU tokens

    uint public  startTime;                        // time to start sale

    uint public  endTime;                          // tiem to close sale

    uint public constant earlyStageLasts = 7 days; // early bird stage lasts in seconds



    bool initialized;

    bool finalized;



    function YOUSale() public {

        soldOut.placeholder = 1;

    }



    /// @notice calculte exchange rate according to current stage

    /// @return exchange rate. zero if not in sale.

    function exchangeRate() public constant returns (uint256){

        if (stage() == Stage.Early) {

            return cornerstoneStage;

        }

        if (stage() == Stage.Normal) {

            return vcStage;

        }

        return 0;

    }



    //当前销售期，未售出余额

    function unsoldOfStage() public constant returns (uint256){

        if (stage() == Stage.Early) {

            return cornerstoneSupply.sub(soldOut.cornerstoneValue);

        }

        if (stage() == Stage.Normal) {

            return vcSupply.sub(soldOut.vcValue);

        }

        return 0;

    }



    /// @notice estimate stage

    /// @return current stage

    function stage() public constant returns (Stage) {

        if (finalized) {

            return Stage.Finalized;

        }



        if (!initialized) {

            // deployed but not initialized

            return Stage.Created;

        }



        if (block.timestamp < startTime) {

            // not started yet

            return Stage.Initialized;

        }



        if (uint256(soldOut.cornerstoneValue).add(soldOut.vcValue) >= publicSupply) {

            // all sold out

            return Stage.Closed;

        }



        if (block.timestamp < endTime) {

            // in sale

            if (block.timestamp < startTime.add(earlyStageLasts)) {

                // early bird stage

                return Stage.Early;

            }

            // normal stage

            return Stage.Normal;

        }



        // closed

        return Stage.Closed;

    }



    function () public payable {

        buy();

    }



    /// @notice entry to buy tokens

    function buy() public payable {

        require(msg.value >= 20 ether);



        uint256 rate = exchangeRate();

        require(rate > 0);



        uint256 requested = msg.value.mul(rate);



        Stage n_stage = stage();

        require(n_stage == Stage.Early || n_stage == Stage.Normal);



        uint256 remained;

        if (n_stage == Stage.Early) {

            remained = cornerstoneSupply.sub(soldOut.cornerstoneValue);

        } else {

            remained = vcSupply.sub(soldOut.vcValue);

        }

        if (requested > remained) {

            //exceed remained

            requested = remained;

        }



        uint256 ethCost = requested.div(rate);



        // Token有,则购买

        if (requested > 0) {

            you.createOption(msg.sender, requested, uint32(endTime), 365);

            // transfer ETH to vault

            ethVault.transfer(ethCost);



            // 记录已出售总额

            if (n_stage == Stage.Early) {

                soldOut.cornerstoneValue = requested.add(soldOut.cornerstoneValue);

            } else{

                soldOut.vcValue = requested.add(soldOut.vcValue);

            }

            LogSold(msg.sender, requested, ethCost);

        }



        uint256 toReturn = msg.value.sub(ethCost);

        if(toReturn > 0) {

            // return over payed ETH

            msg.sender.transfer(toReturn);

        }

    }



    /// @notice initialize to prepare for sale

    /// @param _younus The address YOU token contract following ERC20 standard

    /// @param _ethVault The place to store received ETH

    /// @param _days The days from now to the sales deadline

    function initialize(

        YOUToken _younus,

        address _ethVault,

        uint _days) public onlyOwner {



        // ownership of token contract should already be this

        require(_younus.owner() == address(this));



        require(stage() == Stage.Created);

        require(_days <= 365 );

        require(address(_ethVault) != 0);



        startTime = block.timestamp + 3 days;

        endTime = startTime + _days * 86400;     // 86400 = 24 * 60 * 60



        you = _younus;

        ethVault = _ethVault;

        initialized = true;



        LogInitialized();

    }



    /// @notice finalize

    function finalize() public onlyOwner {

        // only after closed stage

        require(stage() == Stage.Closed);



        uint256 unsold = publicSupply.sub(soldOut.cornerstoneValue).sub(soldOut.vcValue);

        if (unsold > 0) {

            you.createOption(0x000000000000000000000000000000000000002b, unsold, 4070880001, 365);//未售出的token,转给未知地址冻结(4070880001 = 2099/1/1 00:00:01)

        }

        finalized = true;

        LogFinalized();

    }



    //分配期权

    function assignOption(address holder, uint256 amount, uint32 _unfreezeDate, uint32 optionDays) public onlyOwner returns (uint) {

        require(initialized);

        require(optionDays > 0);



        if(_unfreezeDate < uint32(endTime))

            _unfreezeDate = uint32(endTime);



        you.createOption(holder, amount, _unfreezeDate, optionDays);

    }



    function pause() public onlyOwner whenNotPaused returns (bool) {

        you.pause();

        return super.pause();

    }



    function unpause() public onlyOwner whenPaused returns (bool) {

        you.unpause();

        return super.unpause();

    }



    event LogInitialized();

    event LogFinalized();

    event LogSold(address indexed buyer, uint256 youAmount, uint256 ethCost);

}

//TODO

//控制公开销售时，基石和VC的销售额度 ok

//未售出，则直接销毁（销毁的Token从YOUSale出）ok

//添加操作事件 ok

//理清销售合约和代币合约关系(Sale合约持有Token合约) ok

//需要解决一个账户只能购买一次问题(引入期权概念) ok

//如何分配未未公开发行的token(直接转账)，锁定期问题(由YOUSale分配) ok

//添加查看接口 ok

//客户可以方便的自己解冻token(token合约调用clim方法) ok

//可以暂停交易 ok