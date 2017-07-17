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
> Implement regular expression matching with support for '`.`' and '`*`'.  
'`.`' Matches any single character.  
'`*`' Matches zero or more of the preceding element.  
The matching should cover the entire input string (not partial).  
The function prototype should be:  
bool isMatch(const char `*s`, const char `*p`)  
Some examples:  
isMatch("aa","a") → false  
isMatch("aa","aa") → true  
isMatch("aaa","aa") → false  
isMatch("aa", "a\*") → true  
isMatch("aa", ".\*") → true  
isMatch("ab", ".\*") → true  
isMatch("aab", "c\*a\*b") → true  

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
---
# [LeetCode] Wildcard Matching  
> Implement wildcard pattern matching with support for '?' and '`*`'.  
'?' Matches any single character.  
'`*`' Matches any sequence of characters (including the empty sequence).  
The matching should cover the entire input string (not partial).  
The function prototype should be:  
bool isMatch(const char `*s`, const char `*p`)  
Some examples:  
isMatch("aa","a") → false  
isMatch("aa","aa") → true  
isMatch("aaa","aa") → false  
isMatch("aa", "\*") → true  
isMatch("aa", "a\*") → true  
isMatch("ab", "?\*") → true  
isMatch("aab", "c\*a\*b") → false  


算法与上面的正则匹配类似
```python
class Solution(object):
    def isMatch(self, s, p):
        """
        :type s: str
        :type p: str
        :rtype: bool
        """
        t = [[False for _ in range(len(p)+1)] for _ in range(len(s)+1)]
        t[0][0] = True
    
        for i in range(1, len(p)+1):
            if p[i-1] == '*' and t[0][i-1]:
                t[0][i] = True
    
        for i in range(1, len(s)+1):
            for j in range(1, len(p)+1):
                if p[j-1] != '*' and (p[j-1] == s[i-1] or p[j-1] == '?'):
                    t[i][j] = t[i-1][j-1]
                elif p[j-1] == '*':
                    if t[i][j-1]:  # *代表空
                        t[i][j] = True
                    elif t[i-1][j]:  # *代表匹配任意
                        t[i][j] = True
    
        return t[len(s)][len(p)]
```
---
# [LeetCode] Valid Parentheses
> Given a string containing just the characters '(', ')', '{', '}', '[' and ']', determine if 
the input string is valid. The brackets must close in the correct order, "()" and "()[]{}" are 
all valid but "(]" and "([)]" are not.

```python
class Solution(object):
    def isValid(self, s):
        """
        :type s: str
        :rtype: bool
        """
        stack = []  # 保存括号，遇到左括号入栈，遇到右括号弹栈检查
        # 括号类型map，用于检查括号是否匹配
        l = {"(": 1, "{": 2, "[": 3}
        r = {")": 1, "}": 2, "]": 3}
        for i in s:
            if i in l:
                stack.append(i)
            elif i in r:
                if len(stack) == 0:
                    return False
    
                op = stack.pop()
                if r[i] != l[op]:
                    return False
    
        if len(stack) != 0:
            return False
        else:
            return True
```
---
# [LeetCode] Generate Parentheses
> Given n pairs of parentheses, write a function to generate all combinations 
of well-formed parentheses.  
For example, given n = 3, a solution set is:  
```
[
  "((()))",
  "(()())",
  "(())()",
  "()(())",
  "()()()"
]
```
DFS回溯：  
http://blog.csdn.net/yutianzuijin/article/details/13161721  
http://www.cnblogs.com/grandyang/p/4444160.html  
实际上就是暴力遍历。


```python
class Solution(object):
    def generateParenthesis(self, n):
        """
        :type n: int
        :rtype: List[str]
        """

        out = []
        self.dfs(n, n, "", out)
        return out
    
    # left和right分别为剩余的左右括号数，s为中间变化量，out保存最后结果
    def dfs(self, left, right, s, out):
        if left == 0 and right == 0:  # 没有剩余括号，即n个左右括号都用光了，得到一个解
            out.append(s)

        if left > 0:  # 左括号还有剩余，可以直接加到s里面
            self.dfs(left-1, right, s+'(', out)
            
        # 右括号还有剩余，只能是s里面的左括号多过右括号时，才能继续往s里面加左括号
        if right > 0 and left < right:  
            self.dfs(left, right-1, s+')', out)
```
---
# [LeetCode] Longest Valid Parentheses 
> Given a string containing just the characters '(' and ')', find the length of the longest 
valid (well-formed) parentheses substring.  
For "(()", the longest valid parentheses substring is "()", which has length = 2.  
Another example is ")()())", where the longest valid parentheses substring is "()()", which 
has length = 4. 

