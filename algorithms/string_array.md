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
# [LeetCode] Longest Palindromic Substring
> Given a string s, find the longest palindromic substring in s. You may assume that the maximum length of s is 1000.

> Example:  
Input: "babad"
Output: "bab"
Note: "aba" is also a valid answer.  
> Example:  
Input: "cbbd"
Output: "bb"

寻找最长回文串（正反一样），直接思路为遍历每个char，找出以该char为中心，向两边伸展，能包含最长的回文串
遍历过程中，借助Manacherz算法减少重复搜索次数。  
https://www.felix021.com/blog/read.php?2040  
https://segmentfault.com/a/1190000008484167  
https://www.zhihu.com/question/30226229  

首先用一个非常巧妙的方式，将所有可能的奇数/偶数长度的回文子串都转换成了奇数长度：在每个字符的两边都插
入一个特殊的符号。比如 abba 变成 #a#b#b#a#， aba变成 #a#b#a#。 为了进一步减少编码的复杂度，在字符串的开始和
结尾插入特殊字符，这样就不用特殊处理越界问题。然后用一个数组 P[i] 来记录以字符s[i]为中心的最长回文子串向左/右扩张的长度。

![i2.png](https://raw.githubusercontent.com/ytnmgg/notebooks/master/algorithms/image/i2.PNG)

如图所示，C为遍历过程中保存的臂展最大的char的位置，R为其臂展最远点绝对坐标。i为当前char位置，P[i]保存的是位置i的char的
臂展（单边绝对长度），当i落入R以内时，可根据马拉车算法，减少重复计算次数。图中j=2C-i为i对于C的对称点，且P[j]已经计算过了。
根据回文串的性质，以C为中心，左右边R/2的char应该相同。  
* 当P[j]落在R以内时，即P[j]<R-i时，可以确定P[i]=P[j]。
* 当P[j]大于R-i时，P[i]至少为R-i，大于R-i的部分可以不是回文串，因为我们只能确定C左右R/2相同  
综上， `P[i] = min(R-i, P[2C-i])`  


```python
class Solution(object):
    def longestPalindrome(self, s):
        """
        :type s: str
        :rtype: str
        """
 
        # Transform S into T.
        # For example, S = "abba", T = "^#a#b#b#a#$".
        # ^ and $ signs are sentinels appended to each end to avoid bounds checking
        T = '#'.join('^{}$'.format(s))
        n = len(T)
        P = [0] * n
        C = R = 0
        for i in range (1, n-1):
            P[i] = (R > i) and min(R - i, P[2*C - i])
            
            # 在马拉车算法得到的P[i]的基础上，再左右扩展，直到不是回文串为止
            while T[i + 1 + P[i]] == T[i - 1 - P[i]]:
                P[i] += 1
    
            # 保存每次最远的臂展，因为我们总想要i落在R以内才能使用马拉车算法
            if i + P[i] > R:
                C, R = i, i + P[i]
    
        # 在P中间找出最大的值
        maxLen, centerIndex = max((n, i) for i, n in enumerate(P))
        return s[(centerIndex  - maxLen)//2: (centerIndex  + maxLen)//2] 
```
---
# [LeetCode] Regular Expression Matching 
> Implement regular expression matching with support for '.' and '*'.
'.' Matches any single character.
'*' Matches zero or more of the preceding element.
The matching should cover the entire input string (not partial).
The function prototype should be:
bool isMatch(const char *s, const char *p)
Some examples:
isMatch("aa","a") → false
isMatch("aa","aa") → true
isMatch("aaa","aa") → false
isMatch("aa", "a*") → true
isMatch("aa", ".*") → true
isMatch("ab", ".*") → true
isMatch("aab", "c*a*b") → true

动态规划法，由短到长逐个匹配
https://www.youtube.com/watch?v=l3hda49XcDE  
| 1 | ? | ? | ? | ? |  
| 0 | ? | ? | ? | ? |  
| 0 | ? | ? | ? | ? |  
| 0 | ? | ? | ? | ? |  
横轴为pattern串p，纵轴为待匹配串s，第一行为s为空时p的值对应的结果，第一列为p为空时不同的s对应
的匹配情况，因为空s与空p是匹配的，所以左上角为1。又空的p是无法匹配非空的s，所以第一列其它值皆0。
对于第一行，即空s，p是有办法匹配上的，比如`p="a*b*c*"`。
其它位置的算法： 

* 当前p值为`.`或者与当前s值相同，则当前位置p与s匹配，总匹配结果与前一个位置的p与s是否匹配有关
* 当前位置的p为`*`时，又分为两种情况
    * `*`号将其前一个值吃掉，比如`p=acb*`匹配`s=ac`, b被\*吃掉，这种情况下，如果p被吃字符前面的串能
    匹配当前s则总结果匹配，即例子中的`p=ac`匹配`s=ac`。
    * `*`号不吃前面的值，而是延伸前面的值，此时如果p前面的值是`.`或者与s当前值相同，当前p与s匹配，总的结果只需要当前p能匹配s之前的序列。比如`p=acb*`与`s=abb`，当p的`b*`匹配了s的第二个`b`，而且它还能匹配`s=ab`，最终结果为匹配。
```python
class Solution(object):
    def lengthOfLongestSubstring(self, s):
        """
        :type s: str
        :rtype: int
        """
        # 初始化表，全部为False
        t = [[False for _ in range(len(p)+1)] for _ in range(len(s)+1)]

        t[0][0] = True  # 空p匹配空s，故此数为1
        
        # 计算第一行，如果p为a*b*这种，即可匹配
        for i in range(2, len(p)+1):
            if p[i-1] == '*' and t[0][i-2]:
                t[0][i] = True
    
        for i in range(1, len(t)):
            for j in range(1, len(p)+1):
                if p[j-1] != '*' and (p[j-1] == '.' or p[j-1] == s[i-1]):
                    t[i][j] = t[i-1][j-1]  # p不为*， 直接对应匹配即可，总结果受之前结果影响
                elif p[j-1] == '*':
                    if t[i][j-2] is True:
                        t[i][j] = True  # *吃掉前一个字符，若往前推2个能匹配，则匹配
                    elif p[j-2] == s[i-1] or p[j-2] == '.':
                        t[i][j] = t[i-1][j]  # *不吃前一个字符，则若当前p能匹配上一个s，则匹配
                else:
                    t[i][j] = False
    
        return t[len(s)][len(p)]
```
