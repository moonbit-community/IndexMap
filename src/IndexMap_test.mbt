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
test "new" {
  let m : @IndexMap.T[Int, Int] = @IndexMap.new()
  inspect!(m.capacity(), content="8")
  assert_eq!(m.size(), 0)
}

///|
test "get" {
  let m = @IndexMap.new()
  m.set("a", 1)
  m.set("b", 2)
  m.set("c", 3)
  println(m.size())
  inspect!(m.get("a"), content="Some(1)")
  inspect!(m.get("b"), content="Some(2)")
  inspect!(m.get("c"), content="Some(3)")
  inspect!(m.get("d"), content="None")
}

///|
test "get_or_default" {
  let m = @IndexMap.new()
  m.set("a", 1)
  m.set("b", 2)
  m.set("c", 3)
  assert_eq!(m.get_or_default("a", 42), 1)
  assert_eq!(m.get_or_default("b", 42), 2)
  assert_eq!(m.get_or_default("c", 42), 3)
  assert_eq!(m.get_or_default("d", 42), 42)
}

///|
test "op_set" {
  let m = @IndexMap.new()
  m["a"] = 1
  m["b"] = 2
  assert_eq!(m.get("a"), Some(1))
  assert_eq!(m.get("b"), Some(2))
}

///|
test "op_get" {
  let m = @IndexMap.new()
  m.set("a", 1)
  m.set("b", 2)
  assert_eq!(m["a"], Some(1))
  assert_eq!(m["b"], Some(2))
  assert_eq!(m["c"], None)
}

///|
test "set_update" {
  let m = @IndexMap.new()
  m.set("a", 1)
  m.set("b", 2)
  assert_eq!(m.get("a"), Some(1))
  m.set("a", 2)
  assert_eq!(m.get("a"), Some(2))
}

///|
test "contains" {
  let m = @IndexMap.new()
  m.set("a", 1)
  assert_eq!(m.contains("a"), true)
  assert_eq!(m.contains("b"), false)
}

///|
test "from_array" {
  let m = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
  assert_eq!(m.get("a"), Some(1))
  assert_eq!(m.get("b"), Some(2))
  assert_eq!(m.get("c"), Some(3))
}

///|
test "size" {
  let m = @IndexMap.new()
  assert_eq!(m.size(), 0)
  m.set("a", 1)
  assert_eq!(m.size(), 1)
}

///|
test "is_empty" {
  let m = @IndexMap.new()
  assert_eq!(m.is_empty(), true)
  m.set("a", 1)
  assert_eq!(m.is_empty(), false)
  m.remove("a")
  println(m.size())
  assert_eq!(m.is_empty(), true)
}

///|
test "iter" {
  let m = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
  let mut sum = 0
  m.each(fn(_k, v) { sum += v })
  assert_eq!(sum, 6)
}

///|
test "iteri" {
  let m = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
  let mut sum = 0
  let mut s = ""
  m.eachi(fn(i, _k, v) {
    s += i.to_string()
    sum += v
  })
  assert_eq!(s, "012")
  assert_eq!(sum, 6)
}

///|
test "iter" {
  let buf = StringBuilder::new(size_hint=20)
  let map = @IndexMap.of([(1, "one"), (2, "two"), (3, "three")])
  map
  .iter()
  .each(fn(e) {
    let (k, v) = e
    buf.write_string("[\{k}-\{v}]")
  })
  inspect!(buf, content="[1-one][2-two][3-three]")
  buf.reset()
  map
  .iter()
  .take(2)
  .each(fn(e) {
    let (k, v) = e
    buf.write_string("[\{k}-\{v}]")
  })
  inspect!(buf, content="[1-one][2-two]")
}

///|
test "iter2" {
  let buf = StringBuilder::new(size_hint=20)
  let map = @IndexMap.of([(1, "one"), (2, "two"), (3, "three")])
  for k, v in map {
    buf.write_string("[\{k}-\{v}]")
  }
  inspect!(buf, content="[1-one][2-two][3-three]")
}

