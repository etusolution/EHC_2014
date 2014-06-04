#!/usr/bin/perl

chomp($TIME=`date +"%Y%m%d_%H.%M.%S.%N"`);
chomp($HOST=`hostname`);
open(LOG, "> /tmp/$TIME.txt") || die("Cannot open /tmp/$TIME.txt\n");
print LOG "Hostname: $HOST\n";
print LOG "Submitted at $TIME\n";
print LOG "------------------------\n";

$OK ="[32;1m[ OK ][0m";
$ERR="[31;1m[ ERR ][0m";

$JPS=`which jps`;
$NETSTAT=`which netstat`;
$HADOOP=`which hadoop`;
$HBASE=`which hbase`;
$PIG=`which pig`;
$HIVE=`which hive`;

if ( "$JPS" eq "" )
{
  print "[33;1mHave you installed [31;1mJDK[33;1m and make [31;1mjps[33;1m available for all users ?\n";
  print "Please check your \$PATH environment settings.\n Or link jps to /usr/bin/jps.\n[0m";
  exit -1;
}

if ( "$NETSTAT" eq "" )
{
  print "[33;1mHave you installed [31;1mHadoop[33;1m and make it available for all users ?\n";
  print "Please check your \$PATH environment settings.\n[0m";
  exit -1;
}

$JPS=`jps`;
print LOG "jps\n";
print LOG "------------------------\n";
print LOG "$JPS\n";

$NETSTAT=`netstat -nap | grep java | grep LISTEN`;
print LOG "------------------------\n";
print LOG "netstat\n";
print LOG "------------------------\n";
print LOG "$NETSTAT\n";

if ( "$HADOOP" eq "" )
{
  print "[33;1mHave you installed [31;1mHadoop[33;1m and make it available for all users ?\n";
  print "Please check your \$PATH environment settings.\n[0m";
  exit -1;
}

if ( "$HBASE" eq "" )
{
  print "[33;1mHave you installed [31;1mHBase[33;1m and make it available for all users ?\n";
  print "Please check your \$PATH environment settings.\n[0m";
  exit -1;
}

if ( "$PIG" eq "" )
{
  print "[33;1mHave you installed [31;1mPIG[33;1m and make it available for all users ?\n";
  print "Please check your \$PATH environment settings.\n[0m";
  exit -1;
}

if ( "$HIVE" eq "" )
{
  print "[33;1mHave you installed [31;1mHive[33;1m and make it available for all users ?\n";
  print "Please check your \$PATH environment settings.\n[0m";
  exit -1;
}

print "=========================================\n";
print "Setion #1 : HDFS\n";
print "=========================================\n";

$SCORE_1 = 0;

if ( $JPS =~ /NameNode/ )
{
  print "NameNode\t\t\t$OK\n";
  $SCORE_1 = $SCORE_1 + 2;
  if ( $NETSTAT =~ /127.0.0.1:8020/ )
  {
    print "127.0.0.1:8020 found!!\t\t$OK\n";
    $SCORE_1 = $SCORE_1 + 2;
  }
  if ( $NETSTAT =~ /:50070/ )
  {
    print "http://0.0.0.0:50070 found!!\t$OK\n";
    $SCORE_1 = $SCORE_1 + 2;
  }
} else {
  print "NameNode\t\t\t$ERR\n";
}

if ( $JPS =~ /DataNode/ ) {
  print "DataNode\t\t\t$OK\n";
  $SCORE_1 = $SCORE_1 + 2;
} else {
  print "DataNode\t\t\t$ERR\n";
}

if ( $JPS =~ /NameNode/ )
{
  $HDFS = `exec 2> /dev/null ; hadoop fs -lsr / | grep test.img`;
  if ( "$HDFS" eq "" )
  {
    print "[33;1mHave you uploaded [31;1m100mg.img[33;1m to HDFS as '[31;1mtest.img[33;1m' ?[0m\n";
  } else {
    print "test.img found on HDFS !!\t$OK\n";
    $SCORE_1 = $SCORE_1 + 7;
  }
}

print "SCORE #1 :\t\t\t[32;1m$SCORE_1[0m\n";

print "=========================================\n";
print "Setion #2 : YARN (MapReduce v2)          \n";
print "=========================================\n";

$SCORE_2 = 0;

if ( $JPS =~ /ResourceManager/ )
{
  print "ResourceManager\t\t\t$OK\n";
  $SCORE_2 = $SCORE_2 + 5;
  if ( $NETSTAT =~ /:8088/ )
  {
    print "http://0.0.0.0:8088 found!!\t$OK\n";
    $SCORE_2 = $SCORE_2 + 5;
  }
} else {
  print "ResourceManager\t\t\t$ERR\n";
}

if ( $JPS =~ /NodeManager/ ) {
  print "NodeManager\t\t\t$OK\n";
  $SCORE_2 = $SCORE_2 + 10;
} else {
  print "NodeManager\t\t\t$ERR\n";
}

print "SCORE #2 :\t\t\t[32;1m$SCORE_2[0m\n";

print "=========================================\n";
print "Setion #3 : ZooKeeper                    \n";
print "=========================================\n";

$SCORE_3 = 0;

