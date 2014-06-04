#!/usr/bin/perl

#use strict;
our $SCORE_IP = "192.168.70.1";
#our $IP = "127.0.0.1";

chomp($TIME=`date +"%Y%m%d_%H.%M.%S.%N"`);
chomp($HOST=`hostname`);
open(LOG, "> /tmp/score-3_$TIME.txt") || die("Cannot open /tmp/score-3_$TIME.txt\n");
print LOG "Hostname: $HOST\n";
print LOG "Submitted at $TIME\n";
print LOG "------------------------\n";

$OK ="[32;1m[ OK ][0m";
$ERR="[31;1m[ ERR ][0m";

$KRB1 = 0 ;
$KRB2 = 0 ;

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
  print " Running 'wget -q -O kerberos.html http://192.168.90.12:50070/dfshealth.jsp'\n";
  `wget -q -O kerberos.html http://192.168.90.12:50070/dfshealth.jsp`;
  print " Checking for Security Setting .... '\n";
  chomp($KRB = `cat kerberos.html | grep "Security"`);

  if ( $KRB =~ /ON/ ) 
  {
      print "[33;1m HDFS Kerberos : \t$OK\n";
      $KRB1 = 5;
  } else {
      print "[33;1m HDFS Kerberos : \t$ERR\n";
  }

  print LOG "\n";
  print LOG " HDFS Kerberos = $KRB \n";
  print " HDFS Kerberos = $KRB \n";
  print LOG "\n------------------------\n";
}

sub check_krb_2
{
  print "[34;1m === <EHC> checking Hadoop Security (2) === [0m\n";
  print " Running 'ssh -i ~/.vagrant.d/insecure_private_key vagrant@\"192.168.90.13\" \"sudo su - user -c \'/usr/bin/klist -e\''\n";
  chomp($KLIST=`ssh -i ~/.vagrant.d/insecure_private_key vagrant@"192.168.90.13" "sudo su - user -c '/usr/bin/klist -e' 2>&1"`);

  if ( $KLIST =~ /No credentials cache found/ )
  {
      print "[33;1m user Kerberos : \t$OK\n";
      $KRB2 = 5;
  } else {
      print "[33;1m user Kerberos : \t$ERR\n";
  }
}

check_hadoop("192.168.90.13");
check_krb_1();
check_krb_2();

$filename = ".krb_locked";
if ( -e $filename ) {
    print "[31;1m You GAVE UP the score of Kerberos before !!\n";
    $KRB1 = 0;
    $KRB2 = 0;
}

$KRB_SCORE = $KRB1 + $KRB2;

print " ------------------------\n";
print "[33;1m KERBEROS 1 = $KRB1 [0m\n";
print "[33;1m KERBEROS 2 = $KRB2 [0m\n";
print "[33;1m KERBEROS = $KRB_SCORE [0m\n";
