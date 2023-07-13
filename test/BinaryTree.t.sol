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
        BinaryTree.Node memory root = binaryTree.getRoot();

        binaryTree.deleteNode(3);

        /**
         *             5
         *            / \
         *           4   7
         *          /   / \
         *         2   6  8
         */

        console.log("root:", root.value); // 5
        console.log("root.left:", binaryTree.getNode(root.left).value); // 4
        console.log("root.right:", binaryTree.getNode(root.right).value); // 7
        console.log("root.left.left:", binaryTree.getNode(binaryTree.getNode(root.left).left).value); // 2
        console.log("root.right.left:", binaryTree.getNode(binaryTree.getNode(root.right).left).value); // 6
        console.log("root.right.right:", binaryTree.getNode(binaryTree.getNode(root.right).right).value); // 8

        assertEq(root.value, 5);
        assertEq(binaryTree.getNode(root.left).value, 4);
        assertEq(binaryTree.getNode(root.right).value, 7);

        // Deleted node should be empty
        bytes32 deletedTreeLocation = binaryTree.getNode(root.left).right;
        assertEq(deletedTreeLocation, "");
        assertEq(deletedTreeLocation, 0);

        assertEq(binaryTree.getNode(binaryTree.getNode(root.left).left).value, 2);
        assertEq(binaryTree.getNode(binaryTree.getNode(root.right).left).value, 6);
        assertEq(binaryTree.getNode(binaryTree.getNode(root.right).right).value, 8);
    }

    function test__deleteRoot() public buildTree {
        binaryTree.deleteNode(5);

        /**
         *             6
         *            / \
         *           3   7
         *          / \   \
         *         2  4   8
         */

        BinaryTree.Node memory root = binaryTree.getRoot();

        console.log("root:", root.value); // 6
        console.log("root.left:", binaryTree.getNode(root.left).value); // 3
        console.log("root.right:", binaryTree.getNode(root.right).value); // 7
        console.log("root.left.left:", binaryTree.getNode(binaryTree.getNode(root.left).left).value); // 2
        console.log("root.left.right:", binaryTree.getNode(binaryTree.getNode(root.left).right).value); // 4
        console.log("root.right.right:", binaryTree.getNode(binaryTree.getNode(root.right).right).value); // 8

        assertEq(root.value, 6);
        assertEq(binaryTree.getNode(root.left).value, 3);
        assertEq(binaryTree.getNode(root.right).value, 7);
        assertEq(binaryTree.getNode(binaryTree.getNode(root.left).left).value, 2);
        assertEq(binaryTree.getNode(binaryTree.getNode(root.left).right).value, 4);
        // Deleted node should be empty
        bytes32 deletedTreeLocation = binaryTree.getNode(root.right).left;
        assertEq(deletedTreeLocation, "");
        assertEq(deletedTreeLocation, 0);

        assertEq(binaryTree.getNode(binaryTree.getNode(root.right).right).value, 8);
    }

    function test__deleteNodeValueNotInTreeReverts() public buildTree {
        vm.expectRevert(BinaryTree.ValueNotInTree.selector);
        binaryTree.deleteNode(9);
    }

    //===================== TRAVERSAL TESTS ===================//

    function test__displayPreorder() public buildTree {
        uint256[] memory preorder = binaryTree.displayPreorder();

        assertEq(preorder[0], 5);
        assertEq(preorder[1], 3);
        assertEq(preorder[2], 2);
        assertEq(preorder[3], 4);
        assertEq(preorder[4], 7);
        assertEq(preorder[5], 6);
        assertEq(preorder[6], 8);
    }

    function test__displayInorder() public buildTree {
        uint256[] memory inorder = binaryTree.displayInorder();

        assertEq(inorder[0], 2);
        assertEq(inorder[1], 3);
        assertEq(inorder[2], 4);
        assertEq(inorder[3], 5);
        assertEq(inorder[4], 6);
        assertEq(inorder[5], 7);
        assertEq(inorder[6], 8);
    }

    function test__displayPostorder() public buildTree {
        uint256[] memory postorder = binaryTree.displayPostorder();

        assertEq(postorder[0], 2);
        assertEq(postorder[1], 4);
        assertEq(postorder[2], 3);
        assertEq(postorder[3], 6);
        assertEq(postorder[4], 8);
        assertEq(postorder[5], 7);
        assertEq(postorder[6], 5);
    }

    //===================== SEARCHING TESTS ===================//

    function test__findElementEmptyTreeReverts() public {
        vm.expectRevert(BinaryTree.TreeIsEmpty.selector);
        binaryTree.findElement(5);
    }

    function test__findElement() public buildTree {
        (bool found, BinaryTree.Node memory node) = binaryTree.findElement(5);

        assertTrue(found);
        assertEq(node.value, 5);
    }

    function test__findElementValueNotInTreeReverts() public buildTree {
        vm.expectRevert(BinaryTree.ValueNotInTree.selector);
        binaryTree.findElement(9);
    }
}

//===================== GETTER TESTS ===================//
