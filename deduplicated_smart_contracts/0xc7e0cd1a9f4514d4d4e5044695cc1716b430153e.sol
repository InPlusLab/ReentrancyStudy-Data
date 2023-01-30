/**

 *Submitted for verification at Etherscan.io on 2019-08-08

*/



pragma solidity ^0.4.23;



contract IERC223Token {

    function name() public view returns (string);

    function symbol() public view returns (string);

    function decimals() public view returns (uint8);

    function totalSupply() public view returns (uint256);

    function balanceOf(address _holder) public view returns (uint256);



    function transfer(address _to, uint256 _value) public returns (bool success);

    function transfer(address _to, uint _value, bytes _data) public returns (bool success);

    function transfer(address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success);

    

    event Transfer(address indexed _from, address indexed _to, uint _value, bytes _data);

}



contract IERC223Receiver {

  

   /**

 * @dev Standard ERC223 function that will handle incoming token transfers.

 *

 * @param _from  Token sender address.

 * @param _value Amount of tokens.

 * @param _data  Transaction metadata.

 */

    function tokenFallback(address _from, uint _value, bytes _data) public returns(bool);

}



contract IOwned {

    // this function isn't abstract since the compiler emits automatically generated getter functions as external

    function owner() public pure returns (address) {}



    event OwnerUpdate(address _prevOwner, address _newOwner);



    function transferOwnership(address _newOwner) public;

    function acceptOwnership() public;

}



contract ICalled is IOwned {

    // this function isn't abstract since the compiler emits automatically generated getter functions as external

    function callers(address) public pure returns (bool) { }



    function appendCaller(address _caller) public;  // ownerOnly

    function removeCaller(address _caller) public;  // ownerOnly

    

    event AppendCaller(ICaller _caller);

    event RemoveCaller(ICaller _caller);

}



contract ICaller{

	function calledUpdate(address _oldCalled, address _newCalled) public;  // ownerOnly

	

	event CalledUpdate(address _oldCalled, address _newCalled);

}



contract IERC20Token {

    function name() public view returns (string);

    function symbol() public view returns (string);

    function decimals() public view returns (uint8);

    function totalSupply() public view returns (uint256);

    function balanceOf(address _holder) public view returns (uint256);

    function allowance(address _from, address _spender) public view returns (uint256);



    function transfer(address _to, uint256 _value) public returns (bool success);

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    function approve(address _spender, uint256 _value) public returns (bool success);

    

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    event Approval(address indexed _holder, address indexed _spender, uint256 _value);

}



contract IDummyToken is IERC20Token, IERC223Token, IERC223Receiver, ICaller, IOwned{

    // these function isn't abstract since the compiler emits automatically generated getter functions as external

    function operator() public pure returns(ITokenOperator) {}

    //ITokenOperator public operator;

}



contract ISmartToken{

    function disableTransfers(bool _disable) public;

    function issue(address _to, uint256 _amount) public;

    function destroy(address _from, uint256 _amount) public;

	//function() public payable;

}



contract ITokenOperator is ISmartToken, ICalled, ICaller {

    // this function isn't abstract since the compiler emits automatically generated getter functions as external

    function dummy() public pure returns (IDummyToken) {}

    

	function emitEventTransfer(address _from, address _to, uint256 _amount) public;



    function updateChanges(address) public;

    function updateChangesByBrother(address, uint256, uint256) public;

    

    function token_name() public view returns (string);

    function token_symbol() public view returns (string);

    function token_decimals() public view returns (uint8);

    

    function token_totalSupply() public view returns (uint256);

    function token_balanceOf(address _owner) public view returns (uint256);

    function token_allowance(address _from, address _spender) public view returns (uint256);



    function token_transfer(address _from, address _to, uint256 _value) public returns (bool success);

    function token_transfer(address _from, address _to, uint _value, bytes _data) public returns (bool success);

    function token_transfer(address _from, address _to, uint _value, bytes _data, string _custom_fallback) public returns (bool success);

    function token_transferFrom(address _spender, address _from, address _to, uint256 _value) public returns (bool success);

    function token_approve(address _from, address _spender, uint256 _value) public returns (bool success);

    

    function fallback(address _from, bytes _data) public payable;                      		// eth input

    function token_fallback(address _token, address _from, uint _value, bytes _data) public returns(bool);    // token input from IERC233

}



contract IsContract {

	//assemble the given address bytecode. If bytecode exists then the _addr is a contract.

    function isContract(address _addr) internal view returns (bool is_contract) {

        uint length;

        assembly {

              //retrieve the size of the code on target address, this needs assembly

              length := extcodesize(_addr)

        }

        return (length>0);

    }

}



contract Owned is IOwned {

    address public owner;

    address public newOwner;



    /**

        @dev constructor

    */

    constructor() public {

        owner = msg.sender;

    }



    // allows execution by the owner only

    modifier ownerOnly {

        assert(msg.sender == owner);

        _;

    }



    /**

        @dev allows transferring the contract ownership

        the new owner still needs to accept the transfer

        can only be called by the contract owner



        @param _newOwner    new contract owner

    */

    function transferOwnership(address _newOwner) public ownerOnly {

        require(_newOwner != owner);

        newOwner = _newOwner;

    }



    /**

        @dev used by a new owner to accept an ownership transfer

    */

    function acceptOwnership() public {

        require(msg.sender == newOwner);

        emit OwnerUpdate(owner, newOwner);

        owner = newOwner;

        newOwner = address(0x0);

    }

}



