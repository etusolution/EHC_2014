#!/usr/bin/perl

#use strict;
our $SCORE_IP = "192.168.70.1";
#our $IP = "127.0.0.1";

chomp($TIME=`date +"%Y%m%d_%H.%M.%S.%N"`);
chomp($HOST=`hostname`);
open(LOG, "> /tmp/score-2_$TIME.txt") || die("Cannot open /tmp/score-2_$TIME.txt\n");
print LOG "Hostname: $HOST\n";
print LOG "Submitted at $TIME\n";
print LOG "------------------------\n";

$OK ="[32;1m[ OK ][0m";
$ERR="[31;1m[ ERR ][0m";

$HA1 = 0 ;
$HA2 = 0 ;

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

sub check_ha_1
{
  print "[34;1m === <EHC> checking High Availability (1) === [0m\n";
  print " Running 'ssh -i ~/.vagrant.d/insecure_private_key vagrant@\"192.168.90.13\" \"sudo su - hdfs -c 'hdfs haadmin -getServiceState vm1'\"'\n";
  chomp($NN1 = `ssh -i ~/.vagrant.d/insecure_private_key vagrant@"192.168.90.13" "sudo su - hdfs -c 'hdfs haadmin -getServiceState vm1'"`);
  print " Running 'ssh -i ~/.vagrant.d/insecure_private_key vagrant@\"192.168.90.13\" \"sudo su - hdfs -c 'hdfs haadmin -getServiceState vm2'\"'\n";
  chomp($NN2 = `ssh -i ~/.vagrant.d/insecure_private_key vagrant@"192.168.90.13" "sudo su - hdfs -c 'hdfs haadmin -getServiceState vm2'"`);

  if ( "$NN1" eq "active" ) 
  {
      if ( "$NN2" eq "standby" )
      {
      	  print "[33;1m vm1/vm2 = active/standby : \t$OK\n";
      	  $HA1 = 10;
      } 
  } else {
      	  print "[33;1m vm1/vm2 = active/standby : \t$ERR\n";
  }

  print LOG "\n";
  print LOG " NameNode on VM1 = $NN1 \n";
  print " NameNode on VM1 = $NN1 \n";
  print LOG " NameNode on VM2 = $NN2 \n";
  print " NameNode on VM2 = $NN2 \n";
  print LOG "\n------------------------\n";
}

sub check_ha_2
{
  print "[34;1m === <EHC> checking High Availability (2) === [0m\n";
  print " Running 'ssh -i ~/.vagrant.d/insecure_private_key vagrant@\"192.168.90.11\" \"sudo reboot -n'\"'\n";
  `ssh -i ~/.vagrant.d/insecure_private_key vagrant@"192.168.90.11" "sudo reboot -n"`;
  print " sleep 10 seconds!!\n";
  `sleep 10`;
  print " Running 'ssh -i ~/.vagrant.d/insecure_private_key vagrant@\"192.168.90.13\" \"sudo su - hdfs -c 'hdfs haadmin -getServiceState vm2'\"'\n";
  chomp($NN = `ssh -i ~/.vagrant.d/insecure_private_key vagrant@"192.168.90.13" "sudo su - hdfs -c 'hdfs haadmin -getServiceState vm2'"`);

  if ( "$NN" eq "active" ) 
  {
      print "[33;1m vm2 = active : \t\t$OK\n";
      $HA2 = 10;
  } else {
      print "[33;1m vm2 = active : \t\t$ERR\n";
  }
}

check_hadoop("192.168.90.13");
check_ha_1();
check_ha_2();

$filename = ".ha_locked";
if ( -e $filename ) {
    print "[31;1m You GAVE UP the score before !!\n";
    $HA1 = 0;
    $HA2 = 0;
}

$HA = $HA1 + $HA2;

print " ------------------------\n";
print "[33;1m HA1 = $HA1 [0m\n";
print "[33;1m HA2 = $HA2 [0m\n";
print "[33;1m HA = $HA [0m\n";
