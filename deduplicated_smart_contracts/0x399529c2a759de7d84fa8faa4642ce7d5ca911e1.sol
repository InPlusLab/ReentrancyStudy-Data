pragma solidity 0.5.8;



import "./SafeMath.sol";



contract PLincGamesHub {

    

    using SafeMath for uint256;

    

    constructor(address plicHubAddress)

        public

    {

       plincHub = IPLincHub(plicHubAddress);

       

       plincHub.setAuto(9);

    }

    

    function()

        external

        payable

    {}

    

    address manager = address(0x1EB2acB92624DA2e601EEb77e2508b32E49012ef);

    

    event AddGame(address game);

    event RemoveGame(address game);



    modifier onlyManager()

    {

        require(msg.sender == manager);

        _;

    }



    function addGame(address gameAddress)

        external

        onlyManager

        isUnregisteredGame(gameAddress)

    {

        games[gameAddress] = Game(true, 0, 0);

        numberOfGames++;

        

        emit AddGame(gameAddress);

    }

    

    function removeGame(address gameAddress)

        external

        onlyManager

        isRegisteredGame(gameAddress)

    {

        games[gameAddress].registered = false;

        numberOfGames--;

        

        emit RemoveGame(gameAddress);

    }

    

    //

    //Players

    //

    

    struct Player {

        uint256 balance;

        string name;

        uint256 fundingBalance;

    }

    

    mapping(address => Player) public players;

    mapping(string => bool) public names;

    uint256 public totalPlayerBalances;

    uint256 public totalFundingBalances;

    

    event RegisterName(address indexed player, string indexed name);

    event Withdraw(address indexed player, uint256 amount);

    event Fund(address indexed funder, uint256 amount);

    event WithdrawFunding(address indexed player, uint256 amount);

	

	function fund()

	    external

	    payable

	    withdrawPiggyBank

	{

	    players[msg.sender].fundingBalance = players[msg.sender].fundingBalance.add(msg.value);

	    

	    totalFundingBalances += msg.value;

	    

	    emit Fund(msg.sender, msg.value);

	}

	

	function playGame(bytes calldata data)

	    external

	    payable

	    withdrawPiggyBank

	{

	    (address gameAddress, bytes memory gameData) = abi.decode(data, (address, bytes));

	    

	    require(games[gameAddress].registered);

	    

	    games[gameAddress].amountGiven += msg.value;

	    

	    IHubGame(gameAddress).play(msg.sender, msg.value, gameData);

	    

	    buyBondsInternally(msg.value / plincDivisor);

	}

	

	function withdrawBalance()

	    external

	    withdrawPiggyBank

	{

	    uint256 amount = players[msg.sender].balance;

	    

	    players[msg.sender].balance = 0;

	    

	    totalPlayerBalances -= amount;

	   

	    msg.sender.transfer(amount);

	    

	    emit Withdraw(msg.sender, amount);

	}

	

	function withdrawBalancePartial(uint256 howMuch)

	    external

	    withdrawPiggyBank

	{

	    players[msg.sender].balance = players[msg.sender].balance.sub(howMuch);

	    

	    totalPlayerBalances -= howMuch;

	   

	    msg.sender.transfer(howMuch);

	    

	    emit Withdraw(msg.sender, howMuch);

	}

	

	function withdrawFundingBalance()

	    external

	    withdrawPiggyBank

	{

	    uint256 amount = players[msg.sender].fundingBalance;

	    

	    players[msg.sender].fundingBalance = 0;

	    

	    totalFundingBalances -= amount;

	   

	    msg.sender.transfer(amount);

	    

	    emit WithdrawFunding(msg.sender, amount);

	}

	

	function withdrawFundingBalancePartial(uint256 howMuch)

	    external

	    withdrawPiggyBank

	{

	    players[msg.sender].fundingBalance = players[msg.sender].fundingBalance.sub(howMuch);

	    

	    totalFundingBalances -= howMuch;

	   

	    msg.sender.transfer(howMuch);

	    

	    emit WithdrawFunding(msg.sender, howMuch);

	}

	

	function registerName(string calldata newName)

	    external

	    payable

	    withdrawPiggyBank

	{

	    require(msg.value >= 0.01 ether);

	    require(bytes(newName).length > 0 && bytes(newName).length <= 32);

	    require(!names[newName]);

	    

	    players[msg.sender].name = newName;

	    names[newName] = true;

	    

	    emit RegisterName(msg.sender, newName);

	}

	

	//

	//Games

	//

	

	struct Game {

        bool registered;

        uint256 amountGiven;

        uint256 amountTaken;

    }

    

    mapping(address => Game) public games;

    uint256 public numberOfGames;

	

	modifier isRegisteredGame(address gameAddress)

    {

        require(games[gameAddress].registered);

        _;

    }

    

    modifier isUnregisteredGame(address gameAddress)

    {

        require(!games[gameAddress].registered);

        _;

    }

	

	function addPlayerBalance(address playerAddress, uint256 value)

	    external

	    isRegisteredGame(msg.sender)

	{

	    players[playerAddress].balance = players[playerAddress].balance.add(value);

	    games[msg.sender].amountTaken += value;

	    

	    totalPlayerBalances += value;

	}

	

	function subPlayerBalance(address playerAddress, uint256 value)

	    external

	    isRegisteredGame(msg.sender)

	{

	    players[playerAddress].balance = players[playerAddress].balance.sub(value);

	    games[msg.sender].amountGiven += value;

	    

	    totalPlayerBalances -= value;

	}

	

	//

	//PLincHub integration

	//

	

	IPLincHub public plincHub;

	uint256 plincDivisor = 1;

	

	modifier withdrawPiggyBank

    {

	    if(plincHub.piggyBank(address(this)) > 0) {

	        plincHub.piggyToWallet();

	    }

	    _;

    }

	

	function setAuto(uint256 percentage)

        external

        onlyManager

    {

        plincHub.setAuto(percentage);

    }

    

    function setPLincDivisor(uint256 value)

        external

        onlyManager

    {

        plincDivisor = value;

    }

    

    function buyBonds(uint256 value)

        external

        onlyManager

    {

        buyBondsInternally(value);

    }

    

    function fillBonds()

        external

        onlyManager

    {

        plincHub.fillBonds(address(this));

    }

    

    function fetchBonds()

        external

        onlyManager

    {

        plincHub.fetchDivs(address(this));

    }

    

    function piggyToWallet()

        external

    {

        plincHub.piggyToWallet();

    }

    

    function vaultToWallet()

        external

    {

        plincHub.vaultToWallet();

    }

    

    function bondsOutstanding()

        external

        view

        returns (uint256)

    {

       return plincHub.bondsOutstanding(address(this));

    }

    

    function buyBondsInternally(uint256 value)

        private

    {

        plincHub.buyBonds.value(value)(manager);

    }

}



interface IHubGame {

    function play(address playerAddress, uint256 value, bytes calldata gameData) external;

}



interface IPLincHub {

    function setAuto(uint256 percentage) external;

    function buyBonds(address referral) external payable;

    function piggyToWallet() external;

    function vaultToWallet() external;

    function fillBonds(address player) external;

    function fetchDivs(address player) external;

    function piggyBank(address player) external view returns (uint256);

    function bondsOutstanding(address player) external view returns (uint256);

}