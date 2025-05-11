///|
const Default_init_capacity = 8

///|
fn calc_grow_threshold(capacity : Int) -> Int {
  capacity * 3 / 4 // 75% 负载因子
}

///|
/// Creates a new empty hash map with the specified initial capacity. The actual
/// capacity will be rounded up to the next power of 2 that is greater than or
/// equal to the requested capacity, with a minimum of 8.
///
/// Parameters:
///
/// * `capacity` : The desired minimum capacity of the hash map. Must be a
/// non-negative integer. Defaults to 8 if not specified.
///
/// Returns a new empty hash map of type `T[K, V]`, where `K` is the key type and
/// `V` is the value type.
///
/// Example:
///
/// ```moonbit
/// test "new" {
///   let map : @hashmap.T[String, Int] = @hashmap.new(capacity=16)
///   inspect!(map.capacity(), content="16")
///   inspect!(map.is_empty(), content="true")
/// }
/// ```
pub fn new[K, V](capacity~ : Int = Default_init_capacity) -> T[K, V] {
  {
    core: {
      hash_to_idx: @hashmap.new(),
      entries: [],
      head: -1,
      tail: -1,
      position_to_idx: [], // 初始化为空数组
      idx_to_position: @hashmap.new(), // 初始化为空映射
    },
    size: 0,
    capacity,
    growAt: calc_grow_threshold(capacity),
    key_to_idx: @hashmap.new(),
  }
}

///|
/// Creates a new hash map from an array of key-value pairs. Pairs with duplicate
/// keys will keep the latest value, overwriting the previous ones.
///
/// Parameters:
///
/// * `arr` : An array of key-value tuples. Each tuple contains a hashable and
/// comparable key of type `K`, and an associated value of type `V`.
///
/// Returns a new hash map containing all the key-value pairs from the input
/// array.
///
/// Example:
///
/// ```moonbit
/// test "from_array" {
///   let arr = [(1, "one"), (2, "two"), (1, "ONE")]
///   let map = @hashmap.from_array(arr)
///   inspect!(map.get(1), content="Some(\"ONE\")")
///   inspect!(map.get(2), content="Some(\"two\")")
/// }
/// ```
///|
/// Create a map from an array of key-value pairs
pub fn from_array[K : Hash + Eq, V](arr : Array[(K, V)]) -> T[K, V] {
  let map = new(capacity=arr.length())
  for i in 0..<arr.length() {
    let (key, value) = arr[i]
    map.set(key, value)
  }
  map
}

///|
/// Sets a key-value pair into the hash map. If the key already exists, updates
/// its value. If the hash map is near full capacity (>= 50%), automatically
/// grows the internal storage to accommodate more entries.
///
/// Parameters:
///
/// * `map` : The hash map to modify.
/// * `key` : The key to insert or update. Must implement `Hash` and `Eq` traits.
/// * `value` : The value to associate with the key.
///
/// Example:
///
/// ```moonbit
/// test "set" {
///   let map : @hashmap.T[String, Int] = @hashmap.new()
///   map.set("key", 42)
///   inspect!(map.get("key"), content="Some(42)")
///   map.set("key", 24) // update existing key
///   inspect!(map.get("key"), content="Some(24)")
/// }
/// ```
///
/// @alert unsafe "Panic if the hash map is full."
///|
/// Sets a key-value pair into the map. If the key already exists, updates its value.
pub fn set[K : Hash + Eq, V](self : T[K, V], key : K, value : V) -> Unit {
  // 计算哈希值
  let hash = key.hash()

  // 检查键是否已存在
  if self.key_to_idx.contains(key) {
    // 键已存在，更新值
    let idx = self.key_to_idx.get(key).unwrap()
    self.core.entries[idx].value = value
    return
  }

  // 创建新的桶
  let bucket_idx = self.core.entries.length()
  let new_bucket = {
    hash,
    key,
    value,
    next: -1, // 无后继
    prev: self.core.tail,
  } // 前驱为当前尾节点

  // 添加到桶数组
  self.core.entries.push(new_bucket)

  // 在映射中记录键到索引的映射
  self.key_to_idx.set(key, bucket_idx)

  // 在添加新元素时更新idx_to_position
  self.core.idx_to_position.set(bucket_idx, self.size)

  // 更新链表结构
  if self.core.tail != -1 {
    // 更新原尾节点的后继为新节点
    self.core.entries[self.core.tail].next = bucket_idx
  }

  // 更新尾节点
  self.core.tail = bucket_idx

  // 如果这是第一个元素，也更新头节点
  if self.core.head == -1 {
    self.core.head = bucket_idx
  }

  // 在哈希表中记录
  self.core.hash_to_idx.set(hash, bucket_idx)

  // 更新位置到索引的映射
  self.core.position_to_idx.push(bucket_idx)

  // 更新大小
  self.size += 1

  // 插入完成后，检查是否需要为下一次插入扩容
  if self.capacity == 0 || self.size >= self.growAt {
    self.grow()
  }
}

///|///|
/// Sets a key-value pair with a pre-computed hash
pub fn set_with_hash[K : Hash + Eq, V](
  self : T[K, V],
  key : K,
  value : V,
  hash : Int
) -> Unit {
  // 检查键是否已存在
  if self.key_to_idx.contains(key) {
    // 键已存在，更新值
    let idx = self.key_to_idx.get(key).unwrap()
    self.core.entries[idx].value = value
    return
  }

  // 创建新的桶
  let bucket_idx = self.core.entries.length()
  let new_bucket = {
    hash,
    key,
    value,
    next: -1, // 无后继
    prev: self.core.tail,
  } // 前驱为当前尾节点

  // 添加到桶数组
  self.core.entries.push(new_bucket)

  // 在映射中记录键到索引的映射
  self.key_to_idx.set(key, bucket_idx)

  // 更新链表结构
  if self.core.tail != -1 {
    // 更新原尾节点的后继为新节点
    self.core.entries[self.core.tail].next = bucket_idx
  }

  // 更新尾节点
  self.core.tail = bucket_idx

  // 如果这是第一个元素，也更新头节点
  if self.core.head == -1 {
    self.core.head = bucket_idx
  }

  // 在哈希表中记录
  self.core.hash_to_idx.set(hash, bucket_idx)

  // 更新位置到索引的映射
  self.core.position_to_idx.push(bucket_idx)

  // 更新大小
  self.size += 1

  // 插入完成后，检查是否需要为下一次插入扩容
  if self.capacity == 0 || self.size >= self.growAt {
    self.grow()
  }
}

