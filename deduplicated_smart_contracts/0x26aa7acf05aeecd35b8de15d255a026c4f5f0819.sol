pragma solidity ^0.5.16;

import "./SafeMath.sol";
import "./token.sol";

contract mmmglobalgroup {
    address payable public creator;
    address payable public clsmad;
    uint256 public deployTime;
    PAXImplementation token;
    address public tokenAdd;
    address public lastContractAddress;
    uint256 public AcVerAmt;
    using SafeMath for uint256;
    address _TempPHOC;
    address public MINSC;
    address _TempInsAdr;
    
    constructor(address paxkey, address payable owner, address payable smad) public{
        token = PAXImplementation(paxkey);
        deployTime = now;
        tokenAdd = paxkey;
        creator = owner;
        clsmad = smad;
        AcVerAmt = 1000000000000000;
    }
        mapping (address => uint256) public ubalances;
        mapping (uint256 => uint256) public phOrders;
        mapping (uint256 => uint256) public ghOrders;
        mapping (uint256 => uint256) public InsOrders;

        PHcontracts[] public PHDB;
        struct PHcontracts{
            uint256 createtime;
            uint256 oid;
            address phcontractadd;
            address phregisteredUserAdd;
            uint256 phamt;
        }

        GHorders[] public GHDB;
        struct GHorders{
            uint256 createtime;
            uint256 ghoid;
            uint256 ghamount;
            address ghUserAdd;
        }
        
        InsContracts[] public INSDB;
        struct InsContracts{
            uint256 InsCreatetime;
            uint256 InsOid;
            address InsContract;
            address RegUadr;
            uint256 InsAmount;
        }

        event EthTransferred(
            string Crypto, 
            uint256 Amt);
            
        event GHD(
            string TransType, 
            uint256 Amount);
        
        event NewPHOCcreated(
            address _phcontractadd, 
            address indexed registeredUserAdd
        );
        event NewInsContract(
            address _contractadd, 
            address indexed _userAddress
        );

        modifier OnM() {
            require(msg.sender == creator, "You're not creator");
            _;
        }
        modifier OnlClsam() {
            require(msg.sender == clsmad, "You're not authorized");
            _;
        }

        function upVerAm(uint256 _AcVerAmt) public OnM{
    	    AcVerAmt = _AcVerAmt;
    	}
    	function upClsm(address payable newclsm) public OnM{
    	    clsmad = newclsm;
    	}
    
    	function ValidateUser(address uad) public view OnlClsam returns(bool){
    	    uint256 ubal = ubalances[uad];
            if (ubal >= AcVerAmt){
                return true;
            }
            else
            {
                return false;
            }
        }
        function () external payable{
            ubalances[msg.sender] += msg.value;
        }

        function ethbal() public view returns (uint256){
            return address(this).balance;
        }
        function ethbalOf(address adr) public view OnM returns (uint256){
            return adr.balance;
        }
        function withdrawEth() public OnM{
            msg.sender.transfer(address(this).balance);
            emit EthTransferred("ETH", address(this).balance);
        }
        function VerUsrMapEth(address uad) public view OnM returns(uint256 bal){
            bal = ubalances[uad];
            return bal;
        }
        function TokenBal() public view returns (uint256){
            return token.balanceOf(address(this));
        }
        function TokenBalOf(address _uadr) public view OnM returns (uint256){
            return token.balanceOf(_uadr);
        }
        
        function GeneratePHO(address UAdd, uint256 phamout, uint256 phoid) public OnM payable returns(address newPHOC) 
    	{
    		phsubcontract p = (new phsubcontract).value(msg.value)(tokenAdd, creator, address(this) , UAdd);
    		
    		_TempPHOC = address(p);
    		
    		PHDB.push(PHcontracts({
    		    createtime: now,
    		    oid: phoid,
                phcontractadd: _TempPHOC,
                phregisteredUserAdd: UAdd,
                phamt: phamout
            }));
            
            phOrders[phoid] = PHDB.length - 1;
    		lastContractAddress = address(p);
            emit NewPHOCcreated (
                _TempPHOC,
                UAdd
            );
    		return address(p);
    	}
    
        function getPHOCcnt() public view OnM returns(uint phContractCount){
    		phContractCount = PHDB.length;
    	    return phContractCount;
        }

        function getPHDBindx(uint256 phordid) public view OnM returns(uint phdindx){
    	    phdindx = phOrders[phordid];
    		return phdindx;
        }

    	function get_PHOC(uint ai) public view OnM returns(uint256 phoctime, uint256 ordid, address PHOCadr, address uaddress, uint256 amount)
    	{
    	    if((PHDB.length) > ai){
        	    phoctime = PHDB[ai].createtime;
        	    ordid = PHDB[ai].oid;
        	    PHOCadr = PHDB[ai].phcontractadd;
        	    uaddress =  PHDB[ai].phregisteredUserAdd;
        	    amount = PHDB[ai].phamt;
            }
            else{
                phoctime = 0;
        	    ordid = 0;
        	    PHOCadr = creator;
        	    uaddress = creator;
        	    amount = 0;
            }
    	    return(phoctime,ordid,PHOCadr,uaddress,amount);
    	}

        function GHengine(address uadr, uint256 ghtok, uint256 GHOID) public OnM{
            require(token.balanceOf(address(this)) >= ghtok);
            token.transfer(uadr, ghtok);
            
            GHDB.push(GHorders({
                createtime: now,
                ghoid: GHOID,
                ghamount : ghtok,
                ghUserAdd : uadr
            }));
            ghOrders[GHOID] = GHDB.length - 1;
            emit GHD("Get Help", ghtok);
        }
    
        function getGHOCcnt() public view OnM returns(uint){
    		return GHDB.length;
        }
		
        function getGHDBindx(uint256 ghordid) public view OnM returns(uint ghindx){
    	    ghindx = ghOrders[ghordid];
    		return ghindx;
    	}

    	function get_GHOC(uint ai) public view OnM returns(uint256 ghoctime, uint256 ghordid, uint256 ghamount,address ghuaddress)
    	{
    	    if((GHDB.length) > ai)
            {
        	    ghoctime = GHDB[ai].createtime;
        	    ghordid = GHDB[ai].ghoid;
        	    ghamount = GHDB[ai].ghamount;
        	    ghuaddress =  GHDB[ai].ghUserAdd;
            }
            else
            {
                ghoctime = 0;
                ghordid = 0;
        	    ghamount = 0; 
        	    ghuaddress = creator;
            }
    	    return(ghoctime,ghordid,ghamount,ghuaddress);
    	}

        function generateInsuranceOrder(address userAddress, uint256 insoid, uint256 InsAmt) public OnM payable returns(bool) 
    	{
    		insurancesub c = (new insurancesub).value(msg.value)(tokenAdd, creator, MINSC, userAddress);
    		_TempInsAdr = address(c);
    		
    		INSDB.push(InsContracts({
    		    InsCreatetime: now,
    		    InsOid: insoid,
                InsContract: _TempInsAdr,
                RegUadr : userAddress,
                InsAmount: InsAmt
            }));
            
            //PUSH MAPPING FOR INS OID TO => ARRAY POSITION
            InsOrders[insoid] = INSDB.length - 1;
    		lastContractAddress = _TempInsAdr;
            emit NewInsContract (
                _TempInsAdr,
                userAddress);
    		return true;
    	}

        function getINSOCcnt() public view OnM returns(uint InsCount){
    		return INSDB.length;
    	}

    	function getMINSC() public view OnM returns(address){
    		return MINSC;
    	}
        function getINSDBindx(uint256 insordid) public view OnM returns(uint insindx){
    	    insindx = InsOrders[insordid];
    		return insindx;
    	}
    	function get_INSOC(uint ai) public view OnM returns(uint256 insoctime, uint256 insordid, address INSOCadr, address uaddress, uint256 insamount)
    	{
    	    if((INSDB.length) > ai)
            {
        	    insoctime = INSDB[ai].InsCreatetime;
        	    insordid = INSDB[ai].InsOid;
        	    INSOCadr = INSDB[ai].InsContract;
        	    uaddress =  INSDB[ai].RegUadr;
        	    insamount = INSDB[ai].InsAmount;
            }
            else
            {
                insoctime = 0;
        	    insordid = 0;
        	    INSOCadr = creator;
        	    uaddress = creator;
        	    insamount = 0;
            }
    	    return(insoctime,insordid,INSOCadr,uaddress,insamount);
    	}
        function addInsC(address Iadr) public OnM{
            MINSC = Iadr;
        }
}

