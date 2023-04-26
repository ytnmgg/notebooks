# [LinkedList] 实现一个LRU
LRU：缓存策略，使用最少的淘汰，比如Redis或者Google Guava等都使用这种策略

可以基于LinkedList来实现LRU，因为LinkedList基于双向链表，可以考虑把最长使用的放到队头，每次淘汰队尾
```java
  public class Play {
    private static final int MAX_LEN = 100;
    LinkedList<String> lru = new LinkedList<String>();

    public String get(int index) {
        String item = lru.get(index);

        // 查询一次，热点上升到最热，从原位置挪到队首去
        lru.remove(index);
        add(item);

        return item;
    }

    public void add(String item) {
        // 超了，删掉队尾的最不常访问的
        if (lru.size() >= MAX_LEN) {
            lru.removeLast();
        }
        lru.addFirst(item);
    }
}
```
