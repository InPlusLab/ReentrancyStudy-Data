/**

 *Submitted for verification at Etherscan.io on 2019-01-01

*/



pragma solidity ^0.4.18;



// ----------------------------------------------------------------------------

// 'GAILLARD' token contract

//

// Deployed to : 0x7f7195aCE303Fc55E70522B31Df6502C5dfb825A

// Symbol      : BG

// Name        : Gaillard

// Total supply: 40268

// Decimals    : 18

//

// Enjoy.

//

// (c) by Blackmore Toporowski Poncharal / SMOM Inc Toronto Canada and J. Poncharal consultant

/*

// gaillard                                     

évaluation : pour le territoire de la ville de brive, ca supplémentaire  sur 5 ans   pour fond investissement économie ess 15%   (0,15)        base:

production équipements solaires renouvelables et produits induits de la sarl lurçat    soit       5% économie par an sur 5 ans : 5% de part   (0,0025) - 130€ le m² soit 325000€ comme cible sur 5 ans construit -                      4062,5 €

points Cuma transfert de l' origine pétrole au solaire à 5 ans    :                              15000 €              

points Cuma sur produits Bureau sur 5 ans et 5% ca supplémentaire par an     :                   1875 €            base ca 5 ans: 150000€

points Cuma sur produits origine bio et local (biocoop etc) et 5% ca supplémentaire par an  :    3125 €               

produits origine brive (artisanat, vetement otego, denoy…)      5% ca supplémentaire par an   :  3125 €            id:   250000€

entreprises RSE brive label (site plateforme citoyenne )       5% ca supplémenatire par an    :  1875 €            id:   150000€

valeur usage terrains j poncharal Tarnac Vigeois Puymège      50% spécifiquement pour serres solaires et production cresson et figuiers      50%  soit : 3000 €              

augmentation recyclage plastique brive (mesure ipvmp) et appli de tri (collecte etc) 5% par an   875 €          id:  70000€

 ca sarl lurcat et entreprises liées        1% sur ca   1%         par an :                     1080 €          id: 108000€

batiments énergie positive brive                                    10% par an :                6250 €          id: 500000€

prévention santé (domotique, oc, sports, gym…)              5% par an                           1125 €         id: 13500 €

                                                                                 total:        40267,5 €         

valeur recherchée via émission ou rachat (modèle basis) et à la condition d'atteinte minimale des objectifs ci-dessus sur 5 ans, arrondi à 40268€                        

----------------------------------------------------------------------------



*/

// ----------------------------------------------------------------------------

// Safe maths

// ----------------------------------------------------------------------------

contract SafeMath {

    function safeAdd(uint a, uint b) public pure returns (uint c) {

        c = a + b;

        require(c >= a);

    }

    function safeSub(uint a, uint b) public pure returns (uint c) {

        require(b <= a);

        c = a - b;

    }

    function safeMul(uint a, uint b) public pure returns (uint c) {

        c = a * b;

        require(a == 0 || c / a == b);

    }

    function safeDiv(uint a, uint b) public pure returns (uint c) {

        require(b > 0);

        c = a / b;

    }

}





// ----------------------------------------------------------------------------

// ERC Token Standard #20 Interface

// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md

// ----------------------------------------------------------------------------

contract ERC20Interface {

    function totalSupply() public constant returns (uint);

    function balanceOf(address tokenOwner) public constant returns (uint balance);

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);

    function transfer(address to, uint tokens) public returns (bool success);

    function approve(address spender, uint tokens) public returns (bool success);

    function transferFrom(address from, address to, uint tokens) public returns (bool success);



    event Transfer(address indexed from, address indexed to, uint tokens);

    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

}





// ----------------------------------------------------------------------------

// Contract function to receive approval and execute function in one call

//

// Borrowed from MiniMeToken

// ----------------------------------------------------------------------------

contract ApproveAndCallFallBack {

    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;

}





// ----------------------------------------------------------------------------

// Owned contract

// ----------------------------------------------------------------------------