contract Constant {

	bytes32 internal constant _$FM_							= "$FM";

	bytes32 internal constant _$FM2_						= "$FM2";

	bytes32 internal constant _$FI_							= "$FI";

	bytes32 internal constant _$FO_							= "$FO";

	bytes32 internal constant _$FD_							= "$FD";

	bytes32 internal constant _$FD2_						= "$FD2";

	bytes32 internal constant _$F_							= "$F";

	bytes32 internal constant _$F2R_						= "$F2R";

	bytes32 internal constant _$FR_							= "$FR";

	bytes32 internal constant _ETHER_						= "ETHER";//EtherToken will be registered to Data in XCoin.js => registerContract

	bytes32 internal constant _Eventer_						= "Eventer";//Eventer will be registered to Data in XCoin.js => registerContract

	

	bytes32 internal constant _$FOD_						= "$FOD";

	bytes32 internal constant _totalSupply_					= "totalSupply";

	bytes32 internal constant _balanceOf_					= "balanceOf";

	bytes32 internal constant _lastTime_					= "lastTime";

	bytes32 internal constant _factorDrawLots_				= "factorDrawLots";

	bytes32 internal constant _eraDrawLots_					= "eraDrawLots";

	//bytes32 internal constant _drawLots_					= "drawLots";

	

	bytes32 internal constant _weightIssue_					= "weightIssue";

	bytes32 internal constant _privatePlacing_				= "privatePlacing";

	bytes32 internal constant _priceInit_					= "priceInit";

	bytes32 internal constant _softCap_						= "softCap";

	bytes32 internal constant _ratioGiftMax_				= "ratioGiftMax";

	bytes32 internal constant _weightOfReserve_				= "weightOfReserve";

	bytes32 internal constant _weightOfTarget_				= "weightOfTarget";

	bytes32 internal constant _decelerationRatioDividend_	= "decelerationRatioDividend";

	bytes32 internal constant _ratioDividend_				= "ratioDividend";

	bytes32 internal constant _investmentSF_				= "investmentSF";

	bytes32 internal constant _investmentEth_				= "investmentEth";

	bytes32 internal constant _profitSF_					= "profitSF";

	bytes32 internal constant _profitEth_					= "profitEth";

	bytes32 internal constant _returnSF_					= "returnSF";

	bytes32 internal constant _returnEth_					= "returnEth";

	bytes32 internal constant _emaDailyYieldSF_				= "emaDailyYieldSF";

	bytes32 internal constant _emaDailyYield_				= "emaDailyYield";

	bytes32 internal constant _timeLastMiningSF_			= "timeLastMiningSF";

	bytes32 internal constant _timeLastMining_				= "timeLastMining";

	bytes32 internal constant _factorMining_				= "factorMining";

	bytes32 internal constant _projectStatus_				= "projectStatus";

	bytes32 internal constant _projectAddr_					= "projectAddr";

	bytes32 internal constant _projectID_					= "projectID";

	bytes32 internal constant _proposeID_					= "proposeID";

	bytes32 internal constant _disproposeID_				= "disproposeID";

	bytes32 internal constant _projects_					= "projects";

	bytes32 internal constant _projectsVoting_				= "projectsVoting";

	bytes32 internal constant _thresholdPropose_			= "thresholdPropose";

	bytes32 internal constant _divisorAbsent_				= "divisorAbsent";

	bytes32 internal constant _timePropose_					= "timePropose";

	bytes32 internal constant _votes_						= "votes";

	bytes32 internal constant _factorDividend_				= "factorDividend";

	bytes32 internal constant _projectIdCount_				= "projectIdCount";

	bytes32 internal constant _projectInfo_					= "projectInfo";

	bytes32 internal constant _recommenders_				= "recommenders";

	bytes32 internal constant _recommendations_				= "recommendations";

	bytes32 internal constant _rewardRecommend_				= "rewardRecommend";

	bytes32 internal constant _halfRewardBalanceOfRecommender_ = "halfRewardBalanceOfRecommender";

	bytes32 internal constant _agents_						= "agents";

	bytes32 internal constant _factorInvitationOfAgent_		= "factorInvitationOfAgent";

	bytes32 internal constant _factorPerformanceOfAgent_	=	"factorPerformanceOfAgent";

	bytes32 internal constant _performanceOfAgent_			= "performanceOfAgent";

	bytes32 internal constant _lastPerformanceOfAgent_		= "lastPerformanceOfAgent";

	//bytes32 internal constant _invitationOfAgentLock_		= "invitationOfAgentLock";

	bytes32 internal constant _invitationOfAgent_			= "invitationOfAgent";

	//bytes32 internal constant _lockedOfAgent_				= "lockedOfAgent";

	bytes32 internal constant _unlockedOfAgent_				= "unlockedOfAgent";

    bytes32 internal constant _agentIssuable_				= "agentIssuable";

    bytes32 internal constant _agentThreshold_              = "agentThreshold";

    bytes32 internal constant _rewardAgent_                 = "rewardAgent";

	bytes32 internal constant _$FP_						    = "$FP";

	bytes32 internal constant _invitation_					= "invitation";

    bytes32 internal constant _agent_						= "agent";

	bytes32 internal constant _channel_					    = "channel";

	bytes32 internal constant _channels_					= "channels";

	bytes32 internal constant _rewardChannel_				= "rewardChannel";

	bytes32 internal constant _rate0DrawLotsOrder_			= "rate0DrawLotsOrder";

	bytes32 internal constant _thresholdAccelDequeueOrder_	= "thresholdAccelDequeueOrder";

	bytes32 internal constant _periodQuotaOrder_			= "periodQuotaOrder";

	bytes32 internal constant _project$f_			        = "project$f";

	bytes32 internal constant _projectEth_			        = "projectEth";

	bytes32 internal constant _etherAmount_			        = "etherAmount";

	bytes32 internal constant _Recommend_			        = "Recommend";

	

	bytes32 internal constant _Price_						= 0xdedeab50b97b0ea258580c72638be71c84db2913f449665c5275cdb7f93c0409;	//keccak256("Price(bytes32,uint256,int256,uint256,uint256,uint256,uint256,uint256)");	

	// bytes32 internal constant _Weight_						= 0x3656cc39179451c68688a96cd746a26d3368cf97102e851c0c60a0bad65bfaf4;	//keccak256("Weight(bytes32,uint256,uint256,uint256,uint256,uint256,uint256,uint256)");

	// bytes32 internal constant _WeightIssue_					= 0xee865ae6bcc111b5853d9ac0495880f947e4aebeb181b1a6d904d58299e1cced;	//keccak256("WeightIssue(address,address,uint256,uint256,uint256,uint256)");

	// bytes32 internal constant _PrivatePlacement_			= 0x94eb37bbe0c54785ce84a078083aede618c2abba7d7b271e7b625ddf4d1282ee;	//keccak256("PrivatePlacement(address,address,uint256,uint256,uint256)");

	// bytes32 internal constant _Propose_					= 0x87ada46c836271e669e6bc9ba0bc9669495237e101c5291363d524bc8fc32568;	//keccak256("Propose(address,bytes32,bytes32,address,uint256,uint256)");

	// bytes32 internal constant _Dispropose_					= 0xc85e60c2ee8acdaa9f49d4541531b118e86d4018c9c2a0ff7556076a5ff01870;	//keccak256("Dispropose(address,bytes32,bytes32)");

	// bytes32 internal constant _UpdateProject_				= 0xa7f00da0cc536d861fb6f017f8234042f6e26699f3cd9103da6895e93c118125;	//keccak256("UpdateProject(address,bytes32,address,address)");

	// bytes32 internal constant _ReturnProfit_				= 0xba17bd6ee981e52122b986aa98e10567c311e15b7d6dad085bf94e896ed65e66;	//keccak256("ReturnProfit(address,bytes32,uint256,uint256)");

	// bytes32 internal constant _ReturnDisinvestment_			= 0x95211a7460b6a58c8ba08a59a584a7bf992e651f1c6379ed788ddefc41bee305;	//keccak256("ReturnDisinvestment(address,bytes32,uint256,uint256)");

	// bytes32 internal constant _RegisterRecommender_			= 0xfcb064cbe1c349ea06a55b745fcd262396cc7cdbee9589806d350b65df959bc4;	//keccak256("RegisterRecommender(address,bytes32,bool,uint256)");

	// bytes32 internal constant _RegisterAgent_				= 0x2afb1b2d5349ff0163b230509f92d4c12ab9854d4c76bc5f25339e2816a3d48a;	//keccak256("RegisterAgent(address,uint256,uint256)");

	// bytes32 internal constant _AgentAppend_					= 0x5ac70b7391396d39d0973d5ffa4bd81a1c430996801ef8c5661cc43d348c94c9;	//keccak256("AgentAppend(address,uint256,uint256)");

	// bytes32 internal constant _AgentLock_					= 0x12bb003ebbc79a167959a883f0e69272f5040dfc75d4b47e59fd84a803bf74a9;	//keccak256("AgentLock(address,uint256,uint256)");

	// bytes32 internal constant _IssueInvitationOfAgent_		= 0x03ffb74238869c35f07683aa632e0c375c3a24a1c57eb9d4c98c2aa7ec703ff7;	//keccak256("IssueInvitationOfAgent(address,uint256)");

	// bytes32 internal constant _AgentUnlock_					= 0xe172d5d2fe66445fce354d0d2be616095b5b12adbdb7bef4ebfba1ee9b7f2831;	//keccak256("AgentUnlock(address,uint256)");

	// bytes32 internal constant _BindRecommender_				= 0xe4d100017ba2dd1d43322b2387da2814945070a0503d88bf058d454061c44fca;	//keccak256("BindRecommender(address,address,bytes32,address)");

	// bytes32 internal constant _Transfer_					= 0x5f2147fb558c977441fbdfebcf8cd5776606adc8da5ff95566fc2a4137e54d13;	//keccak256("Transfer(address,address,uint256,address)");

	// bytes32 internal constant _Dequeue_					= 0x8ed4de10d9e943b936b256947298f9d79289495a4db8b55f9452da76721f0791;	//keccak256("Dequeue(address,uint256,address,uint256)");

	// bytes32 internal constant _DequeueOrder_				= 0xcc45326a7be89070b5e24ad2502035f73c92d306b6aab85d5116f3e9538bd9cf;	//keccak256("DequeueOrder(address,uint256,uint256)");

	// bytes32 internal constant _DequeueIngot_				= 0xbd1f3a5aca027a47b1833e8de51edf3d32ec6ffce34268ff5d3022f70bde1794;	//keccak256("DequeueIngot(address,uint256,uint256)");

	// bytes32 internal constant _Vote_						= 0xea430f6241d8ab7a4a7da7b9487de059426309628c9c8e7b3e9438f0f431f39e;	//keccak256("Vote(address,bytes32,bytes32,uint256)");

	// bytes32 internal constant _VoteResult_					= 0xa0de2ad353f45bfcc398ad86d3575629f76b3c353ca88ce789602fb9ae5d207c;	//keccak256("VoteResult(bytes32,bytes32,bool,uint256,uint256,uint256)");

	// bytes32 internal constant _Config_						= 0x4691be92868fa80845b397f0e016905e1b4322422075895b96f9b4a8f1d918cf;	//keccak256("Config(bytes32,bytes32,uint256)");

	// bytes32 internal constant _Invest_						= 0x130d745954fedb61791b614172f696ffb5219aa14649d625534e8ff825bd68cd;	//keccak256("Invest(bytes32,address,uint256,uint256)");

	// bytes32 internal constant _Disinvest_					= 0x386d6f5f13437a36e2cf423819da85f6dd09bdbc5f4be7e41c0680904b10d7fd;	//keccak256("Disinvest(bytes32,address)");

	// bytes32 internal constant _DepositEth_					= 0x7034bb05cfe54b0d147fc0574ed166101e7f0313eb404e113974fbe2a998ca83;	//keccak256("DepositEth(address,uint256)");

	// bytes32 internal constant _WithdrawEth_					= 0xb48511ae3e574699605a84740498056f77d218c60c8d7e0e1dee31b9c90fd745;	//keccak256("WithdrawEth(address,address,uint256,bool)");

	// bytes32 internal constant _Forging_					= 0x5409965f0a48c519c9ae4c920bd726a7d8ee91475b3d372ac7484ce2989ffc37;	//keccak256("Forging(address,uint256)");

	// bytes32 internal constant _Purchase_					= 0x3a53f56a211d9f64ed2c86f99e1aa48b4837ed6d63abc0f07ac29d32fe75e230;	//keccak256("Purchase(address,bytes32,uint256,bool,bool)");

	// bytes32 internal constant _CancelOrder_					= 0xc0e68d6b69f741c21e955cad2ae4d505b6f6735c7e7b278251b3f6283a5f07eb;	//keccak256("CancelOrder(address,uint256)");

	// bytes32 internal constant _Lock4Dividend_				= 0xdfd1f12277f9150ae1d758207187dfe823fe860e003119517a71ab60b3d10809;	//keccak256("Lock4Dividend(address,uint256)");

	// bytes32 internal constant _Unlock4Circulate_			= 0x5dd61c8c2501b31d45e1deddbdac925d30d8075094ef1d89588d6353f89a4821;	//keccak256("Unlock4Circulate(address,uint256)");

	// bytes32 internal constant _Apply4Redeem_				= 0xb117f62e1089a5c238e5631cb0a8903798ecfe12e1bb415d18856d168f7b70ec;	//keccak256("Apply4Redeem(address,uint256)");

	// bytes32 internal constant _CancelRedeem_				= 0x56d7520e387607a8daa892e3fed116badc2a636307bdc794b1c1aed97ae203f4;	//keccak256("CancelRedeem(address,uint256)");

	// bytes32 internal constant _Redeem_						= 0x222838db2794d11532d940e8dec38ae307ed0b63cd97c233322e221f998767a6;	//keccak256("Redeem(address,uint256)");

	bytes32 internal constant _RecommendPerformance_		= 0xdff59f3289527807a9634eaf83388e1f449e1f0fd75b01141ed33783d13763bb;	//keccak256("RecommendPerformance(address,address,bytes32,uint256,uint256)");

	bytes32 internal constant _RecommendReward_				= 0xea4e2775055f2f3a80aed6e1fd67888ab02b8cdd276b2983ac96b18965c864ca;	//keccak256("RecommendReward(address,address,bytes32,uint256,uint256,uint256)");



    //uint256 internal constant PROJECT_STATUS_PROPOSING		= uint256(bytes32("PROJECT_STATUS_PROPOSING"));

    uint256 internal constant PROJECT_STATUS_VOTING			= uint256(bytes32("PROJECT_STATUS_VOTING"));

    uint256 internal constant PROJECT_STATUS_FAIL			= uint256(bytes32("PROJECT_STATUS_FAIL"));

    uint256 internal constant PROJECT_STATUS_PASS			= uint256(bytes32("PROJECT_STATUS_PASS"));

    uint256 internal constant PROJECT_STATUS_INVESTED		= uint256(bytes32("PROJECT_STATUS_INVESTED"));

    //uint256 internal constant PROJECT_STATUS_DISPROPOSING	= uint256(bytes32("PROJECT_STATUS_DISPROPOSING"));

    uint256 internal constant PROJECT_STATUS_DISVOTING	    = uint256(bytes32("PROJECT_STATUS_DISVOTING"));

    uint256 internal constant PROJECT_STATUS_DISINVESTING	= uint256(bytes32("PROJECT_STATUS_DISINVESTING"));

    uint256 internal constant PROJECT_STATUS_DISINVESTED	= uint256(bytes32("PROJECT_STATUS_DISINVESTED"));

    

    //uint256 internal constant VOTE_YES                      = uint256(bytes32("VOTE_YES"));

    //uint256 internal constant VOTE_NO                       = uint256(bytes32("VOTE_NO"));

    //uint256 internal constant VOTE_CANCEL                   = uint256(bytes32("VOTE_CANCEL"));

    bytes32 internal constant VOTE_YES                      = "VOTE_YES";

    bytes32 internal constant VOTE_NO                       = "VOTE_NO";

    bytes32 internal constant VOTE_CANCEL                   = "VOTE_CANCEL";

    

}