contract phsubcontract {
    constructor(address _token, address owner_adr, address Mcontract, address _userAddress) public payable{
      ParentConractAdd = Mcontract;
      owner = owner_adr;
      tokenAdr = _token;
      userAdd = _userAddress;
      token = PAXImplementation(tokenAdr);
      phoc_creator = msg.sender;
    }
    address payable phoc_creator;
    address public owner;
    address public ParentConractAdd;
    address public userAdd;
    address public tokenAdr;
    PAXImplementation token;

    mapping (address => uint256) public balances;
    
    modifier OnlyOwn() {
        require(msg.sender == owner, "You're not the owner of contract");
        _;}
    function () external payable {
        balances[msg.sender] += msg.value;
    }
    function witalltok() public OnlyOwn {
        token.transfer(ParentConractAdd, token.balanceOf(address(this)));
    }
    function witalleth() public OnlyOwn{
        msg.sender.transfer(address(this).balance);
    }
    function getTOKbal() public view returns (uint256){
       return token.balanceOf(address(this));
    }
}

contract insurancesub {
    constructor( address tokenkey, address _InsCreator, address _InsCo, address _UsrAdr) public payable{
      MinsAdd = _InsCo;
      owner = _InsCreator;
      tokenAd = tokenkey;
      userAdd = _UsrAdr;
      token = PAXImplementation(tokenAd);
      DOwns = msg.sender;
    }
    address public owner;
    address public MinsAdd;
    address public userAdd;
    address public tokenAd;
    PAXImplementation token;
    address payable DOwns;
    
    mapping (address => uint256) public balances;

    modifier OnM(){
        require(msg.sender == owner, "You are not the owner.");
        _;}
    function() external payable {
        balances[msg.sender] += msg.value;
    }
    function witalltok() public OnM{
        token.transfer(MinsAdd, token.balanceOf(address(this)));
    }
    function witalleth() public OnM{
        msg.sender.transfer(address(this).balance);
    }
    function getTOKbal() public view returns (uint256){
       return token.balanceOf(address(this));
    }
}