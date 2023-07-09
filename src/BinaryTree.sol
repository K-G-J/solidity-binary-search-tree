//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.19;

contract BinaryTree {
    struct Node {
        uint256 value;
        bytes32 left;
        bytes32 right;
    }

    mapping(bytes32 nodeAddress => Node) private tree;

    bytes32 private rootAddress;

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
        if (root.value == 0) {
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
        // Else the value is greater than the current node, insert it to the right
        if (value < node.value) {
            // If the value is less than the current node, check if the left node is empty
            if (node.left == 0) {
                // If the left node is empty, insert the value
                nodeId = insertNode(value, nodeAddress, 0);
            } else {
                // If the left node is not empty, recursively call the function moving to the left
                insertHelper(value, node.left);
            }
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
     *  If the leaf has children, replace the leaf with the child.
     *  If the leaf has no children, delete the leaf.
     *  Have left preference over right when deleting.
     */

    /**
     * @notice Deletes a node from the Binary Tree
     * @param value The value to be deleted
     */
    function deleteNode(uint256 value) public {
        deleteNodeHelper(value, rootAddress);
    }

    /**
     * @notice Recursive helper function for deleting a node from the tree
     * @param value The value to be deleted
     * @param nodeAddress The address of the current node
     */
    function deleteNodeHelper(uint256 value, bytes32 nodeAddress) internal {
        Node memory node = tree[nodeAddress];
        // If the value is equal to the current node's value, start node deletion
        if (node.value == value) {
            deleteLeaf(nodeAddress);
            // If the value is less than the current node's value, go left
        } else if (value < node.value) {
            // If the left node is empty the value is not in the tree
            if (node.left == 0) {
                return;
            } else {
                // If the left node is not empty, recursively call the function moving to the left
                deleteNodeHelper(value, node.left);
            }
            // Else the value is greater than the current node's value, go right
        } else {
            // If the right node is empty the value is not in the tree
            if (node.right == 0) {
                return;
            } else {
                // If the right node is not empty, recursively call the function moving to the right
                deleteNodeHelper(value, node.right);
            }
        }
    }

    /**
     * @notice Deletes a node (leaf) from the tree
     * @param nodeAddress The address of the node to be deleted
     */
    function deleteLeaf(bytes32 nodeAddress) internal {
        Node memory node = tree[nodeAddress];

        // If the leaf has two children, replace the leaf with the maximum left subtree value
        if (node.left != 0 && node.right != 0) {
            // Find the largest value in the left subtree
            bytes32 tempNodeAddress = node.left;
            while (tree[tempNodeAddress].right != 0) {
                tempNodeAddress = tree[tempNodeAddress].right;
            }
            uint256 tempValue = tree[tempNodeAddress].value;
            // Delete the leaf with the largest value from the bottom of left subtree
            deleteNodeHelper(tempValue, node.left);
            // Update the leaf to have the largest value from the left subtree
            node.value = tempValue;

            // If the leaf has only a left child, update the node to make parent point to left child
        } else if (node.left != 0) {
            node.value = tree[node.left].value;
            node.left = tree[node.left].left;
            node.right = tree[node.left].right;
            tree[nodeAddress] = node;

            // If the leaf has only a right child, update the node to make parent point to right child
        } else if (node.right != 0) {
            node.value = tree[node.right].value;
            node.left = tree[node.right].left;
            node.right = tree[node.right].right;
            tree[nodeAddress] = node;

            // If the leaf has no children, delete the node and set the parent's child pointer to null (0)
        } else {
            tree[nodeAddress] = Node(0, 0, 0);
        }
    }

    //===================== TRAVERSAL ===================//

    /* 
        * These are traversal functions.
            - Preorder traversal (O(n)):
                - Start at the root node (rootAddress)
                - Visit the node
                - Traverse the left subtree
                - Traverse the right subtree
            - Inorder traversal (O(n)):
                - Start at the root node (rootAddress)
                - Traverse the left subtree
                - Visit the node
                - Traverse the right subtree
            - Postorder traversal (O(n)):
                - Start at the root node (rootAddress)
                - Traverse the left subtree
                - Traverse the right subtree
                - Visit the node
    */

    // inorder traversal
    function displayInOrder() public {
        displayInOrderHelper(rootAddress);
    }

    // recursive helper function for inorder traversal
    function displayInOrderHelper(bytes32 nodeAddress) internal {
        Node memory node = tree[nodeAddress];
        if (node.left != 0) {
            displayInOrderHelper(node.left);
        }
        // console.log(node.value);
        if (node.right != 0) {
            displayInOrderHelper(node.right);
        }
    }

    // preorder traversal
    function displayPreOrder() public {
        displayPreOrderHelper(rootAddress);
    }

    // recursive helper function for preorder traversal
    function displayPreOrderHelper(bytes32 nodeAddress) internal {
        Node memory node = tree[nodeAddress];
        // console.log(node.value);
        if (node.left != 0) {
            displayPreOrderHelper(node.left);
        }
        if (node.right != 0) {
            displayPreOrderHelper(node.right);
        }
    }

    // post order traversal
    function displayPostOrder() public {
        displayPostOrderHelper(rootAddress);
    }

    // recursive helper function for postorder traversal
    function displayPostOrderHelper(bytes32 nodeAddress) internal {
        Node memory node = tree[nodeAddress];
        if (node.left != 0) {
            displayPostOrderHelper(node.left);
        }
        if (node.right != 0) {
            displayPostOrderHelper(node.right);
        }
        // console.log(node.value);
    }

    // This function is used to test the tree, returns the nodes in the tree as a string
    function getTree() public view returns (string memory) {
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

    /*
        - Here are some other functions that occasionally accompany tree implementations.
    */
    function findMin() public view returns (uint256) {
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

    function findMax() public view returns (uint256) {
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

    function getRoot() public view returns (uint256) {
        if (tree[rootAddress].value != 0) {
            return tree[rootAddress].value;
        }

        revert("Tree is empty");
    }

    function getTreeSize() public view returns (uint256) {
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
}
