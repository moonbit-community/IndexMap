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