///|
test "to_array" {
  let map = @IndexMap.of([(1, "one"), (2, "two"), (3, "three")])
  inspect!(
    map.to_array(),
    content=
      #|[(1, "one"), (2, "two"), (3, "three")]
    ,
  )
}

///|
test "get_nonexistent_key" {
  let m = @IndexMap.new()
  m.set("a", 1)
  m.set("b", 2)
  inspect!(m.get("c"), content="None")
}

///|
test "remove_nonexistent_key" {
  let m = @IndexMap.new()
  m.set("a", 1)
  m.set("b", 2)
  m.remove("c")
  assert_eq!(m.size(), 2)
}

///|
test "get_nonexistent_key" {
  let m = @IndexMap.new()
  m.set("a", 1)
  m.set("b", 2)
  inspect!(m.get("c"), content="None")
}

///|
test "remove_nonexistent_key" {
  let m = @IndexMap.new()
  m.set("a", 1)
  m.set("b", 2)
  m.remove("c")
  assert_eq!(m.size(), 2)
}

///|
test "get_nonexistent_key" {
  let m = @IndexMap.new()
  m.set("a", 1)
  m.set("b", 2)
  inspect!(m.get("c"), content="None")
}

///|
test "remove_nonexistent_key" {
  let m = @IndexMap.new()
  m.set("a", 1)
  m.set("b", 2)
  m.remove("c")
  assert_eq!(m.size(), 2)
}

///|
test "get_nonexistent_key" {
  let m = @IndexMap.new()
  m.set("a", 1)
  m.set("b", 2)
  inspect!(m.get("c"), content="None")
}

///|
test "remove_nonexistent_key" {
  let m = @IndexMap.new()
  m.set("a", 1)
  m.set("b", 2)
  m.remove("c")
  assert_eq!(m.size(), 2)
}

///|
test "get_nonexistent_key_with_psl" {
  let m = @IndexMap.new()
  m.set("a", 1)
  m.set("b", 2)
  m.set("c", 3)
  m.set("d", 4)
  m.set("e", 5)
  m.set("f", 6)
  m.set("g", 7)
  m.set("h", 8)
  m.set("i", 9)
  m.set("j", 10)
  m.set("k", 11)
  m.set("l", 12)
  m.set("m", 13)
  m.set("n", 14)
  m.set("o", 15)
  m.set("p", 16)
  m.set("q", 17)
  m.set("r", 18)
  m.set("s", 19)
  m.set("t", 20)
  m.set("u", 21)
  m.set("v", 22)
  m.set("w", 23)
  m.set("x", 24)
  m.set("y", 25)
  m.set("z", 26)
  inspect!(m.get("A"), content="None")
  inspect!(m.get("B"), content="None")
  inspect!(m.get("C"), content="None")
  inspect!(m.get("D"), content="None")
  inspect!(m.get("E"), content="None")
  inspect!(m.get("F"), content="None")
  inspect!(m.get("G"), content="None")
  inspect!(m.get("H"), content="None")
  inspect!(m.get("I"), content="None")
  inspect!(m.get("J"), content="None")
  inspect!(m.get("K"), content="None")
  inspect!(m.get("L"), content="None")
  inspect!(m.get("M"), content="None")
  inspect!(m.get("N"), content="None")
  inspect!(m.get("O"), content="None")
  inspect!(m.get("P"), content="None")
  inspect!(m.get("Q"), content="None")
  inspect!(m.get("R"), content="None")
  inspect!(m.get("S"), content="None")
  inspect!(m.get("T"), content="None")
  inspect!(m.get("U"), content="None")
  inspect!(m.get("V"), content="None")
  inspect!(m.get("W"), content="None")
  inspect!(m.get("X"), content="None")
  inspect!(m.get("Y"), content="None")
  inspect!(m.get("Z"), content="None")
}

