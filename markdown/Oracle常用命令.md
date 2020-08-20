- create spfile from pfile;     -->基于pfile创建spfile
  - 当spfile和init同时存在，数据库启动优先读取spfile
- create pfile from spfile;     -->基于spfile创建pfile
- create spfile[=path] from pfile=[path];
- select status from v$instance;    -->查询当前数据库状态
- 分步启动Oracle tartup [normal]
  - 1. startup nomount      -->读取参数文件
    - nomount -->started状态
  - 2. alter database mount    -->查看控制文件是否正常，读取控制文件
    - mount -->mounted状态
  - 3. alter database open     -->数据库的正常状态
    - open  -->open状态
- 关闭数据库的四个参数
  - shutdown abort    -->不考虑数据库数据一致性
  - shutdown immediate
  - shutdown transactional
  - shutdown normal

<table>
    <tr>
        <td>关闭模式</td>
        <td>A</td>
        <td>I</td>
        <td>T</td>
        <td>N</td>
    </tr>
    <tr>
        <td>允许新连接</td>
        <td>否</td>
        <td>否</td>
        <td>否</td>
        <td>否</td>
    </tr>
    <tr>
        <td>等待当前会话结束</td>
        <td>否</td>
        <td>否</td>
        <td>否</td>
        <td>是</td>
    </tr>
    <tr>
        <td>等待当前事务处理结束</td>
        <td>否</td>
        <td>否</td>
        <td>是</td>
        <td>是</td>
    </tr>
    <tr>
        <td>强制选择检查点并关闭文件</td>
        <td>否</td>
        <td>是</td>
        <td>是</td>
        <td>是</td>
    </tr>
</table>
- alter database backup controlfile to trace as '/tmp/connn.log'     -->备份控制文件
- 