# Go面向对象编程
## 1. 几个关键概念
**Go语言的面向对象之所以与C++，Java以及(较小程度上的)python这些语言如此不同，是因为它不支持继承。Go语言只支持聚合（也叫作组合）和嵌入**。为了弄明白聚合与嵌入的不同，让我们看一小段代码：
```
type ColorPoint struct {
    color.Color               //匿名字段（嵌入）
    x,y      int                    //具名字段（聚合）
}
```
这里color.Color是来自image/color包的类型，x和y则是整型。在Go语言的术语中，color.Color 、x和y都是结构体的字段，color.Color 字段是匿名的（因为它没有变量名），因此事嵌入字段。x和y是具名的聚合字段。如果我们定义`point := ColorPoint{}`，其字段可以通过point.Color、point.x和point.y来访问。

术语“类”（class），“对象”（object）以及“实例”（instance）在传统的多层次继承式面向对象编程中已经定义得非常清晰，但在Go语言中我们完全避开使用它们。相反，我们使用“类型”和“值”，其中自定义类型的值可以包含方法。

由于没有继承，因此也就没有虚函数。Go语言对此的支持则是采用类型安全的鸭子类型（duck type）。在Go语言中，参数可以被声明为一个具体类型（例如，int、string、或者*os.File以及MyType），也可以是借口（interface），即提供了具有满足该接口的方法的值。对于一个生命为借口的值，我们可以传入任意值，只要该值包含给借口所声明的方法。这点非常灵活而强大，特别是当它与Go语言所支持的访问嵌入字段的方法相结合时。

继承的一个优点是，有些方法只需在基类中实现一次，即可在子类中方便地使用。Go语言为此提供了两种解决方案。其中一种解决方案是使用切入，如果我们嵌入了一个类型，方法只需在所嵌入的类型中实现一次，即可在所有包含该嵌入类型的类型中使用。另一种解决方案是，为每一种类型提供独立的方法，但是只是简单地将包装（通常只有一行）了功能性作用的代码放进一个函数中，然后让所有类的方法都调用这个函数。

Go语言面向对象编程中另一个与众不同点是它的接口、值和方法都相互保持独立。接口用于声明方法签名，结构体用于声明聚合或者嵌入的值，而方法用于声明在自定义类型（通常为结构体）上的操作。在一个自定义类型的方法和任何特殊接口之间没有任何显式的联系。但是如果该类型的方法满足一个或多个接口，那么该类型的值可以用于任何该接口的值的地方。当然，每一个类型都满足空接口（interface{}），因此任何值都可以用于声明了空接口的地方。 

一种按Go语言的方式思考的方法是，把 is-a 关系看成由接口来定义，也就是方法的签名。而 has-a 关系可以使用聚合或者嵌入特定类型值的结构体来表达，这些定义构成自定义类型。