此题难点是要求最大连续valid，而不是直接找出所有的valid然后加起来就可以了。  
变通思路，通过入栈出栈，把所有valid的都消灭了，stack里面剩下的就是非valid的。只需要用stack记住
括号的位置，则可以知道非valid的括号在string中的位置，然后遍历string，找出两个非valid括号之间的最大距离。
即找到了最大连续的valid括号序列。

```python
class Solution(object):
    def longestValidParentheses(self, s):
        """
        :type s: str
        :rtype: int
        """
        sLen = len(s)
        stack = []  # 保存括号位置的栈
        for i in range(sLen):
            if s[i] == '(':
                stack.append(i)
            else:
                if len(stack) != 0 and s[stack[-1]] == '(':
                    stack.pop()  # 配对到valid括号，直接丢掉
                else:
                    stack.append(i)
    
        stack = [-1] + stack + [sLen]  # 添加头尾，便于处理越界问题
        maxV = 0
        for i in range(1, len(stack)):  # 遍历找出最大距离
            maxV = max(stack[i]-stack[i-1]-1, maxV)
        return maxV
```
---
# [LeetCode] Substring with Concatenation of All Words 
> You are given a string, s, and a list of words, words, that are all of the same length. 
Find all starting indices of substring(s) in s that is a concatenation of each word in words 
exactly once and without any intervening characters.  
For example, given:  
s: "barfoothefoobarman" words: ["foo", "bar"]  
You should return the indices: [0,9].  
(order does not matter). 

滑动窗口法。  
```
s序列:
|  wLen  |  wLen  |  wLen  |  wLen  |
```
将s分割为数个窗口，窗口长度为待寻找子串长度（wLen）。分为大小2层循环，外层大循环`step=1`，遍历次数为
单个窗口长度，内层小循环`step=wLen`，循环次数为窗口个数，如此2层遍历即可cover整个s序列。

```python
class Solution(object):
    def findSubstring(self, s, words):
        """
        :type s: str
        :type words: List[str]
        :rtype: List[int]
        """
        
        sLen = len(s)
        wCnt = len(words)
        if sLen == 0 or wCnt == 0:
            return []
        wLen = len(words[0])
        wMap = {}  # 保存words中word的出现次数
        for word in words:
            wMap.setdefault(word, 0)
            wMap[word] += 1
    
        out = []
        # 外层大循环
        for i in range(wLen):
            wMapNew = {}  # 保存在s中找到的word及其出现次数
            count = 0  # 保存满足要求的word的总个数
            left = i  # 滑动窗的最左边沿
    
            # 滑窗从i开始往s尾部滑动，每次跳wLen长度
            # i相当于窗口offset，滑窗每次跳动，都去检验窗口内的序列是否满足要求
            for j in range(i, sLen-wLen+1, wLen):
                word = s[j:wLen+j]  # 取出滑窗内的序列
    
                if word in wMap and wMap[word] > 0:  # 如果序列是需要的
                    wMapNew.setdefault(word, 0)
                    wMapNew[word] += 1  # 更新找到的word字典
    
                    if wMapNew[word] <= wMap[word]:
                        # 如果找到的word还没有超过需要找的个数，则为有效word
                        count += 1
                    else:
                        # 否则，对于某特定word，已经找到足额的个数了，则此word无效
                        # 此时不能简单的把已经找到的其它word丢弃，将滑窗移动一个step，
                        # 而应该大踏步移动滑窗至重复位置，开始新的寻找（重复点及其之前
                        # 已无必要保留，反正会重复）比如，s="adbbadc", words=["a","b","c","d"],
                        # 找到第二个b时，前面已经找到了a,d,b，则b超额，此时不需要移动滑窗，从d
                        # 开始寻找，而应该直接跳过d和第一个b，直接从第二个b开始寻找。
                        while wMapNew[word] > wMap[word]:
                            cutWord = s[left:wLen+left]
                            left += wLen
                            wMapNew[cutWord] -= 1
                            if wMapNew[cutWord] < wMap[cutWord]:
                                count -= 1
    
                    if count == wCnt:  # 找到valid的word个数足够，保存左边界至输出列表
                        out.append(left)
                        
                        # 去掉找到的第一个word，滑窗前跳一个wLen，继续搜索
                        wMapNew[s[left:left+wLen]] -= 1  
                        count -= 1
                        left += wLen
                else:
                    # 序列不是需要的，滑窗向前跳动wLen长度
                    # 为什么不是跳动1个单位，因为有外层i的存在，可以保证整个s都能被cover
                    wMapNew = {}
                    count = 0
                    left = j+wLen
                    continue
    
        return out
```
---
# [LeetCode] Edit Distance 
> Given two words word1 and word2, find the minimum number of steps required to convert word1 to word2. 
(each operation is counted as 1 step.) You have the following 3 operations permitted on a word:  
a) Insert a character  
b) Delete a character  
c) Replace a character  

