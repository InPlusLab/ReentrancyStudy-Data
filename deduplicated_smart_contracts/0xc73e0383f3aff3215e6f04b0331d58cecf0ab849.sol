/**
 *Submitted for verification at Etherscan.io on 2019-11-14
*/

// hevm: flattened sources of /nix/store/nrmi9gk7q94ba1fbhq9bphlbpqd1y8hw-scd-mcd-migration-e730e63/src/ScdMcdMigration.sol
pragma solidity =0.5.12;

////// /nix/store/nrmi9gk7q94ba1fbhq9bphlbpqd1y8hw-scd-mcd-migration-e730e63/src/Interfaces.sol
/* pragma solidity 0.5.12; */

contract GemLike {
    function allowance(address, address) public returns (uint);
    function approve(address, uint) public;
    function transfer(address, uint) public returns (bool);
    function transferFrom(address, address, uint) public returns (bool);
}

contract ValueLike {
    function peek() public returns (uint, bool);
}

contract SaiTubLike {
    function skr() public view returns (GemLike);
    function gem() public view returns (GemLike);
    function gov() public view returns (GemLike);
    function sai() public view returns (GemLike);
    function pep() public view returns (ValueLike);
    function vox() public view returns (VoxLike);
    function bid(uint) public view returns (uint);
    function ink(bytes32) public view returns (uint);
    function tag() public view returns (uint);
    function tab(bytes32) public returns (uint);
    function rap(bytes32) public returns (uint);
    function draw(bytes32, uint) public;
    function shut(bytes32) public;
    function exit(uint) public;
    function give(bytes32, address) public;
}

contract VoxLike {
    function par() public returns (uint);
}

contract JoinLike {
    function ilk() public returns (bytes32);
    function gem() public returns (GemLike);
    function dai() public returns (GemLike);
    function join(address, uint) public;
    function exit(address, uint) public;
}
contract VatLike {
    function ilks(bytes32) public view returns (uint, uint, uint, uint, uint);
    function hope(address) public;
    function frob(bytes32, address, address, address, int, int) public;
}

contract ManagerLike {
    function vat() public view returns (address);
    function urns(uint) public view returns (address);
    function open(bytes32, address) public returns (uint);
    function frob(uint, int, int) public;
    function give(uint, address) public;
    function move(uint, address, uint) public;
}

contract OtcLike {
    function getPayAmount(address, address, uint) public view returns (uint);
    function buyAllAmount(address, uint, address, uint) public;
}

////// /nix/store/nrmi9gk7q94ba1fbhq9bphlbpqd1y8hw-scd-mcd-migration-e730e63/src/ScdMcdMigration.sol
/* pragma solidity 0.5.12; */

/* import { JoinLike, ManagerLike, SaiTubLike, VatLike } from "./Interfaces.sol"; */

