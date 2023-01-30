// SPDX-License-Identifier: MIT
pragma solidity =0.7.5;

// Voken TeraByte Main Contract for vnCHAIN (vision.network)
//
// More info:
//   https://voken.io
//
// Contact us:
//   support@voken.io


import "LibSafeMath.sol";
import "LibIERC20.sol";
import "LibIVesting.sol";
import "LibAuthVoken.sol";
import "LibBurning.sol";


/**
 * @title VokenTB Main Contract for vnCHAIN
 */
contract VokenTB is IERC20, IVesting, AuthVoken, Burning {
    using SafeMath for uint256;

    struct Account {
        uint256 balance;

        uint160 voken;
        address payable referrer;

        IVesting[] vestingContracts;
        mapping (address => bool) hasVesting;

        mapping (address => uint256) allowances;
    }

    string private _name = "Voken TeraByte";
    string private _symbol = "VokenTB";
    uint8 private constant _decimals = 9;
    uint256 private constant _cap = 210_000_000e9;
    uint256 private _totalSupply;
    uint256 private _vokenCounter;
    bool private _changeVokenAddressAllowed;

    mapping (address => Account) private _accounts;
    mapping (uint160 => address payable) private _voken2address;

    event Mint(address indexed account, uint256 amount);
    event Burn(address indexed account, uint256 amount);
    event Donate(address indexed account, uint256 amount);
    event VokenAddressSet(address indexed account, uint160 voken);
    event ReferrerSet(address indexed account, address indexed referrerAccount);


    /**
     * @dev Donate
     */
    receive()
        external
        payable
    {
        if (msg.value > 0) {
            emit Donate(msg.sender, msg.value);
        }
    }

    /**
     * @dev Sets the full name of VOKEN.
     *
     * Can only be called by the current owner.
     */
    function setName(
        string calldata value
    )
        external
        onlyAgent
    {
        _name = value;
    }

    /**
     * @dev Sets the symbol of VOKEN.
     *
     * Can only be called by the current owner.
     */
    function setSymbol(
        string calldata value
    )
        external
        onlyAgent
    {
        _symbol = value;
    }

    /**
     * @dev Set change Voken address is allowed or not.
     */
    function setChangeVokenAddressAllowed(bool value)
        external
        onlyAgent
    {
        _changeVokenAddressAllowed = value;
    }

    /**
     * @dev Set Voken address by `voken`.
     */
    function setVokenAddress(uint160 voken)
        external
        returns (bool)
    {
        require(balanceOf(msg.sender) > 0, "Set Voken Address: balance is zero");
        require(voken > 0, "Set Voken Address: is zero address");

        if (_accounts[msg.sender].voken > 0) {
            require(_changeVokenAddressAllowed, "Change Voken Address: is not allowed");
            delete _voken2address[voken];
        }

        else {
            _vokenCounter = _vokenCounter.add(1);
        }

        _voken2address[voken] = msg.sender;
        _accounts[msg.sender].voken = voken;

        emit VokenAddressSet(msg.sender, voken);
        return true;
    }

    /**
     * @dev Set referrer.
     */
    function setReferrer(
        uint160 referrerVoken
    )
        external
        returns (bool)
    {
        address payable referrer_ = _voken2address[referrerVoken];

        require(referrer_ != address(0), "Set referrer: does not exist");
        require(_accounts[msg.sender].referrer == address(0), "Set referrer: was already exist");

        _accounts[msg.sender].referrer = referrer_;
        emit ReferrerSet(msg.sender, referrer_);
        return true;
    }

    /**
     * @dev Returns the full name of VOKEN.
     */
    function name()
        public
        view
        override
        returns (string memory)
    {
        return _name;
    }

    /**
     * @dev Returns the symbol of VOKEN.
     */
    function symbol()
        public
        view
        override
        returns (string memory)
    {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     */
    function decimals()
        public
        pure
        override
        returns (uint8)
    {
        return _decimals;
    }

    /**
     * @dev Returns the cap on VOKEN's total supply.
     */
    function cap()
        public
        pure
        returns (uint256)
    {
        return _cap;
    }

    /**
     * @dev Returns the amount of VOKEN in existence.
     */
    function totalSupply()
        public
        view
        override
        returns (uint256)
    {
        return _totalSupply;
    }

    /**
     * @dev Returns the amount of VOKEN owned by `account`.
     */
    function balanceOf(
        address account
    )
        public
        view
        override
        returns (uint256)
    {
        return _accounts[account].balance;
    }

    /**
     * @dev Returns the vesting contracts' addresses on `account`.
     */
    function vestingContracts(
        address account
    )
        public
        view
        returns (IVesting[] memory contracts)
    {
        contracts = _accounts[account].vestingContracts;
    }

    /**
     * @dev Returns `true` if change Voken address is allowed.
     */
    function isChangeVokenAddressAllowed()
        public
        view
        returns (bool)
    {
        return _changeVokenAddressAllowed;
    }

    /**
     * @dev Returns Voken address of `account`.
     */
    function address2voken(
        address account
    )
        public
        view
        returns (uint160)
    {
        return _accounts[account].voken;
    }

    /**
     * @dev Returns address of `voken`.
     */
    function voken2address(
        uint160 voken
    )
        public
        view
        returns (address payable)
    {
        return _voken2address[voken];
    }

    /**
     * @dev Returns amount of Voken address.
     */
    function vokenCounter()
        public
        view
        returns (uint256)
    {
        return _vokenCounter;
    }

    /**
     * @dev Returns the referrer of an `account`.
     */
    function referrer(
        address account
    )
        public
        view
        returns (address payable)
    {
        return _accounts[account].referrer;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value)
        public
        override
        onlyNotPaused
        returns (bool)
    {
        _approve(msg.sender, spender, value);
        return true;
    }

    /**
     * @dev Returns the remaining number of VOKEN that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}.
     * This is zero by default.
     */
    function allowance(
        address owner,
        address spender
    )
        public
        override
        view
        returns (uint256)
    {
        return _accounts[owner].allowances[spender];
    }

    /**
     * @dev Returns the vesting amount of VOKEN by `account`.
     */
    function vestingOf(
        address account
    )
        public
        override
        view
        returns (uint256 reserved)
    {
        for (uint256 i = 0; i < _accounts[account].vestingContracts.length; i++) {
            if (
                _accounts[account].vestingContracts[i] != IVesting(0)
                &&
                isContract(address(_accounts[account].vestingContracts[i]))
            ) {
                try _accounts[account].vestingContracts[i].vestingOf(account) returns (uint256 value) {
                    reserved = reserved.add(value);
                }
    
                catch {
                    //
                }
            }
        }
    }

    /**
     * @dev Returns the available amount of VOKEN by `account` and a certain `amount`.
     */
    function availableOf(
        address account
    )
        public
        view
        returns (uint256)
    {
        return balanceOf(account).sub(vestingOf(account));
    }

    /**
     * @dev Destroys `amount` VOKEN from the caller.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     */
    function burn(
        uint256 amount
    )
        public
        returns (bool)
    {
        require(amount > 0, "Burn: amount is zero");

        uint256 balance = balanceOf(msg.sender);
        require(balance > 0, "Burn: balance is zero");

        if (balance >= amount) {
            _burn(msg.sender, amount);
        }
        
        else {
            _burn(msg.sender, balance);
        }

        return true;
    }

    /**
     * @dev Creates `amount` VOKEN and assigns them to `account`.
     *
     * Can only be called by a minter.
     */
    function mint(
        address account,
        uint256 amount
    )
        public
        onlyNotPaused
        onlyMinter
        returns (bool)
    {
        require(amount > 0, "Mint: amount is zero");

        _mint(account, amount);
        return true;
    }

    /**
     * @dev Creates `amount` VOKEN and assigns them to `account` with an `vestingContract`
     *
     * Can only be called by a minter.
     */
    function mintWithVesting(
        address account,
        uint256 amount,
        address vestingContract
    )
        public
        onlyNotPaused
        onlyMinter
        returns (bool)
    {
        require(amount > 0, "Mint: amount is zero");
        require(vestingContract != address(this), "Mint, vesting address is the token address");

        _mintWithVesting(account, amount, vestingContract);
        return true;
    }

    /**
     * @dev Moves `amount` VOKEN from the caller's account to `recipient`.
     *
     * Auto handle {WhitelistSignUp} when `amount` is a specific value.
     * Auto handle {Burn} when `recipient` is `address(0)`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(
        address recipient,
        uint256 amount
    )
        public
        override
        onlyNotPaused
        returns (bool)
    {
        require(amount > 0, "Transfer: amount is zero");

        // Burn
        if (recipient == address(0)) {
            uint256 balance = balanceOf(msg.sender);
            require(balance > 0, "Transfer: balance is zero");

            if (amount <= balance) {
                _burn(msg.sender, amount);
            }

            else {
                _burn(msg.sender, balance);
            }
        }

        // Transfer
        else {
            uint256 available = availableOf(msg.sender);
            require(available > 0, "Transfer: available balance is zero");
            require(amount <= available, "Transfer: insufficient available balance");
            
            _transfer(msg.sender, recipient, amount);
        }

        return true;
    }

    /**
     * @dev Moves `amount` VOKEN from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Auto handle {Burn} when `recipient` is `address(0)`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     * Emits an {Approval} event indicating the updated allowance.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    )
        public
        override
        onlyNotPaused
        returns (bool)
    {
        require(amount > 0, "TransferFrom: amount is zero");

        // Burn
        if (recipient == address(0)) {
            uint256 balance = balanceOf(sender);
            require(balance > 0, "Transfer: balance is zero");

            if (amount <= balance) {
                _burn(sender, amount);
            }

            else {
                _burn(sender, balance);
            }
        }

        // Normal transfer
        else {
            uint256 available = availableOf(sender);
            require(available > 0, "TransferFrom: available balance is zero");
            require(amount <= available, "TransferFrom: insufficient available balance");
            
            _transfer(sender, recipient, amount);
            _approve(sender, msg.sender, _accounts[sender].allowances[msg.sender].sub(amount, "TransferFrom: amount exceeds allowance"));
        }

        return true;
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s VOKEN.
     *
     * Emits an {Approval} event.
     */
    function _approve(
        address owner,
        address spender,
        uint256 value
    )
        private
    {
        require(owner != address(0), "Approve: from the zero address");
        require(spender != address(0), "Approve: to the zero address");

        _accounts[owner].allowances[spender] = value;
        emit Approval(owner, spender, value);
    }

    /**
     * @dev Destroys `amount` VOKEN from `account`, reducing the total supply.
     *
     * Emits a {Burn} event.
     * Emits a {Transfer} event with `to` set to the zero address.
     */
    function _burn(
        address account,
        uint256 amount
    )
        private
    {
        _accounts[account].balance = _accounts[account].balance.sub(amount, "Burn: insufficient balance");
        _totalSupply = _totalSupply.sub(amount, "Burn: amount exceeds total supply");
        emit Burn(account, amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Creates `amount` VOKEN and assigns them to `account`, increasing the total supply.
     *
     * Emits a {Mint} event.
     * Emits a {Transfer} event with `from` set to the zero address.
     */
    function _mint(
        address account,
        uint256 amount
    )
        private
    {
        uint256 total = _totalSupply.add(amount);

        require(total <= _cap, "Mint: total supply cap exceeded");
        require(account != address(0), "Mint: to the zero address");

        _totalSupply = total;
        _accounts[account].balance = _accounts[account].balance.add(amount);
        emit Mint(account, amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Creates `amount` VOKEN and assigns them to `account` with an `vestingContract`, increasing the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     */
    function _mintWithVesting(
        address account,
        uint256 amount,
        address vestingContract
    )
        private
    {
        uint256 total = _totalSupply.add(amount);

        require(total <= _cap, "Mint: total supply cap exceeded");
        require(account != address(0), "Mint: to the zero address");

        _totalSupply = total;
        _accounts[account].balance = _accounts[account].balance.add(amount);

        if (!_accounts[account].hasVesting[vestingContract]) {
            _accounts[account].vestingContracts.push(IVesting(vestingContract));
            _accounts[account].hasVesting[vestingContract] = true;
        }

        emit Mint(account, amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Moves `amount` VOKEN from `sender` to `recipient`.
     *
     * Emits a {Transfer} event.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    )
        private
    {
        if (!isBank(sender) && !isBank(recipient)) {
            uint16 permille = burningPermille();

            if (permille > 0) {
                uint256 amountBurn = amount.mul(permille).div(1_000);
                uint256 amountTransfer = amount.sub(amountBurn);
    
                _accounts[sender].balance = _accounts[sender].balance.sub(amountTransfer, "Transfer: insufficient balance");
                _accounts[recipient].balance = _accounts[recipient].balance.add(amountTransfer);
                emit Transfer(sender, recipient, amountTransfer);
    
                _burn(sender, amountBurn);
                
                return;
            }
        }

        _accounts[sender].balance = _accounts[sender].balance.sub(amount, "Transfer: insufficient balance");
        _accounts[recipient].balance = _accounts[recipient].balance.add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /**
     * @dev Returns true if the `account` is a contract.
     */
    function isContract(address account)
        private
        view
        returns (bool)
    {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}
