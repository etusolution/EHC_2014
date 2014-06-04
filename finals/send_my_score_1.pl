#!/usr/bin/perl

#use strict;
our $SCORE_IP = "192.168.70.1";
#our $IP = "127.0.0.1";

chomp($TIME=`date +"%Y%m%d_%H.%M.%S.%N"`);
chomp($HOST=`hostname`);
open(LOG, "> /tmp/score-1_$TIME.txt") || die("Cannot open /tmp/score-1_$TIME.txt\n");
print LOG "Hostname: $HOST\n";
print LOG "Submitted at $TIME\n";
print LOG "------------------------\n";

$OK ="[32;1m[ OK ][0m";
$ERR="[31;1m[ ERR ][0m";

$VM1 = 0 ;
$VM2 = 0 ;
$VM3 = 0 ;
$VM4 = 0 ;

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

sub check_services
{
  $IP = shift;

  chomp($HOSTNAME = `ssh -i ~/.vagrant.d/insecure_private_key vagrant@"$IP" "hostname"`);

  print "[34;1m === <EHC> checking $HOSTNAME for required hadoop services === [0m\n";
  print " Running 'ssh -i ~/.vagrant.d/insecure_private_key vagrant@\"$IP\" \"sudo jps -lv\"'\n";
  $JPS = `ssh -i ~/.vagrant.d/insecure_private_key vagrant@"$IP" "sudo jps -l"`;
  $PS = `ssh -i ~/.vagrant.d/insecure_private_key vagrant@"$IP" "ps aux | grep java"`;

  print LOG "checking JPS for $HOSTNAME ($IP)\n";
  print LOG "$JPS";
  print LOG "$PS";
  print LOG "\n------------------------\n";

  if ( $HOSTNAME =~ /vm1/ )
  {
    if ( $JPS =~ /QuorumPeerMain/ )
    {
      print "[33;1m ZooKeeper : \t\t$OK\n";
      $VM1 = $VM1 + 1;
    } else {
      print "[33;1m ZooKeeper : \t\t$ERR\n";
    }

    if ( $JPS =~ /JournalNode/ )
    {
      print "[33;1m JournalNode : \t\t$OK\n";
      $VM1 = $VM1 + 1;
    } else {
      print "[33;1m JournalNode : \t\t$ERR\n";
    }

    if ( $JPS =~ /NameNode/ )
    {
      print "[33;1m NameNode : \t\t$OK\n";
      $VM1 = $VM1 + 1;
    } else {
      print "[33;1m NameNode : \t\t$ERR\n";
    }

    if ( $JPS =~ /NodeManager/ )
    {
      print "[33;1m NodeManager : \t\t$OK\n";
      $VM1 = $VM1 + 1;
    } else {
      print "[33;1m NodeManager : \t\t$ERR\n";
    }

    if ( $JPS =~ /HMaster/ )
    {
      print "[33;1m HMaster : \t\t$OK\n";
      $VM1 = $VM1 + 1;
    } else {
      print "[33;1m HMaster : \t\t$ERR\n";
    }

    print "[33;1m Score for VM1 : $VM1 [0m\n";
  }

  if ( $HOSTNAME =~ /vm2/ )
  {
    if ( $JPS =~ /QuorumPeerMain/ )
    {
      print "[33;1m ZooKeeper : \t\t$OK\n";
      $VM2 = $VM2 + 1;
    } else {
      print "[33;1m ZooKeeper : \t\t$ERR\n";
    }

    if ( $JPS =~ /JournalNode/ )
    {
      print "[33;1m JournalNode : \t\t$OK\n";
      $VM2 = $VM2 + 1;
    } else {
      print "[33;1m JournalNode : \t\t$ERR\n";
    }

    if ( $JPS =~ /NameNode/ )
    {
      print "[33;1m NameNode : \t\t$OK\n";
      $VM2 = $VM2 + 1;
    } else {
      print "[33;1m NameNode : \t\t$ERR\n";
    }

    if ( $JPS =~ /ResourceManager/ )
    {
      print "[33;1m ResourceManager : \t$OK\n";
      $VM2 = $VM2 + 1;
    } else {
      print "[33;1m ResourceManager : \t$ERR\n";
    }

    if ( $JPS =~ /HMaster/ )
    {
      print "[33;1m HMaster : \t\t$OK\n";
      $VM2 = $VM2 + 1;
    } else {
      print "[33;1m HMaster : \t\t$ERR\n";
    }

    print "[33;1m Score for VM2 : $VM2 [0m\n";
  }

  if ( $HOSTNAME =~ /vm3/ )
  {
    if ( $JPS =~ /QuorumPeerMain/ )
    {
      print "[33;1m ZooKeeper : \t\t$OK\n";
      $VM3 = $VM3 + 1;
    } else {
      print "[33;1m ZooKeeper : \t\t$ERR\n";
    }

    if ( $JPS =~ /JournalNode/ )
    {
      print "[33;1m JournalNode : \t\t$OK\n";
      $VM3 = $VM3 + 1;
    } else {
      print "[33;1m JournalNode : \t\t$ERR\n";
    }

    if ( $PS =~ /datanode/ )
    {
      print "[33;1m DataNode : \t\t$OK\n";
      $VM3 = $VM3 + 1;
    } else {
      print "[33;1m DataNode : \t\t$ERR\n";
    }

    if ( $JPS =~ /NodeManager/ )
    {
      print "[33;1m NodeManager : \t\t$OK\n";
      $VM3 = $VM3 + 1;
    } else {
      print "[33;1m NodeManager : \t\t$ERR\n";
    }

    if ( $JPS =~ /RegionServer/ )
    {
      print "[33;1m RegionServer : \t$OK\n";
      $VM3 = $VM3 + 1;
    } else {
      print "[33;1m RegionServer : \t$ERR\n";
    }

    print "[33;1m Score for VM3 : $VM3 [0m\n";
  }

  if ( $HOSTNAME =~ /vm4/ )
  {
    if ( $JPS =~ /QuorumPeerMain/ )
    {
      print "[33;1m ZooKeeper : \t\t$OK\n";
      $VM4 = $VM4 + 1;
    } else {
      print "[33;1m ZooKeeper : \t\t$ERR\n";
    }

    if ( $JPS =~ /JournalNode/ )
    {
      print "[33;1m JournalNode : \t\t$OK\n";
      $VM4 = $VM4 + 1;
    } else {
      print "[33;1m JournalNode : \t\t$ERR\n";
    }

    if ( $PS =~ /datanode/ )
    {
      print "[33;1m DataNode : \t\t$OK\n";
      $VM4 = $VM4 + 1;
    } else {
      print "[33;1m DataNode : \t\t$ERR\n";
    }

    if ( $JPS =~ /NodeManager/ )
    {
      print "[33;1m NodeManager : \t\t$OK\n";
      $VM4 = $VM4 + 1;
    } else {
      print "[33;1m NodeManager : \t\t$ERR\n";
    }

    if ( $JPS =~ /RegionServer/ )
    {
      print "[33;1m RegionServer : \t$OK\n";
      $VM4 = $VM4 + 1;
    } else {
      print "[33;1m RegionServer : \t$ERR\n";
    }

    print "[33;1m Score for VM4 : $VM4 [0m\n";
  }
}

check_hadoop("192.168.90.11");
check_hadoop("192.168.90.12");
check_hadoop("192.168.90.13");
check_hadoop("192.168.90.14");

check_services("192.168.90.11");
check_services("192.168.90.12");
check_services("192.168.90.13");
check_services("192.168.90.14");
