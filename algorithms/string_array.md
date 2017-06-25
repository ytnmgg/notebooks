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
# [LeetCode] Longest Substring Without Repeating Characters
> Given a string, find the length of the longest substring without repeating characters.

> Examples:  
> Given `"abcabcbb"`, the answer is `"abc"`, which the length is 3.  ···
> Given `"bbbbb"`, the answer is `"b"`, with the length of 1.  
> Given `"pwwkew"`, the answer is `"wke"`, with the length of 3.   
Note that the answer must be a substring, `"pwke"` is a subsequence and not a substring.

蠕虫法：头尾两个指针，头先动，尾巴不动，每个char最近出现的位置用字典保存，当头发现当前char已经出现过，
尾巴指针移动到该char上一次出现位置的下一个位置，然后头指针继续前进，如此可以保证头尾之间始终不会
有重复的char出现。每次移动，都将最大的头尾距离保存。

```python
class Solution(object):
    def lengthOfLongestSubstring(self, s):
        """
        :type s: str
        :rtype: int
        """
        
        start = maxLength = 0
        usedChar = {}
        
        for i in range(len(s)):
            if s[i] in usedChar and start <= usedChar[s[i]]:
                start = usedChar[s[i]] + 1
            else:
                maxLength = max(maxLength, i - start + 1)

            usedChar[s[i]] = i

        return maxLength
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
        if len(A)>len(B):
            A,B=B,A
        if not A:
            return B[k]
        if k==len(A)+len(B)-1:
            return max(A[-1],B[-1])
        i=len(A)//2
        j=k-i
        if A[i]>B[j]:
            #Here I assume it is O(1) to get A[:i] and B[j:]. In python, it's not but in cpp it is.
            return self.findKth(A[:i],B[j:],i)
        else:
            return self.findKth(A[i:],B[:j]
```
