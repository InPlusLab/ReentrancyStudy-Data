/**

 *Submitted for verification at Etherscan.io on 2019-03-31

*/



pragma solidity ^0.4.20;



contract ERC721 {

   //与ERC20兼容的接口

   function name() constant returns (string name);

   function symbol() constant returns (string symbol);

   function totalSupply() constant returns (uint256 totalSupply);

   function balanceOf(address _owner) constant returns (uint balance);

   //所有权相关的接口

   function ownerOf(uint256 _tokenId) constant returns (address owner);

   function approve(address _to, uint256 _tokenId);

   function takeOwnership(uint256 _tokenId);

   function transfer(address _to, uint256 _tokenId);

   function tokenOfOwnerByIndex(address _owner, uint256 _index) constant returns (uint tokenId);

   //通证元数据接口

   function tokenMetadata(uint256 _tokenId) constant returns (string infoUrl);

   //事件

   event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);

   event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

}



contract ERC721_publish {

  //name - 名称 该函数应当返回通证的名称

  function name() constant returns(string name){

    return "Ting Yu Token";  

  }



  //Symbol - 符号 该函数应当返回通证的符号，它有助于提高与ERC20的兼容性。

  function symbol() constant returns(string symbol){

    return "TYT";

  }

  

  //总发行量 该函数应当返回区块链上供应的通证总数量，该数量不一定是固定不变的。

  uint256 private tokenTotalSupply = 1000000000;

  function totalSupply() constant returns (uint256 supply){

    return tokenTotalSupply;

  }



  //balanceOf - 余额 该函数用于查询某一地址里的通证余额。例如：

  mapping(address => uint) private balances;

  function balanceOf(address _owner) constant returns(uint balance){ 

    return balances[_owner];

  }



  //ownerOf - 持币人

  //该函数返回通证持有人的地址。因为每一个ERC721通证都是不可替代的，因此可以在区块链上 唯一的地址找到，我们可以用通证的ID来确定其持有人。

  mapping(uint256 => address) private tokenOwners;

  mapping(uint256 => bool) private tokenExists;

  function ownerOf(uint256 _tokenId) constant returns (address owner) {

    require(tokenExists[_tokenId]);

    return tokenOwners[_tokenId];

  }



  //approve - 授权

  //该函数用来授权给另一主体代表持有人进行通证转移操作。

  //例如，假设Alice有一个ERC721通证,她可以 调用approve函数来授权给她的朋友Bob，然后Bob就可以代表Alice行使通证持有人的权利。

  mapping(address => mapping (address=> uint256)) allowed;

  function approve(address _to, uint256 _tokenId){

    require(msg.sender ==ownerOf(_tokenId));

    require(msg.sender != _to);

   

    allowed[msg.sender][_to] = _tokenId;

    Approval(msg.sender, _to, _tokenId);

  }



  //takeOwnership - 获取

  //该函数类似于取款功能，一个外部主体通过调用takeOwnership函数来从另一个用户的账户 中提取ERC721通证。

  //因此，在一个用户被(其他人)授权拥有一定数量的通证的情况下，可以通过该功能将这部分 通证从另一个用户的账户中提取出来。

  function takeOwnership(uint256 _tokenId){

    require(tokenExists[_tokenId]);

 

    address oldOwner = ownerOf(_tokenId);

    address newOwner = msg.sender;

 

    require(newOwner != oldOwner);

 

    require(allowed[oldOwner][newOwner] == _tokenId);

    balances[oldOwner] -= 1;

    tokenOwners[_tokenId] = newOwner;

 

    balances[oldOwner] += 1;

    Transfer(oldOwner, newOwner,_tokenId);

  }



  mapping(address => mapping(uint256 => uint256)) private ownerTokensStr;

  function removeFromTokenList(address owner, uint256 _tokenId) private {

    for(uint256 i = 0;ownerTokensStr[owner][i] != _tokenId;i++){

      ownerTokensStr[owner][i] = 0;

    }

  }

  

  //transfer - 转账

  //另一种转移通证的方法时使用transfer函数。转账(transfer)功能可以让用户将通证发给另一个用户， 类似于操作比特币这样的加密数字货币。

  //然而，只有在汇出账户之前授权过汇入账户持有其通证的 情况下，才可以进行转账。

  function transfer(address _to, uint256 _tokenId){

    address currentOwner = msg.sender;

    address newOwner = _to;

    address oldOwner = ownerOf(_tokenId);

    

    require(tokenExists[_tokenId]);

    require(currentOwner == ownerOf(_tokenId));

    require(currentOwner != newOwner);

    require(newOwner != address(0));

    removeFromTokenList(currentOwner,_tokenId);

    balances[oldOwner] -= 1;

    tokenOwners[_tokenId] = newOwner;

    balances[newOwner] += 1;

    Transfer(oldOwner, newOwner, _tokenId);

  }



  //tokenOfOwnerByIndex - 通证检索

  //这个函数是可选的，但推荐实现它。

  //每一个ERC721通证的持有者可以同时持有不止一个通证，因为每个通证都有唯一的ID，但是，要跟踪某个用户持有的 通证可能就会比较困难。

  //为此，合约需要记录每个用户持有的每个通证。通过这种方式，用户可以 通过索引清单检索其拥有的通证。通证检索(tokenOfOwnerByIndex)函数可以通过这种方式追溯某一特定的通证。

  function tokenOfOwnerByIndex(address _owner, uint256 _index) constant returns (uint tokenId){

    return ownerTokensStr[_owner][_index];

  }

  

  //tokenMetaData - 通证元数据 tokenMetaData函数应当返回通证的元数据，或者通证数据的链接。

  //我们可以储存每个通证的引用(references)，例如IPFS哈希或HTTP(S)链接，这些 引用，被称作元数据。元数据是可选的。

  mapping(uint256 => string) tokenLinks;

  function tokenMetadata(uint256 _tokenId) constant returns (string infoUrl) {

    return tokenLinks[_tokenId];

  }



	//Transfer - 转账

	//当一个通证的所有权从一个用户转移到另一个时，将触发该事件，事件的信息包括汇出账户、汇入账户和通证ID。

  event Transfer(address indexed _from,address indexed _to, uint256 _tokenId);

  

  //Approval - 批准

	//当一个用户允许另一个用户持有其通证的时候(例如启用“授权”功能的时候)，该事件就会被触发，事件的信息中 包含这些通证现在的持有账户、被授权账户以及通证ID。

  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

  

}