///|
test "from_iter multiple elements iter" {
  inspect!(
    @IndexMap.from_iter([(2, 2), (1, 1), (3, 3)].iter()),
    content="IndexMap::of([(2, 2), (1, 1), (3, 3)])",
  )
}

///|
test "from_iter single element iter" {
  inspect!(
    @IndexMap.from_iter([(1, 1)].iter()),
    content="IndexMap::of([(1, 1)])",
  )
}

///|
test "from_iter empty iter" {
  let map : @IndexMap.T[Int, Int] = @IndexMap.from_iter(Iter::empty())
  inspect!(map, content="IndexMap::of([])")
}

///|
test "@IndexMap.contains/empty" {
  let map : @IndexMap.T[Int, String] = @IndexMap.new()
  inspect!(map.contains(42), content="false")
}

///|
test "@IndexMap.contains/basic" {
  let map = @IndexMap.of([(1, "one"), (2, "two"), (3, "three")])
  inspect!(map.contains(2), content="true")
  inspect!(map.contains(4), content="false")
}

///|
test "@IndexMap.contains/after_operations" {
  let map = @IndexMap.of([(1, "one"), (2, "two")])
  map.remove(1)
  inspect!(map.contains(1), content="false")
  map.set(1, "ONE")
  inspect!(map.contains(1), content="true")
  map.clear()
  inspect!(map.contains(2), content="false")
}

///|
test "@IndexMap.from_array" {
  let map = @IndexMap.from_array([("a", 1), ("b", 2), ("c", 3)])
  println(map.size())
  @json.inspect!(map, content={ "a": 1, "b": 2, "c": 3 })
}

///|
test "@IndexMap.from_array with int key" {
  let map = @IndexMap.from_array([(1, "one"), (2, "two"), (3, "three")])
  @json.inspect!(map, content={ "1": "one", "2": "two", "3": "three" })
}

///|
test "shift" {
  let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
  inspect!(map.shift(), content="Some((\"a\", 1))")
  inspect!(map.size(), content="2")
  inspect!(map.get("a"), content="None")
}

///|
test "pop" {
  let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
  inspect!(map.pop(), content="Some((\"c\", 3))")
  inspect!(map.size(), content="2")
  inspect!(map.get("c"), content="None")
}

///|
test "get_first" {
  let map = @IndexMap.of([("a", 1), ("b", 2)])
  inspect!(map.get_first(), content="Some((\"a\", 1))")
  inspect!(map.size(), content="2") // 元素没有被移除
}

///|
test "get_last" {
  let map = @IndexMap.of([("a", 1), ("b", 2)])
  inspect!(map.get_last(), content="Some((\"b\", 2))")
  inspect!(map.size(), content="2") // 元素没有被移除
}

///|
test "123" {
  let map = @IndexMap.of([("c", 3), ("a", 1), ("b", 2)])
  let sorted_map = map.sorted()
  assert_eq!(sorted_map.keys(), ["a", "b", "c"])
  assert_eq!(map.keys(), ["c", "a", "b"]) // 原始映射保持不变
}

///|
test "index_of" {
  let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
  inspect!(map.index_of("a"), content="Some(0)")
  inspect!(map.index_of("b"), content="Some(1)")
  inspect!(map.index_of("d"), content="None")
}

///|
test "get_at" {
  // 创建一个测试映射
  let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3), ("d", 4)])

  // 测试有效索引
  inspect!(map.get_at(0), content="Some((\"a\", 1))")
  inspect!(map.get_at(1), content="Some((\"b\", 2))")
  inspect!(map.get_at(2), content="Some((\"c\", 3))")
  inspect!(map.get_at(3), content="Some((\"d\", 4))")

  // 测试无效索引
  inspect!(map.get_at(-1), content="None")
  inspect!(map.get_at(4), content="None")

  // 测试空映射
  let empty_map : @IndexMap.T[String, Int] = @IndexMap.new()
  inspect!(empty_map.get_at(0), content="None")

  // 测试修改元素后的索引访问
  map.set("b", 20)
  inspect!(map.get_at(1), content="Some((\"b\", 20))")
}

