/**
 *Submitted for verification at Etherscan.io on 2020-03-29
*/

pragma solidity ^0.5.12;

contract HEX {
    function xfLobbyEnter(address referrerAddr)
    external
    payable;

    function xfLobbyExit(uint256 enterDay, uint256 count)
    external;

    function xfLobbyPendingDays(address memberAddr)
    external
    view
    returns (uint256[2] memory words);

    function balanceOf (address account)
    external
    view
    returns (uint256);

    function transfer (address recipient, uint256 amount)
    external
    returns (bool);

    function currentDay ()
    external
    view
    returns (uint256);
}

contract Router {

    struct CustomerState {
        uint16 nextPendingDay;
        mapping(uint256 => uint256) contributionByDay;
    }

    struct LobbyContributionState {
        uint256 totalValue;
        uint256 heartsReceived;
    }

    struct ContractStateCache {
        uint256 currentDay;
        uint256 nextPendingDay;
    }

    event LobbyJoined(
        uint40 timestamp,
        uint16 day,
        uint256 amount,
        address indexed customer,
        address indexed affiliate
    );

    event LobbyLeft(
        uint40 timestamp,
        uint16 day,
        uint256 hearts
    );

    event MissedLobby(
        uint40 timestamp,
        uint16 day
    );

    // from HEX
    uint16 private constant LAUNCH_PHASE_DAYS = 350;
    uint16 private constant LAUNCH_PHASE_END_DAY = 351;
    uint256 private constant XF_LOBBY_DAY_WORDS = (LAUNCH_PHASE_END_DAY + 255) >> 8;

    // constants & mappings we need
    HEX private constant hx = HEX(0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39);
    address private operatorOne;
    address private operatorTwo;
    address private operatorThree;
    address private operatorFour;
    address private operatorFive;
    address private constant splitter = 0x889c65411DeA4df35eF6F62252944409FD78054C;
    uint256 private contractNextPendingDay;
    uint256 public constant HEX_LAUNCH_TIME = 1575331200;
    mapping(address => uint8) private registeredAffiliates;
    mapping(uint256 => LobbyContributionState) private totalValueByDay;
    mapping(address => CustomerState) private customerData;
    mapping(uint8 => uint8) public affiliateRankPercentages;

    modifier operatorOnly() {
        require(msg.sender == operatorOne ||
                msg.sender == operatorTwo ||
                msg.sender == operatorThree ||
                msg.sender == operatorFour ||
                msg.sender == operatorFive,
                 "This operation is only allowed to be performed by the contract operator");
        _;
    }

    constructor()
    public
    {
        operatorOne = msg.sender;//SWIFT
        operatorTwo = address(0xD30BC4859A79852157211E6db19dE159673a67E2);//KYLE
        operatorThree = address(0x3487b398546C9b757921df6dE78EC308203f5830);//KEVIN
        operatorFour = address(0xbf1984B12878c6A25f0921535c76C05a60bdEf39);//MARCO
        operatorFive = msg.sender;//TBD
        contractNextPendingDay = _getHexContractDay(); // today is the next day to resolve
        affiliateRankPercentages[0] = 0;
        affiliateRankPercentages[1] = 50;
        affiliateRankPercentages[2] = 100;
    }

    function enterLobby(address customer, address affiliate)
    public
    payable
    {
        bool isAffiliate = false;
        uint8 affiliateLevel = registeredAffiliates[msg.sender];
        uint8 affiliateSplit = affiliateRankPercentages[affiliateLevel];
        if(affiliate != address(0) && affiliateSplit > 0){
            // real affiliate, use them for ref
            uint256 affiliateValue = msg.value * affiliateSplit / 100;
            isAffiliate = true;
            hx.xfLobbyEnter.value(affiliateValue)(affiliate);
            if(msg.value - affiliateValue > 0){
                hx.xfLobbyEnter.value(msg.value - affiliateValue)(splitter);
            }
        } else {
            hx.xfLobbyEnter.value(msg.value)(splitter);
        }

        // record customer contribution
        uint256 currentDay = _getHexContractDay();
        totalValueByDay[currentDay].totalValue += msg.value;
        customerData[customer].contributionByDay[currentDay] += msg.value;
        if(customerData[customer].nextPendingDay == 0){
            // new user
            customerData[customer].nextPendingDay = uint16(currentDay);
        }

        //if the splitter is used as referral, set the zero address as affiliate
        address referrerAddr = isAffiliate ? affiliate : address(0);
        emit LobbyJoined(
            uint40(block.timestamp),
            uint16(currentDay),
            msg.value,
            customer,
            referrerAddr
          );
    }

    function exitLobbiesBeforeDay(address customer, uint256 day)
    public
    {
        ContractStateCache memory state = ContractStateCache(_getHexContractDay(), contractNextPendingDay);
        uint256 _day = day > 0 ? day : state.currentDay;
        require(customerData[customer].nextPendingDay < _day,
            "Customer has no active lobby entries for this time period");
        _leaveLobbies(state, _day);
        // next pending day was updated as part of leaveLobbies
        contractNextPendingDay = state.nextPendingDay;
        _distributeShare(customer, _day);
    }

    function updateOperatorOne(address newOperator)
    public
    {
        require(msg.sender == operatorOne, "Operator may only update themself");
        require(newOperator != address(0),"New operator must be a non-zero address");
        operatorOne = newOperator;
    }

    function updateOperatorTwo(address newOperator)
    public
    {
        require(msg.sender == operatorTwo, "Operator may only update themself");
        require(newOperator != address(0),"New operator must be a non-zero address");
        operatorTwo = newOperator;
    }

    function updateOperatorThree(address newOperator)
    public
    {
        require(msg.sender == operatorThree, "Operator may only update themself");
        require(newOperator != address(0),"New operator must be a non-zero address");
        operatorThree = newOperator;
    }

    function updateOperatorFour(address newOperator)
    public
    {
        require(msg.sender == operatorFour, "Operator may only update themself");
        require(newOperator != address(0),"New operator must be a non-zero address");
        operatorFour = newOperator;
    }
    
    function updateOperatorFive(address newOperator)
    public
    {
        require(msg.sender == operatorFive, "Operator may only update themself");
        require(newOperator != address(0),"New operator must be a non-zero address");
        operatorFive = newOperator;
    }
    
    function registerAffiliate(address affiliateContract, uint8 affiliateRank)
    public
    operatorOnly
    {
        require(registeredAffiliates[affiliateContract] == 0, "Affiliate contract is already registered");
        registeredAffiliates[affiliateContract] = affiliateRank;
    }

    function updateAffiliateRank(address affiliateContract, uint8 affiliateRank)
    public
    operatorOnly
    {
        require(affiliateRank != registeredAffiliates[affiliateContract], "New Affiliate rank must be different than previous");
        require(affiliateRankPercentages[affiliateRank] >= affiliateRankPercentages[registeredAffiliates[affiliateContract]],
                "Cannot set an affiliateRank with lower percentage than previous");
        registeredAffiliates[affiliateContract] = affiliateRank;
    }

    function addAffiliateRank(uint8 affiliateRank, uint8 rankSplitPercentage)
    public
    operatorOnly
    {
        require(affiliateRankPercentages[affiliateRank] == 0, "Affiliate rank already exists");
        require(rankSplitPercentage > 0 && rankSplitPercentage <= 100,
            "Affiliate Split must be between 0-100%");
        affiliateRankPercentages[affiliateRank] = rankSplitPercentage;
    }

    function verifyAffiliate(address affiliateContract)
    public
    view
    returns (bool, uint8)
    {
        return (registeredAffiliates[affiliateContract] > 0, registeredAffiliates[affiliateContract]);
    }

    function batchLeaveLobby(uint256 day, uint256 batchSize)
    public
    {
        require(day < _getHexContractDay(), "You must only leave lobbies that have ended");
        uint256[XF_LOBBY_DAY_WORDS] memory joinedDays = hx.xfLobbyPendingDays(address(this));
        require((joinedDays[day >> 8] & (1 << (day & 255))) >> (day & 255) == 1, "You may only leave lobbies with active entries");

        uint256 balance = hx.balanceOf(address(this));
        _leaveLobby(day, batchSize, balance);
    }

    function ()
    external
    payable
    {
        if(msg.value > 0)
        {
          // If someone just sends eth, get them in a lobby with no affiliate, i.e. splitter
          enterLobby(msg.sender, address(0));
        }
          else
        {
          //if the transaction value is 0, exit lobbies instead
          exitLobbiesBeforeDay(msg.sender, 0);
        }
    }

    function _getHexContractDay()
    private
    view
    returns (uint256)
    {
        require(HEX_LAUNCH_TIME < block.timestamp, "Launch time not before current block");
        return (block.timestamp - HEX_LAUNCH_TIME) / 1 days;
    }

    function _leaveLobbies(ContractStateCache memory currentState, uint256 beforeDay)
    private
    {
        uint256 newBalance = hx.balanceOf(address(this));
        //uint256 oldBalance;
        if(currentState.nextPendingDay < beforeDay){
            uint256[XF_LOBBY_DAY_WORDS] memory joinedDays = hx.xfLobbyPendingDays(address(this));
            while(currentState.nextPendingDay < beforeDay){
                if( (joinedDays[currentState.nextPendingDay >> 8] & (1 << (currentState.nextPendingDay & 255))) >>
                    (currentState.nextPendingDay & 255) == 1){
                    // leaving 0 means leave "all"
                    newBalance = _leaveLobby(currentState.nextPendingDay, 0, newBalance);
                    emit LobbyLeft(uint40(block.timestamp),
                        uint16(currentState.nextPendingDay),
                        totalValueByDay[currentState.nextPendingDay].heartsReceived);
                } else {
                    emit MissedLobby(uint40(block.timestamp),
                     uint16(currentState.nextPendingDay));
                }
                currentState.nextPendingDay++;
            }
        }
    }

    function _leaveLobby(uint256 lobby, uint256 numEntries, uint256 balance)
    private
    returns (uint256)
    {
        hx.xfLobbyExit(lobby, numEntries);
        uint256 oldBalance = balance;
        balance = hx.balanceOf(address(this));
        totalValueByDay[lobby].heartsReceived += balance - oldBalance;
        require(totalValueByDay[lobby].heartsReceived > 0, "Hearts received for a lobby is 0");
        return balance;
    }

    function _distributeShare(address customer, uint256 endDay)
    private
    returns (uint256)
    {
        uint256 totalShare = 0;
        CustomerState storage user = customerData[customer];
        uint256 nextDay = user.nextPendingDay;
        if(nextDay > 0 && nextDay < endDay){
            while(nextDay < endDay){
                if(totalValueByDay[nextDay].totalValue > 0 && totalValueByDay[nextDay].heartsReceived > 0){
                    require(totalValueByDay[nextDay].heartsReceived > 0, "Hearts received must be > 0, leave lobby for day");
                    totalShare += user.contributionByDay[nextDay] *
                        totalValueByDay[nextDay].heartsReceived /
                        totalValueByDay[nextDay].totalValue;
                }
                nextDay++;
            }
            if(totalShare > 0){
                require(hx.transfer(customer, totalShare), strConcat("Failed to transfer ",uint2str(totalShare),", insufficient balance"));
            }
        }
        if(nextDay != user.nextPendingDay){
            user.nextPendingDay = uint16(nextDay);
        }

        return totalShare;
    }

    function uint2str(uint i)
    internal
    pure returns (string memory _uintAsString)
    {
        uint _i = i;
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len - 1;
        while (_i != 0) {
            bstr[k--] = byte(uint8(48 + _i % 10));
            _i /= 10;
        }
        return string(bstr);
    }

    function strConcat(string memory _a, string memory _b, string memory _c
    , string memory _d, string memory _e)
    private
    pure
    returns (string memory){
    bytes memory _ba = bytes(_a);
    bytes memory _bb = bytes(_b);
    bytes memory _bc = bytes(_c);
    bytes memory _bd = bytes(_d);
    bytes memory _be = bytes(_e);
    string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);
    bytes memory babcde = bytes(abcde);
    uint k = 0;
    for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];
    for (uint i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];
    for (uint i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];
    for (uint i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];
    for (uint i = 0; i < _be.length; i++) babcde[k++] = _be[i];
    return string(babcde);
    }

    function strConcat(string memory _a, string memory _b, string memory _c, string memory _d)
    private
    pure
    returns (string memory) {
        return strConcat(_a, _b, _c, _d, "");
    }

    function strConcat(string memory _a, string memory _b, string memory _c)
    private
    pure
    returns (string memory) {
        return strConcat(_a, _b, _c, "", "");
    }

    function strConcat(string memory _a, string memory _b)
    private
    pure
    returns (string memory) {
        return strConcat(_a, _b, "", "", "");
    }
}