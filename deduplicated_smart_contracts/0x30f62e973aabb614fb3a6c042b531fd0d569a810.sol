/**

 *Submitted for verification at Etherscan.io on 2018-10-07

*/



pragma solidity ^0.4.25;



interface HourglassInterface {

    function buy(address _playerAddress) payable external returns(uint256);

    function sell(uint256 _amountOfTokens) external;

    function reinvest() external;

    function withdraw() external;

    function transfer(address _toAddress, uint256 _amountOfTokens) external returns(bool);

    function balanceOf(address _customerAddress) view external returns(uint256);

    function myDividends(bool _includeReferralBonus) external view returns(uint256);

}



contract StrongHandsManager {

    

    event CreateStrongHand(address indexed owner, address indexed strongHand);

    

    mapping (address => address) public strongHands;



    function create(uint256 _unlockAfterNDays)

        public

    {

        address owner = msg.sender;

        

        require(strongHands[owner] == address(0), "you already became a Stronghand");

        

        strongHands[owner] = new StrongHand(msg.sender, _unlockAfterNDays);

        

        emit CreateStrongHand(owner, strongHands[owner]);

    }

}



contract StrongHand {



    HourglassInterface constant p3dContract = HourglassInterface(0xB3775fB83F7D12A36E0475aBdD1FCA35c091efBe);

    

    address public owner;

    

    uint256 public creationDate;

    

    uint256 public unlockAfterNDays;

    

    modifier timeLocked()

    {

        require(now >= creationDate + unlockAfterNDays * 1 days);

        _;

    }

    

    modifier onlyOwner()

    {

        require(msg.sender == owner);

        _;

    }

    

    constructor(address _owner, uint256 _unlockAfterNDays)

        public

    {

        owner = _owner;

        unlockAfterNDays =_unlockAfterNDays;

        

        creationDate = now;

    }

    

    function() public payable {}

    

    function balanceOf()

        external

        view

        returns(uint256)

    {

        return p3dContract.balanceOf(address(this));

    }

    

    function dividendsOf()

        external

        view

        returns(uint256)

    {

        return p3dContract.myDividends(true);

    }

    

    function buy()

        external

        payable

        onlyOwner

    {

        p3dContract.buy.value(msg.value)(0x1EB2acB92624DA2e601EEb77e2508b32E49012ef);

    }

    

    function reinvest()

        external

        onlyOwner

    {

        p3dContract.reinvest();

    }



    function withdraw()

        external

        onlyOwner

    {

        p3dContract.withdraw();

        

        owner.transfer(address(this).balance);

    }

    

    function sell(uint256 _amount)

        external

        timeLocked

        onlyOwner

    {

        p3dContract.sell(_amount);

        

        owner.transfer(address(this).balance);

    }

    

    function transfer(address _toAddress, uint256 _amountOfTokens)

        external

        timeLocked

        onlyOwner

        returns(bool)

    {

        return p3dContract.transfer(_toAddress, _amountOfTokens);

    }

}