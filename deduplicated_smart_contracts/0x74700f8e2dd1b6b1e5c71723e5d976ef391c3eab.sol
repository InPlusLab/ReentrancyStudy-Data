// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./Context.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
import "./Address.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
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
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
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

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity 0.6.2;

// Importing libraries
import "./Ownable.sol";
import "./ERC20.sol";
import "./SafeERC20.sol";
import "./SafeMath.sol";
import "./Address.sol";
import "./ReentrancyGuard.sol";

/**
 * @title Yield Contract
 * @notice Contract to create yield contracts for users
 */

/**
 * TO NOTE
 * @notice Store collateral and provide interest MXX or burn MXX
 * @notice Interest (contractFee, penaltyFee etc) is always represented 10 power 6 times the actual value
 * @notice Note that only 4 decimal precision is allowed for interest
 * @notice If interest is 5%, then value to input is 0.05 * 10 pow 6 = 5000
 * @notice mFactor or mintFactor is represented 10 power 18 times the actual value.
 * @notice If value of 1 ETH is 380 USD, then mFactor of ETH is (380 * (10 power 18))
 * @notice Collateral should always be in its lowest denomination (based on the coin or Token)
 * @notice If collateral is 6 USDT, then value is 6 * (10 power 6) as USDT supports 6 decimals
 * @notice startTime and endTime are represented in Unix time
 * @notice tenure for contract is represented in days (90, 180, 270) etc
 * @notice mxxToBeMinted or mxxToBeMinted is always in its lowest denomination (8 decimals)
 * @notice For e.g if mxxToBeMinted = 6 MXX, then actual value is 6 * (10 power 8)
 */

