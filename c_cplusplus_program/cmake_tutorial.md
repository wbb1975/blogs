# CMake简要教程
本文是一个按部就班的教程，涵盖CMake主要解决的公共构建系统用例。许多主题已经在[掌握CMake](http://www.kitware.com/products/books/CMakeBook.html)中作为单独问题被介绍过了，但是观看它们如何在一个示例工程一起工作仍然是蛮有用的。这个教程也可以在CMake的源代码树中的[Tests/Tutorial](https://gitlab.kitware.com/cmake/cmake/blob/master/Help/guide/tutorial/index.rst)目录下找到。没有不由自己的子目录，包含了那一步所需代码的完整拷贝。

可以查看[ cmake-buildsystem(7) ](https://cmake.org/cmake/help/latest/manual/cmake-buildsystem.7.html#introduction)和[cmake-language(7) ](https://cmake.org/cmake/help/latest/manual/cmake-language.7.html#organization)手册页中的介绍章节来获得对CMake概念及源代码组织的基本印象。
## 起点（Step1）
最基本的项目是从源代码文件中构建出一个可执行文件。对于一个简单的工程来说，两行的CMakeLists.txt文件就足够了。这将是我们教程的开始。CMakeLists.txt文件看起来会像这样：
```
cmake_minimum_required (VERSION 2.6)
project (Tutorial)
add_executable(Tutorial tutorial.cxx)
```

注意，在这个例子中，CMakeLists.txt使用的是小写命令形式。但大写，小写，混写形式的命令CMake都支持。tutorial.cxx源码会计算出一个数的平方根。它的第一个版本看起来非常简单，如下：
```
// A simple program that computes the square root of a number
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
int main (int argc, char *argv[])
{
  if (argc < 2)
    {
    fprintf(stdout,"Usage: %s number\n",argv[0]);
    return 1;
    }
  double inputValue = atof(argv[1]);
  double outputValue = sqrt(inputValue);
  fprintf(stdout,"The square root of %g is %g\n",
          inputValue, outputValue);
  return 0;
}
```

**在配置的头文件中添加版本号**

我们第一个要加入的特性是，在工程和可执行程序上加一个版本号。虽然你可以直接在源代码里面这么做，然而如果用CMakeLists文件来做的话会提供更多的灵活性。为了增加版本号，我们可以如此更改CMakeLists文件：
```
cmake_minimum_required (VERSION 2.6)
project (Tutorial)
# The version number.
set (Tutorial_VERSION_MAJOR 1)
set (Tutorial_VERSION_MINOR 0)
 
# configure a header file to pass some of the CMake settings
# to the source code
configure_file (
  "${PROJECT_SOURCE_DIR}/TutorialConfig.h.in"
  "${PROJECT_BINARY_DIR}/TutorialConfig.h"
  )
 
# add the binary tree to the search path for include files
# so that we will find TutorialConfig.h
include_directories("${PROJECT_BINARY_DIR}")
 
# add the executable
add_executable(Tutorial tutorial.cxx)
```
由于配置文件必须写到binary tree中，因此我们必须将这个目录添加到头文件搜索目录中。我们接下来在源码目录中创建了**TutorialConfig.h.in**文件，其内容如下：
```
// the configured options and settings for Tutorial
#define Tutorial_VERSION_MAJOR @Tutorial_VERSION_MAJOR@
#define Tutorial_VERSION_MINOR @Tutorial_VERSION_MINOR@
```

当CMake配置了这个头文件， @Tutorial_VERSION_MAJOR@ 和 @Tutorial_VERSION_MINOR@ 的值将会被改变。接下来，我们修改了tutorial.cxx来包含配置的头文件并且使用版本号。最终的源代码如下所示：
```
// A simple program that computes the square root of a number
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "TutorialConfig.h"
 
int main (int argc, char *argv[])
{
  if (argc < 2)
    {
    fprintf(stdout,"%s Version %d.%d\n",
            argv[0],
            Tutorial_VERSION_MAJOR,
            Tutorial_VERSION_MINOR);
    fprintf(stdout,"Usage: %s number\n",argv[0]);
    return 1;
    }
  double inputValue = atof(argv[1]);
  double outputValue = sqrt(inputValue);
  fprintf(stdout,"The square root of %g is %g\n",
          inputValue, outputValue);
  return 0;
}
```
最主要的变更是包含了TutorialConfig.h头文件，并输出了版本号。
## 添加库（Step2）
现在我们给工程添加一个库。这个库会包含我们自己的平方根实现。如此，应用程序就可以使用这个库而非编译器提供的库了。在这个教程中，我们将库放入一个叫MathFunctions的子文件夹中。它会使用如下的一行CMakeLists文件：
```
add_library(MathFunctions mysqrt.cxx)
```

源文件mysqrt.cxx有一个叫做mysqrt的函数可以提供与编译器的sqrt相似的功能。为了使用新的库，我们需要在顶层的CMakeLists 文件中添加add_subdirectory的调用。我们也要添加一个另外的头文件搜索目录，使得MathFunctions/mysqrt.h可以被搜索到。最后的改变就是将新的库加到可执行程序中。顶层的CMakeLists 文件现在看起来是这样：
```
include_directories ("${PROJECT_SOURCE_DIR}/MathFunctions")
add_subdirectory (MathFunctions) 
 
# add the executable
add_executable (Tutorial tutorial.cxx)
target_link_libraries (Tutorial MathFunctions)
```

现在我们来考虑如何使得MathFunctions库成为可选的。虽然在这个教程当中没有什么理由这么做，然而如果使用更大的库或者当依赖于第三方的库时，你或许希望这么做。第一步是要在顶层的CMakeLists文件中加上一个选择项。
```
# should we use our own math functions?
option (USE_MYMATH 
        "Use tutorial provided math implementation" ON) 
```
这个选项会显示在CMake的GUI，并且其默认值为ON。当用户选择了之后，这个值会被保存在CACHE中，这样就不需要每次CMAKE都进行更改了。下面一步条件构建和链接MathFunctions库。为了达到这个目的，我们可以改变顶层的CMakeLists文件，使得其看起来像这样：
```
# add the MathFunctions library?
#
if (USE_MYMATH)
  include_directories ("${PROJECT_SOURCE_DIR}/MathFunctions")
  add_subdirectory (MathFunctions)
  set (EXTRA_LIBS ${EXTRA_LIBS} MathFunctions)
endif (USE_MYMATH)
 
# add the executable
add_executable (Tutorial tutorial.cxx)
target_link_libraries (Tutorial  ${EXTRA_LIBS})
```

这里使用了USE_MYMATH来决定MathFunctions是否会被编译和使用。注意这里变量EXTRA_LIBS的使用方法。这是保持一个大的项目看起来比较简洁的一个方法。源代码中相应的变化就比较简单了：
```
// A simple program that computes the square root of a number
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "TutorialConfig.h"
#ifdef USE_MYMATH
#include "MathFunctions.h"
#endif
 
int main (int argc, char *argv[])
{
  if (argc < 2)
    {
    fprintf(stdout,"%s Version %d.%d\n", argv[0],
            Tutorial_VERSION_MAJOR,
            Tutorial_VERSION_MINOR);
    fprintf(stdout,"Usage: %s number\n",argv[0]);
    return 1;
    }
 
  double inputValue = atof(argv[1]);
 
#ifdef USE_MYMATH
  double outputValue = mysqrt(inputValue);
#else
  double outputValue = sqrt(inputValue);
#endif
 
  fprintf(stdout,"The square root of %g is %g\n",
          inputValue, outputValue);
  return 0;
}
```

在源代码中我们同样使用了USE_MYMATH这个宏。它由CMAKE通过配置文件TutorialConfig.h.in来提供给源代码。
```
#cmakedefine USE_MYMATH
```
## 安装和测试（Step3）
接下来我们会为我们的工程增加安装规则和测试支持。安装规则是相当直接的。对于MathFunctions库我们安装库和头文件只需要在MathFunctions的 CMakeLists.txt中添加如下的语句：
```
install (TARGETS MathFunctions DESTINATION bin)
install (FILES MathFunctions.h DESTINATION include)
```
对于应用程序，我们只需要在顶层CMakeLists 文件中如此配置即可以安装可执行程序和配置了的头文件：
```
# add the install targets
install (TARGETS Tutorial DESTINATION bin)
install (FILES "${PROJECT_BINARY_DIR}/TutorialConfig.h"        
         DESTINATION include)
```

这就是所有需要做的。现在你就可以编译这个教程了，然后输入make install（或者编译IDE中的INSTALL目标），则头文件、库和可执行程序等就会被正确地安装。CMake变量CMAKE_INSTALL_PREFIX被用来决定那些文件会被安装在哪个根目录下。添加测试也是一个相当简单的过程。在最顶层的CMakeLists文件的最后我们可以添加一系列的基础测试来确认这个程序是否在正确工作。
```
include(CTest)

# does the application run
add_test (TutorialRuns Tutorial 25)
# does it sqrt of 25
add_test (TutorialComp25 Tutorial 25)
set_tests_properties (TutorialComp25 PROPERTIES PASS_REGULAR_EXPRESSION "25 is 5")
# does it handle negative numbers
add_test (TutorialNegative Tutorial -25)
set_tests_properties (TutorialNegative PROPERTIES PASS_REGULAR_EXPRESSION "-25 is 0")
# does it handle small numbers
add_test (TutorialSmall Tutorial 0.0001)
set_tests_properties (TutorialSmall PROPERTIES PASS_REGULAR_EXPRESSION "0.0001 is 0.01")
# does the usage message work?
add_test (TutorialUsage Tutorial)
set_tests_properties (TutorialUsage PROPERTIES PASS_REGULAR_EXPRESSION "Usage:.*number")
```
第一个测试简单地确认应用是否运行，没有段错误或者其它的崩溃问题，并且返回0。这是CTest的最基本的形式。下面的测试都使用了PASS_REGULAR_EXPRESSION测试属性来确认输出的结果中是否含有某个字符串。如果你需要添加大量的测试来判断不同的输入值，则你需要考虑创建一个类似于下面的宏：
```
#define a macro to simplify adding tests, then use it
macro (do_test arg result)
  add_test (TutorialComp${arg} Tutorial ${arg})
  set_tests_properties (TutorialComp${arg}
    PROPERTIES PASS_REGULAR_EXPRESSION ${result})
endmacro (do_test)
 
# do a bunch of result based tests
do_test (25 "25 is 5")
do_test (-25 "-25 is 0")
```
对do_test的任意一次调用，就有另一个测试被添加到工程中。
## 加入系统自省（Step4）
## 加入一个生成文件和一个生成器（Step5）
## 构建一个安装器（Step6）
## 加入仪表板（Dashboard）支持（Step7）

## 引用
- [cmake-tutorial](https://cmake.org/cmake-tutorial)
- [CMake简要教程](https://www.jianshu.com/p/bbf68f9ddffa)