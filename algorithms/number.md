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
---
# [LeetCode] Trapping Rain Water 
>  Given n non-negative integers representing an elevation map where the width of each bar is 1, 
compute how much water it is able to trap after raining.  
For example,  
Given [0,1,0,2,1,0,1,3,2,1,2,1], return 6.  
```
       |
   |   || | 
 | || ||||||
```
装水问题，从头i开始，找到一个高于或者等于当前位置值的j，则(i,j)之间最多装i与j的位置差乘以高度差，
其中，还要减去ij之间其它柱子占的空间。  
若找不到高于等于i位置的j，即i以后的柱子都矮于i位置的柱子，则从最后一个柱子往回找，重复刚刚的步骤，
但是这次一定能找到高于最后一个柱子的位置（即i位置）

```python
class Solution(object):
    def trap(self, height):
        """
        :type height: List[int]
        :rtype: int
        """
        
        if len(height) < 3:
            return 0
        i = 0
        out = 0
        while i < len(height):
            j = i + 1
            v = 0  # 保存装水量
            
            # 寻找高于或等于i位置柱子的另一个柱子
            while j < len(height) and height[j] < height[i]:
                v += height[i] - height[j]
                j += 1
            # 找到了，保存这一过程的水量，以j为起始点继续找
            if i + 1 < j < len(height):
                out += v
                i = j
            elif i + 1 == j:  # 排除相邻连个柱子的情况，2个柱子无法装水
                i = j
            else:  # j == len(height)  # 没找到，从最后个柱子开始往回找
                j = i
                m = len(height) - 1  # 记录开始寻找后的起始点
                while m > j:
                    n = m - 1  # 移动指针
                    vv = 0
                    # 直到n位置的柱子高于等于m位置的柱子为止
                    while n > j and height[n] < height[m]:
                        vv += height[m] - height[n]
                        n -= 1
                    m = n  # 找到了，保存这一过程的水量，以n为起始点继续找
                    out += vv
                break
    
        return out
```
---
# [LeetCode] 3Sum
> Given an array S of n integers, are there elements a, b, c in S such that a + b + c = 0? 
Find all unique triplets in the array which gives the sum of zero.
Note: The solution set must not contain duplicate triplets.  
For example, given array S = [-1, 0, 1, 2, -1, -4],
A solution set is:
[
  [-1, 0, 1],
  [-1, -1, 2]
]

求3个数的和， 思路类似于Container With Most Water，即用夹逼方法，由两头往中间走，找出满足要求的2个数。

```python
class Solution(object):
    def threeSum(self, nums):
        """
        :type nums: List[int]
        :rtype: List[List[int]]
        """
        nums = sorted(nums)  # 先排序，然后才能用夹逼
        out = []
        for i in range(len(nums)):
            if i > 0 and nums[i] == nums[i-1]:  # 排除重复结果
                continue
    
            # 2sum 夹逼， j和k一头一尾，往中间走
            j = i+1
            k = len(nums) - 1
            while j<k:
                if nums[i] + nums[j] + nums[k] == 0:
                    out.append([nums[i], nums[j], nums[k]])
                    j += 1
                    k -= 1
                    while j < k and nums[j] == nums[j-1]:  # 排除重复结果
                        j += 1
                    while j < k and nums[k] == nums[k+1]:  # 排除重复结果
                        k -= 1
                elif nums[i] + nums[j] + nums[k] < 0:  # 总和不够，小头往前靠，增大总和
                    j += 1
                elif nums[i] + nums[j] + nums[k] > 0:  # 总和超额， 大头往回走，减小总和
                    k -= 1
                    
        return out
```
---
# [LeetCode] 3Sum Closest 
> Given an array S of n integers, find three integers in S such that the sum is closest 
to a given number, target. Return the sum of the three integers. You may assume that each 
input would have exactly one solution.  
For example, given array S = {-1 2 1 -4}, and target = 1.
The sum that is closest to the target is 2. (-1 + 2 + 1 = 2).

上个题的变化，方法类似

```python
class Solution(object):
    def threeSumClosest(self, nums, target):
        """
        :type nums: List[int]
        :type target: int
        :rtype: int
        """
        nums = sorted(nums)
        out = nums[0] + nums[1] + nums[2]

        for i in range(len(nums)):
            if i > 0 and nums[i] == nums[i-1]:
                continue
    
            # 2sum 夹逼
            j = i+1
            k = len(nums) - 1
            while j<k:
    
                if abs(target - (nums[i] + nums[j] + nums[k])) < abs(target-out):
                    out = nums[i] + nums[j] + nums[k]
    
                if nums[i] + nums[j] + nums[k] == target:
                    return target
                elif nums[i] + nums[j] + nums[k] < target:
                    j += 1
                elif nums[i] + nums[j] + nums[k] > target:
                    k -= 1
        return out
```
---
# [LeetCode] Sudoku Solver
> Write a program to solve a Sudoku puzzle by filling the empty cells.
Empty cells are indicated by the character '.'.
You may assume that there will be only one unique solution. 
```
|5|3|.|.|7|.|.|.|.|
|6|.|.|1|9|5|.|.|.|
|.|9|8|.|.|.|.|6|.|
|8|.|.|.|6|.|.|.|3|
|4|.|.|8|.|3|.|.|1|
|7|.|.|.|2|.|.|.|6|
|.|6|.|.|.|.|2|8|.|
|.|.|.|4|1|9|.|.|5|
|.|.|.|.|8|.|.|7|9|
```
数独游戏，典型的回溯搜索，合适就继续，不合适就回退。