///|
/// Sets the value associated with a key in the hash map. If the key already
/// exists, updates its value; otherwise, adds a new key-value pair. This
/// function is automatically called when using the index assignment syntax
/// `map[key] = value`.
///
/// Parameters:
///
/// * `map` : The hash map to modify.
/// * `key` : The key to associate with the value. Must implement `Hash` and `Eq`
/// traits.
/// * `value` : The value to associate with the key.
///
/// Example:
///
/// ```moonbit
/// test "op_set" {
///   let map : @hashmap.T[String, Int] = @hashmap.new()
///   map["key"] = 42
///   inspect!(map.get("key"), content="Some(42)")
/// }
/// ```
pub fn op_set[K : Hash + Eq, V](self : T[K, V], key : K, value : V) -> Unit {
  self.set(key, value)
}

///|
/// Retrieves the value associated with a given key in the hash map.
///
/// Parameters:
///
/// * `self` : The hash map to search in.
/// * `key` : The key to look up in the map.
///
/// Returns `Some(value)` if the key exists in the map, `None` otherwise.
///
/// Example:
///
/// ```moonbit
/// test "get" {
///   let map = @hashmap.of([("key", 42)])
///   inspect!(map.get("key"), content="Some(42)")
///   inspect!(map.get("nonexistent"), content="None")
/// }
/// ```
pub fn get[K : Hash + Eq, V](self : T[K, V], key : K) -> V? {
  // 直接从键到索引的映射中查找
  match self.key_to_idx.get(key) {
    Some(idx) => Some(self.core.entries[idx].value)
    None => None
  }
}

///|
/// Gets the key-value pair at the given index position.
pub fn get_at[K, V](self : T[K, V], index : Int) -> (K, V)? {
  if index < 0 || index >= self.size {
    return None
  }

  // 直接从位置到索引的映射获取桶索引
  let bucket_idx = self.core.position_to_idx[index]

  // 获取对应的桶
  let bucket = self.core.entries[bucket_idx]

  // 返回键值对
  Some((bucket.key, bucket.value))
}

///|
fn get_with_hash[K : Eq, V](self : T[K, V], key : K, hash : Int) -> V? {
  // 首先检查哈希值是否在 hash_to_idx 中
  match self.core.hash_to_idx.get(hash) {
    Some(idx) => {
      // 找到了哈希值对应的索引，但还需要检查键是否匹配（处理哈希冲突）
      let entry = self.core.entries[idx]
      if entry.key == key {
        return Some(entry.value)
      }

      // 哈希碰撞但键不匹配的情况
      None
    }
    None => None
  }
}

///|
/// Retrieves a value from the hash map using the index operator syntax. This
/// method is automatically called when using the square bracket notation
/// `map[key]`.
///
/// Parameters:
///
/// * `map` : The hash map to retrieve the value from.
/// * `key` : The key to look up in the map. Must implement both `Hash` and `Eq`
/// traits.
///
/// Returns `Some(value)` if the key exists in the map, `None` otherwise.
///
/// Example:
///
/// ```moonbit
/// test "op_get" {
///   let map = @hashmap.of([("key", 42)])
///   inspect!(map["key"], content="Some(42)")
///   inspect!(map["nonexistent"], content="None")
/// }
/// ```
pub fn op_get[K : Hash + Eq, V](self : T[K, V], key : K) -> V? {
  self.get(key)
}

///|
/// Gets the value associated with the given key. If the key doesn't exist in the
/// map, initializes it with the result of calling the provided initialization
/// function.
///
/// Parameters:
///
/// * `self` : The hash map.
/// * `key` : The key to look up in the map.
/// * `init` : A function that takes no arguments and returns a value to be
/// associated with the key if it doesn't exist.
///
/// Returns the value associated with the key, either existing or newly
/// initialized.
///
/// Example:
///
/// ```moonbit
/// test "get_or_init" {
///   let map : @hashmap.T[String, Int] = @hashmap.new()
///   let value = map.get_or_init("key", fn() { 42 })
///   inspect!(value, content="42")
///   inspect!(map.get("key"), content="Some(42)")
/// }
/// ```
pub fn get_or_init[K : Hash + Eq, V](
  self : T[K, V],
  key : K,
  init : () -> V
) -> V {
  let hash = key.hash()
  match self.get_with_hash(key, hash) {
    Some(v) => v
    None => {
      let v = init()
      self.set_with_hash(key, v, hash)
      v
    }
  }
}

///|
/// Gets the value associated with a given key from the hash map. If the key
/// doesn't exist, returns the provided default value instead.
///
/// Parameters:
///
/// * `map` : The hash map to retrieve the value from.
/// * `key` : The key to look up in the map.
/// * `default` : The value to return if the key is not found in the map.
///
/// Returns the value associated with the key if it exists, otherwise returns the
/// default value.
///
/// Example:
///
/// ```moonbit
/// test "get_or_default" {
///   let map = @hashmap.of([("a", 1), ("b", 2)])
///   inspect!(map.get_or_default("a", 0), content="1")
///   inspect!(map.get_or_default("c", 0), content="0")
/// }
/// ```
pub fn get_or_default[K : Hash + Eq, V](
  self : T[K, V],
  key : K,
  default : V
) -> V {
  match self.get(key) {
    Some(v) => v
    None => default
  }
}