典型DP问题，用`dp[i][j]`表示从`word1[0:i]`(第1个到第i-1个字符)到`word2[0:j]`所需的最小步数。  
考虑边沿状态：  
* `dp[0][0]` 表示`word1=word2=""`所需的转换步数，显然为`0`
* `dp[i][0]` 表示`word2=""`所需的转换步数，此时对`word1`只能用delete操作，故`dp[i][0]=i`
* `dp[0][j]` 表示`word1=""`所需的转换步数，此时对`word2`只能用delete操作，故`dp[0][j]=j`

考虑完边沿状态，再来看普通状态：  
* 如果当前字符相同，即`word1[i-1]=word2[i-1]`，则不需要做任何操作，即`dp[i][j]=dp[i-1][j-1]`
* 如果不同，则要考虑题中的三种操作：
  * Replace: 将`word1[i-1]`替换为`word2[j-1]`，使得`word1[0:i]=word2[0:j]`，则当前步数较前一步多1步，
  即`dp[i][j]=dp[i-1][j-1]+1`
  * Delete: 删除`word1[i-1]`，使得`word1[0:i-1]=word2[0:j]`，则当前步数为`word1[0:i-1] to word2[0:j]`的
  步数再加删除这1步，即`dp[i][j]=dp[i-1][j]+1`
  * Insert: 将`word2[j-1]`插入到`word1`中，使得`word1[0:i]+word2[j-1]=word2[0:j]`，则当前步数为
  `word1[0:i] to word2[0:j-1]`的步数再加上插入这一步，即`dp[i][j]=dp[i][j-1]+1`

  上面3种操作，取最小值即为dp的当前值。
  
```python
class Solution(object):
    def minDistance(self, word1, word2):
        """
        :type word1: str
        :type word2: str
        :rtype: int
        """
        m = len(word1)
        n = len(word2)
        dp = [[0]*(n+1) for _ in range(m+1)]  # dp中的(i,j)表示word中的(i-1,j-1)位置
        for i in range(1, n+1):  # 初始化word1为空的情况
            dp[0][i] = i
        for i in range(1, m+1):  # 初始化word2为空的情况
            dp[i][0] = i

        for i in range(1, m+1):
            for j in range(1, n+1):
                if word1[i-1] == word2[j-1]:  # 当前字符相同，则不需要操作步数
                    dp[i][j] = dp[i-1][j-1]
                else:  # 否则从3中操作中取最小步数
                    dp[i][j] = min(dp[i-1][j-1]+1, dp[i-1][j]+1, dp[i][j-1]+1)
        return dp[m][n]
```
---
# [LeetCode] Minimum Window Substring 
> Given a string S and a string T, find the minimum window in S which will contain all the 
characters in T in complexity O(n).  
For example,  
S = "ADOBECODEBANC"  
T = "ABC"  
Minimum window is "BANC"  
Note:
If there is no such window in S that covers all characters in T, return the empty string "".  
If there are multiple such windows, you are guaranteed that there will always be only one unique minimum window in S. 

滑动窗口法取最短包含子串
  
```python
    import collections
    
    # need为hash，保存每个字符还需要的个数
    # missing为int，保存总的字符需要的个数
    need, missing = collections.Counter(t), len(t)
    
    # s[i:j]是当前窗口，s[I:J]是最终结果
    i = I = J = 0
    
    for j, c in enumerate(s, 1):
        if need[c] > 0:  # 找到一个字符，总需求满足一个，故减1
            missing -= 1
        need[c] -= 1  # 该字符需求个数减1，因为是Counter，故不存在的字符的初始值为0
        
        # 如果总需求个数递减为0，即找到了所有的，则移动当前滑动窗口的左边界，
        # 使得滑窗左边界落到下一个合适的字符上，这里的下一个合适位置选取比较有技巧
        if missing <= 0:
            while i<j and need[s[i]]<0:
                need[s[i]] += 1
                i += 1
            # not J表示初始状态，j-i<=J-I表示取最短子串，保存至最终结果I,J
            if not J or j-i <= J-I:
                I,J = i,j
    return s[I:J]
```
