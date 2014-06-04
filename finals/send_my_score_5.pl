#!/usr/bin/perl

#use strict;
our $SCORE_IP = "192.168.70.1";
#our $IP = "127.0.0.1";

chomp($TIME=`date +"%Y%m%d_%H.%M.%S.%N"`);
chomp($HOST=`hostname`);
open(LOG, "> /tmp/score-5_$TIME.txt") || die("Cannot open /tmp/score-5_$TIME.txt\n");
print LOG "Hostname: $HOST\n";
print LOG "Submitted at $TIME\n";
print LOG "------------------------\n";

$OK ="[32;1m[ OK ][0m";
$ERR="[31;1m[ ERR ][0m";

$TERASORT = 9999 ;

sub check_hadoop 
{
  $IP=shift;

  print "[34;1m === <EHC> checking $IP for PATH environment variables === [0m\n";

  $JPS=`ssh -i ~/.vagrant.d/insecure_private_key vagrant@"$IP" "which jps"`;
  $NETSTAT=`ssh -i ~/.vagrant.d/insecure_private_key vagrant@"$IP" "which netstat"`;
  $HADOOP=`ssh -i ~/.vagrant.d/insecure_private_key vagrant@"$IP" "which hadoop"`;

  if ( "$JPS" eq "" )
  {
    print "[33;1m Have you installed [31;1mJDK[33;1m and make [31;1mjps[33;1m available for all users ?\n";
    print " Please check your \$PATH environment settings.\n Or link jps to /usr/bin/jps.\n[0m";
    exit -1;
  }

  if ( "$NETSTAT" eq "" )
  {
    print "[33;1m Have you installed [31;1mnet-tools (netstat)[33;1m and make it available for all users ?\n";
    print " Please check your \$PATH environment settings.\n[0m";
    exit -1;
  }

  if ( "$HADOOP" eq "" )
  {
    print "[33;1m Have you installed [31;1mHadoop[33;1m and make it available for all users ?\n";
    print " Please check your \$PATH environment settings.\n[0m";
    exit -1;
  }
}

sub check_krb_1
{
  print "[34;1m === <EHC> checking Hadoop Security (1) === [0m\n";
  if ( -e ".ha_locked" )
  {
    if ( -e ".krb_sent" )
    {
      print " Running 'wget -q -O kerberos.html http://192.168.90.12:50070/dfshealth.jsp'\n";
      `wget -q -O kerberos.html http://192.168.90.12:50070/dfshealth.jsp`;
      print " Checking for Security Setting .... '\n";
      chomp($KRB = `cat kerberos.html | grep "Security"`);
      
      if ( $KRB =~ /ON/ ) 
      {
	  print "[33;1m HDFS Kerberos : \t$OK\n";
	  $KRB1 = 10;
      } else {
	  print "[33;1m HDFS Kerberos : \t$ERR\n";
      }
      
      print LOG "\n";
      print LOG " HDFS Kerberos = $KRB \n";
      print " HDFS Kerberos = $KRB \n";
      print LOG "\n------------------------\n";
    } else {
      print " [32;1m Have you sent score of Kerberos ?! [0m";
    }
  } else {
      print " [31;1m WARN!! WARN!! Press CTRL+C to terminate .... \n OR You will GIVE UP the right to submit score of HA / Kerberos !!! [0m";
  }
}

sub run_terasort
{
  print "[34;1m === <EHC> Run TeraGen  === [0m\n";
  if ( -e ".teragen" )
  {
      print " Skip TeraGen !! \n";
  } else {
      print " Running 'ssh -i ~/.vagrant.d/insecure_private_key vagrant@\"192.168.90.12\" \"hadoop jar /vagrant/hadoop-mapreduce-examples.jar teragen 10000 /terasort-1M '\n [32;1m Messages will show later ... Please wait ....\n[0m";
      $OUTPUT=`ssh -i ~/.vagrant.d/insecure_private_key vagrant@"192.168.90.12" "hadoop jar /vagrant/hadoop-mapreduce-examples.jar teragen 10000 /terasort-1M 2>&1"`;
      `touch .teragen`;
  }

  print "$OUTPUT";
  print LOG "$OUTPUT";

  print "\n[34;1m === <EHC> Run TeraSort  === [0m\n";
  print " Running 'ssh -i ~/.vagrant.d/insecure_private_key vagrant@\"192.168.90.12\" \"sudo su - hdfs -c \'hadoop jar /vagrant/hadoop-mapreduce-examples.jar teragen /terasort-1M /terasort-out\''\n [32;1m Messages will show later ... Please wait ....\n[0m";
  chomp($OUTPUT=`ssh -i ~/.vagrant.d/insecure_private_key vagrant@"192.168.90.12" "sudo su - hdfs -c 'hadoop jar /vagrant/hadoop-mapreduce-examples.jar terasort /terasort-1M /terasort-out' 2>&1"`);

  print "$OUTPUT";
  print LOG "$OUTPUT";

  chomp($IO=`grep "CPU time spent (ms)" /tmp/score-5_$TIME.txt | grep "CPU time spent" | sed 's#=# #' | awk '{ N=N+\$5 } END { print N }'`);
  print "\n\n [33;1m CPU time spent (ms) = $IO\n[0m";
  $TERASORT = $IO;
}

check_hadoop("192.168.90.12");
check_krb_1();
run_terasort();

print " ------------------------\n";
print "[33;1m TERASORT = $TERASORT [0m\n";
