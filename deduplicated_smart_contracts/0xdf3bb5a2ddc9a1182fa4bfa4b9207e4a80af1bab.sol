pragma solidity ^0.4.10;
import './StandardToken.sol';
// requires 4,028,540 BAT deposited here
contract BATSafe {
  mapping (address => uint256) allocations;
  uint256 public unlockDate;
  address public BAT;
  uint256 public constant exponent = 10**18;

  function BATSafe(address _BAT) {
    BAT = _BAT;
    unlockDate = now + 6 * 31 days;
    allocations[0x109c152935Dfe083b77c6FAb6408A93e0a7029fB] = 124000;
    allocations[0x56b5913f719Ec6c674B2Ebc44e48295dBe45Dc7F] = 106000;
    allocations[0xDa53D12dc28561C67be0378341499DdBf66fB060] = 27000;
    allocations[0x9F74d4f71B14a620665970129E188E5AE9788eF4] = 1140000;
    allocations[0xBD6455d071E4dCAF8082f2158c529E607c4853a0] = 114000;
    allocations[0xD7bD2B84Ab23470DA7E8497D45859570fb70B385] = 32000;
    allocations[0x7Cd71e3F9807B34F870a30EFf3D8199425379B51] = 63000;
    allocations[0x64800d80Ba78681C7Fb86518b3152F09d875B458] = 23000;
    allocations[0x3747330538fC5e13709271081FDde1941a633F6f] = 92000;
    allocations[0xb5184eB04aa111AE2E16161B52ac8A8cBba9d47E] = 120000;
    allocations[0x9b3F49A2BCd0394f798773ACb458c0E1F5C05792] = 60000;
    allocations[0x0e0F02508b80e401C26F584fF02eE80Ab094CdF9] = 58000;
    allocations[0xb4eF370D83fc3480F709cBB703ebbF8661083186] = 26500;
    allocations[0x0db21125A98841fbbA14487d88E0dEdd65F6BFb7] = 33500;
    allocations[0x74cE3716d4f140CCFd44f749af414d7005A9d2E9] = 114000;
    allocations[0xb5C76D6636CA4560Bb1835c124771b76587D74dB] = 62000;
    allocations[0x4952Ba0b662CBbc1e6e9cfD62CC64E481cF0411A] = 124000;
    allocations[0xE8Fa9a2b088396B1D7442dBf48F71e6F0e974a16] = 30500;
    allocations[0x68387D4EBd7fbEe061B63Aef00f7B268A46547ca] = 98000;
    allocations[0xc5B4Eb4B3aaC26E95F4ae71b6F4E74A800F1E879] = 62000;
    allocations[0x69C51efB4899c6b6411d9F3B2345CECa00E0060c] = 670000;
    allocations[0x678e898FA7062b26be99bf13F612bfe586CF16e7] = 92000;
    allocations[0x8E4E5186c18435a673AaC0013CE7580D8D9b9cdA] = 98000;
    allocations[0xE1Fab0FAE98DeB5F2cAF2F3dBF11dcb1Ad1f970F] = 59000;
    allocations[0x8B31E6bC3cFC49f2d02C9F352f4e5ccA14eFB017] = 106000;
    allocations[0x952b4e5A63a2150C5FBA4d124865f8c25c5ce861] = 147000;
    allocations[0xccE7AeB1C847FFFee84806FC802c9aa4b790BE9a] = 60000;
    allocations[0x63665e20f8dbF1af1EdD7396217d8Ae826A18aF8] = 120000;
    allocations[0x1cb588C61445216cd8A97f1aCEEB245482dc3101] = 57770;
    allocations[0xC733A26b6d9aF9A5711790FBc63ce5508902B910] = 65770;
    allocations[0x8ae8C43887Ad13D872F7eb5451BFdc465046ea41] = 43500;
  }

  function unlock() external {
    if(now < unlockDate) throw;
    uint256 entitled = allocations[msg.sender];
    allocations[msg.sender] = 0;
    if(!StandardToken(BAT).transfer(msg.sender, entitled * exponent)) throw;
  }

}


