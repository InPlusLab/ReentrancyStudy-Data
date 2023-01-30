pragma solidity ^0.4.24;

import './StandardToken.sol';
import './Ownable.sol';

contract DFAToken is StandardToken, Ownable {

    string public name = 'DEFI ASSETS';
    string public symbol = 'DFA';
    uint8 public decimals = 6;
    // A_total_of_300_million
    uint public INITIAL_SUPPLY = 300000000 * (10 ** uint(decimals));
    

    //Array for release days. 
    //The following 10 years, tokens will be release on a monthly basis based on the days recorded
    uint[] public releaseDays;
    
    // 10% initial Address
    address public initialAddress = 0x35c4a0A5331B00E8E3e8af2d6bF87391B735C21E;
    // Fundpool
    uint[] public fundsPool;
    
    // White List
    address[] public whiteList;

    // Creation_time
    uint public createTime = 0;
    
    //DFA_fundpool_retrieving_event
    event WithdrawDFA(uint256 _value);

    // 
    event Burn(address _from, uint256 _value);
    
    constructor() public {
        // totalSupply 300000000
        totalSupply_ = INITIAL_SUPPLY;
        // 10%_supply
        balances[initialAddress] = INITIAL_SUPPLY / 10;
        emit Transfer(0x0, initialAddress, INITIAL_SUPPLY / 10);
        
        // Initial_fundpool_usage
        // 15%_team_and_consultant(distributed_across_five_years)
        fundsPool.push(INITIAL_SUPPLY * 15 / 100);
        // 35%_ecosystem_development(distributed_across_ten_years)
        fundsPool.push(INITIAL_SUPPLY * 35 / 100);
        // 40%_temporarily_be_used_for_upgrading_of_the_mainnet_with_the_burning_of_the_original_tokens(completed_in_one_year)
        fundsPool.push(INITIAL_SUPPLY * 40 / 100);
        
        // Initial_whitelist
        whiteList.push(0x35c4a0A5331B00E8E3e8af2d6bF87391B735C21E);  
        whiteList.push(0x75e2cc6cdfB4f3EF49fCcBFe0E2F7A7Ad4dDCFf1);  
        whiteList.push(0xff40C95213f5908F315B036e73879B647f2b4167);  
        whiteList.push(0xfEe93971c484886AA661751C5C971B72f4547c8E);  
        whiteList.push(0x1016C70A8A7181aa3EEA84880bCE854f07E91410);  
        whiteList.push(0xc4DA6E5Fa98926656A604068B56DAf4eBf0E5cd5);  
        whiteList.push(0x3aDc956184eC3266c2c90760c8c6A60AfBF5A279);  
        whiteList.push(0x8b95f4b54d8DdB969156e34adC992Bdcb051fb36);  
        whiteList.push(0x4BB8Be7369f145917A9AC475df3F79B9640366b0);  
        whiteList.push(0xdac18fAD59198b02Cc967BB5edC75B6e8881a851);  
        whiteList.push(0xA7cf173Af2143acD11330fa2c8748B19B79E3AA6);  
        whiteList.push(0xDA5Dd9Ca94cc689C4c5Ce42708b65BAE25279c74);  
        whiteList.push(0xfCCa5A8d5Ef0C6BA23AcbDBf2652565e8Bd1269b);  
        whiteList.push(0x20c1C8B34D96c312060a758f8f7440F7D6F9779d);  
        whiteList.push(0x11D8bE6c73FAF023117C226d08A08fF380571617);  
        whiteList.push(0x60a08Ba2688F1F94A8Ea3CB7e1F917c514E45f54);  
        whiteList.push(0x461cf291ecAa62A2eb682DBFF8d2b4B530334CD5);  
        whiteList.push(0x479Fd5A1c96a0109799Ecb9408d23f6F3CFA8613);  
        whiteList.push(0xbD05ACD1875e10aDCFF18897AA20a02c1EC51ec6);  
        whiteList.push(0x61Fd74d003FF9d557a5aF5a470611714ECDb5e45);  
        whiteList.push(0xF7fF79a41c7020361660d09312BAA67B659E7D4D);  
        
        // Recorded_creation_time
        createTime = now;

      
        // initialize the release time array (the nth element represents how much has passed since createTime Day is considered to be an array of days per month for the next 10 years after n+1 months, used to calculate the release time)
        releaseDays = [31,62,92,123,153,184,215,243,274,304,335,365,396,427,457,488,518,549,580,608,639,669,700,730,761,792,822,853,883,914,945,973,1004,1034,1065,1095,1126,1157,1187,1218,1248,1279,1310,1339,1370,1400,1431,1461,1492,1523,1553,1584,1614,1645,1676,1704,1735,1765,1796,1826,1857,1888,1918,1949,1979,2010,2041,2069,2100,2130,2161,2191,2222,2253,2283,2314,2344,2375,2406,2434,2465,2495,2526,2556,2587,2618,2648,2679,2709,2740,2771,2800,2831,2861,2892,2922,2953,2984,3014,3045,3075,3106,3137,3165,3196,3226,3257,3287,3318,3349,3379,3410,3440,3471,3502,3530,3561,3591,3622,3652];
    }
    
   // Only_the_contract_creator_has_the_right_to_allocate_DFA_from_fundpool
    function allocateDFA(
        address _receiver,
        uint256 _value,
        uint8 _poolIndex
    )
        public
        onlyOwner
        returns (bool)
    {
        require(_value > 0, "Allocating 0 DFA is not allowed.");
        require(_poolIndex >= 0 && _poolIndex < 3, "Pool index 0,1,2 is valid.");
        // Automatic zero padding
        _value = _value * (10 ** uint(decimals));
        // Search_whether_the_receiver_is_in_the_whitelist
        bool inWhiteList = false;
        for (uint i = 0; i < whiteList.length; i++) {
            if (whiteList[i] == _receiver) {
                inWhiteList = true;
                break;
            }
        }
        require(inWhiteList, "The receiver is not in the whitelist");
        
      
        //calculate_the_number_of_months_after_the_contract_announced
        uint d = (now - createTime) / 1 days;
        
        //calculated the month from the release time array,
        uint months = 0;
        while (months < 120) {
            if (d < releaseDays[months]) {
                break;
            } else {
                months++;
            }
        }
      

       // Leftover_DFA_amount_in_fundpool
        uint remain = fundsPool[_poolIndex];
       // Calculate_the_locked_DFA_amount
        uint locked = 0;
        // amount of DFAs  can be allocated at this time
        uint allocatableDFA = 0;
        // Calculate_the_allocated_DFA_amount
        if (_poolIndex == 0) { //  // split_into_five_years,_60_months
            locked = (60 >= months ? 60 - months : 0) * (INITIAL_SUPPLY * 15 / 100 / 60);
            allocatableDFA = remain >= locked ? remain - locked : 0;
        } else if (_poolIndex == 1) { //  split_into_ten_years,_120_months
            locked = (120 >= months ? 120 - months : 0) * (INITIAL_SUPPLY * 35 / 100 / 120);
            allocatableDFA = remain >= locked ? remain - locked : 0;
        } else if (_poolIndex == 2) { // Lock_for_one_year_and_available_after_one_year
            allocatableDFA = months >= 12 ? remain : 0;
        } else { // should not go to here
            allocatableDFA = 0;
        }
        
       // Allocate_DFAs_when_there_are_sufficient_DFAs_in_the_fundpool
        require(allocatableDFA >= _value, "Not enough DFAs to distribute in the fundpool");
        fundsPool[_poolIndex] = fundsPool[_poolIndex] - _value;
        balances[_receiver] = balances[_receiver].add(_value);
        emit Transfer(0x0, _receiver, _value);
        return true;
    }
    
    // The_contract_creator_has_the_right_to_destroy_DFA_in_the_fundpool
    function withdrawDFA(
        uint256 _value
    )
        public
        onlyOwner
        returns (bool)
    {
        require(_value > 0, "Retrieving 0 DFA is not allowed.");
        // Automatic zero padding
        _value = _value * (10 ** uint(decimals));
        require(fundsPool[2] >= _value, "The amount of DFA in the fundpool is insufficient to retrieve.");
        fundsPool[2] = fundsPool[2] - _value;
        totalSupply_ = totalSupply_ - _value;
        emit WithdrawDFA(_value);
        return true;
    }

       // _owner destroy DFA
    function burn(uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);                 // Check if the sender has enough
        balances[msg.sender] = balances[msg.sender] - _value;    // Subtract from the sender
        totalSupply_ = totalSupply_ - _value;                    // Updates totalSupply_
        emit Burn(msg.sender, _value);
        return true;
    }

    // Destroy DFA
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value);                                       // Check if the targeted balance is enough
        require(_value <= allowed[_from][msg.sender]);                            // Check allowance
        balances[_from] = balances[_from] - _value;                               // Subtract from the targeted balance
        allowed[_from][msg.sender] = allowed[_from][msg.sender] - _value;         // Subtract from the sender's allowance
        totalSupply_ = totalSupply_ - _value;                                     // Update totalSupply_
        emit Burn(_from, _value);
        return true;
    }
}