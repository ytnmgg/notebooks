# [LeetCode]Two Sum
> Given an array of integers, return indices of the two numbers such that they add up to a specific target.
You may assume that each input would have exactly one solution, and you may not use the same element twice.  

> Example:   
`nums = [2, 7, 11, 15], target = 9, return [0, 1]`.

Create a map to store the index and the remaining value for that index:
```python
class Solution(object):
   def twoSum(self, nums, target):
        """
        :type nums: List[int]
        :type target: int
        :rtype: List[int]
        """
        maps = {}

        for i in range(len(nums)):
            if nums[i] in maps:
                return [maps[nums[i]], i]
            maps[target-nums[i]] = i

        return []
```
---
# [LeetCode] Median of Two Sorted Arrays
> There are two sorted arrays nums1 and nums2 of size m and n respectively.  
Find the median of the two sorted arrays. The overall run time complexity should be O(log (m+n)).

> Example 1:  
nums1 = [1, 3]
nums2 = [2]
The median is 2.0  
Example 2:  
nums1 = [1, 2]
nums2 = [3, 4]
The median is (2 + 3)/2 = 2.5

求第k大的数的问题，用到了二分法的思想来减少搜索次数：  

如图，A出左半段i个数， 则B还需要出j=k-i个数来保证merge以后的序列左边有k个数，此时A和B的左边绿色一共有k个数。  
最好的情况是A[i]恰好等于B[j]，两个序列merge以后，左边绿色部分刚刚是k个，则第k大的数即为A[i]或B[j]。

![i1.png](https://raw.githubusercontent.com/ytnmgg/notebooks/master/algorithms/image/i1.PNG)

但是，如图所示，假如A[i]>B[j]，则merge以后的序列的第k大的数不可能出现在右边红箭头的更右边，因为黄色虚线框中
的个数已经超过了k个，同理merge以后的序列第k大的数也不可能出现在左边红色箭头的更左边，因为绿色虚线框中的个数
还不够k个（A和B的绿色部分加起来为k个）。所以要找的第k大的数在两个红色箭头中间部分，即只需要在A[:i]和B里面找第k大的数，
更进一步，因为merge后的第k大出现在红色箭头之间，则B的左边绿色部分j=k-i个数一定在merge后序列的前k个数里面，
则只需在A[:i]和B[j:]中找出i个数，然后与刚刚的k-i个数一同凑成k个数，第k大数便找到。

同理，当A[i]<B[j]，只需要在A与B[:j]中寻找第k大的数，更进一步，A中的前i个数已经确定在meger后序列的前k个数中，
即只需要在A[i:]和B[:j]中再找出前k-i=j个数即可。
```python
class Solution(object):
    def findMedianSortedArrays(self, nums1, nums2):
        """
        :type nums1: List[int]
        :type nums2: List[int]
        :rtype: float
        """
        l=len(nums1)+len(nums2)  #  序列长度为两序列之和
        # 如果长度为奇数，即是要找第一半大的那个数
        # 如果长度为偶数， 中位数为中间两个数的均值
        return self.findKth(nums1,nums2,l//2) if l%2==1 else (self.findKth(nums1,nums2,l//2-1)+self.findKth(nums1,nums2,l//2))/2.0
            
            
    def findKth(self,A,B,k):
        if len(A)>len(B):  # A始终为较短的序列
            A,B=B,A
        if not A:  # 结束条件1， A已经折半空了
            return B[k]
        if k==len(A)+len(B)-1:  # 结束条件2， k在A+B序列的最后面
            return max(A[-1],B[-1])
        i=len(A)//2  #  将A折半，二分查找
        j=k-i
        
        # 如下2个判断详见上面分析
        if A[i]>B[j]:
            return self.findKth(A[:i],B[j:],i)
        else:
            return self.findKth(A[i:],B[:j]
```
---
# [LeetCode] Container With Most Water
> Given n non-negative integers a1, a2, ..., an, where each represents a point at coordinate (i, ai). n vertical lines 
are drawn such that the two endpoints of line i is at (i, ai) and (i, 0). Find two lines, which together with x-axis 
forms a container, such that the container contains the most water.  
Note: You may not slant the container and n is at least 2. 

一排柱子，高低不同，找出两根，最多能装多少水。常规思路是遍历数组，找出两两组合，求最大差值。
复杂度为O(N^2)，其实可以从两头往中间找，排除掉一部分柱子：  
```
   |  
   |  |     |  
|  |  |  |  |  
|  |  |  |  |  
```
如上图所示，当最后一根柱子高于第一根柱子时，第一根和最后一根柱子的装水量为V，第一根柱子不动，
由最后一根再往前找，不可能找到比V大的柱子，因为水的高度由矮柱子（即第一根柱子）决定，从后往前找，
水面宽度是越来越小的，即V越来越小。所以此时要找到更大的V，需要从第一根柱子开始往后找。类似的，
若最后一根柱子小于第一根，则只需要从最后一根开始往前找即可。


```python
class Solution(object):
    def maxArea(self, height):
        """
        :type height: List[int]
        :rtype: int
        """
        
        maxV = 0
        i = 0
        j = len(height) - 1
    
        while i < j:
            maxV = max(maxV, (j - i) * min(height[i], height[j]))  # 每次移动，都保存最大水量
            if height[j] > height[i]:
                i += 1
            else:
                j -= 1
        return maxV
```