虽然没法为内置类型添加方法，但可以很容易地基于内置类型创建自定义类型，然后为其添加呢任何我们想要的方法。给类型的值可以调用我们提供的方法，同时也可以与它们底层类型提供的任何函数，方法以及操作符 一起使用。例如，假如我们有个类型声明type Integer int，我们可以不拘形式地使用整数的+操作符将这两种类型的值相加。并且，一旦我们有了一个自定义类型，我们也可以添加自定义的方法。例如，func  (i Integer) Double(i Integer {return i * 2}。

基于内置类型的自定义类型不但容易创建，运行时效率也非常高。将基于内置类型的自定义类型与该内置类型相互转换无需耗费运行时代价，因为这种转换能够在编译时完成。鉴于此，要使用自定义的方法时将内置类型“升级”成自定义类型，或者要将一个类型传入一个只接受内置类型参数的函数时将自定义类型“降级”成为内置类型，都是非常实用的做法。
## 2. 自定义类型
自定义类型使用Go语言的如下语法创建：
```
type typeName typeSpecification
```
typeName可以是一个包或者函数内唯一的任何合法的Go标识符。typeSpecification可以是任意内置的类型（如string， int，切片，映射或者通道）、一个接口、一个结构体或者一个函数签名。下面是一些没有方法的自定义类型例子：
```
type Count int
type StringMap map[string]string
type FloatChan chan float64
type FuncForRuneFunc func(rune) rune
```
在有些情况创建一个自定义类型就够了，但有些情况下我们需要给自定义类型添加一些方法来让它更实用。
### 2.1 添加方法
方法是作用在自定义类型的值上的一类特殊函数，通常自定义类型的值会被传递给该函数。该值可以以指针或者值的形式传递，这取决于方法如何定义。定义方法的语法几乎等同于定义函数，除了需要在func关键字和方法之间必须写上接收者（写入括号中）之外，该接收者即可以以该方法所属于的类型的形式出现，也可以以一个变量名及类型的形式出现。当调用方法的时候，其接收者变量被自动设为该方法调用所对应的值或指针。

我们可以为任何自定义类型添加一个或多个方法。一个方法的接收者总是一个该类型的值，或者该类型的指针。然而，对于任何一个给定的类型，每个方法名必须唯一。唯一名字要求的结果是，我们不能同时定义两个相同名字的方法，让其中一个的接收者为指针类型而另一个为值类型。另一结果是，不支持重载方法。也就是说，不能定义名字相同但是不同签名的方法。
```
type Count int
func (count *Count) Increment() {*count++ }
func (count *Count) Decrement() {*count-- }
func (count Count) IsZero() bool {return count == 0}
```
让我们再稍微多看一个更详细的自定义类型，这回是基于一个结构体定义：
```
type Part struct {
    Id    int                  //具名字段（聚合）
    Name string      //具名字段（聚合）
}

func (part *Part) LowerCase() {
    part.Name = strings.ToLower(part.Name)
}

func (part *Part) UpperCase() {
    part.Name = strings.ToUpper(part.Name)
}

func (part Part) String()  string {
    return fmt.Sprintf("<<%s %q>>", part.Id, part.Name)
}

func (part Part) HasPrefix(prefix string) bool {
    return strings.HasPrefix(part.Name, prefix)
}
```
为了演示它是如何工作的，我们创建了接收者为值类型的String()和HasPrefix()方法。当然，传值的话无法修改原始数据，而传递指针的话可以：
```
part := Part{5, "wrench"}
part.UpperCase()
part.Id += 11
fmt.Println(part, partHasPrefix("w"))
```
当创建的自定义类型是基于结构体时，我们可以使用其名字及一对大括号包围的初始值来创建该类型的值。

**类型的方法集是指可以被该类型的值所调用所有方法的集合**。

**一个指向自定义类型的值的指针，它的方法集由为该类型定义的所有方法组成，无论这些方法接收的是一个值还是一个指针**。如果在指针上调用一个接收值的方法，Go语言会聪明地将该指针解引用，并将指针所指的底层值作为方法的接收者。

**一个自定义类型值的方法集则由为该类型定义的接收者类型为值类型的方法组成，但是不包括那些接收这类型为指针的方法**。但这种限制通常并不像这里所说的那样，因为如果我们只有一个值，仍然可以调用一个接收者为指针类型的方法，这可以借助于Go语言传值的地址的能力实现，前提是该值是可寻址的（即它是一个变量，一个解引用指针，一个数组或切片项，或者结构体中的一个可寻址字段）。因此，加入我们这样调用value.Method()，其中Method()需要一个指针接收者，而value是一个可寻址的值，Go语言会把这个调用等同于(&value).Method()。

*Count类型的方法集包含3个方法：Increment()、Decrement()和IsZero()。然而Count类型的方法集则只哟一个方法：IsZero()。所有这些方法都可以在*Count上调用。同时，正如我们在前面的代码片段上看到的，只要Count值是可寻址的，这些函数也可以在*Count值上调用。

将方法的接收者定义为值类型对于小数据类型来说是可行的，如数值类型。这些方法不能修改它们所调用的值，因为只能得到接收者的一个副本。如果我们的数据类型的值很大，或者需要修改值，则需要让方法接受一个指针类型的接收者，这样可以使得方法调用的开销尽可能的小。
#### 2.1.1 重写方法
Go语言可以创建包含一个或者多个类型作为嵌入字段的自定义结构体--这种方法非常方便的一点是，在任何嵌入类型中的方法都可以当作该自定义结构体自身的方法被调用，并且可以将其嵌套类型作为其接收者。
```
type Item struct {
    id               string        //具名字段（聚合）
    price         float64     //具名字段（聚合）
    quantity  int             //具名字段（聚合）
}

func (item *Item) Cost() float64 {
    return item.price * float64(item.quantity)
}

type SpecialItem struct {
    Item                        //匿名字段（嵌入）
    catalogId    int    //具名字段（聚合）
}
```
> **注意**：这里SpeicialItem嵌入了一个Item类型，这意味着我们可以在一个SpecialItem上调用Item的Cost()方法。
```
special := SpecialItem{Item{"Green", 3, 5,}, 207}
fmt.Println(special.id, special.price, special.quantity, special.catalogId)
fmt.Println(special.Cost())
```
**当调用special.Cost()的时候，SpecialItem类型没有它自身的Cost()方法，Go语言使用Item.Cost()方法。同时，传入其嵌入的Item值，而非整个调用该方法的SpecialItem值**。

同时也可以在自定义结构体中创建与所嵌入的字段中的方法同名的方法，来覆盖被嵌入字段中的方法。例如，假设我们有一个新的Item类型：
```
type Luxurytem struct {
    Item                        //匿名字段（嵌入）
    markup    flaot64    //具名字段（聚合）
}
```
如上所述，如果我们在LururyItem上调用Cost()方法，就会使用嵌入的Item.Cost()方法，就像SpecialItem中一样。下面提供了3种不同的覆盖嵌入方法的实现：
```
func (item *LuxuryItem) Cost() float64 {                   //没必要这么冗长
    return item.Item.price * float64(item.Item.quantity) * item.markUp
}

func (item *LuxuryItem) Cost() float64 {                  //没必要的重复
    return item.price * float64(item.Item.quantity) * item.markUp
}

func (item *LuxuryItem) Cost() float64 {                //完美
    return item.Item.Cost() * item.markUp
}
```
#### 2.1.2 方法表达式
方法表达式是一个必须将方法类型作为为第一个参数的函数（在其它语言中常常使用术语“未绑定方法（unbound method）来表示类似的概念”）。
```
asStringV := Part.String          //有效签名：  func(Part) string
sv  := asStringV(part)
hasPrefix := Part.HasPrefix     //有效签名：  func(Part, string) bool
asStringP := (*Part).String        //有效签名：  func(*Part) string
sp := asStringP(&part)
lower := (*Part).LowerCase        //有效签名：  func(*Part)
lower(&part)
fmt.Println(sv, sp, hasPrefix(part, "w"), part)
```
这里我们创建了4个方法表达式：asStringV()接收一个Part值作为其唯一的参数；hasPrefix（）接收一个Part的值作为其第一个参数以及一个字符串作为其第二个参数；asStringP()和lower()都接受一个*Part作为其第一个参数。

方法表达式是一种高级特性，在关键时刻非常有用。
### 2.2 验证类型
对于非零值构造函数不能满足条件的情况下，我们可以创建一个构造函数。Go语言不支持构造函数，因此我们必须显示地调用构造函数。为了支持这些，我们必须假设该类型有一个非法的零值，同时提供一个或者多个构造函数用于构建合法的值。

当碰到其字段必须被验证时，我们也可以使用类似的方法。我们可以将这些字段设为非导出的，同事使用导出的访问函数来做一些必要的验证。
```
type Place struct {
    latitude, longtitude float64
    Name                             string
}

func New(latitude, longtitude float64, name string) *Place {
    return &Place{saneAngle(0, latitude), saneAngle(0, longtitude), name}
}

func (place *Place) Latitude() float64 {return place.latitude}
func (place *Place) SetLatitude(latitude float64) {
    place.latitude = saneAngle(place.latitude, latitude)
}

func (place *Place) Longtitude() float64 {return place.longtitude}
func (place *Place) SetLongtitude(longtitude float64) {
    place.longtitude = saneAngle(place.longtitude, longtitude)
}

func (place *Place String() string {
    return fmt.Sprintf("(%.3f, %.3f) %q", place.latitude, place.longtitude, place.Name)
}

func (original *Place) Copy() *Place {
    return &Place{original.latitude, original.longtitude, original.Name}
}
```
类型Place是导出（在place包中）的，但是它的latitude和longtitude字段是非导出的，因为它们需要验证。我们创建了一个构造函数New()来保证总是能够创建一个合法的*place.Place。Go语言的惯例是调用New()构造函数，如果定义了多个构造函数，则调用以New开头的那些。同时通过提供未导出字段的getter和setter函数，我们可以保证只为其设置合法的值。
```
newYork := place.New(40.716667, -74, "New York")
fmt.Println(newWork)
```
## 3. 接口
在Go语言中，接口是一个自定义类型，它声明了一个或多个方法签名。接口是完全抽象地，因此不能将其实例化。然而，可以创建一个类型为接口的变量，它可以被赋值为任何满足该接口类型的实际类型的值。

interface{}类型是声明了空方法集的接口类。无论包含不包含方法，任何一个值都满足interface{}类型。毕竟，如果一个值有方法，那么其方法集包含空的方法集以及它实际包含的方法。这也是interface{}类型可以用于任意值的原因。我们不能直接在一个以interface{}类型值传入的参数上调用方法（虽然该值可能有一些方法），因为该值满足的接口没有方法。因此，通常而言，最好以实际类型的形式传入值，或者传入一个包含我们想要的方法的接口。
```
type Exchanger interface {
    Exchange()
}
```
Exchanger接口声明了一个方法Exchange()，它不接受输入值也不返回输出。根据Go语言的惯例，**定义接口时接口名字需以er结尾**。定义只包含一个方法的接口是非常普遍的。需注意的是，接口实际上声明的是一个API（Applicatiion Programing Interface，程序编程接口），即0个或多个方法，虽然并不明确规定这些方法所需的功能。
```
type StringPair struct {
    first, second string
}

func (pair *StringPair) Exchange() {
    pair.first, pair.second = pair.second, pair.first
}

type Point [2]int
func (point *Point) Exchange() {
    point[0], point[1] = point[1], point[0]
}
```
自定义的类型StringPair和Point完全不同，但是由于它们都提供了Exchange()方法，因此两个都能满足Exchanger接口。这意味着我们可以创建StringPair和Point值，并将它们传递给接受Exchanger的函数。
```
jeky11 := StringPair{"Henry", "Jeky11"}
point := Point{5, -3}
jeky11.Exchange()         //当做 (&jeky11).Exchange()
point.Exchange()           //当做 (&point).Exchange()
exchangeThese(&jeky11, &point)

func exchangeThese(exchangers...Exchanger) {
    for _, exchanger := range exchangers {
        exchanger.Exchange()
    }
}
```
上面所创建的都是值，然而Exchange()方法需要的是一个指针类型接收者。我们之前也注意到，这并不是什么问题，因为我们调用一个需要指针参数的方法而实际传入的只是可寻址的值时，Go语言会智能地将该值的地址传给方法。因此，在上面的代码片段中，jeky11.Exchange() 会自动地被当做 (&jeky11).Exchange()使用，其他的方法调用情况也类似。
### 3.1 接口嵌入
Go语言的接口对嵌入的支持非常好，接口可以嵌入其它接口，其效果与接口中直接添加被嵌入接口的方法一样。
```
type LowerCaser interface {
    LowerCase()
}

type UpperCaser interface {
    UpperCase()
}

type LowerUpperCaser interface {
    LowerCaser                   // 就像在这里写了LowerCase()一样
    UpperCaser                   // 就像在这里写了UpperCase()一样
}

type FixCaser interface {
    FixCase()
}

type ChangeCaser interface {
    LowerUpperCaser
    FixCaser
}

func (part *Part) FixCase() {
    part.Name = fixCase(part.Name)
}

func (pair *StringPair) FixCase() {
    pair.first = fixCase(pair.first)
    pair.second = fixCase(pair.second)
}

toaskRack := Part{8427, "TOAST RACK"}
lobilia := StringPair{"LOBILIA", "Secahloweu"}
```
如果我们有一对这样的值而想在它们之上调用方法呢？下面的做法不太好：
```
for _, x := range []interface{}{&toaskRack, &lobilia} {                 //不安全
    x.(LowerUpperCaser).UpperCase()                                               //未检查的类型断言
}
```
这里是使用的方法有两点缺陷。**相对较小的一个缺陷是该未经检查的类型断言是作用于LowerUpperCaser接口的，它比我们实际需要的接口更泛化**。更糟糕的一种做法是 使用更泛化的ChangeCaser接口。但是我们不能使用FixCaser接口，因为它只提供了FixCase()方法。**我们应该采用刚好能满足条件的特定接口**，这个例子中就是UpperCaser接口。**该方法最主要的缺陷是使用了一个未经检查的类型断言没可能导致抛出异常**。

```
for _, x := range []interface{}{&toaskRack, &lobilia} {
    if x, ok := x(LowerCaser); ok {         //影子变量
        x.LowerCase() 
    } 
}
```
上面的代码片段使用了一种更安全的方式且使用了最合适的特定接口来完成工作。但这相当笨拙。**这里的问题是，我们使用的是一个通用的interface{}值的切片，而非一个具体类型的值或者满足某个特殊类型接口的切片**。当然，如果所给的都是[]interface{}，那么这种做法使我们所能做到的最好的。

```
for _, x := range []FixCaser{&toaskRack, &lobilia} {
    x.FixCase()
}
```
上面代码所示的方式是最好的，**我们将切片声明为符合我们需求的FixCaser而不是原始的]interface{}接口做类型检查，从而把类型检查工作交给编译器**。
## 4. 结构体
匿名结构体有时可以使得代码紧凑而高效：
```
points := []struct{x, y int} {{4, 5}, {}, {-7, 11}, {15, 17}, {11, 8}}
for _, point := range points {
    fmt.Printf("{%d, %d}", point.x, point.y)
}
```
上面的代码片段中的points变量是一个struct{x, y int}结构体的切片。虽然该结构体本身是匿名的，我们仍然可以通过具名字段来访问其数据，这比前面所使用的数组索引更为简便和安全。
### 4.1 结构体的聚合与嵌入
我们可以像嵌入接口或者其它类型的方式那样来嵌入结构体，也就是通过将一个结构体名字的名字以匿名字段的方式放入另一个结构体中来实现。通常一个嵌入式字段的字段可以通过使用.（点）操作符来访问，而无需提及其类型名。但是如果外部结构体有一个字段的名字与嵌入式结构体中某个字段名字相同，那么为了避免歧义，我们使用时必须带上嵌入结构体的名字。