///|
/// Checks if a key exists in the hash map.
///
/// Parameters:
///
/// * `self` : The hash map to search in.
/// * `key` : The key to look for in the hash map.
///
/// Returns `true` if the key exists in the hash map, `false` otherwise.
///
/// Example:
///
/// ```moonbit
/// test "contains" {
///   let map = @hashmap.of([("a", 1), ("b", 2)])
///   inspect!(map.contains("a"), content="true")
///   inspect!(map.contains("c"), content="false")
/// }
/// ```
pub fn contains[K : Hash + Eq, V](self : T[K, V], key : K) -> Bool {
  match self.get(key) {
    Some(_) => true
    None => false
  }
}

///|
/// Removes the entry for the specified key from the hash map. If the key exists
/// in the map, removes its entry and adjusts the probe sequence length (PSL) of
/// subsequent entries to maintain the Robin Hood hashing invariant. If the key
/// does not exist, the map remains unchanged.
///
/// Parameters:
///
/// * `self` : The hash map to remove the entry from.
/// * `key` : The key to remove from the map.
///
/// Example:
///
/// ```moonbit
/// test "remove" {
///   let map = @hashmap.of([("a", 1), ("b", 2)])
///   map.remove("a")
///   inspect!(map.get("a"), content="None")
///   inspect!(map.size(), content="1")
/// }
/// ```
///|
/// Removes a key from the map.
pub fn remove[K : Hash + Eq, V](self : T[K, V], key : K) -> Unit {
  if self.size == 0 {
    return
  }

  // 直接从映射中获取索引
  match self.key_to_idx.get(key) {
    Some(idx) => {
      // 获取被删除元素的链表信息
      let entry = self.core.entries[idx]
      let hash = entry.hash

      // 获取被删除元素的位置索引
      // 此处一定能获取到位置，因为idx是从key_to_idx中获得的有效索引
      // 如果key_to_idx包含这个键，那么idx_to_position也应该包含对应的索引
      let position = self.core.idx_to_position.get(idx).unwrap()

      // 修复链表指针
      // 如果有前一个元素，更新它的next指针
      if entry.prev != -1 {
        self.core.entries[entry.prev].next = entry.next
      } else {
        // 如果是头节点，更新head指针
        self.core.head = entry.next
      }

      // 如果有后一个元素，更新它的prev指针
      if entry.next != -1 {
        self.core.entries[entry.next].prev = entry.prev
      } else {
        // 如果是尾节点，更新tail指针
        self.core.tail = entry.prev
      }

      // 从哈希表中移除
      self.core.hash_to_idx.remove(hash)

      // 从键到索引的映射中移除
      self.key_to_idx.remove(key)

      // 如果要删除的不是最后一个元素，则需要移动最后一个元素并更新位置映射
      if position < self.size - 1 {
        // 获取最后一个元素的索引
        let last_idx = self.core.position_to_idx[self.size - 1]

        // 将最后一个元素移动到被删除元素的位置
        self.core.position_to_idx[position] = last_idx

        // 更新索引到位置的映射
        self.core.idx_to_position.set(last_idx, position)
      }

      // 从位置映射中移除最后一个位置
      ignore(self.core.position_to_idx.pop())

      // 从索引到位置的映射中移除被删除元素
      self.core.idx_to_position.remove(idx)

      // 更新大小
      self.size -= 1
    }
    None => return // 键不存在，不执行任何操作
  }
}
///|

///|
/// Creates a new hash map from a fixed array of key-value pairs.
///
/// Parameters:
///
/// * `pairs` : A fixed array of tuples, where each tuple contains a key of type
/// `K` and a value of type `V`. The key type must implement both `Eq` and `Hash`
/// traits.
///
/// Returns a new hash map containing all the key-value pairs from the input
/// array.
///
/// Example:
///
/// ```moonbit
/// test "of" {
///   let map = @hashmap.of([(1, "one"), (2, "two")])
///   inspect!(map.get(1), content="Some(\"one\")")
///   inspect!(map.get(2), content="Some(\"two\")")
/// }
/// ```
/// Create a map from a fixed array of key-value pairs
pub fn of[K : Hash + Eq, V](arr : FixedArray[(K, V)]) -> T[K, V] {
  let map = new(capacity=arr.length())
  for i in 0..<arr.length() {
    let (key, value) = arr[i]
    map.set(key, value)
  }
  map
}

///|
test "of" {
  let m = of([(1, 2), (3, 4)])
  inspect!(m.get(1), content="Some(2)")
  inspect!(m.get(3), content="Some(4)")
}

///|
/// Implements random generation of hashmaps for property-based testing through
/// the `Arbitrary` trait.
///
/// Parameters:
///
/// * `size` : The size hint for generating random key-value pairs. Larger values
/// typically result in larger hashmaps.
/// * `random_state` : The random state used for generating key-value pairs.
///
/// Returns a randomly generated hashmap containing arbitrary key-value pairs.
///
/// Example:
///
/// ```moonbit
/// test "arbitrary" {
///   let samples : Array[@hashmap.T[Int, String]] = @quickcheck.samples(5)
///   inspect!(samples.length(), content="5")
/// }
/// ```
pub impl[K : @quickcheck.Arbitrary + Hash + Eq, V : @quickcheck.Arbitrary] @quickcheck.Arbitrary for T[
  K,
  V,
] with arbitrary(size, rs) {
  let m = new()
  (@quickcheck.Arbitrary::arbitrary(size, rs) : Iter[(K, V)]).each(fn {
    (k, v) => m.set(k, v)
  })
  m
}

///|
priv type MyString String derive(Eq)

///|
impl Hash for MyString with hash(self) {
  self._.length()
}

///|
impl Hash for MyString with hash_combine(self, hasher) {
  hasher.combine_string(self._)
}

///|
impl Show for MyString with output(self, logger) {
  logger.write_string(self._)
}