contract IFund {

	function returnProfit(bytes32 _projectID, uint256 _eth, uint256 _sf) public;

	function returnDisinvestment(bytes32 _projectID, uint256 _eth, uint256 _sf) public;

}



contract IProject is ICaller {

	function invest(bytes32 _projectID, uint256 _eth, uint256 _sf) public;

	function disinvest() public;

}



contract IData is ICalled{

    // these function isn't abstract since the compiler emits automatically generated getter functions as external

    function bu(bytes32) public pure returns(uint256) {}

    function ba(bytes32) public pure returns(address) {}

    //function bi(bytes32) public pure returns(int256) {}

    //function bs(bytes32) public pure returns(string) {}

    //function bb(bytes32) public pure returns(bytes) {}

    

    function bau(bytes32, address) public pure returns(uint256) {}

    //function baa(bytes32, address) public pure returns(address) {}

    //function bai(bytes32, address) public pure returns(int256) {}

    //function bas(bytes32, address) public pure returns(string) {}

    //function bab(bytes32, address) public pure returns(bytes) {}

    

    function bbu(bytes32, bytes32) public pure returns(uint256) {}

    function bbs(bytes32, bytes32) public pure returns(string) {}



    function buu(bytes32, uint256) public pure returns(uint256) {}

    function bua(bytes32, uint256) public pure returns(address) {}

	function bus(bytes32, uint256) public pure returns(string) {}

    function bas(bytes32, address) public pure returns(string) {}

    //function bui(bytes32, uint256) public pure returns(int256) {}

    //function bus(bytes32, uint256) public pure returns(string) {}

    //function bub(bytes32, uint256) public pure returns(bytes) {}

    

    function bauu(bytes32, address, uint256) public pure returns(uint256) {}

	//function baau(bytes32, address, address) public pure returns(uint256) {}

    function bbau(bytes32, bytes32, address) public pure returns(uint256) {}

    //function buuu(bytes32, uint256, uint256) public pure returns(uint256) {}

    function bbaau(bytes32, bytes32, address, address) public pure returns(uint256) {}

    

    function setBU(bytes32 _key, uint256 _value) public;

    function setBA(bytes32 _key, address _value) public;

    //function setBI(bytes32 _key, int256 _value) public;

    //function setBS(bytes32 _key, string _value) public;

    //function setBB(bytes32 _key, bytes _value) public;

    

    function setBAU(bytes32 _key, address _addr, uint256 _value) public;

    //function setBAA(bytes32 _key, address _addr, address _value) public;

    //function setBAI(bytes32 _key, address _addr, int256 _value) public;

    //function setBAS(bytes32 _key, address _addr, string _value) public;

    //function setBAB(bytes32 _key, address _addr, bytes _value) public;

    

    function setBBU(bytes32 _key, bytes32 _id, uint256 _value) public;

    function setBBS(bytes32 _key, bytes32 _id, string _value) public;



    function setBUU(bytes32 _key, uint256 _index, uint256 _value) public;

    function setBUA(bytes32 _key, uint256 _index, address _addr) public;

	function setBUS(bytes32 _key, uint256 _index, string _str) public;

    //function setBUI(bytes32 _key, uint256 _index, int256 _value) public;

    //function setBUB(bytes32 _key, uint256 _index, bytes _value) public;



	//function setBAAU(bytes32 _key, address _token, address _addr, uint256 _value) public;

	function setBAUU(bytes32 _key, address _addr, uint256 _index, uint256 _value) public;

    function setBBAU(bytes32 _key, bytes32 _id, address _holder, uint256 _value) public;

	//function setBUUU(bytes32 _key, uint256 _index,  uint256 _index2, uint256 _value) public;

    function setBBAAU(bytes32 _key, bytes32 _id, address _from, address _to, uint256 _value) public;

}



