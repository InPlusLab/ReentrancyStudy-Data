/**
 *Submitted for verification at Etherscan.io on 2020-03-29
*/

pragma solidity ^0.5.14;

interface HEX {
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

contract ReferralSplitter {

    event DistributedShares(
        uint256 timestamp,
        address indexed senderAddress,
        uint256 totalDistributed
    );
    
    event DistributedEthDonation(
        uint256 timestamp,
        address indexed donatorAddress,
        uint256 totalDonated
    );

    HEX internal hx = HEX(0x2b591e99afE9f32eAA6214f7B7629768c40Eeb39);

    uint256 public minGasHearts = 10000000000;
    uint256 private allocatedGasHearts;
    address payable public gasWallet;
    
    address payable internal KYLE = 0xD30BC4859A79852157211E6db19dE159673a67E2; // 20
    address payable internal KEVIN = 0x3487b398546C9b757921df6dE78EC308203f5830; // 15
    address payable internal AMIRIS = 0x406D1fC98D231aD69807Cd41d4D6F8273401354f; // 6
    address payable internal MICHAEL = 0xe551072153c02fa33d4903CAb0435Fb86F1a80cb; // 13
    address payable internal JARED = 0x5eCb4D3B4b451b838242c3CF8404ef18f5C486aB; // 5
    address payable internal LOUIS = 0x454f203260a74C0A8B5c0a78fbA5B4e8B31dCC63; // 1
    address payable internal LOTTO = 0x1EF0Bab01329a6CE39e92eA6B88828430B1Cd91f;// 10
    address payable internal DONATOR = 0x723e82Eb1A1b419Fb36e9bD65E50A979cd13d341; // 7.5
    address payable internal MARCO = 0xbf1984B12878c6A25f0921535c76C05a60bdEf39; // 7.5
    address payable internal SWIFT = 0x88BA4dc5571660A1693E421D83EC97015B53580D; // 7.5
    address payable internal MARK = 0x35e9034f47cc00b8A9b555fC1FDB9598b2c245fD; // 7.5
    
    mapping(address => bool) contributors;
    
    modifier onlyContributors(){
        require(contributors[msg.sender], "not a contributor");
        _;
    }
    
    constructor() public {
        gasWallet = msg.sender;
        contributors[KYLE] = true;
        contributors[KEVIN] = true;
        contributors[AMIRIS] = true;
        contributors[MICHAEL] = true;
        contributors[JARED] = true;
        contributors[LOUIS] = true;
        contributors[LOTTO] = true;
        contributors[DONATOR] = true;
        contributors[MARCO] = true;
        contributors[SWIFT] = true;
        contributors[MARK] = true;
    }
    
    function distribute () public {
        //get balance    
        uint256 balance = hx.balanceOf(address(this));
        //minGasHearts allocation must be below 1% of balance. this stops any 1 contributor setting an excessively high minGasHearts to drain the contract. reduce minGasHearts in the case of high contract balance at will)
        require(minGasHearts < (balance / 100), "minGasHearts must not be > 1% of contract HEX balance - reduce minGasHearts to enable distribution");
        //deduct for gas
        allocatedGasHearts += minGasHearts;
        require(balance > (allocatedGasHearts + 99), "balance does not cover gas allocation");
        balance -= allocatedGasHearts;
        //distribute
        uint256 onePercent = balance / 100;
        uint256 fivePercent = balance / 20;
        hx.transfer(KYLE, 4*fivePercent); // 20%
        hx.transfer(KEVIN, 3*fivePercent); // 15%
        hx.transfer(AMIRIS, fivePercent + onePercent); // 6%
        hx.transfer(MICHAEL, (2*fivePercent) + (3*onePercent)); // 13%
        hx.transfer(JARED, fivePercent); // 5%
        hx.transfer(LOUIS, onePercent); // 1%
        hx.transfer(LOTTO, 2*fivePercent); // 10%
        hx.transfer(DONATOR, fivePercent + (fivePercent/2)); // 7.5%
        hx.transfer(MARCO, fivePercent + (fivePercent/2)); // 7.5%
        hx.transfer(SWIFT, fivePercent + (fivePercent/2)); // 7.5%
        hx.transfer(MARK, fivePercent + (fivePercent/2)); // 7.5%
        emit DistributedShares(now, msg.sender, balance);
    }
    
    function setMinGasHearts(uint256 _minGasHearts) public onlyContributors{
        require(_minGasHearts> 0, "min hearts for gas cannot be zero");
        minGasHearts = _minGasHearts;
    }
    
    function withdrawGasAllocation() public onlyContributors {
        require(gasWallet != address(0), "gas wallet cannot be zero address");
        require(allocatedGasHearts > 0, "zero allocated hex for gas");
        //transfer HEX to gas wallet
        hx.transfer(gasWallet, allocatedGasHearts);
        //reset allocation
        allocatedGasHearts = 0;
    }
    
    function setGasWallet(address payable _gasWallet) public onlyContributors{
        require(_gasWallet != address(0), "cannot be zero address");
        gasWallet = _gasWallet;
    }
    
    //fallback for eth sent to contract - auto distribute as donation
    function() external payable{
        donate();    
    }
    
    function donate() public payable {
        require(msg.value > 0);
        uint256 balance = msg.value;
        uint256 onePercent = balance / 100;
        uint256 fivePercent = balance / 20;
        KYLE.transfer(4*fivePercent); // 20%
        KEVIN.transfer(3*fivePercent); // 15%
        AMIRIS.transfer(fivePercent + onePercent); // 6%
        MICHAEL.transfer((2*fivePercent) + (3*onePercent)); // 13%
        JARED.transfer(fivePercent); // 5%
        LOUIS.transfer(onePercent); // 1%
        LOTTO.transfer(2*fivePercent); // 10%
        DONATOR.transfer(fivePercent + (fivePercent/2)); // 7.5%
        MARCO.transfer(fivePercent + (fivePercent/2)); // 7.5%
        SWIFT.transfer(fivePercent + (fivePercent/2)); // 7.5%
        MARK.transfer(fivePercent + (fivePercent/2)); // 7.5%
        emit DistributedEthDonation(now, msg.sender, balance);
    }
}