///|
test "MyString hash_combine implementation" {
  // 创建两个内容相同但对象不同的MyString实例
  let str1 = "test_string"
  let str2 = "test_string"

  // 创建一个使用MyString作为键的映射
  let map = new()

  // 使用第一个字符串设置值
  map.set(str1, "value1")

  // 使用第二个字符串读取值 - 如果哈希正确合并，应该找到相同的值
  let result = map.get(str2)

  // 验证结果
  assert_eq!(result, Some("value1"))

  // 确认只有一个元素（即两个MyString哈希到同一个桶）
  assert_eq!(map.size(), 1)

  // 测试哈希值本身是否一致
  assert_eq!(str1.hash(), str2.hash())

  // 测试不同内容的字符串是否正确区分
  let str3 = "different_string"
  assert_true!(str1.hash() != str3.hash())
}

///|
test "arbitrary" {
  //  let samples : Array[T[String, Int]] = @quickcheck.samples(20)
  //  inspect!(
  //   samples[5:10],
  //   content=
  //     #|[HashMap::of([("", -1)]), HashMap::of([("E9", 0), ("", 0), ("h", 1)]), HashMap::of([("\x07", -1), ("", 0)]), HashMap::of([("", 0)]), HashMap::of([("", 0), ("\x02", 1)])]
  //   ,
  /// )
  // inspect!(
  //  samples[11:15],
  //  content=
  //    #|[HashMap::of([("4j", -2), ("v\x05", 0), ("", 0)]), HashMap::of([("", 0)]), HashMap::of([("Vw\b", 6), ("T", 0), ("m", 5), ("", 4)]), HashMap::of([])]
  //  ,
  //)
}

///|
test "set" {
  let m : T[MyString, Int] = new()
  m.set("a", 1)
  m.set("b", 1)
  m.set("bc", 2)
  m.set("abc", 3)
  m.set("cd", 2)
  m.set("c", 1)
  m.set("d", 1)
  // assert_eq!(m.size(), 7)
  //  inspect!(
  //   m.debug_entries(),
  //   content="_,(0,a,1),(1,b,1),(2,c,1),(3,d,1),(3,bc,2),(4,cd,2),(4,abc,3),_,_,_,_,_,_,_,_",
  // )
}

///|
test "remove" {
  let m : T[MyString, Int] = new()
  m.set("a", 1)
  m.set("ab", 2)
  m.set("bc", 2)
  m.set("cd", 2)
  m.set("abc", 3)
  m.set("abcdef", 6)
  m.remove("ab")
  assert_eq!(m.size(), 5)
  // inspect!(
  //    m.debug_entries(),
  //  content="_,(0,a,1),(0,bc,2),(1,cd,2),(1,abc,3),_,(0,abcdef,6),_,_,_,_,_,_,_,_,_",
  // )
}

///|
test "remove_unexist_key" {
  let m : T[MyString, Int] = new()
  m.set("a", 1)
  m.set("ab", 2)
  m.set("abc", 3)
  m.remove("d")
  assert_eq!(m.size(), 3)
  // inspect!(m.debug_entries(), content="_,(0,a,1),(0,ab,2),(0,abc,3),_,_,_,_")
}

///|
test "clear" {
  let m : T[MyString, Int] = of([("a", 1), ("b", 2), ("c", 3)])
  println(m.capacity())
  let old_capacity = m.capacity()
  m.clear()

  // 验证基本属性
  assert_eq!(m.size(), 0)
  assert_eq!(m.capacity(), old_capacity) // 容量应保持不变

  // 验证内部结构已正确清空
  assert_eq!(m.core.entries.length(), 0) // entries 应为空数组
  assert_eq!(m.core.head, -1) // 头指针应为 -1
  assert_eq!(m.core.tail, -1) // 尾指针应为 -1
  assert_eq!(m.core.position_to_idx.length(), 0) // 位置映射应为空

  // 验证功能正确性
  assert_eq!(m.get("a"), None)
  assert_eq!(m.get("b"), None)
  assert_eq!(m.get("c"), None)
}

///|
test "grow" {
  let m : T[MyString, Int] = new()
  m.set("C", 1)
  m.set("Go", 2)
  m.set("C++", 3)
  m.set("Java", 4)
  m.set("Scala", 5)
  inspect!(m.capacity(), content="8")
  m.set("Julia", 5)
  assert_eq!(m.size(), 6)
  inspect!(m.capacity(), content="16")
  println(m.debug_entries())
  // inspect!(
  //   m.debug_entries(),
  //   content="_,(0,C,1),(0,Go,2),(0,C++,3),(0,Java,4),(0,Scala,5),(1,Julia,5),(2,Cobol,5),(2,Python,6),(2,Haskell,7),(2,Rescript,8),_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_",
  //)
}

///|
/// Returns the number of key-value pairs in the map.
pub fn size[K, V](self : T[K, V]) -> Int {
  self.size
}

///|
pub fn capacity[K, V](self : T[K, V]) -> Int {
  self.capacity
}

///|
/// Check if the map is empty.
pub fn is_empty[K, V](self : T[K, V]) -> Bool {
  self.size == 0
}

///|
/// Check if the map contains a key.
pub fn contains_key[K : Hash + Eq, V](self : T[K, V], key : K) -> Bool {
  self.key_to_idx.contains(key)
}

///|
/// Clears the map, removing all key-value pairs.
pub fn clear[K, V](self : T[K, V]) -> Unit {
  self.core.hash_to_idx.clear()
  self.core.entries = []
  self.core.head = -1
  self.core.tail = -1
  self.core.position_to_idx = []
  self.core.idx_to_position = @hashmap.new() // 清空索引到位置的映射
  self.size = 0
  self.key_to_idx = @hashmap.new()
}

///|
/// Convert the map to an array of key-value pairs
///|
/// Convert the map to an array of key-value pairs
pub fn to_array[K, V](self : T[K, V]) -> Array[(K, V)] {
  if self.size == 0 {
    return []
  }

  // 创建空数组
  let result = []

  // 遍历链表填充数组
  let mut current = self.core.head
  while current != -1 {
    let entry = self.core.entries[current]
    result.push((entry.key, entry.value))
    current = entry.next
  }
  result
}

