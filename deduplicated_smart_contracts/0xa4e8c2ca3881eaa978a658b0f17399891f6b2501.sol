/**

 *Submitted for verification at Etherscan.io on 2018-10-31

*/



pragma solidity ^0.4.21;



// Project: casinoico.io

// v11, 2018-08-10

// This code is the property of CryptoB2B.io

// Copying in whole or in part is prohibited.

// Authors: Ivan Fedorov and Dmitry Borodin

// Do you want the same TokenSale platform? www.cryptob2b.io



contract IToken{

    function setUnpausedWallet(address _wallet, bool mode) public;

    function mint(address _to, uint256 _amount) public returns (bool);

    function totalSupply() public view returns (uint256);

    function setPause(bool mode) public;

    function setMigrationAgent(address _migrationAgent) public;

    function migrateAll(address[] _holders) public;

    function markTokens(address _beneficiary, uint256 _value) public;

    function freezedTokenOf(address _beneficiary) public view returns (uint256 amount);

    function defrostDate(address _beneficiary) public view returns (uint256 Date);

    function freezeTokens(address _beneficiary, uint256 _amount, uint256 _when) public;

}



contract IFinancialStrategy{



    enum State { Active, Refunding, Closed }

    State public state = State.Active;



    event Deposited(address indexed beneficiary, uint256 weiAmount);

    event Receive(address indexed beneficiary, uint256 weiAmount);

    event Refunded(address indexed beneficiary, uint256 weiAmount);

    event Started();

    event Closed();

    event RefundsEnabled();

    function freeCash() view public returns(uint256);

    function deposit(address _beneficiary) external payable;

    function refund(address _investor) external;

    function setup(uint8 _state, bytes32[] _params) external;

    function getBeneficiaryCash() external;

    function getPartnerCash(uint8 _user, address _msgsender) external;

}



contract IRightAndRoles {

    address[][] public wallets;

    mapping(address => uint16) public roles;



    event WalletChanged(address indexed newWallet, address indexed oldWallet, uint8 indexed role);

    event CloneChanged(address indexed wallet, uint8 indexed role, bool indexed mod);



    function changeWallet(address _wallet, uint8 _role) external;

    function setManagerPowerful(bool _mode) external;

    function onlyRoles(address _sender, uint16 _roleMask) view external returns(bool);

}



contract IAllocation {

    function addShare(address _beneficiary, uint256 _proportion, uint256 _percenForFirstPart) external;

}



contract ICreator{

    IRightAndRoles public rightAndRoles;

    function createAllocation(IToken _token, uint256 _unlockPart1, uint256 _unlockPart2) external returns (IAllocation);

    function createFinancialStrategy() external returns(IFinancialStrategy);

    function getRightAndRoles() external returns(IRightAndRoles);

}



contract GuidedByRoles {

    IRightAndRoles public rightAndRoles;

    function GuidedByRoles(IRightAndRoles _rightAndRoles) public {

        rightAndRoles = _rightAndRoles;

    }

}



/**

 * @title SafeMath

 * @dev Math operations with safety checks that throw on error

 */

library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {

        if (a == 0) {

            return 0;

        }

        uint256 c = a * b;

        assert(c / a == b);

        return c;

    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a / b;

        return c;

    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {

        assert(b <= a);

        return a - b;

    }

    function add(uint256 a, uint256 b) internal pure returns (uint256) {

        uint256 c = a + b;

        assert(c >= a);

        return c;

    }

    function minus(uint256 a, uint256 b) internal pure returns (uint256) {

        if (b>=a) return 0;

        return a - b;

    }

}



/**

 * @title ERC20Basic

 * @dev Simpler version of ERC20 interface

 * @dev see https://github.com/ethereum/EIPs/issues/179

 * This code is taken from openZeppelin without any changes.

 */

contract ERC20Basic {

    function totalSupply() public view returns (uint256);

    function balanceOf(address who) public view returns (uint256);

    function transfer(address to, uint256 value) public returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

}



contract ERC20Provider is GuidedByRoles {

    function transferTokens(ERC20Basic _token, address _to, uint256 _value) public returns (bool){

        require(rightAndRoles.onlyRoles(msg.sender,2));

        return _token.transfer(_to,_value);

    }

}



