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

    //==================== INSERTION TESTS ====================//

    function test__insertionRoot() public {
        binaryTree.insert(5);

        BinaryTree.Node memory root = binaryTree.getRoot();

        console.log("root:", root.value); // 5

        assertEq(root.value, 5);
    }

    function test__insertion() public {
        binaryTree.insert(5);
        binaryTree.insert(3);
        binaryTree.insert(7);
        binaryTree.insert(2);
        binaryTree.insert(4);
        binaryTree.insert(6);
        binaryTree.insert(8);

        BinaryTree.Node memory root = binaryTree.getRoot();

        /**
         *             5
         *            / \
         *           3   7
         *          / \ / \
         *         2  4 6  8
         */

        console.log("root:", root.value); // 5
        console.log("root.left:", binaryTree.getNode(root.left).value); // 3
        console.log("root.right:", binaryTree.getNode(root.right).value); // 7
        console.log("root.left.left:", binaryTree.getNode(binaryTree.getNode(root.left).left).value); // 2
        console.log("root.left.right:", binaryTree.getNode(binaryTree.getNode(root.left).right).value); // 4
        console.log("root.right.left:", binaryTree.getNode(binaryTree.getNode(root.right).left).value); // 6
        console.log("root.right.right:", binaryTree.getNode(binaryTree.getNode(root.right).right).value); // 8

        assertEq(root.value, 5);
        assertEq(binaryTree.getNode(root.left).value, 3);
        assertEq(binaryTree.getNode(root.right).value, 7);
        assertEq(binaryTree.getNode(binaryTree.getNode(root.left).left).value, 2);
        assertEq(binaryTree.getNode(binaryTree.getNode(root.left).right).value, 4);
        assertEq(binaryTree.getNode(binaryTree.getNode(root.right).left).value, 6);
        assertEq(binaryTree.getNode(binaryTree.getNode(root.right).right).value, 8);
    }

    modifier buildTree() {
        binaryTree.insert(5);
        binaryTree.insert(3);
        binaryTree.insert(7);
        binaryTree.insert(2);
        binaryTree.insert(4);
        binaryTree.insert(6);
        binaryTree.insert(8);
        _;
    }

    //==================== DELETION TESTS ====================//

    function test__deleteLeaf() public buildTree {
        binaryTree.deleteNode(2);

        BinaryTree.Node memory root = binaryTree.getRoot();

        /**
         *             5
         *            / \
         *           3   7
         *            \ / \
         *            4 6  8
         */

        console.log("root:", root.value); // 5
        console.log("root.left:", binaryTree.getNode(root.left).value); // 3
        console.log("root.right:", binaryTree.getNode(root.right).value); // 7
        console.log("root.left.right:", binaryTree.getNode(binaryTree.getNode(root.left).right).value); // 4
        console.log("root.right.left:", binaryTree.getNode(binaryTree.getNode(root.right).left).value); // 6
        console.log("root.right.right:", binaryTree.getNode(binaryTree.getNode(root.right).right).value); // 8

        assertEq(root.value, 5);
        assertEq(binaryTree.getNode(root.left).value, 3);
        assertEq(binaryTree.getNode(root.right).value, 7);
        assertEq(binaryTree.getNode(binaryTree.getNode(root.left).right).value, 4);
        assertEq(binaryTree.getNode(binaryTree.getNode(root.right).left).value, 6);
        assertEq(binaryTree.getNode(binaryTree.getNode(root.right).right).value, 8);
    }

    function test__deleteParent() public buildTree {
        binaryTree.deleteNode(3);

        BinaryTree.Node memory root = binaryTree.getRoot();

        /**
         *             5
         *            / \
         *           4   7
         *          /   / \
         *         2   6  8
         */

        // console.log("root:", root.value); // 5
        // console.log("root.left:", binaryTree.getNode(root.left).value); // 4
        // console.log("root.right:", binaryTree.getNode(root.right).value); // 7
        // console.log("root.left.left:", binaryTree.getNode(binaryTree.getNode(root.left).left).value); // 2
        // console.log("root.left.right:", binaryTree.getNode(binaryTree.getNode(root.left).right).value); // 0
        // console.log("root.right.left:", binaryTree.getNode(binaryTree.getNode(root.right).left).value); // 6
        // console.log("root.right.right:", binaryTree.getNode(binaryTree.getNode(root.right).right).value); // 8

        // assertEq(root.value, 5);
        // assertEq(binaryTree.getNode(root.left).value, 4);
        // assertEq(binaryTree.getNode(root.right).value, 7);

        // Deleted node
        // assertEq(binaryTree.getNode(binaryTree.getNode(root.left).left).right, "");
        // assertEq(binaryTree.getNode(binaryTree.getNode(root.left).left).value, 0);

        // assertEq(binaryTree.getNode(binaryTree.getNode(root.left).left).value, 2);
        // assertEq(binaryTree.getNode(binaryTree.getNode(root.right).left).value, 6);
        // assertEq(binaryTree.getNode(binaryTree.getNode(root.right).right).value, 8);
    }

    function test__deleteRoot() public buildTree {}

    function test__deleteValueNotInTreeReverts() public buildTree {}
}
