/**

 *Submitted for verification at Etherscan.io on 2019-03-31

*/



pragma solidity ^0.4.20;



contract ERC721 {

   //��ERC20���ݵĽӿ�

   function name() constant returns (string name);

   function symbol() constant returns (string symbol);

   function totalSupply() constant returns (uint256 totalSupply);

   function balanceOf(address _owner) constant returns (uint balance);

   //����Ȩ��صĽӿ�

   function ownerOf(uint256 _tokenId) constant returns (address owner);

   function approve(address _to, uint256 _tokenId);

   function takeOwnership(uint256 _tokenId);

   function transfer(address _to, uint256 _tokenId);

   function tokenOfOwnerByIndex(address _owner, uint256 _index) constant returns (uint tokenId);

   //֤ͨԪ���ݽӿ�

   function tokenMetadata(uint256 _tokenId) constant returns (string infoUrl);

   //�¼�

   event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);

   event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

}



contract ERC721_publish {

  //name - ���� �ú���Ӧ������֤ͨ������

  function name() constant returns(string name){

    return "Ting Yu Token";  

  }



  //Symbol - ���� �ú���Ӧ������֤ͨ�ķ��ţ��������������ERC20�ļ����ԡ�

  function symbol() constant returns(string symbol){

    return "TYT";

  }

  

  //�ܷ����� �ú���Ӧ�������������Ϲ�Ӧ��֤ͨ����������������һ���ǹ̶�����ġ�

  uint256 private tokenTotalSupply = 1000000000;

  function totalSupply() constant returns (uint256 supply){

    return tokenTotalSupply;

  }



  //balanceOf - ��� �ú������ڲ�ѯĳһ��ַ���֤ͨ�����磺

  mapping(address => uint) private balances;

  function balanceOf(address _owner) constant returns(uint balance){ 

    return balances[_owner];

  }



  //ownerOf - �ֱ���

  //�ú�������֤ͨ�����˵ĵ�ַ����Ϊÿһ��ERC721֤ͨ���ǲ�������ģ���˿������������� Ψһ�ĵ�ַ�ҵ������ǿ�����֤ͨ��ID��ȷ��������ˡ�

  mapping(uint256 => address) private tokenOwners;

  mapping(uint256 => bool) private tokenExists;

  function ownerOf(uint256 _tokenId) constant returns (address owner) {

    require(tokenExists[_tokenId]);

    return tokenOwners[_tokenId];

  }



  //approve - ��Ȩ

  //�ú���������Ȩ����һ�����������˽���֤ͨת�Ʋ�����

  //���磬����Alice��һ��ERC721֤ͨ,������ ����approve��������Ȩ����������Bob��Ȼ��Bob�Ϳ��Դ���Alice��ʹ֤ͨ�����˵�Ȩ����

  mapping(address => mapping (address=> uint256)) allowed;

  function approve(address _to, uint256 _tokenId){

    require(msg.sender ==ownerOf(_tokenId));

    require(msg.sender != _to);

   

    allowed[msg.sender][_to] = _tokenId;

    Approval(msg.sender, _to, _tokenId);

  }



  //takeOwnership - ��ȡ

  //�ú���������ȡ��ܣ�һ���ⲿ����ͨ������takeOwnership����������һ���û����˻� ����ȡERC721֤ͨ��

  //��ˣ���һ���û���(������)��Ȩӵ��һ��������֤ͨ������£�����ͨ���ù��ܽ��ⲿ�� ֤ͨ����һ���û����˻�����ȡ������

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

  

  //transfer - ת��

  //��һ��ת��֤ͨ�ķ���ʱʹ��transfer������ת��(transfer)���ܿ������û���֤ͨ������һ���û��� �����ڲ������ر������ļ������ֻ��ҡ�

  //Ȼ����ֻ���ڻ���˻�֮ǰ��Ȩ�������˻�������֤ͨ�� ����£��ſ��Խ���ת�ˡ�

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



  //tokenOfOwnerByIndex - ֤ͨ����

  //��������ǿ�ѡ�ģ����Ƽ�ʵ������

  //ÿһ��ERC721֤ͨ�ĳ����߿���ͬʱ���в�ֹһ��֤ͨ����Ϊÿ��֤ͨ����Ψһ��ID�����ǣ�Ҫ����ĳ���û����е� ֤ͨ���ܾͻ�Ƚ����ѡ�

  //Ϊ�ˣ���Լ��Ҫ��¼ÿ���û����е�ÿ��֤ͨ��ͨ�����ַ�ʽ���û����� ͨ�������嵥������ӵ�е�֤ͨ��֤ͨ����(tokenOfOwnerByIndex)��������ͨ�����ַ�ʽ׷��ĳһ�ض���֤ͨ��

  function tokenOfOwnerByIndex(address _owner, uint256 _index) constant returns (uint tokenId){

    return ownerTokensStr[_owner][_index];

  }

  

  //tokenMetaData - ֤ͨԪ���� tokenMetaData����Ӧ������֤ͨ��Ԫ���ݣ�����֤ͨ���ݵ����ӡ�

  //���ǿ��Դ���ÿ��֤ͨ������(references)������IPFS��ϣ��HTTP(S)���ӣ���Щ ���ã�������Ԫ���ݡ�Ԫ�����ǿ�ѡ�ġ�

  mapping(uint256 => string) tokenLinks;

  function tokenMetadata(uint256 _tokenId) constant returns (string infoUrl) {

    return tokenLinks[_tokenId];

  }



	//Transfer - ת��

	//��һ��֤ͨ������Ȩ��һ���û�ת�Ƶ���һ��ʱ�����������¼����¼�����Ϣ��������˻��������˻���֤ͨID��

  event Transfer(address indexed _from,address indexed _to, uint256 _tokenId);

  

  //Approval - ��׼

	//��һ���û�������һ���û�������֤ͨ��ʱ��(�������á���Ȩ�����ܵ�ʱ��)�����¼��ͻᱻ�������¼�����Ϣ�� ������Щ֤ͨ���ڵĳ����˻�������Ȩ�˻��Լ�֤ͨID��

  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);

  

}