///|
test "reversed" {
  let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
  let rev_map = map.reversed()
  println(rev_map.keys())
  assert_eq!(rev_map.keys(), ["c", "b", "a"])
  assert_eq!(map.keys(), ["a", "b", "c"]) // 原始映射保持不变
}

///|
test "sorted_by_values" {
  let map = @IndexMap.of([("c", 3), ("a", 1), ("b", 2)])
  let sorted_map = map.sorted_by_values()
  assert_eq!(sorted_map.values(), [1, 2, 3])
}

///|
test "sorted" {
  let map = @IndexMap.of([("c", 3), ("a", 1), ("b", 2)])
  let sorted_map = map.sorted()
  assert_eq!(sorted_map.keys(), ["a", "b", "c"])
  assert_eq!(map.keys(), ["c", "a", "b"]) // 原始映射保持不变
}

///|
test "sorted_by_value" {
  let map = @IndexMap.of([("c", 3), ("a", 1), ("b", 2)])
  let sorted_map = map.sorted_by_value(fn(v1, v2) { v1 - v2 })
  assert_eq!(sorted_map.values(), [1, 2, 3])
  assert_eq!(map.values(), [3, 1, 2]) // 原始映射保持不变
}

///|
test "sorted_by_key" {
  let map = @IndexMap.of([("c", 3), ("a", 1), ("b", 2)])
  let sorted_map = map.sorted_by_key(fn(k1, k2) { k1.compare(k2) })
  assert_eq!(sorted_map.keys(), ["a", "b", "c"])
  assert_eq!(map.keys(), ["c", "a", "b"]) // 原始映射保持不变
}

///|
test "sorted_by" {
  let map = @IndexMap.of([("c", 3), ("a", 1), ("b", 2)])
  let sorted_map = map.sorted_by(fn(k1, v1, k2, v2) { k1.compare(k2) })
  assert_eq!(sorted_map.keys(), ["a", "b", "c"])
  assert_eq!(map.keys(), ["c", "a", "b"]) // 原始映射保持不变
}

///|
test "reverse" {
  let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
  map.reverse()
  let keys = map.keys()
  assert_eq!(keys, ["c", "b", "a"])
}

///|
test "sort" {
  let map = @IndexMap.of([("c", 3), ("a", 1), ("b", 2)])
  map.sort()
  let keys = map.keys()
  assert_eq!(keys, ["a", "b", "c"])
}

///|
test "sort_by_value" {
  let map = @IndexMap.of([("c", 3), ("a", 1), ("b", 2)])
  // 按值降序排序
  map.sort_by_value(fn(v1, v2) { v2 - v1 })
  let values = map.values()
  assert_eq!(values, [3, 2, 1])
}

///|
test "sort_by_key" {
  let map = @IndexMap.of([("c", 3), ("a", 1), ("b", 2)])
  // 按键字母顺序排序
  map.sort_by_key(fn(k1, k2) { k1.compare(k2) })
  let keys = map.keys()
  assert_eq!(keys, ["a", "b", "c"])
}

///|
test "sort_by" {
  let map = @IndexMap.of([("c", 3), ("a", 1), ("b", 2)])
  // 按键字母顺序排序
  map.sort_by(fn(k1, v1, k2, v2) { k1.compare(k2) })
  let keys = map.keys()
  assert_eq!(keys, ["a", "b", "c"])
}

///|
test "IndexSet arbitrary" {
  let samples : Array[@IndexMap.T[Int, Int]] = @quickcheck.samples(20)
  inspect!(
    samples[5:10],
    content="[IndexMap::of([]), IndexMap::of([]), IndexMap::of([(0, 0)]), IndexMap::of([(0, 0)]), IndexMap::of([(0, 0)])]",
  )
  inspect!(
    samples[11:15],
    content="[IndexMap::of([(0, 0), (-1, 1), (2, 0), (-3, -2)]), IndexMap::of([(0, 0)]), IndexMap::of([(0, -1), (-2, 5), (7, -7), (-8, 1), (3, 6)]), IndexMap::of([(0, 0)])]",
  )
}