结构体中的没一个字段的名字都必须是唯一的。
#### 4.1.1 嵌入值
```
type Person struct {
    Title                  string      //具名字段（聚合）
    Forenames    []string   //具名字段（聚合）
    Surname         string    //具名字段（聚合）
}

type Author1 struct {
    Names      Person        //具名字段（聚合）
    Title          []string        //具名字段（聚合）
    YearBorn int                //具名字段（聚合）
}

type Author2 struct {
    Person                            //匿名字段（嵌入）
    Title          []string        //具名字段（聚合）
    YearBorn int                //具名字段（聚合）
}
```
使用区别：可以看到，由于Person中的Title字段与Author2中的Title字段有冲突，为了消除歧义，必须加上Person类型名来消除歧义。
```
author1  := Author1{Person{"Mr", []string{"Robert", "Louis", "Balfour"}, "Stevenson}, []string{"Kidnapped", "Treasure Island"}, 1850}
author1.Names.Title = ""
author1.Names.Forenames = []string{"Oscar", "Fingal", "Wills"}
author1.Names.Surname = "Wilde"
author1.Title = []string{"The picture of Dorian Gray"}
author1.YearBorn += 4

author2  := Author2{Person{"Mr", []string{"Robert", "Louis", "Balfour"}, "Stevenson}, []string{"Kidnapped", "Treasure Island"}, 1850}
author2.Title = []string{"The picture of Dorian Gray"}
author2.Person.Title = ""                                              //必须使用类型名以消除歧义
author2.Forenames = []string{"Oscar", "Fingal", "Wills"}
author2.Surname = "Wilde"
author2.YearBorn += 4
```
#### 4.1.2 嵌入带方法的匿名值
如果一个嵌入字段带方法，那我们就可以在外部结构体中直接调用它，并且只有嵌入的字段（而不是整个外部结构体）会作为接收者传递给这些方法。
```
type Tasks struct {
    slice       []string                     //具名字段（聚合）
    Count                                       //匿名字段（嵌入）
}

func (tasks *Tasks) Add(task string) {
    tasks.slice = append(tasks.slice, task)
    tasks.Increment()                // 就像写tasks.Count.Increment()一样
}

func (tasks *Tasks) Tally() int {
    return int(tasks.Count)
}
```
需重点注意的是，当调用嵌入字段的某个方法时，传递该方法的只是嵌入字段自身。因此，当我们调用Tasks。IsZero()，Tasks.Increment()，或者任何其它在某个Tasks值上调用的Count方法时，这些方法接收到的是一个Count（或者*Count值），而非Tasks值。
#### 4.1.3 嵌入接口
结构体除了可以聚合和嵌入具体的类型外，也可以聚合和嵌入接口。自然地，繁殖在接口中聚合或者嵌入结构体是行不通的，因为接口是完全抽象的概念，所以这样的聚合与嵌入毫无意义。当一个结构体包含聚合（具名的）或者嵌入（匿名的）接口类型的字段时，这意味着该结构体可以将任意满足该接口规格的值存储在该字段中。
```
type Optioner interface {
    Name() string
    IsValid() bool
}

type OptionCommon struct {
    ShortName   string  "short option name"        // 功能等同于注释，但支持通过Go语言的反射访问
    LongName     string "long option name"          // 功能等同于注释，但支持通过Go语言的反射访问
}
```
Optioner接口声明了所有选项类型都必须提供的通用方法。OptionCommon结构体定义了每一个选项常用到的字段。Go语言允许我们用字符串（用Go语言的术语来说是标签）对结构体的字段进行注释。这些标签并没有什么功能性的作用，但与注释不同的是，它们可以通过Go语言的反射来支持访问。有些程序员使用标签来声明字段验证，例如，对字符串使用像“check:len(2, 30)”这样的标签，或者对数字使用check:range(0, 500)”这样的标签，或者使用程序员自定义的任何语义。
```
type IntOption struct {
    OptionCommon             // 匿名字段（嵌入）
    Value, Min, Max int        // 具名字段（聚合）
}

func (option IntOption) Name() string {
    return name(option.ShortName, option.LongName)
}

func (option IntOption) IsValid() bool {
    return option.Min <= option.Value && option.Value <= option,Max
}

func name(shortName, longName string) string {              // 辅助函数
    if longName == "" {
        return shortName
    }
    return longName
}

type FloatOption  struct {
    Optioner                          // 匿名字段（接口嵌入，需要具体的类型）
    Value float64                  // 具名字段（聚合）
}
```
## Reference
- [An Introduction to Programming in Go](http://www.golang-book.com/books/intro)