# Contents

1. [后缀法解多项式](#postfix)
2. [汉诺塔](#hanoi)
3. [动态规划](#Dynamic_Programming)
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