/**
 *Submitted for verification at Etherscan.io on 2019-12-05
*/

pragma solidity >=0.4.21 <0.6.0;

contract MultiSigInterface{
  function update_and_check_reach_majority(uint64 id, string memory name, bytes32 hash, address sender) public returns (bool);
  function is_signer(address addr) public view returns(bool);
}

contract MultiSigTools{
  MultiSigInterface public multisig_contract;
  constructor(address _contract) public{
    require(_contract!= address(0x0));
    multisig_contract = MultiSigInterface(_contract);
  }

  modifier only_signer{
    require(multisig_contract.is_signer(msg.sender), "only a signer can call in MultiSigTools");
    _;
  }

  modifier is_majority_sig(uint64 id, string memory name) {
    bytes32 hash = keccak256(abi.encodePacked(msg.sig, msg.data));
    if(multisig_contract.update_and_check_reach_majority(id, name, hash, msg.sender)){
      _;
    }
  }

  event TransferMultiSig(address _old, address _new);

  function transfer_multisig(uint64 id, address _contract) public only_signer
  is_majority_sig(id, "transfer_multisig"){
    require(_contract != address(0x0));
    address old = address(multisig_contract);
    multisig_contract = MultiSigInterface(_contract);
    emit TransferMultiSig(old, _contract);
  }
}

contract TransferableToken{
    function balanceOf(address _owner) public returns (uint256 balance) ;
    function transfer(address _to, uint256 _amount) public returns (bool success) ;
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success) ;
}


contract TokenClaimer{

    event ClaimedTokens(address indexed _token, address indexed _to, uint _amount);
    /// @notice This method can be used by the controller to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
  function _claimStdTokens(address _token, address payable to) internal {
        if (_token == address(0x0)) {
            to.transfer(address(this).balance);
            return;
        }
        TransferableToken token = TransferableToken(_token);
        uint balance = token.balanceOf(address(this));

        (bool status,) = _token.call(abi.encodeWithSignature("transfer(address,uint256)", to, balance));
        require(status, "call failed");
        emit ClaimedTokens(_token, to, balance);
  }
}

contract GTProject is MultiSigTools, TokenClaimer{
  string public project_name;
  string public project_intro;
  string public project_logo;
  string public project_reserve;

  address public vote_contract;

  mapping (bytes32 => address) public extra_contracts;
  string[] public extra_contract_names;

  event ChangeProjectInfo(string item, string old_value, string new_value);

  event ChangeVoteContract(address _old_contract, address _contract);

  event AddExtraContract(string _name, address _contract);
  event RemoveExtraContract(string _name, address _contract);

  constructor(string memory _name,
              string memory _intro,
              string memory _logo,
              string memory _reserve,
              address _multisig,
              address _vote) MultiSigTools(_multisig) public{
    project_name = _name;
    project_intro = _intro;
    project_logo = _logo;
    project_reserve = _reserve;
    vote_contract = _vote;
  }

  function strCmp(string memory s1, string memory s2) pure internal returns (bool){
    return keccak256(abi.encodePacked(s1)) == keccak256(abi.encodePacked(s2));
  }

  function changeProjectName(uint64 id,
                             string memory _name)
    public
    only_signer
    is_majority_sig(id, "changeProjectName"){
      if(!strCmp(project_name, _name)){
        emit ChangeProjectInfo("name", project_name, _name);
        project_name = _name;
      }
  }
  function changeProjectIntro(uint64 id,
                             string memory _intro)
    public
    only_signer
    is_majority_sig(id, "changeProjectIntro"){
      if(!strCmp(project_intro, _intro)){
        emit ChangeProjectInfo("intro", project_intro, _intro);
        project_intro = _intro;
      }
  }
  function changeProjectLogo(uint64 id,
                             string memory _logo)
    public
    only_signer
    is_majority_sig(id, "changeProjectLogo"){
      if(!strCmp(project_logo, _logo)){
        emit ChangeProjectInfo("name", project_logo, _logo);
        project_logo = _logo ;
      }
  }
  function changeProjectReserve(uint64 id,
                             string memory _reserve)
    public
    only_signer
    is_majority_sig(id, "changeProjectReserve"){
      if(!strCmp(project_reserve, _reserve)){
        emit ChangeProjectInfo("reserve", project_reserve, _reserve);
        project_reserve = _reserve;
      }
  }

  function changeVoteContract(uint64 id, address _vote) public
    only_signer
    is_majority_sig(id, "changeVoteContract"){
      emit ChangeVoteContract(vote_contract, _vote);
      vote_contract = _vote;
  }

  function addExtraContract(uint64 id, string memory _name, address _contract) public
    only_signer
    is_majority_sig(id, "addExtraContract"){
      require(_contract != address(0x0), "address can't be 0");
      bytes32 hash = keccak256(abi.encodePacked(_name));
      require(extra_contracts[hash] == address(0x0), "already exist");
      extra_contracts[hash] = _contract;
      extra_contract_names.push(_name);
      emit AddExtraContract(_name, _contract);
  }

  function removeExtraContract(uint64 id, string memory _name) public
    only_signer
    is_majority_sig(id, "removeExtraContract"){
      bytes32 hash = keccak256(abi.encodePacked(_name));
      require(extra_contracts[hash] != address(0x0), "not exist");
      address addr = extra_contracts[hash];
      delete extra_contracts[hash];

      for(uint i = 0; i < extra_contract_names.length; i++){
        if(keccak256(abi.encodePacked(extra_contract_names[i])) == hash ){
          extra_contract_names[i] = extra_contract_names[extra_contract_names.length - 1];
          delete extra_contract_names[extra_contract_names.length - 1];
          extra_contract_names.length -- ;
          break;
        }
      }
      emit RemoveExtraContract(_name, addr);
  }

  function getExtraContractNumber() public view returns (uint){
    return extra_contract_names.length;
  }
  function getExtraContractInfo(uint i) public view returns(string memory name, address addr){
    require(i < extra_contract_names.length, "out of range");
    name = extra_contract_names[i];
    addr = getExtraContractAddress(name);
  }

  function getExtraContractAddress(string memory _name) public view returns(address){
      bytes32 hash = keccak256(abi.encodePacked(_name));
      return extra_contracts[hash];
  }

  function claimStdTokens(uint64 id, address _token, address payable to) public only_signer is_majority_sig(id, "claimStdTokens"){
    _claimStdTokens(_token, to);
  }
}

contract GTProjectFactory{

  event CreateGTProject(address _addr, string _name, string _intro, string _logo, string _reserve,
                       address _multisig, address _vote);

  function createGTProject(string memory _name,
                           string memory _intro,
                           string memory _logo,
                           string memory _reserve,
                           address _multisig,
                           address _vote) public returns(address){
    GTProject gtp = new GTProject(_name, _intro, _logo, _reserve, _multisig, _vote);
    emit CreateGTProject(address(gtp), _name, _intro, _logo, _reserve, _multisig, _vote);
    return address(gtp);
  }
}