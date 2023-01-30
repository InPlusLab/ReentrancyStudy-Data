/**
 *Submitted for verification at Etherscan.io on 2019-10-11
*/

pragma solidity 0.4.26;

/***************
DDR CONTRACT
***************/

contract DigitalDollarRetainer {

// **terms governing DDR**
string public terms = "|| Establishing a retainer and acknowledging the mutual consideration and agreement hereby, Client, indentified as ethereum address '0x[[Client]]', commits a digital payment transactional script capped at '$[[Payment Cap in Dollars]]' for the benefit of Provider, identified as ethereum address '0x[[Provider]]', in exchange for the prompt satisfaction of the following deliverables, '[[Deliverable]]', to Client by Provider upon scripted payments set at the rate of '$[[Deliverable Rate]]' per deliverable, with such retainer relationship not to exceed '[[Retainer Duration in Days]]' days and to be governed by the choice of [[Choice of Law and Arbitration Forum]] law and 'either/or' arbitration rules in [[Choice of Law and Arbitration Forum]]. ||";

// **ERC-20 Token References**
address public daiToken = 0x89d24A6b4CcB1B6fAA2625fE562bDD9a23260359; // **designated ERC-20 token for payments - DAI 'digital dollar'**
address public usdcToken = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48; // **designated ERC-20 token for payments - USDC 'digital dollar'**

// **Retainer References**
address public client; // **client ethereum address**
address public provider; // **ethereum address that receives payments in exchange for goods or services**
string public deliverable; // **goods or services (deliverable) retained for benefit of ethereum payments**
string public governingLawForum; // **choice of law and forum for retainer relationship**
uint256 public retainerDurationDays; // **duration of retainer in days**
uint256 public deliverableRate; // **rate for retained deliverables in digital dollars**
uint256 public paid; // **amount paid thus far under retainer in digital dollars**
uint256 public payCap; // **retainer payment cap in digital dollars**

event Paid(uint256 amount, address indexed); // **triggered on successful payments**

constructor(address _client, address _provider, string _deliverable, string _governingLawForum, uint256 _retainerDurationDays, uint256 _deliverableRate, uint256 _payCap) public {
client = _client;
provider = _provider;
deliverable = _deliverable;
governingLawForum = _governingLawForum;
retainerDurationDays = _retainerDurationDays;
deliverableRate = _deliverableRate;
payCap = _payCap;
require(deliverableRate <= payCap, "constructor: deliverableRate cannot exceed payCap"); // program safety check / economics
}

function payDAI() public { // **forwards approved DAI token amount to provider ethereum address**
require(msg.sender == client); // program safety check / authorization
require(paid + deliverableRate <= payCap, "payDAI: payCap exceeded"); // program safety check / economics
ERC20 dai = ERC20(daiToken);
dai.transferFrom(msg.sender, provider, deliverableRate);
paid = paid + deliverableRate;
emit Paid(deliverableRate, msg.sender);
}

function payUSDC() public { // **forwards approved USDC token amount to provider ethereum address**
require(msg.sender == client); // program safety check / authorization
require(paid + deliverableRate <= payCap, "payUSDC: payCap exceeded"); // program safety check / economics
ERC20 usdc = ERC20(usdcToken);
usdc.transferFrom(msg.sender, provider, deliverableRate);
paid = paid + deliverableRate;
emit Paid(deliverableRate, msg.sender);
}
}

/***************
ERC20 CONTRACT
***************/

/**
* @title ERC20
* @dev see https://github.com/ethereum/EIPs/issues/20
*/
contract ERC20 {
uint256 public totalSupply;

function balanceOf(address who) public view returns (uint256);
function transfer(address to, uint256 value) public returns (bool);
function allowance(address owner, address spender) public view returns (uint256);
function transferFrom(address from, address to, uint256 value) public returns (bool);
function approve(address spender, uint256 value) public returns (bool);

event Approval(address indexed owner, address indexed spender, uint256 value);
event Transfer(address indexed from, address indexed to, uint256 value);
}

/***************
FACTORY CONTRACT
***************/

contract DigitalDollarRetainerFactory {

// **index of created contracts**
mapping (address => bool) public validContracts;
address[] public contracts;

// **useful to know the row count in contracts index**
function getContractCount()
public
view
returns(uint contractCount)
{
return contracts.length;
}

// **get all contracts**
function getDeployedContracts() public view returns (address[])
{
return contracts;
}

// **deploy a new contract**
function newDigitalDollarRetainer(address _client, address _provider, string _deliverable, string _governingLawForum, uint256 _retainerDurationDays, uint256 _deliverableRate, uint256 _payCap)
public
returns(address)
{
DigitalDollarRetainer c = new DigitalDollarRetainer(_client, _provider, _deliverable, _governingLawForum, _retainerDurationDays, _deliverableRate, _payCap);
validContracts[c] = true;
contracts.push(c);
return c;
}
}