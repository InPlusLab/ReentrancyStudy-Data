pragma solidity >=0.6.0 <0.7.0;
import "./Proxy.sol";

contract ProxyFactory {

    event ProxyCreation(Proxy proxy);

    function createProxy(address owner, bytes32 version, address implementation, bytes memory data)
        public
        payable
        returns (Proxy proxy)
    {
        proxy = new Proxy{value:msg.value}(owner, version, implementation);
        if (data.length > 0) {
            (bool success,) = address(proxy).call(data);
            require(success, "Failing call after deployment");
        }

        emit ProxyCreation(proxy);
    }

    function createProxyWithNonce(address owner, bytes32 version, address implementation, bytes memory data, bytes32 saltNonce)
        public
        payable
        returns (Proxy proxy)
    {
        bytes32 salt = keccak256(abi.encode(keccak256(data), saltNonce));
        bytes memory deploymentData = abi.encodePacked(type(Proxy).creationCode, abi.encode(owner, version, implementation));
        uint256 amount = msg.value;

        // solium-disable-next-line security/no-inline-assembly
        assembly {
            proxy := create2(amount, add(0x20, deploymentData), mload(deploymentData), salt)
        }
        require(address(proxy) != address(0), "Create2 call failed");

        if (data.length > 0) {
            (bool success,) = address(proxy).call(data);
            require(success, "Failing call after deployment");
        }

        emit ProxyCreation(proxy);
    }
}
