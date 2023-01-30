pragma solidity ^0.4.24;

import "./LuckyDraw.sol";

contract Events {
    event newName(
        address indexed playerAddress,
        bytes32 indexed playerName,
        uint256 amountPaid,
        uint256 timeStamp
    );


    event onRoundEnd
    (
        DataStructs.EventReturns compressedData,
        address playerAddress,
        uint256 ethIn,
        uint256 keysBought,
        uint256 newPot,
        uint256 genAmount
    );
    event onWithdrawFunds
    (
        address playerAddress,
        uint256 ethOut,
        uint256 timeStamp
    );

    event onAffiliatePayout
    (
        uint256 indexed affiliateID,
        address affiliateAddress,
        bytes32 affiliateName,
        uint256 indexed roundID,
        uint256 indexed buyerID,
        uint256 amount,
        uint256 timeStamp
    );

    event onPotDeposit
    (
        uint256 roundID,
        uint256 amountAddedToPot
    );

    //  fired whenever a player tries a reinvest after round timer
    // hit zero, and causes end round to be ran.
    event onReLoadAndDistribute
    (
        address playerAddress,
        bytes32 playerName,
        uint256 compressedData,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot,
        uint256 genAmount
    );

    event topInvestorsDistribute(
        address first,
        address second,
        address third
    );

    event topPromotersDistribute(
        address first,
        address second,
        address third
    );

    event luckyDrawDeclared(
        address winner,
        uint256 amt,
        uint256 time
    );

    event nextRoundStarted(
        uint256 roundId,
        uint256 startTime,
        uint256 endTime
    );

}

