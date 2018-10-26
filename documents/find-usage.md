### 通过搜索目录树查找文件：find

#### find程序一般语法为：
```shell
find path... test... action...
```
一旦输入该命令，find就会遵循一个3个步骤的处理过程。
1. 路径：find所做的第一件事情就是查看每个路径，检查所标识的整个目录树，包括所有的子目录。
2. 测试：对于所遇到的每个文件，find应用指定的测试条件。这里的目标就是创建一个满足指定标准的所有文件的列表。
3. 动作：一旦搜索完成，find应用指定的测试条件。这里的目标就是创建一个满足指定标准的所有文件的列表。

#### find命令：路径
可以为find指定不止一个搜索路径，例如：
```shell
find /bin /sbin /usr/bin ~harley/bin
```

#### find命令：测试
| 文件名             |                                                   |
| ------------------ | ------------------------------------------------- |
| -name pattern      | 包含pattern的文件名                               |
| -iname pattern     | 包含pattern的文件名（不区分大小写））             |
| 文件特征           |                                                   |
| -type [df]         | 文件类型：d=目录，f=普通目录                      |
| -perm mode         | 设置为mode的文件权限                              |
| -user userid       | 属主为userid                                      |
| -grouop groupid    | 组为grouopid                                      |
| -nogroup           | 查无有效属组的文件                                |
| -nouser            | 查无有效属主的文件                                |
| -size [-+]n[cbkMG] | 大小为n[字符（字节）、块、千字节、兆字节、吉字节] |
| -empty             | 空文件（大小=0）                                  |
| 访问时间、修改时间 | a：访问时间； c：创建时间 ；m：修改时间           |
| -amin [-+]n        | n分钟之前                                         |
| -anewer file       | file文件之后访问                                  |
| -atime [-+]n       | n天之前                                           |
| -cmin [-+]n        | n分钟之前的状态改变                               |
| -cnewer file       | file文件之后状态改变                              |
| -ctime [-+]n       | n天之前状态改变                                   |
| -mmin [-+]n        | n分钟之前修改                                     |
| -mtime [-+]n       | n天之前修改                                       |
| -newer file        | file 文件之后修改                                 |
| -depth             | 使查找在进入子目录前先行查找完本目录              |
| -fstype            | 查看更改时间比f1新但比f2旧的文件                  |
| -mount             | 查看文件时不跨越文件系统mount点                   |
| -follow            | 如遇到符号链接文件，就跟踪链接所知的文件          |
| cpio               | 查位于某一类型文件系统中的文件                    |
| -prune             | 忽略某个目录                                      |
| -maxdepth          | 查找目录级别深度                                  |

example :
```shell
find /etc -type f -print
find /etc -type d -print
find /etc -print
find . -type f -name important -print
find . -type f -name '*.c' -print
find . -type f -name 'data[123]' -print
find ~ -type d -perm 700 -print
find ~ -type f -user harley -print
find ~ -type f -group staff -print
```
-size 选项，后面跟一个具体的值。表示字符的c（也就是字节）、表示512字节块的b、表示千字节的k、表示兆字节的M和表示及字节的G。
example：
```shell
find ~ -type f -size 1b -print
find ~ -type f -size 100c -print
```

#### find命令：使用！运算符对测试求反
example：
```shell
find ~ -type f \! -name '*.jpg' -print     #显示扩展名不是.jpg的文件名
find ~ -type f '!' -name '*.jpg' -print
```

#### find命令：动作
| 动作                  |                           |
| ------------------- | ------------------------- |
| -print              | 将路径名写入到标准输出               |
| -fprint file        | 同-print：将输出写入到file中       |
| -ls                 | 显示长目录列表                   |
| -fls file           | 同-ls：将输出写入到file中          |
| -delete             | 删除文件                      |
| -exec command {} \; | 执行command, {}只是匹配的文件名     |
| -ok command {} \;   | 同-exec，但是在运行command之前进行确认 |

example：
```shell
find ~ -name '*.backup' -exec ls -dils {} \;
find ~ -name '*.backup' -exec rm -rf {} \;
find . -name '*.bakcup' -size -1M -exec rm -rf {} \;
```