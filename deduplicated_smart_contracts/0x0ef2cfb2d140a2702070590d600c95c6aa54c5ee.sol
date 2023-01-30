pragma solidity ^0.4.18;
pragma experimental ABIEncoderV2;

import './ERC20Interface.sol';
import './SafeMath.sol';

interface keeperv1 {
    function worked(address _job_contarct) external;
    function isValid(address _job_contarct , address _keeper) view external returns(bool);
}

interface JobContract {
    function work() external;
}

contract Keeper is keeperv1 {
    
    uint256 job_count = 0;
    
    uint256 max_token = 10000000000000000000;
    
    address manager;
    
    ERC20Interface token = ERC20Interface(0x02d7b659389d537912B313611cBC5a7F7Ed615A9);
    
    mapping(address => uint256) owner_job_count;
    
    mapping (uint256 => Job) jobs;

    mapping (address => uint256) balance;
    
    //first address is job address and second one is keeper address
    mapping (address => mapping(uint256 => address)) keeper;
    //first address is job address and second one is last index
    mapping (address => uint256) keeper_index;
    
    //first address is keeper address and second one is job address
    mapping (address =>  mapping(address => uint256)) jobs_bonde;
    
    mapping (address => uint256) completed_work_count;

    ////////////////
    ///improvment///
    ///////////////
    
    mapping (address => uint256) job2index;
    
    struct Job {
        address job_contarct;
        address owner;
        string job_name;
        string document_link;
        uint256 liquidity;
        uint256 reward;
        uint256 limit_call;
        uint256 last_call;
        uint256 min_xp;
        uint256 keeper_count;
        uint256 max_keeper_count;
    }

    constructor() public{
        manager = msg.sender;
    }
    
    //////////////////////////////////
    ///////// Main Functions /////////
    //////////////////////////////////
    
    //create new job
    function createJob(address _job_contarct, string _job_name , string _document_link , uint256 _liquidity , uint256 _reward , uint256 _max_keeper_count , uint256 _limit_call , uint _min_xp) public payable{
        
        //check for contract unique
        require(!hasJob(_job_contarct) , 'Job Is Already Added');
        
        //transfer token to contract
        require(token.transferFrom(msg.sender, address(this), _liquidity) == true , 'transfer failed');

        require(_min_xp <= 5 , 'max xp is 5');
        
        job_count++;
        
        jobs[job_count].job_contarct = _job_contarct;
        jobs[job_count].job_name = _job_name;
        jobs[job_count].document_link = _document_link;
        jobs[job_count].liquidity = _liquidity;
        jobs[job_count].max_keeper_count = _max_keeper_count;
        jobs[job_count].reward = _reward;
        jobs[job_count].limit_call = _limit_call;
        jobs[job_count].min_xp = _min_xp;
        jobs[job_count].last_call = now;
        jobs[job_count].keeper_count = 0;
        jobs[job_count].owner = msg.sender;
        
        job2index[_job_contarct] = job_count;
        
        owner_job_count[msg.sender]++;
    }
    
    function editJob(address _job_contarct , uint256 _liquidity , uint256 _reward , uint256 _limit_call , uint256 _min_xp , uint256 _max_keeper_count) public{
        Job storage _selected_job = getJob(_job_contarct);
        require(_selected_job.owner == msg.sender , 'You are not Job Owner');
        require(_min_xp <= 5 , 'max xp is 5');
        
        if(_liquidity > 0){
            //transfer token to contract
            require(token.transferFrom(msg.sender, address(this), _liquidity) == true , 'transfer failed');
        }
        
        _selected_job.liquidity = SafeMath.add(_liquidity , _selected_job.liquidity);
        _selected_job.reward = _reward;
        _selected_job.limit_call = _limit_call;
        _selected_job.max_keeper_count = _max_keeper_count;
        _selected_job.min_xp = _min_xp;
    }
    
    //bonde to a job
    function bonde(address _job_contarct , uint256 _amount) public{
        
        Job storage _selected_job = getJob(_job_contarct);
        
        require(balance[msg.sender] >= _amount , 'Insufficient token balance');
        require(minMax(_amount) >= _selected_job.min_xp , 'Insufficient token xp');
        require(!isKeeper(_job_contarct , msg.sender) , 'You are a job keeper');
        require((_selected_job.keeper_count < _selected_job.max_keeper_count) || (_selected_job.max_keeper_count == 0) , 'job user count limit is over');
                
        //subtract token balance
        balance[msg.sender] = SafeMath.sub(balance[msg.sender] , _amount);
        
        //bonde token to job
        jobs_bonde[msg.sender][_job_contarct] = _amount;
        
        // //add keeper to job
        keeper[_job_contarct][keeper_index[_job_contarct]] = msg.sender;
        keeper_index[_job_contarct]++;
        _selected_job.keeper_count++;
    }

    function unbonde(address _job_contarct) public{
        
        Job storage _selected_job = getJob(_job_contarct);

        
        require(isKeeper(_job_contarct , msg.sender) , 'You are not a job keeper');
    
        //get user bonde for this job
        uint256 _bonde_balance = jobs_bonde[msg.sender][_job_contarct] ;
    
        //add token balance to user
        balance[msg.sender] = SafeMath.add(balance[msg.sender] , _bonde_balance);
        
        //sub user balance from job
        jobs_bonde[msg.sender][_job_contarct] = 0;
    
        
        // //remove keeper from job
        uint256 _keeper_index = findJobKeeperIndex(_job_contarct);
        delete keeper[_job_contarct][_keeper_index];
        keeper_index[_job_contarct]--;
        _selected_job.keeper_count--;
    }
    
    function worked(address _job_contarct) external{

        uint256 _job_index = getJobIndexByAddressOrThrow(_job_contarct);
        Job storage _selected_job =  jobs[_job_index];   
        require(isKeeper(_job_contarct , msg.sender) && checkBalance(_selected_job) , "Transaction is Invalid");
        
        ///// Start do work 
        
        JobContract job2do = JobContract(_job_contarct);
        job2do.work();
        
        //// End do work
        
        //sub reward credit
        _selected_job.liquidity = SafeMath.sub(_selected_job.liquidity , _selected_job.reward);
        
        //add reward
        jobs_bonde[msg.sender][_job_contarct] = SafeMath.add(jobs_bonde[msg.sender][_job_contarct] , _selected_job.reward);
        completed_work_count[msg.sender]++;
        
        _selected_job.last_call = now;
    }
    
    function withdraw(uint256 _amount) public{
        
        require(_amount <= balance[msg.sender] , 'Insufficient Token Amount Balance');
    
        balance[msg.sender] = SafeMath.sub(balance[msg.sender] , _amount);
    
        token.approve(address(this) , _amount);

        require(token.transferFrom(address(this) , msg.sender , _amount) == true , 'Insufficient Token Amount In Repo');
        
    }
    
    //////////////////////////////////
    ///////// Show Functions /////////
    //////////////////////////////////
    
    function showKeeperJobBonde(address _job_contarct , address _keeper) public view returns(uint256){
        return jobs_bonde[_keeper][_job_contarct];
    }
    
    function showJobLiquidity(address _job_contarct) public view returns(uint256){
        return getJob(_job_contarct).liquidity;
    }
    
    function showAllJobs() public view returns(address[] , string[] , uint256[] , address[]){
        address[] memory _jobs_address = new address[](job_count);
        string[] memory _jobs_name = new string[](job_count);
        uint256[] memory _jobs_liquidity = new uint256[](job_count);
        address[] memory _jobs_owner = new address[](job_count);

        for(uint256 i = 1 ; i <= job_count ; i++){
            _jobs_address[i-1] = (jobs[i].job_contarct);
            _jobs_name[i-1] = (jobs[i].job_name);
            _jobs_liquidity[i-1] = (jobs[i].liquidity);
            _jobs_owner[i-1] = (jobs[i].owner);
        }
        
        return(_jobs_address , _jobs_name , _jobs_liquidity , _jobs_owner);
    }
    
    function showJobDetail(address _job_contarct) public view returns(address , address , string , string , uint256 , uint256 , uint256 , uint256 ,uint256 , uint256 ){
        
        Job storage _selected_job = getJob(_job_contarct);
        
        return(
            _selected_job.job_contarct ,
            _selected_job.owner ,
            _selected_job.job_name ,
            _selected_job.document_link ,
            _selected_job.liquidity ,
            _selected_job.reward ,
            _selected_job.keeper_count ,
            _selected_job.max_keeper_count ,
            _selected_job.limit_call ,
            _selected_job.min_xp
        );
    }
    
    function showFreeBalance(address _keeper) public view returns(uint256){
        return balance[_keeper];
    }
    
    function showCompletedWorkCount(address _keeper) public view returns(uint256){
        return completed_work_count[_keeper];
    }
    
    function showOwnedJob() public view returns(address[] , string[]){
        
        uint256 _job_count = owner_job_count[msg.sender];
        
        address[] memory _jobs_address = new address[](_job_count);
        string[] memory _jobs_name = new string[](_job_count);
        
        uint256 _index = 0;
        for(uint256 i = 1 ; i <= job_count ; i++){
            if(jobs[i].owner == msg.sender){
                _jobs_address[_index] = (jobs[i].job_contarct);
                _jobs_name[_index] = (jobs[i].job_name);
                _index++;
            }
        }
        
        return(_jobs_address , _jobs_name);
    }
    
    function showJobOwnedCount() public view returns(uint256){
        return owner_job_count[msg.sender];
    }
    
    function showXp(address _keeper) public view returns(uint256){
        return minMax(balance[_keeper]);
    }

    function showMaxToken() public view returns(uint256){
        
        return max_token;
    }
    
    function nextAvailabeCall(address _job_contarct) public view returns(uint256){
        Job storage _selected_job = getJob(_job_contarct);
        return _selected_job.limit_call + _selected_job.last_call;
    }
    
    ///////////////////////////////////
    ///////// Manger Functions/////////
    ///////////////////////////////////
    
    function changeMaxToken(uint256 _max_token) public{
        require(msg.sender == manager , "You Are NOT manger");
        max_token = _max_token;
    }
    
    ///////////////////////////////////////
    ///////// Helper Functions ////////////
    ///////////////////////////////////////
    
    function findJobKeeperIndex(address _job_contarct) internal view returns(uint256){
        uint256 _index = keeper_index[_job_contarct];
        bool _has_result = false;
        uint256 _result = 0;
        for(uint256 i = 0 ; i <= _index ; i++){
            if(keeper[_job_contarct][i] == msg.sender){
                _has_result = true;
                _result = i;
                break;
            }
        }
        
        require(_has_result , 'Keeper Not Found');
        
        return _result;
    }
    
    function hasJob(address _job_contarct) private constant returns (bool _result) {
        _result = false;
        
        uint256 index = job2index[_job_contarct];
        if(index != 0){
            _result = true;
        }
    }
    
    function minMax(uint256 _value) private view returns(uint256){
        if(_value > max_token){
            _value = max_token;
        }
        return SafeMath.div(SafeMath.mul(_value , 5) , max_token);
    }
    
    function isKeeper(address _job_contarct , address _keeper)public view returns (bool){
        bool _result = false;
        for(uint256 i = 0 ; i < keeper_index[_job_contarct] ; i++){
            if(keeper[_job_contarct][i] == _keeper){
                _result = true;
                break;
            }
        }
        return _result;
    }
    
    function getJobIndexByAddressOrThrow(address _job_contarct) internal view returns (uint256) {
        uint256 index = job2index[_job_contarct];
        require(index > 0 , 'Job not found');
        return index;
    }
    
    function checkBalance(Job storage _selected_job) internal view returns(bool){
        return _selected_job.liquidity >= _selected_job.reward;
    }
    
    function checkLastCall(Job storage _selected_job) internal view returns(bool _result){
        _result = false;
        if(_selected_job.last_call + _selected_job.limit_call <= now){
            _result = true;
        }
    }
    
    function isValid(address _job_contarct , address _keeper) external view returns (bool _result){
        
        uint256 _job_index = getJobIndexByAddressOrThrow(_job_contarct);
        Job storage _selected_job =  jobs[_job_index];        
        
        _result = true;
        if(!isKeeper(_job_contarct , _keeper)){
            _result = false;
        }
        if(!checkBalance(_selected_job)){
            _result = false;
        }
        if(!checkLastCall(_selected_job)){
            _result = false;
        }
    }
    
    function getJob(address _job_contarct) private view returns(Job storage){
        uint256 _job_index = getJobIndexByAddressOrThrow(_job_contarct);
        return jobs[_job_index];
    }
}