contract GoldenKingdom is Events {
    using SafeMath for uint256;
    using NameFilter for string;

    LuckyDraw private luckyDraw;

    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    address public externalWallet;
    string constant public name = "Golden Kingdom";
    string constant public symbol = "GK";

    // Round duration
    uint256 constant private rndInit_ = 1 hours;                // round timer starts at this
    uint256 constant private rndInc_ = 180 seconds;              // every full key purchased adds this much to the timer
    uint256 constant private rndMax_ =  48 hours;               // max length a round timer can be

    uint256 public rID_;

    // Price of each key is 0.001 ETH
    uint256 public keyPrice = 1000000000000000;

    mapping (bytes32 => address) public pAddrxName;          // (addr => pName) returns player address by name
    mapping (address => DataStructs.Player) public plyr_;    // (addr => data) player data
    mapping (address => mapping (uint256 => DataStructs.PlayerRounds)) public plyrRnds_;     // (addr => rID => data) player round data by player id & round ids

    mapping(address => mapping(uint256 => uint256)) public playerEarned_; //How much amount a player has earned till now.(addr => rID => amount)
    mapping(address => mapping(uint256 => uint256)) public playerExtraEarnings_;
    mapping (uint256 => DataStructs.Round) public round_;   // (rID => data) round data

    mapping(address => uint256) internal referralBalance_;
    mapping(address => address) public firstReferrer;

    uint256 public keyHolderFees_;
    uint256 public treasureAmount_;
    uint256 public adminKeyVault_;
    uint256 public luckyDrawVault_;
    uint256 internal tokenInvestorsSupply_ = 0;
    uint256 public totalSupply_ = 0;

    uint256 lastLuckyDrawTime = 0;
    uint256 public lastLuckyDrawAmt = 0;
    uint256 luckyDrawDuration = 24 hours;
    bool public luckyDrawEnabled = true;

    uint256 lastPromoterDistTime = 0;
    uint256 lastInvestorDistTime = 0;
    uint256 topleaderboardDuration = 7 days;

    struct Leaderboard {
        uint256 amt;
        address addr;
    }

    //Promoters Datastructures
    Leaderboard[3] public topPromoters;
    uint256 public promoterDistRound;
    uint256 public topPromotersVault = 0;
    mapping(address => mapping(uint256 => uint256)) public promoters; // get promotional earnings by player and investment round
    address[3] public lastTopPromoters;

    //Investors Datastructures
    Leaderboard[3] public topInvestors;
    uint256 public investorDistRound;
    uint256 public topInvestorsVault = 0;
    mapping(address => mapping(uint256 => uint256)) public investors; // get investment by player and investment round
    address[3] public lastTopInvestors;

    constructor(address _externalWallet)
        public isHuman()
    {
        externalWallet = _externalWallet;
        keyHolderFees_ = 61;
        treasureAmount_ = 20;
        _owner = msg.sender;
        luckyDraw = LuckyDraw(address(0x486148A9b1e5ccBaA98811cc1Bd183Bb909bE2d4));
        lastLuckyDrawTime = now;
        lastPromoterDistTime = now;
        lastInvestorDistTime = now;
        promoterDistRound = 1;
        investorDistRound = 1;
    }

    /**
     * @dev allows only the user to run the function
     */
    modifier onlyOwner() {
        require(msg.sender == _owner, "only Owner");
        _;
    }

     /**
     * @dev allows only the external wallet to run the function
     */
    modifier onlyExternalWallet() {
        require(msg.sender == externalWallet, "only External Wallet can call this function");
        _;
    }

    /**
     * @dev used to make sure no one can interact with contract until it has
     * been activated.
     */
    modifier isActivated() {
        require(activated_ == true, "ouch, contract is not ready yet !");
        _;
    }


    /**
     * @dev prevents contracts from interacting
     */
    modifier isHuman() {
        require(msg.sender == tx.origin, "nope, you're not an Human buddy !!");
        _;
    }

    /**
     * @dev sets boundaries for incoming tx
     */
    modifier isWithinLimits(uint256 _eth) {
        require(_eth >= 50000000000000000, "Minimum contribution amount is 0.05 ETH");
        _;
    }
//-------------------------------------------------------------------------------------------------------//
//-------------------------------------------------------------------------------------------------------//

    function changeKeyPrice(uint256 _amt)
        onlyOwner()
        public
    {
        keyPrice = _amt;
    }

    function changeExternalWallet(address _newAddress)
    onlyOwner()
    public
    returns (bool)
    {
        require(_newAddress != address(0x0));

        externalWallet = _newAddress;
        return true;

    }

    function ()
        isHuman()
        isWithinLimits(msg.value)
        isActivated()
        public
        payable
    {
        //set up our tx event data and determine if player is new or not
        DataStructs.EventReturns memory _eventData_ =  _eventData_;

        // fetch player id
         address _playerAddr = msg.sender;

        // buy core
        purchaseCore(_playerAddr, 0x0, _eventData_);
    }

     /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Returns true if the caller is the current owner.
     */
    function isOwner() public view returns (bool) {
        return msg.sender == _owner;
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

     /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), "New owner cannot be the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function stopLuckyDraw()
        onlyOwner()
        public
    {
        require(luckyDrawEnabled = true, "Luckydraw is already stopped");
        luckyDrawEnabled = false;
    }

    function startLuckyDraw()
        onlyOwner()
        public
    {
        require(luckyDrawEnabled = false, "Lucky draw is already running");
        luckyDrawEnabled = true;
    }


    function reinvestDividendEarnings(uint256 _keys)
        isHuman()
        isActivated()
        private
    {

        address _playerAddr = msg.sender;

        // set up our tx event data and determine if player is new or not
        DataStructs.EventReturns memory _eventData_ = _eventData_;

        address _affAddr = firstReferrer[msg.sender];
        uint256 _eth = _keys.mul(keyPrice).div(1000000000000000000);
        uint256 _rID = rID_;

        if (plyrRnds_[_playerAddr][_rID].keys == 0) {
            _eventData_ = managePlayer(_playerAddr, _eventData_);
            round_[_rID].playerCounter = round_[_rID].playerCounter + 1;

        }

        // if they reinvest at least 1 whole key
        if (_keys >= 1000000000000000000)
        {
            updateTimer(_keys, _rID);

            // set new leaders
            if (round_[_rID].plyr != _playerAddr)
                round_[_rID].plyr = _playerAddr;

            // set the new leader bool to true
            _eventData_.compressedData = _eventData_.compressedData + 100;
        }

        // update player
        plyrRnds_[_playerAddr][_rID].keys = (_keys.mul(1).div(100)).add(plyrRnds_[_playerAddr][_rID].keys);
        plyrRnds_[_playerAddr][_rID].eth = plyrRnds_[_playerAddr][_rID].eth.add(_eth);
        plyr_[_playerAddr].eth = plyr_[_playerAddr].eth.add(_eth);

        // update round
        round_[_rID].keys = _keys.add(round_[_rID].keys);
        round_[_rID].eth = round_[_rID].eth.add(_eth);
        investors[_playerAddr][investorDistRound] = investors[_playerAddr][investorDistRound].add(_eth);
        addInvestor(_playerAddr);
        luckyDraw.add(_playerAddr);

        //check if its been over a day since the last lucky draw happened
        if (now.sub(lastLuckyDrawTime) >= luckyDrawDuration  && luckyDrawEnabled == true){
            //pick a winner and transfer winnings to account
            address luckyDrawWinner = luckyDraw.draw();
            plyr_[luckyDrawWinner].gen = plyr_[luckyDrawWinner].gen.add(luckyDrawVault_);
            lastLuckyDrawAmt = luckyDrawVault_;
            luckyDrawVault_ = 0;
            lastLuckyDrawTime = now;
            emit luckyDrawDeclared(luckyDrawWinner, lastLuckyDrawAmt, now);
        }


        _eventData_ = distributeInternal(_rID, _playerAddr, _affAddr, _keys, _eventData_);

    }

    function reinvestReferralEarnings(uint256 _keys)
        isHuman()
        isActivated()
        private
    {

        address _playerAddr = msg.sender;

        // set up our tx event data and determine if player is new or not
        DataStructs.EventReturns memory _eventData_ = _eventData_;

        address _affAddr = firstReferrer[msg.sender];
        uint256 _eth = _keys.mul(keyPrice).div(1000000000000000000);
        uint256 _rID = rID_;

        if (plyrRnds_[_playerAddr][_rID].keys == 0) {
            _eventData_ = managePlayer(_playerAddr, _eventData_);
            round_[_rID].playerCounter = round_[_rID].playerCounter + 1;

        }

        // if they reinvest at least 1 whole key
        if (_keys >= 1000000000000000000)
        {
            updateTimer(_keys, _rID);

            // set new leader
            if (round_[_rID].plyr != _playerAddr)
                round_[_rID].plyr = _playerAddr;

            // set the new leader bool to true
            _eventData_.compressedData = _eventData_.compressedData + 100;
        }
        // update player
        plyrRnds_[_playerAddr][_rID].keys = (_keys.mul(1).div(100)).add(plyrRnds_[_playerAddr][_rID].keys);
        plyrRnds_[_playerAddr][_rID].eth = plyrRnds_[_playerAddr][_rID].eth.add(_eth);
        plyr_[_playerAddr].eth = plyr_[_playerAddr].eth.add(_eth);

        // update round
        round_[_rID].keys = _keys.add(round_[_rID].keys);
        round_[_rID].eth = round_[_rID].eth.add(_eth);

        investors[_playerAddr][investorDistRound] = investors[_playerAddr][investorDistRound].add(_eth);
        addInvestor(_playerAddr);
        luckyDraw.add(_playerAddr);

        //check if its been over a day since the last lucky draw happened
        if (now.sub(lastLuckyDrawTime) >= luckyDrawDuration && luckyDrawEnabled == true){
            //pick a winner and transfer winnings to account
            address luckyDrawWinner = luckyDraw.draw();
            plyr_[luckyDrawWinner].gen = plyr_[luckyDrawWinner].gen.add(luckyDrawVault_);
            lastLuckyDrawAmt = luckyDrawVault_;
            luckyDrawVault_ = 0;
            lastLuckyDrawTime = now;
            emit luckyDrawDeclared(luckyDrawWinner, lastLuckyDrawAmt, now);
        }


        _eventData_ = distributeInternal(_rID, _playerAddr, _affAddr, _keys, _eventData_);

    }

    function reinvestAllEarnings()
        isHuman()
        isActivated()
        public
    {

        address _playerAddr = msg.sender;
        uint256 _rID = rID_;
        uint256 eth = 0;
        uint256 _now = now;

        // set up our tx event data
        DataStructs.EventReturns memory _eventData_ = _eventData_;

        //Check if the round is running, then only the player can reinvest
        if (_now > round_[_rID].strt && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
        {

            updateGenVault(_playerAddr, plyr_[_playerAddr].lrnd);

            uint256 _keys = referralBalance_[_playerAddr].add(plyr_[_playerAddr].gen);
            require(_keys > 0, "Sorry, you don't have sufficient earning to reinvest");

            //make the player referral earnings to 0.
            playerEarned_[_playerAddr][_rID] = playerEarned_[_playerAddr][_rID].add(plyr_[_playerAddr].gen);
            referralBalance_[_playerAddr] = 0;
            plyr_[_playerAddr].gen = 0;

            address _affAddr = firstReferrer[msg.sender];
            uint256 _eth = _keys.mul(keyPrice).div(1000000000000000000);
            eth = _eth;

            if (plyrRnds_[_playerAddr][_rID].keys == 0) {
            _eventData_ = managePlayer(_playerAddr, _eventData_);
            round_[_rID].playerCounter = round_[_rID].playerCounter + 1;

        }


            // if they reinvest at least 1 whole key
            if (_keys >= 1000000000000000000)
            {
            updateTimer(_keys, _rID);

            // set new leaders
            if (round_[_rID].plyr != _playerAddr)
                round_[_rID].plyr = _playerAddr;

            // set the new leader bool to true
            _eventData_.compressedData = _eventData_.compressedData + 100;
            }
            // update player
            plyrRnds_[_playerAddr][_rID].keys = (_keys.mul(1).div(100)).add(plyrRnds_[_playerAddr][_rID].keys);
            plyrRnds_[_playerAddr][_rID].eth = plyrRnds_[_playerAddr][_rID].eth.add(_eth);
            plyr_[_playerAddr].eth = plyr_[_playerAddr].eth.add(_eth);

            // update round
            round_[_rID].keys = _keys.add(round_[_rID].keys);
            round_[_rID].eth = round_[_rID].eth.add(_eth);


            // distribute keys amongst all
             _eventData_ = distributeInternal(_rID, _playerAddr, _affAddr, _keys, _eventData_);
        }
        // if round is not active and end round needs to be ran
        else if (_now > round_[_rID].end && round_[_rID].ended == false) {
            // end the round (distributes treasure)
            round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);

            // build event data
            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
            //_eventData_.compressedIDs = _eventData_.compressedIDs + _pID;

            // fire buy and distribute event
            emit Events.onReLoadAndDistribute
            (
                msg.sender,
                plyr_[_playerAddr].name,
                _eventData_.compressedData,
               // _eventData_.compressedIDs,
                _eventData_.winnerAddr,
                _eventData_.winnerName,
                _eventData_.amountWon,
                _eventData_.newPot,
                _eventData_.genAmount
            );
        }

        investors[_playerAddr][investorDistRound] = investors[_playerAddr][investorDistRound].add(eth);
        addInvestor(_playerAddr);
        luckyDraw.add(_playerAddr);

        //check if its been over a day since the last lucky draw happened
        if (now.sub(lastLuckyDrawTime) >= luckyDrawDuration  && luckyDrawEnabled == true){
            //pick a winner and transfer winnings to account
            address luckyDrawWinner = luckyDraw.draw();
            plyr_[luckyDrawWinner].gen = plyr_[luckyDrawWinner].gen.add(luckyDrawVault_);
            lastLuckyDrawAmt = luckyDrawVault_;
            luckyDrawVault_ = 0;
            lastLuckyDrawTime = now;
            emit luckyDrawDeclared(luckyDrawWinner, lastLuckyDrawAmt, now);
        }

    }

    function withdrawDividendEarnings()
        isActivated()
        isHuman()
        public
    {
        uint256 _now = now;
        uint256 _rID = rID_;

        address _playerAddress = msg.sender;

        // set up our tx event data
        DataStructs.EventReturns memory _eventData_ = _eventData_;

        //Is the round active, then only withdraw can happen
        if (_now > round_[_rID].strt  && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
        {
            updateGenVault(_playerAddress, plyr_[_playerAddress].lrnd);

            uint256 _earnings = plyr_[_playerAddress].gen + plyr_[_playerAddress].win;

            if(_earnings > 0)
            {
                uint256 _withdrawAmount = (_earnings.div(2)).mul(keyPrice).div(1000000000000000000);
                uint256 _reinvestAmount = _earnings.div(2);
                _earnings = 0;

                require(address(this).balance >= _withdrawAmount, "Contract doesn't have sufficient amount to give you");

                playerEarned_[_playerAddress][_rID] = playerEarned_[_playerAddress][_rID].add(plyr_[_playerAddress].gen);
                plyr_[_playerAddress].gen = 0;
                plyr_[_playerAddress].win = 0;
                totalSupply_ = totalSupply_.sub(_reinvestAmount);

                address(msg.sender).transfer(_withdrawAmount);
                reinvestDividendEarnings(_reinvestAmount);
            }

            // fire withdraw event
            emit Events.onWithdrawFunds
            (
                msg.sender,
                _withdrawAmount,
                now
            );

        }

        // if round is not active and end round needs to be ran
        else if (_now > round_[_rID].end && round_[_rID].ended == false) {
            // end the round (distributes treasure)
            round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);

            // build event data
            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);

            // fire buy and distribute event
            emit Events.onReLoadAndDistribute
            (
                msg.sender,
                plyr_[_playerAddress].name,
                _eventData_.compressedData,
                _eventData_.winnerAddr,
                _eventData_.winnerName,
                _eventData_.amountWon,
                _eventData_.newPot,
                _eventData_.genAmount
            );
        }


    }

    function withdrawReferralEarnings ()
        isHuman()
        isActivated()
        public
     {

        address _playerAddress = msg.sender;
        // set up our tx event data
        DataStructs.EventReturns memory _eventData_ = _eventData_;

        require(referralBalance_[_playerAddress] > 0, "Sorry, you can't withdraw 0 referral earning");

        uint256 _now = now;
        uint256 _rID = rID_;

        //Is the round active, then only withdraw can happen
        if (_now > round_[_rID].strt  && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
        {
            uint256 _earnings = referralBalance_[_playerAddress];

            if(_earnings > 0)
            {
                uint256 _withdrawAmount = (_earnings.div(2)).mul(keyPrice).div(1000000000000000000);
                uint256 _reinvestAmount = _earnings.div(2);
                _earnings = 0;

                require(address(this).balance >= _withdrawAmount, "Contract doesn't have sufficient amount to give you");

                referralBalance_[_playerAddress] = 0;

                totalSupply_ = totalSupply_.sub(_reinvestAmount);

                address(msg.sender).transfer(_withdrawAmount);
                reinvestReferralEarnings(_reinvestAmount);

                // fire withdraw event
                emit Events.onWithdrawFunds
                (
                    msg.sender,
                    _withdrawAmount,
                    now
                );
            }
        }

        // if round is not active and end round needs to be ran
        else if (_now > round_[_rID].end && round_[_rID].ended == false) {
            // end the round (distributes treasure)
            round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);

            // build event data
            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);

            // fire buy and distribute event
            emit Events.onReLoadAndDistribute
            (
                msg.sender,
                plyr_[_playerAddress].name,
                _eventData_.compressedData,
                _eventData_.winnerAddr,
                _eventData_.winnerName,
                _eventData_.amountWon,
                _eventData_.newPot,
                _eventData_.genAmount
            );
        }

     }

     function distributeTopInvestors()
        onlyOwner()
        public
    {
        if (now.sub(lastInvestorDistTime) >= topleaderboardDuration){

            uint256 totAmt = topInvestorsVault;
            topInvestorsVault = 0;
            investorDistRound = investorDistRound.add(1);

            address first = topInvestors[0].addr;
            address second  = topInvestors[1].addr;
            address third  = topInvestors[2].addr;

            plyr_[first].gen = plyr_[first].gen.add(totAmt.mul(50).div(100));
            topInvestors[0].addr = address(0x0);
            topInvestors[0].amt = 0;

            plyr_[second].gen = plyr_[second].gen.add(totAmt.mul(30).div(100));
            topInvestors[1].addr = address(0x0);
            topInvestors[1].amt = 0;

            plyr_[third].gen = plyr_[third].gen.add(totAmt.mul(20).div(100));
            topInvestors[2].addr = address(0x0);
            topInvestors[2].amt = 0;

            lastTopInvestors[0] = first;
            lastTopInvestors[1] = second;
            lastTopInvestors[2] = third;

            emit topInvestorsDistribute(first, second, third);
        }
        else{
            revert("There is still time or a round is running");
        }
    }

    function distributeTopPromoters()
        onlyOwner()
        public
    {
        if (now.sub(lastPromoterDistTime) >= topleaderboardDuration){

            uint256 totAmt = topPromotersVault;
            topPromotersVault = 0;
            investorDistRound = investorDistRound.add(1);

            address first = topPromoters[0].addr;
            address second  = topPromoters[1].addr;
            address third  = topPromoters[2].addr;

            plyr_[first].gen = plyr_[first].gen.add(totAmt.mul(50).div(100));
            topPromoters[0].addr = address(0x0);
            topPromoters[0].amt = 0;

            plyr_[second].gen = plyr_[second].gen.add(totAmt.mul(30).div(100));
            topPromoters[1].addr = address(0x0);
            topPromoters[1].amt = 0;

            plyr_[third].gen = plyr_[third].gen.add(totAmt.mul(20).div(100));
            topPromoters[2].addr = address(0x0);
            topPromoters[2].amt = 0;

            lastTopPromoters[0] = first;
            lastTopPromoters[1] = second;
            lastTopPromoters[2] = third;

            emit topPromotersDistribute(first, second, third);

        }
        else{
            revert("There is still time.");
        }
    }

    function addPromoter(address _add)
        isActivated()
        private
        returns (bool)
    {
        if (_add == address(0x0)){
            return false;
        }

        uint256 _amt = promoters[_add][promoterDistRound];
        // if the amount is less than the last on the leaderboard, reject
        if (topPromoters[2].amt >= _amt){
            return false;
        }

        address firstAddr = topPromoters[0].addr;
        uint256 firstAmt = topPromoters[0].amt;
        address secondAddr = topPromoters[1].addr;
        uint256 secondAmt = topPromoters[1].amt;


        // if the user should be at the top
        if (_amt > topPromoters[0].amt){

            if (topPromoters[0].addr == _add){
                topPromoters[0].amt = _amt;
                return true;
            }
            else{
                firstAddr = topPromoters[0].addr;
                firstAmt = topPromoters[0].amt;
                secondAddr = topPromoters[1].addr;
                secondAmt = topPromoters[1].amt;

                topPromoters[0].addr = _add;
                topPromoters[0].amt = _amt;
                topPromoters[1].addr = firstAddr;
                topPromoters[1].amt = firstAmt;
                topPromoters[2].addr = secondAddr;
                topPromoters[2].amt = secondAmt;
                return true;
            }
        }
        // if the user should be at the second position
        else if (_amt >= topPromoters[1].amt){

            if (topPromoters[0].addr == _add){
                topPromoters[0].amt = _amt;
                return true;
            }
            else if (topPromoters[1].addr == _add){
                topPromoters[1].amt = _amt;
                return true;
            }
            else{
                secondAddr = topPromoters[1].addr;
                secondAmt = topPromoters[1].amt;

                topPromoters[1].addr = _add;
                topPromoters[1].amt = _amt;
                topPromoters[2].addr = secondAddr;
                topPromoters[2].amt = secondAmt;
                return true;
            }

        }
        // if the user should be at the third position
        else if (_amt >= topPromoters[2].amt){

            if (topPromoters[0].addr == _add){
                topPromoters[0].amt = _amt;
                return true;
            }
            else if (topPromoters[1].addr == _add){
                topPromoters[1].amt = _amt;
                return true;
            }
            else if (topPromoters[2].addr == _add){
                topPromoters[2].amt = _amt;
                return true;
            }
            else{
                topPromoters[2].addr = _add;
                topPromoters[2].amt = _amt;
                return true;
            }

        }

    }

    function addInvestor(address _add)
        isActivated()
        private
        returns (bool)
    {
        if (_add == address(0x0)){
            return false;
        }

        uint256 _amt = investors[_add][investorDistRound];
        // if the amount is less than the last on the leaderboard, reject
        if (topInvestors[2].amt >= _amt){
            return false;
        }

        address firstAddr = topInvestors[0].addr;
        uint256 firstAmt = topInvestors[0].amt;
        address secondAddr = topInvestors[1].addr;
        uint256 secondAmt = topInvestors[1].amt;

        // if the user should be at the top
        if (_amt > topInvestors[0].amt){

            if (topInvestors[0].addr == _add){
                topInvestors[0].amt = _amt;
                return true;
            }
            else{
                firstAddr = topInvestors[0].addr;
                firstAmt = topInvestors[0].amt;
                secondAddr = topInvestors[1].addr;
                secondAmt = topInvestors[1].amt;

                topInvestors[0].addr = _add;
                topInvestors[0].amt = _amt;
                topInvestors[1].addr = firstAddr;
                topInvestors[1].amt = firstAmt;
                topInvestors[2].addr = secondAddr;
                topInvestors[2].amt = secondAmt;
                return true;
            }
        }
        // if the user should be at the second position
        else if (_amt >= topInvestors[1].amt){

            if (topInvestors[0].addr == _add){
                topInvestors[0].amt = _amt;
                return true;
            }
            else if (topInvestors[1].addr == _add){
                topInvestors[1].amt = _amt;
                return true;
            }
            else{
                secondAddr = topInvestors[1].addr;
                secondAmt = topInvestors[1].amt;

                topInvestors[1].addr = _add;
                topInvestors[1].amt = _amt;
                topInvestors[2].addr = secondAddr;
                topInvestors[2].amt = secondAmt;
                return true;
            }

        }
        // if the user should be at the third position
        else if (_amt >= topInvestors[2].amt){

            if (topInvestors[0].addr == _add){
                topInvestors[0].amt = _amt;
                return true;
            }
            else if (topInvestors[1].addr == _add){
                topInvestors[1].amt = _amt;
                return true;
            }
            else if (topInvestors[2].addr == _add){
                topInvestors[2].amt = _amt;
                return true;
            }
            else{
                topInvestors[2].addr = _add;
                topInvestors[2].amt = _amt;
                return true;
            }

        }

    }

    function purchaseViaAddr(address _affAddress)
        isHuman()
        isActivated()
        isWithinLimits(msg.value)
        public
        payable
    {
        //  set up our tx event data and determine if player is new or not
        DataStructs.EventReturns memory _eventData_ = _eventData_;

        // fetch player id
        address _playerAddr = msg.sender;
        address _affAddr = _affAddress;

        // purchase core
        purchaseCore(_playerAddr, _affAddr, _eventData_);
    }

    function purchaseViaName(bytes32 _affName)
        isHuman()
        isActivated()
        isWithinLimits(msg.value)
        public
        payable
    {
        //  set up our tx event data and determine if player is new or not
        DataStructs.EventReturns memory _eventData_ = _eventData_;

        // fetch player id
        address _playerAddr = msg.sender;
        address _affAddr = pAddrxName[_affName];

        // purchase core
        purchaseCore(_playerAddr, _affAddr, _eventData_);
    }

    function purchaseCore(address _playerAddr, address _affAddr, DataStructs.EventReturns memory _eventData_)
        private
    {

        uint256 _rID = rID_;
        uint256 _now = now;

        // Check if round is active
        if (_now > round_[_rID].strt && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
        {
            // call core

             coreLogic(_rID, _playerAddr, msg.value, _affAddr, _eventData_);


        // if round is not active
        } else {
            // check to see if end round needs to be ran
            if (_now > round_[_rID].end && round_[_rID].ended == false)
            {
                // end the round (distributes pot) & start new round
			    round_[_rID].ended = true;
                  _eventData_ = endRound(_eventData_);

                // build event data
                 _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);

                 // // fire buy and distribute event
                emit onRoundEnd
                (
                    _eventData_,
                    msg.sender,
                    _eventData_.compressedIDs,
                    _eventData_.newPot,
                    msg.value,
                    _eventData_.genAmount
                );

            }

            // Send back the eth
            address(_playerAddr).transfer(msg.value);
        }
    }

    /**
     * @dev this is the core logic for any purchase that happens while a round
     * is live.
     */
    function coreLogic(uint256 _rID, address _playerAddr, uint256 _eth, address _affAddr, DataStructs.EventReturns memory _eventData_)
        private
    {
        // if player is new to round
        if (plyrRnds_[_playerAddr][_rID].keys == 0) {
            _eventData_ = managePlayer(_playerAddr, _eventData_);
            round_[_rID].playerCounter = round_[_rID].playerCounter + 1;
        }


        uint256 amountToExternalWallet = _eth.div(2);
        address(externalWallet).transfer(amountToExternalWallet);

        // mint the new keys
        uint256 _keys = keysRec(_eth);

        // if they bought at least 1 whole key
        if (_keys >= 1000000000000000000)
        {
            updateTimer(_keys, _rID);

            // set new leaders
            if (round_[_rID].plyr != _playerAddr)
                round_[_rID].plyr = _playerAddr;

            // set the new leader bool to true
            _eventData_.compressedData = _eventData_.compressedData + 100;
        }

        // update player
         plyrRnds_[_playerAddr][_rID].keys = (_keys.mul(1).div(100)).add(plyrRnds_[_playerAddr][_rID].keys);
         plyrRnds_[_playerAddr][_rID].eth = _eth.add(plyrRnds_[_playerAddr][_rID].eth);
         plyr_[_playerAddr].eth = plyr_[_playerAddr].eth.add(_eth);

        // update round
        round_[_rID].keys = _keys.add(round_[_rID].keys);
        round_[_rID].eth = _eth.add(round_[_rID].eth);

        // distribute keys amongst all

        _eventData_ = distributeInternal(_rID, _playerAddr, _affAddr, _keys, _eventData_);

        investors[_playerAddr][investorDistRound] = investors[_playerAddr][investorDistRound].add(_eth);
        addInvestor(_playerAddr);
        luckyDraw.add(_playerAddr);

        //check if its been over a day since the last lucky draw happened
        if (now.sub(lastLuckyDrawTime) >= luckyDrawDuration  && luckyDrawEnabled == true){

            //pick a winner and transfer ETH to account
            address luckyDrawWinner = luckyDraw.draw();
            plyr_[luckyDrawWinner].gen = plyr_[luckyDrawWinner].gen.add(luckyDrawVault_);
            lastLuckyDrawAmt = luckyDrawVault_;
            luckyDrawVault_ = 0;
            lastLuckyDrawTime = now;
            emit luckyDrawDeclared(luckyDrawWinner, lastLuckyDrawAmt, now);
        }

    }


    /**
     * @dev distributes eth based on fees to gen and treasure
     */
    function distributeInternal(uint256 _rID, address _playerAddr, address _affAddr, uint256 _keys, DataStructs.EventReturns memory _eventData_)
        private
        returns(DataStructs.EventReturns)
    {
        // calculate keys Holder's share to be distributed as dividends(61%)
        uint256 _keyHolderShare = (_keys.mul(keyHolderFees_)) .div(100);

        //admin share is 3%
        uint256 _adminShare = (_keys.mul(3)).div(100);
        adminKeyVault_ = adminKeyVault_.add(_adminShare);

        // distribute share to affiliate 12%
        uint256 _affShare = (_keys.mul(12)).div(100);

        // calculate treasure Amount (20%)
        uint256 _treasureAmount = _keys.mul(treasureAmount_).div(100);

        // update the top leaderboard vaults
        topPromotersVault = topPromotersVault.add(_keys.div(100));
        topInvestorsVault = topInvestorsVault.add(_keys.div(100));

        // Calculate amount given to the person(investor)
        uint256 _investorAmount = _keys.mul(1).div(100);
        plyr_[_playerAddr].keys = plyr_[_playerAddr].keys.add(_investorAmount);

        totalSupply_ = totalSupply_.add(_keys);

        //increase lucky draw allowance
        luckyDrawVault_ = luckyDrawVault_.add(_keys.div(100));

        // decide what to do with affiliate share of fees
         calculateReferralBonus(_affShare,_affAddr,_playerAddr);


        if (round_[_rID].playerCounter == 1)
        {
            round_[_rID].treasure = _keyHolderShare.add(round_[_rID].treasure);
            tokenInvestorsSupply_ = tokenInvestorsSupply_.add(_investorAmount);
        }
        else
        {
            //distribute gen share (thats what updateMasks() does) and adjust
            updateMasks(_rID, _playerAddr, _keyHolderShare, _investorAmount);
            //Updating the total keys a investor has received, to calculate the mask value.
            tokenInvestorsSupply_ = tokenInvestorsSupply_.add(_investorAmount);
        }

        // add keys to treasure
        round_[_rID].treasure = _treasureAmount.add(round_[_rID].treasure);

        // set up event data
        _eventData_.genAmount = _keyHolderShare.add(_eventData_.genAmount);
        _eventData_.potAmount = _treasureAmount;

        return(_eventData_);
    }

    /**
     * @dev decides if round end needs to be run & new round started.  and if
     * player unmasked earnings from previously played rounds need to be moved.
     */
    function managePlayer(address _pAddress, DataStructs.EventReturns memory _eventData_)
        private
        returns (DataStructs.EventReturns)
    {
        // if player has played a previous round, move their unmasked earnings
        // from that round to dividends vault.
        if (plyr_[_pAddress].lrnd != 0)
        {
            updateGenVault(_pAddress, plyr_[_pAddress].lrnd);

            // update player's last round played

            plyr_[_pAddress].gen = plyr_[_pAddress].gen.add(plyr_[_pAddress].keys);

            plyr_[_pAddress].keys = 0;
        }

        plyr_[_pAddress].lrnd = rID_;

        // set the joined round bool to true
        _eventData_.compressedData = _eventData_.compressedData + 10;

        return(_eventData_);
    }

     /**
     * @dev ends the round. manages paying out winner/splitting up pot
     */
    function endRound(DataStructs.EventReturns memory _eventData_)
        private
        returns (DataStructs.EventReturns)
    {
        // setup local rID
        uint256 _rID = rID_;

        // grab our winning player
        address _winPAddress = round_[_rID].plyr;

        // grab our treasure amount
        uint256 _treasure = round_[_rID].treasure;

        // calculate our winner share, community rewards, gen share,
        // and amount reserved for next pot
        uint256 _winnerAmount = (_treasure.mul(40)) / 100;
        uint256 _adminAmount = (_treasure.mul(19)) / 100;
        uint256 _toCurrentHolders = (_treasure.mul(40)) / 100;
        uint256 _toNextRound = _treasure.div(100);

        // calculate ppt for round mask
        uint256 _ppt = (_toCurrentHolders.mul(1000000000000000000)) / (tokenInvestorsSupply_);


        // pay our winner
        plyr_[_winPAddress].win = _winnerAmount.add(plyr_[_winPAddress].win);

        // Admin share
        adminKeyVault_ = adminKeyVault_.add(_adminAmount);

        // distribute gen portion to key holders
        round_[_rID].mask = _ppt.add(round_[_rID].mask);

        // Prepare event data
        _eventData_.compressedData = _eventData_.compressedData + (round_[_rID].end * 1000000);
        _eventData_.winnerAddr = plyr_[_winPAddress].addr;
        _eventData_.winnerName = plyr_[_winPAddress].name;
        _eventData_.amountWon = _winnerAmount;
        _eventData_.genAmount = _toCurrentHolders;
        _eventData_.newPot = _toNextRound;

        activated_ = false;

        return(_eventData_);
    }

    /**
     * @dev start next round
     */
    function startNextRound()
        public
        onlyOwner()
    {

        //setup local round id
        uint256 _rID = rID_;

        uint256 _now = now;

         // set up our tx event data
        DataStructs.EventReturns memory _eventData_ = _eventData_;

        //check if end round needs to be ran
        if (_now > round_[_rID].end && round_[_rID].ended == false)
        {
             // end the round (distributes treasure) & start new round
            round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);

            // build event data
            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
        }


        require(activated_ == false, "round is already runnning.");


        uint256 _treasure = round_[_rID].treasure;
        uint256 _toNextRound = _treasure.div(100);

        rID_++;
        _rID++;
        round_[_rID].strt = now;
        round_[_rID].end = now.add(rndInit_);
        round_[_rID].treasure = _toNextRound;


        activated_ = true;

        emit nextRoundStarted(rID_, round_[_rID].strt, round_[_rID].end);
    }

     /**
     * @dev last declared winner of lucky draw
     */
    function getLastLuckyDrawWinner()
        public
        view
        returns(address winner)
    {
        return luckyDraw.getWinner();
    }

    /**
     * @dev update lucky draw contract address
     */
    function updateLuckDrawContract(address _contractAddress)
        public
        onlyOwner()
    {
        luckyDraw = LuckyDraw(_contractAddress);
    }


    /**
     * @dev moves any unmasked earnings to gen vault.  updates earnings mask
     */
    function updateGenVault(address _pAddress, uint256 _rIDlast)
        private
    {

        uint256 _earnings;
        uint256 _extraEarnings;
        (_earnings, _extraEarnings) = calcUnMaskedEarnings(_pAddress, _rIDlast);

        if (_earnings > 0)
        {
            // put in gen vault
            plyr_[_pAddress].gen = _earnings.add(plyr_[_pAddress].gen);
            // zero out their earnings by updating mask
            plyrRnds_[_pAddress][_rIDlast].mask = _earnings.add(plyrRnds_[_pAddress][_rIDlast].mask);

            //assign extra earnings to admin
            adminKeyVault_ = adminKeyVault_.add(_extraEarnings);
            playerExtraEarnings_[_pAddress][_rIDlast] = playerExtraEarnings_[_pAddress][_rIDlast].add(_extraEarnings);

        }
    }

    /**
     * @dev updates round timer based on number of whole keys bought.
     */
    function updateTimer(uint256 _keys, uint256 _rID)
        private
    {
        // grab time
        uint256 _now = now;

        // calculate time based on number of keys bought
        uint256 _newTime;
        if (_now > round_[_rID].end && round_[_rID].plyr == 0)
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(_now);
        else
            _newTime = (((_keys) / (1000000000000000000)).mul(rndInc_)).add(round_[_rID].end);

        // compare to max and set new end time
        if (_newTime < (rndMax_).add(_now))
            round_[_rID].end = _newTime;
        else
            round_[_rID].end = rndMax_.add(_now);
    }

    function registerName(string _nameString)
        isHuman()
        public
        payable
    {
        bytes32 _name = _nameString.nameFilter();
        address _plyrAddress = msg.sender;

        require(pAddrxName[_name] == address(0x0), "Name already registered");

        _owner.transfer(msg.value);

        pAddrxName[_name] = _plyrAddress;
        plyr_[_plyrAddress].name = _name;

        // fire event
        emit Events.newName(_plyrAddress, _name, msg.value, now);
    }

    function getPlayerName(address _add)
        public
        view
        returns(bytes32)
    {
        return plyr_[_add].name;
    }


    /**
     * @dev updates masks for round and player when keys are bought
     * @return dust left over
     */
    function updateMasks(uint256 _rID, address _playerAddr, uint256 _gen, uint256 _investorAmount)
        private
        //returns(uint256)
    {
        /* MASKING NOTES
            earnings masks are a tricky thing for people to wrap their minds around.
            the basic thing to understand here.  is were going to have a global
            tracker based on profit per share for each round, that increases in
            relevant proportion to the increase in share supply.

            the player will have an additional mask that basically says "based
            on the rounds mask, my shares, and how much i've already withdrawn,
            how much is still owed to me?"
        */

            // calc profit per key & round mask based on this buy:  (dust goes to pot)
            uint256 _ppt = (_gen.mul(1000000000000000000)) / (tokenInvestorsSupply_);
            round_[_rID].mask = _ppt.add(round_[_rID].mask);

            // calculate player earning from their own buy (only based on the keys
            // they just bought).  & update player earnings mask

            plyrRnds_[_playerAddr][_rID].mask = ((round_[_rID].mask.mul(_investorAmount)) / (1000000000000000000)).add(plyrRnds_[_playerAddr][_rID].mask);

     }


    function transferFundsToSmartContract()
    public
    onlyExternalWallet()
    payable {

    }

    function overtimeWithdraw()
    public
    onlyOwner()
    returns (bool){

        uint256 _now = now;
        uint256 _rID = rID_;

         if (_now > round_[_rID].end && round_[_rID].ended == true)
            {
                if ((_now.sub(round_[_rID].end)) >= 30 days )
                {
                    address(externalWallet).transfer(address(this).balance);
                    return true;
                }
            }
        return false;

    }

    function withdrawTokensByAdmin()
    public
    onlyOwner() {
        uint256 withdrawEthAmount  = adminKeyVault_.mul(keyPrice).div(1000000000000000000);

        //Check whether sufficient funds are there
        require(address(this).balance >= withdrawEthAmount,"Not sufficient balance in smart contract");

        //reduce the withdrawal amount from total supply
        totalSupply_ = totalSupply_.sub(adminKeyVault_);

        adminKeyVault_ = 0;

        // transfer eth to admin's address
        address(_owner).transfer(withdrawEthAmount);
    }

    function keysRec(uint256 _newEth)
        internal
        view
        returns (uint256)
    {
        return(_newEth.div(keyPrice).mul(1000000000000000000)); //considereing 18 decimals for the key
    }

    function calculateReferralBonus(uint256 _referralBonus, address _referredBy, address _playerAddr) private returns(bool) {

        address _secondReferrer;
        address _thirdReferrer;

        if(
            // is this a referred purchase?
            _referredBy != 0x0000000000000000000000000000000000000000 &&

            // Ohoo noo, you can't refer yourself buddy :P
            _referredBy != _playerAddr
        )
        {
            //If the user has already been referred by someone previously, can't be referred by someone else
            if(firstReferrer[msg.sender] != 0x0000000000000000000000000000000000000000) {
                    _referredBy  = firstReferrer[msg.sender];
            }
            else {
                firstReferrer[msg.sender] = _referredBy;
            }

        //check for second referrer
            if(firstReferrer[_referredBy] != 0x0000000000000000000000000000000000000000)
            {
                 _secondReferrer = firstReferrer[_referredBy];
                //check for third referrer
                if(firstReferrer[_secondReferrer] != 0x0000000000000000000000000000000000000000) {
                     _thirdReferrer = firstReferrer[_secondReferrer];

                    //transfer 1% of total referral commission to third referrer
                    referralBalance_[_thirdReferrer] = referralBalance_[_thirdReferrer].add(_referralBonus.mul(1).div(12));

                    //transfer 3% of total referral commission to second referrer
                    referralBalance_[_secondReferrer] = referralBalance_[_secondReferrer].add(_referralBonus.mul(3).div(12));

                    //transfer 8% of total referral commission to first referrer
                    referralBalance_[_referredBy] = referralBalance_[_referredBy].add(_referralBonus.mul(8).div(12));


                }
                //No Third Referrer then transfer to first and second referrer and to Admin
                else {
                    //transfer 3% of total referral commission to second referrer
                    referralBalance_[_secondReferrer] = referralBalance_[_secondReferrer].add(_referralBonus.mul(3).div(12));
                    //transfer 8% of total referral commission to first referrer
                    referralBalance_[_referredBy] = referralBalance_[_referredBy].add(_referralBonus.mul(8).div(12));

                    //transfer 1% to admin
                    adminKeyVault_ = adminKeyVault_.add(_referralBonus.mul(1).div(12));

                }
            } //no second referrer then transfer 8% to the first referrer and rest 4% to admin
            else {
                referralBalance_[_referredBy] = referralBalance_[_referredBy].add(_referralBonus.mul(8).div(12));

                //transfer 4% to admin
                adminKeyVault_ = adminKeyVault_.add(_referralBonus.mul(4).div(12));
            }

            promoters[_referredBy][promoterDistRound] = promoters[_referredBy][promoterDistRound].add(_referralBonus.div(12).mul(100));
            addPromoter(_referredBy);
            return true;
    }

    //might be possible that the referrer is 0x0 but previously someone has referred the user
    else if(
            //0x0 coming from the UI
            _referredBy == 0x0000000000000000000000000000000000000000 &&

            //check if the somone has previously referred the user
            firstReferrer[msg.sender] != 0x0000000000000000000000000000000000000000

        )
        {
            _referredBy = firstReferrer[msg.sender];
           //check for second referrer
            if(firstReferrer[_referredBy] != 0x0000000000000000000000000000000000000000)
            {
                 _secondReferrer = firstReferrer[_referredBy];
                //check for third referrer
                if(firstReferrer[_secondReferrer] != 0x0000000000000000000000000000000000000000) {
                     _thirdReferrer = firstReferrer[_secondReferrer];

                    //transfer 1% of total referral commission to third referrer
                    referralBalance_[_thirdReferrer] = referralBalance_[_thirdReferrer].add(_referralBonus.mul(1).div(12));

                    //transfer 3% of total referral commission to second referrer
                    referralBalance_[_secondReferrer] = referralBalance_[_secondReferrer].add(_referralBonus.mul(3).div(12));

                    //transfer 8% of total referral commission to first referrer
                    referralBalance_[_referredBy] = referralBalance_[_referredBy].add(_referralBonus.mul(8).div(12));

                }
                //No Third Referrer then transfer to first and second referrer
                else {
                    //transfer 3% of total referral commission to second referrer
                    referralBalance_[_secondReferrer] = referralBalance_[_secondReferrer].add(_referralBonus.mul(3).div(12));
                    //transfer 8% of total referral commission to first referrer
                    referralBalance_[_referredBy] = referralBalance_[_referredBy].add(_referralBonus.mul(8).div(12));

                    //transfer 1% to admin
                    adminKeyVault_ = adminKeyVault_.add(_referralBonus.mul(1).div(12));
                }
            } //no second referrer then transfer all to the first referrer
            else {
                referralBalance_[_referredBy] = referralBalance_[_referredBy].add(_referralBonus.mul(8).div(12));

                //transfer 4% to admin
                adminKeyVault_ = adminKeyVault_.add(_referralBonus.mul(4).div(12));
            }
            promoters[_referredBy][promoterDistRound] = promoters[_referredBy][promoterDistRound].add(_referralBonus.div(12).mul(100));
            addPromoter(_referredBy);
            return true;
        }

        else {
            // Transfer all 12% to Admin
            adminKeyVault_ = adminKeyVault_.add(_referralBonus);
        }
        return false;


     }

    /** upon contract deploy, it will be deactivated.  this is a one time
     * use function that will activate the contract.  we do this so devs
     * have time to set things up on the web end                   **/
    bool public activated_ = false;
    function activate()
        public
    {
        // only admin  just can activate
        require(msg.sender == _owner, "only admin can activate");


        // if round 1 has already finished.
        require(rID_ == 0, "This is not the first round, please click startNextRound() to start new round");

        // can only be ran once
        require(activated_ == false, "Golden Kingdom already activated");

        // activate the contract
        activated_ = true;

        // let's start the first round
        rID_ = 1;
            round_[1].strt = now ;
            round_[1].end = now + rndInit_ ;
    }