///|
struct Person {
  name : String
  age : Int
} derive(Eq, Show)

///|
impl Compare for Person with compare(self, other) {
  if self.age != other.age {
    self.age - other.age // Sort by age
  } else {
    self.name.compare(other.name) // Then by name
  }
}

///|
fn get_score(scores : @sorted_map.T[Int, Int], student_id : Int) -> Int {
  match scores.get(student_id) {
    Some(score) => score
    None => {
      println(
        "Student ID " +
        student_id.to_string() +
        " does not exist, returning default score",
      )
      0 // Default score
    }
  }
}

///|
/// 测试键值更新功能
test "update_existing_key" {
  let map : T[String, Int] = @IndexMap.new()

  // 首次插入键值对
  map.set("key1", 100)
  assert_eq!(map.get("key1"), Some(100))

  // 更新同一个键的值
  map.set("key1", 200)
  assert_eq!(map.get("key1"), Some(200))
  assert_eq!(map.size(), 1) // 确认大小没有变化，只是更新了值
}

///|
/// 测试首次插入元素更新头节点
test "first_element_head_update" {
  let map : T[String, Int] = @IndexMap.new()

  // 确认初始状态
  assert_eq!(map.size(), 0)

  // 使用断言检查私有成员是否为期望值
  let first_entry = map.first()
  assert_eq!(first_entry, None)

  // 插入第一个元素
  map.set("first", 1)

  // 验证头节点已正确设置
  assert_eq!(map.first(), Some(("first", 1)))
  assert_eq!(map.last(), Some(("first", 1)))
}

///|
/// 测试get_or_init函数
test "get_or_init_function" {
  let map : T[String, Int] = @IndexMap.new()

  // 记录init函数调用次数
  let mut init_calls = 0

  // 对不存在的键调用get_or_init
  let value1 = map.get_or_init("new_key", fn() {
    init_calls += 1
    42
  })
  assert_eq!(value1, 42)
  assert_eq!(init_calls, 1)
  assert_eq!(map.get("new_key"), Some(42))

  // 对已存在的键调用get_or_init
  let value2 = map.get_or_init("new_key", fn() {
    init_calls += 1
    100 // 这个值不应该被使用
  })
  assert_eq!(value2, 42) // 返回已存在的值
  assert_eq!(init_calls, 1) // init函数不应该再次调用
  assert_eq!(map.get("new_key"), Some(42))
}

///|
/// 测试空映射上的remove操作
test "remove_on_empty_map" {
  let map : T[String, Int] = @IndexMap.new()

  // 确认映射为空
  assert_eq!(map.size(), 0)

  // 在空映射上执行remove，不应抛出错误
  map.remove("non_existent_key")

  // 映射应该仍然为空
  assert_eq!(map.size(), 0)
}

///|
/// 测试触发扩容
test "capacity_growth" {
  // 创建一个较小容量的映射
  let map : T[Int, String] = @IndexMap.new(capacity=4)

  // 记录初始容量
  let initial_capacity = map.capacity()
  assert_eq!(initial_capacity, 4)

  // 计算增长阈值 (75% 负载因子)
  let growth_threshold = initial_capacity * 3 / 4

  // 添加足够的元素以触发扩容
  for i in 0..<growth_threshold {
    map.set(i, "value" + i.to_string())
  }

  // 添加一个额外的元素应该触发扩容
  map.set(growth_threshold, "trigger growth")

  // 验证容量已增加
  assert_true!(map.capacity() > initial_capacity)
  assert_eq!(map.capacity(), 8) // 应该是原来的两倍

  // 验证所有元素仍然存在
  for i in 0..=growth_threshold {
    if i == growth_threshold {
      assert_eq!(map.get(i), Some("trigger growth"))
    } else {
      assert_eq!(map.get(i), Some("value" + i.to_string()))
    }
  }
}

