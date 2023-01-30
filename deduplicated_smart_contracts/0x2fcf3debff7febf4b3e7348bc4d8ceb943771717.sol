/**
 *Submitted for verification at Etherscan.io on 2019-11-15
*/

pragma solidity ^0.4.24;

/**
              _.-+.
         _.-""     '.
      :""       o    '.
      |\       m       '.
      | \     o       _.+
      |  '.  F    _.-"  |
      |    \  _.-"      |
      |     +"       e  |
       \    |      b    |
        \   |    u     .+
         \  |  C    .-'
          \ |    .-'
           \| .-'
            +'
            
This contract is an evolution of Fomo3D Long:
https://etherscan.io/address/0xa62142888aba8370742be823c1782d17a0389da1#code
https://fomo3d.hostedwiki.co/pages/FAQ

Modifications:
- Replaced "PlayerBook" with FomoCube username contract
- Removed staking requirement
- Removed teams
- Removed airdrops
|
--- New ETH distribution:
// 50% for POLY holders, 20% for the jackpot
// 15% for CUBE holders, 10% for referrer or CUBE holders
// 5% for the developers <3
|
--- Replaced "Pot" system with a jackpot and "increment":
|
- The increment is the minimum purchase to become the leader (in POLY)
|
- The increment starts at 0 and increases by 100 for every ETH in the jackpot
|
- The jackpot is awarded to the leader when the timer runs out
|
- Each new leader increases the round timer by 30 minutes, and the maximum is 72 hours
|
- POLY follows the same price formula as "Fomo3D Long",
- thus the cost of becoming the leader is affected by price and increment
|
- For example:
~~ Jackpot of 10 ETH --> Becoming the leader costs 0.14 ETH
~~ Jackpot of 50 ETH --> Becoming the leader costs 1.44 ETH
~~ Jackpot of 100 ETH -> Becoming the leader costs 4.02 ETH
|
~~~
  This system is designed to end the round before players lose interest.
  The increasing cost of becoming the leader forces whales to fight for the jackpot -
  - benefitting all previous buyers.
~~~
|
>>> https://fomocube.io/

 */
 
//==============================================================================
//     _    _  _ _|_ _  .
//    (/_\/(/_| | | _\  .
//==============================================================================
contract PolyFomoEvents {
    // fired at end of buy or reload
    event onEndTx
    (
        uint256 compressedData,     
        uint256 compressedIDs,      
        bytes32 playerName,
        address playerAddress,
        uint256 ethIn,
        uint256 polyBought,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot,
        uint256 cubeAmount,
        uint256 genAmount,
        uint256 potAmount
    );
    
    // fired whenever theres a withdraw
    event onWithdraw
    (
        uint256 indexed playerID,
        address playerAddress,
        bytes32 playerName,
        uint256 ethOut,
        uint256 timeStamp
    );
    
    // fired whenever a withdraw forces end round to be ran
    event onWithdrawAndDistribute
    (
        address playerAddress,
        bytes32 playerName,
        uint256 ethOut,
        uint256 compressedData,
        uint256 compressedIDs,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot
    );
    
    // fired whenever a player tries a buy after round timer 
    // hit zero, and causes end round to be ran.
    event onBuyAndDistribute
    (
        address playerAddress,
        bytes32 playerName,
        uint256 ethIn,
        uint256 compressedData,
        uint256 compressedIDs,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot
    );
    
    // fired whenever a player tries a reload after round timer 
    // hit zero, and causes end round to be ran.
    event onReLoadAndDistribute
    (
        address playerAddress,
        bytes32 playerName,
        uint256 compressedData,
        uint256 compressedIDs,
        address winnerAddr,
        bytes32 winnerName,
        uint256 amountWon,
        uint256 newPot
    );
    
    // fired whenever an affiliate is paid
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
}

//==============================================================================
//   _ _  _ _|_ _ _  __|_   _ _ _|_    _   .
//  (_(_)| | | | (_|(_ |   _\(/_ | |_||_)  .
//====================================|=========================================

contract modularLong is PolyFomoEvents {}

