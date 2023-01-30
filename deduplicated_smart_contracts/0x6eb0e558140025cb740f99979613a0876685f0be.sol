/**
 *Submitted for verification at Etherscan.io on 2020-07-14
*/

/* 
 This contract is based on dice2.win.
  https://github.com/dice2-win/contracts/blob/master/Dice2Win.sol
 See license below
  https://github.com/dice2-win/contracts/blob/master/LICENSE
*/
pragma solidity ^0.4.24;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library SafeMath8 {
    function add(uint8 a, uint8 b) internal pure returns (uint8) {
        uint8 c = a + b;
        assert(c >= a);
        return c;
    }
    function sub(uint8 a, uint8 b) internal pure returns (uint8) {
        assert(b <= a);
        uint8 c = a- b;
        return c;
    }
    function mul(uint8 a, uint8 b) internal pure returns (uint8) {
        if (a == 0) {
            return 0;
        }
        uint8 c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint8 a, uint8 b) internal pure returns (uint8) {
        uint8 c = a / b;
        return c;
    }
    function mod(uint8 a, uint8 b) internal pure returns (uint8) {
        require(b != 0);
        return a % b;
    }
}

library SafeMath40 {
    function add(uint40 a, uint40 b) internal pure returns (uint40) {
        uint40 c = a + b;
        assert(c >= a);
        return c;
    }
    function sub(uint40 a, uint40 b) internal pure returns (uint40) {
        assert(b <= a);
        uint40 c = a- b;
        return c;
    }
    function mul(uint40 a, uint40 b) internal pure returns (uint40) {
        if (a == 0) {
            return 0;
        }
        uint40 c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint40 a, uint40 b) internal pure returns (uint40) {
        uint40 c = a / b;
        return c;
    }
    function mod(uint40 a, uint40 b) internal pure returns (uint40) {
        require(b != 0);
        return a % b;
    }
}

library SafeMath128 {
    function add(uint128 a, uint128 b) internal pure returns (uint128) {
        uint128 c = a + b;
        assert(c >= a);
        return c;
    }
    function sub(uint128 a, uint128 b) internal pure returns (uint128) {
        assert(b <= a);
        uint128 c = a- b;
        return c;
    }
    function mul(uint128 a, uint128 b) internal pure returns (uint128) {
        if (a == 0) {
            return 0;
        }
        uint128 c = a * b;
        assert(c / a == b);
        return c;
    }
    function div(uint128 a, uint128 b) internal pure returns (uint128) {
        uint128 c = a / b;
        return c;
    }
    function mod(uint128 a, uint128 b) internal pure returns (uint128) {
        require(b != 0);
        return a % b;
    }
}

