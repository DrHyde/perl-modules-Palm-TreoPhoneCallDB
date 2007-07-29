#!/usr/bin/perl -w

use strict;

use Test::More tests => 8;

use Palm::PDB;
BEGIN { use_ok('Palm::TreoPhoneCallDB') }

my $pdb = Palm::PDB->new();
$pdb->Load('t/PhoneCallDB.pdb');

my @records = @{$pdb->{records}};

my $record = $records[0];
ok($record->{number}   eq '02089393940',      "Number set correctly");
ok($record->{name}     eq 'Hyperformance (W)',"Name set correctly");
ok($record->{duration} eq '51',               "Duration set correctly");
ok($record->{date}     eq '2007-07-26',       "Date set correctly");
ok($record->{time}     eq '20:08',            "Time set correctly");
ok($record->{epoch}    eq '1185476880',   "Epoch calculated correctly");

ok(!exists($record->{rawdata}), "No raw data cos we didn't ask for it");
