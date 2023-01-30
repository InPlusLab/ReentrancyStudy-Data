pragma solidity 0.5.17;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./Roles.sol";
import "./Ownable.sol";
import "./IERC1404.sol";

contract CrowdliToken is IERC20, IERC1404, Ownable {
    /**
     * Arithmetic operations in Solidity wrap on overflow. This can easily result
     * in bugs, because programmers usually assume that an overflow raises an
     * error, which is the standard behavior in high level programming languages.
     * `SafeMath` restores this intuition by reverting the transaction when an
     * operation overflows.
     *
     * Using this library instead of the unchecked operations eliminates an entire
     * class of bugs, so it's recommended to use it always.
     */
    using SafeMath for uint256;

    /**
     * Library for managing addresses assigned to a Role.
     */
    using Roles for Roles.Role;

    Roles.Role _transferblock;
    Roles.Role _kyc;

    mapping (address => uint256) private _balances;
    mapping (address => uint256) private _allocated;
    mapping (uint8 => string) private _restrictionCodes;
    mapping (uint8 => string) private _burnCodes;
    mapping (uint8 => string) private _mintCodes;
    mapping (uint8 => string) private _blockCodes;
    mapping (address => mapping (address => uint256)) private _allowances;
    mapping (address => mapping (bytes32 => uint256)) private _propertyAmountLocks;

    uint256 private _totalSupply;
    string private _name = "CROWDLITOKEN";
    string private _symbol = "CRT";
    uint8 private _decimals = 5;

    uint8 private constant CODE_TYPE_RESTRICTION = 1;
    uint8 private constant CODE_TYPE_BURN = 2;
    uint8 private constant CODE_TYPE_MINT = 3;
    uint8 private constant CODE_TYPE_BLOCK = 4;

    uint8 private constant NO_RESTRICTIONS = 0;
    uint8 private constant FROM_NOT_IN_KYC_ROLE = 1;
    uint8 private constant TO_NOT_IN_KYC_ROLE = 2;
    uint8 private constant FROM_IN_TRANSFERBLOCK_ROLE = 3;
    uint8 private constant TO_IN_TRANSFERBLOCK_ROLE = 4;
    uint8 private constant NOT_ENOUGH_FUNDS = 5;
    uint8 private constant NOT_ENOUGH_UNALLOCATED_FUNDS = 6;

    constructor() public {
        _restrictionCodes[0] = "NO_RESTRICTIONS";
        _restrictionCodes[1] = "FROM_NOT_IN_KYC_ROLE";
        _restrictionCodes[2] = "TO_NOT_IN_KYC_ROLE";
        _restrictionCodes[3] = "FROM_IN_TRANSFERBLOCK_ROLE";
        _restrictionCodes[4] = "TO_IN_TRANSFERBLOCK_ROLE";
        _restrictionCodes[5] = "NOT_ENOUGH_FUNDS";
        _restrictionCodes[6] = "NOT_ENOUGH_UNALLOCATED_FUNDS";

        _mintCodes[0] = "CRT_SALE";
        _mintCodes[1] = "ANNUAL_ISSUANCE_FEE";
        _mintCodes[2] = "QUARTERLY_ISSUANCE_FEE";
        _mintCodes[3] = "REPLACE_TOKENS";
        _mintCodes[4] = "OTHER";

        _burnCodes[0] = "KYC_ISSUE";
        _burnCodes[1] = "REFUND_EXIT";
        _burnCodes[2] = "REPLACE_TOKENS";
        _burnCodes[3] = "OTHER";

        _blockCodes[0] = "KYC_ISSUE";
        _blockCodes[1] = "KYT_ISSUE";
        _blockCodes[2] = "LOST_TOKENS";
        _blockCodes[3] = "MAINTENANCE";
        _blockCodes[4] = "OTHER";
    }

    /**
     * Returns the name of the token
     */
    function name() public view returns (string memory) {
        return _name;
    }

    /**
     * Returns the symbol of the token
     */
    function symbol() public view returns (string memory) {
        return _symbol;
    }

    /**
     * Returns the number of decimals the token uses
     */
    function decimals() public view returns (uint8) {
        return _decimals;
    }

    /**
     * Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256) {
        return _totalSupply;
    }

    /**
     * Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256) {
        return _balances[account];
    }

    /**
     * Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    /**
     * Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    /**
     * Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
        return true;
    }

    /**
     * Atomically increases the allowance granted to `spender` by the caller.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
        return true;
    }

    /**
     * Atomically decreases the allowance granted to `spender` by the caller.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
        return true;
    }

    /**
     * Moves tokens `amount` from `sender` to `recipient`.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(detectTransferRestriction(sender,recipient,amount) == NO_RESTRICTIONS, "CROWDLITOKEN: Transferrestriction detected please call detectTransferRestriction(address from, address to, uint256 value) for detailed information");
        _balances[sender] = _balances[sender].sub(amount, "ERC20: transfer amount exceeds balance");
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /**
     * Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal onlyOwner {
        require(account != address(0), "ERC20: mint to the zero address");
        require(_kyc.has(account), "CROWDLITOKEN: address is not in kyc list");
        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal onlyOwner {
        require(account != address(0), "ERC20: burn from the zero address");
        _balances[account] = _balances[account].sub(amount, "ERC20: burn amount exceeds balance");
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(address owner, address spender, uint256 amount) internal {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * Destroys `amount` tokens from `account`.
     *
     * See {_burn}.
     */
    function burn(address account, uint256 amount, uint8 code) external onlyOwner {
        require(codeExist(code,CODE_TYPE_BURN), "CROWDLITOKEN: The code does not exist");
        require(allocatedTokens(account) == 0, "CROWDLITOKEN: There are token allocations, its not allowed to burn tokens if there are token allocations");
        _burn(account, amount);
        emit Burn(account, amount, code);
    }

    /**
     * Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Mint} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function mintTo(address account, uint256 amount, uint8 code) external onlyOwner {
        require(codeExist(code,CODE_TYPE_MINT), "CROWDLITOKEN: The code does not exist");
        _mint(account, amount);
        emit Mint(account, amount, code);
    }

    /**
     * Returns a human-readable message for a given restrictioncode
     */
    function messageForTransferRestriction(uint8 restrictionCode) external view returns (string memory){
        require(codeExist(restrictionCode,CODE_TYPE_RESTRICTION), "CROWDLITOKEN: The code does not exist");
        return _restrictionCodes[restrictionCode];
    }

    /**
     * Returns a human-readable message for a given burncode
     */
    function messageForBurnCode(uint8 burnCode) external view returns (string memory){
        require(codeExist(burnCode,CODE_TYPE_BURN), "CROWDLITOKEN: The code does not exist");
        return _burnCodes[burnCode];
    }

    /**
     * Returns a human-readable message for a given mintcode
     */
    function messageForMintCode(uint8 mintCode) external view returns (string memory){
        require(codeExist(mintCode,CODE_TYPE_MINT), "CROWDLITOKEN: The code does not exist");
        return _mintCodes[mintCode];
    }

    /**
     * Returns a human-readable message for a given blockcode
     */
    function messageForBlockCode(uint8 blockCode) external view returns (string memory){
        require(codeExist(blockCode,CODE_TYPE_BLOCK), "CROWDLITOKEN: The code does not exist");
        return _blockCodes[blockCode];
    }

    /**
     * Detects if a transfer will be reverted and if so returns an appropriate reference code
     */
    function detectTransferRestriction(address from, address to, uint256 value) public view returns (uint8){
        if(!_kyc.has(from)){
            return FROM_NOT_IN_KYC_ROLE;
        } else if(!_kyc.has(to)){
            return TO_NOT_IN_KYC_ROLE;
        } else if(_transferblock.has(from)){
            return FROM_IN_TRANSFERBLOCK_ROLE;
        } else if(_transferblock.has(to)){
            return TO_IN_TRANSFERBLOCK_ROLE;
        } else if(_balances[from] < value){
            return NOT_ENOUGH_FUNDS;
        } else if(_balances[from].sub(_allocated[from]) < value){
            return NOT_ENOUGH_UNALLOCATED_FUNDS;
        } else {
            return NO_RESTRICTIONS;
        }
    }

    /**
     * Mark a List of `address` with the kyc Role
     */
    function addUserListToKycRole(address[] calldata whitelistedAddresses) external onlyOwner {
        for(uint i=0; i< whitelistedAddresses.length; i++){
            _kyc.add(whitelistedAddresses[i]);
        }
    }

    /**
     * Remove the Role kyc from an `address`
     */
    function removeUserFromKycRole(address whitelistedAddress) external onlyOwner {
        require(_balances[whitelistedAddress] == 0, "CROWDLITOKEN: To remove someone from the whitelist the balance have to be 0");
        _kyc.remove(whitelistedAddress);
    }

    /**
     * Add the Role `transferblock` to an `address`
     */
    function addTransferBlock(address blockedAddress, uint8 code) external onlyOwner {
        require(codeExist(code,CODE_TYPE_BLOCK), "CROWDLITOKEN: The code does not exist");
        _transferblock.add(blockedAddress);
        emit Block(blockedAddress, code);
    }

    /**
     * Remove the Role `transferblock` from an `address`
     */
    function removeTransferblock(address unblockAddress, uint8 code) external onlyOwner {
        require(codeExist(code,CODE_TYPE_BLOCK), "CROWDLITOKEN: The code does not exist");
        _transferblock.remove(unblockAddress);
        emit Unblock(unblockAddress, code);
    }

    /**
     * Get the total amount of allocated tokens for a specific `owner`
     */
    function allocatedTokens(address owner) public view returns (uint256){
	    return _allocated[owner];
    }

    /**
     * Get the amount of allocated tokens for a specific `owner` for a specific `property`
     */
    function propertyLock(address owner, bytes32 propertyAddress) public view returns (uint256) {
        return _propertyAmountLocks[owner][propertyAddress];
    }

    /**
     * Add a new `restrictionCode` with a related `codeText` to the available `_restrictionCodes`
     */
    function setRestrictionCode(uint8 code, string calldata codeText) external onlyOwner {
        require(!codeExist(code,CODE_TYPE_RESTRICTION), "CROWDLITOKEN: The code already exists");
        require(code > 100, "ERC1404: Codes till 100 are reserverd for the SmartContract internals");
        _restrictionCodes[code] = codeText;
    }

    /**
     * Add a new `burncode` with a related `codeText` to the available `_burnCodes`
     */
    function setBurnCode(uint8 code, string calldata codeText) external onlyOwner {
        require(!codeExist(code,CODE_TYPE_BURN), "CROWDLITOKEN: The code already exists");
        require(code > 100, "ERC1404: Codes till 100 are reserverd for the SmartContract internals");
        _burnCodes[code] = codeText;
    }

    /**
     * Add a new `mintcode` with a related `codeText` to the available `_mintCodes`
     */
    function setMintCode(uint8 code, string calldata codeText) external onlyOwner {
        require(!codeExist(code,CODE_TYPE_MINT), "CROWDLITOKEN: The code already exists");
        require(code > 100, "ERC1404: Codes till 100 are reserverd for the SmartContract internals");
        _mintCodes[code] = codeText;
    }

    /**
     * Add a new `blockcode` with a related `codeText` to the available `_blockCodes`
     */
    function setBlockCode(uint8 code, string calldata codeText) external onlyOwner {
        require(!codeExist(code,CODE_TYPE_BLOCK), "CROWDLITOKEN: The code already exists");
        require(code > 100, "ERC1404: Codes till 100 are reserverd for the SmartContract internals");
        _blockCodes[code] = codeText;
    }

    /**
     * Remove a `restrictioncode` from the available `_restrictionCodes`
     */
    function removeRestrictionCode(uint8 restrictionCode) external onlyOwner {
        require(codeExist(restrictionCode,CODE_TYPE_RESTRICTION), "CROWDLITOKEN: The code does not exist");
        require(restrictionCode > 100, "ERC1404: Codes till 100 are reserverd for the SmartContract internals");
        delete _restrictionCodes[restrictionCode];
    }

    /**
     * Remove a `burncode` from the available `_burnCodes`
     */
    function removeBurnCode(uint8 code) external onlyOwner {
        require(codeExist(code,CODE_TYPE_BURN), "CROWDLITOKEN: The code does not exist");
        require(code > 100, "ERC1404: Codes till 100 are reserverd for the SmartContract internals");
        delete _burnCodes[code];
    }

    /**
     * Remove a `mintcode` from the available `_mintCodes`
     */
    function removeMintCode(uint8 code) external onlyOwner {
        require(codeExist(code,CODE_TYPE_MINT), "CROWDLITOKEN: The code does not exist");
        require(code > 100, "ERC1404: Codes till 100 are reserverd for the SmartContract internals");
        delete _mintCodes[code];
    }

    /**
     * Remove a `blockcode` from the available `_blockCodes`
     */
    function removeBlockCode(uint8 code) external onlyOwner {
        require(codeExist(code,CODE_TYPE_BLOCK), "CROWDLITOKEN: The code does not exist");
        require(code > 100, "ERC1404: Codes till 100 are reserverd for the SmartContract internals");
        delete _blockCodes[code];
    }

    /**
     * Allocate a specific `amount` of tokens for a specific `property` for a specific `owner` address
     *
     * Requirements:
     *
     * - `owner` needs enough unallocated funds
     */
    function allocateAmountFromAddressForProperty(address owner, bytes32 propertyAddress, uint256 amount) external onlyOwner {
        require(_balances[owner] - allocatedTokens(owner) >= amount, "CrowdliToken: Not enough unallocated tokens to allocate the requested amount");
        _allocated[owner] = _allocated[owner].add(amount);
	    _propertyAmountLocks[owner][propertyAddress] = _propertyAmountLocks[owner][propertyAddress].add(amount);
        emit Allocate(owner, propertyAddress, amount);
    }

    /**
     * Unallocate a specific `amount` of tokens for a specific `property` for a specific `owner` address
     *
     * Requirements:
     *
     * - `owner` needs enough unallocated funds
     */
    function unallocatePropertyFromAddress(address owner, bytes32 propertyAddress, uint256 amount) external onlyOwner {
        require(propertyLock(owner,propertyAddress) > 0, "CROWDLITOKEN: The property has no allocated tokens for that address");
        require(amount <= propertyLock(owner,propertyAddress), "CROWDLITOKEN: There are not enough allocated tokens to unallocate the requested amount");
        _allocated[owner] = _allocated[owner].sub(amount);
        _propertyAmountLocks[owner][propertyAddress] = _propertyAmountLocks[owner][propertyAddress].sub(amount);
        emit Unallocate(owner, propertyAddress, amount);
    }

    /**
     * Check if the given Code exists
     */
    function codeExist(uint8 code,uint8 codeType) internal view returns (bool){
        bytes memory memString;
        if(codeType == CODE_TYPE_RESTRICTION){
            memString = bytes(_restrictionCodes[code]);
        } else if(codeType == CODE_TYPE_BURN){
            memString = bytes(_burnCodes[code]);
        } else if(codeType == CODE_TYPE_MINT){
            memString = bytes(_mintCodes[code]);
        } else if(codeType == CODE_TYPE_BLOCK){
            memString = bytes(_blockCodes[code]);
        }
        if (memString.length == 0) {
            return false;
        } else {
            return true;
        }
    }

    /**
     * Emitted when `tokens` are allocated to a specific property
     */
    event Allocate(address indexed owner, bytes32 indexed propertyAddress, uint256 amount);

    /**
     * Emitted when `tokens` are unallocated from a specific property
     */
    event Unallocate(address indexed owner, bytes32 indexed propertyAddress, uint256 amount);

    /**
     * Emitted when `value` tokens are burned from one account (`from`)
     */
    event Burn(address indexed from, uint256 value, uint8 code);

    /**
     * Emitted when `value` tokens are minted to a account (`to`)
     */
    event Mint(address indexed to, uint256 value, uint8 code);

    /**
     * Emitted when `blockAddress` is blocked for transfers for a reason (`code`)
     */
    event Block(address indexed blockAddress, uint8 code);

    /**
     * Emitted when `unblockAddress` is no more blocked for transfers for a reason (`code`)
     */
    event Unblock(address indexed unblockAddress, uint8 code);
}
