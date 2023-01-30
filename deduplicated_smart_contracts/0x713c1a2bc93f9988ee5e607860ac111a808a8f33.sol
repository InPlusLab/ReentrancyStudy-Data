pragma solidity ^0.4.19;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;

  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    owner = newOwner;
  }

}

contract Refund is Ownable {

    
    address[] public addrs = [0x14af116811f834a4b5fb81008ed0a566b0a54326, 
    0x14af116811f834a4b5fb81008ed0a566b0a54326, 0x25affa543b067c975cfb56e2adacdc9433e50243, 
    0xdc4b2474c0837adc8368ed1aa66e62fba3fabe18, 0x549956701a4624ee627926bdc6eee7e8af02dd6b, 
    0x02beb330458f21dee5cce36f2ca97f758063f2c0, 0x3f48a2e2e4eb8af36dfee0342a1b8799b08132f1, 
    0x41cc6228725e121cffbd054558cc6d8ba1e4c51c, 0x3531decff920b14e7263a24f3c4ac13abdcf60fd, 
    0xbd30d8553947cc2bb504b9b29366b34e5d0dce3e, 0x11bf20edb7fd144775f9c9defefddbfc186e4c0d, 
    0x005a510b2df05f27866475ea32a286a72860e69c, 0x76110779be9c603aa2b6032bed095e19c840c143, 
    0xa1a3fb84169277f7794b310270f7bbe5286efe75, 0x69b6892e6b054bcd0159fb63d8f4dedd927e0ec3, 
    0xcfc857ca9305e2cd7e19b81cd68fdf89310cff7b, 0xc05fbce22edd39455ba77816de9bf536aadbb944, 
    0xb7ef214f734802c540bb0263b42ca990bbc4c651, 0xe0301b3c40cf78961f7b5f5e570d2ec54278410b, 
    0x70b9663b76728d11b76a7b1142bf156bb5a94cb3, 0x70b9663b76728d11b76a7b1142bf156bb5a94cb3, 
    0x36dc348eb3560da109915c14152a28e294547914, 0xfcd933e240bc72b5cc89d8d3349a19ab4bb7ec8f, 
    0x1f879e03cad485075f809cfcf69a3a6d3dea34cc, 0x1f879e03cad485075f809cfcf69a3a6d3dea34cc, 
    0xa37c90bd1448d5589aaf4c4b8db94c0319818ab9, 0x47d1873d2babde1e4547eaa39d6d0cb9152c69e2, 
    0xbbdecf8bceaaca3548965e246be87424c8c2d24d, 0xb7e6c5f007550388530b12e7d357b1502af50185, 
    0x2434c962fbac790b70f10c4302c0c6ae87d7fe2b, 0x36dc348eb3560da109915c14152a28e294547914, 
    0xc6e7dc762f0e37842cf4706376fb71f9d2cc1f6c, 0xce10b54a04ec1af34b2f256b0cc55842f1a3553f, 
    0x35ac3dca25f0bd44931105dbd1d08941f7d7915f, 0x11a26b9c968227a28bcef33f1ed07c14d1b71829, 
    0x11a26b9c968227a28bcef33f1ed07c14d1b71829, 0x005a510b2df05f27866475ea32a286a72860e69c, 
    0x11a26b9c968227a28bcef33f1ed07c14d1b71829, 0x11a26b9c968227a28bcef33f1ed07c14d1b71829, 
    0x11a26b9c968227a28bcef33f1ed07c14d1b71829, 0x11a26b9c968227a28bcef33f1ed07c14d1b71829, 
    0xb38ce8222faf25908940979c009ef741a642e7fd, 0xa25179297a3e6b19d1e055cc82db924c8c2096e1, 
    0xda5697cd002068afbf4f9a1d348855120087902a, 0xda5697cd002068afbf4f9a1d348855120087902a, 
    0xaa53075b1092dcd19cc09121a8a84e708ac4534d, 0x4b79f80ac86feafd407c727d0ebcd20b06bb6f9c, 
    0x1b2fe8472218013f270d48699b8ff3f682433918];
    
    uint[] public funds = [10000000000000000, 10000000000000000, 10000000000000000000, 
    80000000000000000, 290000000000000000, 20000000000000000, 100000000000000000, 
    610000000000000000, 3990000000000000000, 50000000000000000, 700000000000000000, 
    590000000000000000, 20000000000000000, 5000000000000000000, 138290000000000000, 
    10000000000000000, 250000000000000000, 2200000000000000000, 245000000000000000, 
    51400000000000000, 50000000000000000, 20000000000000000, 10000000000000000, 
    10000000000000000, 1000000000000000, 250000000000000000, 259261340000000000, 
    24190000000000000, 1010000000000000000, 25000000000000000, 30000000000000000, 
    500000000000000000, 1000000000000000000, 48000000000000000, 15000000000000000, 
    13000000000000000, 500000000000000000, 1500000000000000, 1300000000000000, 
    8000000000000000, 5000000000000000, 2700000000000000000, 5000000000000000, 
    70969000000000000, 70969000000000000, 10000000000000000, 40000000000000000, 
    50000000000000000];
    
    event RefundEvent(address, uint);
    
    function Refund () public {
    }
    
    function startRefund() public onlyOwner {
        for(uint i; i < addrs.length; i++) {
            addrs[i].transfer(funds[i]);
            RefundEvent(addrs[i], funds[i]);
        }
    }
    
    function () payable public {
        
    }
    
    
    function finalize() public onlyOwner {
        selfdestruct(msg.sender);
    }
}