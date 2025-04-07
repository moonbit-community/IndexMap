// Copyright 2025 International Digital Economy Academy
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
///|
const Default_init_capacity = 8

///|
fn calc_grow_threshold(capacity : Int) -> Int {
  capacity * 3 / 4 // 75% 负载因子
}

///|
fn power_2_above(x : Int, n : Int) -> Int {
  for i = x {
    if i >= n {
      break i
    }
    let next = i << 1
    if next < 0 {
      // overflow happened
      break i
    }
    continue next
  }
}

///|
test "power_2_above" {
  inspect!(power_2_above(1, 15), content="16")
  inspect!(power_2_above(1, 16), content="16")
  inspect!(power_2_above(1, 17), content="32")
  inspect!(power_2_above(1, 32), content="32")
  inspect!(power_2_above(128, 33), content="128")
  inspect!(power_2_above(1, 2147483647), content="1073741824")
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
  // 检查是否需要扩容
  if self.capacity == 0 || self.size >= self.growAt {
    self.grow()
  }

  // 计算哈希值
  let hash = key.hash()

  // 检查键是否已存在
  match self.key_to_idx.get(key) {
    Some(idx) => {
      // 键已存在，更新值
      self.core.entries[idx].value = value
      return
    }
    None => ignore(None)
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
}

///|
///|
/// Sets a key-value pair with a pre-computed hash
fn set_with_hash[K : Hash + Eq, V](
  self : T[K, V],
  key : K,
  value : V,
  hash : Int
) -> Unit {
  // 检查是否需要扩容
  if self.capacity == 0 || self.size >= self.growAt {
    self.grow()
  }

  // 检查键是否已存在
  match self.key_to_idx.get(key) {
    Some(idx) => {
      // 键已存在，更新值
      self.core.entries[idx].value = value
      return
    }
    None => ignore(None)
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

  // 直接从映射中获取索引，O(1)操作
  match self.key_to_idx.get(key) {
    Some(idx) => {
      // 获取被删除元素的链表信息
      let entry = self.core.entries[idx]
      let hash = entry.hash

      // 找到元素在position_to_idx中的位置
      let mut position = -1
      for i in 0..<self.size {
        if self.core.position_to_idx[i] == idx {
          position = i
          break
        }
      }
      if position == -1 {
        // 应该不会发生，防御性编程
        return
      }

      // 从哈希表中移除
      self.core.hash_to_idx.remove(hash)

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

      // 从映射中移除被删除的键
      self.key_to_idx.remove(key)

      // 更新位置到索引的映射
      // 移除当前位置的元素并将后面的元素前移
      for i in position..<(self.size - 1) {
        self.core.position_to_idx[i] = self.core.position_to_idx[i + 1]
      }
      let temp = self.core.position_to_idx.pop()

      // 更新大小
      self.size -= 1
    }
    None => ignore(None) // 键不存在，不执行任何操作
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
  m.clear()
  assert_eq!(m.size(), 0)
  assert_eq!(m.capacity(), 8)
  //for i in 0..<m.capacity() {
  //  @test.same_object!(m.entries[i], None)
  // }
}

///|
test "grow" {
  let m : T[MyString, Int] = new()
  m.set("C", 1)
  m.set("Go", 2)
  m.set("C++", 3)
  m.set("Java", 4)
  m.set("Scala", 5)
  m.set("Julia", 5)
  assert_eq!(m.size(), 6)
  inspect!(m.capacity(), content="16")
  m.set("Cobol", 5)
  assert_eq!(m.size(), 7)
  inspect!(m.capacity(), content="16")
  m.set("Python", 6)
  m.set("Haskell", 7)
  m.set("Rescript", 8)
  assert_eq!(m.size(), 10)
  inspect!(m.capacity(), content="32")
  //inspect!(
  //  m.debug_entries(),
  //  content="_,(0,C,1),(0,Go,2),(0,C++,3),(0,Java,4),(0,Scala,5),(1,Julia,5),(2,Cobol,5),(2,Python,6),(2,Haskell,7),(2,Rescript,8),_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_,_",
  // )
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
  self.capacity = self.capacity * 2
  self.growAt = calc_grow_threshold(self.capacity)
  self.core.hash_to_idx = @hashmap.new()
  self.core.entries = []
  self.core.head = -1
  self.core.tail = -1
  self.core.position_to_idx = []
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