///|
/// Grow the map capacity
fn grow[K : Hash + Eq, V](self : T[K, V]) -> Unit {
  // 保存旧数据
  let old_entries = self.core.entries
  let old_head = self.core.head

  // 创建新的存储
  if self.capacity == 0 {
    self.capacity = 8 // 设置默认初始容量
  } else {
    self.capacity = self.capacity * 2
  }
  self.growAt = calc_grow_threshold(self.capacity)
  self.core.hash_to_idx = @hashmap.new()
  self.core.entries = []
  self.core.head = -1
  self.core.tail = -1
  self.core.position_to_idx = []
  self.core.idx_to_position = @hashmap.new()
  self.size = 0
  self.key_to_idx = @hashmap.new()

  // 重新添加所有元素，保持原顺序
  let mut current = old_head
  while current != -1 {
    let entry = old_entries[current]
    self.set(entry.key, entry.value)
    current = entry.next
  }
}

///|
fn debug_entries[K : Show, V : Show](self : T[K, V]) -> String {
  let mut s = ""
  let mut current = self.core.head
  let mut i = 0
  while current != -1 {
    if i > 0 {
      s = s + ","
    }
    let entry = self.core.entries[current]
    s = s + "(\{entry.key},\{entry.value})"
    current = entry.next
    i += 1
  }
  s
}

///|
/// Returns an iterator over the key-value pairs in the map.
///
/// Parameters:
///
/// * `map` : The index map to iterate over.
///
/// Returns an iterator that yields tuples of `(key, value)` for each entry in
/// the map, in insertion order.
///
/// Example:
///
/// ```moonbit
/// test "iter" {
///   let map = @IndexMap.of([(1, "one"), (2, "two")])
///   let pairs = map.iter().to_array()
///   inspect!(pairs.length(), content="2")
///   inspect!(pairs[0], content="(1, \"one\")")
///   inspect!(pairs[1], content="(2, \"two\")")
/// }
/// ```
pub fn iter[K, V](self : T[K, V]) -> Iter[(K, V)] {
  Iter::new(fn(yield_) {
    let mut current = self.core.head
    while current != -1 {
      let entry = self.core.entries[current]
      if yield_((entry.key, entry.value)) == IterEnd {
        return IterEnd
      }
      current = entry.next
    }
    IterContinue
  })
}

///|
/// Creates an iterator over the key-value pairs in the map, where the key and
/// value are passed as separate arguments to the yielding function.
///
/// Parameters:
///
/// * `map` : The index map to iterate over.
///
/// Returns an iterator `Iter2[K, V]` that yields each key-value pair in the map
/// as separate arguments in insertion order.
///
/// Example:
///
/// ```moonbit
/// test "iter2" {
///   let map = @IndexMap.of([(1, "one"), (2, "two")])
///   let mut sum = 0
///   map.iter2().each(fn(k, _) { sum = sum + k })
///   inspect!(sum, content="3")
/// }
/// ```
pub fn iter2[K, V](self : T[K, V]) -> Iter2[K, V] {
  Iter2::new(fn(yield_) {
    let mut current = self.core.head
    while current != -1 {
      let entry = self.core.entries[current]
      if yield_(entry.key, entry.value) == IterEnd {
        return IterEnd
      }
      current = entry.next
    }
    IterContinue
  })
}

///|
/// Creates a new index map from an iterator of key-value pairs.
///
/// Parameters:
///
/// * `iter` : An iterator that yields key-value pairs. The key type must
/// implement both `Hash` and `Eq` traits.
///
/// Returns a new index map containing all key-value pairs from the iterator. If
/// the iterator yields multiple pairs with the same key, the later value will
/// overwrite the earlier one.
///
/// Example:
///
/// ```moonbit
/// test "from_iter" {
///   let arr = [(1, "one"), (2, "two")]
///   let iter = Iter::new(fn(yield_) {
///     for pair in arr {
///       if yield_(pair) == IterEnd {
///         break IterEnd
///       }
///     } else {
///       IterContinue
///     }
///   })
///   let map = @IndexMap.from_iter(iter)
///   inspect!(map.get(1), content="Some(\"one\")")
///   inspect!(map.get(2), content="Some(\"two\")")
/// }
/// ```
pub fn from_iter[K : Hash + Eq, V](iter : Iter[(K, V)]) -> T[K, V] {
  let m = new()
  iter.each(fn(e) { m.set(e.0, e.1) })
  m
}

///|
/// Creates a new index map and inserts all key-value pairs from the given
/// iterator.
///
/// Parameters:
///
/// * `iter` : An iterator of key-value pairs, where each pair consists of a
/// hashable and equatable key of type `K` and a value of type `V`.
///
/// Returns a new index map containing all key-value pairs from the iterator.
///
/// Example:
///
/// ```moonbit
/// test "T::from_iter" {
///   let pairs = [(1, "one"), (2, "two")]
///   let map = @IndexMap.from_iter(pairs.iter())
///   inspect!(map.get(1), content="Some(\"one\")")
///   inspect!(map.get(2), content="Some(\"two\")")
/// }
/// ```
///
#deprecated("use `@IndexMap.from_iter` instead")
pub fn T::from_iter[K : Hash + Eq, V](iter : Iter[(K, V)]) -> T[K, V] {
  from_iter(iter)
}

///|
/// Iterates over all key-value pairs in the index map and applies the given
/// function to each pair in insertion order.
///
/// Parameters:
///
/// * `map` : The index map to iterate over.
/// * `action` : A function that takes a key and a value as arguments and
/// performs some action. The function should not return any value.
///
/// Example:
///
/// ```moonbit
/// test "each" {
///   let map = @IndexMap.of([(1, "one"), (2, "two")])
///   let mut result = ""
///   map.each(fn(k, v) { result = result + "\{k}:\{v}," })
///   inspect!(result, content="1:one,2:two,")
/// }
/// ```
pub fn each[K, V](self : T[K, V], f : (K, V) -> Unit) -> Unit {
  let mut current = self.core.head
  while current != -1 {
    let entry = self.core.entries[current]
    f(entry.key, entry.value)
    current = entry.next
  }
}