contract PolyFomo is modularLong {
    using SafeMath for *;
    using PolygonCalcLong for uint256;
    
    address private comAddress_;
    CubeInterface private cube;
    UsernameInterface private username;
    
//==============================================================================
//     _ _  _  |`. _     _ _ |_ | _  _  .
//    (_(_)| |~|~|(_||_|| (_||_)|(/__\  .  (game settings)
//=================_|===========================================================
    string constant public name = "PolyFomo";
    string constant public symbol = "POLY";
    uint256 constant private rndExtra_ = 24 hours;              // Countdown before open
    uint256 constant private rndInit_ = 1 hours;                // round timer starts at this
    uint256 constant private rndInc_ = 30 minutes;              // every new leader adds 30 minutes to the timer
    uint256 constant private rndMax_ = 72 hours;                // max length a round timer can be
    
//==============================================================================
//     _| _ _|_ _    _ _ _|_    _   .
//    (_|(_| | (_|  _\(/_ | |_||_)  .  (data used to store game info that changes)
//=============================|================================================
    uint256 public rID_;    // round id number / total rounds that have happened
    uint256 public pID_;  // total number of players
//****************
// PLAYER DATA 
//****************
    mapping (address => uint256) public pIDxAddr_;                                               // (addr => pID) returns player id by address
    mapping (uint256 => PolyFomoDatasets.Player) public plyr_;                                   // (pID => data) player data
    mapping (uint256 => mapping (uint256 => PolyFomoDatasets.PlayerRounds)) public plyrRnds_;    // (pID => rID => data) player round data by player id & round id

//****************
// ROUND DATA 
//****************
    mapping (uint256 => PolyFomoDatasets.Round) public round_;              // (rID => data) round data
    uint256 public rndEth_;
//****************
// TEAM FEE DATA 
//****************
//==============================================================================
//     _ _  _  __|_ _    __|_ _  _  .
//    (_(_)| |_\ | | |_|(_ | (_)|   .  (initial data setup upon contract deploy)
//==============================================================================
    constructor(address usernameAddress, address cubeAddress, address comAddress)
        public
    {
        username = UsernameInterface(usernameAddress);
        cube = CubeInterface(cubeAddress);
        comAddress_ = comAddress;
        
        // PURCHASES
        // 50% for POLY holders, 20% for jackpot, 15% for CUBE holders, 10% for referral or CUBE holders, 5% dev fee
        
        // Open the gates
        rID_ = 1;
        round_[1].strt = cube.startTime() + rndExtra_;
        round_[1].end = cube.startTime() + rndInit_ + rndExtra_;
	}
//==============================================================================
//     _ _  _  _|. |`. _  _ _  .
//    | | |(_)(_||~|~|(/_| _\  .  (these are safety checks)
//==============================================================================

    /**
     * @dev prevents contracts from interacting with fomo3d 
     */
    modifier isHuman() {
        require(tx.origin == msg.sender);
        _;
    }

    /**
     * @dev sets boundaries for incoming tx 
     */
    modifier isWithinLimits(uint256 _eth) {
        require(_eth >= 1000000000, "pocket lint: not a valid currency");
        require(_eth <= 100000000000000000000000, "no vitalik, no");
        _;    
    }
    
//==============================================================================
//     _    |_ |. _   |`    _  __|_. _  _  _  .
//    |_)|_||_)||(_  ~|~|_|| |(_ | |(_)| |_\  .  (use these to interact with contract)
//====|=========================================================================
    /**
     * @dev emergency buy uses last stored affiliate ID
     */
    function()
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        // set up our tx event data and determine if player is new or not
        PolyFomoDatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
            
        // fetch player id
        uint256 _pID = pIDxAddr_[msg.sender];
        
        // buy core 
        buyCore(_pID, plyr_[_pID].laff, _eventData_);
    }
    
    /**
     * @dev converts all incoming ethereum to poly.
     * @param _affCode the ID/address/name of the player who gets the affiliate fee
     */
    
    function buyXaddr(address _affCode)
        isHuman()
        isWithinLimits(msg.value)
        public
        payable
    {
        // set up our tx event data and determine if player is new or not
        PolyFomoDatasets.EventReturns memory _eventData_ = determinePID(_eventData_);
        
        // fetch player id
        uint256 _pID = pIDxAddr_[msg.sender];
        
        // manage affiliate residuals
        uint256 _affID;
        // if no affiliate code was given or player tried to use their own, lolz
        if (_affCode == address(0) || _affCode == msg.sender)
        {
            // use last stored affiliate code
            _affID = plyr_[_pID].laff;
        
        // if affiliate code was given    
        } else {
            // get affiliate ID from aff Code 
            _affID = pIDxAddr_[_affCode];
            
            if (_affID == 0) {
                _affID = registerReferrer(_affCode);
            }
            
            // if affID is not the same as previously stored 
            if (_affID != plyr_[_pID].laff)
            {
                // update last affiliate
                plyr_[_pID].laff = _affID;
            }
        }
        
        // buy core 
        buyCore(_pID, _affID, _eventData_);
    }
    
    /**
     * @dev essentially the same as buy, but instead of you sending ether 
     * from your wallet, it uses your unwithdrawn earnings.
     * @param _affCode the ID/address/name of the player who gets the affiliate fee
     * @param _eth amount of earnings to use (remainder returned to gen vault)
     */
    
    function reLoadXaddr(address _affCode, uint256 _eth)
        isHuman()
        isWithinLimits(_eth)
        public
    {
        // set up our tx event data
        PolyFomoDatasets.EventReturns memory _eventData_;
        
        // fetch player ID
        uint256 _pID = pIDxAddr_[msg.sender];
        
        // manage affiliate residuals
        uint256 _affID;
        // if no affiliate code was given or player tried to use their own, lolz
        if (_affCode == address(0) || _affCode == msg.sender)
        {
            // use last stored affiliate code
            _affID = plyr_[_pID].laff;
        
        // if affiliate code was given    
        } else {
            // get affiliate ID from aff Code 
            _affID = pIDxAddr_[_affCode];
            
            // set up new referrer if necessary
            if (_affID == 0) {
                _affID = registerReferrer(_affCode);
            }
            // if affID is not the same as previously stored 
            if (_affID != plyr_[_pID].laff)
            {
                // update last affiliate
                plyr_[_pID].laff = _affID;
            }
        }
        
        // reload core
        reLoadCore(_pID, _affID, _eth, _eventData_);
    }

    /**
     * @dev withdraws all of your earnings.
     */
    function withdraw()
        isHuman()
        public
    {
        // setup local rID 
        uint256 _rID = rID_;
        
        // grab time
        uint256 _now = now;
        
        // fetch player ID
        uint256 _pID = pIDxAddr_[msg.sender];
        
        // setup temp var for player eth
        uint256 _eth;
        
        // check to see if round has ended and no one has run round end yet
        if (_now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
        {
            // set up our tx event data
            PolyFomoDatasets.EventReturns memory _eventData_;
            
            // end the round (distributes pot)
            round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);
            
            // get their earnings
            _eth = withdrawEarnings(_pID);
            
            // gib moni
            if (_eth > 0)
                plyr_[_pID].addr.transfer(_eth);    
            
            // build event data
            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
            _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
            
            // fire withdraw and distribute event
            emit PolyFomoEvents.onWithdrawAndDistribute
            (
                msg.sender, 
                username.getNameByAddress(plyr_[_pID].addr), 
                _eth, 
                _eventData_.compressedData, 
                _eventData_.compressedIDs, 
                _eventData_.winnerAddr, 
                _eventData_.winnerName, 
                _eventData_.amountWon, 
                _eventData_.newPot
            );
            
        // in any other situation
        } else {
            // get their earnings
            _eth = withdrawEarnings(_pID);
            
            // gib moni
            if (_eth > 0)
                plyr_[_pID].addr.transfer(_eth);
            
            // fire withdraw event
            emit PolyFomoEvents.onWithdraw(_pID, msg.sender, username.getNameByAddress(plyr_[_pID].addr), _eth, _now);
        }
    }
    
