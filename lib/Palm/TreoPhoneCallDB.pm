# $Id: TreoPhoneCallDB.pm,v 1.4 2007/07/29 15:38:40 drhyde Exp $

package Palm::TreoPhoneCallDB;

use strict;
use warnings;

use Palm::Raw();
use DateTime;

use vars qw($VERSION @ISA $timezone $incl_raw);

$VERSION = '1.0';
@ISA = qw(Palm::Raw);
$timezone = 'Europe/London';
$incl_raw = 0;

sub import {
    my $class = shift;
    my %opts = @_;
    $timezone = $opts{timezone} if(exists($opts{timezone}));
    $incl_raw = $opts{incl_raw} if(exists($opts{incl_raw}));
    Palm::PDB::RegisterPDBHandlers(__PACKAGE__, [HsPh => 'call']);
}

=head1 NAME

Palm::TreoPhoneCallDB - Handler for Treo PhoneCallDB databases

=head1 SYNOPSIS

    use Palm::PDB;
    use Palm::TreoPhoneCallDB timezone => 'Europe/London';

    my $pdb = Palm::PDB->new();
    $pdb->Load("PhoneCallDB.pdb");
    print Dumper(@{$pdb->{records}})'

=head1 DESCRIPTION

This is a helper class for the Palm::PDB package, which parses the database
generated by Palm Treos as a  record who you called, when, and for how long.

=head1 OPTIONS

You can set some global options when you 'use' the module:

=over

=item timezone

Defaults to 'Europe/London'.

=item incl_raw

Whether to include the raw binary blob of data in the parsed records.
Only really useful for debuggering, and so defaults to false.

=back

=head1 METHODS

This class inherits from Palm::Raw, so has all of its methods.  The following
are over-ridden, and differ from that in the parent class thus:

=head2 ParseRecord

Returns data structures with the following keys:

=over

=item rawdata

The raw data blob passed to the method.  This is only present if the
incl_raw option is true.

=item date

The date the call started, in YYYY-MM-DD format

=item time

The time the call started, in HH:MM format

=item epoch

The epoch time the call started.  Note that because the database doesn't
store the timezone, we assume 'Europe/London'.  If you want to change
that, then suppy a timezone option when you 'use' the module.

Internally, this uses the DateTime module.  In the case of ambiguous times
then it uses the latest UTC time.  For invalid local times, the epoch is
set to -1, an impossible number as it's before Palm even existed.

Note that this is always the Unix epoch time.  See L<DateTime> for details
of what this means.

=item duration

The length of the call in seconds

=item name

The name of the other party, which the Treo extracts from the SIM phone-book
or from the Palm address book at the time the call is connected.

=item number

The number of the other party.  This is not normalised so you might see the
same number in different formats, eg 02079813000 and +442079813000.  I may
add number normalisation in the future.

=item direction

Either 'Incoming', 'Outgoing' or 'Missed'.  

=back

Other fields may be added in the future.

=cut

sub ParseRecord {
    my $self = shift;
    my %record = @_;

    $record{rawdata} = delete($record{data});

    my($flags, $date, $time, $duration, $name, $number) = unpack(
        'n3N1Z*Z*', $record{rawdata}
    );
    my $year = 1904 + (($date & 0b1111111000000000) >> 9);
    my $month = sprintf('%02d', ($date & 0b111100000) >> 5);
    my $day = sprintf('%02d', $date & 0b11111);
    my $hour = sprintf('%02d', $time >> 8);
    my $minute = sprintf('%02d', $time & 255);

    @record{qw(date time duration name number direction)} = (
        "$year-$month-$day",
        "$hour:$minute",
        $duration,
        $name,
        $number,
        (qw(Incoming Missed Outgoing))[$record{category} - 1]
    );
    $record{epoch} = eval { DateTime->new(
        year => $year,
        month => $month,
        day => $day,
        hour => $hour,
        minute => $minute,
        time_zone => $timezone
    )->epoch(); } || -1;

    delete $record{rawdata} unless($incl_raw);

    return \%record;
}

=head1 LIMITATIONS

There is currently no support for creating a new database, or for editing
the contents of an existing database.  If you need that functionality,
please submit a patch with tests.  I will *not* write this myself
unless I need it.

Behaviour if you try to create or edit a database is currently undefined.

=head1 BUGS and FEEDBACK

Online documentation claims that there are various flags in the
records to indicate whether calls are incoming or outgoing and
so on.  I can't find these flags anywhere in the data generated by
my Treo 680.  Instead, it seems to be stored in the 'category'
field.  It is, however, possible that the category numbers for each
type of call vary from one Treo to another maybe depending on the
order in which the first calls are made.

If you find any other bugs please report them either using
L<http://rt.cpan.org/> or by email.  Ideally, I would like to receive a
sample database and a test file, which fails with the latest version of
the module but will pass when I fix the bug.

=head1 SEE ALSO

L<Palm::PDB>

L<DateTime>

=head1 AUTHOR

David Cantrell E<lt>F<david@cantrell.org.uk>E<gt>

=head1 COPYRIGHT and LICENCE

Copyright 2007 David Cantrell

This module is free-as-in-speech software, and may be used, distributed,
and modified under the same terms as Perl itself.

=head1 CONSPIRACY

This module is also free-as-in-mason software.

=cut

1;