//----------------------------------------------------------------------------------------------//
//                                  READ ONLY FUNCTIONS
//----------------------------------------------------------------------------------------------//

    function getReferralBalance(address referralAddress)
    public
    view
    returns (uint256)
    {
    return referralBalance_[referralAddress];
    }

    /**
     * @dev calculates unmasked earnings (just calculates, does not update mask)
     * @return earnings in wei format
     */
    function calcUnMaskedEarnings(address _pAddress, uint256 _rIDlast)
        private
        view
        returns(uint256, uint256)
    {
        uint256 _earnings =   (((round_[_rIDlast].mask).mul(plyrRnds_[_pAddress][_rIDlast].keys)) / (1000000000000000000)).sub(plyrRnds_[_pAddress][_rIDlast].mask).sub(playerExtraEarnings_[_pAddress][_rIDlast]);
        uint256 _playerMaxEarningCap = (plyrRnds_[_pAddress][rID_].eth.mul(2)).div(keyPrice).mul(1000000000000000000);

        if
            (
               (_earnings.add(playerEarned_[_pAddress][_rIDlast]).add(plyr_[_pAddress].keys)) >= _playerMaxEarningCap
            )
            return(
                    _playerMaxEarningCap.sub((playerEarned_[_pAddress][_rIDlast]).add((plyr_[_pAddress].keys))),
                   _earnings.sub(_playerMaxEarningCap).add((playerEarned_[_pAddress][_rIDlast]).add((plyr_[_pAddress].keys)))
                  );
        else
            return(_earnings, 0);
    }

    /**
     * @dev returns player info based on address.  if no address is given, it will
     * use msg.sender
     * @param _playerAddr address of the player you want to lookup
     * @return gold boxes owned (current round)
     * @return winnings vault
     * @return dividends vault
     * @return referral vault
	 * @return player round eth
     */
    function getPlayerInfoByAddress(address _playerAddr)
        public
        view
        returns( uint256, uint256, uint256, uint256, uint256)
    {

       // setup local rID
        //uint256 _rID = rID_;

        uint256 _earnings;
        uint256 _extraEarnings;

        (_earnings, _extraEarnings) = calcUnMaskedEarnings(_playerAddr, plyr_[_playerAddr].lrnd);

        if(rID_ == plyr_[_playerAddr].lrnd)
        {
            return
            (  plyrRnds_[_playerAddr][rID_].keys,         //1
                plyr_[_playerAddr].win,                    //2
                (plyr_[_playerAddr].gen).add(_earnings),       //3
                referralBalance_[_playerAddr],                    //4
                plyrRnds_[_playerAddr][rID_].eth           //5
            );
        }
        else
        {
            return
            (  plyrRnds_[_playerAddr][rID_].keys,         //1
                plyr_[_playerAddr].win,                    //2
                (plyr_[_playerAddr].gen).add(_earnings).add(plyr_[_playerAddr].keys),       //3
                referralBalance_[_playerAddr],                    //4
                plyrRnds_[_playerAddr][rID_].eth           //5
            );
        }
    }

    /**
     * @dev returns time left.
     * provider
     * @return time left in seconds
     */
    function getTimeLeft()
        public
        view
        returns(uint256)
    {
        // setup local rID
        uint256 _rID = rID_;

        // grab time
        uint256 _now = now;

        if (_now < round_[_rID].end)
            if (_now > round_[_rID].strt )
                return( (round_[_rID].end).sub(_now) );
            else
                return( (round_[_rID].strt ).sub(_now) );
        else
            return(0);
    }

}

