# SOLIDITY BINARY SEARCH TREE

## Description

A Solidity smart contract implementation of a Binary Search Tree.

Includes code for:

- Insertion into tree
- Deletion from tree
- Preoder traversal
- Inorder traversal
- Postorder traversal
- Find by value
- Find minimum value in tree
- Find maximum value in tree
- Get the root of the tree
- Get the size of the tree (number of nodes)
- Get the height of the tree (largest number of edges from the root to the most distant leaf node)

## Binary Search Tree

A Binary Search Tree (BST) is a type of binary tree data structure that has the following properties:

1. Each node has a value associated with it.
2. The values of all nodes in the left subtree of a node are less than the value of the node.
3. The values of all nodes in the right subtree of a node are greater than the value of the node.
4. Both the left and right subtrees of a node must also be binary search trees.

These properties allow for efficient lookup, addition, and deletion of items in the tree.

Consider the following example of a binary search tree:

```
        8
       / \
      3   10
     / \    \
    1   6    14
       / \   /
      4   7 13
```

In this tree, the root node is 8. All nodes to the left of 8 are smaller than 8, and all nodes to the right are larger. The same property holds for each subtree in the tree. For example, in the left subtree rooted at 3, 1 is to the left of 3 and is smaller, and 6 is to the right and is larger. This property is recursively true for all subtrees in the tree.

This structure makes binary search trees efficient for searches. If you're looking for a specific item, you can start at the root and, based on whether your item is larger or smaller, navigate either to the left or right child. This halves the number of potential nodes to search at each step, making the search operation very efficient.

This is the basic concept of a binary search tree. Note that there are many variations and enhancements of this basic structure that can provide additional properties and functionality, such as self-balancing trees, AVL trees, red-black trees, and B-trees, among others.
