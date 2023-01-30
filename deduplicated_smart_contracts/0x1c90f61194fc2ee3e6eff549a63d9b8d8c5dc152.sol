/**

 *Submitted for verification at Etherscan.io on 2019-02-11

*/



pragma solidity ^0.4.24;



contract CampaignFactory {

  modifier onlyOwner() {

    require(msg.sender == owner);

    _;

  }

  address[] campaigns;

  address public owner = msg.sender;



  function createCampaign(

    uint _duration,

    string _title,

    string _description,

    string _website) public onlyOwner returns(address) {

    Campaign newCampaign = new Campaign(

      _duration,

      _title,

      _description,

      _website,

      msg.sender

    );



    campaigns.push(newCampaign);

    return newCampaign;

  }



  function getCampaigns() public view returns(address[]){

    require( campaigns.length > 0);

    return campaigns;

  }

}



contract Campaign {

  enum CampaignState {

    READY, OPEN, CLOSED

  }



  uint public currentAmount;

  uint public targetAmount;

  uint public duration; //period of campaign(days)

  uint createtionTime = now;



  address public owner;

  address[] donatorsArr;

  address[] receiversArr;



  string title;

  string description;

  string website;



  mapping (address => uint) donators;

  mapping (address => uint) receiversMap;

  // widthdraw list

  mapping (address => bool) receiversWidthdraw;



  CampaignState public state;



  constructor(

    uint _duration,

    string _title,

    string _description,

    string _website,

    address _owner

  ) public {

    title = _title;

    duration = (_duration*1 minutes); //days to minutes

    description = _description;

    website = _website;

    owner = _owner;

    state = CampaignState.READY;

  }



  modifier onlyOwner() {

    require(msg.sender == owner);

    _;

  }



  /*

  * check state and duration

  */

  modifier onlyWhenCampaignClosed() {

    require(state == CampaignState.CLOSED);// && now >= createtionTime + duration) ;

    _;

  }



  /*

* check state and duration

*/

  modifier onlyWhenCampaignOpen() {

    require(state == CampaignState.OPEN && now <= createtionTime + duration) ;

    _;

  }



  /**

  * fallback function

  */

  function () public payable{

    if( msg.value > 0 ){

      require(state == CampaignState.OPEN);

      donatorsArr.push(msg.sender);

      donators[msg.sender] += msg.value;

      currentAmount += msg.value;

    }

  }



  function addReceiver(address _receiver, uint _requiredAmount) onlyOwner public {

    require(state == CampaignState.READY);

    require(_requiredAmount > 0 && receiversMap[_receiver] <= 0);

    receiversArr.push(_receiver);

    receiversMap[_receiver] = _requiredAmount;

    targetAmount += _requiredAmount;

  }



  function updateReceiver(address _receiver, uint _requiredAmount) onlyOwner public {

    require(state == CampaignState.READY);

    require(_requiredAmount > 0 && receiversMap[_receiver] > 0);

    targetAmount = targetAmount - receiversMap[_receiver] + _requiredAmount;

    receiversMap[_receiver] = _requiredAmount;

  }



  /**

  * returns title, description, website, duration, targetAmount, count of receivers, state

  */

  function campaignInfo() view public returns(string, string, string, uint, uint, uint, uint) {

    return (title, description, website, duration, targetAmount, receiversArr.length, uint(state) );

  }



  function getReceivers() view public returns (address[]){

    return receiversArr;

  }



  function getReceiversMap(address _receiver) view public returns (uint){

    return receiversMap[_receiver];

  }



  function getDonators() view public returns (address[]) {

    return donatorsArr;

  }



  function donate() public onlyWhenCampaignOpen payable{

    require(state == CampaignState.OPEN);



    require(msg.value > 0);

    donatorsArr.push(msg.sender);

    donators[msg.sender] += msg.value;

    currentAmount += msg.value;

  }



  function extendDuration(uint _newDuration) onlyOwner public {

    require(duration < _newDuration);

    duration = _newDuration;

  }



  function startCampaign() onlyOwner public {

    require(state == CampaignState.READY);

    require(receiversArr.length > 0);

    changeState(CampaignState.OPEN);

  }

  function stopCampaign() onlyOwner public {

    require(state == CampaignState.OPEN && targetAmount <= currentAmount);

    changeState(CampaignState.CLOSED);

  }



  function changeState(CampaignState _state) internal {

    // require(state != _state && state < _state);

    require(state != _state);

    state = _state;

  }

  // function changeState(uint _state) internal {

  //   require(state != _state && uint(CampaignState.READY) <= _state && uint(CampaignState.CLOSED) >= _state);

  //   state = CampaignState(_state);

  // }



  function queryMyDonation() view public returns(uint) {

    require(donators[msg.sender] > 0);

    return donators[msg.sender];

  }



  function widthdraw() onlyWhenCampaignClosed public payable{

    require(receiversMap[msg.sender] > 0);

    require(!receiversWidthdraw[msg.sender]);

    // uint amount = receiversMap[msg.sender];

    // delete receiversMap[msg.sender];

    // msg.sender.transfer(amount);

    receiversWidthdraw[msg.sender] = true;

    msg.sender.transfer(receiversMap[msg.sender]);

  }



  function getContractBalance() public view returns(uint) {

    return address(this).balance;

  }



  function getCampaignEndBlockTime() public view returns (uint) {

    return (createtionTime + duration);

  }



}