library DataStructs {


    struct EventReturns {
        uint256 compressedData;
        uint256 compressedIDs;
        address winnerAddr;         // winner address
        bytes32 winnerName;         // winner name
        uint256 amountWon;          // amount won
        uint256 newPot;             // amount in new pot
        uint256 genAmount;          // amount distributed to gen
        uint256 potAmount;          // amount added to pot
     }
    struct Player {
        address addr;       // player address
        bytes32 name;       // player name
        uint256 win;        // winnings vault
        uint256 gen;        // Keys as dividends
        uint256 lrnd;       // last round played
        uint256 keys;       // keys player has got with his purchase
        uint256 eth;        // Amount invested by player
    }
    struct PlayerRounds {
        uint256 eth;    // eth player has added to round (used for eth limiter)
        uint256 keys;   // keys
        uint256 mask;   // player mask
    }
    struct Round {
        address plyr;   // playerAddr of player in lead
        uint256 playerCounter;   // Number of players in a round
        uint256 end;    // time ends/ended
        bool ended;     // has round end function been ran
        uint256 strt;   // time round started
        uint256 keys;   // keys
        uint256 eth;    // total eth in
        uint256 treasure;    // keys in trasure (during round) / final amount paid to winner (after round ends)
        uint256 mask;   // global mask
    }
}