if ( $JPS =~ /QuorumPeerMain/ )
{
  print "ZooKeeper\t\t\t$OK\n";
  $SCORE_3 = $SCORE_3 + 5;
  if ( $NETSTAT =~ /:2181/ )
  {
    print "0.0.0.0:2181 found!!\t\t$OK\n";
    $SCORE_3 = $SCORE_3 + 10;
  }
} else {
  print "ZooKeeper\t\t\t$ERR\n";
}

print "SCORE #3 :\t\t\t[32;1m$SCORE_3[0m\n";

print "=========================================\n";
print "Setion #4 : HBase                        \n";
print "=========================================\n";

$SCORE_4 = 0;

if ( $JPS =~ /HMaster/ )
{
  print "HMaster\t\t\t\t$OK\n";
  $SCORE_4 = $SCORE_4 + 5;
} else {
  print "HMaster\t\t\t\t$ERR\n";
}

if ( $JPS =~ /HRegionServer/ )
{
  print "HRegionServer\t\t\t$OK\n";
  $SCORE_4 = $SCORE_4 + 5;
} else {
  print "HRegionServer\t\t\t$ERR\n";
}

if ( $JPS =~ /HMaster/ )
{
  chomp($HBASE = `exec 2> /dev/null ; echo "scan 't1'" | hbase shell | grep "row(s)" | awk '{ print \$1 }'`);
  if ( $HBASE gt 0 )
  {
    print "$HBASE rows on 't1' table.\t\t$OK\n";
    $SCORE_4 = $SCORE_4 + 10;
  } else {
    print "No rows on 't1' table.\t\t$ERR\n";
    print "[33;1mHave you create [31;1m't1'[33;1m table on HBase ?[0m\n";
  }
}
print "SCORE #4 :\t\t\t[32;1m$SCORE_4[0m\n";

print "=========================================\n";
print "Setion #5 : Pig                          \n";
print "=========================================\n";

$SCORE_5 = 0;

if ( "$PIG" ne "" )
{
  $PIG1 = `exec 2> /dev/null ; hadoop fs -lsr / | grep pig_output`;
  if ( "$PIG1" eq "" )
  {
    print "[33;1mHave you run the example pig code \nand generate result on [31;1m/tmp/pig_output[33;1m ?[0m\n";
  } else {
    print "pig_output found on HDFS !!\t$OK\n";
    $SCORE_5 = $SCORE_5 + 7;

    `exec 2> /dev/null ; hadoop fs -get /tmp/pig_output/part-* /tmp/pig_output.hdfs`;
    `echo "7D286B5592D83BBE\t59" >  /tmp/reference`;
    `echo "0B294E3062F036C3\t61" >> /tmp/reference`;
    `echo "128315306CE647F6\t78" >> /tmp/reference`;

    print LOG "------------------------\n";
    print LOG "Pig                     \n";
    print LOG "------------------------\n";

    print LOG `cat /tmp/pig_output.hdfs`;
  
    chomp($PIG2 = `diff /tmp/pig_output.hdfs /tmp/reference; echo \$?`);
    if ( $PIG2 eq "0" )
    {
      print "pig_output are correct !!\t$OK\n";
      $SCORE_5 = $SCORE_5 + 8;
    } else {
      print "pig_output are wrong !!\t$ERR\n";
    }

    `rm -f /tmp/reference /tmp/pig_output.hdfs`;
  }
}

print "SCORE #5 :\t\t\t[32;1m$SCORE_5[0m\n";

print "=========================================\n";
print "Setion #6 : Hive                         \n";
print "=========================================\n";

$SCORE_6 = 0;

if ( "$HIVE" ne "" )
{
  $HIVE1 = `exec 2> /dev/null ; hadoop fs -lsr / | grep "baseball.db"`;
  if ( "$HIVE1" eq "" )
  {
    print "[33;1mHave you run the example hive code \nand store data in table [31;1mbaseball.master[33;1m ?[0m\n";
  } else {
    print "baseball database found !!\t$OK\n";
    $SCORE_6 = $SCORE_6 + 7;
    
    print LOG "------------------------\n";
    print LOG "Hive\n";
    print LOG "------------------------\n";

    chomp($HIVE2 = `exec 2> /dev/null ; hive -S -e "use baseball; SELECT birthyear, lahmanID, nameFirst FROM master WHERE birthyear > 1900 LIMIT 3;" > /tmp/hive_result ; echo $?`);
    print LOG `cat /tmp/hive_result`;
    print $HIVE2;
    if ( "$HIVE2" eq "0" )
    {
      print "hive queries are correct !!\t$OK\n";
      $SCORE_6 = $SCORE_6 + 8;
    } else {
      print "hive queries are wrong !!\t$ERR\n";
    }
  }
}

print "SCORE #6 :\t\t\t[32;1m$SCORE_6[0m\n";

print "=========================================\n";
$SCORE = $SCORE_1 + $SCORE_2 + $SCORE_3 + $SCORE_4 + $SCORE_5 + $SCORE_6 ;
print "Total SCORE :\t\t\t[33;1m$SCORE[0m\n";
print LOG "Total SCORE :\t\t\t[33;1m$SCORE[0m\n";