//==============================================================================
//     _  _ _|__|_ _  _ _  .
//    (_|(/_ |  | (/_| _\  . (for UI & viewing things on etherscan)
//=====_|=======================================================================

    /**
     * @dev return minimum purchase in POLY for 1 timer increment
     * @return minimum purchase in POLY for 1 timer increment (in wei format)
     */

    function getIncrementPrice()
        public 
        view
        returns(uint256)
    {  
        // setup local rID
        uint256 _rID = rID_;
        
        // grab pot
        uint256 _pot = round_[_rID].pot;
        
        return (_pot / 1000000000000000000).mul(100000000000000000000);
    }

    /**
     * @dev return the price buyer will pay for next 1 individual poly.
     * @return price for next poly bought (in wei format)
     */
    function getBuyPrice()
        public 
        view 
        returns(uint256)
    {  
        // setup local rID
        uint256 _rID = rID_;
        
        // grab time
        uint256 _now = now;
        
        // are we in a round?
        if (_now > round_[_rID].strt && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].poly.add(1000000000000000000)).ethRec(1000000000000000000) );
        else // rounds over.  need price for new round
            return ( 75000000000000 ); // init
    }
    
    /**
     * @dev returns time left.  dont spam this, you'll ddos yourself from your node 
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
            if (_now > round_[_rID].strt)
                return( (round_[_rID].end).sub(_now) );
            else
                return( (round_[_rID].strt).sub(_now) );
        else
            return(0);
    }
    
    /**
     * @dev returns player earnings per vaults 
     * @return winnings vault
     * @return general vault
     * @return affiliate vault
     */
    function getPlayerVaults(uint256 _pID)
        public
        view
        returns(uint256 ,uint256, uint256)
    {
        // setup local rID
        uint256 _rID = rID_;
        
        // if round has ended.  but round end has not been run (so contract has not distributed winnings)
        if (now > round_[_rID].end && round_[_rID].ended == false && round_[_rID].plyr != 0)
        {
            // if player is winner 
            if (round_[_rID].plyr == _pID)
            {
                return
                (
                    (plyr_[_pID].win).add(round_[_rID].pot),
                    (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)   ),
                    plyr_[_pID].aff
                );
            // if player is not the winner
            } else {
                return
                (
                    plyr_[_pID].win,
                    (plyr_[_pID].gen).add(  getPlayerVaultsHelper(_pID, _rID).sub(plyrRnds_[_pID][_rID].mask)  ),
                    plyr_[_pID].aff
                );
            }
            
        // if round is still going on, or round has ended and round end has been ran
        } else {
            return
            (
                plyr_[_pID].win,
                (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),
                plyr_[_pID].aff
            );
        }
    }
    
    /**
     * solidity hates stack limits.  this lets us avoid that hate 
     */
    function getPlayerVaultsHelper(uint256 _pID, uint256 _rID)
        private
        view
        returns(uint256)
    {
        return round_[_rID].mask.mul(plyrRnds_[_pID][_rID].poly) / 1000000000000000000;
    }
    
    /**
     * @dev returns all current round info needed for front end
     * @return round id 
     * @return total poly for round 
     * @return time round ends
     * @return time round started
     * @return current pot 
     * @return current player in leads address 
     * @return current player in leads name
     * @return eth spent in current round
     */
    function getCurrentRoundInfo()
        public
        view
        returns(uint256, uint256, uint256, uint256, uint256, address, bytes32, uint256)
    {
        // setup local rID
        uint256 _rID = rID_;
        
        return
        (
            _rID,                                                     //0
            round_[_rID].poly,                                        //1
            round_[_rID].end,                                         //2
            round_[_rID].strt,                                        //3
            round_[_rID].pot,                                         //4
            plyr_[round_[_rID].plyr].addr,                            //5
            username.getNameByAddress(plyr_[round_[_rID].plyr].addr), //6
            rndEth_                                                   //7
        );
    }

    /**
     * @dev returns player info based on address.  if no address is given, it will 
     * use msg.sender 
     * @param _addr address of the player you want to lookup 
     * @return player ID 
     * @return player name
     * @return poly owned (current round)
     * @return winnings vault
     * @return general vault 
     * @return affiliate vault 
     * @return player round eth
     */
    function getPlayerInfoByAddress(address _addr)
        public 
        view 
        returns(uint256, bytes32, uint256, uint256, uint256, uint256, uint256)
    {
        // setup local rID
        uint256 _rID = rID_;
        
        if (_addr == address(0))
        {
            _addr == msg.sender;
        }
        uint256 _pID = pIDxAddr_[_addr];
        
        return
        (
            _pID,                               //0
            username.getNameByAddress(_addr),   //1
            plyrRnds_[_pID][_rID].poly,         //2
            plyr_[_pID].win,                    //3
            (plyr_[_pID].gen).add(calcUnMaskedEarnings(_pID, plyr_[_pID].lrnd)),       //4
            plyr_[_pID].aff,                    //5
            plyrRnds_[_pID][_rID].eth           //6
        );
    }

