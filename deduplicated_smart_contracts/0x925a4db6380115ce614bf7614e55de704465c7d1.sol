/**

 *Submitted for verification at Etherscan.io on 2018-12-18

*/



pragma solidity ^0.4.24;



contract Gateway {

  address adminVault;

  address owner;



  constructor (address _adminVault) public {

      owner = msg.sender;

      require(_adminVault!=address(0));

      adminVault = _adminVault;

  }



  function sendEther(address _merchant, uint fee) public payable {

      require(msg.value>=fee && fee>=0);

      require(_merchant != address(0));



      _merchant.transfer(sub(msg.value, fee));

      adminVault.transfer(fee);

  }



  function updateAdminVault (address _newAdminVault) public {

      require(msg.sender == owner);

      require(_newAdminVault!=address(0));

      adminVault = _newAdminVault;

  }



  function sub(uint256 a, uint256 b) internal pure returns (uint256) {

      assert(b <= a);

      return a - b;

  }



  function getAdmin() public view returns (address)  {

      return adminVault;

  }



  function getOwner() public view returns (address) {

      return owner;

  }



  function transferOwnership(address _newOwner) public {

    require(msg.sender == owner);

    require(_newOwner!=address(0));

    owner=_newOwner;

  }

}