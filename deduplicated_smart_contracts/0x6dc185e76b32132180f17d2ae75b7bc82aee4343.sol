/**

 *Submitted for verification at Etherscan.io on 2018-10-28

*/



pragma solidity ^0.4.24;



// File: openzeppelin-solidity/contracts/ownership/Ownable.sol



/**

 * 

Ownable contract  comes from

https://github.com/OpenZeppelin/openzeppelin-solidity/blob/master/contracts/ownership/Ownable.sol

and is Licensed under MIT license 



All other contracts are Created by 

Łukasz Grynasz https://www.linkedin.com/in/%C5%82ukasz-grynasz-aba24b55/

Adam Skrodzki https://www.linkedin.com/in/adam-skrodzki-521051b/



as a part of https://pway.io project



 * @title Ownable

 * @dev The Ownable contract has an owner address, and provides basic authorization control

 * functions, this simplifies the implementation of "user permissions".

 */

contract Ownable {

  address public owner;





  event OwnershipRenounced(address indexed previousOwner);

  event OwnershipTransferred(

    address indexed previousOwner,

    address indexed newOwner

  );





  /**

   * @dev The Ownable constructor sets the original `owner` of the contract to the sender

   * account.

   */

  constructor() public {

    owner = msg.sender;

  }



  /**

   * @dev Throws if called by any account other than the owner.

   */

  modifier onlyOwner() {

    require(msg.sender == owner);

    _;

  }



  /**

   * @dev Allows the current owner to relinquish control of the contract.

   * @notice Renouncing to ownership will leave the contract without an owner.

   * It will not be possible to call the functions with the `onlyOwner`

   * modifier anymore.

   */

  function renounceOwnership() public onlyOwner {

    emit OwnershipRenounced(owner);

    owner = address(0);

  }



  /**

   * @dev Allows the current owner to transfer control of the contract to a newOwner.

   * @param _newOwner The address to transfer ownership to.

   */

  function transferOwnership(address _newOwner) public onlyOwner {

    _transferOwnership(_newOwner);

  }



  /**

   * @dev Transfers control of the contract to a newOwner.

   * @param _newOwner The address to transfer ownership to.

   */

  function _transferOwnership(address _newOwner) internal {

    require(_newOwner != address(0));

    emit OwnershipTransferred(owner, _newOwner);

    owner = _newOwner;

  }

}



// File: contracts\PwayContract.sol



contract PwayContract is Ownable {



    modifier onlyHuman(address addr){

        uint size;

        assembly { size := extcodesize(addr) } // solium-disable-line

        if(size == 0){

            _;

        }else{

            revert("Provided address is a contract");

        }

    }

    

}



// File: contracts\NameRegistry.sol



contract NameRegistry is PwayContract {



    event EntrySet(string entry,address adr);



    mapping(string => address) names;

  

    function hasAddress(string name) public view returns(bool) {

        return names[name] != address(0);

    }

    

    function getAddress(string name) public view returns(address) {

        require(names[name] != address(0), "Address could not be 0x0");

        return names[name];

    }

    

    function setAddress(string name, address _adr) public {

        require(_adr != address(0), "Address could not be 0x0");



        bytes memory nameBytes = bytes(name);

        require(nameBytes.length > 0, "Name could not be empty");



        bool isEmpty = names[name] == address(0);



        //can be initialized by everyone , but only change by itself

        require(isEmpty || names[name] == msg.sender);



        names[name] = _adr;

        emit EntrySet(name, names[name]);

    } 

  

}



// File: contracts\rateProviders\IProvider.sol



interface IEthRateProvider

{

	

	function getETHUSDRate() view public returns(uint256);

	function changeProvider(NameRegistry _reg,address _newProvider) ;

}



// File: contracts\rateProviders\OasisDexProvider.sol



interface IDex{

	function getBuyAmount(address buy_gem, address pay_gem, uint256 pay_amt) returns (uint256);

}



contract OasisDexProvider is PwayContract

{



	address public dex;//0x14FBCA95be7e99C15Cc2996c6C9d841e54B79425  

	address public dai;//0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359  

	address public weth;//0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2



	

	NameRegistry reg;



	constructor(NameRegistry _reg,address dexAddress,address daiTokenAddress,address wethAddress){

		reg = _reg;	

		_reg.setAddress("EthRateProvider",address(this));

		dex=dexAddress;

		dai=daiTokenAddress;

		weth=wethAddress;

	}

	

	function getETHUSDRate() view public returns(uint256){

		return IDex(dex).getBuyAmount(dai,weth,1);

	}



	function changeProvider(NameRegistry _reg,address _newProvider) onlyOwner{

		require(IEthRateProvider(_newProvider).getETHUSDRate()!=0);

		_reg.setAddress("EthRateProvider",_newProvider);

	}

}