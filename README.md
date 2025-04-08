# IndexMap

Similar to Rust's `IndexMap`, this is an implementation of a data structure that is compatible with all operations in MoonBit's core `IndexMap` library.

# Usage

## Create

You can create an empty map using `new()` or construct it using `from_array()`.

```moonbit
  let m1 : @IndexMap.T[String, Int] = @IndexMap.new()
  let m2 : @IndexMap.T[Int, Int] = @IndexMap.of([(1, 1), (2, 2), (3, 3)])
```

## Set & Get

Use `set()` to add a key-value pair and `get()` to retrieve a value.

```moonbit
  let map : @IndexMap.T[String, Int] = @IndexMap.new()
  map.set("a", 1)
  assert_eq!(map.get("a"), Some(1))
  assert_eq!(map.get_or_default("a", 0), 1)
  assert_eq!(map.get_or_default("b", 0), 0)
  map.remove("a")
  assert_eq!(map.contains("a"), false)
```

## Remove

Use `remove()` to delete a key-value pair.

```moonbit
  let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
  map.remove("a") |> ignore
  assert_eq!(map.to_array(), [("b", 2), ("c", 3)])
```

## Contains

Use `contains()` to check if a key exists.

```moonbit
    let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
    assert_eq!(map.contains("a"), true)
    assert_eq!(map.contains("d"), false)
```

## Size & Capacity

Use `size()` to get the number of key-value pairs and `capacity()` to get the current capacity.

```moonbit
  let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3), ("d", 4)])
  assert_eq!(map.size(), 4)
  assert_eq!(map.capacity(), 8)
```

Similarly, use `is_empty()` to check if the map is empty.

```moonbit
  let map : @IndexMap.T[String, Int] = @IndexMap.new()
  assert_eq!(map.is_empty(), true)
```

## Clear

Use `clear` to remove all key-value pairs (allocated memory remains unchanged).

```moonbit
  let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
  map.clear()
  assert_eq!(map.is_empty(), true)
```

## Iteration

Use `each()` or `eachi()` to iterate through all key-value pairs.

```moonbit
  let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
  let arr = []
  map.each(fn(k, v) { arr.push((k, v)) })
  let arr2 = []
  map.eachi(fn(i, k, v) { arr2.push((i, k, v)) })
```

Or use `iter()` to get a map iterator.

```moonbit
  let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
  let _iter = map.iter()
```

###  Pop &  Shift
Use `pop()` to remove and return the last inserted element, and `shift()` to remove and return the first element.

```moonbit
  let m : @IndexMap.T[String, Int] = @IndexMap.new()
  m.set("a", 1)
  m.set("b", 2)
  m.set("c", 3)
  assert_eq!(m.shift().unwrap().0, "a")
  assert_eq!(m.shift().unwrap().0, "b")
  m.set("d", 4)
  m.set("e", 5)
  assert_eq!(m.pop().unwrap().0, "e")
  assert_eq!(m.pop().unwrap().0, "d")
```

To peek at elements without removing them, use `peek_last()` or `peek_first()` to get the last or first element.

```moonbit
  let m = @IndexMap.new()
  m.set("a", 1)
  m.set("b", 2)
  assert_eq!(m.get_first().unwrap().0, "a")
  assert_eq!(m.get_last().unwrap().0, "b")
```

###  Sort
The `IndexMap` can be sorted using the `sorted()` method, which returns a sorted array of elements while leaving the original container unchanged.

```moonbit
  let map = @IndexMap.of([("c", 3), ("a", 1), ("b", 2)])
  let sorted_map = map.sorted()
  assert_eq!(sorted_map.keys(), ["a", "b", "c"])
  assert_eq!(map.keys(), ["c", "a", "b"]) 
```

To sort elements in place, use the `sort()` method.

```moonbit
  let map = @IndexMap.of([("c", 3), ("a", 1), ("b", 2)])
  map.sort()
  let keys = map.keys()
  assert_eq!(keys, ["a", "b", "c"])
```

###  Get_at & Index_of
Use `get_at(x)` to retrieve the value of the x-th inserted element and `index_of(T)` to get the index of an element `T` in the `IndexMap`.

```moonbit
  let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
  assert_eq!(map.index_of("a"), Some(0))
  assert_eq!(map.index_of("d"), None)
  assert_eq!(map.get_at(0).unwrap().0, "a")
```