//SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;

import {Script} from "forge-std/Script.sol";
import {BinaryTree} from "../src/BinaryTree.sol";

contract DeployBinaryTree is Script {
    function run() external returns (BinaryTree) {
        vm.startBroadcast();
        BinaryTree binaryTree = new BinaryTree();
        vm.stopBroadcast();
        return binaryTree;
    }
}
