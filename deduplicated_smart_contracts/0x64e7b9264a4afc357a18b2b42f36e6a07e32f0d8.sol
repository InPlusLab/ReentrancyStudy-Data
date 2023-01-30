/**

 *Submitted for verification at Etherscan.io on 2018-12-20

*/



pragma solidity ^0.4.25;



// File: contracts/MoonRaffleContract.sol



contract MoonRaffleContract {



    address mainContractAddress;

    address addressOne;

    address burnAddress = 0x0;

    bytes32[4] initialSecretHashArray;



    uint256 seedAmount;

    uint256 depositAmount;



    struct MoonRaffleParams {



        // ECONOMIC PARAMETERS

        uint256 pricePerTicket;

        uint256 maxTicketsPerTransaction;

        uint256 prizePoolPercentage;

        uint256 firstPrizePercentage;

        uint256 secondPrizePercentage;

        uint256 thirdPrizePercentage;

        uint256 contractFeePercentage;

        uint256 rolloverPercentage;

        uint256 referralPercentage;

        uint256 referralHurdle;

        uint256 referralFloorTimePercentage;



        // TIME PARAMETERS

        uint256 moonRaffleLiveSecs;

        uint256 winnerCalcSecs;

        uint256 claimSecs;



    }



    MoonRaffleParams moonRaffleParameters;



    // TIME SETTINGS

    uint256 startTime;

    uint256 moonRaffleEndTime;

    uint256 winnerCalcDeadlineTime;

    uint256 finishClaimTime;

    uint256 referralFloorTime;

    uint256 waitTime = 3600;

    uint256 referralMultiplierInterval = 3600;



    // STATE BOOLS

    bool isSeeded = false;

    bool isDepositReceived = false;

    bool isNonceCalced = false;

    bool isWinnerCalced = false;



    address currentDefaultReferrerAddress;

    address currentStarReferrer;

    uint256 currentStarReferrerPoints;



    // ITERATION VARIABLES

    bytes32 randomNumber;

    bool[256] binaryNonce;

    uint256 nonceCalcTime = 0;

    uint256 fee = 0;

    uint256 rollover = 0;

    uint256 ticketCounter = 0;

    uint256 playerCounter = 0;

    uint256 referralPointsCounter = 0;



    mapping(address => uint256) entries;

    mapping(address => uint256) referralPoints;

    mapping(uint256 => address) tickets;

    mapping(address => uint256) winnerClaims;



    // FINAL STATE VARIABLES

    address firstPrizeAddressFinal;

    address secondPrizeAddressFinal;

    address thirdPrizeAddressFinal;



    uint256 firstPrizeAmountFinal;

    uint256 secondPrizeAmountFinal;

    uint256 thirdPrizeAmountFinal;

    uint256 feeAmountFinal;

    uint256 rolloverAmountFinal;

    uint256 referralBonusAmountFinal;

    uint256 totalTicketsFinal;

    uint256 totalPlayersFinal;

    uint256 seedAmountFinal;

    uint256 depositAmountFinal;

    uint256 referralPointsFinal;



    // EVENTS

    event logFallbackDonationTransaction(address _sender, uint256 _amount);

    event logContractSeeded(uint256 _seedAmount);

    event logContractDepositReceived(uint256 _depositAmount);

    event logContractActive(uint256 _startTime, uint256 _moonRaffleEndTime, uint256 _referralFloorTime, uint256 _winnerCalcDeadlineTime, uint256 _finishClaimTime);

    event logTicketPurchase(address _player, uint256 _numberOfTickets, bool _referrerValidity);

    event logPrizeClaimed(address _winner, uint256 _prizeAmount);

    event logReferralBonusClaimed(address _referrer, uint256 _bonusAmount);

    event logDepositBurn(uint256 _depositAmount);

    event logRefundClaimed(address _player, uint256 _refundAmount);

    event logSecretsRevealed(string _initialSecret1, string _initialSecret2, string _initialSecret3, string _initialSecret4);

    event logWinnersCalculated(address _first, uint256 _firstAmount, address _second, uint256 _secondAmount, address _third, uint256 _thirdAmount);







    // ACCESS MODIFIERS

    modifier isHuman() {

        address _addr = msg.sender;

        uint256 _codeLength;



        assembly {_codeLength := extcodesize(_addr)}

        require(_codeLength == 0, "sorry humans only");

        _;

    }



    modifier onlyAddressOne() {

        require(msg.sender == addressOne);

        _;

    }



    modifier onlyMainContract() {

        require(msg.sender == mainContractAddress);

        _;

    }



    // TIME MODIFIERS

    modifier retractContractPhase() {

        require(isDepositReceived == false);

        _;

    }



    modifier contractLive() {

        require(isSeeded == true);

        require(isDepositReceived == true);

        _;

    }



    modifier entryTimeLive() {

        require(isSeeded == true);

        require(isDepositReceived == true);

        require(now <= moonRaffleEndTime);

        _;

    }



    modifier nonceWaitingPhaseLive() {

        require(isSeeded == true);

        require(isDepositReceived == true);

        require(isNonceCalced == false);

        require(isWinnerCalced == false);

        require(now < moonRaffleEndTime + waitTime);

        _;

    }



    modifier nonceCalculationPhaseLive() {

        require(isSeeded == true);

        require(isDepositReceived == true);

        require(isNonceCalced == false);

        require(isWinnerCalced == false);

        require(now >= moonRaffleEndTime + waitTime);

        require(now <= winnerCalcDeadlineTime);

        _;

    }



    modifier winnerWaitingPhaseLive() {

        require(isSeeded == true);

        require(isDepositReceived == true);

        require(isNonceCalced == true);

        require(isWinnerCalced == false);

        require(now < nonceCalcTime + waitTime);

        _;

    }



    modifier winnerCalculationPhaseLive() {

        require(isSeeded == true);

        require(isDepositReceived == true);

        require(isNonceCalced == true);

        require(isWinnerCalced == false);

        require(now >= nonceCalcTime + waitTime);

        require(now <= winnerCalcDeadlineTime);

        _;

    }



    modifier prizeClaimPhaseLive() {

        require(isSeeded == true);

        require(isDepositReceived == true);

        require(isWinnerCalced == true);

        require(now <= finishClaimTime);

        _;

    }



    modifier moonRaffleContractCompleted() {

        require(isSeeded == true);

        require(isDepositReceived == true);

        require(isWinnerCalced == true);

        _;

    }



    modifier moonRaffleContractDead() {

        require(isSeeded == true);

        require(isDepositReceived == true);

        require(isWinnerCalced == true);

        require(now > finishClaimTime);

        _;

    }



    modifier refundPhaseLive() {

        require(isSeeded == true);

        require(isDepositReceived == true);

        require(isWinnerCalced == false);

        require(now > winnerCalcDeadlineTime);

        _;

    }



    // FALLBACK

    function() public payable {

        emit logFallbackDonationTransaction(msg.sender, msg.value);

    }





    constructor(

        address _mainContractAddress,

        address _addressOne,

        bytes32 _initialSecretHash1,

        bytes32 _initialSecretHash2,

        bytes32 _initialSecretHash3,

        bytes32 _initialSecretHash4,

        uint256[14] _moonRaffleParameters

    )

    public

    payable

    {

        mainContractAddress = _mainContractAddress;

        addressOne = _addressOne;

        currentDefaultReferrerAddress = _addressOne;

        currentStarReferrer = currentDefaultReferrerAddress;

        currentStarReferrerPoints = 0;

        initialSecretHashArray = [_initialSecretHash1, _initialSecretHash2, _initialSecretHash3, _initialSecretHash4];

        moonRaffleParameters.pricePerTicket = _moonRaffleParameters[0];

        moonRaffleParameters.maxTicketsPerTransaction = _moonRaffleParameters[1];

        moonRaffleParameters.prizePoolPercentage = _moonRaffleParameters[2];

        moonRaffleParameters.firstPrizePercentage = _moonRaffleParameters[3];

        moonRaffleParameters.secondPrizePercentage = _moonRaffleParameters[4];

        moonRaffleParameters.thirdPrizePercentage = _moonRaffleParameters[5];

        moonRaffleParameters.contractFeePercentage = _moonRaffleParameters[6];

        moonRaffleParameters.rolloverPercentage = _moonRaffleParameters[7];

        moonRaffleParameters.referralPercentage = _moonRaffleParameters[8];

        moonRaffleParameters.referralHurdle = _moonRaffleParameters[9];

        moonRaffleParameters.referralFloorTimePercentage = _moonRaffleParameters[10];

        moonRaffleParameters.moonRaffleLiveSecs = _moonRaffleParameters[11];

        moonRaffleParameters.winnerCalcSecs = _moonRaffleParameters[12];

        moonRaffleParameters.claimSecs = _moonRaffleParameters[13];



        startTime = now;

        moonRaffleEndTime = startTime + moonRaffleParameters.moonRaffleLiveSecs;

        winnerCalcDeadlineTime = moonRaffleEndTime + moonRaffleParameters.winnerCalcSecs;

        finishClaimTime = moonRaffleEndTime + moonRaffleParameters.claimSecs;

        referralFloorTime = startTime + (moonRaffleParameters.moonRaffleLiveSecs * moonRaffleParameters.referralFloorTimePercentage / 100);



        randomNumber = keccak256(abi.encodePacked(blockhash(block.number - 1)));

    }







    function sendContractSeed() onlyMainContract public payable {

        require(isSeeded == false);

        seedAmount = msg.value;

        isSeeded = true;

        emit logContractSeeded(seedAmount);

    }



    function sendContractDeposit() public payable {

        require(isSeeded == true);

        require(isDepositReceived == false);

        require(msg.value >= (seedAmount * moonRaffleParameters.contractFeePercentage / 200));

        depositAmount = msg.value;

        isDepositReceived = true;

        emit logContractDepositReceived(depositAmount);

        emit logContractActive(startTime, moonRaffleEndTime, referralFloorTime, winnerCalcDeadlineTime, finishClaimTime);

    }





    function hasEntry() public view returns (bool) {

        if (entries[msg.sender] > 0) {return true;}

        return false;

    }



    function isValidReferrer(address _referrerAddress) public view returns (bool) {

        if (entries[_referrerAddress] >= moonRaffleParameters.referralHurdle) {return true;}

        else if (_referrerAddress == addressOne) {return true;}

        else {return false;}

    }





    function play(address _referrerAddress) isHuman entryTimeLive external payable {

        require(msg.value >= moonRaffleParameters.pricePerTicket);



        uint256 numberOfEntries = (msg.value / moonRaffleParameters.pricePerTicket);

        if (numberOfEntries > moonRaffleParameters.maxTicketsPerTransaction) { numberOfEntries = moonRaffleParameters.maxTicketsPerTransaction; }



        uint256 numberOfEntriesTemp = (msg.value / moonRaffleParameters.pricePerTicket);

        if (numberOfEntriesTemp > moonRaffleParameters.maxTicketsPerTransaction) { numberOfEntriesTemp = moonRaffleParameters.maxTicketsPerTransaction; }



        uint256 tempReferralMultiplier = ( moonRaffleParameters.moonRaffleLiveSecs * (100 - moonRaffleParameters.referralFloorTimePercentage)) / (referralMultiplierInterval * 100);

        if (now < referralFloorTime) {

            tempReferralMultiplier = (moonRaffleEndTime - now) / referralMultiplierInterval;

        }

        uint256 tempReferralPoints = numberOfEntries * tempReferralMultiplier;

        uint256 tempTotalReferralPoints = 0;





        if (isValidReferrer(_referrerAddress)) {

            referralPoints[_referrerAddress] += tempReferralPoints * 4;

            referralPoints[msg.sender] += tempReferralPoints;

            referralPoints[currentDefaultReferrerAddress] += tempReferralPoints;

            tempTotalReferralPoints += tempReferralPoints * 6;

            updateStarReferrer(_referrerAddress);

            updateStarReferrer(msg.sender);

            updateStarReferrer(currentDefaultReferrerAddress);

        } else {

            referralPoints[currentDefaultReferrerAddress] += tempReferralPoints;

            tempTotalReferralPoints += tempReferralPoints;

            updateStarReferrer(currentDefaultReferrerAddress);

        }



        referralPointsCounter += tempTotalReferralPoints;



        if (!hasEntry()) {

            playerCounter += 1;

        }



        entries[msg.sender] += numberOfEntriesTemp;



        while (numberOfEntriesTemp > 0) {

            tickets[ticketCounter] = msg.sender;

            ticketCounter += 1;

            numberOfEntriesTemp -= 1;

        }



        randomNumber = keccak256(abi.encodePacked(randomNumber, blockhash(block.number - 1), msg.sender));



        if (isValidReferrer(msg.sender)) {

            currentDefaultReferrerAddress = msg.sender;

        }



        emit logTicketPurchase(msg.sender, numberOfEntries, isValidReferrer(msg.sender));

    }



    function updateStarReferrer(address _referrer) internal {

        if (referralPoints[_referrer] > currentStarReferrerPoints) {

            currentStarReferrer = _referrer;

            currentStarReferrerPoints = referralPoints[_referrer];

        }

    }





    function claimPrize() isHuman prizeClaimPhaseLive external {

        require(winnerClaims[msg.sender] > 0);

        uint256 prizeAmount = winnerClaims[msg.sender];

        winnerClaims[msg.sender] = 0;

        emit logPrizeClaimed(msg.sender, prizeAmount);

        msg.sender.transfer(prizeAmount);

    }



    function claimReferralBonus() isHuman prizeClaimPhaseLive external {

        require(referralPoints[msg.sender] > 0);

        uint256 tempReferralBonus = (referralBonusAmountFinal / referralPointsFinal) * referralPoints[msg.sender];

        referralPoints[msg.sender] = 0;

        emit logReferralBonusClaimed(msg.sender, tempReferralBonus);

        msg.sender.transfer(tempReferralBonus);

    }



    function claimRefund() isHuman refundPhaseLive external {

        require(hasEntry());

        if (depositAmount > 0) {burnDeposit();}

        uint256 refundAmount = (address(this).balance / ticketCounter) * entries[msg.sender];

        ticketCounter -= entries[msg.sender];

        entries[msg.sender] = 0;

        emit logRefundClaimed(msg.sender, refundAmount);

        msg.sender.transfer(refundAmount);

    }



    function calculateNonce() isHuman nonceCalculationPhaseLive external {

        uint256 counter = 1;

        while (counter <= 256) {

            uint temp = uint256(blockhash(block.number - counter)) % 2;

            if (temp == 0) {

                binaryNonce[counter - 1] = false;

            } else {

                binaryNonce[counter - 1] = true;

            }

            counter += 1;

        }

        nonceCalcTime = now;

        isNonceCalced = true;

    }



    function calculateFinalRandomNumber(string _initialSecret, uint _secretIndex) winnerCalculationPhaseLive internal {

        require(keccak256(abi.encodePacked(_initialSecret)) == initialSecretHashArray[_secretIndex]);

        randomNumber = keccak256(abi.encodePacked(randomNumber, binaryNonce, _initialSecret));

    }



    function calculateWinners() winnerCalculationPhaseLive internal {

        firstPrizeAddressFinal = tickets[uint256(randomNumber) % ticketCounter];

        secondPrizeAddressFinal = tickets[uint256(keccak256(abi.encodePacked(randomNumber))) % ticketCounter];

        thirdPrizeAddressFinal = tickets[uint256(keccak256(abi.encodePacked(keccak256(abi.encodePacked(randomNumber))))) % ticketCounter];

    }



    function calculatePrizes() winnerCalculationPhaseLive internal {

        fee = ((address(this).balance - depositAmount) / 100) * moonRaffleParameters.contractFeePercentage;

        rollover = ((address(this).balance - depositAmount) / 100) * moonRaffleParameters.rolloverPercentage;

        feeAmountFinal = fee;

        rolloverAmountFinal = rollover;

        referralBonusAmountFinal = ((address(this).balance - depositAmount) / 100) * moonRaffleParameters.referralPercentage;

        totalTicketsFinal = ticketCounter;

        totalPlayersFinal = playerCounter;

        seedAmountFinal = seedAmount;

        depositAmountFinal = depositAmount;

        referralPointsFinal = referralPointsCounter;





        firstPrizeAmountFinal = ((address(this).balance - depositAmount) / 100) * moonRaffleParameters.firstPrizePercentage;

        winnerClaims[firstPrizeAddressFinal] += firstPrizeAmountFinal;



        secondPrizeAmountFinal = ((address(this).balance - depositAmount) / 100) * moonRaffleParameters.secondPrizePercentage;

        winnerClaims[secondPrizeAddressFinal] += secondPrizeAmountFinal;



        thirdPrizeAmountFinal = ((address(this).balance - depositAmount) / 100) * moonRaffleParameters.thirdPrizePercentage;

        winnerClaims[thirdPrizeAddressFinal] += thirdPrizeAmountFinal;

    }



    function finishMoonRaffle(

        string _initialSecret1,

        string _initialSecret2,

        string _initialSecret3,

        string _initialSecret4

    ) winnerCalculationPhaseLive external {

        require(keccak256(abi.encodePacked(_initialSecret1)) == initialSecretHashArray[0]);

        require(keccak256(abi.encodePacked(_initialSecret2)) == initialSecretHashArray[1]);

        require(keccak256(abi.encodePacked(_initialSecret3)) == initialSecretHashArray[2]);

        require(keccak256(abi.encodePacked(_initialSecret4)) == initialSecretHashArray[3]);



        emit logSecretsRevealed(_initialSecret1, _initialSecret2, _initialSecret3, _initialSecret4);



        uint256 secretIndex = uint256(randomNumber) % 4;



        if (secretIndex == 0) {

            calculateFinalRandomNumber(_initialSecret1, secretIndex);

        } else if (secretIndex == 1) {

            calculateFinalRandomNumber(_initialSecret2, secretIndex);

        } else if (secretIndex == 2) {

            calculateFinalRandomNumber(_initialSecret3, secretIndex);

        } else {

            calculateFinalRandomNumber(_initialSecret4, secretIndex);

        }



        calculateWinners();

        calculatePrizes();



        isWinnerCalced = true;



        emit logWinnersCalculated(

            firstPrizeAddressFinal,

            firstPrizeAmountFinal,

            secondPrizeAddressFinal,

            secondPrizeAmountFinal,

            thirdPrizeAddressFinal,

            thirdPrizeAmountFinal

        );

    }





    function claimFeeAndDeposit() prizeClaimPhaseLive external {

        require(fee > 0);

        require(depositAmount > 0);

        uint256 feeAndDeposit = fee + depositAmount;

        fee = 0;

        depositAmount = 0;

        addressOne.transfer(feeAndDeposit);

    }



    function claimRollover() prizeClaimPhaseLive external {

        require(rollover > 0);

        uint256 tempRollover = rollover;

        rollover = 0;

        mainContractAddress.transfer(tempRollover);

    }



    function recoverUnclaimedBalance() moonRaffleContractDead external {

        require(address(this).balance > 0);

        mainContractAddress.transfer(address(this).balance);

    }



    function retractContract() onlyMainContract retractContractPhase external {

        require(address(this).balance > 0);

        mainContractAddress.transfer(address(this).balance);

    }



    function burnDeposit() refundPhaseLive internal {

        require(depositAmount > 0);

        uint256 burnAmount = depositAmount;

        depositAmount = 0;

        emit logDepositBurn(burnAmount);

        burnAddress.transfer(burnAmount);

    }



    function getRandomNumber() external view returns (bytes32) {

        return randomNumber;

    }



    function getTime() external view returns (uint256) {

        return now;

    }



    function getSeedAmount() external view returns (uint256) {

        require(isSeeded == true);

        return seedAmount;

    }



    function getRequiredDepositAmount() external view returns (uint256) {

        return seedAmount * moonRaffleParameters.contractFeePercentage / 200;

    }



    function getDepositAmount() contractLive external view returns (uint256) {

        require(isDepositReceived == true);

         if (isWinnerCalced == true) {

            return depositAmountFinal;

        }

        else {

            return depositAmount;

        }

    }



    function getCurrentPrizeAmounts() contractLive external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {

        if (isWinnerCalced == true) {

            uint256 tempPrizePool = firstPrizeAmountFinal + secondPrizeAmountFinal + thirdPrizeAmountFinal;

            return (tempPrizePool, firstPrizeAmountFinal, secondPrizeAmountFinal, thirdPrizeAmountFinal, feeAmountFinal, rolloverAmountFinal, referralBonusAmountFinal);

        }

        else {

            uint256 prizePool = (address(this).balance - depositAmount) / 100 * moonRaffleParameters.prizePoolPercentage;

            uint256 tempFirstPrize = (address(this).balance - depositAmount) / 100 * moonRaffleParameters.firstPrizePercentage;

            uint256 tempSecondPrize = (address(this).balance - depositAmount) / 100 * moonRaffleParameters.secondPrizePercentage;

            uint256 tempThirdPrize = (address(this).balance - depositAmount) / 100 * moonRaffleParameters.thirdPrizePercentage;

            uint256 currentFeeAmount = (address(this).balance - depositAmount) * moonRaffleParameters.contractFeePercentage / 100;

            uint256 currentRolloverAmount = (address(this).balance - depositAmount) * moonRaffleParameters.rolloverPercentage / 100;

            uint256 currentReferralAmount = (address(this).balance - depositAmount) * moonRaffleParameters.referralPercentage / 100;

            return (prizePool, tempFirstPrize, tempSecondPrize, tempThirdPrize, currentFeeAmount, currentRolloverAmount, currentReferralAmount);

        }

    }



    function getWinners() external view returns (address, address, address) {

        require(isWinnerCalced == true);

        return (firstPrizeAddressFinal, secondPrizeAddressFinal, thirdPrizeAddressFinal);

    }



    function getFirstPrizeAddress() external view returns (address) {

        require(isWinnerCalced == true);

        return firstPrizeAddressFinal;

    }



    function getSecondPrizeAddress() external view returns (address) {

        require(isWinnerCalced == true);

        return secondPrizeAddressFinal;

    }



    function getThirdPrizeAddress() external view returns (address) {

        require(isWinnerCalced == true);

        return thirdPrizeAddressFinal;

    }



    function getMyStatus() external view returns (uint256, bool, uint256, uint256) {

        bool referralStatus = isValidReferrer(msg.sender);

        uint256 tempReferralBonus;

        if (isWinnerCalced == true) {

            tempReferralBonus = (referralBonusAmountFinal / referralPointsFinal) * referralPoints[msg.sender];

        } else {

            if (referralPointsCounter == 0) {

                tempReferralBonus = 0;

            } else {

                tempReferralBonus = ((address(this).balance - depositAmount) / 100 * moonRaffleParameters.referralPercentage) / referralPointsCounter * referralPoints[msg.sender];

            }

        }



        return (entries[msg.sender], referralStatus, tempReferralBonus, referralPoints[msg.sender]);

    }





    function getCurrentPhase() external view returns (uint256, string) {

        if (isSeeded == false) {return (0, "unseeded");}

        if (isDepositReceived == false) {return (1, "waiting for deposit");}

        if (now <= moonRaffleEndTime) {return (2, "moonraffle is live");}

        if (

            isNonceCalced == false &&

            isWinnerCalced == false &&

            now < moonRaffleEndTime + waitTime

        ) {return (3, "waiting for enough blocks to be mined before calculating 256 bit nonce");}

        if (

            isNonceCalced == false &&

            isWinnerCalced == false &&

            now >= moonRaffleEndTime + waitTime &&

            now <= winnerCalcDeadlineTime

        ) {return (4, "please go ahead and calculate the 256 bit nonce. anyone can do it!");}

        if (

            isNonceCalced == true &&

            isWinnerCalced == false &&

            now < nonceCalcTime + waitTime

        ) {return (5, "waiting for enough blocks to be mined before calculating final winners");}

        if (

            isNonceCalced == true &&

            isWinnerCalced == false &&

            now >= nonceCalcTime + waitTime &&

            now <= winnerCalcDeadlineTime

        ) {return (6, "waiting for winners to be calculated");}

        if (

            isWinnerCalced == false &&

            now > winnerCalcDeadlineTime

        ) {return (7, "winners not calculated in time, please claim your refund plus a bonus");}

        if (

            isWinnerCalced == true &&

            now <= finishClaimTime

        ) {return (8, "winners have been calculated please claim your prizes & referral bonuses");}

        if (now > finishClaimTime) {return (9, "contract complete, no more claims allowed");}

    }



    function getAddresses() external view returns (address, address) {

        return (mainContractAddress, addressOne);

    }



    function getMoonRaffleEntryParameters() external view returns (uint256, uint256) {

        return (moonRaffleParameters.pricePerTicket, moonRaffleParameters.maxTicketsPerTransaction);

    }



    function getMoonRaffleTimes() external view returns (uint256, uint256, uint256, uint256, uint256, uint256) {

        return (startTime, moonRaffleEndTime, winnerCalcDeadlineTime, finishClaimTime, referralFloorTime, nonceCalcTime);

    }



    function getMoonRaffleStatus() external view returns (uint256, uint256, uint256) {

        return (ticketCounter, playerCounter, referralPointsCounter);

    }



    function getCurrentDefaultReferrer() external view returns (address) {

        return (currentDefaultReferrerAddress);

    }



    function getStarReferrerDetails() external view returns (address, uint256) {

        return (currentStarReferrer, currentStarReferrerPoints);

    }



    function getCurrentReferralMultiplier() external view returns (uint256) {

        uint256 tempReferralMultiplier = moonRaffleParameters.moonRaffleLiveSecs * (100 - moonRaffleParameters.referralFloorTimePercentage) / (referralMultiplierInterval * 100);

        if (now < referralFloorTime) {

            tempReferralMultiplier = (moonRaffleEndTime - now) / referralMultiplierInterval;

        }

        return tempReferralMultiplier;

    }



    function getBinaryNonce() external view returns (bool[256]) {

        return binaryNonce;

    }



    function getMoonRaffleParamenters() external view returns (

        uint256,

        uint256,

        uint256,

        uint256,

        uint256,

        uint256,

        uint256,

        uint256,

        uint256

    ) {

        return (

        moonRaffleParameters.firstPrizePercentage,

        moonRaffleParameters.secondPrizePercentage,

        moonRaffleParameters.thirdPrizePercentage,

        moonRaffleParameters.contractFeePercentage,

        moonRaffleParameters.rolloverPercentage,

        moonRaffleParameters.referralPercentage,

        moonRaffleParameters.referralHurdle,

        moonRaffleParameters.referralFloorTimePercentage,

        seedAmount

        );

    }



    function hasPlayerClaimedPrize() external view returns (bool) {

        require(msg.sender == firstPrizeAddressFinal || msg.sender == secondPrizeAddressFinal || msg.sender == thirdPrizeAddressFinal);

        return winnerClaims[msg.sender] == 0;

    }



    function hasPlayerClaimedReferralBonus() external view returns (bool){

        return referralPoints[msg.sender] == 0 && entries[msg.sender] > 0 ;

    }



    function getContractBalance() external view returns (uint256) {

        return address(this).balance;

    }



    function isRetractable() external view returns (bool) {

        return isDepositReceived == false;

    }



}



