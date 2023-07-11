//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.19;

import {Test, console} from "forge-std/Test.sol";
import {BinaryTree} from "../src/BinaryTree.sol";
import {DeployBinaryTree} from "../script/BinaryTree.s.sol";

contract BinaryTreeTest is Test {
    BinaryTree public binaryTree;

    function setUp() public {
        DeployBinaryTree deployer = new DeployBinaryTree();
        binaryTree = deployer.run();
    }
}