contract I$martFund is IFund, IOwned, ICaller {



    function checkQuotaPropose(uint256 _eth, uint256 _sf) public view returns(bool);

    function propose(bytes32 _projectID, bytes32 _proposeID, IProject _project, uint256 _eth, uint256 _sf, string _mixInfo) public;

    function dispropose(bytes32 _projectID, bytes32 _disproposeID, string _mixInfo) public;

	function getVotes(bytes32 _ID, bytes32 _vote) public view returns(uint256);

    function vote(bytes32 _ID, bytes32 _vote) public;



	function forging(uint256 _msm) public;

    function purchase(bool _wantDividend, bool _nonInvate, bytes32 _channel, bytes32 _recommendation) public payable;

    function cancelOrder(uint256 _mso) public returns(uint256 eth);

    function lock4Dividend(uint256 _msd2_ms) public returns(uint256 msd);

    function unlock4Circulate(uint256 _msd) public returns(uint256 msd2);



    function transferMS(address _to, uint256 _ms) public returns (bool success);

    function transferMSI(address _to, uint256 _msi) public returns (bool success);

    function transferMSM(address _to, uint256 _msm) public returns (bool success);



    function apply4Redeem(uint256 _ms) public returns(uint256 ms2r);

    function cancelRedeem(uint256 _ms2r_msr) public returns(uint256 ms);

    function redeem(uint256 msr) public returns(uint256 eth);

    

}



contract SafeMath {

    // Overflow protected math functions



    /**

        @dev returns the sum of _x and _y, asserts if the calculation overflows



        @param _x   value 1

        @param _y   value 2



        @return sum

    */

    function safeAdd(uint256 _x, uint256 _y) internal pure returns (uint256) {

        uint256 z = _x + _y;

        require(z >= _x);        //assert(z >= _x);

        return z;

    }



    /**

        @dev returns the difference of _x minus _y, asserts if the subtraction results in a negative number



        @param _x   minuend

        @param _y   subtrahend



        @return difference

    */

    function safeSub(uint256 _x, uint256 _y) internal pure returns (uint256) {

        require(_x >= _y);        //assert(_x >= _y);

        return _x - _y;

    }



    /**

        @dev returns the product of multiplying _x by _y, asserts if the calculation overflows



        @param _x   factor 1

        @param _y   factor 2



        @return product

    */

    function safeMul(uint256 _x, uint256 _y) internal pure returns (uint256) {

        uint256 z = _x * _y;

        require(_x == 0 || z / _x == _y);        //assert(_x == 0 || z / _x == _y);

        return z;

    }

	

	function safeDiv(uint256 _x, uint256 _y)internal pure returns (uint256){

	    // assert(b > 0); // Solidity automatically throws when dividing by 0

        // uint256 c = a / b;

        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return _x / _y;

	}

	

	function ceilDiv(uint256 _x, uint256 _y)internal pure returns (uint256){

		return (_x + _y - 1) / _y;

	}

}



contract Sqrt {

	function sqrt(uint x)public pure returns(uint y) {

        uint z = (x + 1) / 2;

        y = x;

        while (z < y) {

            y = z;

            z = (x / z + z) / 2;

        }

    }

}



contract DataCaller is Owned, ICaller {

    IData public data;

    

    constructor(IData _data) public {

        data = IData(_data);

    }

    

    function calledUpdate(address _oldCalled, address _newCalled) public ownerOnly {

        if(data == _oldCalled) {

            data = IData(_newCalled);

            emit CalledUpdate(_oldCalled, _newCalled);

        }

    }

}



contract GetBU is DataCaller {

    function getBU(bytes32 _key) internal view returns(uint256) {

        return data.bu(_key);        

    }

}



contract SetBU is DataCaller {

    function setBU(bytes32 _key, uint256 _value) internal {

        data.setBU(_key, _value);    

    }

}



contract Disable is Owned {

	bool public disabled;

	

	modifier enabled {

		assert(!disabled);

		_;

	}

	

	function disable(bool _disable) public ownerOnly {

		disabled = _disable;

	}

}



