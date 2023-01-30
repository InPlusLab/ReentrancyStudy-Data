/**
 *Submitted for verification at Etherscan.io on 2020-03-09
*/

pragma solidity ^0.5.12;

contract VatLike {
    function urns(bytes32, address) public view returns (uint, uint);
    function hope(address) public;
    function flux(bytes32, address, address, uint) public;
    function move(address, address, uint) public;
    function frob(bytes32, address, address, address, int, int) public;
    function fork(bytes32, address, address, int, int) public;
}

contract UrnHandler {
    constructor(address vat) public {
        VatLike(vat).hope(msg.sender);
    }
}

contract OasisCdpManagerEvents {
    event OpenEvent(
        address indexed usr,
        bytes32 ilk,
        address indexed urn
    );

    event FrobEvent(
        address indexed usr,
        bytes32 ilk,
        address indexed urn,
        int dink,
        int dart
    );

    event FluxEvent(
        address indexed usr,
        bytes32 ilk,
        address indexed urn,
        address dst,
        uint wad
    );

    event MoveEvent(
        address indexed usr,
        bytes32 ilk,
        address indexed urn,
        address dst,
        uint rad
    );

    event QuitEvent(
        address indexed usr,
        bytes32 ilk,
        address indexed urn,
        int dink,
        int dart
    );

    event EnterEvent(
        address indexed usr,
        bytes32 ilk,
        address indexed urn,
        int dink,
        int dart
    );
}

contract OasisCdpManager is OasisCdpManagerEvents {
    address public vat;

    mapping (
        address => mapping (
            bytes32 => address
        )
    ) public urns;  // Owner => Ilk => UrnHandler

    constructor(address vat_) public {
        vat = vat_;
    }

    function toInt(uint x) internal pure returns (int y) {
        y = int(x);
        require(y >= 0);
    }

    // Open a new cdp for msg.sender address.
    function open(
        bytes32 ilk
    ) public returns (address urn) {
        require(urns[msg.sender][ilk] == address(0), "cannot-override-urn");
        urn = address(new UrnHandler(vat));
        urns[msg.sender][ilk] = urn;
        emit OpenEvent(msg.sender, ilk, urn);
    }

    // Frob the cdp keeping the generated DAI or collateral freed in the cdp urn address.
    function frob(
        bytes32 ilk,
        int dink,
        int dart
    ) public {
        address urn = urns[msg.sender][ilk];
        VatLike(vat).frob(
            ilk,
            urn,
            urn,
            urn,
            dink,
            dart
        );
        emit FrobEvent(msg.sender, ilk, urn, dink, dart);
    }

    // Transfer wad amount of cdp collateral from the cdp address to a dst address.
    function flux(
        bytes32 ilk,
        address dst,
        uint wad
    ) public {
        VatLike(vat).flux(ilk, urns[msg.sender][ilk], dst, wad);
        emit FluxEvent(msg.sender, ilk, urns[msg.sender][ilk], dst, wad);
    }

    // Transfer wad amount of cdp collateral from the cdp address to a dst address.
    // This function has the purpose to take away collateral from the system that doesn't correspond to the cdp but was sent there wrongly.
    function flux(
        bytes32 ilk,
        bytes32 ilkExtract,
        address dst,
        uint wad
    ) public {
        VatLike(vat).flux(ilkExtract, urns[msg.sender][ilk], dst, wad);
        emit FluxEvent(msg.sender, ilkExtract, urns[msg.sender][ilk], dst, wad);
    }

    // Transfer rad amount of DAI from the cdp address to a dst address.
    function move(
        bytes32 ilk,
        address dst,
        uint rad
    ) public {
        VatLike(vat).move(urns[msg.sender][ilk], dst, rad);
        emit MoveEvent(msg.sender, ilk, urns[msg.sender][ilk], dst, rad);
    }

    // Quit the system, migrating the msg.sender cdp (ink, art) to a msg.sender urn
    function quit(
        bytes32 ilk
    ) public {
        address urn = urns[msg.sender][ilk];
        (uint ink, uint art) = VatLike(vat).urns(ilk, urn);
        VatLike(vat).fork(
            ilk,
            urn,
            msg.sender,
            toInt(ink),
            toInt(art)
        );
        emit QuitEvent(msg.sender, ilk, urn, toInt(ink), toInt(art));
    }

    // Import a position from msg.sender urn to msg.sender cdp
    function enter(
        bytes32 ilk
    ) public {
        address urn = urns[msg.sender][ilk];
        require(urn != address(0), "not-existing-urn");
        (uint ink, uint art) = VatLike(vat).urns(ilk, msg.sender);
        VatLike(vat).fork(
            ilk,
            msg.sender,
            urn,
            toInt(ink),
            toInt(art)
        );
        emit EnterEvent(msg.sender, ilk, urn, toInt(ink), toInt(art));
    }
}