//==============================================================================
//     _ _  _ _   | _  _ . _  .
//    (_(_)| (/_  |(_)(_||(_  . (this + tools + calcs + modules = our softwares engine)
//=====================_|=======================================================
    /**
     * @dev logic runs whenever a buy order is executed.  determines how to handle 
     * incoming eth depending on if we are in an active round or not
     */
    function buyCore(uint256 _pID, uint256 _affID, PolyFomoDatasets.EventReturns memory _eventData_)
        private
    {
        // setup local rID
        uint256 _rID = rID_;
        
        // grab time
        uint256 _now = now;
        // if round is active
        if (_now > round_[_rID].strt && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0))) 
        {
            // call core 
            core(_rID, _pID, msg.value, _affID, _eventData_);
        
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
                _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
                
                // fire buy and distribute event 
                emit PolyFomoEvents.onBuyAndDistribute
                (
                    msg.sender, 
                    username.getNameByAddress(plyr_[_pID].addr), 
                    msg.value, 
                    _eventData_.compressedData, 
                    _eventData_.compressedIDs, 
                    _eventData_.winnerAddr, 
                    _eventData_.winnerName, 
                    _eventData_.amountWon, 
                    _eventData_.newPot
                );
            }
            
            // put eth in players vault 
            plyr_[_pID].gen = plyr_[_pID].gen.add(msg.value);
        }
    }
    
    /**
     * @dev logic runs whenever a reload order is executed.  determines how to handle 
     * incoming eth depending on if we are in an active round or not 
     */
    function reLoadCore(uint256 _pID, uint256 _affID, uint256 _eth, PolyFomoDatasets.EventReturns memory _eventData_)
        private
    {
        // setup local rID
        uint256 _rID = rID_;
        
        // grab time
        uint256 _now = now;
        
        // if round is active
        if (_now > round_[_rID].strt && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0))) 
        {
            // get earnings from all vaults and return unused to gen vault
            // because we use a custom safemath library.  this will throw if player 
            // tried to spend more eth than they have.
            plyr_[_pID].gen = withdrawEarnings(_pID).sub(_eth);
            
            // call core 
            core(_rID, _pID, _eth, _affID, _eventData_);
        
        // if round is not active and end round needs to be ran   
        } else if (_now > round_[_rID].end && round_[_rID].ended == false) {
            // end the round (distributes pot) & start new round
            round_[_rID].ended = true;
            _eventData_ = endRound(_eventData_);
                
            // build event data
            _eventData_.compressedData = _eventData_.compressedData + (_now * 1000000000000000000);
            _eventData_.compressedIDs = _eventData_.compressedIDs + _pID;
                
            // fire buy and distribute event 
            emit PolyFomoEvents.onReLoadAndDistribute
            (
                msg.sender, 
                username.getNameByAddress(plyr_[_pID].addr), 
                _eventData_.compressedData, 
                _eventData_.compressedIDs, 
                _eventData_.winnerAddr, 
                _eventData_.winnerName, 
                _eventData_.amountWon, 
                _eventData_.newPot
            );
        }
    }
    
    /**
     * @dev this is the core logic for any buy/reload that happens while a round 
     * is live.
     */
    function core(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, PolyFomoDatasets.EventReturns memory _eventData_)
        private
    {
        // if player is new to round
        if (plyrRnds_[_pID][_rID].poly == 0)
            _eventData_ = managePlayer(_pID, _eventData_);
        
        // early round eth limiter 
        if (round_[_rID].eth < 30000000000000000000 && plyrRnds_[_pID][_rID].eth.add(_eth) > 1000000000000000000)
        {
            uint256 _availableLimit = (1000000000000000000).sub(plyrRnds_[_pID][_rID].eth);
            uint256 _refund = _eth.sub(_availableLimit);
            plyr_[_pID].gen = plyr_[_pID].gen.add(_refund);
            _eth = _availableLimit;
        }
        
        // if eth left is greater than min eth allowed (sorry no pocket lint)
        if (_eth > 1000000000) 
        {
            
            // mint the new poly
            uint256 _poly = (round_[_rID].eth).polyRec(_eth);
            
            if (_poly >= getIncrementPrice())
            {
                updateTimer(_rID);

                // set new leaders
                if (round_[_rID].plyr != _pID)
                    round_[_rID].plyr = _pID;  
                
                // set the new leader bool to true
                _eventData_.compressedData = _eventData_.compressedData + 100;
            }
            
            // update player 
            plyrRnds_[_pID][_rID].poly = _poly.add(plyrRnds_[_pID][_rID].poly);
            plyrRnds_[_pID][_rID].eth = _eth.add(plyrRnds_[_pID][_rID].eth);
            
            // update round
            round_[_rID].poly = _poly.add(round_[_rID].poly);
            round_[_rID].eth = _eth.add(round_[_rID].eth);
            rndEth_ = _eth.add(rndEth_);
    
            // distribute eth
            _eventData_ = distributeExternal(_rID, _pID, _eth, _affID, _eventData_);
            _eventData_ = distributeInternal(_rID, _pID, _eth, _poly, _eventData_);
            
            // call end tx function to fire end tx event.
            endTx(_pID, _eth, _poly, _eventData_);
        }
    }
