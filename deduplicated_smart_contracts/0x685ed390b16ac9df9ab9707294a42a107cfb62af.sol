/**
 *Submitted for verification at Etherscan.io on 2019-09-13
*/

pragma solidity ^0.5.8;
library SafeMath {
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    }
}

contract weeWMA
{
    using SafeMath for uint256;
    string public name;
    uint8 public decimals;
    string public symbol;
    address owner;
    uint256 private _totalSupply;
    mapping (address => mapping (address => uint256)) private _allowed;
    mapping (address => uint) private _balanceOf;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    
    
    constructor() public {
        
        // Creating a Contract of 20 billion token. name of the token 
        // is weeMarketplaceAccessToken and the symbol of token is WMA
        decimals = 18;
        _totalSupply = 20000000000 * 10**uint(decimals);
        name = "weeMarketplaceAccessToken";
        
        symbol = "WMA";
        _balanceOf[msg.sender] = _totalSupply;            
        owner = msg.sender;
        emit Transfer( address(0),msg.sender, _totalSupply);
        
    }
    
    
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return _allowed[_owner][_spender];
    }
    
    /**
     * @dev See {IERC20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */

    function approve(address spender, uint256 _value) public returns (bool) {
          
        
        require(spender != address(0), "ERC20: approve to the zero address");
        require(msg.sender != address(0), "ERC20: approve from the zero address");

        // To change the approve amount you first have to reduce the addresses`
        //  allowance to zero by calling `approve(_spender, 0)` if it is not
        //  already 0 to mitigate the race condition described here:
        //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
        require(!((_value != 0) && (_allowed[msg.sender][spender] != 0)));

        _allowed[msg.sender][spender] = _value;
        emit Approval(msg.sender, spender, _value);
        
             
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
     * - `_from` cannot be the zero address.
     * - `_to` cannot be the zero address.
     * - `_from` must have a balance of at least `amount`.
     */
    
    function _transfer(address _from, address _to, uint256 _value) internal returns (bool)
    {
        
        require(_from != address(0), "ERC20: transfer from the zero address");
        require(_to != address(0), "ERC20: transfer to the zero address");
        require (_balanceOf[_from] >= _value);
        
        _balanceOf[_from] = _balanceOf[_from].sub(_value) ; 
        _balanceOf[_to] = _balanceOf[_to].add(_value);
        emit Transfer(_from, _to, _value);

        return true;
        
    }
    

    function transferFrom(address _from,address _to, uint256 _value) public returns (bool){
        
        require(_allowed[_from][msg.sender] >= _value, "Insufficient Balance");
        _allowed[_from][msg.sender] = _allowed[_from][msg.sender].sub(_value);
       // emit Approval(_from,msg.sender, _allowed[_from][msg.sender]); 
        return _transfer(_from, _to, _value);
        
    }
   
    function transfer(address _to, uint256 _value) public returns (bool){
        
       return _transfer(msg.sender, _to, _value);
        
    }
   
    /**
     * @dev See {IERC20-balanceOf}.
     */

    function balanceOf(address _owner) public view returns (uint256) 
    {
        
        return _balanceOf[_owner];
        
    }
    

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view returns (uint256 supply) 
    {
        
        return _totalSupply;
        
    }

}