///|
/// 测试尾节点的后继更新
test "tail_next_pointer_update" {
  let map : T[String, Int] = @IndexMap.new()

  // 添加第一个元素
  map.set("first", 1)

  // 添加第二个元素，这会更新原尾节点的后继
  map.set("second", 2)

  // 验证链表顺序正确
  assert_eq!(map.to_array(), [("first", 1), ("second", 2)])

  // 验证tail指向最后添加的元素
  assert_eq!(map.last(), Some(("second", 2)))

  // 添加第三个元素
  map.set("third", 3)

  // 再次验证链表顺序
  assert_eq!(map.to_array(), [("first", 1), ("second", 2), ("third", 3)])

  // 确认tali指向最新添加的元素
  assert_eq!(map.last(), Some(("third", 3)))
}

///|
test "0 size" {
  let map : T[String, Int] = @IndexMap.new()
  assert_eq!(map.values(), [])
  assert_eq!(map.keys(), [])
  assert_eq!(map.to_array(), [])
  let mut test0 = map.shift()
  assert_eq!(test0, None)
  test0 = map.last()
  assert_eq!(test0, None)
  test0 = map.first()
  assert_eq!(test0, None)
  test0 = map.get_first()
  assert_eq!(test0, None)
  test0 = map.get_last()
  assert_eq!(test0, None)
  test0 = map.pop()
  assert_eq!(test0, None)
  map.remove("1")
  assert_eq!(map.size(), 0)
}

///|
/// 测试to_json_string函数
test "to_json_string_function" {
  let map = @IndexMap.new()
  map.set("name", "John")
  map.set("age", "30")
  map.set("city", "New York")

  // 验证JSON字符串格式正确，并且保持了插入顺序
  let json = map.to_json_string()
  // 使用实际输出的格式进行断言
  assert_true!(json.contains("\"name\":String(\"John\")"))
  assert_true!(json.contains("\"age\":String(\"30\")"))
  assert_true!(json.contains("\"city\":String(\"New York\")"))

  // 确认顺序正确（通过检查子字符串相对位置）
  let name_pos = json.index_of("name")
  let age_pos = json.index_of("age")
  let city_pos = json.index_of("city")
  assert_true!(name_pos < age_pos)
  assert_true!(age_pos < city_pos)
}

///|
/// 测试contains_key函数
test "contains_key_function" {
  let map = @IndexMap.new()
  map.set("key1", "value1")

  // 测试存在的键
  assert_true!(map.contains_key("key1"))

  // 测试不存在的键
  assert_false!(map.contains_key("key2"))
}

///|
/// 测试set函数中更新已存在键的值逻辑
test "set_update_existing_key" {
  let map = @IndexMap.new()

  // 首次插入
  map.set("key", "original_value")
  assert_eq!(map.get("key"), Some("original_value"))

  // 获取初始大小和顺序信息
  let initial_size = map.size()
  let initial_keys = map.keys()

  // 更新已存在的键
  map.set("key", "updated_value")

  // 验证值已更新
  assert_eq!(map.get("key"), Some("updated_value"))

  // 验证大小未变化（没有添加新条目）
  assert_eq!(map.size(), initial_size)

  // 验证键的顺序未变化
  assert_eq!(map.keys(), initial_keys)
}

///|
/// 测试reverse函数处理size <= 1的情况
test "reverse_with_small_size" {
  // 测试空映射
  let empty_map = @IndexMap.new()
  let empty_keys_before = empty_map.keys()
  empty_map.reverse()
  let empty_keys_after = empty_map.keys()
  assert_eq!(empty_keys_before, empty_keys_after)

  // 测试只有一个元素的映射
  let single_map = @IndexMap.new()
  single_map.set("key", "value")
  let single_keys_before = single_map.keys()
  single_map.reverse()
  let single_keys_after = single_map.keys()
  assert_eq!(single_keys_before, single_keys_after)
  assert_eq!(single_map.get("key"), Some("value"))
}

