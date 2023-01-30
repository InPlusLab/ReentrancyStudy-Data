/**
 *Submitted for verification at Etherscan.io on 2020-12-09
*/

pragma solidity ^0.6.12;

interface Router {
	function WETH() external pure returns (address);
	function swapExactETHForTokens(uint256 _amountOutMin, address[] calldata _path, address _to, uint256 _deadline) external payable returns (uint256[] memory);
}

interface SURF {
	function whirlpoolAddress() external view returns (address);
	function balanceOf(address) external view returns (uint256);
	function approve(address, uint256) external returns (bool);
	function transfer(address, uint256) external returns (bool);
	function transferFrom(address, address, uint256) external returns (bool);
}

interface SURF3d {
	function whirlpoolManager() external view returns (address);
	function dividendsOf(address) external view returns (uint256);
	function buyFor(uint256, address) external returns (uint256);
	function withdraw() external returns (uint256);
}

interface Whirlpool {
	function userInfo(address) external view returns (uint256, uint256, uint256);
	function claim() external;
}

contract SURFstacker {

	uint256 constant private FLOAT_SCALAR = 2**64;
	uint256 constant private MIN_DEPOSIT = 1e20; // 100 SURF min
	uint256 constant private MAX_DEPOSIT = 1e22; // 10,000 SURF max
	uint256 constant private RETURN = 115; // deposit + 15% extra repaid
	uint256 constant private S3D_BUY = 382; // 38.2% of deposits buy S3D for the WhirlpoolManager contract

	struct Deposit {
		address user;
		uint96 timestamp;
		uint128 deposit;
		uint128 paid;
	}

	struct Info {
		Deposit[] queue;
		uint256 paidToIndex;
		uint256 totalDeposited;
		mapping(address => uint256) deposits;
		uint256 openingBlock;
		Router router;
		SURF surf;
		SURF3d s3d;
		Whirlpool whirlpool;
	}
	Info private info;
	

	event Deposited(uint256 indexed index, address indexed user, uint256 amount);
	event Paid(uint256 indexed index, address indexed user, uint256 amount);
	event PaidOff(uint256 indexed index, address indexed user, uint256 totalPaid);


	constructor(address _surf, address _s3d, uint256 _openingBlock) public {
		info.router = Router(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
		info.surf = SURF(_surf);
		info.s3d = SURF3d(_s3d);
		info.whirlpool = Whirlpool(info.surf.whirlpoolAddress());
		info.openingBlock = _openingBlock;
	}

	receive() external payable {
		if (msg.sender == tx.origin) {
			deposit();
		}
	}

	function deposit() public payable {
		depositFor(msg.sender);
	}

	function depositFor(address _user) public payable {
		require(msg.value > 0);
		_depositETH(msg.value, _user);
	}

	function buy(uint256 _amount) external {
		buyFor(_amount, msg.sender);
	}

	function buyFor(uint256 _amount, address _user) public {
		uint256 _balanceBefore = info.surf.balanceOf(address(this));
		info.surf.transferFrom(msg.sender, address(this), _amount);
		uint256 _amountReceived = info.surf.balanceOf(address(this)) - _balanceBefore;
		_deposit(_amountReceived, _user);
	}

	function tokenCallback(address _from, uint256 _tokens, bytes calldata) external returns (bool) {
		require(msg.sender == address(info.surf));
		_deposit(_tokens, _from);
		return true;
	}

	function processDividends() external {
		uint256 _balanceBefore = info.surf.balanceOf(address(this));
		if (info.s3d.dividendsOf(address(this)) > 0) {
			info.s3d.withdraw();
		}
		(uint256 _staked, , ) = info.whirlpool.userInfo(address(this));
		if (_staked > 0) {
			info.whirlpool.claim();
		}
		uint256 _amountReceived = info.surf.balanceOf(address(this)) - _balanceBefore;
		if (_amountReceived > 0) {
			_process(_amountReceived);
		}
	}


	function allInfoFor(address _user) external view returns (uint256 totalDeposits, uint256 paidToIndex, uint256 totalDeposited, uint256 openingBlock, uint256 currentBlock, uint256 userETH, uint256 userSURF, uint256 userDeposit) {
		totalDeposits = info.queue.length;
		paidToIndex = info.paidToIndex;
		totalDeposited = info.totalDeposited;
		openingBlock = info.openingBlock;
		currentBlock = block.number;
		userETH = _user.balance;
		userSURF = info.surf.balanceOf(_user);
		userDeposit = info.deposits[_user];
	}

	function getDeposit(uint256 _index) public view returns (address user, uint256 timestamp, uint256 depositAmount, uint256 paid, uint256 remaining) {
		require(_index < info.queue.length);
		Deposit memory _dep = info.queue[_index];
		user = _dep.user;
		timestamp = _dep.timestamp;
		depositAmount = _dep.deposit;
		paid = _dep.paid;
		remaining = RETURN * depositAmount / 100 - paid;
	}

	function getDeposits(uint256[] memory _indexes) public view returns (address[] memory users, uint256[] memory timestamps, uint256[] memory deposits, uint256[] memory paids, uint256[] memory remainings) {
		uint256 _length = _indexes.length;
		users = new address[](_length);
		timestamps = new uint256[](_length);
		deposits = new uint256[](_length);
		paids = new uint256[](_length);
		remainings = new uint256[](_length);
		for (uint256 i = 0; i < _length; i++) {
			(users[i], timestamps[i], deposits[i], paids[i], remainings[i]) = getDeposit(_indexes[i]);
		}
	}

	function getDepositsTable(uint256 _limit, uint256 _page, bool _isAsc, bool _onlyUnpaid) external view returns (uint256[] memory indexes, address[] memory users, uint256[] memory timestamps, uint256[] memory deposits, uint256[] memory paids, uint256[] memory remainings, uint256 totalDeposits, uint256 totalPages) {
		require(_limit > 0);
		totalDeposits = info.queue.length - (_onlyUnpaid ? info.paidToIndex : 0);

		if (totalDeposits > 0) {
			totalPages = (totalDeposits / _limit) + (totalDeposits % _limit == 0 ? 0 : 1);
			require(_page < totalPages);

			uint256 _offset = _limit * _page;
			if (_page == totalPages - 1 && totalDeposits % _limit != 0) {
				_limit = totalDeposits % _limit;
			}

			indexes = new uint256[](_limit);
			for (uint256 i = 0; i < _limit; i++) {
				indexes[i] = (_isAsc ? _offset + i : totalDeposits - _offset - i - 1) + (_onlyUnpaid ? info.paidToIndex : 0);
			}
		} else {
			totalPages = 0;
			indexes = new uint256[](0);
		}
		(users, timestamps, deposits, paids, remainings) = getDeposits(indexes);
	}


	function _depositETH(uint256 _value, address _user) internal {
		uint256 _balanceBefore = info.surf.balanceOf(address(this));
		address[] memory _poolPath = new address[](2);
		_poolPath[0] = info.router.WETH();
		_poolPath[1] = address(info.surf);
		info.router.swapExactETHForTokens{value: _value}(0, _poolPath, address(this), block.timestamp + 5 minutes);
		uint256 _amount = info.surf.balanceOf(address(this)) - _balanceBefore;
		_deposit(_amount, _user);
	}

	function _deposit(uint256 _amount, address _user) internal {
		require(block.number >= info.openingBlock && _amount >= MIN_DEPOSIT && _amount <= MAX_DEPOSIT);

		Deposit memory _newDeposit = Deposit({
			user: _user,
			timestamp: uint96(block.timestamp),
			deposit: uint128(_amount),
			paid: 0
		});
		info.queue.push(_newDeposit);
		info.totalDeposited += _amount;
		info.deposits[_user] += _amount;
		emit Deposited(info.queue.length - 1, _user, _amount);

		uint256 _s3dBuyAmount = S3D_BUY * _amount / 1000;
		_purchaseS3D(_s3dBuyAmount);

		uint256 _amountPayable = _amount - _s3dBuyAmount;
		_process(_amountPayable);
	}

	function _purchaseS3D(uint256 _amount) internal {
		info.surf.approve(address(info.s3d), _amount);
		info.s3d.buyFor(_amount, info.s3d.whirlpoolManager());
	}

	function _process(uint256 _amount) internal {
		while (_amount > 0) {
			uint256 _currentIndex = info.paidToIndex;
			if (_currentIndex >= info.queue.length) {
				_purchaseS3D(_amount);
				_amount = 0;
			} else {
				Deposit storage _currentDeposit = info.queue[_currentIndex];
				uint256 _amountPayable = _amount;
				uint256 _totalPayable = RETURN * _currentDeposit.deposit / 100;
				uint256 _amountRemaining = _totalPayable - _currentDeposit.paid;
				if (_amountRemaining <= _amountPayable) {
					_amountPayable = _amountRemaining;
					emit PaidOff(_currentIndex, _currentDeposit.user, _totalPayable);
					info.paidToIndex++;
				}
				_currentDeposit.paid += uint128(_amountPayable);
				info.surf.transfer(_currentDeposit.user, _amountPayable);
				emit Paid(_currentIndex, _currentDeposit.user, _amountPayable);
				_amount -= _amountPayable;
			}
		}
	}
}