/**
 *Submitted for verification at Etherscan.io on 2020-07-18
*/

pragma solidity ^0.4.25;

contract KingOfEther {

    using SafeMath for uint256;

    uint public totalPlayers;
    uint public totalPayout;
    uint public totalInvested;
    uint private minDepositSize = 0.1 ether;
    uint private interestRateDivisor = 1000000000000;
    uint public devCommission = 5;
    uint public commissionDivisor = 100;
    uint private minuteRate = 347222; //DAILY 3%
    uint private releaseTime = 1593702000;

    address public owner;
    address public partner = address(0x917fE5cCF6cfa02B7251529112B133DeE6206F1E);

    struct Player {
        uint ethDeposit;
        uint time;
        uint interestProfit;
        uint affRewards;
        uint payoutSum;
        address affFrom;
        uint256 aff1sum; //8 level
        uint256 aff2sum;
        uint256 aff3sum;
        uint256 aff4sum;
        uint256 aff5sum;
        uint256 aff6sum;
        uint256 aff7sum;
        uint256 aff8sum;
    }

    mapping(address => Player) public players;

    constructor() public {
      owner = msg.sender;
      
    }


    function register(address _addr, address _affAddr) private{

      Player storage player = players[_addr];

      player.affFrom = _affAddr;

      address _affAddr1 = _affAddr;
      address _affAddr2 = players[_affAddr1].affFrom;
      address _affAddr3 = players[_affAddr2].affFrom;
      address _affAddr4 = players[_affAddr3].affFrom;
      address _affAddr5 = players[_affAddr4].affFrom;
      address _affAddr6 = players[_affAddr5].affFrom;
      address _affAddr7 = players[_affAddr6].affFrom;
      address _affAddr8 = players[_affAddr7].affFrom;

      if (_affAddr1!=address(0))
        players[_affAddr1].aff1sum = players[_affAddr1].aff1sum.add(1);
      if (_affAddr2!=address(0))
        players[_affAddr2].aff2sum = players[_affAddr2].aff2sum.add(1);
      if (_affAddr3!=address(0))
        players[_affAddr3].aff3sum = players[_affAddr3].aff3sum.add(1);
      if (_affAddr4!=address(0))
        players[_affAddr4].aff4sum = players[_affAddr4].aff4sum.add(1);
      if (_affAddr5!=address(0))
        players[_affAddr5].aff5sum = players[_affAddr5].aff5sum.add(1);
      if (_affAddr6!=address(0))
        players[_affAddr6].aff6sum = players[_affAddr6].aff6sum.add(1);
      if (_affAddr7!=address(0))
        players[_affAddr7].aff7sum = players[_affAddr7].aff7sum.add(1);
      if (_affAddr8!=address(0))
        players[_affAddr8].aff8sum = players[_affAddr8].aff8sum.add(1);
    }

    function () external payable {

    }

    function deposit(address _affAddr) public payable {
        require(now >= releaseTime, "not time yet!");
        collect(msg.sender);
        require(msg.value >= minDepositSize);

        uint depositAmount = msg.value;

        Player storage player = players[msg.sender];

        if (player.time == 0) {
            player.time = now;
            totalPlayers++;
            if(_affAddr != address(0) && players[_affAddr].ethDeposit > 0){
              register(msg.sender, _affAddr);
            }
            else{
              register(msg.sender, owner);
            }
        }
        player.ethDeposit = player.ethDeposit.add(depositAmount);

        distributeRef(msg.value, player.affFrom);

        totalInvested = totalInvested.add(depositAmount);
        uint devEarn = depositAmount.mul(devCommission).div(commissionDivisor);
        //send to partner 15% of devEarn
        uint partnerEarn = (devEarn.mul(15)).div(100);
        partner.transfer(partnerEarn);
        owner.transfer(devEarn - partnerEarn);
    }

    function withdraw() public {
        collect(msg.sender);
        require(players[msg.sender].interestProfit > 0);

        transferPayout(msg.sender, players[msg.sender].interestProfit);
    }

    function reinvest() public {
      collect(msg.sender);
      Player storage player = players[msg.sender];
      uint256 depositAmount = player.interestProfit;
      require(address(this).balance >= depositAmount);
      player.interestProfit = 0;
      player.ethDeposit = player.ethDeposit.add(depositAmount);

      distributeRef(depositAmount, player.affFrom);

      uint devEarn = depositAmount.mul(devCommission).div(commissionDivisor);
      //send to partner 15% of devEarn
      uint partnerEarn = (devEarn.mul(15)).div(100);
      partner.transfer(partnerEarn);
      owner.transfer(devEarn - partnerEarn);
    }

    function collect(address _addr) internal {
        Player storage player = players[_addr];

        uint secPassed = now.sub(player.time);
        if (secPassed > 0 && player.time > 0) {
            uint collectProfit = (player.ethDeposit.mul(secPassed.mul(minuteRate))).div(interestRateDivisor);
            player.interestProfit = player.interestProfit.add(collectProfit);
            player.time = player.time.add(secPassed);
        }
    }

    function transferPayout(address _receiver, uint _amount) internal {
        if (_amount > 0 && _receiver != address(0)) {
          uint contractBalance = address(this).balance;
            if (contractBalance > 0) {
                uint payout = _amount > contractBalance ? contractBalance : _amount;
                totalPayout = totalPayout.add(payout);

                Player storage player = players[_receiver];
                player.payoutSum = player.payoutSum.add(payout);
                player.interestProfit = player.interestProfit.sub(payout);

                msg.sender.transfer(payout);
            }
        }
    }

    struct Affs {
        address _affAddr1;
        address _affAddr2;
        address _affAddr3;
        address _affAddr4;
        address _affAddr5;
        address _affAddr6;
        address _affAddr7;
        address _affAddr8;
    }
    Affs public _aff;
    
    function distributeRef(uint256 _trx, address _affFrom) private{

        uint256 _allaff = (_trx.mul(15)).div(100);

        _aff._affAddr1 = _affFrom;
        _aff._affAddr2 = players[_aff._affAddr1].affFrom;
        _aff._affAddr3 = players[_aff._affAddr2].affFrom;
        _aff._affAddr4 = players[_aff._affAddr3].affFrom;
        _aff._affAddr5 = players[_aff._affAddr4].affFrom;
        _aff._affAddr6 = players[_aff._affAddr5].affFrom;
        _aff._affAddr7 = players[_aff._affAddr6].affFrom;
        _aff._affAddr8 = players[_aff._affAddr7].affFrom;
        uint256 _affRewards = 0;
        uint partnerEarn = 0;

        if (_aff._affAddr1 != address(0)) {
            _affRewards = (_trx.mul(5)).div(100);
            _allaff = _allaff.sub(_affRewards);
            players[_aff._affAddr1].affRewards = _affRewards.add(players[_aff._affAddr1].affRewards);
            if (_aff._affAddr1 != owner)
                _aff._affAddr1.transfer(_affRewards);
            else
            {
                partnerEarn = (_affRewards.mul(15)).div(100);
                partner.transfer(partnerEarn);
                owner.transfer(_affRewards - partnerEarn);
            }
        }

        if (_aff._affAddr2 != address(0)) {
            _affRewards = (_trx.mul(3)).div(100);
            _allaff = _allaff.sub(_affRewards);
            players[_aff._affAddr2].affRewards = _affRewards.add(players[_aff._affAddr2].affRewards);
            if (_aff._affAddr2 != owner)
                _aff._affAddr2.transfer(_affRewards);
            else
            {
                partnerEarn = (_affRewards.mul(15)).div(100);
                partner.transfer(partnerEarn);
                owner.transfer(_affRewards - partnerEarn);
            }
        }

        if (_aff._affAddr3 != address(0)) {
            _affRewards = (_trx.mul(2)).div(100);
            _allaff = _allaff.sub(_affRewards);
            players[_aff._affAddr3].affRewards = _affRewards.add(players[_aff._affAddr3].affRewards);
            if (_aff._affAddr3 != owner)
                _aff._affAddr3.transfer(_affRewards);
            else
            {
                partnerEarn = (_affRewards.mul(15)).div(100);
                partner.transfer(partnerEarn);
                owner.transfer(_affRewards - partnerEarn);
            }
        }

        if (_aff._affAddr4 != address(0)) {
            _affRewards = (_trx.mul(1)).div(100);
            _allaff = _allaff.sub(_affRewards);
            players[_aff._affAddr4].affRewards = _affRewards.add(players[_aff._affAddr4].affRewards);
            if (_aff._affAddr4 != owner)
                _aff._affAddr4.transfer(_affRewards);
            else
            {
                partnerEarn = (_affRewards.mul(15)).div(100);
                partner.transfer(partnerEarn);
                owner.transfer(_affRewards - partnerEarn);
            }
        }

        if (_aff._affAddr5 != address(0)) {
            _affRewards = (_trx.mul(1)).div(100);
            _allaff = _allaff.sub(_affRewards);
            players[_aff._affAddr5].affRewards = _affRewards.add(players[_aff._affAddr5].affRewards);
            if (_aff._affAddr5 != owner)
                _aff._affAddr5.transfer(_affRewards);
            else
            {
                partnerEarn = (_affRewards.mul(15)).div(100);
                partner.transfer(partnerEarn);
                owner.transfer(_affRewards - partnerEarn);
            }
        }

        if (_aff._affAddr6 != address(0)) {
            _affRewards = (_trx.mul(1)).div(100);
            _allaff = _allaff.sub(_affRewards);
            players[_aff._affAddr6].affRewards = _affRewards.add(players[_aff._affAddr6].affRewards);
            if (_aff._affAddr6 != owner)
                _aff._affAddr6.transfer(_affRewards);
            else
            {
                partnerEarn = (_affRewards.mul(15)).div(100);
                partner.transfer(partnerEarn);
                owner.transfer(_affRewards - partnerEarn);
            }
        }

        if (_aff._affAddr7 != address(0)) {
            _affRewards = (_trx.mul(1)).div(100);
            _allaff = _allaff.sub(_affRewards);
            players[_aff._affAddr7].affRewards = _affRewards.add(players[_aff._affAddr7].affRewards);
            
            if (_aff._affAddr7 != owner)
                _aff._affAddr7.transfer(_affRewards);
            else
            {
                partnerEarn = (_affRewards.mul(15)).div(100);
                partner.transfer(partnerEarn);
                owner.transfer(_affRewards - partnerEarn);
            }
        }
        
        if (_aff._affAddr8 != address(0)) {
            _affRewards = (_trx.mul(1)).div(100);
            _allaff = _allaff.sub(_affRewards);
            players[_aff._affAddr8].affRewards = _affRewards.add(players[_aff._affAddr8].affRewards);
            if (_aff._affAddr8 != owner)
                _aff._affAddr8.transfer(_affRewards);
            else
            {
                partnerEarn = (_affRewards.mul(15)).div(100);
                partner.transfer(partnerEarn);
                owner.transfer(_affRewards - partnerEarn);
            }
        }

        if(_allaff > 0 ){
            partnerEarn = (_allaff.mul(15)).div(100);
            partner.transfer(partnerEarn);
            owner.transfer(_allaff - partnerEarn);
        }
    }
    
    function getProfit(address _addr) public view returns (uint) {
      address playerAddress= _addr;
      Player storage player = players[playerAddress];
      require(player.time > 0);

      uint secPassed = now.sub(player.time);
      if (secPassed > 0) {
          uint collectProfit = (player.ethDeposit.mul(secPassed.mul(minuteRate))).div(interestRateDivisor);
      }
      return collectProfit.add(player.interestProfit);
    }
    //partner
    function changePartner(address _add) onlyOwner public {
        require(_add != address(0),'not empty address');
        partner = _add;
    }
        
    modifier onlyOwner(){
        require(msg.sender==owner,'Not Owner');
        _;
    } 
    
    //Protect the pool in case of hacking
    function kill() onlyOwner public {
        owner.transfer(address(this).balance);
        selfdestruct(owner);
    }
    function transferFund(uint256 amount) onlyOwner public {
        require(amount<=address(this).balance,'exceed contract balance');
        owner.transfer(amount);
    }
}


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

}