## 在你的构建中使用Guava
### 如何配置你的构建
对下面的任何代码片段，请把给性的版本替换为你希望使用的Guava版本号。
#### [Maven](http://maven.apache.org/)
将下面的片段加入到<dependencies /> 部分：
```
<dependency>
    <groupId>com.google.guava</groupId>
    <artifactId>guava</artifactId>
    <version>23.5-jre</version> <!-- or 23.5-android for the Android flavor -->
</dependency>
```
#### [Gradle](http://www.gradle.org/)
确保Maven中央仓库如下面般可用：
```
repositories {
  mavenCentral()
}
```
然后像下面的代码那样将Guava依赖加入到依赖章节中：
```
dependencies {
  compile group: 'com.google.guava', name: 'guava', version: '23.5-jre' # or 23.5-android for the Android flavor
}
```
#### [Ivy](http://ant.apache.org/ivy/)
将下面一行加入到依赖章节中：
```
<dependency org="com.google.guava" name="guava" rev="23.5-jre" />
 <!-- or rev="23.5-android" for the Android flavor -->
```
并确保使用了公共解析器。
#### [Buildr](http://buildr.apache.org/)
`compile.with 'com.google.guava:guava:jar:23.5-jre' # or '...:23.5-android' for the Android flavor`
#### 手动依赖
你也可手动下载类，源代码及JavaDoc的Jar文件。参见合适的[Release](https://github.com/google/guava/releases)版本。
#### GWT如何？
在上面的代码示例中，留下"com.google.guava"不变，但把"guava"替换为"guava-gwt"（GWT没有Andriod版本）。
## Guava自己的依赖如何？
Guava确实有一个运行时依赖：com.google.guava:failureaccess:1.0。这个组件在使用ListenableFuture时需要，这有别于Guava的其它组件。
## 我如何避免多版本Guava间的冲突？
## 如果第三方库中包含了声明为@Beta的API该怎么办？

## Reference
- [Using Guava in your build](https://github.com/google/guava/wiki/UseGuavaInYourBuild)