```python
class Solution(object):
    def solveSudoku(self, board):
        """
        :type board: List[List[str]]
        :rtype: void Do not return anything, modify board in-place instead.
        """
        rowList = [[] for i in range(9)]  # 保存每一列的已经用了的数
        colList = [[] for i in range(9)]  # 保存每一行的已经用了的数
        boxList = [[] for i in range(9)]  # 保存每一个9宫格已经用了的数
    
        for i in range(9):  # 遍历棋盘，为上面3个List赋值
            for j in range(9):
                if board[i][j] != '.':
                    rowList[i].append(board[i][j])
                    boxList[i//3*3+j//3].append(board[i][j])
                if board[j][i] != '.':
                    colList[i].append(board[j][i])
                
        def check(i, j):  # 给board[i][j]填值
            if i == 9:  # 前9行填满了，结束
                return True
                
            m = i if j + 1 < 9 else i + 1  # 下一个i
            n = j + 1 if j + 1 < 9 else 0  # 下一个j
            
            if board[i][j] != '.':  # board上(i,j)处已经有数，继续递归填下一个位置(m,n)
                if check(m, n):  # 如果以后的位置都填好了，就返回True给上一级
                    return True
            else:
                for k in range(1, 10):  # 找一个数填到(i,j)
                    # 如果该数在当前行/列/九宫格均没出现过，则为有效数
                    if str(k) not in rowList[i] and str(k) not in colList[j] and str(k) not in boxList[i // 3 * 3 + j // 3]:
                        board[i][j] = str(k)
                        rowList[i].append(str(k))
                        colList[j].append(str(k))
                        boxList[i//3*3+j//3].append(str(k))
                        if check(m, n):  # 检查下一个位置，若之后的都填好，则返回True给上一级
                            return True
                            
                        # 以后的位置行不通，找不到数返回True，则把刚刚填的数pop掉，
                        # 用for循环继续尝试下一个k
                        rowList[i].pop()  
                        colList[j].pop()
                        boxList[i // 3 * 3 + j // 3].pop()
    
                board[i][j] = '.'

        check(0, 0)
```
---
# [LeetCode] N-Queens
> The n-queens puzzle is the problem of placing n queens on an n×n chessboard such that no two queens attack each other.
Given an integer n, return all distinct solutions to the n-queens puzzle.
Each solution contains a distinct board configuration of the n-queens' placement, where 'Q' and '.' 
both indicate a queen and an empty space respectively.  
For example,  
There exist two distinct solutions to the 4-queens puzzle:
```
[
 [".Q..",  // Solution 1
  "...Q",
  "Q...",
  "..Q."],

 ["..Q.",  // Solution 2
  "Q...",
  "...Q",
  ".Q.."]
]
```
N皇后问题，行列斜线都不能有重复  
解法同上数独游戏，用递归回溯

```python
class Solution(object):
    def solveNQueens(self, n):
        """
        :type n: int
        :rtype: List[List[str]]
        """
        out = []
        import copy
        def mark(i, temp):
            if i == n:
                tt = copy.deepcopy(temp)
                tt = ["".join(lines) for lines in tt]
                out.append(tt)
                return
            for j in range(n):  # 横着的n个位置，每个都试一下
                for k in range(i):  # 往回的k行，每一行都验证一下
                    if temp[k][j] == 'Q':  # 当前列的前面每一行不能有Q
                        break
                    if i-k-1 >= 0 and j-k-1 >= 0 and temp[i-k-1][j-k-1] == 'Q':  # 左斜上不能有Q
                        break
                    if i-k-1 >= 0 and j+k+1 < n and temp[i-k-1][j+k+1] == 'Q':  # 右斜上不能有Q
                        break
                else:  # 没有找到重复的Q，当前位置可以用
                    temp[i][j] = 'Q'
                    mark(i+1, temp)
                    temp[i][j] = '.'
        for i in range(n):  # 第一行，横着每个位置都试一下
            temp = [['.' for _ in range(n)] for _ in range(n)]
            temp[0][i] = 'Q'
            mark(1, temp)
        return out
```
---
# [LeetCode] First Missing Positive 
> Given an unsorted integer array, find the first missing positive integer.  
For example,  
Given [1,2,0] return 3,  
and [3,4,-1,1] return 2.  
Your algorithm should run in O(n) time and uses constant space.  

算法要求使用常量的空间，则想到原地替换，思路同计数排序（Counting sort）：  
http://www.cnblogs.com/ccsccs/articles/4216113.html  

```python
class Solution(object):
    def firstMissingPositive(self, nums):
        """
        :type nums: List[int]
        :rtype: int
        """
        
        i = 0
        while i < len(nums):
            # 假设i位置上的值为a，把a放到a位置上去。把a位置上的值放到i位置上来
            if 1 <= nums[i] <= len(nums) and nums[i] != nums[nums[i] - 1]:
                tmp = nums[i]
                nums[i] = nums[tmp - 1]
                nums[tmp - 1] = tmp
            else:
                i += 1
        # 遍历nums，如果i不等于nums[i]，则i为第一个缺失的正数
        for i in range(len(nums)):
            if nums[i] != i+1:
                return i+1
        else:
            return len(nums)+1
```
---
# [LeetCode] Maximum Subarray 
> Find the contiguous subarray within an array (containing at least one number) which has the largest sum.  
For example, given the array [-2,1,-3,4,-1,2,1,-5,4],  
the contiguous subarray [4,-1,2,1] has the largest sum = 6. 

求最大和子串，用动态规划

```python
class Solution(object):
    def maxSubArray(self, nums):
        """
        :type nums: List[int]
        :rtype: int
        """
        maxSoFar = nums[0]  # 到目前为止的最大值
        maxEndingHere = nums[0]  # 到目前为止，以当前值为结尾的最大值
        for i in range(1,len(nums)):
            maxEndingHere = max(maxEndingHere+nums[i], nums[i])
            maxSoFar = max(maxSoFar, maxEndingHere)
        return maxSoFar
```