contract Owned {

    address public owner;

    address public newOwner;



    event OwnershipTransferred(address indexed _from, address indexed _to);



    function Owned() public {

        owner = msg.sender;

    }



    modifier onlyOwner {

        require(msg.sender == owner);

        _;

    }



    function transferOwnership(address _newOwner) public onlyOwner {

        newOwner = _newOwner;

    }

    function acceptOwnership() public {

        require(msg.sender == newOwner);

        OwnershipTransferred(owner, newOwner);

        owner = newOwner;

        newOwner = address(0);

    }

}





// ----------------------------------------------------------------------------

// ERC20 Token, with the addition of symbol, name and decimals and assisted

// token transfers

// ----------------------------------------------------------------------------

contract GaillardToken is ERC20Interface, Owned, SafeMath {

    string public symbol;

    string public  name;

    uint8 public decimals;

    uint public _totalSupply;



    mapping(address => uint) balances;

    mapping(address => mapping(address => uint)) allowed;





    // ------------------------------------------------------------------------

    // Constructor

    // ------------------------------------------------------------------------

    function GaillardToken() public {

        symbol = "BG";

        name = "Gaillard";

        decimals = 18;

        _totalSupply = 40268000000000000000000;

        balances[0x7f7195aCE303Fc55E70522B31Df6502C5dfb825A] = _totalSupply;

        Transfer(address(0), 0x7f7195aCE303Fc55E70522B31Df6502C5dfb825A, _totalSupply);

    }





    // ------------------------------------------------------------------------

    // Total supply

    // ------------------------------------------------------------------------

    function totalSupply() public constant returns (uint) {

        return _totalSupply  - balances[address(0)];

    }





    // ------------------------------------------------------------------------

    // Get the token balance for account tokenOwner

    // ------------------------------------------------------------------------

    function balanceOf(address tokenOwner) public constant returns (uint balance) {

        return balances[tokenOwner];

    }





    // ------------------------------------------------------------------------

    // Transfer the balance from token owner's account to to account

    // - Owner's account must have sufficient balance to transfer

    // - 0 value transfers are allowed

    // ------------------------------------------------------------------------

    function transfer(address to, uint tokens) public returns (bool success) {

        balances[msg.sender] = safeSub(balances[msg.sender], tokens);

        balances[to] = safeAdd(balances[to], tokens);

        Transfer(msg.sender, to, tokens);

        return true;

    }





    // ------------------------------------------------------------------------

    // Token owner can approve for spender to transferFrom(...) tokens

    // from the token owner's account

    //

    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md

    // recommends that there are no checks for the approval double-spend attack

    // as this should be implemented in user interfaces 

    // ------------------------------------------------------------------------

    function approve(address spender, uint tokens) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        Approval(msg.sender, spender, tokens);

        return true;

    }





    // ------------------------------------------------------------------------

    // Transfer tokens from the from account to the to account

    // 

    // The calling account must already have sufficient tokens approve(...)-d

    // for spending from the from account and

    // - From account must have sufficient balance to transfer

    // - Spender must have sufficient allowance to transfer

    // - 0 value transfers are allowed

    // ------------------------------------------------------------------------

    function transferFrom(address from, address to, uint tokens) public returns (bool success) {

        balances[from] = safeSub(balances[from], tokens);

        allowed[from][msg.sender] = safeSub(allowed[from][msg.sender], tokens);

        balances[to] = safeAdd(balances[to], tokens);

        Transfer(from, to, tokens);

        return true;

    }





    // ------------------------------------------------------------------------

    // Returns the amount of tokens approved by the owner that can be

    // transferred to the spender's account

    // ------------------------------------------------------------------------

    function allowance(address tokenOwner, address spender) public constant returns (uint remaining) {

        return allowed[tokenOwner][spender];

    }





    // ------------------------------------------------------------------------

    // Token owner can approve for spender to transferFrom(...) tokens

    // from the token owner's account. The spender contract function

    // receiveApproval(...) is then executed

    // ------------------------------------------------------------------------

    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {

        allowed[msg.sender][spender] = tokens;

        Approval(msg.sender, spender, tokens);

        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);

        return true;

    }





    // ------------------------------------------------------------------------

    // Don't accept ETH

    // ------------------------------------------------------------------------

    function () public payable {

        revert();

    }





    // ------------------------------------------------------------------------

    // Owner can transfer out any accidentally sent ERC20 tokens

    // ------------------------------------------------------------------------

    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {

        return ERC20Interface(tokenAddress).transfer(owner, tokens);

    }

}