library NameFilter {
    /**
     * @dev filters name strings
     * -converts uppercase to lower case.
     * -makes sure it does not start/end with a space
     * -makes sure it does not contain multiple spaces in a row
     * -cannot be only numbers
     * -cannot start with 0x
     * -restricts characters to A-Z, a-z, 0-9, and space.
     * @return reprocessed string in bytes32 format
     */
    function nameFilter(string _input)
        internal
        pure
        returns(bytes32)
    {
        bytes memory _temp = bytes(_input);
        uint256 _length = _temp.length;

        //sorry limited to 32 characters
        require (_length <= 32 && _length > 0, "string must be between 1 and 32 characters");
        // make sure it doesnt start with or end with space
        require(_temp[0] != 0x20 && _temp[_length-1] != 0x20, "string cannot start or end with space");
        // make sure first two characters are not 0x
        if (_temp[0] == 0x30)
        {
            require(_temp[1] != 0x78, "string cannot start with 0x");
            require(_temp[1] != 0x58, "string cannot start with 0X");
        }

        // create a bool to track if we have a non number character
        bool _hasNonNumber;

        // convert & check
        for (uint256 i = 0; i < _length; i++)
        {
            // if its uppercase A-Z
            if (_temp[i] > 0x40 && _temp[i] < 0x5b)
            {
                // convert to lower case a-z
                _temp[i] = byte(uint(_temp[i]) + 32);

                // we have a non number
                if (_hasNonNumber == false)
                    _hasNonNumber = true;
            } else {
                require
                (
                    // require character is a space
                    _temp[i] == 0x20 ||
                    // OR lowercase a-z
                    (_temp[i] > 0x60 && _temp[i] < 0x7b) ||
                    // or 0-9
                    (_temp[i] > 0x2f && _temp[i] < 0x3a),
                    "string contains invalid characters"
                );
                // make sure theres not 2x spaces in a row
                if (_temp[i] == 0x20)
                    require( _temp[i+1] != 0x20, "string cannot contain consecutive spaces");

                 // see if we have a character other than a number
                if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39))
                    _hasNonNumber = true;
            }
        }

        require(_hasNonNumber == true, "string cannot be only numbers");

        bytes32 _ret;
        assembly {
            _ret := mload(add(_temp, 32))
        }
        return (_ret);
    }
}

library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     * - Subtraction cannot overflow.
     *
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     * - The divisor cannot be zero.
     * NOTE: This is a feature of the next version of OpenZeppelin Contracts.
     * @dev Get it via `npm install @openzeppelin/contracts@next`.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}