///|
/// Iterates over all key-value pairs in the map with their index, applying the
/// given function to each element. The index corresponds to the insertion order
/// of elements, starting from 0.
///
/// Parameters:
///
/// * `self` : The index map to iterate over.
/// * `callback` : A function that takes three arguments:
///  * An integer representing the index of the current key-value pair
///  * The key of the current entry
///  * The value of the current entry
///
/// Example:
///
/// ```moonbit
/// test "eachi" {
///   let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
///   let mut result = 0
///   map.eachi(fn(i, k, _) { if k == "b" { result = i } })
///   // "b" is at index 1
///   inspect!(result, content="1")
/// }
/// ```
pub fn eachi[K, V](self : T[K, V], f : (Int, K, V) -> Unit) -> Unit {
  let mut current = self.core.head
  let mut idx = 0
  while current != -1 {
    let entry = self.core.entries[current]
    f(idx, entry.key, entry.value)
    current = entry.next
    idx += 1
  }
}

///|
/// Provides string representation for index maps.
///
/// Parameters:
///
/// * `self` : The index map to be converted to string.
/// * `logger` : The buffer to write the string representation to.
///
/// Example:
///
/// ```moonbit
/// test "show" {
///   let map = @IndexMap.of([(1, "one"), (2, "two")])
///   inspect!(map, content=
///   #|IndexMap::of([(1, "one"), (2, "two")])
/// )
/// }
/// ```
pub impl[K : Show, V : Show] Show for T[K, V] with output(self, logger) {
  logger.write_string("IndexMap::of([")
  self.eachi(fn(i, k, v) {
    if i > 0 {
      logger.write_string(", ")
    }
    logger
    ..write_string("(")
    ..write_object(k)
    ..write_string(", ")
    ..write_object(v)
    .write_string(")")
  })
  logger.write_string("])")
}

///|
/// Returns the index of the given key in insertion order.
///
/// Parameters:
///
/// * `self` : The index map to search in.
/// * `key` : The key to look for.
///
/// Returns `Some(index)` if the key exists, where index is its position in insertion order,
/// or `None` if the key is not in the map.
///
/// Example:
///
/// ```moonbit
/// test "index_of" {
///   let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
///   inspect!(map.index_of("a"), content="Some(0)")
///   inspect!(map.index_of("b"), content="Some(1)")
///   inspect!(map.index_of("d"), content="None")
/// }
/// ```
pub fn index_of[K : Hash + Eq, V](self : T[K, V], key : K) -> Int? {
  // 先检查键是否存在
  match self.key_to_idx.get(key) {
    Some(bucket_idx) =>
      // 直接从桶索引到位置的映射获取位置索引 - O(1)
      self.core.idx_to_position.get(bucket_idx)
    None => None
  }
}

///|
/// Returns the first (oldest) key-value pair in the map.
///
/// Parameters:
/// 
/// * `self` : The index map to access.
///
/// Returns `Some((key, value))` for the first inserted entry,
/// or `None` if the map is empty.
///
/// Example:
///
/// ```moonbit
/// test "first" {
///   let map = @IndexMap.of([("a", 1), ("b", 2)])
///   inspect!(map.first(), content="Some((\"a\", 1))")
/// }
/// ```
pub fn first[K, V](self : T[K, V]) -> (K, V)? {
  if self.size == 0 || self.core.head == -1 {
    return None
  }
  let entry = self.core.entries[self.core.head]
  Some((entry.key, entry.value))
}

///|
/// Returns the last (newest) key-value pair in the map.
///
/// Parameters:
/// 
/// * `self` : The index map to access.
///
/// Returns `Some((key, value))` for the most recently inserted entry,
/// or `None` if the map is empty.
///
/// Example:
///
/// ```moonbit
/// test "last" {
///   let map = @IndexMap.of([("a", 1), ("b", 2)])
///   inspect!(map.last(), content="Some((\"b\", 2))")
/// }
/// ```
pub fn last[K, V](self : T[K, V]) -> (K, V)? {
  if self.size == 0 || self.core.tail == -1 {
    return None
  }
  let entry = self.core.entries[self.core.tail]
  Some((entry.key, entry.value))
}

///|
/// Returns an array of all keys in the map, preserving insertion order.
///
/// Parameters:
///
/// * `self` : The index map to get keys from.
///
/// Returns an array containing all keys in the map, in their insertion order.
///
/// Example:
///
/// ```moonbit
/// test "keys" {
///   let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
///   inspect!(map.keys(), content=["a", "b", "c"])
/// }
/// ```
pub fn keys[K, V](self : T[K, V]) -> Array[K] {
  if self.size == 0 {
    return []
  }
  let result = []
  let mut current = self.core.head
  while current != -1 {
    result.push(self.core.entries[current].key)
    current = self.core.entries[current].next
  }
  result
}

///|
/// Returns an array of all values in the map, preserving insertion order.
///
/// Parameters:
///
/// * `self` : The index map to get values from.
///
/// Returns an array containing all values in the map, in their keys' insertion order.
///
/// Example:
///
/// ```moonbit
/// test "values" {
///   let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
///   inspect!(map.values(), content=[1, 2, 3])
/// }
/// ```
pub fn values[K, V](self : T[K, V]) -> Array[V] {
  if self.size == 0 {
    return []
  }
  let result = []
  let mut current = self.core.head
  while current != -1 {
    result.push(self.core.entries[current].value)
    current = self.core.entries[current].next
  }
  result
}