contract FinancialStrategy is IFinancialStrategy, GuidedByRoles,ERC20Provider{

    using SafeMath for uint256;



    uint8 public step;



    mapping (uint8 => mapping (address => uint256)) public deposited;



    uint256[1] public percent = [10];

    uint256[1] public cap = [0]; // QUINTILLIONS (0 - no limits)

    uint256[1] public debt = [0];

    uint256[1] public total = [0]; // QUINTILLIONS

    uint256[1] public took = [0];

    uint256[1] public ready = [0];



    address[1] public wallets = [0xB9B2350EF14123C9bA6924c0c00B47909ab7d2D2];



    uint256 public benTook=0;

    uint256 public benReady=0;

    uint256 public newCash=0;

    uint256 public cashHistory=0;



    address public benWallet=0;



    modifier canGetCash(){

        //require(state == State.Closed);

        _;

    }



    function FinancialStrategy(IRightAndRoles _rightAndRoles) GuidedByRoles(_rightAndRoles) public {

        emit Started();

    }



    function balance() external view returns(uint256){

        return address(this).balance;

    }



    

    function deposit(address _investor) external payable {

        require(rightAndRoles.onlyRoles(msg.sender,1));

        require(state == State.Active);

        deposited[step][_investor] = deposited[step][_investor].add(msg.value);

        newCash = newCash.add(msg.value);

        cashHistory += msg.value;

        emit Deposited(_investor,msg.value);

    }





    // 0 - destruct

    // 1 - close

    // 2 - restart

    // 3 - refund

    // 4 - calc

    // 5 - update Exchange                                                                      

    function setup(uint8 _state, bytes32[] _params) external {

        require(rightAndRoles.onlyRoles(msg.sender,1));



        if (_state == 0)  {

            require(_params.length == 1);

            // call from Crowdsale.distructVault(true) for exit

            // arg1 - nothing

            // arg2 - nothing

            selfdestruct(address(_params[0]));



        }

        else if (_state == 1 ) {

            require(_params.length == 0);

            // Call from Crowdsale.finalization()

            //   [1] - successfull round (goalReach)

            //   [3] - failed round (not enough money)

            // arg1 = weiTotalRaised();

            // arg2 = nothing;

        

            require(state == State.Active);

            //internalCalc(_arg1);

            state = State.Closed;

            emit Closed();

        

        }

        else if (_state == 2) {

            require(_params.length == 0);

            // Call from Crowdsale.initialization()

            // arg1 = weiTotalRaised();

            // arg2 = nothing;

            require(state == State.Closed);

            require(address(this).balance == 0);

            state = State.Active;

            step++;

            emit Started();

        

        }

        else if (_state == 3 ) {

            require(_params.length == 0);

            require(state == State.Active);

            state = State.Refunding;

            emit RefundsEnabled();

        }

        else if (_state == 4) {

            require(_params.length == 2);

            //onlyPartnersOrAdmin(address(_params[1]));

            internalCalc(uint256(_params[0]));

        }

        else if (_state == 5) {

            // arg1 = old ETH/USD (exchange)

            // arg2 = new ETH/USD (_ETHUSD)

            require(_params.length == 2);

            for (uint8 user=0; user<cap.length; user++) cap[user]=cap[user].mul(uint256(_params[0])).div(uint256(_params[1]));

        }



    }



    function freeCash() view public returns(uint256){

        return newCash+benReady;

    }



    function internalCalc(uint256 _allValue) internal {



        uint256 free=newCash+benReady;

        uint256 common=0;

        uint256 prcSum=0;

        uint256 plan=0;

        uint8[] memory indexes = new uint8[](percent.length);

        uint8 count = 0;



        if (free==0) return;



        uint8 i;



        for (i =0; i <percent.length; i++) {

            plan=_allValue*percent[i]/100;



            if(cap[i] != 0 && plan > cap[i]) plan = cap[i];



            if (total[i] >= plan) {

                debt[i]=0;

                continue;

            }



            plan -= total[i];

            debt[i] = plan;

            common += plan;

            indexes[count++] = i;

            prcSum += percent[i];

        }

        if(common > free){

            benReady = 0;

            uint8 j = 0;

            while (j < count){

                i = indexes[j++];

                plan = free*percent[i]/prcSum;

                if(plan + total[i] <= cap[i] || cap[i] ==0){

                    debt[i] = plan;

                    continue;

                }

                debt[i] = cap[i] - total[i]; //'total' is always less than 'cap'

                free -= debt[i];

                prcSum -= percent[i];

                indexes[j-1] = indexes[--count];

                j = 0;

            }

        }

        common = 0;

        for(i = 0; i < debt.length; i++){

            total[i] += debt[i];

            ready[i] += debt[i];

            common += ready[i];

        }

        benReady = address(this).balance - common;

        newCash = 0;

    }



    function refund(address _investor) external {

        require(state == State.Refunding);

        uint256 depositedValue = deposited[step][_investor];

        require(depositedValue > 0);

        deposited[step][_investor] = 0;

        _investor.transfer(depositedValue);

        emit Refunded(_investor, depositedValue);

    }



    // Call from Crowdsale:

    function getBeneficiaryCash() external canGetCash {

        require(rightAndRoles.onlyRoles(msg.sender,1));

        address _beneficiary = rightAndRoles.wallets(2,0);

        uint256 move=benReady;

        benWallet=_beneficiary;

        if (move == 0) return;



        emit Receive(_beneficiary, move);

        benReady = 0;

        benTook += move;

        

        _beneficiary.transfer(move);

    

    }





    // Call from Crowdsale:

    function getPartnerCash(uint8 _user, address _msgsender) external canGetCash {

        require(rightAndRoles.onlyRoles(msg.sender,1));

        require(_user<wallets.length);



        onlyPartnersOrAdmin(_msgsender);



        uint256 move=ready[_user];

        if (move==0) return;



        emit Receive(wallets[_user], move);

        ready[_user]=0;

        took[_user]+=move;



        wallets[_user].transfer(move);

    

    }



    function onlyPartnersOrAdmin(address _sender) internal view {

        if (!rightAndRoles.onlyRoles(_sender,65535)) {

            for (uint8 i=0; i<wallets.length; i++) {

                if (wallets[i]==_sender) break;

            }

            if (i>=wallets.length) {

                revert();

            }

        }

    }

}



