/**
 *Submitted for verification at Etherscan.io on 2019-10-27
*/

/**
 * Lich su VN 1955-1963 : Trung tam luu tru Quoc Gia II 
 * Tai Lieu thoi ky 10/1955. Sau khi Hiep dinh Geneve1 
 * http://bit.ly/lichsuVNCH
 ****************************************************
 * Cac ban yeu men lich su VN 
 * Tham gia tro choi bang cong nghe 4.0 token = VNCH
 ****************************************************
* Cai dat app Wallet : trustwallet.com hoac metamask.io
* Add Custom Token Contract = http://bit.ly/VNCHToken  
* Token Symbol = VNCH
* Decimals = 18
****************************************************
 * Co token bat dau tham gia :
 * Token VNCH so le phia sau dau phay : bao gom 18 con so le
 * Va duoc chia thanh 9 cap so (11 22 33 44 55 66 77 88 99)
 * Dung de tham gia xo so thu : 2,3,4,5,7 (thu 6 nghi)

 * vi du tai khoan co 12,000000000000000000 (TK co 12 token)
 * Ban choi ngay thu 5 co tong cong 07 cap so
 * vi du  chon 7 cap so 11 22 33 44 55 66 77
 * thi ban chuyen den dia chi xosoVNCH: 0,11223344556677
 * Luc nay he sinh thai tu dong ghi nhan tai khoan ban tham gia
 * Dia chi soxoVNCH: http://bit.ly/xosoVNCH
 * Kiem tra IN/OUT & thoi gian : http://bit.ly/ktkxsVNCH

*********************LIEN HE ********************************
 * Lien he FB :http://bit.ly/fbVNCH
 * Lien he trang web & email & phone http://bit.ly/webVNCH 
 * Facebook http://bit.ly/fbVNCH
 * Web http://bit.ly/webVNCH
 * Telegram http://bit.ly/telegramVNCH
 * Whatapp http://bit.ly/whatappVNCH
 * Viber http://bit.ly/viberVNCH
 * Call Inum http://bit.ly/inumVNCH

 ****************************************************
 * Thoi gian tham gia ghi nhan y nhu trang Thelott.com
 * Khi het gio thi ban tham gia cung khong co hieu luc
 * Xem ket qua hang ngay https://www.thelott.com/results

 * Giai thuong cap nhat y chang nhu trang Thelott.com
 * Khi trung thi duoc chuyen Token vao tai khoan ban tham gia
 * Update & support xem muc LIEN HE

 *********************HUONG DAN CHOI & TRUNG THUONG ***********
 * Ngay thu 2, 4: Bao gom 6 cap so
 * https://www.thelott.com/mon-wed-lotto/how-to-win 

 * Ngay  thu 3 : Bao gom 7 cap so
 * https://www.thelott.com/oz-lotto/how-to-win

 * Ngay thu 5 : bao gom 7 cap so
 *https://www.thelott.com/powerball/how-to-play

 * Ngay thu 7 : Bao gom 6 cap so
 *https://www.thelott.com/tattslotto/how-to-win

*/
pragma solidity ^0.5.8;

// ----------------------------------------------------------------------------

// Symbol      : VNCH

// Name        : http://bit.ly/VNCHToken

// Total supply issue

// Decimals    : 18

//


// ----------------------------------------------------------------------------



// ----------------------------------------------------------------------------

// Safe maths

// ----------------------------------------------------------------------------

library SafeMath {

    function add(uint a, uint b) internal pure returns (uint c) {

        c = a + b;

        require(c >= a);

    }

    function sub(uint a, uint b) internal pure returns (uint c) {

        require(b <= a);

        c = a - b;

    }

    function mul(uint a, uint b) internal pure returns (uint c) {

        c = a * b;

        require(a == 0 || c / a == b);

    }

    function div(uint a, uint b) internal pure returns (uint c) {

        require(b > 0);

        c = a / b;

    }

}



// ----------------------------------------------------------------------------

// ERC Token Standard #20 Interface

// ----------------------------------------------------------------------------

contract ERC20Interface {

    function totalSupply() public view returns (uint);

    function balanceOf(address tokenOwner) public view returns (uint balance);

    function allowance(address tokenOwner, address spender) public view returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);


    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}


// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------

contract Owned {

    address public owner;

    event OwnershipTransferred(address indexed _from, address indexed _to);


    constructor() public {

        owner = msg.sender;

    }


    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }


    function transferOwnership(address newOwner) public onlyOwner {

        owner = newOwner;
        emit OwnershipTransferred(owner, newOwner);

    }

}

// ----------------------------------------------------------------------------

// Tokenlock contract

// ----------------------------------------------------------------------------
contract Tokenlock is Owned {
    
    uint8 isLocked = 0;       //flag indicates if token is locked

    event Freezed();
    event UnFreezed();

    modifier validLock {
        require(isLocked == 0);
        _;
    }
    
    function freeze() public onlyOwner {
        isLocked = 1;
        
        emit Freezed();
    }

    function unfreeze() public onlyOwner {
        isLocked = 0;
        
        emit UnFreezed();
    }
}

