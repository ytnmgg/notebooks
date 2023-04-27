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
![234_redblack_2.jpg](https://raw.githubusercontent.com/ytnmgg/notebooks/master/algorithms/image/234_redblack_2.jpg)
![234_redblack_3.jpg](https://raw.githubusercontent.com/ytnmgg/notebooks/master/algorithms/image/234_redblack_3.jpg)
![234_redblack_4.jpg](https://raw.githubusercontent.com/ytnmgg/notebooks/master/algorithms/image/234_redblack_4.jpg)


1. 新增的是第一个节点：无需调整，默认就是黑色
2. 234树是2节点，新增节点与之合并成3节点：新增红色，父亲黑色，上黑下红规则满足，无需调整
3. 234树是3节点，新增节点与之合并成4节点：新增红色，如果父亲红色，需要调整；如果父亲黑色，不需要调整
4. 234树是4节点，新增节点发生裂变：原4节点对应的红黑树是稳定的上黑下红形态，所以新增的红色节点父亲一定是红色，需要调整


## 插入新节点后进行调整
```java
private void fixAfterInsertion(Entry<K,V> x) {
    // 新增节点都是红色的
    x.color = RED;

    // 父亲是红色，新加的又是红色，出现红红相连，才需要调整
    // 上面2/3/4几种情况中，父亲是黑色的情况，都不需要调整
    while (x != null && x != root && x.parent.color == RED) {
        // 插入节点的父亲是爷爷的左孩，有几种可能
        // 1. 情况3的A、B
        // 2. 情况4的A、B
        if (parentOf(x) == leftOf(parentOf(parentOf(x)))) {
            // 叔叔节点
            Entry<K,V> y = rightOf(parentOf(parentOf(x)));
            
            if (colorOf(y) == RED) {
                // 情况4的A/B，叔叔存在
                // 这种变化颜色即可: 爷爷变成红（爷爷如果是root，最后还是会变黑），父亲和叔叔变黑
                // 为什么不插入的x变黑就行了？这样的话就不黑平衡了，父亲分支路径黑色会比叔叔分支黑色多一个,所以要求新增的节点都是红色
                setColor(parentOf(x), BLACK);
                setColor(y, BLACK);
                setColor(parentOf(parentOf(x)), RED);
                x = parentOf(parentOf(x));
            } else {
                // 情况3的A/B，叔叔不存在
                // 注意colorOf默认是黑色，即叔叔节点不存在会进入这个else逻辑

                // 情况3的B，以x的父亲为中心左旋
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


## 旋转算法
```java
private void rotateLeft(Entry<K,V> p) {
    if (p != null) {
        // 右旋，p落下去，p的右孩顶替它的原来位置
        Entry<K,V> r = p.right;

        // p的右孩的左孩挂到p的右孩
        // 因为旋转前，p的右孩（r）及其子孙都比p大，大小关系：p的右孩>p的右孩的左孩>p
        // 所以旋转后，p的右孩（r）占了p的原有位置，r的原左孩及p都位于r的左侧，但是p更小，所以r的原左孩新的位置是p的右孩（大小介于p和r之间）
        p.right = r.left;

        // 双向指针，还需要反着指一下
        if (r.left != null)
            r.left.parent = p;

        // r占了p的位置，双向指针，r的父需要改成原p的父
        r.parent = p.parent;

        // 双向指针，还需要反着指一下（需要分左右两种情况）
        if (p.parent == null)
            root = r;
        else if (p.parent.left == p)
            p.parent.left = r;
        else
            p.parent.right = r;

        // 双向指针，r的左指向p，p的父指向r 
        r.left = p;
        p.parent = r;
    }
}

private void rotateRight(Entry<K,V> p) {
    if (p != null) {
        // 右旋，p落下去，p的左孩顶替它的原来位置
        Entry<K,V> l = p.left;

        // p的左孩的右孩挂到p的左孩
        // 因为旋转前，p的左孩（l）及其子孙都比p小，大小关系：p的左孩<p的左孩的右孩<p
        // 所以旋转后，p的左孩（l）占了p的原有位置，l的原右孩及p都位于l的右侧，但是p更大，所以l的原右孩新的位置是p的左孩（大小介于l和p之间）
        p.left = l.right;

        // 双向指针，还需要反着指一下
        if (l.right != null) l.right.parent = p;

        // l占了p的位置，双向指针，l的父需要改成原p的父
        l.parent = p.parent;

        // 双向指针，还需要反着指一下（需要分左右两种情况）
        if (p.parent == null)
            root = l;
        else if (p.parent.right == p)
            p.parent.right = l;
        else p.parent.left = l;

        // 双向指针，l的右指向p，p的父指向l
        l.right = p;
        p.parent = l;
    }
}
```