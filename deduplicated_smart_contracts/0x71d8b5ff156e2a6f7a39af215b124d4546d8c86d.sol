/**
 *Submitted for verification at Etherscan.io on 2019-08-04
*/

pragma solidity ^0.5.10;

contract Trusti{
    struct Asset{
		string assetHash;
		string siteName;
        string assetSignee;
    }
	event LogAssetAdded(string assetHash, string assetSignee, string site);
    event LogNewOraclizeQuery(string description);
    mapping(bytes32 => bytes32 ) validIdstoSite;
    mapping (address => Asset[]) siteToAssets;
    mapping (string => Asset[]) assetHashToAssets;
    
    constructor()public
	{
        userAddAssets("Blockchain based data certification","trusti.id");
    }
    
	function userAddAssets(string memory _assetHash, string memory _assetSignee) public{
        Asset memory _asset = Asset({
            assetHash: _assetHash,
            siteName: "trusti.id",
            assetSignee: _assetSignee
            });
        siteToAssets[msg.sender].push(_asset);
        assetHashToAssets[_assetHash].push(_asset);
    }
    
	function searchAsset(string memory dataHash, uint id) public view returns(string memory, string memory) {
        return (
                assetHashToAssets[dataHash][id].assetHash,
                assetHashToAssets[dataHash][id].assetSignee
        );
    }
}