contract IReserve is ICalled {

    // these function isn't abstract since the compiler emits automatically generated getter functions as external

    function balanceOfColdWallet() public pure returns(uint256) {}

    function balanceOfShares() public pure returns(uint256) {}

    function balanceOfOrder() public pure returns(uint256) {}

    function balanceOfMineral() public pure returns(uint256) {}

    function balanceOfProject() public pure returns(uint256) {}

    function balanceOfQueue() public pure returns(uint256) {}

    function headOfQueue() public pure returns(uint256){}

    function tailOfQueue() public view returns(uint256);

    

    function setColdWallet(address _coldWallet, uint256 _ratioAutoSave, uint256 _ratioAutoRemain) public;

	function saveToColdWallet(uint256 _amount) public;

    function restoreFromColdWallet() public payable;



    function depositShares() public payable;

    function depositOrder() public payable;

    function depositMineral() public payable;

    function depositProject() public payable;

    

    function order2Shares(uint256 _amount) public;

    function mineral2Shares(uint256 _amount) public;

    function shares2Project(uint256 _amount)public;

    function project2Shares(uint256 _amount)public;

    function project2Mineral(uint256 _amount) public;

	

    function withdrawShares(uint256 _amount) public returns(bool atonce);

    function withdrawSharesTo(address _to, uint256 _amount) public returns(bool atonce);

    function withdrawOrder(uint256 _amount) public returns(bool atonce);

    function withdrawOrderTo(address _to, uint256 _amount) public returns(bool atonce);

    function withdrawMineral(uint256 _amount) public returns(bool atonce);

    function withdrawMineralTo(address _to, uint256 _amount) public returns(bool atonce);

    function withdrawProject(uint256 _amount)public returns(bool atonce);

    function withdrawProjectTo(address _to, uint256 _amount)public returns(bool atonce);

    

	function() public payable;

}



contract IFormula is IOwned, ICaller {

    uint8 public constant MAX_PRECISION = 127;

    uint32 public constant MAX_WEIGHT = 1000000;

    function reserve() public pure returns(IReserve) { }



    function totalSupply() public view returns (uint256);

    function balanceOf(address _addr)public view returns(uint256);

    function price() view public returns(uint256);

    //function costOfTxShares() view public returns(uint256);

    

	function calcTimedQuota(uint256 _rest, uint256 _full, uint256 _timespan, uint256 _period) public pure returns (uint256);

    function calcEma(uint256 _emaPre, uint256 _value, uint32 _timeSpan, uint256 _period) public view returns(uint256);

    //function calcFactorReward(uint256 _dailyYield) public view returns(uint256);

	function calcFactorMining(uint256 _roi) public view returns(uint256);

    

	function calcOrderTo$fAmount(uint256) public view returns(uint256);

	//function calc$martFundAmount(uint256 _amount, uint256 _factorRestrain) public view returns(uint256);



    function calculatePurchaseReturn(uint256 _supply, uint256 _connectorBalance, uint32 _connectorWeight, uint256 _depositAmount) public constant returns (uint256);

    function calculateRedeemReturn(uint256 _supply, uint256 _connectorBalance, uint32 _connectorWeight, uint256 _sellAmount) public constant returns (uint256);

	

    function power(uint256 _baseN, uint256 _baseD, uint32 _expN, uint32 _expD) public view returns (uint256, uint8);

    function power2(uint256 _baseN, uint256 _baseD, uint32 _expN, uint32 _expD) public view returns (uint256, uint8);

    function ln(uint256 _numerator, uint256 _denominator) public pure returns (uint256);

    

}



contract I$martFundImpl is ICalled, ICaller {

    uint256 public constant DEQUEUE_DEFAULT             = 0;

    uint256 public constant DEQUEUE_ORDER               = 1;

    uint256 public constant DEQUEUE_INGOT               = 2;

    uint256 public constant DEQUEUE_DOUBLE              = 3;

    uint256 public constant DEQUEUE_DOUBLE_REVERSELY    = 4;

    uint256 public constant DEQUEUE_NONE                = 5;

    

	function data() public pure returns(IData){}

	function reserve() public pure returns(IReserve){}

	function formula() public pure returns(IFormula){}

	

    function dequeueOrder(uint256 gaslimit, bool force) public returns(uint256 dealt);

    function dequeueIngot(uint256 gaslimit, bool force) public returns(uint256 dealt);

    function dequeueAlternately(uint256 gaslimit, bool force) public returns(uint256 dealt);

    function dequeueDouble(uint256 gaslimit, bool force) public returns(uint256 dealt);

    function dequeue(bytes32 _when) public returns(uint256 dealt);



    function getVotes(bytes32 _ID, bytes32 _vote) public view returns(uint256);

	function impl_vote(address _holder, bytes32 _ID, bytes32 _vote) public;

    function impl_forging(address _from, uint256 _msm) public;

    function impl_purchase(address _from, bool _wantDividend, bool _nonInvate, bytes32 _channel) public payable;

    function impl_cancelOrder(address _from, uint256 _msm) public returns(uint256 eth);

    function impl_lock4Dividend(address _from, uint256 _msd2_ms) public returns(uint256 msd);

    function impl_unlock4Circulate(address _from, uint256 _msd) public returns(uint256 msd2);



    function impl_quotaApply4Redeem() view public returns(uint256);

    function impl_apply4Redeem(address _from, uint256 _ms) public returns(uint256 ms2r);

    function impl_cancelRedeem(address _from, uint256 _ms2r_msr) public returns(uint256 ms);

    function impl_redeem(address _from, uint256 msr) public returns(uint256 eth);

}



contract Enabled is Disable, GetBU {

	modifier enabled2 {

        require(!disabled && getBU("dappEnabled") != 0);

        _;

    }

}



contract DisableDapp is SetBU {

	function disableDapp(bool _disable) public ownerOnly {

		setBU("dappEnabled", _disable ? 0 : 1);

	}

}

    

contract GetBA is DataCaller {

    function getBA(bytes32 _key) internal view returns(address) {

        return data.ba(_key);        

    }

}



contract SetBA is DataCaller {

    function setBA(bytes32 _key, address _value) internal {

        data.setBA(_key, _value);    

    }

}



contract GetBAU is DataCaller {

    function getBAU(bytes32 _key, address _addr) internal view returns(uint256) {

        return data.bau(_key, _addr);        

    }

}



contract SetBAU is DataCaller {

    function setBAU(bytes32 _key, address _addr, uint256 _value) internal {

        data.setBAU(_key, _addr, _value);    

    }

}



contract GetBBU is DataCaller {

    function getBBU(bytes32 _key, bytes32 _id) internal view returns(uint256) {

        return data.bbu(_key, _id);

    }

}



contract SetBBU is DataCaller {

    function setBBU(bytes32 _key, bytes32 _id, uint256 _value) internal {

        data.setBBU(_key, _id, _value);    

    }

}



contract GetBBS is DataCaller {

    function getBBS(bytes32 _key, bytes32 _id) internal view returns(string) {

        return data.bbs(_key, _id);

    }

}



contract SetBBS is DataCaller {

    function setBBS(bytes32 _key, bytes32 _id, string _value) internal {

        data.setBBS(_key, _id, _value);    

    }

}



contract GetBUU is DataCaller {

    function getBUU(bytes32 _key, uint256 _index) internal view returns(uint256) {

        return data.buu(_key, _index);        

    }

}



contract SetBUU is DataCaller {

    function setBUU(bytes32 _key, uint256 _index, uint256 _value) internal {

        data.setBUU(_key, _index, _value);    

    }

}



contract GetBUA is DataCaller {

	function getBUA(bytes32 _key, uint256 _index) internal view returns(address) {

        return data.bua(_key, _index);        

    }

}



