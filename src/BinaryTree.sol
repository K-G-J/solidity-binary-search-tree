//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

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
     *  Insertion (average log(n)), worst case O(n))
     *
     *  Start at the root node (rootAddress)
     *  If the value is less than the current node's value, go left.
     *  If the value is greater than the current node's value, go right.
     *  Generate ID for the new node.
     *  Insert the new node into the tree via the ID.
     *  Returns the address of the new node.
     */

    /**
     * @notice Inserts a node into the Binary Tree
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
     *  Deletion (average log(n)), worst case O(n)
     *
     *  Start at the root node (rootAddress)
     *  If the value is less than the current node's value, go left.
     *  If the value is greater than the current node's value, go right.
     *  If the value is equal to the current node's value, start node deletion.
     *  If the node has children, replace the node with the child.
     *  If the leaf has no children, delete the leaf.
     *  Have left preference over right when deleting.
     */

    /**
     * @notice Deletes a node from the Binary Tree
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
            // TODO: USE HELPER FUNCTIONS
            // Find the largest value in the left subtree
            bytes32 tempNodeAddress = node.left;
            while (tree[tempNodeAddress].right != 0) {
                tempNodeAddress = tree[tempNodeAddress].right;
            }
            uint256 tempValue = tree[tempNodeAddress].value;
            // Delete the leaf with the largest value from the bottom of left subtree
            deleteNodeHelper(tempValue, nodeAddress, node.left);
            // Update the node to have the largest value from the left subtree
            node.value = tempValue;
            tree[nodeAddress] = node;

            // If the node has only a left child, update to make parent point to left child
        } else if (node.left != 0) {
            bytes32 leftChild = node.left;
            if (parent.left == nodeAddress) {
                parent.left = leftChild;
                tree[parentAddress] = parent;
            } else {
                parent.right = leftChild;
                tree[parentAddress] = parent;
            }

            // If the node has only a right child, update to make parent point to right child
        } else if (node.right != 0) {
            bytes32 rightChild = node.right;
            if (parent.left == nodeAddress) {
                parent.left = rightChild;
                tree[parentAddress] = parent;
            } else {
                parent.right = rightChild;
                tree[parentAddress] = parent;
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
            tree[nodeAddress] = Node(0, 0, 0);
        }
    }

    //===================== TRAVERSAL ===================//

    /**
     *  Preorder traversal (O(n)):
     *      Visit the root.
     *      Traverse the left subtree, i.e., call Preorder(left->subtree)
     *      Traverse the right subtree, i.e., call Preorder(right->subtree)
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
     *  Inorder traversal (O(n)):
     *      Traverse the left subtree, i.e., call Inorder(left->subtree)
     *      Visit the root.
     *      Traverse the right subtree, i.e., call Inorder(right->subtree)
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
     *  Postorder traversal (O(n)):
     *      Traverse the left subtree, i.e., call Postorder(left->subtree)
     *      Traverse the right subtree, i.e., call Postorder(right->subtree)
     *      Visit the root
     *
     * @notice Displays the values in the tree postorder
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

    /*
        These are search functions.
            - Search for a value in the tree (average log(n)), worst case O(n)):
                - Start at the root node (rootAddress)
                - If the value is less than the current node, traverse the left subtree
                - If the value is greater than the current node, traverse the right subtree
                - If the value is equal to the current node, return true
                - If the value is not in the tree, return false
    */

    // search for a value in the tree
    function findElement(uint256 value) public view returns (bool) {
        return findElementHelper(value, rootAddress);
    }

    // recursive helper function for findElement
    function findElementHelper(uint256 value, bytes32 nodeAddress) internal view returns (bool) {
        Node memory node = tree[nodeAddress];
        if (node.value == value) {
            return true;
        } else if (node.value > value) {
            if (node.left == 0) {
                return false;
            } else {
                return findElementHelper(value, node.left);
            }
        } else {
            if (node.right == 0) {
                return false;
            } else {
                return findElementHelper(value, node.right);
            }
        }
    }

    //===================== GETTERS ===================//

    function getMin() public view treeNotEmpty returns (uint256) {
        return findMinHelper(rootAddress);
    }

    function findMinHelper(bytes32 nodeAddress) internal view returns (uint256) {
        Node memory node = tree[nodeAddress];
        if (node.left == 0) {
            return node.value;
        } else {
            return findMinHelper(node.left);
        }
    }

    function getMax() public view treeNotEmpty returns (uint256) {
        return findMaxHelper(rootAddress);
    }

    function findMaxHelper(bytes32 nodeAddress) internal view returns (uint256) {
        Node memory node = tree[nodeAddress];
        if (node.right == 0) {
            return node.value;
        } else {
            return findMaxHelper(node.right);
        }
    }

    // This function is used to test the tree, returns the nodes in the tree as a string
    function getTree() public view treeNotEmpty returns (string memory) {
        string memory result;
        Node memory node;
        bytes32 tempRoot = rootAddress;
        node = tree[tempRoot];
        while (node.left != 0 || node.right != 0) {
            node = tree[tempRoot];
            result = string(abi.encodePacked(result, " ", node.value));
            if (node.left != 0) {
                tempRoot = node.left;
            } else {
                tempRoot = node.right;
            }
        }

        return result;
    }

    function getRoot() public view treeNotEmpty returns (Node memory) {
        return tree[rootAddress];
    }

    function getTreeSize() public view treeNotEmpty returns (uint256) {
        return getTreeSizeHelper(rootAddress);
    }

    function getTreeSizeHelper(bytes32 nodeAddress) internal view returns (uint256) {
        Node memory node = tree[nodeAddress];
        if (node.left == 0 && node.right == 0) {
            return 1;
        } else {
            if (node.left == 0) {
                return 1 + getTreeSizeHelper(node.right);
            } else if (node.right == 0) {
                return 1 + getTreeSizeHelper(node.left);
            } else {
                return 1 + getTreeSizeHelper(node.left) + getTreeSizeHelper(node.right);
            }
        }
    }

    // TODO: GET TREE HEIGHT

    //===================== VALIDATION ===================//

    //===================== INVERSRION ===================//

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
