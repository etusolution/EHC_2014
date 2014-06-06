# Etu Hadoop Competition 2014

Here are the source codes of "`send_my_score`" used in [Etu Hadoop Competition 2014][1]. For detail competition rules please check following URLs:

 * preliminary : http://ehc.etusolution.com/index.php/tw/#rules
 * finals : http://ehc.etusolution.com/final/rules.html

### Folders and Files

 * Following are the source tree.
```
.
├── finals
│   ├── send_my_score_1.pl
│   ├── send_my_score_2.pl
│   ├── send_my_score_3.pl
│   ├── send_my_score_4.pl
│   ├── send_my_score_5.pl
│   └── send_my_score_6.pl
├── preliminary
│   └── send_my_score.pl
└── README.md
```

### Description

 * In `preliminary` folder, file `send_my_score.pl` is the source code of `send_my_score` used in CentOS 6.4 EC2 instances.
 * In `finals` folder, there are 6 binaries run on CentOS 6.5 Host OS (Physical Machine).

  File Name          | Test Case Description
  -------------------|----------------------
  send_my_score_1.pl | check Hadoop Daemon status on VM1 to VM4 with `jps`
  send_my_score_2.pl | check QJM status with `hdfs haadmin -getServiceState`
  send_my_score_3.pl | check Kerberos Security status based on NameNode WebUI and `klist`
  send_my_score_4.pl | Performance Test Case (1) `TestDFSIO -write`
  send_my_score_5.pl | Performance Test Case (2) `TeraGen` & `TeraSort`
  send_my_score_6.pl | Performance Test Case (3) `hbase.PerformanceEvaluation randomWrite 1`

### Author

Jazz Yao-Tsung Wang < jazzwang **AT** etusolution **-DOT-** com >

### Why I release these source code ?

 * I believe that there are BUGs in these source codes and test cases. People are welcome to file tickets / issues for us to make improvement in future.
 * If you're teaching or trying to hire new employee, I think these test cases could be used for scoring hadoop beginner (`preliminary`) and skillful system administrators (`finals`).

### License

Apache 2.0

## FAQ

 * **Q1: Can I use this program to run another event?**
 * A1: It's open to all teachers and students. *Please do not use it for commercial purpose*.


  [1]: http://ehc.etusolution.com