contract SetBUA is DataCaller {

	function setBUA(bytes32 _key, uint256 _index, address _addr) internal {

        data.setBUA(_key, _index, _addr);        

    }

}



contract GetBUS is DataCaller {

	function getBUS(bytes32 _key, uint256 _index) internal view returns(string) {

        return data.bus(_key, _index);        

    }

}



contract SetBUS is DataCaller {

	function setBUS(bytes32 _key, uint256 _index, string _str) internal {

        data.setBUS(_key, _index, _str);        

    }

}



contract GetBAUU is DataCaller {

	function getBAUU(bytes32 _key, address _addr, uint256 _index) internal view returns(uint256) {

        return data.bauu(_key, _addr, _index);        

    }

}



contract SetBAUU is DataCaller {

	function setBAUU(bytes32 _key, address _addr, uint256 _index, uint256 _value) internal {

        data.setBAUU(_key, _addr, _index, _value);    

    }

}



contract GetBBAU is DataCaller {

    function getBBAU(bytes32 _key, bytes32 _id, address _holder) internal view returns(uint256) {

        return data.bbau(_key, _id, _holder);

    }

}



contract SetBBAU is DataCaller {

    function setBBAU(bytes32 _key, bytes32 _id, address _holder, uint256 _value) internal {

        data.setBBAU(_key, _id, _holder, _value);    

    }

}



contract GetBBAAU is DataCaller {

    function getBBAAU(bytes32 _key, bytes32 _id, address _from, address _to) internal view returns(uint256) {

        return data.bbaau(_key, _id, _from, _to);        

    }

}



contract SetBBAAU is DataCaller {

    function setBBAAU(bytes32 _key, bytes32 _id, address _from, address _to, uint256 _value) internal {

        data.setBBAAU(_key, _id, _from, _to, _value);

    }

}



contract Destructor is Owned{

    function destruct() public ownerOnly {

        selfdestruct(owner);

    }

}