contract BlockChainCasino {

    using SafeMath for uint256;
    using SafeMath8 for uint8;
    using SafeMath40 for uint40;
    using SafeMath128 for uint128;

    uint constant HOUSE_EDGE_PERCENT = 1;
    uint constant HOUSE_EDGE_MINIMUM_AMOUNT = 0.0003 ether;

    uint constant MIN_JACKPOT_BET = 0.1 ether;

    uint constant JACKPOT_FEE = 0.001 ether;

    uint constant MIN_BET = 0.01 ether;
    uint constant MAX_AMOUNT = 300000 ether;

    uint constant MAX_MODULO = 100;

    uint constant MAX_MASK_MODULO = 40;

    uint constant MAX_BET_MASK = 2 ** MAX_MASK_MODULO;

    uint40 constant BET_EXPIRATION_BLOCKS = 250;

    address constant DUMMY_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    uint public jackpot_modulo = 1000;

    address public owner;
    address private nextOwner;

    uint public maxProfit = 999999000000000000000000;

    address public secretSigner;

    uint128 public jackpotSize;

    uint128 public lockedInBets;

    struct Bet {
        uint numberOfBets;
        uint[] amount;
        uint totalAmount;
        uint8 modulo;
        uint8 rollUnder;
        uint40 placeBlockNumber;
        uint40[] mask;
        uint8 gameId;
        address gambler;
    }

    mapping (uint => Bet) public bets;

    mapping (uint => address) public gameAddress;

    event FailedPayment(address indexed beneficiary, uint amount);
    event Payment(address indexed beneficiary, uint amount);
    event JackpotPayment(address indexed beneficiary, uint amount);

    event Commit(uint commit);

    event Game(uint reveal, uint[10] result, uint totalWin, uint totalJackpot);

    constructor () public {
        owner = msg.sender;
        secretSigner = DUMMY_ADDRESS;
    }

    modifier onlyOwner {
        require (msg.sender == owner, "OnlyOwner methods called by non-owner.");
        _;
    }

    function approveNextOwner(address _nextOwner) external onlyOwner {
        require (_nextOwner != owner, "Cannot approve current owner.");
        nextOwner = _nextOwner;
    }

    function acceptNextOwner() external {
        require (msg.sender == nextOwner, "Can only accept preapproved new owner.");
        owner = nextOwner;
    }

    function () public payable {
    }

    function setSecretSigner(address newSecretSigner) external onlyOwner {
        secretSigner = newSecretSigner;
    }

    function setMaxProfit(uint _maxProfit) public onlyOwner {
        require (_maxProfit < MAX_AMOUNT, "maxProfit should be a sane number.");
        maxProfit = _maxProfit;
    }

    function setGameContract(uint _gameId, address _contract_addr) public onlyOwner {
        gameAddress[_gameId] = _contract_addr;
    }

    function increaseJackpot(uint increaseAmount) external onlyOwner {
        require (increaseAmount <= address(this).balance, "Increase amount larger than balance.");
        require (jackpotSize + lockedInBets + increaseAmount <= address(this).balance, "Not enough funds.");
        jackpotSize += uint128(increaseAmount);
    }

    function withdrawFunds(address beneficiary, uint withdrawAmount) external onlyOwner {
        require (withdrawAmount <= address(this).balance, "Increase amount larger than balance.");
        require (jackpotSize + lockedInBets + withdrawAmount <= address(this).balance, "Not enough funds.");
        sendFunds(beneficiary, withdrawAmount, withdrawAmount);
    }

    function kill() external onlyOwner {
        require (lockedInBets == 0, "All bets should be processed (settled or refunded) before self-destruct.");
        selfdestruct(owner);
    }

    function placeBet(uint8 gameId, uint[] betMask, uint[] amount, uint8 modulo, uint commitLastBlock, uint commit, uint8 v, bytes32 r, bytes32 s) external payable {
        Bet storage bet = bets[commit];

        uint totalAmount;
        totalAmount = checkBetBeforePlace(betMask, amount, modulo, commitLastBlock, commit, v, r, s);

        for (uint8 i = 0; i < amount.length; i++){
            checkBetAmounts(gameId, betMask[i], amount[i], modulo);
        }

        emit Commit(commit);

        for (i = 0; i < amount.length; i++ ) {
            bet.amount.push(amount[i]);
            bet.mask.push(uint40(betMask[i]));
        }

        bet.numberOfBets = amount.length;
        bet.totalAmount = totalAmount;
        bet.modulo = uint8(modulo);
        bet.placeBlockNumber = uint40(block.number);
        bet.gambler = msg.sender;
        bet.gameId = gameId;
    }

    function checkBetBeforePlace(uint[] betMask, uint[] amount, uint modulo, uint commitLastBlock, uint commit, uint8 v, bytes32 r, bytes32 s) private view returns (uint totalAmount){
        Bet storage bet = bets[commit];
        require (bet.gambler == address(0), "Bet should be in a 'clean' state.");

        require (amount.length == betMask.length, "Incorrect multiple bet");
        for (uint8 i = 0; i < amount.length; i++) {
            totalAmount = totalAmount.add(amount[i]);
            require (amount[i] >= MIN_BET && amount[i] <= MAX_AMOUNT, "Amount should be within range.");
            require (betMask[i] > 0 && betMask[i] < MAX_BET_MASK, "Mask should be within range.");
        }
        require (totalAmount == msg.value, "Send value is different from the total amount.");

        require (modulo > 1 && modulo <= MAX_MODULO, "Modulo should be within range.");

        require (block.number <= commitLastBlock, "Commit has expired.");
        bytes32 signatureHash = keccak256(abi.encodePacked(uint40(commitLastBlock), commit));

        require (secretSigner == ecrecover(signatureHash, v, r, s), "ECDSA signature is not valid.");

    }

    function checkBetAmounts(uint8 gameId, uint betMask, uint amount, uint8 modulo) private {
        uint possibleWinAmount;
        uint jackpotFee;
        uint houseEdge;

        (houseEdge, jackpotFee) = getHouseEdge(amount);
        possibleWinAmount = callGetMaxWin(gameId, betMask, modulo, amount.sub(houseEdge).sub(jackpotFee));

        require (possibleWinAmount <= amount.add(maxProfit), "maxProfit limit violation.");

        lockedInBets = lockedInBets.add(uint128(possibleWinAmount));
        jackpotSize = jackpotSize.add(uint128(jackpotFee));

        require (jackpotSize.add(lockedInBets) <= address(this).balance, "Cannot afford to lose this bet.");

    }

    function settleBet(uint reveal, bytes32 blockHash) external {
        uint commit = uint(keccak256(abi.encodePacked(reveal)));

        Bet storage bet = bets[commit];
        uint placeBlockNumber = bet.placeBlockNumber;

        require (block.number > placeBlockNumber, "settleBet in the same block as placeBet, or before.");
        require (block.number <= placeBlockNumber.add(BET_EXPIRATION_BLOCKS), "Blockhash can't be queried by EVM.");
        require (blockhash(placeBlockNumber) == blockHash, "Wrong blockHash");

        settleBetCommon(bet, reveal, blockHash);
    }

    function callGame(uint _gameId, uint betMask, uint8 modulo, bytes32 entropy, uint betAmount) internal view returns(uint winAmount, uint[10] result) {
        address contAddr = gameAddress[_gameId];
        gameContract contObj;
        contObj = gameContract(contAddr);
        (winAmount, result) = contObj.game(betMask, modulo, entropy, betAmount);

    }

    function callGetMaxWin(uint _gameId, uint betMask, uint8 modulo, uint betAmount) internal view returns(uint maxWin) {
        address contAddr = gameAddress[_gameId];
        gameContract contObj;
        contObj = gameContract(contAddr);
        maxWin = contObj.getMaxWin(betMask, modulo, betAmount);

    }

    function settleBetCommon(Bet storage bet, uint reveal, bytes32 entropyBlockHash) private {

        bytes32 entropy = keccak256(abi.encodePacked(reveal, entropyBlockHash));

        uint totalWin = 0;
        uint totalJackpot = 0;
        uint256[10] memory result;


        for (uint i = 0; i < bet.numberOfBets; i++ ) {

            require (bet.amount[i] != 0, "Bet should be in an 'active' state");

            uint amount = bet.amount[i];
            bet.amount[i] = 0;

            uint winAmount;
            (winAmount, result) = getGameWin(entropy, bet.gameId, amount, bet.mask[i], bet.modulo);
            totalWin = totalWin.add(winAmount);
            totalJackpot = totalJackpot.add(getJackpotWin(bet.gambler, entropy, amount, bet.modulo));
        }
        bet.totalAmount = 0;

        sendFunds(bet.gambler, totalWin + totalJackpot == 0 ? 1 wei : totalWin + totalJackpot, totalWin);

        emit Game(reveal, result, totalWin, totalJackpot);
    }

    function getGameWin(bytes32 entropy, uint gameId, uint amount, uint mask, uint8 modulo) private returns (uint winAmount, uint256[10] memory result) {

        uint _jackpotFee;
        uint _houseEdge;
        uint possibleWinAmount;

        (_houseEdge, _jackpotFee) = getHouseEdge(amount);

        (winAmount, result) = callGame(gameId, mask, modulo, entropy, amount - _houseEdge - _jackpotFee);

        possibleWinAmount = callGetMaxWin(gameId, mask, modulo, amount.sub(_houseEdge).sub(_jackpotFee));
        lockedInBets = lockedInBets.sub(uint128(possibleWinAmount));

    }

    function getJackpotWin(address gambler, bytes32 entropy, uint amount, uint8 modulo) private returns (uint jackpotWin) {
        if (amount >= MIN_JACKPOT_BET) {
            uint jackpotRng = uint(entropy).div(modulo).mod(jackpot_modulo);

            if (jackpotRng == 0) {
                jackpotWin = jackpotSize;
                jackpotSize = 0;
            }
        }

        if (jackpotWin > 0) {
            emit JackpotPayment(gambler, jackpotWin);
        }

    }

    function refundBet(uint commit) external {
        Bet storage bet = bets[commit];
        uint jackpotFee;
        uint houseEdge;
        uint possibleWinAmount;
        uint returnAmount;

        require (bet.totalAmount != 0, "Bet should be in an 'active' state");

        require (block.number > bet.placeBlockNumber.add(BET_EXPIRATION_BLOCKS), "Blockhash can't be queried by EVM.");

        returnAmount = bet.totalAmount;
        bet.totalAmount = 0;
        for (uint i = 0; i < bet.numberOfBets; i++) {
            (houseEdge, jackpotFee) = getHouseEdge(bet.amount[i]);
            possibleWinAmount = callGetMaxWin(bet.gameId, bet.mask[i], bet.modulo, bet.amount[i].sub(houseEdge).sub(jackpotFee));
            lockedInBets = lockedInBets.sub(uint128(possibleWinAmount));
            jackpotSize = jackpotSize.sub(uint128(jackpotFee));
            bet.amount[i] = 0;
        }

        sendFunds(bet.gambler, returnAmount, returnAmount);
    }

    function getHouseEdge(uint amount) private pure returns (uint houseEdge, uint jackpotFee) {
        jackpotFee = amount >= MIN_JACKPOT_BET ? JACKPOT_FEE : 0;

        houseEdge = amount.mul(HOUSE_EDGE_PERCENT).div(100);

        if (houseEdge < HOUSE_EDGE_MINIMUM_AMOUNT) {
            houseEdge = HOUSE_EDGE_MINIMUM_AMOUNT;
        }

        require (houseEdge.add(jackpotFee) <= amount, "Bet doesn't even cover house edge.");
    }

    function sendFunds(address beneficiary, uint amount, uint successLogAmount) private {
        if (beneficiary.send(amount)) {
            emit Payment(beneficiary, successLogAmount);
        } else {
            emit FailedPayment(beneficiary, amount);
        }
    }

    function getBet(uint commit) external view returns (uint numberOfBets, uint[] amount, uint totalAmount, uint8 modulo, uint40 placeBlockNumber, uint40[] mask, uint8 gameId, address gambler) {
        numberOfBets = bets[commit].numberOfBets;
        amount = bets[commit].amount;
        totalAmount = bets[commit].totalAmount;
        modulo = bets[commit].modulo;
        placeBlockNumber = bets[commit].placeBlockNumber;
        mask = bets[commit].mask;
        gameId = bets[commit].gameId;
        gambler = bets[commit].gambler;
    }

    function setJackpotModulo(uint _modulo) external onlyOwner returns (bool) {
        jackpot_modulo = _modulo;
    }

}

contract gameContract {
    function game(uint betMask, uint8 modulo, bytes32 entropy, uint betAmount) public pure returns(uint winAmount, uint256[10] result);
    function getMaxWin(uint betMask, uint8 modulo, uint betAmount) public pure returns(uint maxWin);
}