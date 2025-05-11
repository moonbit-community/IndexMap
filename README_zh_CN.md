# IndexMap

[English](https://github.com/moonbit-community/IndexMap/blob/master/README.md) | [简体中文](https://github.com/moonbit-community/IndexMap/blob/master/README_zh_CN.md)

[![构建状态](https://img.shields.io/github/actions/workflow/status/moonbit-community/IndexMap/ci.yml)](https://github.com/moonbit-community/IndexMap/actions)  [![许可证](https://img.shields.io/github/license/moonbit-community/IndexMap)](LICENSE)  [![代码覆盖率](https://codecov.io/gh/moonbit-community/IndexMap/branch/master/graph/badge.svg)](https://codecov.io/gh/moonbit-community/IndexMap)  

类似于Rust的`IndexMap`，这是一个与MoonBit核心`IndexMap`库所有操作兼容的数据结构实现。

## 🚀 核心特性

• 🗺️ 创建IndexMap - 支持多种方式创建`IndexMap`  
• ➕ 设置与获取 - 轻松添加和检索键值对  
• ❌ 删除 - 从映射中移除特定键值对  
• 🔍 包含检查 - 检查键是否存在于映射中  
• 📏 大小与容量 - 获取元素数量或当前映射容量  
• 🧹 清空 - 清除`IndexMap`中的所有元素  
• 🔄 迭代 - 按插入顺序遍历元素  
• 🧹 弹出与移位 - 移除并返回第一个或最后一个元素  
• 🔄 排序 - 对映射元素进行排序  
• 🔍 获取位置与索引 - 获取特定索引处的元素或查找元素的索引

## 📥 安装
```bash
moon add kesmeey/IndexMap
```

## 🚀 使用指南

### 🔨 创建
可以使用`new()`或`from_array()`方法定义`IndexMap`。

```moonbit
let m1 : @IndexMap.T[String, Int] = @IndexMap.new()
let m2 : @IndexMap.T[Int, Int] = @IndexMap.of([(1, 1), (2, 2), (3, 3)])
```

### ➕ 设置与获取
使用`set()`方法添加键值对，`get()`方法检索值。

```moonbit
let map : @IndexMap.T[String, Int] = @IndexMap.new()
map.set("a", 1)
assert_eq!(map.get("a"), Some(1))
assert_eq!(map.get_or_default("a", 0), 1)
assert_eq!(map.get_or_default("b", 0), 0)
```

### ❌ 删除
使用`remove()`方法从`IndexMap`中移除键值对。

```moonbit
let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
map.remove("a") |> ignore
assert_eq!(map.to_array(), [("b", 2), ("c", 3)])
```

### 🔍 包含检查
使用`contains()`检查键是否存在于映射中。

```moonbit
let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
assert_eq!(map.contains("a"), true)
assert_eq!(map.contains("d"), false)
```

### 📏 大小与容量
使用`size()`获取当前元素数量，`capacity()`获取容器容量。

```moonbit
let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3), ("d", 4)])
assert_eq!(map.size(), 4)
assert_eq!(map.capacity(), 8)
```

使用`is_empty()`检查`IndexMap`是否为空。

```moonbit
let map : @IndexMap.T[String, Int] = @IndexMap.new()
assert_eq!(map.is_empty(), true)
```

### 🧹 清空
使用`clear()`清空`IndexMap`中的所有元素。

```moonbit
let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
map.clear()
assert_eq!(map.is_empty(), true)
```

### 🔄 迭代
使用`each()`或`eachi()`按插入顺序迭代元素。

```moonbit
let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
let arr = []
map.each(fn(k, v) { arr.push((k, v)) })
let arr2 = []
map.eachi(fn(i, k, v) { arr2.push((i, k, v)) })
```

或使用`iter()`获取映射迭代器：

```moonbit
let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
let _iter = map.iter()
```

### 🧹 弹出与移位
使用`pop()`移除并返回最后插入的元素，`shift()`移除并返回第一个元素。

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

使用`peek_last()`或`peek_first()`查看但不移除元素：

```moonbit
let m = @IndexMap.new()
m.set("a", 1)
m.set("b", 2)
assert_eq!(m.get_first().unwrap().0, "a")
assert_eq!(m.get_last().unwrap().0, "b")
```

### 🔄 排序
使用`sorted()`方法返回排序后的元素数组，原容器保持不变。

```moonbit
let map = @IndexMap.of([("c", 3), ("a", 1), ("b", 2)])
let sorted_map = map.sorted()
assert_eq!(sorted_map.keys(), ["a", "b", "c"])
assert_eq!(map.keys(), ["c", "a", "b"]) 
```

使用`sort()`方法原地排序元素：

```moonbit
let map = @IndexMap.of([("c", 3), ("a", 1), ("b", 2)])
map.sort()
let keys = map.keys()
assert_eq!(keys, ["a", "b", "c"])
```

### 🔍 获取位置与索引
使用`get_at(x)`获取第x个插入元素的值，`index_of(T)`获取元素`T`在`IndexMap`中的索引。

```moonbit
let map = @IndexMap.of([("a", 1), ("b", 2), ("c", 3)])
assert_eq!(map.index_of("a"), Some(0))
assert_eq!(map.index_of("d"), None)
assert_eq!(map.get_at(0).unwrap().0, "a")
```

## 📜 许可证
本项目采用Apache-2.0许可证。详见LICENSE文件。

## 📢 联系与支持
• Moonbit社区: moonbit-community  
• GitHub问题: 提交问题  

👋 如果喜欢这个项目，请给它一颗⭐！祝编程愉快！🚀