contract $martFund is Constant, I$martFund, IERC223Receiver, SafeMath, Sqrt, DataCaller, Enabled, DisableDapp, GetBA, GetBAU, SetBAU, GetBUA, SetBUA, GetBUU, SetBUU, GetBBU, SetBBU, GetBBAU, GetBUS, SetBUS, GetBAUU, Destructor{    //, RLPReader {

    IReserve public reserve;

    IFormula public formula;

    I$martFundImpl public impl;

    

    constructor(IData _data, IReserve _reserve, IFormula _formula, I$martFundImpl _impl) DataCaller(_data) public {

        reserve = _reserve;

        formula = _formula;

        impl = _impl;

    }



    function calledUpdate(address _oldCalled, address _newCalled) public ownerOnly {

        if(data == _oldCalled){

            data = IData(_newCalled);

        }else if(reserve == _oldCalled){

            reserve = IReserve(_newCalled);

        }else if(formula == _oldCalled){

            formula = IFormula(_newCalled);

        }else if(impl == _oldCalled){

			impl = I$martFundImpl(_newCalled);

		}else{

            return;

        }

        emit CalledUpdate(_oldCalled, _newCalled);

    }



    function updateEmaDailyYieldSF(uint256 _value) internal/*public*/ returns(uint256) {

        uint256 ema = getBU("emaDailyYieldSF");

        uint32 timeSpan = uint32(safeSub(now, getBU("timeLastMiningSF")));

		setBU("timeLastMiningSF", now);

        ema = formula.calcEma(ema, _value, timeSpan, 1 days);

        setBU("emaDailyYieldSF", ema);

        return ema;

    }



    function checkQuotaPropose(uint256 _eth, uint256 _sf) public view returns(bool) {

		uint256 totalSupply_ = formula.totalSupply();

		uint256 reserve_ = reserve.balanceOfShares();

		if(_sf * 1 ether > totalSupply_ * getBU("quotaPerProposeSF") || _eth * 1 ether > reserve_ * getBU("quotaPerProposeEth"))

			return false;

		for(uint256 id = getBUU(_projectsVoting_, 0x0); id != 0x0; id = getBUU(_projectsVoting_, id)) {

			_sf  += getBUU(_investmentSF_,  id);

			_eth += getBUU(_investmentEth_, id);

		}

		return _sf * 1 ether <= totalSupply_ * getBU("quotaAllProposeSF") && _eth * 1 ether <= reserve_ * getBU("quotaAllProposeEth");

	}

	

	event Propose(address indexed _holder, bytes32 indexed _projectID, bytes32 _proposeID, IProject _project, uint256 _eth, uint256 _sf);

    function propose(bytes32 _projectID, bytes32 _proposeID, IProject _project, uint256 _eth, uint256 _sf, string _mixInfo) public enabled2 {

		emit Propose(msg.sender, _proposeID, _projectID, _project, _eth, _sf);

		// emitEvent(_Propose_, bytes32(msg.sender), _projectID, uint256(_proposeID), uint256(_project), _eth, _sf);

		IDummyToken $fd = IDummyToken(getBA(_$FD_));

		require($fd.balanceOf(msg.sender) * 1 ether >= $fd.totalSupply() * getBU(_thresholdPropose_));	//, "Proponent has not enough $FD!"

		if(address(_project) != address(0x0))

			require(checkQuotaPropose(_eth, _sf));			//, "Too much financing!"

        

        if(_projectID == _proposeID) {							// first invest of the _projectID

            uint256 projectID = getBAU(_projectID_, _project);

			uint256 status = getBUU(_projectStatus_, projectID);

			require(projectID == 0 || status == PROJECT_STATUS_FAIL || status == PROJECT_STATUS_DISINVESTED);

            projectID = uint256(_projectID);

            setBAU(_projectID_, _project, projectID);

        }else{

            projectID = uint256(_projectID);

			require(getBAU(_projectID_, _project) == projectID);

			require(getBUU(_projectStatus_, projectID) == PROJECT_STATUS_INVESTED);	//, "Can't repropose a project which had not INVESTED!"

			uint256 proposeID = getBUU(_proposeID_, projectID);

			require(proposeID == 0 || proposeID == projectID || getBUU(_projectStatus_, proposeID) != PROJECT_STATUS_VOTING);

			uint256 disproposeID = getBUU(_disproposeID_, projectID);

			require(disproposeID == 0 || getBUU(_projectStatus_, disproposeID) == PROJECT_STATUS_FAIL);

        }

       

		proposeID = uint256(_proposeID);

        require(getBUU(_projectStatus_, proposeID) == 0x0);	//, "Can't propose same proposeID again!"

 		setBUU(_proposeID_, projectID, proposeID);

		setBUU(_projectID_, proposeID, projectID);

        setBUU(_projectStatus_, proposeID, PROJECT_STATUS_VOTING);

		setBUU(_timePropose_, proposeID, now);

		setBUA(_projectAddr_, proposeID, _project);

		setBUU(_investmentSF_, proposeID, _sf);

		setBUU(_investmentEth_, proposeID, _eth);

		setBUS(_projectInfo_, proposeID, _mixInfo);

		

		setBUU(_projects_, proposeID, getBUU(_projects_, 0x0));					// join projects list

		setBUU(_projects_, 0x0, proposeID);

		setBUU(_projectsVoting_, proposeID, getBUU(_projectsVoting_, 0x0));

		setBUU(_projectsVoting_, 0x0, proposeID);

		

		vote(_proposeID, VOTE_YES);

    }

    

    event Dispropose(address indexed _holder, bytes32 indexed _projectID, bytes32 _disproposeID);

    function dispropose(bytes32 _projectID, bytes32 _disproposeID, string _mixInfo) public enabled2 {

		emit Dispropose(msg.sender, _projectID, _disproposeID);

		// emitEvent(_Dispropose_, bytes32(msg.sender), _projectID, uint256(_disproposeID));

		uint256 projectID = uint256(_projectID);

		require(getBUU(_projectStatus_, projectID) == PROJECT_STATUS_INVESTED);	//, "Can't dispropose a project which had not INVESTED!"

		uint256 proposeID = getBUU(_proposeID_, projectID);

		require(proposeID == 0 || proposeID == projectID || getBUU(_projectStatus_, proposeID) != PROJECT_STATUS_VOTING);

		uint256 disproposeID = getBUU(_disproposeID_, projectID);

		require(disproposeID == 0 || getBUU(_projectStatus_, disproposeID) == PROJECT_STATUS_FAIL);		//, "The dispropose of the project already exist!"

		disproposeID = uint256(_disproposeID);

		require(getBUU(_projectStatus_, disproposeID) == 0x0);						//, "Can't dispropose same disproposeID again!"

		setBUU(_disproposeID_, projectID, disproposeID);

		setBUU(_projectID_, disproposeID, projectID);

        

		IDummyToken $fd = IDummyToken(getBA(_$FD_));

		require($fd.balanceOf(msg.sender) * 1 ether >= $fd.totalSupply() * getBU(_thresholdPropose_));	//, "Proponent has not enough $FD!"

		setBUU(_projectStatus_, disproposeID, PROJECT_STATUS_DISVOTING);

		setBUU(_timePropose_, disproposeID, now);

		setBUS(_projectInfo_, disproposeID, _mixInfo);

		

		setBUU(_projects_, disproposeID, getBUU(_projects_, 0x0));				// join projects list

		setBUU(_projects_, 0x0, disproposeID);

		setBUU(_projectsVoting_, disproposeID, getBUU(_projectsVoting_, 0x0));

		setBUU(_projectsVoting_, 0x0, disproposeID);

		

		vote(_disproposeID, VOTE_YES);

    }

    

    function getVotes(bytes32 _ID, bytes32 _vote) public view returns(uint256) {

		return impl.getVotes(_ID, _vote);

	}

	

    function vote(bytes32 _ID, bytes32 _vote) public enabled2 {

		uint256 status = getBUU(_projectStatus_, uint256(_ID));

		require(status == PROJECT_STATUS_VOTING || status == PROJECT_STATUS_DISVOTING);	//, "Project status is not VOTING or DISVOTING!"

		impl.impl_vote(msg.sender, _ID, _vote);

    }

    

    function voteYes(bytes32 _projectID) public {

		vote(_projectID, VOTE_YES);

	}

	

    function voteNo(bytes32 _projectID) public {

		vote(_projectID, VOTE_NO);

	}

	

    function voteCancle(bytes32 _projectID) public {

		vote(_projectID, VOTE_CANCEL);

	}

    

	event UpdateProject(address indexed _sender, bytes32 indexed _projectID, address _oldProject, address _newProject);

	function updateProject(address _oldProject, address _newProject) public ownerOnly {

        // assert(getBU("UpdateContract") == uint256(oldProject));

        uint256 id = getBAU(_projectID_, _oldProject);

        setBAU(_projectID_, _newProject, id);

        setBAU(_projectID_, _oldProject, 0);

        setBUA(_projectAddr_, id, _newProject);

		emit UpdateProject(msg.sender, bytes32(id), _oldProject, _newProject);

		// emitEvent(_UpdateProject_, bytes32(msg.sender), bytes32(id), uint256(_oldProject), uint256(_newProject));

    }

    

	event ReturnProfit(address indexed _sender, bytes32 indexed _projectID, uint256 _eth, uint256 _sf);

	function returnProfit(bytes32 _projectID, uint256 _eth, uint256 _sf) public enabled2 {

	    emit ReturnProfit(msg.sender, _projectID, _eth, _sf);

		// emitEvent(_ReturnProfit_, bytes32(msg.sender), _projectID, _eth, _sf);

		uint256 projectID = uint256(_projectID);

		if(_sf > 0) {

			setBUU(_profitSF_, projectID, safeAdd(getBUU(_profitSF_, projectID), _sf));

			setBU(_profitSF_, safeAdd(getBU(_profitSF_), _sf));

			uint256 ema = updateEmaDailyYieldSF(_sf);

			I$FM2_Operator addrMSM2O = I$FM2_Operator(IDummyToken(getBA(_$FM2_)).operator());

			uint256 ratioDividend = addrMSM2O.updateRatioDividend(_sf, ema);

			uint256 dividend = _sf * ratioDividend / 1 ether;

			uint256 supplyOld = formula.totalSupply();

			uint256 supplyNew = safeSub(supplyOld+dividend, _sf);

			uint256 weightOld = getBU(_weightOfReserve_);

			uint256 weightNew = weightOld * supplyOld / supplyNew;

			setBU(_weightOfReserve_, weightNew);

			uint256 reserve_ = reserve.balanceOfShares();

            emit Weight("returnProfit", weightNew, weightOld, reserve_, reserve_, supplyNew, supplyOld, reserve_*1 ether/weightOld*1 ether/supplyOld);

			// emitEvent(_Weight_, "returnProfit", bytes32(0), weightNew, weightOld, reserve_, reserve_, supplyNew, supplyOld, reserve_*1 ether/weightOld*1 ether/supplyOld);

			IDummyToken(getBA(_$F_)).operator().destroy(getBUA(_projectAddr_, projectID), _sf);

			addrMSM2O.dividend(dividend);

			setBU(_returnSF_, safeSub(safeAdd(getBU(_returnSF_), _sf), dividend));

		}

		if(_eth > 0) {

		    setBUU(_profitEth_, projectID, getBUU(_profitEth_, projectID) + _eth);

		    setBU(_profitEth_, getBU(_profitEth_) + _eth);

			reserve.project2Mineral(_eth);

            IEtherToken(getBA(_ETHER_)).destroy(getBUA(_projectAddr_, projectID), _eth);

			//updateEmaDailyYield(msg.value);

			//updateFactorReward();

			//setBU("hasNonceMark", hasNonceMark ? 1 : 0);

            setBAU(_projectID_, msg.sender, projectID);

			ITokenOperator(IDummyToken(getBA(_$FM_)).operator()).issue(msg.sender, _eth);

			impl.dequeue("dequeueWhenMining");

		}

	}

	

    event Weight(bytes32 indexed _cause, uint256 _weightNew, uint256 _weightOld, uint256 _reserveNew, uint256 _reserveOld, uint256 _supplyNew, uint256 _supplyOld, uint256 _price);

	event ReturnDisinvestment(address indexed _sender, bytes32 indexed _projectID, uint256 _eth, uint256 _sf);

	function returnDisinvestment(bytes32 _projectID, uint256 _eth, uint256 _sf) public enabled2 {

	    emit ReturnDisinvestment(msg.sender, _projectID, _eth, _sf);

		// emitEvent(_ReturnDisinvestment_, bytes32(msg.sender), _projectID, _eth, _sf);

		setBUU(_projectStatus_, uint256(_projectID), PROJECT_STATUS_DISINVESTED);

        setBUU(_disproposeID_, uint256(_projectID), 0);

        address project = getBUA(_projectAddr_, uint256(_projectID));

        setBAU(_projectID_, project, 0);//detach project with _projectID

		

		uint256 supply = formula.totalSupply();

		uint256 reserve_ = reserve.balanceOfShares(); 

		if(_sf > 0) {

			setBUU(_profitSF_, uint256(_projectID), safeAdd(getBUU(_profitSF_, uint256(_projectID)), _sf));

			setBU(_profitSF_, safeAdd(getBU(_profitSF_), _sf));

			setBU(_returnSF_, safeAdd(getBU(_returnSF_), _sf));

			uint256 weightOld = getBU(_weightOfReserve_);

			uint256 weightNew = weightOld * supply / safeSub(supply, _sf);

			setBU(_weightOfReserve_, weightNew);

            emit Weight("returnDisinvestment", weightNew, weightOld, reserve_, reserve_, safeSub(supply, _sf), supply, reserve_*1 ether/weightOld*1 ether/supply);

			// emitEvent(_Weight_, "returnDisinvestment", bytes32(0), weightNew, weightOld, reserve_, reserve_, safeSub(supply, _sf), supply, reserve_*1 ether/weightOld*1 ether/supply);

			IDummyToken(getBA(_$F_)).operator().destroy(project, _sf);

		}

		if(_eth > 0) {

			setBUU(_profitEth_, uint256(_projectID), getBUU(_profitEth_, uint256(_projectID)) + _eth);

			setBU(_profitEth_, getBU(_profitEth_) + _eth);

			setBU(_returnEth_, getBU(_returnEth_) + _eth);

			weightOld = getBU(_weightOfReserve_);

			weightNew = weightOld * (reserve_+_eth) / reserve_;

			setBU(_weightOfReserve_, weightNew);

            emit Weight("returnDisinvestment", weightNew, weightOld, reserve_+_eth, reserve_, supply, supply, reserve_*1 ether/weightOld*1 ether/supply);

			// emitEvent(_Weight_, "returnDisinvestment", bytes32(0), weightNew, weightOld, reserve_+_eth, reserve_, supply, supply, reserve_*1 ether/weightOld*1 ether/supply);

			// reserve.depositShares.value(_eth)();

            IEtherToken(getBA(_ETHER_)).destroy(project, _eth);

            reserve.project2Shares(_eth);

		}

	}

	

	function forging(uint256 _msm) public enabled {

        return impl.impl_forging(msg.sender, _msm);

    }

    

    function purchase(bool _wantDividend, bool _nonInvate, bytes32 _channel, bytes32 _recommendation) public payable enabled {

        if(_recommendation != 0)

            IRecommend(getBA(_Recommend_)).bindRecommenderImpl(msg.sender, _recommendation);

		if(msg.value > 0)

			return impl.impl_purchase.value(msg.value)(msg.sender, _wantDividend, _nonInvate, _channel);

    }



    function cancelOrder(uint256 _mso) public enabled returns(uint256 eth) {

        return impl.impl_cancelOrder(msg.sender, _mso);

    }

    

    function lock4Dividend(uint256 _msd2_ms) public enabled returns(uint256 msd) {

        return impl.impl_lock4Dividend(msg.sender, _msd2_ms);

    }

    

    function unlock4Circulate(uint256 _msd) public enabled returns(uint256 msd2) {

        return impl.impl_unlock4Circulate(msg.sender, _msd);

    }

    

    event Transfer(address indexed _from, address indexed _to, uint256 _value, address _token);

	function transferMS(address _to, uint256 _ms) public enabled returns(bool success) {

        return IDummyToken(getBA(_$F_)).operator().token_transfer(msg.sender, _to, _ms);

		emit Transfer(msg.sender, _to, _ms, getBA(_$F_));

		// emitEvent(_Transfer_, bytes32(msg.sender), bytes32(_to), _ms, uint256(getBA(_$F_)));

    }

    

    function transferMSI(address _to, uint256 _msi) public enabled returns(bool success) {

        return IDummyToken(getBA(_$FI_)).operator().token_transfer(msg.sender, _to, _msi);

		emit Transfer(msg.sender, _to, _msi, getBA(_$FI_));

		// emitEvent(_Transfer_, bytes32(msg.sender), bytes32(_to), _msi, uint256(getBA(_$FI_)));

    }

    

    function transferMSM(address _to, uint256 _msm) public enabled returns(bool success) {

        return IDummyToken(getBA(_$FM_)).operator().token_transfer(msg.sender, _to, _msm);

		emit Transfer(msg.sender, _to, _msm, getBA(_$FM_));

		// emitEvent(_Transfer_, bytes32(msg.sender), bytes32(_to), _msm, uint256(getBA(_$FM_)));

    }



    function apply4Redeem(uint256 _ms) public enabled returns(uint256 msr) {

        return impl.impl_apply4Redeem(msg.sender, _ms);

    }

    

    function cancelRedeem(uint256 _ms2r_msr) public enabled returns(uint256 ms) {

        return impl.impl_cancelRedeem(msg.sender, _ms2r_msr);

    }

    

    function redeem(uint256 _msr) public enabled returns(uint256 eth) {

        return impl.impl_redeem(msg.sender, _msr);

    }



    //event Dequeue(address indexed _holder, uint256 _dealt, address _token, uint256 _gaslimit);

    event DequeueOrder(address indexed _holder, uint256 _dealt, uint256 _gaslimit);

	function dequeueOrder(uint256 gaslimit) public enabled returns(uint256 dealt) {		// for urge order

		dealt = impl.dequeueOrder(gaslimit, true);

		//emit Dequeue(msg.sender, dealt, getBA(_$FO_), gaslimit);

		emit DequeueOrder(msg.sender, dealt, gaslimit);

		//emitEvent(_Dequeue_, bytes32(msg.sender), bytes32(0), dealt, uint256(getBA(_$FO_)), gaslimit);

		// emitEvent(_DequeueOrder_, bytes32(msg.sender), bytes32(0), dealt, gaslimit);

	}

    

    event DequeueIngot(address indexed _holder, uint256 _dealt, uint256 _gaslimit);

    function dequeueIngot(uint256 gaslimit) public enabled returns(uint256 dealt) {

		dealt = impl.dequeueIngot(gaslimit, true);

		//emit Dequeue(msg.sender, dealt, getBA(_$FM2_), gaslimit);

		emit DequeueIngot(msg.sender, dealt, gaslimit);

		//emitEvent(_Dequeue_, bytes32(msg.sender), bytes32(0), dealt, uint256(getBA(_$FM2_)), gaslimit);

		// emitEvent(_DequeueIngot_, bytes32(msg.sender), bytes32(0), dealt, gaslimit);

	}



    function nop()public{

    }

	

    function tokenFallback(address _from, uint _value, bytes _data) public enabled2 returns(bool){

        if(msg.sender == getBA(_$F_))

            return true;

        return false;

        _from;  _value; _data;

    }

	

    function() public payable{

        purchase(false, false, 0x0, 0x0);

    }

}



contract IRecommend{

    function bindRecommenderImpl(address _sender, bytes32 _recommendation) public returns(bool);

}



contract I$FM2_Operator {

	function updateRatioDividend(uint256 _amount, uint256 _ema) public returns(uint256 ratioDividend);

    function dequeueIngot(uint256 gaslimit, bool force) public returns(uint256);

	function dividend(uint256 _amount) public;

}



contract IEtherToken {

    function destroy(address _from, uint256 _eth) public;

}