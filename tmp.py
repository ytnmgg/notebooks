class SeqMap:
    def __init__(self):
        self.m = {}
        self.arr = []

    def getByKey(self, key):
        return self.m[key]

    def getByIndex(self, index):
        if index > len(self.arr) - 1:
            return None
        
        return self.m[self.arr[index]]

    def put(self, key, value):
        if key in self.m:
            self.m[key] = value
        else:
            self.m[key] = value
            self.arr.append(key)

    def deleteByKey(self, key):
        if key not in self.m:
            return

        del self.m[key]
        
        tmp = []
        for k in self.arr:
            if k != key:
                tmp.append(k)
        self.arr = tmp

    def deleteByIndex(self, index):
        if index > len(self.arr) - 1:
            return
        
        key = self.arr[index]
        del self.m[key]
        
        tmp = []
        for k in self.arr:
            if k != key:
                tmp.append(k)
        self.arr = tmp
        

seqMap = SeqMap()
seqMap.put('k1','v1')
print(seqMap.m)