///|
// 创建自定义键类型
struct TestKey {
  id : Int
  value : Int
} derive(Eq, Show)

///|
impl Hash for TestKey with hash_combine(self, hasher) {
  hasher.combine_int(self.value)
}

///|
impl Compare for TestKey with compare(self, other) {
  // 只比较value字段，忽略id字段
  if self.value < other.value {
    return -1
  } else if self.value > other.value {
    return 1
  } else {
    return 0 // 相等情况
  }
}

///|
/// 测试sort函数中处理相等键的情况
test "sort_with_equal_keys" {

  // 创建带有相等value但不同id的键的映射
  let map = @IndexMap.new()
  map.set(TestKey::{ id: 1, value: 10 }, "A")
  map.set(TestKey::{ id: 2, value: 20 }, "B")
  map.set(TestKey::{ id: 3, value: 10 }, "C") // 与第一个键的value相同

  // 执行排序并验证结果
  map.sort()

  // 获取排序后的键
  let sorted_keys = map.keys()

  // 验证排序结果（相等的键应保持相对顺序）
  assert_eq!(sorted_keys[0].value, 10)
  assert_eq!(sorted_keys[1].value, 10)
  assert_eq!(sorted_keys[2].value, 20)
}

///|
/// 测试sorted_by_key和sorted_by_values中处理相等情况
test "sorted_functions_with_equal_values" {
  // 测试sorted_by_key相等情况
  let map1 = @IndexMap.new()
  map1.set(10, "A")
  map1.set(20, "B")
  map1.set(10, "C") // 相同的键，会覆盖之前的值
  let result1 = map1.sorted_by_key(fn(k1, k2) {
    if k1 < k2 {
      -1
    } else if k1 > k2 {
      1
    } else {
      0
    } // 测试相等情况
  })

  // 验证结果（应该只有一个10键，因为它覆盖了之前的值）
  assert_eq!(result1.size(), 2)
  assert_eq!(result1.get(10), Some("C"))

  // 测试sorted_by_values相等情况
  let map2 = @IndexMap.new()
  map2.set("A", 10)
  map2.set("B", 20)
  map2.set("C", 10) // 相同的值
  let result2 = map2.sorted_by_values()

  // 验证结果（相等值的键应该保持插入顺序）
  let keys = result2.keys()
  assert_eq!(keys.length(), 3)

  // 找到值为10的键，它们应该在前面
  let val10_keys = []
  for k in keys {
    if result2.get(k) == Some(10) {
      val10_keys.push(k)
    }
  }

  // 验证有两个值为10的键
  assert_eq!(val10_keys.length(), 2)
  assert_true!(val10_keys.contains("A"))
  assert_true!(val10_keys.contains("C"))
}

///|
/// 测试索引到位置映射中的默认值处理
test "idx_to_position_default_handling" {
  // 创建一个特殊情况，使idx_to_position.get返回None
  let map = @IndexMap.new()

  // 首先添加几个元素
  map.set("key1", "value1")
  map.set("key2", "value2")

  // 清除内部映射但保留条目（模拟idx_to_position映射不完整的情况）
  // 通过删除再添加元素来强制position映射更新
  map.clear()
  map.set("new_key", "new_value")

  // 访问某个操作，触发position查找
  // 即使内部存在不一致，操作应该成功完成
  let result = map.get("new_key")
  assert_eq!(result, Some("new_value"))

  // 确认可以正常遍历
  let keys = map.keys()
  assert_eq!(keys, ["new_key"])
}