contract ScdMcdMigration {
    SaiTubLike                  public tub;
    VatLike                     public vat;
    ManagerLike                 public cdpManager;
    JoinLike                    public saiJoin;
    JoinLike                    public wethJoin;
    JoinLike                    public daiJoin;

    constructor(
        address tub_,           // SCD tub contract address
        address cdpManager_,    // MCD manager contract address
        address saiJoin_,       // MCD SAI collateral adapter contract address
        address wethJoin_,      // MCD ETH collateral adapter contract address
        address daiJoin_        // MCD DAI adapter contract address
    ) public {
        tub = SaiTubLike(tub_);
        cdpManager = ManagerLike(cdpManager_);
        vat = VatLike(cdpManager.vat());
        saiJoin = JoinLike(saiJoin_);
        wethJoin = JoinLike(wethJoin_);
        daiJoin = JoinLike(daiJoin_);

        require(wethJoin.gem() == tub.gem(), "non-matching-weth");
        require(saiJoin.gem() == tub.sai(), "non-matching-sai");

        tub.gov().approve(address(tub), uint(-1));
        tub.skr().approve(address(tub), uint(-1));
        tub.sai().approve(address(tub), uint(-1));
        tub.sai().approve(address(saiJoin), uint(-1));
        wethJoin.gem().approve(address(wethJoin), uint(-1));
        daiJoin.dai().approve(address(daiJoin), uint(-1));
        vat.hope(address(daiJoin));
    }

    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x, "add-overflow");
    }

    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x, "sub-underflow");
    }

    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x, "mul-overflow");
    }

    function toInt(uint x) internal pure returns (int y) {
        y = int(x);
        require(y >= 0, "int-overflow");
    }

    // Function to swap SAI to DAI
    // This function is to be used by users that want to get new DAI in exchange of old one (aka SAI)
    // wad amount has to be <= the value pending to reach the debt ceiling (the minimum between general and ilk one)
    function swapSaiToDai(
        uint wad
    ) external {
        // Get wad amount of SAI from user's wallet:
        saiJoin.gem().transferFrom(msg.sender, address(this), wad);
        // Join the SAI wad amount to the `vat`:
        saiJoin.join(address(this), wad);
        // Lock the SAI wad amount to the CDP and generate the same wad amount of DAI
        vat.frob(saiJoin.ilk(), address(this), address(this), address(this), toInt(wad), toInt(wad));
        // Send DAI wad amount as a ERC20 token to the user's wallet
        daiJoin.exit(msg.sender, wad);
    }

    // Function to swap DAI to SAI
    // This function is to be used by users that want to get SAI in exchange of DAI
    // wad amount has to be <= the amount of SAI locked (and DAI generated) in the migration contract SAI CDP
    function swapDaiToSai(
        uint wad
    ) external {
        // Get wad amount of DAI from user's wallet:
        daiJoin.dai().transferFrom(msg.sender, address(this), wad);
        // Join the DAI wad amount to the vat:
        daiJoin.join(address(this), wad);
        // Payback the DAI wad amount and unlocks the same value of SAI collateral
        vat.frob(saiJoin.ilk(), address(this), address(this), address(this), -toInt(wad), -toInt(wad));
        // Send SAI wad amount as a ERC20 token to the user's wallet
        saiJoin.exit(msg.sender, wad);
    }

    // Function to migrate a SCD CDP to MCD one (needs to be used via a proxy so the code can be kept simpler). Check MigrationProxyActions.sol code for usage.
    // In order to use migrate function, SCD CDP debtAmt needs to be <= SAI previously deposited in the SAI CDP * (100% - Collateralization Ratio)
    function migrate(
        bytes32 cup
    ) external returns (uint cdp) {
        // Get values
        uint debtAmt = tub.tab(cup);    // CDP SAI debt
        uint pethAmt = tub.ink(cup);    // CDP locked collateral
        uint ethAmt = tub.bid(pethAmt); // CDP locked collateral equiv in ETH

        // Take SAI out from MCD SAI CDP. For this operation is necessary to have a very low collateralization ratio
        // This is not actually a problem as this ilk will only be accessed by this migration contract,
        // which will make sure to have the amounts balanced out at the end of the execution.
        vat.frob(
            bytes32(saiJoin.ilk()),
            address(this),
            address(this),
            address(this),
            -toInt(debtAmt),
            0
        );
        saiJoin.exit(address(this), debtAmt); // SAI is exited as a token

        // Shut SAI CDP and gets WETH back
        tub.shut(cup);      // CDP is closed using the SAI just exited and the MKR previously sent by the user (via the proxy call)
        tub.exit(pethAmt);  // Converts PETH to WETH

        // Open future user's CDP in MCD
        cdp = cdpManager.open(wethJoin.ilk(), address(this));

        // Join WETH to Adapter
        wethJoin.join(cdpManager.urns(cdp), ethAmt);

        // Lock WETH in future user's CDP and generate debt to compensate the SAI used to paid the SCD CDP
        (, uint rate,,,) = vat.ilks(wethJoin.ilk());
        cdpManager.frob(
            cdp,
            toInt(ethAmt),
            toInt(mul(debtAmt, 10 ** 27) / rate + 1) // To avoid rounding issues we add an extra wei of debt
        );
        // Move DAI generated to migration contract (to recover the used funds)
        cdpManager.move(cdp, address(this), mul(debtAmt, 10 ** 27));
        // Re-balance MCD SAI migration contract's CDP
        vat.frob(
            bytes32(saiJoin.ilk()),
            address(this),
            address(this),
            address(this),
            0,
            -toInt(debtAmt)
        );

        // Set ownership of CDP to the user
        cdpManager.give(cdp, msg.sender);
    }
}