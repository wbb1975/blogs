# Read File and Resource in JUnit Test
This quick tutorial is going to cover how to read file and resource in JUnit test where may need to access files or resources under the src/test/resources folder.

## Sample Project Directory Layout
A typical java project directory layout look like the below:

Layout    |SubDirectory
----------|-------------
![Typical Java Project Layoutt](https://github.com/wbb1975/blogs/blob/master/java/images/SampleProjectDirectoryLayout.png) | - src/main/java    contains all application/library sources
- src/main/resources    contains application/library resources
- src/test/java    contain test sources
- src/test/resources    test resources


In this article, we mainly focus on the test sources and resources. There are several cases that we may want to read file and resource in JUnit tests such as:
- File or resource contains the test data
- Tests are related to file operations
- Configuration files
## Read File and Resource in JUnit Test Examples
### 1. Using ClassLoader’s Resource
```
    @Test
    public void testReadFileWithClassLoader(){
        ClassLoader classLoader = this.getClass().getClassLoader();
        File file = new File(classLoader.getResource("lorem_ipsum.txt").getFile());
        assertTrue(file.exists());
 
    }
```
If we need to read file or resource in the sub directory of the src/test/resources directory, we have to specify the path to that sub directory. For example,  we will read the users.csv file from the src/test/resources/data01 directory:
```
    @Test
    public void testReadFileWithClassLoader2() {
        ClassLoader classLoader = this.getClass().getClassLoader();
        File file = new File(classLoader.getResource("data01/users.csv").getFile());
        assertTrue(file.exists());
 
    }
```
### 2. Using Class’s Resource
Any file under src/test/resources is often copied to target/test-classes. To access these resource files in JUnit we can use the class’s resource. It will locate the file in the test’s classpath /target/test-classes.
```
    @Test
    public void testReadFileWithResource() {
        URL url = this.getClass().getResource("/lorem_ipsum.txt");
        File file = new File(url.getFile());
        assertTrue(file.exists());
    }
```
The “/” means the file or resource is located at the src/test/resources directory. If the file or resource is in the sub directory, we have to  specify the relative path from the src/test/resources to that sub directory. Let’s see an example which we read the users.csv file fromsrc/test/resources/data directory:
```
    @Test
    public void testReadFileWithResource2() throws IOException{
        InputStream is = this.getClass().getResourceAsStream("/data01/users.csv");
        assertNotNull(is);
    }
```
### 3. Using Relative Path
We can read file and resource in JUnit test by using the relative path from the src/test/resources folder. Let’s see an example:
```
    @Test
    public void readFileRelativePath() {
        File file = new File("src/test/resources/lorem_ipsum.txt");
        assertTrue(file.exists());
    }
```
### 4. Read File and Resource in JUnit Test into Stream
If we want to read file and resource in JUnit test directly into stream, we can use the class’s resource again:
```
    @Test
    public void testReadAsStream() throws IOException{
        InputStream is = this.getClass().getResourceAsStream("/lorem_ipsum.txt");
        assertNotNull(is);
    }
```
If the file or resource is in the sub directory, we have to specify the relative path from the src/test/resources to that sub directory. Let’s see the following example which will read the users.csv file in src/test/resources/data01:
```
    @Test
    public void testReadAsStream2() throws IOException{
        InputStream is = this.getClass().getResourceAsStream("/data01/users.csv");
        assertNotNull(is);
    }
```

## Reference
1. [Read File and Resource in JUnit Test](https://howtoprogram.xyz/2017/01/17/read-file-and-resource-in-junit-test/)