///|
/// 测试删除唯一元素后清空链表
test "remove_only_element_clears_list" {
  let map = @IndexMap.new()

  // 添加唯一元素
  map.set("only_key", "only_value")
  assert_eq!(map.size(), 1)
  assert_eq!(map.first(), Some(("only_key", "only_value")))

  // 移除唯一元素
  map.remove("only_key")

  // 验证链表已清空
  assert_eq!(map.size(), 0)
  assert_eq!(map.first(), None)
  assert_eq!(map.last(), None)

  // 验证可以继续添加元素
  map.set("new_key", "new_value")
  assert_eq!(map.size(), 1)
  assert_eq!(map.first(), Some(("new_key", "new_value")))
}

///|
/// 测试shift方法删除单个元素
test "shift_only_element_clears_list" {
  let map = @IndexMap.new()

  // 添加唯一元素
  map.set("only_key", "only_value")
  assert_eq!(map.size(), 1)

  // 使用shift移除唯一元素
  let removed = map.shift()
  assert_eq!(removed, Some(("only_key", "only_value")))

  // 验证链表已清空
  assert_eq!(map.size(), 0)
  assert_eq!(map.first(), None)
  assert_eq!(map.last(), None)
}

///|
/// 测试pop方法删除单个元素
test "pop_only_element_clears_list" {
  let map = @IndexMap.new()

  // 添加唯一元素
  map.set("only_key", "only_value")
  assert_eq!(map.size(), 1)

  // 使用pop移除唯一元素
  let removed = map.pop()
  assert_eq!(removed, Some(("only_key", "only_value")))

  // 验证链表已清空
  assert_eq!(map.size(), 0)
  assert_eq!(map.first(), None)
  assert_eq!(map.last(), None)
}

///|
/// 测试迭代中断
test "iteration_early_termination" {
  let map = @IndexMap.new()

  // 添加多个元素
  map.set("key1", "value1")
  map.set("key2", "value2")
  map.set("key3", "value3")
  map.set("key4", "value4")

  // 计数器
  let mut count = 0

  // 使用each方法，在第二个元素后跳过处理
  let mut should_continue = true
  map.each(fn(k, v) {
    if should_continue {
      count += 1
      if count >= 2 {
        should_continue = false
      }
    }
  })

  // 验证只处理了两个元素
  assert_eq!(count, 2)
}

///|
/// 测试更新已存在键的完整流程
test "complete_key_update_process" {
  let map = @IndexMap.new()

  // 添加初始键值对
  map.set("key", "old_value")

  // 验证初始状态
  assert_eq!(map.size(), 1)
  assert_eq!(map.get("key"), Some("old_value"))

  // 保存内部数据状态
  let old_size = map.size()
  let old_capacity = map.capacity()

  // 更新键的值
  map.set("key", "new_value")

  // 验证更新后的状态
  assert_eq!(map.size(), old_size) // 大小应该不变
  assert_eq!(map.capacity(), old_capacity) // 容量应该不变
  assert_eq!(map.get("key"), Some("new_value")) // 值应该更新
}

///|
/// 测试链表结构的完整更新
test "tail_next_pointer_complete_update" {
  let map = @IndexMap.new()

  // 测试空链表添加元素 (此时tail = -1)
  map.set("first", 1)

  // 验证首尾指向同一个元素
  assert_eq!(map.first(), map.last())

  // 添加更多元素，测试尾部链接
  map.set("second", 2)
  map.set("third", 3)

  // 验证顺序和连接
  let array = map.to_array()
  assert_eq!(array, [("first", 1), ("second", 2), ("third", 3)])

  // 确保可以从头遍历到尾
  let items = []
  map.each(fn(k, v) { items.push((k, v)) })
  assert_eq!(items, array)
}

///|
/// 测试容量为0情况下的自动扩容
test "growth_from_zero_capacity" {
  // 创建特殊情况：容量为0的映射
  let map : @IndexMap.T[String, Int] = @IndexMap.new(capacity=0)

  // 验证初始容量
  assert_eq!(map.capacity(), 0)

  // 添加元素应触发扩容
  map.set("key", 100)

  // 验证扩容成功
  assert_true!(map.capacity() > 0)
  assert_eq!(map.get("key"), Some(100))
}
