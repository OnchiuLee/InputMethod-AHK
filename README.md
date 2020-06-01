# AHK-Input-method

## 最新的包请前往资源库下载[http://98wb.ys168.com/](http://98wb.ys168.com/ "98五笔资源库")

<font size=28>## 用Autohotkey脚本语言改装的五笔98输入法，可以实现正常的文本输入，包含的功能有：</font>


1、显示字根拆分

2、内置的方案有「98五笔含词」「98五笔单字」「98五笔超集」

3、内置98超集可以打十万汉字，需字体支持，[更多资源:](http://98wb.ys168.com/ "98五笔资源库")

![效果图](https://github.com/OnchiuLee/AHK-Input-method/blob/master/Font/%E5%AD%97%E4%BD%93%E6%94%AF%E6%8C%81/%E6%95%88%E6%9E%9C%E5%9B%BE.png)

**更多使用见使用说明。。。**

```
注意事项：


一、开机自启项如果设置无效，请退出。以管理员身份运行主程序或在设置页面换一种自启方式。主启动文件为32位AUTOHOTKEY.EXE,会根据系统位数自适应32位或64位,MAIN目录下的AUTOHOTKEYU64.EXE不要删除,不然会调用出错!!!

二、配置文件CONFIG.INI在程序运行时更改无效，进「高级设置」进行配置，如果在配置文件中更改色值，需注意例如：正常色值“1C7399”需颠倒成“99731C”写入配色项才正常。

三、对于WIN7以下的系统无法使用GDIP候选风格，请使用另两种，WIN8以上的系统使用GDIP候选框风格最佳。

四、对于部分软件光标无法跟随可以在「高级设置」固定光标位置（可以设置显示位置的坐标）。少数软件窗口出现候选词无法上屏时，请设置「剪切板通道」解决。

五、字根拆分功能需要专门字体支持方能显示，请在本程序FONT目录安装字体再导入注册表关联系统字体或在上面资源库地址进行下载。支持的字体有：「98WB-1/98WB-3/98WB-0/98WB-V/98WB-P0/98WB-ZG/五笔拆字字根字体」。

六、中英文切换热键更换注意：如果仅设置单个CTRL/SHIFT/ALT/WIN请进按键选择页面进行「清空」操作。设置组合键最好不有设置当前电脑没有的按键！！！

七、批量造词热键「默认为CTRL+CAPSLOCK」，可以直接输入中文词条进行无码生词，也可以固定格式造词例如「GGTE=五笔」，  ` 键可以引导在线精准造词，上屏即保存词库中，造词过程中是以单字形式输入每个单字以`键隔开。

八、临时英文 为``引导，~键引导以形查音，Z键空引导时显示历史输入，最大数量为一页设置的最大值。Z键+字母为拼音反查 如果当前设置的字体为拆分字体，则反查的显示为拆分字根否则显示为五笔编码。

九、/+编码 输出特殊符号，具体参照目录下使用说明。同时/+标签名 可以进行配置更改、方案切换，具体参照「标签页设置」  /ZZSJ、/ZZRQ、/ZZNL、/WEEK、/DATE、/TIME、/NL 为输出当前的时间日期或者农历时间日期。/+数字串可以用来查询农历日期和金额大小写转换。

十、托盘菜单「启用状态」/「禁用状态」为程序挂起功能，当本程序与其它程序有冲突时可以临时挂起相当于禁用(默认快捷键为ALT+Z)，重复点击为启用。「CTRL+ESC」为退出程序热键。

十一、含词/超集/英文/特殊符号词库都能进行导入或导出为TXT码表，方案码表导入格式支持「单行多义」和「单义单义」

十二、如果部分系统页面候选框无法显示，请开启UIA 提升候选框层级显示权限

十三、大批量造词可以把批量无编码的词条TXT文本拖至桌面LOGO上即可进行大批量造词并写
入，码表文件拖拽至输入法LOGO上也可进行「多义」与「单义」格式互转

十四、码表切换可以通过【CI/ZI/CHAIJI/ZG】标签切换，也可以通过设置页面。双击桌面LOGO的码表名称【含词/单字/超集/字根】进行切换。

十五、自造词管理词频为0的为从导入的词库中已经删除的词，在自造词管理界面删除即可恢复。

十六、自己配色的主题可以导出可作为选择的主题选项，在主题管理界面可以对主题进行删除操作，慎重操作删除不可恢复！

十七、在「高级设置」的「词库项」勾选“导出为YAML文件” 可以直接把柚子的词库导出为RIME系列输入可直接使用的YAML词库文件（前提条件是SYNC目录下有HEADER.TXT头文件才会导出为YAML格式，否则导出为普通的单行单义TXT码表文件）

十八、如果在固定的电脑上使用最好进行「提权开启UIA」操作，以免出现不必要的问题。要是仅仅作为便携使用，则不要开启UIA，不然频繁换电脑会出现启动文件本地签名不一致导致无法启动的情况。

```
