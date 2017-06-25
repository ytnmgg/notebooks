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
表示，尾巴指针移动到该char上一次出现位置的下一个位置，然后头指针继续前进，如此可以保证头尾之间始终不会
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
