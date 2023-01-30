/**

 *Submitted for verification at Etherscan.io on 2018-10-19

*/



pragma solidity 0.4.25;



contract Packages {

  mapping (address => Package) packages;



  struct Package{

    uint8 releaseCount;

    Release[] releases;

  }



  struct Release {

    bytes32 checksum;

    string uri;

  }



  function newestURI(address dapp_address) constant public returns (string) {

    Package storage package = packages[dapp_address];

    return package.releases[package.releaseCount - 1].uri;

  }



  function newestChecksum(address dapp_address) constant public returns (bytes32) {

    Package storage package = packages[dapp_address];

    return package.releases[package.releaseCount - 1].checksum;

  }



  function versionURI(address dapp_address, uint8 release_id) constant public returns (string) {

    Package storage package = packages[dapp_address];

    return package.releases[release_id].uri;

  }



  function versionChecksum(address dapp_address, uint8 release_id) constant public returns (bytes32) {

    Package storage package = packages[dapp_address];

    return package.releases[release_id].checksum;

  }



  event NewRelease(address dapp_address);



  function createRelease(bytes32 checksum, string uri) public {

    Package storage package = packages[msg.sender];

    package.releases.push(Release(checksum, uri));

    package.releaseCount++;

    emit NewRelease(msg.sender);

  }



}