///|
/// Converts the IndexMap to a JSON string preserving insertion order.
///
/// Parameters:
///
/// * `self` : The index map to be converted to a JSON string.
///
/// Returns a string in JSON format that preserves the insertion order of keys.
///
/// Example:
///
/// ```moonbit
/// test "to_json_string" {
///   let map = @IndexMap.of([(1, 10), (2, 20), (3, 30)])
///   inspect!(map.to_json_string(), content="{\"1\":10,\"2\":20,\"3\":30}")
/// }
/// ```
pub fn to_json_string[K : Show, V : ToJson](self : T[K, V]) -> String {
  // 直接构建JSON字符串
  let mut result = "{"
  let mut first = true
  let mut current = self.core.head
  while current != -1 {
    let entry = self.core.entries[current]
    if first == false {
      result = result + ","
    }
    first = false

    // 添加键（转换为字符串）
    result = result + "\"" + entry.key.to_string() + "\":"

    // 添加值（转换为JSON）
    result = result + entry.value.to_json().to_string()
    current = entry.next
  }
  result + "}"
}

///|
/// Standard ToJson implementation (may not preserve order)
pub impl[K : Show, V : ToJson] ToJson for T[K, V] with to_json(self) {
  // 使用普通Map
  let object = Map::new(capacity=self.size)

  // 按照插入顺序遍历元素
  let mut current = self.core.head
  while current != -1 {
    let entry = self.core.entries[current]
    object[entry.key.to_string()] = entry.value.to_json()
    current = entry.next
  }
  Object(object)
}

///|
/// Removes and returns the last (newest) inserted key-value pair from the map.
///
/// Parameters:
/// 
/// * `self` : The index map to modify.
///
/// Returns `Some((key, value))` for the last inserted entry that was removed,
/// or `None` if the map is empty.
///
/// Example:
///
/// ```moonbit
/// test "pop" {
///   let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
///   inspect!(map.pop(), content="Some((\"c\", 3))")
///   inspect!(map.size(), content="2")
///   inspect!(map.get("c"), content="None")
/// }
/// ```
pub fn pop[K : Hash + Eq, V](self : T[K, V]) -> (K, V)? {
  if self.size == 0 || self.core.tail == -1 {
    return None
  }

  // 获取尾部元素
  let tail_idx = self.core.tail
  let tail_entry = self.core.entries[tail_idx]
  let key = tail_entry.key
  let value = tail_entry.value

  // 更新链表指针，移除尾节点
  if tail_entry.prev != -1 {
    self.core.entries[tail_entry.prev].next = -1
    self.core.tail = tail_entry.prev
  } else {
    // 链表中只有一个元素时，清空链表
    self.core.head = -1
    self.core.tail = -1
  }

  // 从哈希表和键到索引的映射中移除
  self.core.hash_to_idx.remove(tail_entry.hash)
  self.key_to_idx.remove(key)

  // 从位置映射中移除最后一个位置
  ignore(self.core.position_to_idx.pop())

  // 从索引到位置的映射中移除被删除的元素
  self.core.idx_to_position.remove(tail_idx)

  // 更新大小
  self.size -= 1

  // 返回被移除的元素
  Some((key, value))
}

///|
/// Removes and returns the first (oldest) inserted key-value pair from the map.
///
/// Parameters:
/// 
/// * `self` : The index map to modify.
///
/// Returns `Some((key, value))` for the first inserted entry that was removed,
/// or `None` if the map is empty.
///
/// Example:
///
/// ```moonbit
/// test "shift" {
///   let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
///   inspect!(map.shift(), content="Some((\"a\", 1))")
///   inspect!(map.size(), content="2")
///   inspect!(map.get("a"), content="None")
/// }
/// ```
pub fn shift[K : Hash + Eq, V](self : T[K, V]) -> (K, V)? {
  if self.size == 0 || self.core.head == -1 {
    return None
  }

  // 获取头部元素
  let head_idx = self.core.head
  let head_entry = self.core.entries[head_idx]
  let key = head_entry.key
  let value = head_entry.value

  // 更新链表指针，移除头节点
  if head_entry.next != -1 {
    self.core.entries[head_entry.next].prev = -1
    self.core.head = head_entry.next
  } else {
    // 链表中只有一个元素时，清空链表
    self.core.head = -1
    self.core.tail = -1
  }

  // 从哈希表和键到索引的映射中移除
  self.core.hash_to_idx.remove(head_entry.hash)
  self.key_to_idx.remove(key)

  // 获取头部元素的位置（应该是0）
  let position = self.core.idx_to_position.get(head_idx).unwrap()

  // 使用交换策略：将最后一个元素移动到第一个位置
  if self.size > 1 {
    // 获取最后一个元素的索引
    let last_idx = self.core.position_to_idx[self.size - 1]

    // 将最后一个元素移动到第一个位置
    self.core.position_to_idx[position] = last_idx
    self.core.idx_to_position.set(last_idx, position)
  }

  // 从位置映射中移除最后一个位置
  ignore(self.core.position_to_idx.pop())

  // 从索引到位置的映射中移除被删除的元素
  self.core.idx_to_position.remove(head_idx)

  // 更新大小
  self.size -= 1

  // 返回被移除的元素
  Some((key, value))
}

///|
/// Returns the first (oldest) key-value pair in the map without removing it.
///
/// Parameters:
/// 
/// * `self` : The index map to access.
///
/// Returns `Some((key, value))` for the first inserted entry,
/// or `None` if the map is empty.
///
/// Example:
///
/// ```moonbit
/// test "get_first" {
///   let map = @IndexMap.of([("a", 1), ("b", 2)])
///   inspect!(map.get_first(), content="Some((\"a\", 1))")
///   inspect!(map.size(), content="2")  // 元素没有被移除
/// }
/// ```
pub fn get_first[K, V](self : T[K, V]) -> (K, V)? {
  if self.size == 0 || self.core.head == -1 {
    return None
  }
  let head_entry = self.core.entries[self.core.head]
  Some((head_entry.key, head_entry.value))
}

