# Contents

1. [后缀法解多项式](#postfix)
2. [汉诺塔](#hanoi)
3. [动态规划](#Dynamic_Programming)
4. [Merge/Quick 排序](#sort)
---
# 后缀法解多项式 <a name="postfix"></a>
* 构建Stack类：
```python
class Stack:                         
    def __init__(self):              
        self.items = []              
    def isEmpty(self):               
        return self.items == []      
    def push(self, item):            
        self.items.append(item)      
    def pop(self):                   
        return self.items.pop()      
    def peek(self):                  
        return self.items[-1]        
    def size(self):                  
        return len(self.items)       
```
* 将输入多项式修改为后缀表达式形式
例如：(3+2)*(4-1) = 32+41-×
```python
def input_to_postfix():
    import sys
    s = str(sys.argv[1])

    opStack = Stack() # 栈用于存储操作符
    outList = [] # 输出列表

    prec = {'+':1,'-':1,'*':2,'/':2,'(':0} # 定义操作符的优先级

    s = s.replace(' ', '')
    for i in s:
        if i not in '+-*/()': # 如果是操作数，则存入outList
            outList.append(i)
        else:
            if i == '(': # 如果是左括号，则压入opStack
                opStack.push(i)                       
            elif i == ')': # 如果是右括号，将opStack中的操作符挨个弹出并存入outList，直到遇到左括号
                op = opStack.pop()                                                
                while op != '(':                                                  
                    outList.append(op)                                            
                    op = opStack.pop()                                            
            else: 
                # 如果是操作符，则先将opStack中的优先级高于等于该操作符的其它操作符弹出并存入outList，
                # 再将此操作符压入opStack
                while(not opStack.isEmpty() and prec[opStack.peek()] >= prec[i] ):
                    outList.append(opStack.pop())                                 
                opStack.push(i)                                                   

    while not opStack.isEmpty(): # 最后将opStack中的所有操作符弹出并存入outList
        outList.append(opStack.pop()) 
    return outList
```
* 由后缀表达式计算最终结果
```python
def cal_postfix(outList):
    opStack = Stack() # 栈用于存储操作数                     
    for i in outList:                         
        if i not in '+-*/': # 如果是操作数，存入opStack
            opStack.push(i)                   
        else: # 如果是操作符，则从opStack弹出2个操作数，进行运算并将结果压入opStack
            o1 = opStack.pop()                
            o2 = opStack.pop()                
            n = eval(str(o2)+str(i)+str(o1))  
            opStack.push(n)

    return opStack.pop() # opStack最终保存最后结果
```
---
# 汉诺塔 <a name="hanoi"></a>
* 有三根杆子A，B，C。A杆上有N个(N>1)穿孔圆盘，盘的尺寸由下到上依次变小。要求按下列规则将所有圆盘移至C杆：
  1. 每次只能移动一个圆盘；
  2. 大盘不能叠在小盘上面。

```python
# 移动一堆disk
def moveTower(height, fromBar, interBar, toBar):                        
    if height >= 1:        
        # 把编号为height的disk上面的所有其它disk从fromBar移动到interBar, 借助toBar
        moveTower(height-1, fromBar, toBar, interBar) 
        
        # 把编号为height的disk从fromBar移动到toBar
        moveDisk(height, fromBar, toBar) 
        
        # 把刚刚移动到interBar上面的所有disk移动到toBar, 借助fromBar
        moveTower(height-1, interBar, fromBar, toBar) 

# 移动单个disk
def moveDisk(height, fromBar, toBar):                                   
    print("move Disk {} from {} to {}".format(height, fromBar, toBar))  
                                                                        
if __name__ == '__main__':                                              
    moveTower(3, "Bar1", "Bar2", "Bar3")  
```
---
# 动态规划 <a name="Dynamic_Programming"></a>
* 假设有一堆硬币，面额为1/5/10/25圆这几种，当需要找零63圆时，哪种方案硬币个数最少。
* 最先想到的是递归法：
```python
# 该dict很重要，用以保存中间计算结果，可以大大减小递归深度
# key为需要找零总额，value为找零硬币面额数组，例如，minResult['6'] = [1,5], 
# 表示6圆的最佳方案为1/5圆各一枚。
minResult = {} 
def calCoins(valueList, total):
    if total in valueList: # 如果找零总额在面额数组[1,5,10,25]中，直接返回
        minResult[str(total)] = [total]                        
        return [total]                                         
                                                               
    if str(total) in minResult: # 如果找零总额已经计算过了，则直接返回无须再算
        return minResult[str(total)]                           
                                                               
    minNum = total # 中间变量，保存循环中发现的最小方案所需的硬币个数
    coin = None # 中间变量，保存循环中发现的最小方案使用的硬币面额
    # 遍历valueList， 找出当前使用某个面额所需的最少硬币个数
    for v in [c for c in valueList if c < total]:
        # 递归，如果使用面额v，计算剩下的找零总额所需的最少硬币个数
        coins = calCoins(valueList, total-v)                   
        if len(coins) < minNum:                                
            minNum = len(coins)                                
            minResult[str(total-v)] = coins                    
            coin = v
    # 循环遍历完毕，更新minResult，保存找零总额为total的方案
    minResult[str(total)] = minResult[str(total-coin)] + [coin]
                                                               
    return minResult[str(total)]                               

if __name__ == '__main__':                                     
    k = 63                                                     
    coinValue = [1,5,10,25]                                    
    calCoins(coinValue, k)                                     
    print minResult[str(k)]                                                           
```
* 然后是非递归的动态规划法，比较一下：
```python
def dpCalCoins(valueList, total, minResult):
    # 从小到大遍历总找零数，这样做的好处是以后寻找更小总额方案时已经计算出了
    for c in range(total+1):                                   
        minNum = c # 中间变量，保存循环中发现的最小方案所需的硬币个数
        coin = None # 中间变量，保存循环中发现的最小方案使用的硬币面额
        # 遍历valueList， 找出当前使用某个面额所需的最少硬币个数
        for v in [i for i in valueList if i <= c]:
            # 初始化，程序需要，并非算法需要
            if str(c-v) not in minResult:                      
                minResult[str(c-v)] = []                       
            # 这里因为是从小到大遍历的total，所以minResult[str(c-v)]肯定已经算出了，这里是与递归的区别
            if len(minResult[str(c-v)]) <= minNum:             
                minNum = len(minResult[str(c-v)]) + 1          
                coin = v
        # 循环遍历完毕，更新minResult，保存找零总额为c的方案
        if coin is not None:                                   
            minResult[str(c)] = minResult[str(c-coin)] + [coin]
    return minResult                                           
                                                               
                                                               
if __name__ == '__main__':                                     
    k = 63                                                     
    coinValue = [1,5,10,25]                                                                      
    print dpCalCoins(coinValue, k, {})                         
```
---
# Merge/Quick 排序 <a name="sort"></a>
* Merge排序，思路为递归，将数组分为两段，假设左段与右段都为排序好的序列（典型递归思想），则通过Merge可得到最终排序好的序列
```python
def do_sort(l):
    if len(l) > 1: # 递归结束条件，序列长度大于1
        # 将序列分为左右两段
        mid = len(l) // 2
        left = l[:mid]
        right = l[mid:]
        
        # 左右两段分别排序
        do_sort(left)                        
        do_sort(right)                       

        # 把左右两段Merge成最终排序完成的序列
        i=0                                  
        j=0                                  
        k=0                                  
        while i<len(left) and j<len(right):
            # 分别从左右两段选择，较大的放入最终序列
            if left[i] < right[j]:           
                l[k] = right[j]              
                j += 1                       
            else:                            
                l[k] = left[i]               
                i += 1                       
            k += 1                           
        
        # 上面的while循环完成后，只有左段或者右段序列有剩余，
        # 不可能都有剩余，故下面2个while只会有一个执行
        
        # 防止左段序列还有剩余，依次放入最终序列
        while i<len(left):                   
            l[k] = left[i]                   
            i += 1                           
            k += 1                           
            
        # 防止右段序列还有剩余，依次放入最终序列
        while j<len(right):                  
            l[k] = right[j]                  
            j += 1                           
            k += 1                           
                                             
if __name__ == "__main__":                   
    l = [2,3,1,5,4,6]                        
    do_sort(l)                               
    print(l)
```
* Quick排序, 思路为找出pivot位置，使得其左边子序列均大于它，右边均小于它，然后再对子序列进行递归. 
总体思路类似于Merge排序，都是分治，但是Quick排序在原序里操作，较Merge排序节省空间，时间复杂度均为nlogn
```python
# first 为序列左边界，last为序列右边界
# 初始值为待排序序列的左右边界，随着递归变化
def do_sort(l,first,last):                       
    # 递归结束条件，序列左边界小于右边界，实际上等价于Merge排序中的子序列长度大于1
    if first < last: 
        mid = partition(l,first,last) # 找出分界点
        do_sort(l,first,mid-1) # 对左边子序列排序
        do_sort(l,mid+1,last)# 对右边子序列排序
                                                 
def partition(l,first,last):                     
    pivot = l[first] # 将分界值（pivot）设置为第一个数
    head = first + 1 # 除去pivot的剩余序列的头指针
    tail = last # 除去pivot的剩余序列的尾指针
                                                 
    done = False                                 
    while not done:
        # 移动头指针，直到发现小于pivot的元素，或者头尾指针交替
        while head <= tail and l[head] >= pivot: 
            head += 1     
        
        # 移动尾指针，直到发现大于pivot的元素，或者头尾指针交替
        while head <= tail and l[tail] <= pivot: 
            tail -= 1                            
        
        # 如果两个while循环后head仍然小于tail
        # 则表示head处的值小于pivot，tail处的值大于pivot，此时交换这两个值
        if head < tail:                          
            l[head], l[tail] = l[tail], l[head]  
        # 如果指针交替，表示指针左边全部大于pivot，右边全部小于pivot
        # 则结束循环，将pivot与右指针的值交换，交换右指针而不是左指针
        # 的原因是指针交替，右指针在左指针左边，它指向的值是左指针曾经指向
        # 过的，可以保证其值大于pivot，可以将其与pivot交换
        else:                                    
            l[tail], l[first] = l[first], l[tail]
            done = True                          
    return tail                                  

if __name__ == "__main__":                       
    l = [2,3,1,5,4,6]                            
    do_sort(l, 0, len(l)-1)                      
    print(l)  
```    