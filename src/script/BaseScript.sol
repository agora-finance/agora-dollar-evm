// SPDX-License-Identifier: ISC
// solhint-disable-next-line
pragma solidity >=0.8.0;

import { Strings } from "@openzeppelin/contracts/utils/Strings.sol";
import { Script } from "forge-std/Script.sol";

abstract contract BaseScript is Script {
    using Strings for *;

    address internal deployer;
    uint256 internal privateKey;

    function setUp() public virtual {
        privateKey = vm.envUint("PK");
        deployer = vm.rememberKey(privateKey);
    }

    modifier broadcaster() {
        vm.startBroadcast(deployer);
        _;
        vm.stopBroadcast();
    }

    struct DeployReturn {
        address contractAddress;
        bytes constructorParams;
        string contractName;
    }

    function deploy(
        function() returns (DeployReturn memory) _deployFunction
    ) internal broadcaster returns (DeployReturn memory _return) {
        _return = _deployFunction();
    }
}