// File: contracts/MoonRaffleContractFactoryInterface.sol



contract MoonRaffleContractFactoryInterface {



    function createMoonRaffleContract(

        address _addressOne,

        bytes32 _initialSecretHash1,

        bytes32 _initialSecretHash2,

        bytes32 _initialSecretHash3,

        bytes32 _initialSecretHash4,

        uint256[14] _moonRaffleParameters

        )

        public

        payable

        returns (address);



}



// File: contracts/MoonRaffleContractFactory.sol



contract MoonRaffleContractFactory is MoonRaffleContractFactoryInterface {



    address mainContractAddress;



    modifier onlyMainContract() {

        require(msg.sender == mainContractAddress);

        _;

    }



    constructor (address _mainContractAddress) public payable {

        mainContractAddress = _mainContractAddress;

    }



    function createMoonRaffleContract(

        address _addressOne,

        bytes32 _initialSecretHash1,

        bytes32 _initialSecretHash2,

        bytes32 _initialSecretHash3,

        bytes32 _initialSecretHash4,

        uint256[14] _moonRaffleParameters

        )

        onlyMainContract

        public

        payable

        returns (address)

        {

        address newContract = new MoonRaffleContract(

            mainContractAddress,

            _addressOne,

            _initialSecretHash1,

            _initialSecretHash2,

            _initialSecretHash3,

            _initialSecretHash4,

            _moonRaffleParameters

        );

        return newContract;

        }

}