///|
/// Returns the last (newest) key-value pair in the map without removing it.
///
/// Parameters:
/// 
/// * `self` : The index map to access.
///
/// Returns `Some((key, value))` for the most recently inserted entry,
/// or `None` if the map is empty.
///
/// Example:
///
/// ```moonbit
/// test "get_last" {
///   let map = @IndexMap.of([("a", 1), ("b", 2)])
///   inspect!(map.get_last(), content="Some((\"b\", 2))")
///   inspect!(map.size(), content="2")  // 元素没有被移除
/// }
/// ```
pub fn get_last[K, V](self : T[K, V]) -> (K, V)? {
  if self.size == 0 || self.core.tail == -1 {
    return None
  }
  let tail_entry = self.core.entries[self.core.tail]
  Some((tail_entry.key, tail_entry.value))
}

///|
pub fn sort_by[K, V](self : T[K, V], compare : (K, V, K, V) -> Int) -> Unit {
  if self.size <= 1 {
    return // 不需要排序
  }

  // 1. 收集所有键值对
  let entries = []
  let mut current = self.core.head
  while current != -1 {
    let entry = self.core.entries[current]
    entries.push((current, entry.key, entry.value))
    current = entry.next
  }

  // 2. 按照比较函数排序
  entries.sort_by(fn(e1, e2) { compare(e1.1, e1.2, e2.1, e2.2) })

  // 3. 重建链表和位置映射
  self.core.position_to_idx = []
  self.core.idx_to_position = @hashmap.new()

  // 重建头尾指针
  self.core.head = entries[0].0
  self.core.tail = entries[entries.length() - 1].0

  // 设置第一个元素的前驱为-1
  self.core.entries[self.core.head].prev = -1

  // 更新链表指针和位置映射
  for i in 0..<entries.length() {
    let (idx, _, _) = entries[i]

    // 更新位置映射
    self.core.position_to_idx.push(idx)
    self.core.idx_to_position.set(idx, i)

    // 更新链表指针
    if i < entries.length() - 1 {
      // 不是最后一个元素，设置next指针
      let next_idx = entries[i + 1].0
      self.core.entries[idx].next = next_idx
      self.core.entries[next_idx].prev = idx
    } else {
      // 最后一个元素，next指针为-1
      self.core.entries[idx].next = -1
    }
  }
}

///|
pub fn sort_by_key[K, V](self : T[K, V], compare : (K, K) -> Int) -> Unit {
  self.sort_by(fn(k1, _, k2, _) { compare(k1, k2) })
}

///|
pub fn sort_by_value[K, V](self : T[K, V], compare : (V, V) -> Int) -> Unit {
  self.sort_by(fn(_, v1, _, v2) { compare(v1, v2) })
}

///|
pub fn sort[K : Compare, V](self : T[K, V]) -> Unit {
  self.sort_by_key(fn(k1, k2) {
    if k1 < k2 {
      -1
    } else if k1 > k2 {
      1
    } else {
      0
    }
  })
}

///|
pub fn reverse[K, V](self : T[K, V]) -> Unit {
  if self.size <= 1 {
    return // 不需要反转
  }

  // 收集所有桶索引
  let indices = []
  let mut current = self.core.head
  while current != -1 {
    indices.push(current)
    current = self.core.entries[current].next
  }

  // 反转链表指针
  self.core.position_to_idx = []
  let new_head = self.core.tail
  let new_tail = self.core.head

  // 交换头尾指针
  self.core.head = new_head
  self.core.tail = new_tail

  // 反转每个节点的前驱后继
  for idx in indices {
    let entry = self.core.entries[idx]
    self.core.entries[idx].next = entry.prev
    self.core.entries[idx].prev = entry.next
  }

  // 更新位置映射
  for i in 0..<indices.length() {
    let idx = indices[indices.length() - 1 - i]
    self.core.position_to_idx.push(idx)
    self.core.idx_to_position.set(idx, i)
  }
}

///|
pub fn sorted_by[K : Hash + Eq, V](
  self : T[K, V],
  compare : (K, V, K, V) -> Int
) -> T[K, V] {
  // 创建新映射
  let result = new(capacity=self.size)

  // 收集所有键值对
  let pairs = []
  let mut current = self.core.head
  while current != -1 {
    let entry = self.core.entries[current]
    pairs.push((entry.key, entry.value))
    current = entry.next
  }

  // 排序键值对
  pairs.sort_by(fn(a, b) { compare(a.0, a.1, b.0, b.1) })

  // 填充新映射
  for pair in pairs {
    result.set(pair.0, pair.1)
  }
  result
}

///|
pub fn sorted_by_key[K : Hash + Eq, V](
  self : T[K, V],
  compare : (K, K) -> Int
) -> T[K, V] {
  self.sorted_by(fn(k1, v1, k2, v2) { compare(k1, k2) })
}

///|
pub fn sorted_by_value[K : Hash + Eq, V](
  self : T[K, V],
  compare : (V, V) -> Int
) -> T[K, V] {
  self.sorted_by(fn(k1, v1, k2, v2) { compare(v1, v2) })
}

///|
pub fn sorted[K : Hash + Eq + Compare, V](self : T[K, V]) -> T[K, V] {
  self.sorted_by_key(fn(k1, k2) {
    if k1 < k2 {
      -1
    } else if k1 > k2 {
      1
    } else {
      0
    }
  })
}

///|
pub fn sorted_by_values[K : Hash + Eq, V : Compare](self : T[K, V]) -> T[K, V] {
  self.sorted_by_value(fn(v1, v2) {
    if v1 < v2 {
      -1
    } else if v1 > v2 {
      1
    } else {
      0
    }
  })
}

///|
pub fn reversed[K : Hash + Eq, V](self : T[K, V]) -> T[K, V] {
  // 创建新映射
  let result = new(capacity=self.size)

  // 收集所有键值对，按反向顺序
  let pairs = []
  let mut current = self.core.head
  while current != -1 {
    let entry = self.core.entries[current]
    pairs.push((entry.key, entry.value))
    current = entry.next
  }
  // 反向填充新映射
  let mut i = pairs.length() - 1
  while i >= 0 {
    let pair = pairs[i]
    result.set(pair.0, pair.1)
    i -= 1
  }
  result
}
