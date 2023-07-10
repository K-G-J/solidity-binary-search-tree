//SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.19;

import {Strings} from "@openzeppelin/contracts/utils/Strings.sol";

/**
 * @title BinaryTree
 * @dev This contract implements a Binary Search Tree data structure.
 *
 * A Binary Search Tree (BST) is a node-based binary tree data structure that has the following properties:
 * The left subtree of a node contains only nodes with values less than the node’s value.
 * The right subtree of a node contains only nodes with valuess greater than the node’s value.
 * Both the left and right subtrees must also be Binary Search Trees.
 *
 * For this implementation, duplicate values will be allowed, and nodes with values that are the same as the root node’s will be in the root node’s right subtree.
 */

contract BinaryTree {
    //===================== ERRORS ===================//

    error TreeIsEmpty();
    error ValueNotInTree();

    //===================== TYPES ===================//

    struct Node {
        uint256 value;
        bytes32 left;
        bytes32 right;
    }

    //===================== STATE VARIABLES ===================//

    mapping(bytes32 nodeAddress => Node) public tree;

    bytes32 private rootAddress;

    //===================== MODIFIERS ===================//

    modifier treeNotEmpty() {
        if (tree[rootAddress].value == 0 && tree[rootAddress].left == 0 && tree[rootAddress].right == 0) {
            revert TreeIsEmpty();
        }
        _;
    }

    //===================== INSERTION ===================//

    /**
     * @notice Inserts a node into the Binary Tree
     *
     *  Insertion (average log(n), worst case O(n)):
     *      - Start at the root node (rootAddress)
     *      - If the value is less than the current node's value, go left.
     *      - If the value is greater than the current node's value, go right.
     *      - Generate ID for the new node.
     *      - Insert the new node into the tree via the ID.
     *
     * @param value The value to be inserted
     * @return The address of the new node
     */
    function insert(uint256 value) external returns (bytes32) {
        Node memory root = tree[rootAddress];
        // If the tree is empty insert the value as the root
        if (root.value == 0 && root.left == 0 && root.right == 0) {
            root.value = value;
            root.left = 0;
            root.right = 0;
            tree[0] = root;
            rootAddress = generateId(value, 0);
            tree[rootAddress] = root;
            return rootAddress;
        } else {
            // If the tree is not empty find the correct place to insert the value
            bytes32 nodeId = insertHelper(value, rootAddress);
            return nodeId;
        }
    }

    /**
     * @notice Recursive helper function for inserting a node into the tree
     * @param value The value to be inserted
     * @param nodeAddress The address of the current node
     */
    function insertHelper(uint256 value, bytes32 nodeAddress) internal returns (bytes32 nodeId) {
        // Parent node
        Node memory node = tree[nodeAddress];

        // If the value is less than the current node, insert it to the left
        if (value < node.value) {
            // If the value is less than the current node, check if the left node is empty
            if (node.left == 0) {
                // If the left node is empty, insert the value
                nodeId = insertNode(value, nodeAddress, 0);
            } else {
                // If the left node is not empty, recursively call the function moving to the left
                insertHelper(value, node.left);
            }

            // Else the value is greater than the current node, insert it to the right
        } else {
            // If the value is greater than the current node, check if the right node is empty
            if (node.right == 0) {
                // If the right node is empty, insert the value
                nodeId = insertNode(value, nodeAddress, 1);
            } else {
                // If the right node is not empty, recursively call the function moving to the right
                insertHelper(value, node.right);
            }
        }
    }

    /**
     * @notice Internal function that inserts a node into the tree
     * @param value Value of the node
     * @param nodeAddress Address of the parent node
     * @param location Location of the node insertion in relation to the parent node (left = 0 or right = 1)
     */
    function insertNode(uint256 value, bytes32 nodeAddress, uint256 location) internal returns (bytes32 nodeId) {
        Node memory parentNode = tree[nodeAddress];
        nodeId = generateId(value, nodeAddress);
        if (location == 0) {
            // If the value is less than the current node insert it to the left
            parentNode.left = nodeId;
        } else {
            // If the value is greater than the current node insert it to the right
            parentNode.right = nodeId;
        }

        // Update the tree
        tree[nodeAddress] = parentNode;
        tree[nodeId] = Node(value, 0, 0);
    }

    /**
     * @notice Generates a unique id for the node
     * @param value Value of the node
     * @param parentAddress Address of the parent node
     */
    function generateId(uint256 value, bytes32 parentAddress) internal view returns (bytes32) {
        // Generate a unique hash id for the node
        return keccak256(abi.encodePacked(value, parentAddress, block.timestamp));
    }

    //===================== DELETION ===================//

    /**
     *  @notice Deletes a node from the Binary Tree
     *
     *  Deletion (average log(n), worst case O(n)):
     *      - Start at the root node (rootAddress)
     *      - If the value is less than the current node's value, go left.
     *      - If the value is greater than the current node's value, go right.
     *      - If the value is equal to the current node's value, start node deletion.
     *      - If the node has children, replace the node with the child.
     *      - If the leaf has no children, delete the leaf.
     *      - Have right preference over left when deleting.
     *
     * @param value The value to be deleted
     */
    function deleteNode(uint256 value) external treeNotEmpty returns (Node memory removedNode) {
        removedNode = deleteNodeHelper(value, "", rootAddress);
    }

    /**
     * @notice Recursive helper function for deleting a node from the tree
     * @param value The value to be deleted
     * @param parentAddress The address of the parent node
     * @param nodeAddress The address of the current node
     */
    function deleteNodeHelper(uint256 value, bytes32 parentAddress, bytes32 nodeAddress)
        internal
        returns (Node memory removedNode)
    {
        Node memory node = tree[nodeAddress];
        // If the value is equal to the current node's value, start node deletion
        if (node.value == value) {
            removedNode = deleteLeaf(parentAddress, nodeAddress);

            // If the value is less than the current node's value, go left
        } else if (value < node.value) {
            // If the left node is empty the value is not in the tree
            if (node.left == 0) {
                revert ValueNotInTree();
            } else {
                // If the left node is not empty, recursively call the function moving to the left
                // The current node becomes the parent node
                deleteNodeHelper(value, nodeAddress, node.left);
            }

            // Else the value is greater than the current node's value, go right
        } else {
            // If the right node is empty the value is not in the tree
            if (node.right == 0) {
                revert ValueNotInTree();
            } else {
                // If the right node is not empty, recursively call the function moving to the right
                // The current node becomes the parent node
                deleteNodeHelper(value, nodeAddress, node.right);
            }
        }
    }

    /**
     * @notice Deletes a node from the tree
     * @param parentAddress The address of the parent node
     * @param nodeAddress The address of the node to be deleted
     */
    function deleteLeaf(bytes32 parentAddress, bytes32 nodeAddress) internal returns (Node memory node) {
        Node memory parent = tree[parentAddress];
        node = tree[nodeAddress];

        // If the node has two children, replace the node with the maximum left subtree value
        if (node.left != 0 && node.right != 0) {
            // Find the minimum value in the right subtree
            uint256 minRightValue = findMin(node.right);
            // Delete the leaf with the minimum value from the right subtree
            deleteNodeHelper(minRightValue, nodeAddress, node.left);
            // Update the node to have the minimum value from the right subtree
            node.value = minRightValue;
            tree[nodeAddress] = node;

            // If the node has only a left child, update so parent points to left child and set the node to null (0)
        } else if (node.left != 0) {
            bytes32 leftChild = node.left;
            if (parent.left == nodeAddress) {
                parent.left = leftChild;
                tree[parentAddress] = parent;
                tree[nodeAddress] = Node(0, 0, 0);
            } else {
                parent.right = leftChild;
                tree[parentAddress] = parent;
                tree[nodeAddress] = Node(0, 0, 0);
            }

            // If the node has only a right child, update so parent points to right child and set the node to null (0)
        } else if (node.right != 0) {
            bytes32 rightChild = node.right;
            if (parent.left == nodeAddress) {
                parent.left = rightChild;
                tree[parentAddress] = parent;
                tree[nodeAddress] = Node(0, 0, 0);
            } else {
                parent.right = rightChild;
                tree[parentAddress] = parent;
                tree[nodeAddress] = Node(0, 0, 0);
            }

            // If the leaf has no children, delete the leaf and set the parent's child pointer to null (0)
        } else {
            if (parent.left == nodeAddress) {
                parent.left = 0;
                tree[parentAddress] = parent;
            } else {
                parent.right = 0;
                tree[parentAddress] = parent;
            }
            // Set the node to null (0)
            tree[nodeAddress] = Node(0, 0, 0);
        }
    }

    //===================== TRAVERSAL ===================//

    /**
     * @notice Displays the values in the tree preorder
     *
     * Preorder traversal (O(n)):
     *      - Visit the root
     *      - Traverse the left subtree, i.e., call Preorder(left->subtree)
     *      - Traverse the right subtree, i.e., call Preorder(right->subtree)
     *
     * @return An array of the values in the tree preorder
     */
    function displayPreOrder() external treeNotEmpty returns (uint256[] memory) {
        return displayPreOrderHelper(rootAddress, 0);
    }

    /**
     * @notice Recursive helper function for preorder traversal
     * @param nodeAddress The address of the current node
     * @param index The index of the current node value in return array
     * @return An array of the values in the tree in preorder
     */
    function displayPreOrderHelper(bytes32 nodeAddress, uint256 index) internal returns (uint256[] memory) {
        Node memory node = tree[nodeAddress];
        uint256 size = getTreeSize();
        uint256[] memory values = new uint256[](size);
        // Add the current node value to the array (0 will be the root)
        values[index] = node.value;
        // Keep traversing the left subtrees
        if (node.left != 0) {
            displayPreOrderHelper(node.left, index + 1);
        }
        // After, traverse the right subtrees
        if (node.right != 0) {
            displayPreOrderHelper(node.right, index + 1);
        }
        return values;
    }

    /**
     * @notice Displays the values in the tree inorder
     *
     * Inorder traversal (O(n)):
     *      - Traverse the left subtree, i.e., call Inorder(left->subtree)
     *      - Visit the root
     *      - Traverse the right subtree, i.e., call Inorder(right->subtree)
     *
     * @return An array of the values in the tree inorder
     * @dev Values are displayed in sorted order from the smallest to the largest value.
     */
    function displayInOrder() external treeNotEmpty returns (uint256[] memory) {
        return displayInOrderHelper(rootAddress, 0);
    }

    /**
     * @notice A recursive helper function for displaying the values in the tree inorder
     * @param nodeAddress The address of the current node
     * @param index The index of the current node value in return array
     */
    function displayInOrderHelper(bytes32 nodeAddress, uint256 index) internal returns (uint256[] memory) {
        Node memory node = tree[nodeAddress];
        uint256 size = getTreeSize();
        uint256[] memory values = new uint256[](size);
        // Keep traversing the left subtrees
        if (node.left != 0) {
            displayInOrderHelper(node.left, index + 1);
        }
        // Add the current node value to the array
        values[index - 1] = node.value;
        // After, traverse the right subtrees
        if (node.right != 0) {
            displayInOrderHelper(node.right, index + 1);
        }
        return values;
    }

    /**
     *  @notice Displays the values in the tree postorder
     *
     *  Postorder traversal (O(n)):
     *      - Traverse the left subtree, i.e., call Postorder(left->subtree)
     *      - Traverse the right subtree, i.e., call Postorder(right->subtree)
     *      - Visit the root
     *
     * @return An array of the values in the tree postorder
     */
    function displayPostOrder() external treeNotEmpty returns (uint256[] memory) {
        return displayPostOrderHelper(rootAddress, 0);
    }

    /**
     * @notice A recursive helper function for displaying the values in the tree postorder
     * @param nodeAddress The address of the current node
     * @param index The index of the current node value in return array
     */
    function displayPostOrderHelper(bytes32 nodeAddress, uint256 index) internal returns (uint256[] memory) {
        Node memory node = tree[nodeAddress];
        uint256 size = getTreeSize();
        uint256[] memory values = new uint256[](size);
        // Keep traversing the left subtrees
        if (node.left != 0) {
            displayPostOrderHelper(node.left, index + 1);
        }
        // After, traverse the right subtrees
        if (node.right != 0) {
            displayPostOrderHelper(node.right, index + 1);
        }
        // Add the current node value to the array
        values[index - 1] = node.value;
        return values;
    }

    //===================== SEARCHING ===================//

    /**
     * @notice Searches for a value in the tree
     *
     *  Search for a value in the tree (average log(n), worst case O(n)):
     *      - Start at the root node (rootAddress)
     *      - If the value is less than the current node, traverse the left subtree
     *      - If the value is greater than the current node, traverse the right subtree
     *      - If the value is equal to the current node, return true and the node
     *      - If the value is not in the tree, revert
     *
     * @param value The value to be searched for
     * @return True if the value is in the tree
     * @return The node if the value is in the tree
     */
    function findElement(uint256 value) public view returns (bool, Node memory) {
        return findElementHelper(value, rootAddress);
    }

    /**
     * @notice Recursive helper function for searching for a value in the tree
     * @param value The value to be searched for
     * @param nodeAddress The address of the current node
     * @return True if the value is in the tree
     * @return The node if the value is in the tree
     */
    function findElementHelper(uint256 value, bytes32 nodeAddress) internal view returns (bool, Node memory) {
        Node memory node = tree[nodeAddress];
        // If the value is equal to the current node, return true and the node
        if (node.value == value) {
            return (true, node);

            // If the value is less than the current node, traverse the left subtree
        } else if (value < node.value) {
            if (node.left == 0) {
                revert ValueNotInTree();
            } else {
                return findElementHelper(value, node.left);
            }

            // If the value is greater than the current node, traverse the right subtree
        } else {
            if (node.right == 0) {
                revert ValueNotInTree();
            } else {
                return findElementHelper(value, node.right);
            }
        }
    }

    //===================== GETTERS ===================//

    /**
     * @notice Returns the minimum value in the tree
     */
    function getMin() external view treeNotEmpty returns (uint256) {
        return findMin(rootAddress);
    }

    /**
     * @notice Recursive helper function for finding the minimum value in the tree from a given node
     * @param nodeAddress The address of the current node
     */
    function findMin(bytes32 nodeAddress) public view returns (uint256) {
        Node memory node = tree[nodeAddress];
        // If the left node is empty, the current node is the minimum value
        if (node.left == 0) {
            return node.value;
            // Else keep traversing the left subtrees
        } else {
            return findMin(node.left);
        }
    }

    /**
     * @notice Returns the maximum value in the tree
     */
    function getMax() external view treeNotEmpty returns (uint256) {
        return findMax(rootAddress);
    }

    /**
     * @notice Recursive helper function for finding the maximum value in the tree from a given node
     * @param nodeAddress The address of the current node
     */
    function findMax(bytes32 nodeAddress) public view returns (uint256) {
        Node memory node = tree[nodeAddress];
        // If the right node is empty, the current node is the maximum value
        if (node.right == 0) {
            return node.value;
            // Else keep traversing the right subtrees
        } else {
            return findMax(node.right);
        }
    }

    /**
     * @notice Constructs a string consisting of parenthesis and values from the binary tree with preorder traversal (root, left subtree, right subtree)
     * @dev Omits all the empty parenthesis pairs that do not affect the one-to-one mapping relationship between the string and the original binary tree.
     */
    function getTree() external view treeNotEmpty returns (string memory) {
        return treeToString(rootAddress);
    }

    /**
     * @notice Recursive helper function for converting the tree to a string with preorder traversal
     *
     *         - For each non-null node, append the node value to the string
     *         - For each non-leaf node append a pair of parentheses that encloses the preorder
     *         string of its child nodes.
     *         - If a node has a right child but no left child, include a pair of parentheses for
     *         the left null child.
     *
     * @param nodeAddress The address of the current node
     * @return The tree as a string with () for empty nodes
     */
    function treeToString(bytes32 nodeAddress) internal view returns (string memory) {
        // If only root, return the root value as a string
        if (getTreeSize() == 1) {
            uint256 rootValue = tree[rootAddress].value;
            return Strings.toString(rootValue);
        }
        // Else recursively add the left and right children to the string in parenthesis
        Node memory node = tree[nodeAddress];
        string memory treeString = Strings.toString(node.value);
        // If the node has a left child, add the left child to the string in parenthesis recursively
        if (node.left != 0) {
            treeString = string(abi.encodePacked(treeString, "(", treeToString(node.left), ")"));
        }
        // If the node has a right child, add the right child to the string in parenthesis recursively
        if (node.right != 0) {
            // If the node has a right child but no left child, add empty parenthesis to the string
            if (node.left == 0) {
                treeString = string(abi.encodePacked(treeString, "()"));
            }
            // Add the right child to the string in parenthesis recursively
            treeString = string(abi.encodePacked(treeString, "(", treeToString(node.right), ")"));
        }
        return treeString;
    }

    /**
     * @notice Returns the root node of the tree
     */
    function getRoot() public view treeNotEmpty returns (Node memory) {
        return tree[rootAddress];
    }

    /**
     * @notice Returns the size of the tree (number of nodes)
     */
    function getTreeSize() public view treeNotEmpty returns (uint256) {
        return getTreeSizeHelper(rootAddress);
    }

    /**
     * @notice Recursive helper function for finding the size of the tree
     *
     *      - Traverse all nodes of the tree (following a depth-first search pattern)
     *      - Sum up the count of nodes in the tree
     *
     * @param nodeAddress The address of the current node
     */
    function getTreeSizeHelper(bytes32 nodeAddress) internal view returns (uint256) {
        Node memory node = tree[nodeAddress];
        // If leaf node, having no children, return 1 representing this single node.
        if (node.left == 0 && node.right == 0) {
            return 1;
            // Else recursively call the function on the left and right subtrees
        } else {
            // If no left child, add 1 for current node to the count of nodes in the right subtree.
            if (node.left == 0) {
                return 1 + getTreeSizeHelper(node.right);
                // If no right child, add 1 for current node to the count of nodes in the left subtree.
            } else if (node.right == 0) {
                return 1 + getTreeSizeHelper(node.left);
                // If both left and right children, add 1 for current node to the count of nodes in both subtrees
            } else {
                return 1 + getTreeSizeHelper(node.left) + getTreeSizeHelper(node.right);
            }
        }
    }

    // TODO: GET TREE HEIGHT FUNCTION

    //===================== VALIDATION ===================//

    // TODO: VALIDATE TREE FUNCTION

    //===================== INVERSRION ===================//

    // TODO: INVERT TREE FUNCTION

    /**
     * An inverted form of a Binary Tree is another Binary Tree with left and right children of all non-leaf nodes interchanged. You may also call it the mirror of the input tree.
     * If you invert a Binary Search Tree is will no longer be a valid Binary Search Tree.
     */

    /*
        * These are inversion functions.
            - Invert the tree (average log(n)), worst case O(n)):
                - Start at the root node (rootAddress)
                - Invert the left subtree
                - Invert the right subtree
                - Swap the left and right pointers
    */
}