//==============================================================================
//     _ _ | _   | _ _|_ _  _ _  .
//    (_(_||(_|_||(_| | (_)| _\  .
//==============================================================================
    /**
     * @dev calculates unmasked earnings (just calculates, does not update mask)
     * @return earnings in wei format
     */
    function calcUnMaskedEarnings(uint256 _pID, uint256 _rIDlast)
        private
        view
        returns(uint256)
    {
        return(  (((round_[_rIDlast].mask).mul(plyrRnds_[_pID][_rIDlast].poly)) / (1000000000000000000)).sub(plyrRnds_[_pID][_rIDlast].mask)  );
    }
    
    /** 
     * @dev returns the amount of poly you would get given an amount of eth. 
     * @param _rID round ID you want price for
     * @param _eth amount of eth sent in 
     * @return poly received 
     */
    function calcPolyReceived(uint256 _rID, uint256 _eth)
        public
        view
        returns(uint256)
    {
        // grab time
        uint256 _now = now;
        
        // are we in a round?
        if (_now > round_[_rID].strt && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].eth).polyRec(_eth) );
        else // rounds over.  need poly for new round
            return ( (_eth).poly() );
    }
    
    /** 
     * @dev returns current eth price for X poly.  
     * @param _poly number of poly desired (in 18 decimal format)
     * @return amount of eth needed to send
     */
    function iWantXPoly(uint256 _poly)
        public
        view
        returns(uint256)
    {
        // setup local rID
        uint256 _rID = rID_;
        
        // grab time
        uint256 _now = now;
        
        // are we in a round?
        if (_now > round_[_rID].strt && (_now <= round_[_rID].end || (_now > round_[_rID].end && round_[_rID].plyr == 0)))
            return ( (round_[_rID].poly.add(_poly)).ethRec(_poly) );
        else // rounds over.  need price for new round
            return ( (_poly).eth() );
    }