contract RightAndRoles is IRightAndRoles {

    bool managerPowerful = true;



    function RightAndRoles(address[] _roles) public {

        uint8 len = uint8(_roles.length);

        require(len > 0&&len <16);

        wallets.length = len;



        for(uint8 i = 0; i < len; i++){

            wallets[i].push(_roles[i]);

            roles[_roles[i]] += uint16(2)**i;

            emit WalletChanged(_roles[i], address(0),i);

        }

    }



    function changeClons(address _clon, uint8 _role, bool _mod) external {

        require(wallets[_role][0] == msg.sender&&_clon != msg.sender);

        emit CloneChanged(_clon,_role,_mod);

        uint16 roleMask = uint16(2)**_role;

        if(_mod){

            require(roles[_clon]&roleMask == 0);

            wallets[_role].push(_clon);

        }else{

            address[] storage tmp = wallets[_role];

            uint8 i = 1;

            for(i; i < tmp.length; i++){

                if(tmp[i] == _clon) break;

            }

            require(i > tmp.length);

            tmp[i] = tmp[tmp.length];

            delete tmp[tmp.length];

        }

        roles[_clon] = _mod?roles[_clon]|roleMask:roles[_clon]&~roleMask;

    }



    // Change the address for the specified role.

    // Available to any wallet owner except the observer.

    // Available to the manager until the round is initialized.

    // The Observer's wallet or his own manager can change at any time.

    // @ Do I have to use the function      no

    // @ When it is possible to call        depend...

    // @ When it is launched automatically  -

    // @ Who can call the function          staff (all 7+ roles)

    function changeWallet(address _wallet, uint8 _role) external {

        require(wallets[_role][0] == msg.sender || wallets[0][0] == msg.sender || (wallets[1][0] == msg.sender && (managerPowerful || _role == 0)));

        emit WalletChanged(wallets[_role][0],_wallet,_role);

        uint16 roleMask = uint16(2)**_role;

        address[] storage tmp = wallets[_role];

        for(uint8 i = 0; i < tmp.length; i++){

            roles[tmp[i]] = roles[tmp[i]]&~roleMask;

        }

        delete  wallets[_role];

        tmp.push(_wallet);

        roles[_wallet] = roles[_wallet]|roleMask;

    }



    function setManagerPowerful(bool _mode) external {

        require(wallets[0][0] == msg.sender);

        managerPowerful = _mode;

    }



    function onlyRoles(address _sender, uint16 _roleMask) view external returns(bool) {

        return roles[_sender]&_roleMask != 0;

    }



    function getMainWallets() view external returns(address[]){

        address[] memory _wallets = new address[](wallets.length);

        for(uint8 i = 0; i<wallets.length; i++){

            _wallets[i] = wallets[i][0];

        }

        return _wallets;

    }



    function getCloneWallets(uint8 _role) view external returns(address[]){

        return wallets[_role];

    }

}