contract YieldContract is Ownable, ReentrancyGuard {
    // Using SafeERC20 for ERC20
    using SafeERC20 for ERC20;

    // Using SafeMath Library to prevent integer overflow
    using SafeMath for uint256;

    // Using Address library for ERC20 contract checks
    using Address for address;

    /**
     * DEFINING VARIABLES
     */

    /**
     * @dev - Array to store valid ERC20 addresses
     */
    address[] public erc20List;

    /**
     * @dev - A struct to store ERC20 details
     * @notice symbol - The symbol/ ticker symbol of ERC20 contract
     * @notice isValid - Boolean variable indicating if the ERC20 is valid to be used for yield contracts
     * @notice noContracts - Integer indicating the number of contracts associated with it
     * @notice mFactor - Value of a coin/token in USD * 10 power 18
     */
    struct Erc20Details {
        string symbol;
        bool isValid;
        uint64 noContracts;
        uint256 mFactor;
    }

    /**
     * @dev - A mapping to map ERC20 addresses to its details
     */
    mapping(address => Erc20Details) public erc20Map;

    /**
     * @dev - Array to store user created yield contract IDs
     */
    bytes32[] public allContracts;

    /**
     * @dev - A enum to store yield contract status
     */
    enum Status {
        Inactive, 
        Active, 
        OpenMarket, 
        Claimed, 
        Destroyed
    }

    /**
     * @dev - A enum to switch set value case
     */
    enum ParamType {
        ContractFee,
        MinEarlyRedeemFee,
        MaxEarlyRedeemFee,
        TotalAllocatedMxx
    }

    /**
     * @dev - A struct to store yield contract details
     * @notice contractOwner - The owner of the yield contract
     * @notice tokenAddress - ERC20 contract address (if ETH then ZERO_ADDRESS)
     * @notice startTime - Start time of the yield contract (in unix timestamp)
     * @notice endTime - End time of the yield contract (in unix timestamp)
     * @notice tenure - The agreement tenure in days
     * @notice contractStatus - The status of a contract (can be Inactive/Active/OpenMarket/Claimed/Destroyed)
     * @notice collateral - Value of collateral (multiplied by 10 power 18 to handle decimals)
     * @notice mxxToBeMinted - The final MXX token value to be returned to the contract owner
     * @notice interest - APY or Annual Percentage Yield (returned from tenureApyMap)
     */
    struct ContractDetails {
        address contractOwner;
        uint48 startTime;
        uint48 endTime;
        address tokenAddress;
        uint16 tenure;
        uint64 interest;
        Status contractStatus;
        uint256 collateral;
        uint256 mxxToBeMinted;
    }

    /**
     * @dev - A mapping to map contract IDs to their details
     */
    mapping(bytes32 => ContractDetails) public contractMap;

    /**
     * @dev - A mapping to map tenure in days to apy (Annual Percentage Yield aka interest rate)
     * Percent rate is multiplied by 10 power 6. (For e.g. if 5% then value is 0.05 * 10 power 6)
     */
    mapping(uint256 => uint64) public tenureApyMap;

    /**
     * @dev - Variable to store contract fee
     * If 10% then value is 0.1 * 10 power 6
     */
    uint64 public contractFee;

    /**
     * @dev - Constant variable to store Official MXX ERC20 token address
     */
    address public constant MXX_ADDRESS = 0x8a6f3BF52A26a21531514E23016eEAe8Ba7e7018;

    /**
     * @dev - Constant address to store the Official MXX Burn Address
     */
    address public constant BURN_ADDRESS = 0x19B292c1a84379Aab41564283e7f75bF20e45f91;

    /**
     * @dev - Constant variable to store ETH address
     */
    address internal constant ZERO_ADDRESS = address(0);

    /**
     * @dev - Constant variable to store 10 power of 6
     */
    uint64 internal constant POW6 = 1000000;

    /**
     * @dev - Variable to store total allocated MXX for yield contracts
     */
    uint256 public totalAllocatedMxx;

    /**
     * @dev - Variable to total MXX minted from yield contracts
     */
    uint256 public mxxMintedFromContract;

    /**
     * @dev - Variables to store % of penalty / redeem fee fees
     * If min penalty / redeem fee is 5% then value is 0.05 * 10 power 6
     * If max penalty / redeem fee is 50% then value is 0.5 * 10 power 6
     */
    uint64 public minEarlyRedeemFee;
    uint64 public maxEarlyRedeemFee;

    /**
     * CONSTRUCTOR FUNCTION
     */

    constructor(uint256 _mxxmFactor) public Ownable() {
        // Setting default variables
        tenureApyMap[90] = 2 * POW6;
        tenureApyMap[180] = 4 * POW6;
        tenureApyMap[270] = 10 * POW6;
        contractFee = (8 * POW6) / 100;
        totalAllocatedMxx = 1000000000 * (10**8); // 1 billion initial Mxx allocated //
        minEarlyRedeemFee = (5 * POW6) / 100;
        maxEarlyRedeemFee = (5 * POW6) / 10;

        addErc20(MXX_ADDRESS, _mxxmFactor);
    }

    /**
     * DEFINE MODIFIER
     */

    /**
     * @dev Throws if address is a user address (except ZERO_ADDRESS)
     * @param _erc20Address - Address to be checked
     */

    modifier onlyErc20OrEth(address _erc20Address) {
        require(
            _erc20Address == ZERO_ADDRESS || Address.isContract(_erc20Address),
            "Not contract address"
        );
        _;
    }

    /**
     * @dev Throws if address in not in ERC20 list (check for mFactor and symbol)
     * @param _erc20Address - Address to be checked
     */

    modifier inErc20List(address _erc20Address) {
        require(
            erc20Map[_erc20Address].mFactor != 0 ||
                bytes(erc20Map[_erc20Address].symbol).length != 0,
            "Not in ERC20 list"
        );
        _;
    }

    /**
     * INTERNAL FUNCTIONS
     */

    /**
     * @dev This function will check the array for an element and retun the index
     * @param _inputAddress - Address for which the index has to be found
     * @param _inputAddressList - The address list to be checked
     * @return index - Index element indicating the position of the inputAddress inside the array
     * @return isFound - Boolean indicating if the element is present in the array or not
     * Access Control: This contract or derived contract
     */

    function getIndex(address _inputAddress, address[] memory _inputAddressList)
        internal
        pure
        returns (uint256 index, bool isFound)
    {
        // Enter loop
        for (uint256 i = 0; i < _inputAddressList.length; i++) {
            // If value matches, return index
            if (_inputAddress == _inputAddressList[i]) {
                return (i, true);
            }
        }

        // If no value matches, return false
        return (0, false);
    }

    /**
     * GENERAL FUNCTIONS
     */

    /**
     * @dev This function will set interest rate for the tenure in days
     * @param _tenure - Tenure of the agreement in days
     * @param _interestRate - Interest rate in 10 power 6 (If 5%, then value is 0.05 * 10 power 6)
     * @return - Boolean status - True indicating successful completion
     * Access Control: Only Owner
     */

    function setInterest(uint256 _tenure, uint64 _interestRate)
        public
        onlyOwner()
        returns (bool)
    {
        tenureApyMap[_tenure] = _interestRate;
        return true;
    }

    /**
     * @dev This function will set value based on ParamType
     * @param _parameter - Enum value indicating ParamType (0,1,2,3)
     * @param _value - Value to be set
     * @return - Boolean status - True indicating successful completion
     * Access Control: Only Owner
     */

    function setParamType(ParamType _parameter, uint256 _value)
        public
        onlyOwner()
        returns (bool)
    {
        if (_parameter == ParamType.ContractFee) {
            contractFee = uint64(_value);
        } else if (_parameter == ParamType.MinEarlyRedeemFee) {
            require(
                uint64(_value) <= maxEarlyRedeemFee,
                "Greater than max redeem fee"
            );
            minEarlyRedeemFee = uint64(_value);
        } else if (_parameter == ParamType.MaxEarlyRedeemFee) {
            require(
                uint64(_value) >= minEarlyRedeemFee,
                "Less than min redeem fee"
            );
            maxEarlyRedeemFee = uint64(_value);
        } else if (_parameter == ParamType.TotalAllocatedMxx) {
            require(
                _value >= mxxMintedFromContract,
                "Less than total mxx minted"
            );
            totalAllocatedMxx = _value;
        }
    }

    /**
     * SUPPORTED ERC20 ADDRESS FUNCTIONS
     */

    /**
     * @dev Adds a supported ERC20 address into the contract
     * @param _erc20Address - Address of the ERC20 contract
     * @param _mFactor - Mint Factor of the token (value of 1 token in USD * 10 power 18)
     * @return - Boolean status - True indicating successful completion
     * @notice - Access control: Only Owner
     */
    function addErc20(address _erc20Address, uint256 _mFactor)
        public
        onlyOwner()
        onlyErc20OrEth(_erc20Address)
        returns (bool)
    {
        // Check for existing contracts and validity. If condition fails, revert
        require(
            erc20Map[_erc20Address].noContracts == 0,
            "Token has existing contracts"
        );
        require(!erc20Map[_erc20Address].isValid, "Token already available");

        // Add token details and return true
        // If _erc20Address = ZERO_ADDRESS then it is ETH else ERC20
        erc20Map[_erc20Address] = Erc20Details(
            (_erc20Address == ZERO_ADDRESS)
                ? "ETH"
                : ERC20(_erc20Address).symbol(),
            true,
            0,
            _mFactor
        );

        erc20List.push(_erc20Address);
        return true;
    }

    /**
     * @dev Adds a list of supported ERC20 addresses into the contract
     * @param _erc20AddressList - List of addresses of the ERC20 contract
     * @param _mFactorList - List of mint factors of the token
     * @return - Boolean status - True indicating successful completion
     * @notice - The length of _erc20AddressList and _mFactorList must be the same
     * @notice - Access control: Only Owner
     */
    function addErc20List(
        address[] memory _erc20AddressList,
        uint256[] memory _mFactorList
    ) public onlyOwner() returns (bool) {
        // Check if the length of 2 input arrays are the same else throw
        require(
            _erc20AddressList.length == _mFactorList.length,
            "Inconsistent Inputs"
        );

        // Enter loop and token details
        for (uint256 i = 0; i < _erc20AddressList.length; i++) {
            addErc20(_erc20AddressList[i], _mFactorList[i]);
        }
        return true;
    }

    /**
     * @dev Removes a valid ERC20 addresses from the contract
     * @param _erc20Address - Address of the ERC20 contract to be removed
     * @return - Boolean status - True indicating successful completion
     * @notice - Access control: Only Owner
     */
    function removeErc20(address _erc20Address)
        public
        onlyOwner()
        returns (bool)
    {
        // Check if Valid ERC20 not equals MXX_ADDRESS
        require(_erc20Address != MXX_ADDRESS, "Cannot remove MXX");

        // Check if _erc20Address has existing yield contracts
        require(
            erc20Map[_erc20Address].noContracts == 0,
            "Token has existing contracts"
        );

        // Get array index and isFound flag
        uint256 index;
        bool isFound;
        (index, isFound) = getIndex(_erc20Address, erc20List);

        // Require address to be in list
        require(isFound, "Address not found");

        // Get last valid ERC20 address in the array
        address lastErc20Address = erc20List[erc20List.length - 1];

        // Assign last address to the index position
        erc20List[index] = lastErc20Address;

        // Delete last address from the array
        erc20List.pop();

        // Delete ERC20 details for the input address
        delete erc20Map[_erc20Address];
        return true;
    }

    /**
     * @dev Enlists/Delists ERC20 address to prevent adding new yield contracts with this ERC20 collateral
     * @param _erc20Address - Address of the ERC20 contract
     * @param _isValid - New validity boolean of the ERC20 contract
     * @return - Boolean status - True indicating successful completion
     * @notice - Access control: Only Owner
     */
    function setErc20Validity(address _erc20Address, bool _isValid)
        public
        onlyOwner()
        inErc20List(_erc20Address)
        returns (bool)
    {
        // Set valid ERC20 validity
        erc20Map[_erc20Address].isValid = _isValid;
        return true;
    }

    /**
     * @dev Updates the mint factor of a coin/token
     * @param _erc20Address - Address of the ERC20 contract or ETH address (ZERO_ADDRESS)
     * @return - Boolean status - True indicating successful completion
     * @notice - Access control: Only Owner
     */
    function updateMFactor(address _erc20Address, uint256 _mFactor)
        public
        onlyOwner()
        inErc20List(_erc20Address)
        onlyErc20OrEth(_erc20Address)
        returns (bool)
    {
        // Update mint factor
        erc20Map[_erc20Address].mFactor = _mFactor;
        return true;
    }

    /**
     * @dev Updates the mint factor for list of coin(s)/token(s)
     * @param _erc20AddressList - List of ERC20 addresses
     * @param _mFactorList - List of mint factors for ERC20 addresses
     * @return - Boolean status - True indicating successful completion
     * @notice - Length of the 2 input arrays must be the same
     * @notice - Access control: Only Owner
     */
    function updateMFactorList(
        address[] memory _erc20AddressList,
        uint256[] memory _mFactorList
    ) public onlyOwner() returns (bool) {
        // Length of the 2 input arrays must be the same. If condition fails, revert
        require(
            _erc20AddressList.length == _mFactorList.length,
            "Inconsistent Inputs"
        );

        // Enter the loop, update and return true
        for (uint256 i = 0; i < _erc20AddressList.length; i++) {
            updateMFactor(_erc20AddressList[i], _mFactorList[i]);
        }
        return true;
    }

    /**
     * @dev Returns number of valid Tokens/Coins supported
     * @return - Number of valid tokens/coins
     * @notice - Access control: Public
     */
    function getNoOfErc20s() public view returns (uint256) {
        return (erc20List.length);
    }

    /**
     * @dev Returns subset list of valid ERC20 contracts
     * @param _start - Start index to search in the list
     * @param _end - End index to search in the list
     * @return - List of valid ERC20 addresses subset
     * @notice - Access control: Public
     */
    function getSubsetErc20List(uint256 _start, uint256 _end)
        public
        view
        returns (address[] memory)
    {
        // If _end higher than length of array, set end index to last element of the array
        if (_end >= erc20List.length) {
            _end = erc20List.length - 1;
        }

        // Check conditions else fail
        require(_start <= _end, "Invalid limits");

        // Define return array
        uint256 noOfElements = _end - _start + 1;
        address[] memory subsetErc20List = new address[](noOfElements);

        // Loop in and add elements from erc20List array
        for (uint256 i = _start; i <= _end; i++) {
            subsetErc20List[i - _start] = erc20List[i];
        }
        return subsetErc20List;
    }

    /**
     * YIELD CONTRACT FUNCTIONS
     */

    /**
     * @dev Creates a yield contract
     * @param _erc20Address - The address of the ERC20 token (ZERO_ADDRESS if ETH)
     * @param _collateral - The collateral value of the ERC20 token or ETH
     * @param _tenure - The number of days of the agreement
     * @notice - Collateral to be input - Actual value * (10 power decimals)
     * @notice - For e.g If collateral is 5 USDT (Tether) and decimal is 6, then _collateral is (5 * (10 power 6))
     * Non Reentrant modifier is used to prevent re-entrancy attack
     * @notice - Access control: External
     */

    function createYieldContract(
        address _erc20Address,
        uint256 _collateral,
        uint16 _tenure
    ) external payable nonReentrant() {
        // Check if token/ETH is approved to create contracts
        require(erc20Map[_erc20Address].isValid, "Token/Coin not approved");

        // Create contractId and check if status Inactive (enum state 0)
        bytes32 contractId = keccak256(
            abi.encode(msg.sender, _erc20Address, now, allContracts.length)
        );
        require(
            contractMap[contractId].contractStatus == Status.Inactive,
            "Contract already exists"
        );

        // Check if APY (interest rate is not zero for the tenure)
        require(tenureApyMap[_tenure] != 0, "No interest rate is set");

        // Get decimal value for collaterals
        uint256 collateralDecimals;

        // Check id collateral is not 0
        require(_collateral != 0, "Collateral is 0");

        if (_erc20Address == ZERO_ADDRESS) {
            // In case of ETH, check to ensure if collateral value match ETH sent
            require(msg.value == _collateral, "Incorrect funds");

            // ETH decimals is 18
            collateralDecimals = 10**18;
        } else {
            // In case of non ETH, check to ensure if msg.value is 0
            require(msg.value == 0, "Incorrect funds");

            collateralDecimals = 10**uint256(ERC20(_erc20Address).decimals());

            // Transfer collateral
            ERC20(_erc20Address).safeTransferFrom(
                msg.sender,
                address(this),
                _collateral
            );
        }

        // Calculate MXX to be Minted
        uint256 numerator = _collateral
            .mul(erc20Map[_erc20Address].mFactor)
            .mul(tenureApyMap[_tenure])
            .mul(10**uint256(ERC20(MXX_ADDRESS).decimals()))
            .mul(_tenure);
        uint256 denominator = collateralDecimals
            .mul(erc20Map[MXX_ADDRESS].mFactor)
            .mul(365 * POW6);
        uint256 valueToBeMinted = numerator.div(denominator);

        // Update total MXX minted from yield contracts
        mxxMintedFromContract = mxxMintedFromContract.add(valueToBeMinted);

        // Check the MXX to be minted will result in total MXX allocated for creating yield contracts
        require(
            totalAllocatedMxx >= mxxMintedFromContract,
            "Total allocated MXX exceeded"
        );

        // Calculate MXX to be burnt
        numerator = valueToBeMinted.mul(contractFee);
        denominator = POW6;
        uint256 valueToBeBurnt = numerator.div(denominator);

        // Send valueToBeBurnt to contract fee destination
        ERC20(MXX_ADDRESS).safeTransferFrom(
            msg.sender,
            BURN_ADDRESS,
            valueToBeBurnt
        );

        // Create contract
        contractMap[contractId] = ContractDetails(
            msg.sender,
            uint48(now),
            uint48(now.add(uint256(_tenure).mul(1 days))),
            _erc20Address,
            _tenure,
            tenureApyMap[_tenure],
            Status.Active,
            _collateral,
            valueToBeMinted
        );

        // Push to all contracts and user contracts
        allContracts.push(contractId);

        // Increase number of contracts ERC20 details
        erc20Map[_erc20Address].noContracts += 1;
    }

    /**
     * @dev Early Redeem a yield contract
     * @param _contractId - The Id of the contract
     * Non Reentrant modifier is used to prevent re-entrancy attack
     * @notice - Access control: External
     */

    function earlyRedeemContract(bytes32 _contractId) external nonReentrant() {
        // Check if contract is Active
        require(
            contractMap[_contractId].contractStatus == Status.Active,
            "Contract is not active"
        );

        // Check if redeemer is the owner
        require(
            contractMap[_contractId].contractOwner == msg.sender,
            "Redeemer is not owner"
        );

        // Check if current time is less than end time
        require(
            now < contractMap[_contractId].endTime,
            "Contract is beyond its end time"
        );

        // Calculate mxxMintedTillDate
        uint256 numerator = now.sub(contractMap[_contractId].startTime).mul(
            contractMap[_contractId].mxxToBeMinted
        );
        uint256 denominator = uint256(contractMap[_contractId].endTime).sub(
            contractMap[_contractId].startTime
        );
        uint256 mxxMintedTillDate = numerator.div(denominator);

        // Calculate penaltyPercent
        numerator = uint256(maxEarlyRedeemFee).sub(minEarlyRedeemFee).mul(
            now.sub(contractMap[_contractId].startTime)
        );
        uint256 penaltyPercent = uint256(maxEarlyRedeemFee).sub(
            numerator.div(denominator)
        );

        // Calculate penaltyMXXToBurn
        numerator = penaltyPercent.mul(mxxMintedTillDate);
        uint256 penaltyMXXToBurn = numerator.div(POW6);

        // Check if penalty MXX to burn is not 0
        require(penaltyMXXToBurn != 0, "No penalty MXX");

        // Calculate mxxToBeSent
        uint256 mxxToBeSent = mxxMintedTillDate.sub(penaltyMXXToBurn);

        // Return collateral
        if (contractMap[_contractId].tokenAddress == ZERO_ADDRESS) {
            // Send back ETH
            (bool success, ) = contractMap[_contractId].contractOwner.call{
                value: contractMap[_contractId].collateral
            }("");
            require(success, "Transfer failed");
        } else {
            // Send back ERC20 collateral
            ERC20(contractMap[_contractId].tokenAddress).safeTransfer(
                contractMap[_contractId].contractOwner,
                contractMap[_contractId].collateral
            );
        }

        // Return MXX
        ERC20(MXX_ADDRESS).safeTransfer(
            contractMap[_contractId].contractOwner,
            mxxToBeSent
        );

        // Burn penalty fee
        ERC20(MXX_ADDRESS).safeTransfer(BURN_ADDRESS, penaltyMXXToBurn);

        // Updating contract
        contractMap[_contractId].startTime = uint48(now);
        contractMap[_contractId].mxxToBeMinted = contractMap[_contractId]
            .mxxToBeMinted
            .sub(mxxMintedTillDate);
        contractMap[_contractId].contractOwner = ZERO_ADDRESS;
        contractMap[_contractId].contractStatus = Status.OpenMarket;
    }

    /**
     * @dev Acquire a yield contract in the open market
     * @param _contractId - The Id of the contract
     * Non Reentrant modifier is used to prevent re-entrancy attack
     * @notice - Access control: External
     */

    function acquireYieldContract(bytes32 _contractId)
        external
        payable
        nonReentrant()
    {
        // Check if contract is open
        require(
            contractMap[_contractId].contractStatus == Status.OpenMarket,
            "Contract not in open market"
        );

        // Get collateral in case of ERC20 tokens, for ETH it is already received via msg.value
        if (contractMap[_contractId].tokenAddress != ZERO_ADDRESS) {
            // In case of ERC20, ensure no ETH is sent
            require(msg.value == 0, "ETH should not be sent");
            ERC20(contractMap[_contractId].tokenAddress).safeTransferFrom(
                msg.sender,
                address(this),
                contractMap[_contractId].collateral
            );
        } else {
            // In case of ETH check if money received equals the collateral else revert
            require(
                msg.value == contractMap[_contractId].collateral,
                "Incorrect funds"
            );
        }

        // Updating contract
        contractMap[_contractId].contractOwner = msg.sender;
        contractMap[_contractId].contractStatus = Status.Active;
    }

    /**
     * @dev Destroy an open market yield contract
     * @param _contractId - The Id of the contract
     * Non Reentrant modifier is used to prevent re-entrancy attack
     * @notice - Access control: External
     */

    function destroyOMContract(bytes32 _contractId)
        external
        onlyOwner()
        nonReentrant()
    {
        // Check if contract is open
        require(
            contractMap[_contractId].contractStatus == Status.OpenMarket,
            "Contract not in open market"
        );

        // Reduced MXX minted from contract and update status as destroyed
        mxxMintedFromContract -= contractMap[_contractId].mxxToBeMinted;
        contractMap[_contractId].contractStatus = Status.Destroyed;
    }

    /**
     * @dev Claim a yield contract in the active market
     * @param _contractId - The Id of the contract
     * Non Reentrant modifier is used to prevent re-entrancy attack
     * @notice - Access control: External
     */

    function claimYieldContract(bytes32 _contractId) external nonReentrant() {
        // Check if contract is active
        require(
            contractMap[_contractId].contractStatus == Status.Active,
            "Contract is not active"
        );

        // Check if owner and msg.sender are the same
        require(
            contractMap[_contractId].contractOwner == msg.sender,
            "Contract owned by someone else"
        );

        // Check if current time is greater than contract end time
        require(now >= contractMap[_contractId].endTime, "Too early to claim");

        // Return collateral
        if (contractMap[_contractId].tokenAddress == ZERO_ADDRESS) {
            // Send back ETH
            (bool success, ) = contractMap[_contractId].contractOwner.call{
                value: contractMap[_contractId].collateral
            }("");
            require(success, "Transfer failed");
        } else {
            // Send back ERC20 collateral
            ERC20(contractMap[_contractId].tokenAddress).safeTransfer(
                contractMap[_contractId].contractOwner,
                contractMap[_contractId].collateral
            );
        }

        // Return minted MXX
        ERC20(MXX_ADDRESS).safeTransfer(
            contractMap[_contractId].contractOwner,
            contractMap[_contractId].mxxToBeMinted
        );

        // Updating contract
        contractMap[_contractId].contractStatus = Status.Claimed;

        // Reduce no of contracts in ERC20 details
        erc20Map[contractMap[_contractId].tokenAddress].noContracts -= 1;
    }

    /**
     * @dev This function will subset of yield contract
     * @param _start - Start of the list
     * @param _end - End of the list
     * @return - List of subset yield contract
     * Access Control: Public
     */

    function getSubsetYieldContracts(uint256 _start, uint256 _end)
        public
        view
        returns (bytes32[] memory)
    {
        // If _end higher than length of array, set end index to last element of the array
        if (_end >= allContracts.length) {
            _end = allContracts.length.sub(1);
        }

        // Check conditions else fail
        require(_start <= _end, "Invalid limits");

        // Define return array
        uint256 noOfElements = _end.sub(_start).add(1);
        bytes32[] memory subsetYieldContracts = new bytes32[](noOfElements);

        // Loop in and add elements from allContracts array
        for (uint256 i = _start; i <= _end; i++) {
            subsetYieldContracts[i - _start] = allContracts[i];
        }

        return subsetYieldContracts;
    }

    /**
     * @dev This function will withdraw MXX back to the owner
     * @param _amount - Amount of MXX need to withdraw
     * @return - Boolean status indicating successful completion
     * Access Control: Only Owner
     */

    function withdrawMXX(uint256 _amount)
        public
        onlyOwner()
        nonReentrant()
        returns (bool)
    {
        ERC20(MXX_ADDRESS).safeTransfer(msg.sender, _amount);
        return true;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor () internal {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and make it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.2;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies in extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/*
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with GSN meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./Context.sol";
import "./IERC20.sol";
import "./SafeMath.sol";
import "./Address.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of ERC20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract MXXERC20 is Context, IERC20 {
    using SafeMath for uint256;
    using Address for address;

    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor (string memory name, string memory symbol) public {
        _name = name;
        _symbol = symbol;
        _decimals = 18;
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
    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
     * required by the EIP. See the note at the beginning of {ERC20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for ``sender``'s tokens of at least
     * `amount`.
     */
    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
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
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address. // Commented for MXX
     * - `recipient` cannot be the zero address. // Commented for MXX
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        //require(sender != address(0), "ERC20: transfer from the zero address");
        //require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
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

    /**
     * @dev Sets {decimals} to a value other than the default one of 18.
     *
     * WARNING: This function should only be called from the constructor. Most
     * applications that interact with token contracts will not expect
     * {decimals} to ever change, and may work incorrectly if it does.
     */
    function _setupDecimals(uint8 decimals_) internal {
        _decimals = decimals_;
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be to transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(IERC20 token, address spender, uint256 value) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        // solhint-disable-next-line max-line-length
        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}
// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./Context.sol";
/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

