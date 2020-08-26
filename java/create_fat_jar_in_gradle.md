# 在Gradle中创建Fat jar
## 1. 简介
在这篇快速教程中，我们将介绍在Gradle中创建fat Jar。

基本上，一个 fat jar （也叫Uber Jar）是一个自给自足的归档文件，它包含运行一个应用所需的类及其依赖（的库）。
## 2. 最初设置
让我们从一个Java项目的简单的build.gradle文件开始，其包含两个依赖：
```
apply plugin: 'java'
 
repositories {
    mavenCentral()
}
 
dependencies {
    compile group: 'org.slf4j', name: 'slf4j-api', version: '1.7.25'
    compile group: 'org.slf4j', name: 'slf4j-simple', version: '1.7.25'
}
```
## 3. 利用Java插件的Jar任务
让我们在Java Gradle插件的修稿JAR任务开始。魔人地，该任务产生的jars不包含任何依赖。

我们可以通过增加几行代码来覆写该行为，我们还需要做两件事情来使它工作：
- Manifest文件中的一个 `Main-Class` 属性
- 包含依赖jars

让我们把这点修改添加到Gradle 任务中：
```
jar {
    manifest {
        attributes "Main-Class": "com.baeldung.fatjar.Application"
    }
 
    from {
        configurations.compile.collect { it.isDirectory() ? it : zipTree(it) }
    }
}
```
## 4. 创建一个单独的任务
如果你不想修改原来的 jar 任务，你可以查U那个建一个单独的任务来做一样的工作。下面的代码添加了一个新的任务叫customFatJar：
```
task customFatJar(type: Jar) {
    manifest {
        attributes 'Main-Class': 'com.baeldung.fatjar.Application'
    }
    baseName = 'all-in-one-jar'
    from { configurations.compile.collect { it.isDirectory() ? it : zipTree(it) } }
    with jar
}
```
## 5. 使用专用插件
我们也可以使用已有的Gradle 插件来构建fat JAR。

下面的例子中我们将使用[Shadow](https://github.com/johnrengelman/shadow) 插件：
```
buildscript {
    repositories {
        jcenter()
    }
    dependencies {
        classpath 'com.github.jengelman.gradle.plugins:shadow:2.0.1'
    }
}
 
apply plugin: 'java'
apply plugin: 'com.github.johnrengelman.shadow'
```
一旦我们应用了Shadow 插件，shadowJar 任务即可被使用。
## 6. 结论　
在本教程中，我展示了不同的在Gradle中创建fat jar的方法。我们覆写缺省的jar任务，创建一个单独的任务或者是用shadow 插件。

哪种方式值得推荐？答案是--取决于实际情况。

在简单的项目中，覆写默认的jar任务或创建一个新的就足够了，但随着项目规模增长，我们强烈建议使用插件。因为他们已经解决了更多困难的问题，比如说与外部META-INF冲突问题。

像平常一样，本教程的全部实现代码可在[GitHub](https://github.com/eugenp/tutorials/tree/master/gradle)上找到。

## Reference
- [Creating a Fat Jar in Gradle](https://www.baeldung.com/gradle-fat-jar)