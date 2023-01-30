pragma solidity 0.4.24;

import "./SafeMath.sol";
import './StandardToken.sol';
import './Ownable.sol';

contract FLXCToken is StandardToken, Ownable {

    using SafeMath for uint256;

    string public constant symbol = "FLXC";
    string public constant name = "FLXC Token";
    uint8 public constant decimals = 18;

    // Total Number of tokens ever goint to be minted. 10 BILLION FLXC tokens.
    uint256 private constant minting_capped_amount = 10000000000 * 10 ** uint256(decimals);

    // 10% of inital supply.
    uint256  constant vesting_amount = 100000000 * 10 ** uint256(decimals);

    uint256 private initialSupply = minting_capped_amount;

    address public vestingAddress;

  
    /** @dev to cap the total number of tokens that will ever be newly minted
      * owner has to stop the minting by setting this variable to true.
      */
    bool public mintingFinished = false;

    /** @dev Miniting Essentials functions as per OpenZeppelin standards
      */
    modifier canMint() {
      require(!mintingFinished);
      _;
    }
    modifier hasMintPermission() {
      require(msg.sender == owner);
      _;
    }

    /** @dev to prevent malicious use of FLXC tokens and to comply with Anti
      * Money laundering regulations FLXC tokens can be frozen.
      */
    mapping (address => bool) public frozenAccount;

    /** @dev This generates a public event on the blockchain that will notify clients
      */
    event FrozenFunds(address target, bool frozen);
    event Mint(address indexed to, uint256 amount);
    event MintFinished();
    event Burn(address indexed burner, uint256 value);

    constructor() public {

        _totalSupply = minting_capped_amount;
        owner = msg.sender;
        balances[owner] = _totalSupply;
        emit Transfer(address(0), owner, balances[owner]);
    }

    /* Do not accept ETH */
    function() public payable {
        revert();
    }


    function setVestingAddress(address _vestingAddress) external onlyOwner {
        vestingAddress = _vestingAddress;
        assert(approve(vestingAddress, vesting_amount));
    }
   
    function getVestingAmount() public view returns(uint256) {
        return vesting_amount;
    }


    /** @dev Transfer possible only after ICO ends and Frozen accounts
      * wont be able to transfer funds to other any other account and viz.
      * @notice added safeTransfer functionality
      */
    function transfer(address _to, uint256 _value) public returns(bool) {
        require(!frozenAccount[msg.sender]);
        require(!frozenAccount[_to]);

        require(super.transfer(_to, _value));
        return true;
    }

    /** @dev Only owner's tokens can be transferred before Crowdsale ends.
      * beacuse the inital supply of FLXC is allocated to owners acc and later
      * distributed to various subcontracts.
      * @notice added safeTransferFrom functionality
      */
    function transferFrom(address _from, address _to, uint256 _value) public returns(bool) {
        require(!frozenAccount[_from]);
        require(!frozenAccount[_to]);
        require(!frozenAccount[msg.sender]);


        require(super.transferFrom(_from, _to, _value));
        return true;
    }

    /** @notice added safeApprove functionality
      */
    function approve(address spender, uint256 tokens) public returns (bool){
        require(super.approve(spender, tokens));
        return true;
    }

   /** @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
     * @param target Address to be frozen
     * @param freeze either to freeze it or not
     */
    function freezeAccount(address target, bool freeze) public onlyOwner {
        require(frozenAccount[target] != freeze);

        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }


    /** @dev Function to mint tokens
      * @param _to The address that will receive the minted tokens.
      * @param _amount The amount of tokens to mint.
      * @return A boolean that indicates if the operation was successful.
      */
    function mint(address _to, uint256 _amount) public hasMintPermission canMint returns (bool) {
      require(_totalSupply.add(_amount) <= minting_capped_amount);

      _totalSupply = _totalSupply.add(_amount);
      balances[_to] = balances[_to].add(_amount);
      emit Mint(_to, _amount);
      emit Transfer(address(0), _to, _amount);
      return true;
    }

   /** @dev Function to stop minting new tokens.
     * @return True if the operation was successful.
     */
    function finishMinting() public onlyOwner canMint returns (bool) {
      mintingFinished = true;
      emit MintFinished();
      return true;
    }

    /** @dev Burns a specific amount of tokens.
      * @param _value The amount of token to be burned.
      */
     function burn(uint256 _value) public {
       _burn(msg.sender, _value);
     }

     function _burn(address _who, uint256 _value) internal {
       require(_value <= balances[_who]);
       // no need to require value <= totalSupply, since that would imply the
       // sender's balance is greater than the totalSupply, which *should* be an assertion failure

       balances[_who] = balances[_who].sub(_value);
       _totalSupply = _totalSupply.sub(_value);
       emit Burn(_who, _value);
       emit Transfer(_who, address(0), _value);
     }
}



