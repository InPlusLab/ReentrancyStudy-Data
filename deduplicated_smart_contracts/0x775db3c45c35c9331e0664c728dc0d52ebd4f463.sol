/**
 *Submitted for verification at Etherscan.io on 2019-08-04
*/

pragma solidity ^0.5.10;

contract Trusti {
    struct Asset {
    string name;
    string datahash;
    address manufacturer;
    bool initialized;    
         }
         
    struct tracking {
    address location;
    string uuid;
          }
    mapping(string => tracking) locations;
    mapping(string  => Asset) private assetStore;

      event AssetCreate(address manufacturer, string uuid, address location);
      event AssetTransfer(address from, address to, string uuid);

      function createAsset(string memory name, string memory datahash, string memory uuid) public {
      require(!assetStore[uuid].initialized, "Asset With This UUID Already Exists");
 
      assetStore[uuid] = Asset(name, datahash, msg.sender,true);
      locations[uuid] = tracking(msg.sender, uuid);
      emit AssetCreate(msg.sender, uuid, msg.sender);
                }
                
       function transferAsset(address to, string memory uuid) public {
         require(locations[uuid].location==msg.sender, "You are Not Authorized to Transfer This Asset");
         
        locations[uuid]= tracking(to, uuid);
        emit AssetTransfer(msg.sender, to, uuid);
               }
               
          function getAssetDetails(string memory uuid)public view returns (string memory,string memory,address) {
 
               return (assetStore[uuid].name, assetStore[uuid].datahash, assetStore[uuid].manufacturer);
                   }
          function getAssetLocation(string memory uuid)public view returns (address) {
 
            return (locations[uuid].location);
                  }

         
       }