//==============================================================================
//    _|_ _  _ | _  .
//     | (_)(_)|_\  .
//==============================================================================
        
    /**
     * @dev gets existing or registers new pID.  use this when a player may be new
     * @return pID 
     */
    function determinePID(PolyFomoDatasets.EventReturns memory _eventData_)
        private
        returns (PolyFomoDatasets.EventReturns memory)
    {
        uint256 _pID = pIDxAddr_[msg.sender];

        if (_pID == 0)
        {
            pID_++;
            pIDxAddr_[msg.sender] = pID_;
            plyr_[pID_].addr = msg.sender;
            
            // set the new player bool to true
            _eventData_.compressedData = _eventData_.compressedData + 1;
        }
        
        return (_eventData_);
    }
    
    /**
     * @dev registers a non-player referrer
     * @return pID 
     */
    function registerReferrer(address _affCode)
        private
        returns (uint256 affID)
    {
        pID_++;
        pIDxAddr_[_affCode] = pID_;
        plyr_[pID_].addr = _affCode;
        
        return pID_;
    }
    
    /**
     * @dev decides if round end needs to be run & new round started.  and if 
     * player unmasked earnings from previously played rounds need to be moved.
     */
    function managePlayer(uint256 _pID, PolyFomoDatasets.EventReturns memory _eventData_)
        private
        returns (PolyFomoDatasets.EventReturns memory)
    {
        // if player has played a previous round, move their unmasked earnings
        // from that round to gen vault.
        if (plyr_[_pID].lrnd != 0)
            updateGenVault(_pID, plyr_[_pID].lrnd);
            
        // update player's last round played
        plyr_[_pID].lrnd = rID_;
            
        // set the joined round bool to true
        _eventData_.compressedData = _eventData_.compressedData + 10;
        
        return(_eventData_);
    }
    
    /**
     * @dev ends the round. manages paying out winner/splitting up pot
     */
    function endRound(PolyFomoDatasets.EventReturns memory _eventData_)
        private
        returns (PolyFomoDatasets.EventReturns memory)
    {
        // setup local rID
        uint256 _rID = rID_;
        
        // grab our winning player
        uint256 _winPID = round_[_rID].plyr;
        
        // Entire 20% of buys / pot value
        uint256 _win = round_[_rID].pot;

        // pay our winner
        plyr_[_winPID].win = _win.add(plyr_[_winPID].win);
        
        // prepare event data
        _eventData_.compressedData = _eventData_.compressedData + (round_[_rID].end * 1000000);
        _eventData_.compressedIDs = _eventData_.compressedIDs + (_winPID * 100000000000000000000000000);
        _eventData_.winnerAddr = plyr_[_winPID].addr;
        _eventData_.winnerName = username.getNameByAddress(plyr_[_winPID].addr);
        _eventData_.amountWon = _win;
        _eventData_.newPot = 0;
        
        // start next round
        rID_++;
        _rID++;
        round_[_rID].strt = now;
        round_[_rID].end = now.add(rndInit_);
        round_[_rID].pot = 0;
        
        return(_eventData_);
    }
    
    /**
     * @dev moves any unmasked earnings to gen vault.  updates earnings mask
     */
    function updateGenVault(uint256 _pID, uint256 _rIDlast)
        private 
    {
        uint256 _earnings = calcUnMaskedEarnings(_pID, _rIDlast);
        if (_earnings > 0)
        {
            // put in gen vault
            plyr_[_pID].gen = _earnings.add(plyr_[_pID].gen);
            // zero out their earnings by updating mask
            plyrRnds_[_pID][_rIDlast].mask = _earnings.add(plyrRnds_[_pID][_rIDlast].mask);
        }
    }
    
    /**
     * @dev increment timer if poly requirement is met
     */
    function updateTimer(uint256 _rID)
        private
    {
        // grab time
        uint256 _now = now;
        
        // calculate time based on number of poly bought
        uint256 _newTime;
        if (_now > round_[_rID].end && round_[_rID].plyr == 0)
            _newTime = rndInc_.add(_now);
        else
            _newTime = rndInc_.add(round_[_rID].end);
        
        // compare to max and set new end time
        if (_newTime < (rndMax_).add(_now))
            round_[_rID].end = _newTime;
        else
            round_[_rID].end = rndMax_.add(_now);
    }

    /**
     * @dev distributes eth based on fees to com, aff, and cube
     */
    function distributeExternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _affID, PolyFomoDatasets.EventReturns memory _eventData_)
        private
        returns(PolyFomoDatasets.EventReturns memory)
    {       
        uint256 _cube;
    
        // 5% for the developers :)
        uint256 _com = _eth / 20;
        comAddress_.transfer(_com);
        
        // 10% for aff or CUBE holders
        uint256 _aff = _eth / 10;
        
        if (_affID != _pID && _affID != 0) {
            plyr_[_affID].aff = _aff.add(plyr_[_affID].aff);
            emit PolyFomoEvents.onAffiliatePayout(_affID, plyr_[_affID].addr, username.getNameByAddress(plyr_[_affID].addr), _rID, _pID, _aff, now);
        } else {
            _cube = _aff;
        }
        
        // 15% for CUBE holders
        _cube = _cube.add((_eth.mul(15)) / (100));
        if (_cube > 0)
        {
            // distribute to CUBE
            cube.distribute.value(_cube)();
            
            // set up event data
            _eventData_.cubeAmount = _cube.add(_eventData_.cubeAmount);
        }
        
        return(_eventData_);
    }

    /**
     * @dev distributes eth based on fees to gen and pot
     */
    function distributeInternal(uint256 _rID, uint256 _pID, uint256 _eth, uint256 _poly, PolyFomoDatasets.EventReturns memory _eventData_)
        private
        returns(PolyFomoDatasets.EventReturns memory)
    {
        // 50% for POLY holders
        uint256 _gen = (_eth.mul(50)) / 100;
        
        // update eth balance (eth = eth - (developers (5%) + aff share (10%)) + cube share (15%))
        _eth = _eth.sub((_eth.mul(30)) / 100);
        
        // 20% for winner
        uint256 _pot = _eth.sub(_gen);
        
        // distribute gen share (thats what updateMasks() does) and adjust
        // balances for dust.
        uint256 _dust = updateMasks(_rID, _pID, _gen, _poly);
        if (_dust > 0)
            _gen = _gen.sub(_dust);
        
        // add the 20% + dust
        round_[_rID].pot = _pot.add(_dust).add(round_[_rID].pot);
        
        // set up event data
        _eventData_.genAmount = _gen.add(_eventData_.genAmount);
        _eventData_.potAmount = _pot;
        
        return(_eventData_);
    }
    
    /**
     * @dev updates masks for round and player when poly are bought
     * @return dust left over 
     */
    function updateMasks(uint256 _rID, uint256 _pID, uint256 _gen, uint256 _poly)
        private
        returns(uint256)
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
        
        // calc profit per poly & round mask based on this buy:  (dust goes to pot)
        uint256 _ppt = (_gen.mul(1000000000000000000)) / (round_[_rID].poly);
        round_[_rID].mask = _ppt.add(round_[_rID].mask);
            
        // calculate player earning from their own buy (only based on the poly
        // they just bought).  & update player earnings mask
        uint256 _pearn = (_ppt.mul(_poly)) / (1000000000000000000);
        plyrRnds_[_pID][_rID].mask = (((round_[_rID].mask.mul(_poly)) / (1000000000000000000)).sub(_pearn)).add(plyrRnds_[_pID][_rID].mask);
        
        // calculate & return dust
        return(_gen.sub((_ppt.mul(round_[_rID].poly)) / (1000000000000000000)));
    }
    
    /**
     * @dev adds up unmasked earnings, & vault earnings, sets them all to 0
     * @return earnings in wei format
     */
    function withdrawEarnings(uint256 _pID)
        private
        returns(uint256)
    {
        // update gen vault
        updateGenVault(_pID, plyr_[_pID].lrnd);
        
        // from vaults 
        uint256 _earnings = (plyr_[_pID].win).add(plyr_[_pID].gen).add(plyr_[_pID].aff);
        if (_earnings > 0)
        {
            plyr_[_pID].win = 0;
            plyr_[_pID].gen = 0;
            plyr_[_pID].aff = 0;
        }

        return(_earnings);
    }
    
    /**
     * @dev prepares compression data and fires event for buy or reload tx's
     */
    function endTx(uint256 _pID, uint256 _eth, uint256 _poly, PolyFomoDatasets.EventReturns memory _eventData_)
        private
    {
        _eventData_.compressedData = _eventData_.compressedData + (now * 1000000000000000000);
        _eventData_.compressedIDs = _eventData_.compressedIDs + _pID + (rID_ * 10000000000000000000000000000000000000000000000000000);
        
        emit PolyFomoEvents.onEndTx
        (
            _eventData_.compressedData,
            _eventData_.compressedIDs,
            username.getNameByAddress(plyr_[_pID].addr),
            msg.sender,
            _eth,
            _poly,
            _eventData_.winnerAddr,
            _eventData_.winnerName,
            _eventData_.amountWon,
            _eventData_.newPot,
            _eventData_.cubeAmount,
            _eventData_.genAmount,
            _eventData_.potAmount
        );
    }
}

