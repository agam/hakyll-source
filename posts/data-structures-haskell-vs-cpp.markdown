---
title: Comparison of data structures in C++ and Haskell
date: 2013-06-26
---

Comparison of Data Structures in C++ and Haskell
===

Once again, just to satisfy my curiosity, I want to do a tiny comparison of a basic feature in both languages, trying to see how data structures are implemented. Ok, I'm fairly certain how it works for in C++, I'm really just curious about Haskell.

C++ version
---

Haskell version
---

```haskell
data BinaryTree a = BinaryLeaf a | BinaryBranch (BinaryTree a) (BinaryTree a) deriving (Show)
data NaryTree a = NaryLeaf a | NaryBranch [NaryTree a] deriving (Show)

binarySum :: (Num a) => (BinaryTree a) -> a
binarySum (BinaryLeaf x) = x
binarySum (BinaryBranch a b) =  (binarySum a) + (binarySum b)

narySum :: (Num a) => NaryTree a -> a
narySum (NaryLeaf x) = x
narySum (NaryBranch b) = foldl (\acc x -> acc + (narySum x)) 0 b

--Create dummy binary and n-ary trees and print out their sum
main = let bt = BinaryBranch (BinaryLeaf 4) (BinaryLeaf 5)
           nt = NaryBranch ((NaryLeaf 4) : (NaryLeaf 5) : (NaryLeaf 6) : [])
       in do
          putStrLn ("BinarySum = " ++ show(binarySum bt))
          putStrLn ("NarySum = " ++ show(narySum nt))
```



