## 红黑树5大性质
1. 节点是红色或黑色
2. 根节点是黑色
3. 所有叶子都是黑色（叶子是NIL节点，一般不画出来）
4. 每个红色节点必须有两个黑色的子节点（从每个叶子到根的所有路径不能有两个连续的红节点）
5. 从任一节点到每个叶子路径包含相同数量的黑节点（黑平衡）


234树与红黑树的对应关系（基础原则要记牢）
![234_redblack.jpg](https://raw.githubusercontent.com/ytnmgg/notebooks/master/algorithms/image/234_redblack.jpg)


## 插入新节点
```java
public V put(K key, V value) {
    // root是成员变量，表示TreeMap的根节点
    Entry<K,V> t = root;

    // 如果当前treeMap为空，没有root节点，当前插入的就是第一个节点
    if (t == null) {
        compare(key, key); // type (and possibly null) check

        root = new Entry<>(key, value, null);
        size = 1;
        modCount++;
        return null;
    }


    int cmp;
    Entry<K,V> parent;
    // split comparator and comparable paths
    Comparator<? super K> cpr = comparator;
    if (cpr != null) {
        // 选择1：自定义比较器的逻辑
        do {
            parent = t;
            cmp = cpr.compare(key, t.key);
            if (cmp < 0)
                t = t.left;
            else if (cmp > 0)
                t = t.right;
            else
                return t.setValue(value);
        } while (t != null);
    }
    else {
        // 选择2：使用系统比较器的逻辑
        if (key == null)
            throw new NullPointerException();
        @SuppressWarnings("unchecked")
            Comparable<? super K> k = (Comparable<? super K>) key;

        do {
            // parent指向t的当前位置（从root开始往下找）
            parent = t;
            // 插入的key和当前位置（从root开始）比较
            cmp = k.compareTo(t.key);
            // 根据key的比较，决定t往左下寻找还是往右下寻找
            if (cmp < 0)
                // t往当前节点的左边往下找
                t = t.left;
            else if (cmp > 0)
                // t往当前节点的右边往下找
                t = t.right;
            else
                // 因为是map，key唯一，出现key相同，则直接覆盖value
                return t.setValue(value);
        
        // 如果t已经到了叶子节点（最后一层节点的再下面的空节点），退出循环
        } while (t != null);
    }

    // 没有发现已经存在的key，且已经到了应该追加的位置
    // new一个新节点出来（e的parent指向刚刚一直跟着走的parent指针指向的位置）
    Entry<K,V> e = new Entry<>(key, value, parent);
    // 根据t在parent的左下边还是右下边，决定parent的孩子节点的指向
    // 插入之前，parent的左孩或右孩节点应该是指向空的，现在需要指向新增的e节点
    if (cmp < 0)
        parent.left = e;
    else
        parent.right = e;
    
    // 重新作色和调整位置（红黑树的重点）
    fixAfterInsertion(e);
    size++;
    modCount++;
    return null;
}
```
### 新增节点的几种情况：


## 插入新节点后进行调整
```java
private void fixAfterInsertion(Entry<K,V> x) {
    // 新增节点都是红色的
    x.color = RED;

    // 1. 如果插入的是第一个节点（root节点），则不用处理，直接结束
    // 2. 如果不是root节点，则一定有parent，
    while (x != null && x != root && x.parent.color == RED) {
        if (parentOf(x) == leftOf(parentOf(parentOf(x)))) {
            Entry<K,V> y = rightOf(parentOf(parentOf(x)));
            if (colorOf(y) == RED) {
                setColor(parentOf(x), BLACK);
                setColor(y, BLACK);
                setColor(parentOf(parentOf(x)), RED);
                x = parentOf(parentOf(x));
            } else {
                if (x == rightOf(parentOf(x))) {
                    x = parentOf(x);
                    rotateLeft(x);
                }
                setColor(parentOf(x), BLACK);
                setColor(parentOf(parentOf(x)), RED);
                rotateRight(parentOf(parentOf(x)));
            }
        } else {
            Entry<K,V> y = leftOf(parentOf(parentOf(x)));
            if (colorOf(y) == RED) {
                setColor(parentOf(x), BLACK);
                setColor(y, BLACK);
                setColor(parentOf(parentOf(x)), RED);
                x = parentOf(parentOf(x));
            } else {
                if (x == leftOf(parentOf(x))) {
                    x = parentOf(x);
                    rotateRight(x);
                }
                setColor(parentOf(x), BLACK);
                setColor(parentOf(parentOf(x)), RED);
                rotateLeft(parentOf(parentOf(x)));
            }
        }
    }

    // 根节点一定是黑色的
    root.color = BLACK;
}
```