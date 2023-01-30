// SPDX-License-Identifier: MIT

pragma solidity >=0.6.0 <0.8.0;

import "./Context.sol";
import "./SafeMath.sol";
import "./Pausable.sol";
import "./IERC20.sol";
import "./INEONVAULT.sol";

/**
 * 'NEON' token contract
 * 
 * Name        : NEONToken
 * Symbol      : NEON
 * Total supply: 10,000 (10 thousands)
 * Decimals    : 18
 *
 * ERC20 Token, with the Burnable, Pausable and Ownable from OpenZeppelin
 */
contract NEONToken is Context, IERC20, Pausable {
    using SafeMath for uint256;

    mapping (address => uint256) private _balances;
    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;
    
    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint8 private _transferFee;
    address private _vault;
    address private _presale;

    /**
     * @dev Throws if called by any account other than the presale or vault contract.
     */
    modifier onlyWithoutFee() {
        require(
            _presale == _msgSender() || _vault == _msgSender(),
            "Ownable: caller is not the presale or vault or owner contract");
        _;
    }

    event ChangedTransferFee(address owner, uint8 fee);
    event ChangedNEONVault(address oldAddress, address newAddress);
    event ChangedNeonPresale(address oldAddress, address newAddress);

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (address presale, address uniswap, address marketing, address team) {
        _name = 'Neon Vault';
        _symbol = 'NEON';
        _decimals = 18;
        _presale = presale;

        // set initial transfer fee as 1%
        // It is allow 2 digits under point
        _transferFee = 100;

        // presale 5,000
        _mint(presale, 5000E18);
        // Uniswap pool 4,250
        _mint(uniswap, 4250E18);
        // Marketing 500
        _mint(marketing, 500E18);
        // Team 250
        _mint(team, 250E18);
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5,05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless {_setupDecimals} is
     * called.
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public virtual override whenNotPaused returns (bool) {
        uint256 feeAmount = amount.mul(uint256(transferFee())).div(10000);
        uint256 leftAmount = amount.sub(feeAmount);
        _transfer(_msgSender(), _vault, feeAmount);
        _transfer(_msgSender(), recipient, leftAmount);

        INEONVault(_vault).addEpochReward(feeAmount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * Requirements:
     *
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override whenNotPaused returns (bool) {
        uint256 feeAmount = amount.mul(uint256(transferFee())).div(10000);
        uint256 leftAmount = amount.sub(feeAmount);
        
        _transfer(sender, _vault, feeAmount);
        _transfer(sender, recipient, leftAmount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));

        INEONVault(_vault).addEpochReward(feeAmount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * @dev See {IERC20-transfer}. transfer tokens while only presale or vault
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transferWithoutFee(address recipient, uint256 amount) external onlyWithoutFee returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * @dev Returns the trasfer fee value.
     */
    function transferFee() public view returns (uint8) {
        return _transferFee;
    }

    /**
     * @dev Change the transfer fee. Must be called by only governance.
     */
    function changeTransferFee(uint8 fee) external onlyGovernance {
        _transferFee = fee;
        emit ChangedTransferFee(governance(), fee);
    }

    /**
     * @dev return neon vault contract address
     */
    function NEONVault() external view returns (address) {
        return _vault;
    }

    /**
     * @dev Change staking contract when it redeploy
     */
    function changeNEONVault(address vault) external onlyGovernance {
        require(vault != address(0), "Invalid vault contract address");
        address oldAddress = _vault;
        _vault = vault;
        emit ChangedNEONVault(oldAddress, _vault);
    }

    /**
     * @dev return presale contract address
     */
    function neonPresale() external view returns (address) {
        return _presale;
    }

    /**
     * @dev Change presale contract when it redeploy
     */
    function changeNeonPresale(address presale) external onlyGovernance {
        require(presale != address(0), "Invalid presale contract address");
        address oldAddress = _presale;
        _presale = presale;
        emit ChangedNeonPresale(oldAddress, _presale);
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
