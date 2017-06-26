# [LeetCode] Merge k Sorted Lists 
> Merge k sorted linked lists and return it as one sorted list. Analyze and describe its complexity. 

因为要merge多个链表，都去遍历的话复杂的较高。巧用优先队列，每次自动拿出最小的node，组成新的链表。

```python
# Definition for singly-linked list.
# class ListNode(object):
#     def __init__(self, x):
#         self.val = x
#         self.next = None

class Solution(object):
    def mergeKLists(self, lists):
        """
        :type lists: List[ListNode]
        :rtype: ListNode
        """
        
        from Queue import PriorityQueue
        dummy = ListNode(None)  # 添加链表头，便于处理越界问题
        curr = dummy
        q = PriorityQueue()
        for node in lists:
            if node: q.put((node.val,node))  # 优先队列里面保存一对（val，Node），val用于比较，实际用Node
        while q.qsize()>0:
            curr.next = q.get()[1]
            curr=curr.next
            
            # 从优先队列里面拿出来的实际上是个链表，我们只比较了头结点，
            # 把头节点插入curr以后，需要把头节点所在链表上的剩余部分放入优先队列继续比较
            if curr.next:
                q.put((curr.next.val, curr.next))
        return dummy.next
```
---
# [LeetCode] Reverse Nodes in k-Group
> Given a linked list, reverse the nodes of a linked list k at a time and return its modified list.
k is a positive integer and is less than or equal to the length of the linked list. If the 
number of nodes is not a multiple of k then left-out nodes in the end should remain as it is.
You may not alter the values in the nodes, only nodes itself may be changed. Only constant memory 
is allowed.  
For example：  
Given this linked list: 1->2->3->4->5  
For k = 2, you should return: 2->1->4->3->5  
For k = 3, you should return: 3->2->1->4->5  

反转链表，典型算法有3指针法，递归法等。这里使用递归法，递归巧妙的使用了回溯的思想：  

![i2.png](https://raw.githubusercontent.com/ytnmgg/notebooks/master/algorithms/image/i4.PNG)

如图所示，绿圈为待反转链表Node，对于当前`p`，只需递归找到`pn`，然后令`pn.next=p`，即可反转链表。
需要注意的是边界问题，最后一个Node的`pn`应该为`ph`，第一个Node的下一个Node为`pt`，即`p1.next=pt`

```python
# Definition for singly-linked list.
# class ListNode(object):
#     def __init__(self, x):
#         self.val = x
#         self.next = None

class Solution(object):
    def reverseKGroup(self, head, k):
        """
        :type head: ListNode
        :type k: int
        :rtype: ListNode
        """
        dummy = ListNode(None)
        dummy.next = head
        ph = dummy  # 把ph放在第一个Node的前一个位置上
        pt = ph
        while True:
            # 把pt放在最后一个Node的后一个位置上
            n = 0
            while n <= k:
                if pt is None:
                    break
                pt = pt.next
                n += 1
    
            # 序列没有k那么长，退出而不排序
            if n <= k:
                break
    
            # 使用回溯法反转ph和pt之间的链表
            # 由回溯函数可知pl为ph.next，即为链表内的原第一个Node，
            # 反转后为最后一个Node，它的下一个Node应该为pt
            pl = self.rev(ph.next, ph, pt)
            pl.next = pt
    
            # 重置ph和pt的位置，反转接下来的一段链表
            ph = pl
            pt = ph
        return dummy.next
    
    # p为移动指针，从链表头移动到尾，ph保存原链表第一个Node之前的位置，
    # pt保存原链最后一个Node之后的一个位置
    def rev(self, p, ph, pt):
        if p == pt:  # p移动到了最后Node之后，表示递归遍历完成。
            return ph # 返回链表第一个Node之前的位置，用于主函数中指向pt
        
        # 除了最后一次返回的是ph，每次返回的都是当前p的下一个Node
        pn = self.rev(p.next, ph, pt)
        
        # pn是当前p的下一个Node，用它指向当前p，实现反转
        pn.next = p 
        return p
```
