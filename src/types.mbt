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
/// 桶结构，包含键值对信息和链表指针
priv struct Bucket[K, V] {
  hash : Int // 键的哈希值（缓存以避免重复计算）
  key : K // 键
  mut value : V // 值
  mut next : Int // 链表后继索引，-1表示没有后继
  mut prev : Int // 链表前驱索引，-1表示没有前驱
} derive(Show)

///|
/// IndexMap核心结构，包含所有数据组织功能
priv struct IndexMapCore[K, V] {
  mut hash_to_idx : @hashmap.T[Int, Int] // 哈希值到桶索引的映射
  mut entries : Array[Bucket[K, V]] // 数组：存储实际的键值对及其链表信息
  mut head : Int // 链表头节点索引，-1表示空链表
  mut tail : Int // 链表尾节点索引，-1表示空链表
  mut position_to_idx : Array[Int] // 位置到桶索引的映射，支持O(1)的索引访问
  mut idx_to_position : @hashmap.T[Int, Int] // 桶索引到位置的映射，使index_of操作为O(1)
} derive(Show)

/// A mutable indexed hash map.
///
/// reference:
/// - <https://programming.guide/robin-hood-hashing.html>
/// - <https://cs.uwaterloo.ca/research/tr/1986/CS-86-14.pdf>

///|
/// Mutable indexed hash map, not thread safe.
/// Maintains insertion order and allows access by index.
///
/// # Example
///
/// ```
/// let map = @indexmap.of([(3, "three"), (8, "eight"), (1, "one")])
/// assert_eq!(map.get(2), None)
/// assert_eq!(map.get(3), Some("three"))
/// map.set(3, "updated")
/// assert_eq!(map.get(3), Some("updated"))
/// assert_eq!(map.get_at(0), (3, "updated"))  // Access by insertion order
/// ```
struct T[K, V] {
  core : IndexMapCore[K, V] // 包含核心数据结构
  mut size : Int // 元素数量
  mut capacity : Int // 当前哈希表容量
  mut growAt : Int // 扩容阈值
  mut key_to_idx : @hashmap.T[K, Int] // 键到索引的直接映射，用于O(1)查找
}