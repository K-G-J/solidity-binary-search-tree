//SPDX-License-Identifier: MIT

import {Script} from "forge-std/Script.sol";
import {BinaryTree} from "../src/BinaryTree.sol";

pragma solidity ^0.8.19;

contract DeployBinaryTree is Script {
    function run() external returns (BinaryTree) {
        vm.startBroadcast();
        BinaryTree binaryTree = new BinaryTree();
        vm.stopBroadcast();
        return binaryTree;
    }
}
