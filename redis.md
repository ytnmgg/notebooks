- [redis 多线程还是单线程](#redis-多线程还是单线程)
- [redis和DB一致性保证](#redis和db一致性保证)
  - [删除缓存优于更新缓存](#删除缓存优于更新缓存)
  - [先删缓存，再更新db](#先删缓存再更新db)
  - [先更新db，再删缓存](#先更新db再删缓存)
  - [延迟双删](#延迟双删)
- [lua脚本超时：](#lua脚本超时)
- [redis 分布式锁](#redis-分布式锁)
- [redis zset 定时关单](#redis-zset-定时关单)
- [redis限流](#redis限流)
- [redis大key](#redis大key)
  - [大key定义：](#大key定义)
  - [如何查找大 key](#如何查找大-key)
  - [影响](#影响)
  - [解决](#解决)

# redis 多线程还是单线程
   https://zhuanlan.zhihu.com/p/646111642
   Redis6开始支持多线程：
   1. 主线程处理请求，建立连接获取socket
   2. 主线程将socket分配给多个IO线程并行处理socket，阻塞等待。
   3. 多个IO线程读取socket请求并解析，并行处理完成后返回结果给主线程
   4. 主线程执行命令
   5. 主线程将结果写入输出缓冲区
   6. 主线程阻塞，等待多个IO线程并行回写socket完成。


# redis和DB一致性保证

## 删除缓存优于更新缓存
   1. 缓存内容有时候结构比较复杂，是一堆东西的汇总，遍历更新代码更复杂，删操作更轻量
   2. 删除是一个lazy Loading的思想，用到缓存了再更新并缓存；否则极端场景，读比较少，修改了100次db，要改100次缓存，但是恰好缓存只读了1次。。99次更新缓存都是废操作
   3. 一致性问题：同时有请求A和请求B进行更新操作，那么会出现
      1. 线程A更新了数据库
      2. 线程B更新了数据库
      3. 线程B更新了缓存
      4. 线程A更新了缓存
         
    这就出现请求A更新缓存应该比请求B更新缓存早才对，但是因为网络等原因，B却比A更早更新了缓存。这就导致了脏数据，因此不考虑。
    
    当然加分布式锁可以解决这个问题，但是比较起来，删除操作就简单很多了。

## 先删缓存，再更新db
   1. 线程A删缓存
   2. 线程B读缓存，没命中
   3. 线程B读db，更新缓存为值10 （此时缓存为旧值）
   4. 线程A更新数据库为20 （出现新值与缓存值不一致！）
## 先更新db，再删缓存
   1. 线程A读取缓存，恰好缓存失效，查db，得旧值10
   2. 线程B更新db为新值20，再删缓存
   3. 线程A拿到旧值10，回写缓存10（出现新值与缓存值不一致！）

    这种情况发生的条件是：步骤2线程B写数据库耗时比步骤1线程A读数据库耗时更短，才有可能步骤2先于步骤3；
    但是实际数据库的读操作是远快于写操作，故这种异常情况很难出现。
    所以简单做法，就是先更新db，再删缓存，就够了。

## 延迟双删
   1. 先淘汰缓存
   2. 再写数据库（这两步和原来一样）
   3. 休眠1秒，再次淘汰缓存
    > 为什么要延迟：这里4-(3)，是指在上面《先删缓存，再更新db》的2-(4)后面加一步:2-(5)线程A去做缓存删除。这里延迟的目的是想等其它读到db旧值的线程，回去更新缓存都结束了，这里删除之后，线程去db拿一定是拿新值，再把新值更新到缓存。
    即db数据已经落库完成了，且之前拿到旧值的数据都回来了，不会再有旧值干扰设置到缓存了
               
    > 1秒怎么定？在读数据业务逻辑的耗时基础上，加几百ms即可。这么做的目的，就是确保读请求结束，写请求可以删除读请求造成的缓存脏数据。
    因为在db新数据落库完成之前的0.0001s，又来了一个请求，拿到旧数据，慢慢回去，得等这个请求完成之后，再删缓存

   
# lua脚本超时：
      如果时长达到 Lua-time-limit（默认5秒）规定的最大执行时间，Redis只会做这几件事情：
         - 日志记录有脚本运行超时
         - 开始允许接受其他客户端请求，但仅限于 SCRIPT KILL 和 SHUTDOWN NOSAVE 两个命令
           - SCRIPT KILL：停止脚本，但是脚本里有写命令的话，这个请求会失败
           - SHUTDOWN NOSAVE：停止redis服务器，防止。这里也说明：AOF文件是在整个lua脚本的命令都执行完成以后，再刷盘AOF文件的
         - 其他请求仍返回busy错误
      
      为什么服务器不强制停掉脚本的执行？担心原子性，中途停止可能导致内存的数据集上只修改了部分数据（只读脚本可以正常停止）



# redis 分布式锁
   https://blog.csdn.net/scm_2008/article/details/127422698

      3. 普通： setnx key value 返回1成功，0失败； del key 释放锁
      4. 解决服务宕机，无法释放：setnx key value; expire key 60
      5. 2中两条命令不是原子的，还是有可能执行了setnx之后没来得及执行expire就宕机了，解决方式是用lua脚本保障原子性：
          String lua_scripts = "if redis.call('setnx',KEYS[1],ARGV[1]) == 1 then redis.call('expire',KEYS[1],ARGV[2]) return 1 else return 0 end";
          jedis.eval(lua_scripts, key, value, 60);
      6. redis2.6开始支持原子命令：set key value ex 60 nx
      7. del key 可能误删别人的（场景：线程1拿锁执行业务，超过了expire时间，锁自动释放；线程2拿到锁，正在进行业务；线程1执行完成业务，删锁，实际上是线程2的锁被释放了；线程3过来又拿到了锁，和线程2同时进行业务，资源冲突）
      8. 5的解法：value中保存线程唯一id，线程去解锁的时候，判断id是否一致（是否不是自己的锁），再决定是否删除
      9.  6又出现了原子性，get id和del key不是原子的，又得用lua脚本保障原子性：
         String lua_scripts = "if (redis.call('get', KEYS[1]) == ARGV[1] ) then redis.call('del', KEYS[1]); return 1; end; return 0;";
         jedis.eval(lua_scripts, key, value);

# redis zset 定时关单
      1. zadd key score value : key=表名，score=单据应该过期的时间戳（创建时间+过期间距），value=单据id
      2. zrangebyscore key min max withscores LIMIT offset count: 
         min=0，max=当前时间戳，则过期时间小于当前时间的单据都能捞出来，offset=0 count=100：一次从头捞100个
      3. zrem key value: 执行业务单据过期操作以后，删除value=id的reids记录 
         或者批量删：zremrangebyscore key min max
      注意上面2~3步骤，需要加分布式锁

# redis限流
方法1：zset时间窗
13. 访问一次就添加一条记录：zadd key score value: key=uid, score=当前时间戳，value=订单号
14. 删除时间窗口外面的记录：zremrangebyscore key min max: key=uid, min=0, max=当前时间戳-窗口大小（比如：1000=1秒）
15. 统计窗口内的条数：zcard key: key=uid，判断count和限流值大小关系，决定是否丢弃当前请求

方法2：incr and expire
https://redis.com/glossary/rate-limiting/
16. get key: key=uid:minute，即key由uid+当前分钟数组成，比如xxxx:3，表示xxxx用户第3分钟的访问次数
17. 如果值存在，且大于限流值，比如20，则抛限流异常
18. incr key; expire key 59： 加一，且1分钟后过期
    注意：上面方法，incr key，如果key不存在，那么key的值会先被初始化为0，然后再执行 INCR 操作，即始终会设置值为1，不会报错

方法3：令牌桶
令牌桶和漏捅区别：

瞬时速率：如果在一瞬间有很多请求进来，此时来不及产生令牌，则在一瞬间最多只有n个请求能获取到令牌执行业务逻辑，所以令牌桶算法也可以控制瞬时速率
        漏桶由于出水量固定，所以无法应对突然的流量爆发访问，也就是没有保证瞬时速率的功能，但是可以保证平均速率
场景：漏桶更适用于“秒杀、抢购、热点时间”等场景，因为这种场景用漏桶的话是先缓存请求，但是令牌桶则是先丢弃请求，会造成大量报错

lua 脚本:
```lua
local key = KEYS[1]
local capacity = tonumber(ARGV[1])
local rate = tonumber(ARGV[2]) -- token生成速率，每秒多少个
local now = tonumber(ARGV[3])

-- 上次生成令牌的时间
local last_time = tonumber(redis.call('hget', key, 'last_time') or 0)

-- 上次剩余的token
local current_tokens = tonumber(redis.call('hget', key, 'tokens') or 0)

local elapsed_time = now - last_time

-- 新生成的token
local new_tokens = elapsed_time * rate / 1000

if new_tokens > 0 then
   redis.call('hset', key, 'last_time', now)
end

local tokens = math.min(current_tokens + new_tokens, capacity)

if tokens >= 1 then
   redis.call('hset', key, 'tokens', tokens - 1)
   return 1 -- 未触发限流 
else
   return 0 -- 触发限流 
end
```

```java
// 使用上面脚本的代码
public boolean tryAquire() {
   String script = ""; // 上面的脚本字符串
   long now = System.currentTimeMillis();
   int capacity = 100;
   int rate = 10;
   List<String> keys = Arrays.asList("rate_limit_key");
   List<String> args =Arrays.asList(String.valueOf(capacity), String.valueOf(rate), String.valueOf(now));

   Long result = (Long)jedis.eval(script, keys, args);
   return result == 1;
}
```


# redis大key

## 大key定义：
string 超过5MB
set list 等成员个数超过1w个

## 如何查找大 key
- bigkeys，redis自带命令，string类型统计的是value的字节数，另外4种复杂结构的类型统计的是元素个数，不能直观的看出value占用字节数
- memory usage keyname ，redis 4.0以后版本自带的命令
- 第三方监控

## 影响
- key一般只能落到一个单机，key过大，内存oom或达到阈值，导致重要key被逐出
- 查询、解析内容，占内存，占网络带宽，处理变慢，阻塞其它请求
- 给迁移、复制带来较大压力
- 删除大key问题 （DEL命令）
  - String 类型的key，DEL 时间复杂度是 O(1)，大key除外。
  - List/Hash/Set/ZSet 类型的key，DEL 时间复杂度是 O(M)，M 为元素数量，元素越多，耗时越久。
  - 大Key如果一次性执行删除操作，会立即触发大量内存的释放过程。这个过程中，操作系统需要将释放的内存块重新插入空闲内存块链表，以便之后的管理和再分配。由于这个过程是同步进行的，并且可能涉及大量的内存块操作，因此它将占用相当一部分处理时间，并可能造成Redis主线程的阻塞。这种阻塞会导致Redis无法及时响应其他命令请求，从而引起请求超时，超时的累积可能会导致Redis连接耗尽，进而产生服务异常。因此删除大key，一定要慎之又慎，可以选择异步删除或批量删除。
  - 异步删除命令：UNLINK，当使用UNLINK删除一个大Key时，Redis不会立即释放关联的内存空间，而是将删除操作放入后台处理队列中。Redis会在处理命令的间隙，逐步执行后台队列中的删除操作，从而不会显著影响服务器的响应性能。
  - 批量删除命令：主要是针对Hash、List、Set、Zset，用 sscan、zscan、hascan等，扫描大key下面的一部分内容，批量删除，再扫描下一批；针对List，每次用ltrim删除list的一部分内容

## 解决
- 业务模型优化，避免内容集中在一个key中；减少不必要的内容存储；业务编码，比如就3个图片，用012表示，具体url存前端；定期清理，避免数据堆积
- 拆分大key，分布到集群的不同机器上去；单机模式，也可以拆分成多个小key；
- 压缩数据

