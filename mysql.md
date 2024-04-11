- [基础](#基础)
  - [select语句where条件group by ,having , order by,limit的顺序及用法](#select语句where条件group-by-having--order-bylimit的顺序及用法)
  - [列值如果有null，不等于要小心，可能不包含](#列值如果有null不等于要小心可能不包含)
  - [distinct](#distinct)
  - [CHAR\_LENGTH](#char_length)
  - [时间](#时间)
    - [运算](#运算)
    - [比较](#比较)
    - [格式化](#格式化)
  - [CROSS JOIN](#cross-join)
  - [求平均AVG、四舍五入ROUND](#求平均avg四舍五入round)
  - [IFNULL](#ifnull)
  - [HAVING](#having)
  - [HAVING支持聚合函数，WHERE不行](#having支持聚合函数where不行)
  - [AVG](#avg)
  - [UNION](#union)
  - [IF](#if)
  - [窗口函数OVER](#窗口函数over)
  - [排序](#排序)
  - [正则表达式-空格](#正则表达式-空格)
  - [删除](#删除)
  - [GROUP\_CONCAT](#group_concat)
- [LeetCode题目收藏](#leetcode题目收藏)
  - [1174. 即时食物配送 II](#1174-即时食物配送-ii)
  - [550. 游戏玩法分析 IV](#550-游戏玩法分析-iv)
  - [1141. 查询近30天活跃用户数](#1141-查询近30天活跃用户数)
  - [1045. 买下所有产品的客户](#1045-买下所有产品的客户)
  - [1731. 每位经理的下属员工数量](#1731-每位经理的下属员工数量)
  - [180. 连续出现的数字](#180-连续出现的数字)
  - [1164. 指定日期的产品价格](#1164-指定日期的产品价格)
  - [1204. 最后一个能进入巴士的人](#1204-最后一个能进入巴士的人)
  - [626. 换座位](#626-换座位)
  - [602. 好友申请 II ：谁有最多的好友](#602-好友申请-ii-谁有最多的好友)
  - [585. 2016年的投资](#585-2016年的投资)
  - [176. 第二高的薪水](#176-第二高的薪水)
  - [1327. 列出指定时间段内所有的下单产品](#1327-列出指定时间段内所有的下单产品)


# 基础
## select语句where条件group by ,having , order by,limit的顺序及用法
语句顺序:
- select 选择的列
- from 表
- where 查询的条件
- group by 分组属性 having 分组过滤的条件
- order by 排序属性
- limit 起始记录位置，取记录的条数

## 列值如果有null，不等于要小心，可能不包含

>例子：
编写解决方案，报告每个奖金 少于 1000 的员工的姓名和奖金数额。

```sql
Employee table:
+-------+--------+------------+--------+
| empId | name   | supervisor | salary |
+-------+--------+------------+--------+
| 3     | Brad   | null       | 4000   |
| 1     | John   | 3          | 1000   |
| 2     | Dan    | 3          | 2000   |
| 4     | Thomas | 3          | 4000   |
+-------+--------+------------+--------+
Bonus table:
+-------+-------+
| empId | bonus |
+-------+-------+
| 2     | 500   |
| 4     | 2000  |
+-------+-------+

SELECT e.name,b.bonus
FROM Employee e LEFT JOIN Bonus b
ON e.empId=b.empId
WHERE b.bonus<1000 OR b.bonus is null
```
bonus可能是null，则不能被bonus<1000覆盖，需要单独写出来：b.bonus is null

原因：
普通编程语言里的布尔型只有 true 和 false 两个值，这种逻辑体系被称为二值逻辑。而 SQL 语言里，除此之外还有第三个值 unknown，因此这种逻辑体系被称为三值逻辑
三个真值之间有下面这样的优先级顺序
- AND 的情况：false ＞ unknown ＞ true
- OR 的情况：true ＞ unknown ＞ false

unknown是因关系数据库采用了 NULL 而被引入的，他不是“未知”的这个意思，而是“无意义”的这个意思。而null是指“未知”的意思

注意：要想和 null 比较 只能用 is null 或者 is not null，这样才会返回true或者false。null和<,>,=,<>这些放在一起结果永远是unknown，比如如 2=null，结果肯定是unknown，而unknown在三值逻辑中不是true也不是false，在写where子句的筛选条件时尤其要注意。

## distinct
```sql
select distinct(password), username from user;
```
上面句子以为是用password去重，实际效果还是password+username组合到一起去重
也就是：distinct加不加括号，不改变意义，distinct始终会把后面跟着的所有列一起作为去重条件

> 注意：DISTINCT子句将所有NULL值视为相同的值


## CHAR_LENGTH
计算字符串中字符数的最佳函数是 CHAR_LENGTH(str)，不管汉字、数字或是字母都算是一个字符。
另一个常用的函数 LENGTH(str) ，返回字符串 str 的字节数，某些字符包含多于 1 个字节。

以字符 '¥' 为例：CHAR_LENGTH() 返回结果为 1，而 LENGTH() 返回结果为 2，因为该字符串包含 2 个字节。

> - UTF8： 一个汉字3个字节、一个数字或字母1个字节
> - GBK：一个汉字2个字节、一个数字或字母1个字节
> - utf8mb4: 一个汉字4个字节、一个数字或字母1个字节

## 时间

日期
CURDATE()、CURRENT_DATE()、CURRENT_DATE
返回例如：2017-11-14

时间
NOW()、CURRENT_TIMESTAMP()、CURRENT_TIMESTAMP，LOCALTIME()、LOCALTIME、LOCALTIMESTAMP()、LOCALTIMESTAMP
返回例如：2017-11-14 13:47:36

### 运算
DATE_ADD(date,INTERVAL exp unit)，DATE_SUB(date,INTERVAL exp unit)
例如：date_add('2017-11-13 20:20:20',interval '1:2' minute_second)，返回：2017-11-13 20:21:22

类似的：adddate() addtime()

### 比较
1. datediff(t1, t2)：比较天数差
0: t1 == t2
正数: t1 > t2
负数: t1 < t2

2. timestampdiff(时间类型, 日期1, 日期2)：比较时间差
时间类型：SECOND、MINUTE、HOUR、DAY、WEEK、MONTH、QUARTER、YEAR
0: t1 == t2
正数: t1 < t2
负数：t1 > t2 （和datediff相反）

3. 也可以直接用 > = < 等符号直接比较

### 格式化
```sql
SELECT DATE_FORMAT(NOW(),'%Y-%m-%d %H:%i:%s');   -- 结果：2020-12-07 22:18:58
```
>例子：
编写一个 sql 查询来查找每个月和每个国家/地区的事务数及其总金额、已批准的事务数及其总金额。

```sql
Transactions table:
+------+---------+----------+--------+------------+
| id   | country | state    | amount | trans_date |
+------+---------+----------+--------+------------+
| 121  | US      | approved | 1000   | 2018-12-18 |
| 122  | US      | declined | 2000   | 2018-12-19 |
| 123  | US      | approved | 2000   | 2019-01-01 |
| 124  | DE      | approved | 2000   | 2019-01-07 |
+------+---------+----------+--------+------------+

SELECT 
    DATE_FORMAT(trans_date, '%Y-%m') as month,
    country,
    COUNT(*) as trans_count,
    SUM(IF(state='approved', 1, 0)) as approved_count,
    SUM(amount) as trans_total_amount,
    SUM(IF(state='approved', amount, 0)) as approved_total_amount
FROM Transactions
GROUP BY month, country
```


## CROSS JOIN
两张表所有行两两配对，全组合

>例子：
找出与之前（昨天的）日期相比温度更高的所有日期的 id
```sql
Weather 表：
+----+------------+-------------+
| id | recordDate | Temperature |
+----+------------+-------------+
| 1  | 2015-01-01 | 10          |
| 2  | 2015-01-02 | 25          |
| 3  | 2015-01-03 | 20          |
| 4  | 2015-01-04 | 30          |
+----+------------+-------------+

SELECT a.id 
FROM Weather a  
CROSS JOIN Weather b 
ON datediff(a.recordDate, b.recordDate)=1
WHERE a.temperature > b.temperature

# 类似还可以这样：
SELECT a.id
FROM Weather a, Weather b
WHERE datediff(a.recordDate, b.recordDate)=1 AND a.temperature > b.temperature
```

## 求平均AVG、四舍五入ROUND

>例子：
现在有一个工厂网站由几台机器运行，每台机器上运行着 相同数量的进程 。编写解决方案，计算每台机器各自完成一个进程任务的平均耗时。
结果表必须包含machine_id（机器ID） 和对应的 average time（平均耗时） 别名 processing_time，且四舍五入保留3位小数。
```sql
Activity 表:
+------------+------------+---------------+-----------+
| machine_id | process_id | activity_type | timestamp |
+------------+------------+---------------+-----------+
| 0          | 0          | start         | 0.712     |
| 0          | 0          | end           | 1.520     |
| 0          | 1          | start         | 3.140     |
| 0          | 1          | end           | 4.120     |
| 1          | 0          | start         | 0.550     |
| 1          | 0          | end           | 1.550     |
+------------+------------+---------------+-----------+

SELECT a.machine_id, round(avg(abs(b.timestamp-a.timestamp)), 3) as processing_time
FROM Activity a, Activity b
WHERE a.machine_id=b.machine_id AND a.process_id=b.process_id AND a.activity_type='start' AND b.activity_type='end'
GROUP BY a.machine_id
```

## IFNULL
在mysql中IFNULL(a, b)函数用于判断第一个表达式a是否为 NULL，如果第一个值不为NULL就执行第一个值。第一个值为NULL 则返回第二个参数的值b。

>例子：
查询出每个学生参加每一门科目测试的次数，结果按 student_id 和 subject_name 排序。

```sql
Students table:
+------------+--------------+
| student_id | student_name |
+------------+--------------+
| 1          | Alice        |
| 2          | Bob          |
| 13         | John         |
| 6          | Alex         |
+------------+--------------+
Subjects table:
+--------------+
| subject_name |
+--------------+
| Math         |
| Physics      |
| Programming  |
+--------------+
Examinations table:
+------------+--------------+
| student_id | subject_name |
+------------+--------------+
| 1          | Math         |
| 1          | Physics      |
| 1          | Programming  |
| 2          | Programming  |
| 1          | Physics      |
| 1          | Math         |
| 13         | Math         |
| 13         | Programming  |
| 13         | Physics      |
| 2          | Math         |
| 1          | Math         |
+------------+--------------+

SELECT a.student_id, a.student_name, a.subject_name, IFNULL(b.attended_exams, 0) AS attended_exams
FROM
(
    SELECT s.student_id, s.student_name, sb.subject_name
    FROM Students s
    CROSS JOIN Subjects sb
) a
LEFT JOIN
(
    SELECT student_id, subject_name, COUNT(*) AS attended_exams
    FROM Examinations
    GROUP BY student_id, subject_name
) b
ON a.student_id=b.student_id AND a.subject_name=b.subject_name
ORDER BY a.student_id, a.subject_name
```

## HAVING
跟在聚合函数比如GROUP BY后面，作为WHERE使用

>例子：
编写一个解决方案，找出至少有五个直接下属的经理。

```sql
Employee 表:
+-----+-------+------------+-----------+
| id  | name  | department | managerId |
+-----+-------+------------+-----------+
| 101 | John  | A          | Null      |
| 102 | Dan   | A          | 101       |
| 103 | James | A          | 101       |
| 104 | Amy   | A          | 101       |
| 105 | Anne  | A          | 101       |
| 106 | Ron   | B          | 101       |
+-----+-------+------------+-----------+

SELECT a.name
FROM Employee a
INNER JOIN
(
    SELECT count(*) as cnt, managerId
    FROM Employee
    GROUP BY managerId
    HAVING cnt >= 5
) b
ON a.id=b.managerId
```

## HAVING支持聚合函数，WHERE不行

比较:

- WHERE：
    - 优点：先筛选数据在关联，执行效率高 
    - 缺点：不能使用分组中的数据进行筛选
- HAVING：
    - 优点：可以使用分组中的聚合函数
    - 缺点：在最后的结果集中进行筛选，执行效率低

>例子：1084. 销售分析III
编写解决方案，报告2019年春季才售出的产品。即仅在2019-01-01至2019-03-31（含）之间出售的商品。

```sql
输入：
Product table:
+------------+--------------+------------+
| product_id | product_name | unit_price |
+------------+--------------+------------+
| 1          | S8           | 1000       |
| 2          | G4           | 800        |
| 3          | iPhone       | 1400       |
+------------+--------------+------------+
Sales table:
+-----------+------------+----------+------------+----------+-------+
| seller_id | product_id | buyer_id | sale_date  | quantity | price |
+-----------+------------+----------+------------+----------+-------+
| 1         | 1          | 1        | 2019-01-21 | 2        | 2000  |
| 1         | 2          | 2        | 2019-02-17 | 1        | 800   |
| 2         | 2          | 3        | 2019-06-02 | 1        | 800   |
| 3         | 3          | 4        | 2019-05-13 | 2        | 2800  |
+-----------+------------+----------+------------+----------+-------+
输出：
+-------------+--------------+
| product_id  | product_name |
+-------------+--------------+
| 1           | S8           |
+-------------+--------------+

SELECT s.product_id,p.product_name
FROM Sales s
LEFT JOIN Product as p
ON s.product_id=p.product_id
GROUP BY s.product_id
HAVING min(s.sale_date)>='2019-01-01' AND max(s.sale_date)<='2019-03-31'
```

>例子：596. 超过5名学生的课
查询 至少有5个学生 的所有班级。

```sql
输入: 
Courses table:
+---------+----------+
| student | class    |
+---------+----------+
| A       | Math     |
| B       | English  |
| C       | Math     |
| D       | Biology  |
| E       | Math     |
| F       | Computer |
| G       | Math     |
| H       | Math     |
+---------+----------+
输出: 
+---------+ 
| class   | 
+---------+ 
| Math    | 
+---------+

SELECT class
FROM Courses
GROUP BY class
HAVING COUNT(DISTINCT student)>4
```

## AVG

AVG(条件表达式)

AVG除了传入列名求某一列的平级，还可以传入表达式，进行过滤后平均计算

>例子：
用户的“确认率”是 'confirmed' 消息的数量除以请求的确认消息的总数。没有请求任何确认消息的用户的确认率为 0 。确认率四舍五入到 小数点后两位 。
编写一个SQL查询来查找每个用户的 确认率。

```sql
Signups 表:
+---------+---------------------+
| user_id | time_stamp          |
+---------+---------------------+
| 3       | 2020-03-21 10:16:13 |
| 7       | 2020-01-04 13:57:59 |
| 2       | 2020-07-29 23:09:44 |
| 6       | 2020-12-09 10:39:37 |
+---------+---------------------+
Confirmations 表:
+---------+---------------------+-----------+
| user_id | time_stamp          | action    |
+---------+---------------------+-----------+
| 3       | 2021-01-06 03:30:46 | timeout   |
| 3       | 2021-07-14 14:00:00 | timeout   |
| 7       | 2021-06-12 11:57:29 | confirmed |
| 7       | 2021-06-13 12:58:28 | confirmed |
| 7       | 2021-06-14 13:59:27 | confirmed |
| 2       | 2021-01-22 00:00:00 | confirmed |
| 2       | 2021-02-28 23:59:59 | timeout   |
+---------+---------------------+-----------+

SELECT
    s.user_id,
    ROUND(IFNULL(AVG(c.action='confirmed'), 0), 2) AS confirmation_rate
    # 为了好理解，上面这行可以这样：
    # ROUND(SUM(IF(c.action='confirmed', 1, 0)) / count(*), 2) AS confirmation_rate
FROM
    Signups AS s
LEFT JOIN
    Confirmations AS c
ON
    s.user_id = c.user_id
GROUP BY
    s.user_id
```

>类似的例子还有：
将查询结果的质量 quality 定义为：各查询结果的评分与其位置之间比率的平均值。
将劣质查询百分比 poor_query_percentage 为：评分小于 3 的查询结果占全部查询结果的百分比。
编写解决方案，找出每次的 query_name 、 quality 和 poor_query_percentage。
quality 和 poor_query_percentage 都应 四舍五入到小数点后两位。

```sql
Queries table:
+------------+-------------------+----------+--------+
| query_name | result            | position | rating |
+------------+-------------------+----------+--------+
| Dog        | Golden Retriever  | 1        | 5      |
| Dog        | German Shepherd   | 2        | 5      |
| Dog        | Mule              | 200      | 1      |
| Cat        | Shirazi           | 5        | 2      |
| Cat        | Siamese           | 3        | 3      |
| Cat        | Sphynx            | 7        | 4      |
+------------+-------------------+----------+--------+

select 
    query_name, 
    round(avg(rating/position), 2) as quality,
    round(100*avg(IF(rating<3, 1, 0)), 2) as poor_query_percentage
    # 上面还可以写为：
    # round(100*avg(rating<3), 2) as poor_query_percentage
    # 或者：
    # ROUND(SUM(IF(rating < 3, 1, 0)) * 100 / COUNT(*), 2) poor_query_percentage
from Queries
group by query_name
```

## UNION
> UNION默认会去重，即合并结果集时会自动去除重复的记录; UNION 默认会对合并后的结果集进行排序.
> 
> UNION ALL 不会去重和排序，效率比UNION高


>例子：
一个员工可以属于多个部门。当一个员工加入超过一个部门的时候，他需要决定哪个部门是他的直属部门。
请注意，当员工只加入一个部门的时候，那这个部门将默认为他的直属部门，虽然表记录的值为'N'.
请编写解决方案，查出员工所属的直属部门。
```sql
输入：
Employee table:
+-------------+---------------+--------------+
| employee_id | department_id | primary_flag |
+-------------+---------------+--------------+
| 1           | 1             | N            |
| 2           | 1             | Y            |
| 2           | 2             | N            |
| 3           | 3             | N            |
| 4           | 2             | N            |
| 4           | 3             | Y            |
| 4           | 4             | N            |
+-------------+---------------+--------------+
输出：
+-------------+---------------+
| employee_id | department_id |
+-------------+---------------+
| 1           | 1             |
| 2           | 1             |
| 3           | 3             |
| 4           | 3             |
+-------------+---------------+

SELECT employee_id, department_id
FROM Employee
GROUP BY employee_id
HAVING COUNT(*)=1
UNION
SELECT employee_id, department_id
FROM Employee
WHERE primary_flag='Y'
```

> union的查询里不能有order by

>例子：

请你编写一个解决方案：
查找评论电影数量最多的用户名。如果出现平局，返回字典序较小的用户名。
查找在 February 2020 平均评分最高 的电影名称。如果出现平局，返回字典序较小的电影名称。
字典序 ，即按字母在字典中出现顺序对字符串排序，字典序较小则意味着排序靠前。
输入：

```sql
Movies 表：
+-------------+--------------+
| movie_id    |  title       |
+-------------+--------------+
| 1           | Avengers     |
| 2           | Frozen 2     |
| 3           | Joker        |
+-------------+--------------+
Users 表：
+-------------+--------------+
| user_id     |  name        |
+-------------+--------------+
| 1           | Daniel       |
| 2           | Monica       |
| 3           | Maria        |
| 4           | James        |
+-------------+--------------+
MovieRating 表：
+-------------+--------------+--------------+-------------+
| movie_id    | user_id      | rating       | created_at  |
+-------------+--------------+--------------+-------------+
| 1           | 1            | 3            | 2020-01-12  |
| 1           | 2            | 4            | 2020-02-11  |
| 1           | 3            | 2            | 2020-02-12  |
| 1           | 4            | 1            | 2020-01-01  |
| 2           | 1            | 5            | 2020-02-17  | 
| 2           | 2            | 2            | 2020-02-01  | 
| 2           | 3            | 2            | 2020-03-01  |
| 3           | 1            | 3            | 2020-02-22  | 
| 3           | 2            | 4            | 2020-02-25  | 
+-------------+--------------+--------------+-------------+
输出：
Result 表：
+--------------+
| results      |
+--------------+
| Daniel       |
| Frozen 2     |
+--------------+

-- 因为UNION前后的sql里面都有orderby，直接连起来会报错
-- 这里取巧，前后都用括号括起来，变成子查询，就没这个问题了
-- 用UNION ALL，而不是UNION，防止去重

(
    SELECT NAME AS RESULTS
    FROM Users AS U
    INNER JOIN MovieRating AS MR
    ON U.USER_ID = MR.USER_ID
    GROUP BY U.USER_ID
    ORDER BY COUNT(*) DESC, NAME
    LIMIT 1
)
UNION ALL
(
    SELECT TITLE AS RESULTS
    FROM Movies AS M
    INNER JOIN MovieRating AS MR
    ON M.MOVIE_ID = MR.MOVIE_ID
    WHERE LEFT(CREATED_AT, 7) = '2020-02'
    GROUP BY M.MOVIE_ID
    ORDER BY AVG(RATING) DESC, TITLE
    LIMIT 1
)
```

## IF
只有2种结果的用if比case when更合适

>例子：
对每三个线段报告它们是否可以形成一个三角形。

```sql
输入: 
Triangle 表:
+----+----+----+
| x  | y  | z  |
+----+----+----+
| 13 | 15 | 30 |
| 10 | 20 | 15 |
+----+----+----+
输出: 
+----+----+----+----------+
| x  | y  | z  | triangle |
+----+----+----+----------+
| 13 | 15 | 30 | No       |
| 10 | 20 | 15 | Yes      |
+----+----+----+----------+

SELECT x,y,z,
    IF(x+y>z AND x+z>y AND y+z>x, 'Yes', 'No') AS triangle
FROM Triangle
```

## 窗口函数OVER
https://blog.csdn.net/liangmengbk/article/details/124253806

语法：
[你要的操作] OVER ( PARTITION BY  <用于分组的列名>
                    ORDER BY <按序叠加的列名> 
                    ROWS|RANGE <窗口滑动的数据范围> )

其中，ROWS表示以数据行为单位计算窗口的偏移量，RANGE表示以数值（例如10天、5km等）为单位计算窗口的偏移量。

<窗口滑动的数据范围> 用来限定 [你要的操作] 所运用的数据的范围，具体有如下这些：
当前 - current row
之前的 - preceding
之后的 - following
无界限 - unbounded
表示从前面的起点 - unbounded preceding
表示到后面的终点 - unbounded following

举例：
取当前行和前五行：ROWS between 5 preceding and current row --共6行
取当前行和后五行：ROWS between current row and 5 following --共6行
取前五行和后五行：ROWS between 5 preceding and 5 following --共11行
取当前行和前六行：ROWS 6 preceding（等价于between...and current row） --共7行
这一天和前面6天：RANGE between interval 6 day preceding and current row --共7天
这一天和前面6天：RANGE interval 6 day preceding（等价于between...and current row） --共7天
字段值落在当前值-100到+200的区间：RANGE between 100 preceding and 200 following  --共301个

>例子：
你是餐馆的老板，现在你想分析一下可能的营业额变化增长（每天至少有一位顾客）。
计算以 7 天（某日期 + 该日期前的 6 天）为一个时间段的顾客消费平均值。average_amount 要 保留两位小数。
结果按 visited_on 升序排序。

```sql
输入：
Customer 表:
+-------------+--------------+--------------+-------------+
| customer_id | name         | visited_on   | amount      |
+-------------+--------------+--------------+-------------+
| 1           | Jhon         | 2019-01-01   | 100         |
| 2           | Daniel       | 2019-01-02   | 110         |
| 3           | Jade         | 2019-01-03   | 120         |
| 4           | Khaled       | 2019-01-04   | 130         |
| 5           | Winston      | 2019-01-05   | 110         | 
| 6           | Elvis        | 2019-01-06   | 140         | 
| 7           | Anna         | 2019-01-07   | 150         |
| 8           | Maria        | 2019-01-08   | 80          |
| 9           | Jaze         | 2019-01-09   | 110         | 
| 1           | Jhon         | 2019-01-10   | 130         | 
| 3           | Jade         | 2019-01-10   | 150         | 
+-------------+--------------+--------------+-------------+
输出：
+--------------+--------------+----------------+
| visited_on   | amount       | average_amount |
+--------------+--------------+----------------+
| 2019-01-07   | 860          | 122.86         |
| 2019-01-08   | 840          | 120            |
| 2019-01-09   | 840          | 120            |
| 2019-01-10   | 1000         | 142.86         |
+--------------+--------------+----------------+

SELECT DISTINCT visited_on,
       sum_amount AS amount, 
       ROUND(sum_amount/7, 2) AS average_amount
FROM 
(
    SELECT 
        visited_on, 
        SUM(amount) OVER ( 
            ORDER BY visited_on 
            RANGE interval 6 day preceding  
        ) AS sum_amount 
    FROM Customer
) t
-- 最后手动地从第7天开始
WHERE DATEDIFF(visited_on, (SELECT MIN(visited_on) FROM Customer)) >= 6
```

## 排序
RANK，DENSE_RANK、ROW_NUMBER
区别：
- RANK 并列跳跃排名，并列即相同的值，相同的值保留重复名次，遇到下一个不同值时，跳跃到总共的排名。
- DENSE_RANK 并列连续排序，并列即相同的值，相同的值保留重复名次，遇到下一个不同值时，依然按照连续数字排名。
- ROW_NUMBER 连续排名，即使相同的值，依旧按照连续数字进行排名

如图：
```sql
+-----------+-----------+------------+--------------+
| VALUE     | RNAK      | DENSE_RANK | ROW_NUMBER   |
+-----------+-----------+------------+--------------+
| 70        | 1         | 1          | 1            |
| 70        | 1         | 1          | 2            |
| 70        | 1         | 1          | 3            |
| 75        | 4         | 2          | 4            |
| 80        | 5         | 3          | 5            |
| 90        | 6         | 4          | 6            |
+-----------+-----------+------------+--------------+

```

> 例子：
公司的主管们感兴趣的是公司每个部门中谁赚的钱最多。一个部门的 高收入者 是指一个员工的工资在该部门的 不同 工资中 排名前三 。
编写解决方案，找出每个部门中 收入高的员工 。
以 任意顺序 返回结果表。

```sql

输入: 
Employee 表:
+----+-------+--------+--------------+
| id | name  | salary | departmentId |
+----+-------+--------+--------------+
| 1  | Joe   | 85000  | 1            |
| 2  | Henry | 80000  | 2            |
| 3  | Sam   | 60000  | 2            |
| 4  | Max   | 90000  | 1            |
| 5  | Janet | 69000  | 1            |
| 6  | Randy | 85000  | 1            |
| 7  | Will  | 70000  | 1            |
+----+-------+--------+--------------+
Department  表:
+----+-------+
| id | name  |
+----+-------+
| 1  | IT    |
| 2  | Sales |
+----+-------+
输出: 
+------------+----------+--------+
| Department | Employee | Salary |
+------------+----------+--------+
| IT         | Max      | 90000  |
| IT         | Joe      | 85000  |
| IT         | Randy    | 85000  |
| IT         | Will     | 70000  |
| Sales      | Henry    | 80000  |
| Sales      | Sam      | 60000  |
+------------+----------+--------+
解释:
在IT部门:
- Max的工资最高
- 兰迪和乔都赚取第二高的独特的薪水
- 威尔的薪水是第三高的

在销售部:
- 亨利的工资最高
- 山姆的薪水第二高
- 没有第三高的工资，因为只有两名员工


SELECT Department, Employee, Salary
FROM (
    SELECT 
        d.name Department, 
        ee.name Employee, 
        ee.salary Salary, 
        DENSE_RANK() OVER
        (
            PARTITION BY departmentId 
            ORDER BY salary 
            DESC
        ) ranks
    FROM Employee ee
    LEFT JOIN Department d
    ON ee.departmentId = d.id
) t
WHERE ranks <= 3

-- 除了用RANK排序函数，本题也能朴素解：
SELECT
    d.Name Department, 
    e1.Name Employee, 
    e1.Salary Salary
FROM
    Employee e1
    LEFT JOIN Department d 
    ON e1.DepartmentId = d.Id
WHERE
    3 > (
            SELECT
                COUNT(DISTINCT e2.Salary)
            FROM Employee e2
            WHERE
                e2.Salary > e1.Salary AND e1.DepartmentId = e2.DepartmentId
        )
```

## 正则表达式-空格
在MySQL中，反斜杠在字符串中是属于转义字符，经过语法解析器解析时会进行一次转义
在MySQL中，正则表达式也是一个字符串，所以一般正则表达式的空格表示为`\s`，MySQL中需要为：`\\s`

>例子：
查询患有 I 类糖尿病的患者 ID （patient_id）、患者姓名（patient_name）以及其患有的所有疾病代码（conditions）。
I 类糖尿病的代码总是包含前缀 DIAB1 。

```sql
输入：
Patients表：
+------------+--------------+--------------+
| patient_id | patient_name | conditions   |
+------------+--------------+--------------+
| 1          | Daniel       | YFEV COUGH   |
| 2          | Alice        |              |
| 3          | Bob          | DIAB100 MYOP |
| 4          | George       | ACNE DIAB100 |
| 5          | Alain        | DIAB201      |
+------------+--------------+--------------+
输出：
+------------+--------------+--------------+
| patient_id | patient_name | conditions   |
+------------+--------------+--------------+
| 3          | Bob          | DIAB100 MYOP |
| 4          | George       | ACNE DIAB100 | 
+------------+--------------+--------------+
解释：Bob 和 George 都患有代码以 DIAB1 开头的疾病。

SELECT *
FROM Patients
WHERE
    conditions REGEXP '^DIAB1|\\sDIAB1'
```

## 删除
一般的删除写法是：
```sql
DELETE FROM t1 WHERE id=xxx
```
如果想在join中删除，可以这样：
```sql
DELETE t1 
FROM t1 
LEFT JOIN t2
ON t1.id=t2.id
WHERE t1.id=xxx
```
> 例子：
编写解决方案 删除 所有重复的电子邮件，只保留一个具有最小 id 的唯一电子邮件。

```sql
输入: 
Person 表:
+----+------------------+
| id | email            |
+----+------------------+
| 1  | john@example.com |
| 2  | bob@example.com  |
| 3  | john@example.com |
+----+------------------+
输出: 
+----+------------------+
| id | email            |
+----+------------------+
| 1  | john@example.com |
| 2  | bob@example.com  |
+----+------------------+

DELETE p1
FROM Person p1 
INNER JOIN Person p2
ON p1.email=p2.email AND p1.id>p2.id
```

## GROUP_CONCAT
GROUP_CONCAT()函数将组中的字符串连接成为具有各种选项的单个字符串
```sql
GROUP_CONCAT(
    DISTINCT expression
    ORDER BY expression
    SEPARATOR sep
)
```

> 例子：
编写解决方案找出每个日期、销售的不同产品的数量及其名称。
每个日期的销售产品名称应按词典序排列。
返回按 sell_date 排序的结果表。

```sql
输入：
Activities 表：
+------------+-------------+
| sell_date  | product     |
+------------+-------------+
| 2020-05-30 | Headphone   |
| 2020-06-01 | Pencil      |
| 2020-06-02 | Mask        |
| 2020-05-30 | Basketball  |
| 2020-06-01 | Bible       |
| 2020-06-02 | Mask        |
| 2020-05-30 | T-Shirt     |
+------------+-------------+
输出：
+------------+----------+------------------------------+
| sell_date  | num_sold | products                     |
+------------+----------+------------------------------+
| 2020-05-30 | 3        | Basketball,Headphone,T-shirt |
| 2020-06-01 | 2        | Bible,Pencil                 |
| 2020-06-02 | 1        | Mask                         |
+------------+----------+------------------------------+

SELECT 
    sell_date,
    COUNT(DISTINCT(product)) AS num_sold, 
    GROUP_CONCAT(
        DISTINCT product 
        ORDER BY product 
        SEPARATOR ','
    ) AS products
FROM 
    Activities
GROUP BY 
    sell_date
ORDER BY 
    sell_date ASC
```


# LeetCode题目收藏
## 1174. 即时食物配送 II
如果顾客期望的配送日期和下单日期相同，则该订单称为 「即时订单」，否则称为「计划订单」。
「首次订单」是顾客最早创建的订单。我们保证一个顾客只会有一个「首次订单」。
编写解决方案以获取即时订单在所有用户的首次订单中的比例。保留两位小数。

```sql
输入：
Delivery 表：
+-------------+-------------+------------+-----------------------------+
| delivery_id | customer_id | order_date | customer_pref_delivery_date |
+-------------+-------------+------------+-----------------------------+
| 1           | 1           | 2019-08-01 | 2019-08-02                  |
| 2           | 2           | 2019-08-02 | 2019-08-02                  |
| 3           | 1           | 2019-08-11 | 2019-08-12                  |
| 4           | 3           | 2019-08-24 | 2019-08-24                  |
| 5           | 3           | 2019-08-21 | 2019-08-22                  |
| 6           | 2           | 2019-08-11 | 2019-08-13                  |
| 7           | 4           | 2019-08-09 | 2019-08-09                  |
+-------------+-------------+------------+-----------------------------+
输出：
+----------------------+
| immediate_percentage |
+----------------------+
| 50.00                |
+----------------------+

SELECT ROUND(100*AVG(t.first_date=d.customer_pref_delivery_date), 2) AS immediate_percentage
FROM (
    select customer_id, min(order_date) as first_date
    from delivery
    group by customer_id
) t
INNER JOIN Delivery d
ON t.customer_id=d.customer_id AND t.first_date=d.order_date
```

## 550. 游戏玩法分析 IV
编写解决方案，报告在首次登录的第二天再次登录的玩家的 比率，四舍五入到小数点后两位。换句话说，你需要计算从首次登录日期开始至少连续两天登录的玩家的数量，然后除以玩家总数。

```sql
输入：
Activity table:
+-----------+-----------+------------+--------------+
| player_id | device_id | event_date | games_played |
+-----------+-----------+------------+--------------+
| 1         | 2         | 2016-03-01 | 5            |
| 1         | 2         | 2016-03-02 | 6            |
| 2         | 3         | 2017-06-25 | 1            |
| 3         | 1         | 2016-03-02 | 0            |
| 3         | 4         | 2018-07-03 | 5            |
+-----------+-----------+------------+--------------+
输出：
+-----------+
| fraction  |
+-----------+
| 0.33      |
+-----------+

SELECT ROUND(AVG(a.event_date is not null), 2) fraction
FROM (
    # 首次登录日期
    SELECT player_id, min(event_date) as frist_date
    FROM Activity
    GROUP BY player_id
) f
LEFT JOIN Activity a
ON f.player_id=a.player_id AND DATEDIFF(a.event_date, f.frist_date)=1
```

## 1141. 查询近30天活跃用户数
编写解决方案，统计截至 2019-07-27（包含2019-07-27），近 30 天的每日活跃用户数（当天只要有一条活动记录，即为活跃用户）。
以 任意顺序 返回结果表。
结果示例如下。

```sql
输入：
Activity table:
+---------+------------+---------------+---------------+
| user_id | session_id | activity_date | activity_type |
+---------+------------+---------------+---------------+
| 1       | 1          | 2019-07-20    | open_session  |
| 1       | 1          | 2019-07-20    | scroll_down   |
| 1       | 1          | 2019-07-20    | end_session   |
| 2       | 4          | 2019-07-20    | open_session  |
| 2       | 4          | 2019-07-21    | send_message  |
| 2       | 4          | 2019-07-21    | end_session   |
| 3       | 2          | 2019-07-21    | open_session  |
| 3       | 2          | 2019-07-21    | send_message  |
| 3       | 2          | 2019-07-21    | end_session   |
| 4       | 3          | 2019-06-25    | open_session  |
| 4       | 3          | 2019-06-25    | end_session   |
+---------+------------+---------------+---------------+
输出：
+------------+--------------+ 
| day        | active_users |
+------------+--------------+ 
| 2019-07-20 | 2            |
| 2019-07-21 | 2            |
+------------+--------------+ 

SELECT activity_date as day, COUNT(distinct user_id) as active_users
FROM Activity
GROUP BY activity_date
HAVING activity_date <= '2019-07-27' AND DATEDIFF('2019-07-27', activity_date)<30
```

## 1045. 买下所有产品的客户
SELECT 结果作为字段参数

编写解决方案，报告 Customer 表中购买了 Product 表中所有产品的客户的 id。

```sql
输入：
Customer 表：
+-------------+-------------+
| customer_id | product_key |
+-------------+-------------+
| 1           | 5           |
| 2           | 6           |
| 3           | 5           |
| 3           | 6           |
| 1           | 6           |
+-------------+-------------+
Product 表：
+-------------+
| product_key |
+-------------+
| 5           |
| 6           |
+-------------+
输出：
+-------------+
| customer_id |
+-------------+
| 1           |
| 3           |
+-------------+

SELECT customer_id
FROM Customer
GROUP BY customer_id
HAVING COUNT(DISTINCT product_key)=(
    SELECT COUNT(DISTINCT product_key) FROM Product
)
```

## 1731. 每位经理的下属员工数量
编写SQL查询需要听取汇报的所有经理的ID、名称、直接向该经理汇报的员工人数，以及这些员工的平均年龄，其中该平均年龄需要四舍五入到最接近的整数。
返回的结果集需要按照 employee_id 进行排序。

```sql
Employees table:
+-------------+---------+------------+-----+
| employee_id | name    | reports_to | age |
+-------------+---------+------------+-----+
| 9           | Hercy   | null       | 43  |
| 6           | Alice   | 9          | 41  |
| 4           | Bob     | 9          | 36  |
| 2           | Winston | null       | 37  |
+-------------+---------+------------+-----+
Result table:
+-------------+-------+---------------+-------------+
| employee_id | name  | reports_count | average_age |
+-------------+-------+---------------+-------------+
| 9           | Hercy | 2             | 39          |
+-------------+-------+---------------+-------------+

SELECT e.reports_to as employee_id, m.name, COUNT(*) as reports_count, ROUND(AVG(e.age), 0) as average_age
FROM Employees e
JOIN Employees m
ON e.reports_to=m.employee_id
GROUP BY e.reports_to
ORDER BY employee_id
```

## 180. 连续出现的数字
找出所有至少连续出现三次的数字。

```sql
输入：
Logs 表：
+----+-----+
| id | num |
+----+-----+
| 1  | 1   |
| 2  | 1   |
| 3  | 1   |
| 4  | 2   |
| 5  | 1   |
| 6  | 2   |
| 7  | 2   |
+----+-----+
输出：
Result 表：
+-----------------+
| ConsecutiveNums |
+-----------------+
| 1               |
+-----------------+

SELECT DISTINCT l1.num AS ConsecutiveNums
FROM 
    Logs l1,
    Logs l2,
    Logs l3
WHERE
    l1.Id=l2.Id-1
    AND l2.Id=l3.Id-1
    AND l1.num=l2.num
    AND l2.num=l3.num
```

## 1164. 指定日期的产品价格
编写一个解决方案，找出在 2019-08-16 时全部产品的价格，假设所有产品在修改前的价格都是 10 。

```sql
输入：
Products 表:
+------------+-----------+-------------+
| product_id | new_price | change_date |
+------------+-----------+-------------+
| 1          | 20        | 2019-08-14  |
| 2          | 50        | 2019-08-14  |
| 1          | 30        | 2019-08-15  |
| 1          | 35        | 2019-08-16  |
| 2          | 65        | 2019-08-17  |
| 3          | 20        | 2019-08-18  |
+------------+-----------+-------------+
输出：
+------------+-------+
| product_id | price |
+------------+-------+
| 2          | 50    |
| 1          | 35    |
| 3          | 10    |
+------------+-------+

SELECT p1.product_id, IFNULL(p2.new_price, 10) as price
FROM (
    -- 所有产品
    SELECT DISTINCT product_id
    FROM Products
) p1
LEFT JOIN
(
    SELECT a.product_id, b.new_price
    FROM (
        -- 在 2019-08-16 之前有过修改的产品
        SELECT product_id as product_id, max(change_date) as change_date
        FROM Products
        WHERE change_date<='2019-08-16'
        GROUP BY product_id
    ) a
    INNER JOIN Products b
    ON a.product_id=b.product_id AND a.change_date=b.change_date

) p2
ON p1.product_id=p2.product_id
```

## 1204. 最后一个能进入巴士的人
有一队乘客在等着上巴士。然而，巴士有1000  千克 的重量限制，所以其中一部分乘客可能无法上巴士。
编写解决方案找出 最后一个 上巴士且不超过重量限制的乘客，并报告 person_name 。题目测试用例确保顺位第一的人可以上巴士且不会超重。

```sql
输入：
Queue 表
+-----------+-------------+--------+------+
| person_id | person_name | weight | turn |
+-----------+-------------+--------+------+
| 5         | Alice       | 250    | 1    |
| 4         | Bob         | 175    | 5    |
| 3         | Alex        | 350    | 2    |
| 6         | John Cena   | 400    | 3    |
| 1         | Winston     | 500    | 6    |
| 2         | Marie       | 200    | 4    |
+-----------+-------------+--------+------+
输出：
+-------------+
| person_name |
+-------------+
| John Cena   |
+-------------+
解释：
为了简化，Queue 表按 turn 列由小到大排序。
+------+----+-----------+--------+--------------+
| Turn | ID | Name      | Weight | Total Weight |
+------+----+-----------+--------+--------------+
| 1    | 5  | Alice     | 250    | 250          |
| 2    | 3  | Alex      | 350    | 600          |
| 3    | 6  | John Cena | 400    | 1000         | (最后一个上巴士)
| 4    | 2  | Marie     | 200    | 1200         | (无法上巴士)
| 5    | 4  | Bob       | 175    | ___          |
| 6    | 1  | Winston   | 500    | ___          |
+------+----+-----------+--------+--------------+

SELECT a.person_name

-- 按a的id分组，且组员都是a的前面的乘客（包含a本身）
FROM 
    Queue a,
    Queue b
Where a.turn>=b.turn
GROUP BY a.person_id
HAVING SUM(b.weight)<=1000 --排除掉超限的分组

-- 最终结果按turn倒排，取第一个（题目要求找最后一个）
-- 因为每个a.turn都代表了一个分组，其中a是组内排最后的成员；那么取a.turn最大的小组符合题意
ORDER BY a.turn DESC 
LIMIT 1
```

## 626. 换座位
编写解决方案来交换每两个连续的学生的座位号。如果学生的数量是奇数，则最后一个学生的id不交换。
按 id 升序 返回结果表。

```sql
输入: 
Seat 表:
+----+---------+
| id | student |
+----+---------+
| 1  | Abbot   |
| 2  | Doris   |
| 3  | Emerson |
| 4  | Green   |
| 5  | Jeames  |
+----+---------+
输出: 
+----+---------+
| id | student |
+----+---------+
| 1  | Doris   |
| 2  | Abbot   |
| 3  | Green   |
| 4  | Emerson |
| 5  | Jeames  |
+----+---------+

SELECT
    (
        CASE
            #奇数（非最后一个）
            WHEN MOD(s.id, 2)!=0 AND c.counts!=s.id THEN s.id+1
            #最后一个奇数
            WHEN MOD(s.id, 2)!=0 AND c.counts=s.id THEN s.id
            #偶数
            ELSE s.id-1
        END 
    ) as id,
    s.student
FROM 
    Seat s,   
    (
        SELECT COUNT(*) as counts
        FROM Seat
    ) c #座位总数表
```

## 602. 好友申请 II ：谁有最多的好友
编写解决方案，找出拥有最多的好友的人和他拥有的好友数目。
生成的测试用例保证拥有最多好友数目的只有 1 个人。

```sql
输入：
RequestAccepted 表：
+--------------+-------------+-------------+
| requester_id | accepter_id | accept_date |
+--------------+-------------+-------------+
| 1            | 2           | 2016/06/03  |
| 1            | 3           | 2016/06/08  |
| 2            | 3           | 2016/06/08  |
| 3            | 4           | 2016/06/09  |
+--------------+-------------+-------------+
输出：
+----+-----+
| id | num |
+----+-----+
| 3  | 3   |
+----+-----+

SELECT id, count(*) as num
from (
    SELECT requester_id as id from RequestAccepted
    UNION ALL
    SELECT accepter_id as id from RequestAccepted
) as t
GROUP BY id
ORDER BY num DESC
LIMIT 1
```

## 585. 2016年的投资
编写解决方案报告 2016 年 (tiv_2016) 所有满足下述条件的投保人的投保金额之和：
1. 他在 2015 年的投保额 (tiv_2015) 至少跟一个其他投保人在 2015 年的投保额相同。
2. 他所在的城市必须与其他投保人都不同（也就是说 (lat, lon) 不能跟其他任何一个投保人完全相同）。
tiv_2016 四舍五入的 两位小数
```sql
输入：
Insurance 表：
+-----+----------+----------+-----+-----+
| pid | tiv_2015 | tiv_2016 | lat | lon |
+-----+----------+----------+-----+-----+
| 1   | 10       | 5        | 10  | 10  |
| 2   | 20       | 20       | 20  | 20  |
| 3   | 10       | 30       | 20  | 20  |
| 4   | 10       | 40       | 40  | 40  |
+-----+----------+----------+-----+-----+
输出：
+----------+
| tiv_2016 |
+----------+
| 45.00    |
+----------+

SELECT ROUND(SUM(tiv_2016), 2) as tiv_2016
FROM Insurance
WHERE tiv_2015 in (
    SELECT tiv_2015 
    FROM Insurance
    GROUP BY tiv_2015
    HAVING COUNT(*) > 1
)
AND (lat, lon) in (
    SELECT lat, lon
    FROM Insurance
    GROUP BY lat, lon
    HAVING COUNT(*) = 1 
)

-- 也可以这样：
SELECT ROUND(SUM(a.tiv_2016),2) AS TIV_2016
FROM insurance a
WHERE EXISTS (
    SELECT *
    FROM insurance b 
    WHERE a.pid<>b.pid AND a.tiv_2015=b.tiv_2015
)
AND NOT EXISTS(
    SELECT *
    FROM insurance c 
    WHERE a.pid<>c.pid AND a.lat=c.lat AND a.lon=c.lon
);
```

## 176. 第二高的薪水
查询并返回 Employee 表中第二高的薪水 。如果不存在第二高的薪水，查询应该返回 null(Pandas 则返回 None) 。

```sql
输入：
Employee 表：
+----+--------+
| id | salary |
+----+--------+
| 1  | 100    |
| 2  | 200    |
| 3  | 300    |
+----+--------+
输出：
+---------------------+
| SecondHighestSalary |
+---------------------+
| 200                 |
+---------------------+
示例 2：

输入：
Employee 表：
+----+--------+
| id | salary |
+----+--------+
| 1  | 100    |
+----+--------+
输出：
+---------------------+
| SecondHighestSalary |
+---------------------+
| null                |
+---------------------+


-- 麻烦的是null，可以用临时表的方式解决：
SELECT
(
    SELECT DISTINCT salary
    FROM Employee
    ORDER BY salary
    DESC
    LIMIT 1,1
) AS SecondHighestSalary

--或者用IFNULL
SELECT
IFNULL(
    (
        SELECT DISTINCT salary
        FROM Employee
        ORDER BY salary
        DESC
        LIMIT 1,1
    ),
    null
) AS SecondHighestSalary
```

## 1327. 列出指定时间段内所有的下单产品
写一个解决方案，要求获取在 2020 年 2 月份下单的数量不少于 100 的产品的名字和数目。

```sql
输入：
Products 表:
+-------------+-----------------------+------------------+
| product_id  | product_name          | product_category |
+-------------+-----------------------+------------------+
| 1           | Leetcode Solutions    | Book             |
| 2           | Jewels of Stringology | Book             |
| 3           | HP                    | Laptop           |
| 4           | Lenovo                | Laptop           |
| 5           | Leetcode Kit          | T-shirt          |
+-------------+-----------------------+------------------+
Orders 表:
+--------------+--------------+----------+
| product_id   | order_date   | unit     |
+--------------+--------------+----------+
| 1            | 2020-02-05   | 60       |
| 1            | 2020-02-10   | 70       |
| 2            | 2020-01-18   | 30       |
| 2            | 2020-02-11   | 80       |
| 3            | 2020-02-17   | 2        |
| 3            | 2020-02-24   | 3        |
| 4            | 2020-03-01   | 20       |
| 4            | 2020-03-04   | 30       |
| 4            | 2020-03-04   | 60       |
| 5            | 2020-02-25   | 50       |
| 5            | 2020-02-27   | 50       |
| 5            | 2020-03-01   | 50       |
+--------------+--------------+----------+
输出：
+--------------------+---------+
| product_name       | unit    |
+--------------------+---------+
| Leetcode Solutions | 130     |
| Leetcode Kit       | 100     |
+--------------------+---------+

SELECT p.product_name, SUM(o.unit) as unit
FROM Orders o
LEFT JOIN Products p
ON o.product_id=p.product_id
WHERE DATE_FORMAT(o.order_date, '%Y-%m')='2020-02'
GROUP BY o.product_id
HAVING unit>=100
```