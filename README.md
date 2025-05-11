Here's the reformatted version of your IndexMap documentation following the specified format:


# IndexMap

[English](https://github.com/moonbit-community/IndexMap/blob/master/README.md) | [简体中文](https://github.com/moonbit-community/IndexMap/blob/master/README_zh_CN.md)

[![Build Status](https://img.shields.io/github/actions/workflow/status/moonbit-community/IndexMap/ci.yml)](https://github.com/moonbit-community/IndexMap/actions)  [![License](https://img.shields.io/github/license/moonbit-community/IndexMap)](LICENSE)  [![codecov](https://codecov.io/gh/moonbit-community/IndexMap/branch/master/graph/badge.svg)](https://codecov.io/gh/moonbit-community/IndexMap)  

Similar to Rust's `IndexMap`, this is an implementation of a data structure that is compatible with all operations in MoonBit's core `IndexMap` library.

## 🚀 Key Features

• 🗺️ IndexMap Creation – Supports creating `IndexMap` with various methods.  
• ➕ Set & Get – Easily add and retrieve key-value pairs.  
• ❌ Remove – Remove specific key-value pairs from the map.  
• 🔍 Contains – Check if a key exists in the map.  
• 📏 Size & Capacity – Get the number of elements or the current capacity of the map.  
• 🧹 Clear – Clear all elements from the `IndexMap`.  
• 🔄 Iteration – Iterate over the elements in insertion order.  
• 🧹 Pop & Shift – Remove and return the first or last element from the map.  
• 🔄 Sort – Sort the elements of the map.  
• 🔍 Get_at & Index_of – Get an element at a specific index or find the index of an element.

## 📥 Installation
```bash
moon add kesmeey/IndexMap
```

## 🚀 Usage Guide

### 🔨 Create
You can define an `IndexMap` using the `new()` or `from_array()` methods.

```moonbit
let m1 : @IndexMap.T[String, Int] = @IndexMap.new()
let m2 : @IndexMap.T[Int, Int] = @IndexMap.of([(1, 1), (2, 2), (3, 3)])
```

### ➕ Set & Get
You can use the `set()` method to add a key-value pair to the `IndexMap`, and `get()` to retrieve a value.

```moonbit
let map : @IndexMap.T[String, Int] = @IndexMap.new()
map.set("a", 1)
assert_eq!(map.get("a"), Some(1))
assert_eq!(map.get_or_default("a", 0), 1)
assert_eq!(map.get_or_default("b", 0), 0)
```

### ❌ Remove
You can remove a key-value pair from the `IndexMap` using the `remove()` method.

```moonbit
let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
map.remove("a") |> ignore
assert_eq!(map.to_array(), [("b", 2), ("c", 3)])
```

### 🔍 Contains
Use `contains()` to check if a key exists in the map.

```moonbit
let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
assert_eq!(map.contains("a"), true)
assert_eq!(map.contains("d"), false)
```

### 📏 Size & Capacity
You can use the `size()` method to get the current number of elements, or `capacity()` to get the container's capacity.

```moonbit
let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3), ("d", 4)])
assert_eq!(map.size(), 4)
assert_eq!(map.capacity(), 8)
```

You can also use the `is_empty()` method to check if the `IndexMap` is empty.

```moonbit
let map : @IndexMap.T[String, Int] = @IndexMap.new()
assert_eq!(map.is_empty(), true)
```

### 🧹 Clear
You can use `clear()` to empty all elements from the `IndexMap`.

```moonbit
let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
map.clear()
assert_eq!(map.is_empty(), true)
```

### 🔄 Iteration
You can iterate over the elements using `each()` or `eachi()`. The elements will be iterated in the order they were inserted.

```moonbit
let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
let arr = []
map.each(fn(k, v) { arr.push((k, v)) })
let arr2 = []
map.eachi(fn(i, k, v) { arr2.push((i, k, v)) })
```

Or use `iter()` to get a map iterator:

```moonbit
let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
let _iter = map.iter()
```

### 🧹 Pop & 🔄 Shift
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

To peek at elements without removing them, use `peek_last()` or `peek_first()`:

```moonbit
let m = @IndexMap.new()
m.set("a", 1)
m.set("b", 2)
assert_eq!(m.get_first().unwrap().0, "a")
assert_eq!(m.get_last().unwrap().0, "b")
```

### 🔄 Sort
The `IndexMap` can be sorted using the `sorted()` method, which returns a sorted array of elements while leaving the original container unchanged.

```moonbit
let map = @IndexMap.of([("c", 3), ("a", 1), ("b", 2)])
let sorted_map = map.sorted()
assert_eq!(sorted_map.keys(), ["a", "b", "c"])
assert_eq!(map.keys(), ["c", "a", "b"]) 
```

To sort elements in place, use the `sort()` method:

```moonbit
let map = @IndexMap.of([("c", 3), ("a", 1), ("b", 2)])
map.sort()
let keys = map.keys()
assert_eq!(keys, ["a", "b", "c"])
```

### 🔍 Get_at & Index_of
Use `get_at(x)` to retrieve the value of the x-th inserted element and `index_of(T)` to get the index of an element `T` in the `IndexMap`.

```moonbit
let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
assert_eq!(map.index_of("a"), Some(0))
assert_eq!(map.index_of("d"), None)
assert_eq!(map.get_at(0).unwrap().0, "a")
```

## 📜 License
This project is licensed under the Apache-2.0 License. See LICENSE for details.

## 📢 Contact & Support
• Moonbit Community: moonbit-community  
        • GitHub Issues: Report an Issue  

👋 If you like this project, give it a ⭐! Happy coding! 🚀