// (B)

// The contract for freezing tokens for the team..

contract Allocation is GuidedByRoles, IAllocation {

    using SafeMath for uint256;



    struct Share {

        uint256 proportion;

        uint256 forPart;

    }



    // How many days to freeze from the moment of finalizing ICO

    uint256 public unlockPart1;

    uint256 public unlockPart2;

    uint256 public totalShare;



    mapping(address => Share) public shares;



    ERC20Basic public token;



    // The contract takes the ERC20 coin address from which this contract will work and from the

    // owner (Team wallet) who owns the funds.

    function Allocation(IRightAndRoles _rightAndRoles,ERC20Basic _token, uint256 _unlockPart1, uint256 _unlockPart2) GuidedByRoles(_rightAndRoles) public{

        unlockPart1 = _unlockPart1;

        unlockPart2 = _unlockPart2;

        token = _token;

    }



    function addShare(address _beneficiary, uint256 _proportion, uint256 _percenForFirstPart) external {

        require(rightAndRoles.onlyRoles(msg.sender,1));

        shares[_beneficiary] = Share(shares[_beneficiary].proportion.add(_proportion),_percenForFirstPart);

        totalShare = totalShare.add(_proportion);

    }



    //    function unlock() external {

    //        unlockFor(msg.sender);

    //    }



    // If the time of freezing expired will return the funds to the owner.

    function unlockFor(address _owner) public {

        require(now >= unlockPart1);

        uint256 share = shares[_owner].proportion;

        if (now < unlockPart2) {

            share = share.mul(shares[_owner].forPart)/100;

            shares[_owner].forPart = 0;

        }

        if (share > 0) {

            uint256 unlockedToken = token.balanceOf(this).mul(share).div(totalShare);

            shares[_owner].proportion = shares[_owner].proportion.sub(share);

            totalShare = totalShare.sub(share);

            token.transfer(_owner,unlockedToken);

        }

    }

}



contract Creator is ICreator{



    function Creator() public{

        address[] memory tmp = new address[](8);

        //Crowdsale.

        tmp[0] = address(this);

        //manager

        tmp[1] = msg.sender;

        //beneficiary

        tmp[2] = 0x110c6Ad53EDD6D3E7df115e73e38CF5aF6394061;

        // Accountant

        // Receives all the tokens for non-ETH investors (when finalizing Round1 & Round2)

        tmp[3] = 0xDB3DA0644907a2D5D5f8C2DAe7Bd4589FDCBa16E;

        // Observer

        // Has only the right to call paymentsInOtherCurrency (please read the document)

        tmp[4] = 0x8a91aC199440Da0B45B2E278f3fE616b1bCcC494;

        // Bounty - 2% tokens

        tmp[5] = 0xb1C8C72dC76080E6cA557d0D9820821F1B397a93;

        // Company - 10% tokens

        tmp[6] = 0x6d84Ac0BdFb815EB38CA49deE0D856ba10e1CE67;

        // Team - 11% tokens, freeze 1 year

        tmp[7] = 0x9C7B511e20eB7bd2d2435AeB9e32BB166769f9A6;

        rightAndRoles = new RightAndRoles(tmp);

    }



    function createAllocation(IToken _token, uint256 _unlockPart1, uint256 _unlockPart2) external returns (IAllocation) {

        Allocation allocation = new Allocation(rightAndRoles,ERC20Basic(_token),_unlockPart1,_unlockPart2);

        return allocation;

    }



    function createFinancialStrategy() external returns(IFinancialStrategy) {

        return new FinancialStrategy(rightAndRoles);

    }



    function getRightAndRoles() external returns(IRightAndRoles){

        rightAndRoles.changeWallet(msg.sender,0);

        return rightAndRoles;

    }

}