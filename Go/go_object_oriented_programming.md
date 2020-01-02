# Go面向对象编程
## 几个关键概念
**Go语言的面向对象之所以与C++，Java以及(较小程度上的)python这些语言如此不同，是因为它不支持继承。Go语言只支持聚合（也叫作组合）和嵌入**。为了弄明白聚合与嵌入的不同，让我们看一小段代码：
```
type ColorPoint struct {
    color.Color               //匿名字段（嵌入）
    x,y      int                    //具名字段（聚合）
}
```
这里color.Color是来自image/color包的类型，x和y则是整型。在Go语言的术语中，color.Color 、x和y都是结构体的字段，color.Color 字段是匿名的（因为它没有变量名），因此事嵌入字段。x和y是具名的聚合字段。如果我们定义`point := ColorPoint{}`，其字段可以通过point.Color、point.x和point.y来访问。


## 自定义类型
## 接口
## 结构体

## Reference
- [An Introduction to Programming in Go](http://www.golang-book.com/books/intro)