//==============================================================================
//   __|_ _    __|_ _  .
//  _\ | | |_|(_ | _\  .
//==============================================================================
library PolyFomoDatasets {
    struct EventReturns {
        uint256 compressedData;
        uint256 compressedIDs;
        address winnerAddr;         // winner address
        bytes32 winnerName;         // winner name
        uint256 amountWon;          // amount won
        uint256 newPot;             // amount in new pot
        uint256 cubeAmount;         // amount distributed to cube
        uint256 genAmount;          // amount distributed to gen
        uint256 potAmount;          // amount added to pot
    }
    struct Player {
        address addr;   // player address
        bytes32 name;   // player name
        uint256 win;    // winnings vault
        uint256 gen;    // general vault
        uint256 aff;    // affiliate vault
        uint256 lrnd;   // last round played
        uint256 laff;   // last affiliate id used
    }
    struct PlayerRounds {
        uint256 eth;    // eth player has added to round (used for eth limiter)
        uint256 poly;   // poly
        uint256 mask;   // player mask 
    }
    struct Round {
        uint256 plyr;   // pID of player in lead
        uint256 end;    // time ends/ended
        bool ended;     // has round end function been ran
        uint256 strt;   // time round started
        uint256 poly;   // poly
        uint256 eth;    // total eth in
        uint256 pot;    // eth to pot (during round) / final amount paid to winner (after round ends)
        uint256 mask;   // global mask
    }
}