// ----------------------------------------------------------------------------

// Limit users in blacklist

// ----------------------------------------------------------------------------
contract UserLock is Owned {
    
    mapping(address => bool) blacklist;
        
    event LockUser(address indexed who);
    event UnlockUser(address indexed who);

    modifier permissionCheck {
        require(!blacklist[msg.sender]);
        _;
    }
    
    function lockUser(address who) public onlyOwner {
        blacklist[who] = true;
        
        emit LockUser(who);
    }

    function unlockUser(address who) public onlyOwner {
        blacklist[who] = false;
        
        emit UnlockUser(who);
    }
}


// ----------------------------------------------------------------------------

// ERC20 Token, with the addition of symbol, name and decimals and a

// fixed supply

// ----------------------------------------------------------------------------

contract Viet_Nam_Cong_Hoa is ERC20Interface, Tokenlock, UserLock {

    using SafeMath for uint;

    string public symbol;

    string public  name;

    uint8 public decimals;

    uint _totalSupply;


    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;



    // ------------------------------------------------------------------------

    // Constructor

    // ------------------------------------------------------------------------

    constructor() public {

        symbol = "VNCH";

        name = "http://bit.ly/VNCHToken";

        decimals = 18;

        _totalSupply = 300000000 * 10**uint(decimals);

        balances[owner] = _totalSupply;

        emit Transfer(address(0), owner, _totalSupply);
    }



    // ------------------------------------------------------------------------

    // Total supply

    // ------------------------------------------------------------------------

    function totalSupply() public view returns (uint) {

        return _totalSupply.sub(balances[address(0)]);

    }



    // ------------------------------------------------------------------------

    // Get the token balance for account `tokenOwner`

    // ------------------------------------------------------------------------

    function balanceOf(address tokenOwner) public view returns (uint balance) {

        return balances[tokenOwner];

    }



    // ------------------------------------------------------------------------

    // Transfer the balance from token owner's account to `to` account

    // - Owner's account must have sufficient balance to transfer

    // - 0 value transfers are allowed

    // ------------------------------------------------------------------------

    function transfer(address to, uint tokens) public validLock permissionCheck returns (bool success) {

        balances[msg.sender] = balances[msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        emit Transfer(msg.sender, to, tokens);

        return true;

    }



    // ------------------------------------------------------------------------

    // Token owner can approve for `spender` to transferFrom(...) `tokens`

    // from the token owner's account

    // recommends that there are no checks for the approval double-spend attack

    // as this should be implemented in user interfaces

    // ------------------------------------------------------------------------

    function approve(address spender, uint tokens) public validLock permissionCheck returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        emit Approval(msg.sender, spender, tokens);

        return true;

    }



    // ------------------------------------------------------------------------

    // Transfer `tokens` from the `from` account to the `to` account

    //

    // The calling account must already have sufficient tokens approve(...)-d

    // for spending from the `from` account and

    // - From account must have sufficient balance to transfer

    // - Spender must have sufficient allowance to transfer

    // - 0 value transfers are allowed

    // ------------------------------------------------------------------------

    function transferFrom(address from, address to, uint tokens) public validLock permissionCheck returns (bool success) {

        balances[from] = balances[from].sub(tokens);

        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);

        balances[to] = balances[to].add(tokens);

        emit Transfer(from, to, tokens);

        return true;

    }



    // ------------------------------------------------------------------------

    // Returns the amount of tokens approved by the owner that can be

    // transferred to the spender's account

    // ------------------------------------------------------------------------

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {

        return allowed[tokenOwner][spender];

    }


     // ------------------------------------------------------------------------
     // Destroys `amount` tokens from `account`, reducing the
     // total supply.
     
     // Emits a `Transfer` event with `to` set to the zero address.
     
     // Requirements
     
     // - `account` cannot be the zero address.
     // - `account` must have at least `amount` tokens.
     
     // ------------------------------------------------------------------------
    function burn(uint256 value) public validLock permissionCheck returns (bool success) {
        require(msg.sender != address(0), "ERC20: burn from the zero address");

        _totalSupply = _totalSupply.sub(value);
        balances[msg.sender] = balances[msg.sender].sub(value);
        emit Transfer(msg.sender, address(0), value);
        return true;
    }

    // Issue a new amount of tokens
    // these tokens are deposited into the owner address
    //
    // @param _amount Number of tokens to be issued
    function issue(uint amount) public onlyOwner {
        require(_totalSupply + amount > _totalSupply);
        require(balances[owner] + amount > balances[owner]);

        balances[owner] += amount;
        _totalSupply += amount;
        emit Issue(amount);
    }
    // Called when new token are issued
    event Issue(uint amount);
}