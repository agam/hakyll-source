---
title: Comparison of data structures in C++ and Haskell
date: 2013-06-26
---

Comparison of Data Structures in C++ and Haskell
===

Once again, just to satisfy my curiosity, I want to do a tiny comparison of a basic feature in both languages, trying to see how data structures are implemented. Ok, I'm fairly certain how it works for in C++, I'm really just curious about Haskell.

C++ version
---

```C
#include <iostream>
#include <memory>
#include <vector>

struct BinaryNode {
  int val;
  BinaryNode *leftchild, *rightchild;
  BinaryNode(int v, BinaryNode* lc = nullptr, BinaryNode* rc = nullptr)
    : val(v), leftchild(lc), rightchild(rc) {}
};

struct NaryNode {
  int val;
  std::vector<NaryNode*> children;
  NaryNode(int v, std::vector<NaryNode*>& c) : val(v), children(c) {}
};

int binarySum(BinaryNode* node) {
  if (node == nullptr) {
    return 0;
  }
  return node->val + binarySum(node->leftchild) + binarySum(node->rightchild);
}

int narySum(NaryNode* node) {
  if (node == nullptr) {
    return 0;
  }
  int sum = node->val;
  for (const auto it : node->children) {
    sum += narySum(it);
  }
  return sum;
}

// Create dummy binary and n-ary trees and print out their sum
int main() {
  std::unique_ptr<BinaryNode> bnode1(new BinaryNode(4));
  std::unique_ptr<BinaryNode> bnode2(new BinaryNode(5));
  std::unique_ptr<BinaryNode> broot(new BinaryNode(0, bnode1.get(), bnode2.get()));
  std::cout << "BinarySum = " << binarySum(broot.get()) << std::endl;

  std::vector<NaryNode*> children;
  std::unique_ptr<NaryNode> nnode1(new NaryNode(4, children));
  std::unique_ptr<NaryNode> nnode2(new NaryNode(5, children));
  std::unique_ptr<NaryNode> nnode3(new NaryNode(6, children));
  children.push_back(nnode1.get());
  children.push_back(nnode2.get());
  children.push_back(nnode3.get());
  std::unique_ptr<NaryNode> nroot(new NaryNode(0, children));
  std::cout << "NarySum = " << narySum(nroot.get()) << std::endl;
}
```

Assembly highlights:

Uploaded the full file as a [Gist](https://gist.github.com/agam/5872178) (it's 6437 lines long, we aren't in _Hello World_ territory any more; on the other hand, this program would have been much longer in C.

The function `_Z9binarySumP10BinaryNode` is defined near the top, and the function `_Z7narySumP8NaryNode` right under it.

The assembly code follows along almost exactly as the C++ code above (of course all the struct offsets are "just added" and you don't see the members being accessed directly).

The recursion is more obviously visible for the first function, where you see a pattern of "call the function", "call the function again" and then add the node value to it. For the second function, you can see calls to `vector<NaryNode>::begin()` and `vector<NaryNode>::end()` at the beginning of the loop, and the test 'n' jump and the recursive call in the middle of the body.

It is useful also to see how `main()` works here, you can see three calls to the `BinaryNode` constructor (`_ZN10BinaryNodeC1EiPS_S0_`), and then similar stuff for the `NaryNode` objects. At the end are multiple calls to the destructors (similar to `callq	_ZNSt10unique_ptrI8NaryNodeSt14default_deleteIS0_EED1Ev`).

Most of the rest of the code is the definition of these functions (vector begin/end and unique_ptr delete etc.)

Note: I found a better way to show the assembly <-> source correspondence, in an interactive way: [GCC Explorer](http://gcc.godbolt.org/) and I'll use that next time, it's just way more convenient. Also, I've been showing unoptimized assembly, which is _just noise_, will refer to `-O2` next time.

Haskell version
---

```haskell
data BinaryTree a = BinaryLeaf a | BinaryBranch (BinaryTree a) (BinaryTree a)
data NaryTree a = NaryLeaf a | NaryBranch [NaryTree a]

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

Assembly highlights:

Uploaded the [full file (core) as a Gist](https://gist.github.com/agam/5974455) 

`main` is present as `main1` near the bottom, which has two calls to `Handle.Text.hPutStr2` 

The binary sum is unpacked quite straightforwardly :-

```haskell
main_$sbinarySum =
  \ (ds_dBk :: BinaryTree Type.Integer) ->
    case ds_dBk of _ {
      BinaryLeaf x_aaA -> x_aaA;
      BinaryBranch a_aaB b_aaC ->
        Type.plusInteger
          (main_$sbinarySum a_aaB) (main_$sbinarySum b_aaC)
    }
```

whereas the nary sum is less so :-

```haskell
main_$snarySum =
  \ (ds_dtA :: NaryTree Type.Integer) ->
    case ds_dtA of _ {
      NaryLeaf x_aad -> x_aad;
      NaryBranch b_aae -> lgo_r1MR lvl_r1MQ b_aae
    }

lgo_r1MR =
  \ (z_atM :: Type.Integer)
    (ds_atN :: [NaryTree Type.Integer]) ->
    case ds_atN of _ {
      [] -> z_atM;
      : x_atS xs_atT ->
        lgo_r1MR
          (Type.plusInteger z_atM (main_$snarySum x_atS))
          xs_atT
    }
```

with the second function being defined for iteration. I uploaded a gist with the [assembly output](https://gist.github.com/agam/5974501), which is of course tedious and quite spaghetti-like.

Here is an example of the nary leaf:

```nasm
.globl Main_NaryLeaf_closure
.type Main_NaryLeaf_closure, @object
Main_NaryLeaf_closure:
	.quad	Main_NaryLeaf_info
.text
	.align 8
	.quad	4294967301
	.quad	0
	.quad	15
Main_NaryLeaf_info:
.LcBb:
	addq $16,%r12
	cmpq 144(%r13),%r12
	ja .LcBg
	movq $Main_NaryLeaf_con_info,-8(%r12)
	movq %r14,0(%r12)
	leaq -7(%r12),%rbx
	jmp *0(%rbp)
.LcBg:
	movq $16,192(%r13)
.LcBe:
	movl $Main_NaryLeaf_closure,%ebx
	jmp *-8(%r13)
	.size Main_NaryLeaf_info, .-Main_NaryLeaf_info
```

Running time
---

Pretty much on par here:

```shell
$ time ./cpptree
BinarySum = 9
NarySum = 15

real	0m0.005s
user	0m0.000s

$ time ./haskelltree 
BinarySum = 9
NarySum = 15

real	0m0.004s
user	0m0.000s
sys	0m0.000s
```

Fast compilation, comparable run-time, shorter code ... we're talking serious competition here :)
