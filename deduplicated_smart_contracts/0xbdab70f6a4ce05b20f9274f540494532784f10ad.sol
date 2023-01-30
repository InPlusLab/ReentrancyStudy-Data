/**
 *Submitted for verification at Etherscan.io on 2019-08-07
*/

pragma solidity >=0.4.21 <0.6.0;


contract Token {
    function balanceOf(address a) external returns (uint) {return 0;}
    function transfer(address a, uint val) external returns (bool) {return false;}
}


contract AbstractSweeperList {
    function sweeperOf(address _token) external returns (address);
}


contract UserWallet {
    AbstractSweeperList c;
    constructor (address _sweeperlist) public {
        c = AbstractSweeperList(_sweeperlist);
    }

    function sweep(address _token, uint _amount) public {
        c.sweeperOf(_token).delegatecall(msg.data);
    }
}


contract Controller is AbstractSweeperList {
    address public owner;
    address public authorizedCaller;

    //destination defaults to same as owner
    //but is separate to allow never exposing cold storage
    address public destination;

    bool public halted;

    event LogNewWallet(address receiver);
    event LogSweep(address from, address token, uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Sender is not the owner");
        _;
    }

    modifier onlyAuthorizedCaller() {
        require(msg.sender == authorizedCaller, "unauthorized call");
        _;
    }

    modifier onlyAdmins() {
        require(msg.sender == authorizedCaller || msg.sender == owner, "unauthorized call");
        _;
    }

    constructor () public
    {
        owner = msg.sender;
        destination = msg.sender;
        authorizedCaller = msg.sender;
    }

    function changeAuthorizedCaller(address _newCaller) public onlyOwner {
        authorizedCaller = _newCaller;
    }

    function changeDestination(address _dest) public onlyOwner {
        destination = _dest;
    }

    function changeOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    function makeWallet() public onlyAdmins returns (address wallet)  {
        wallet = address(new UserWallet(address(this)));
        emit LogNewWallet(wallet);
    }

    //assuming halt because caller is compromised
    //so let caller stop for speed, only owner can restart

    function halt() public onlyAdmins {
        halted = true;
    }

    function start() public onlyOwner {
        halted = false;
    }

    //***********
    //SweeperList
    //***********
    address public defaultSweeper = address(new DefaultSweeper(address(this)));
    mapping (address => address) sweepers;

    function addSweeper(address _token, address _sweeper) public onlyOwner {
        sweepers[_token] = _sweeper;
    }

    function sweeperOf(address _token) public returns (address) {
        address sweeper = sweepers[_token];
        if (sweeper == address(0)) sweeper = defaultSweeper;
        return sweeper;
    }

    function logSweep(address from, address token, uint amount) public {
        emit LogSweep(from, token, amount);
    }
}


contract AbstractSweeper {
    //abstract:
    function sweep(address token, uint amount) external returns (bool);

    Controller controller;

    constructor (address _controller) public {
        controller = Controller(_controller);
    }

    modifier canSweep() {
        require(msg.sender == controller.authorizedCaller() || msg.sender == controller.owner(), "Unauthorized call");
        require(controller.halted() == false, "Controller is in halted state");
        _;
    }
}


contract DefaultSweeper is AbstractSweeper {
    constructor (address controller) public AbstractSweeper(controller) {}

    function sweep(address _token, uint _amount) public canSweep
    returns (bool) {
        Token token = Token(_token);
        uint amount = _amount;
        if (amount > token.balanceOf(address(this))) {
            return false;
        }

        address destination = controller.destination();

	// Because sweep is called with delegatecall, this typically
	// comes from the UserWallet.
        bool success = token.transfer(destination, amount);
        if (success) {
            controller.logSweep(address(this), _token, _amount);
        }
        return success;
    }
}