//==============================================================================
//  |  _      _ _ | _  .
//  |<(/_\/  (_(_||(_  .
//=======/======================================================================
library PolygonCalcLong {
    using SafeMath for *;
    /**
     * @dev calculates number of poly received given X eth 
     * @param _curEth current amount of eth in contract 
     * @param _newEth eth being spent
     * @return amount of ticket purchased
     */
    function polyRec(uint256 _curEth, uint256 _newEth)
        internal
        pure
        returns (uint256)
    {
        return(poly((_curEth).add(_newEth)).sub(poly(_curEth)));
    }
    
    /**
     * @dev calculates amount of eth received if you sold X poly 
     * @param _curPoly current amount of poly that exist 
     * @param _sellPoly amount of poly you wish to sell
     * @return amount of eth received
     */
    function ethRec(uint256 _curPoly, uint256 _sellPoly)
        internal
        pure
        returns (uint256)
    {
        return((eth(_curPoly)).sub(eth(_curPoly.sub(_sellPoly))));
    }

    /**
     * @dev calculates how many poly would exist with given an amount of eth
     * @param _eth eth "in contract"
     * @return number of poly that would exist
     */
    function poly(uint256 _eth) 
        internal
        pure
        returns(uint256)
    {
        return ((((((_eth).mul(1000000000000000000)).mul(312500000000000000000000000)).add(5624988281256103515625000000000000000000000000000000000000000000)).sqrt()).sub(74999921875000000000000000000000)) / (156250000);
    }
    
    /**
     * @dev calculates how much eth would be in contract given a number of poly
     * @param _poly number of poly "in contract" 
     * @return eth that would exists
     */
    function eth(uint256 _poly) 
        internal
        pure
        returns(uint256)  
    {
        return ((78125000).mul(_poly.sq()).add(((149999843750000).mul(_poly.mul(1000000000000000000))) / (2))) / ((1000000000000000000).sq());
    }
}

//==============================================================================
//  . _ _|_ _  _ |` _  _ _  _  .
//  || | | (/_| ~|~(_|(_(/__\  .
//==============================================================================

interface UsernameInterface {
    function getNameByAddress(address _addr) external view returns (bytes32);
}

interface CubeInterface {
    function distribute() external payable;
    function startTime() external view returns (uint256);
}

/**
 * @title SafeMath v0.1.9
 * @dev Math operations with safety checks that throw on error
 * change notes:  original SafeMath library from OpenZeppelin modified by Inventor
 * - added sqrt
 * - added sq
 * - added pwr 
 * - changed asserts to requires with error log outputs
 * - removed div, its useless
 */
library SafeMath {
    
    /**
    * @dev Multiplies two numbers, throws on overflow.
    */
    function mul(uint256 a, uint256 b) 
        internal 
        pure 
        returns (uint256 c) 
    {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        require(c / a == b, "SafeMath mul failed");
        return c;
    }

    /**
    * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256) 
    {
        require(b <= a, "SafeMath sub failed");
        return a - b;
    }

    /**
    * @dev Adds two numbers, throws on overflow.
    */
    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c) 
    {
        c = a + b;
        require(c >= a, "SafeMath add failed");
        return c;
    }
    
    /**
     * @dev gives square root of given x.
     */
    function sqrt(uint256 x)
        internal
        pure
        returns (uint256 y) 
    {
        uint256 z = ((add(x,1)) / 2);
        y = x;
        while (z < y) 
        {
            y = z;
            z = ((add((x / z),z)) / 2);
        }
    }
    
    /**
     * @dev gives square. multiplies x by x
     */
    function sq(uint256 x)
        internal
        pure
        returns (uint256)
    {
        return (mul(x,x));
    }
    
    /**
     * @dev x to the power of y 
     */
    function pwr(uint256 x, uint256 y)
        internal 
        pure 
        returns (uint256)
    {
        if (x==0)
            return (0);
        else if (y==0)
            return (1);
        else 
        {
            uint256 z = x;
            for (uint256 i=1; i < y; i++)
                z = mul(z,x);
            return (z);
        }
    }
}