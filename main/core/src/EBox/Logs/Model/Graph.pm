# Copyright (C) 2008-2013 Zentyal S.L.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 2, as
# published by the Free Software Foundation.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA

use strict;
use warnings;

package EBox::Logs::Model::Graph;

use base ( 'EBox::Model::DataTable', 'EBox::Logs::Model::Base',);

use EBox::Gettext;
use EBox::Exceptions::DataNotFound;
use EBox::Exceptions::Internal;

use Time::Local;

use TryCatch::Lite;

sub datasets
{
    my ($self) = @_;

    my @fields;
    my %dataPoints;
    my %conversors;

    my $dbFields = $self->dbFields();
    while (my ($field, $attr) = each %{ $dbFields }) {
        push @fields, $field;
        $dataPoints{$field} = [];

        if (exists $attr->{conversor}) {
            $conversors{$field} = $attr->{conversor};
        }
    }

    my $dbRows = $self->reportRows();

    foreach my $row (@{ $dbRows }) {
        # transform time in timestamp
        $row->{date} =~ m/^(\d+)\-(\d+)\-(\d+)\s(\d+):/;
        my $month = $2 - 1; # months go throught 0-11

        my $timestamp = timelocal( 0, 0,  $4, $3, $month, $1);

        foreach my $field (@fields) {
            my $value = $row->{$field};
            if (exists $conversors{$field}) {
                $value = $conversors{$field}->($value);
            }

            push @{ $dataPoints{$field} }, [$timestamp, $value];
        }

    }

    my @dataSet;
    foreach my $field (@fields) {
        push @dataSet, $dataPoints{$field};
    }

    return \@dataSet;
}

# Overrides base method to limit the number of rows according timeperiod
my %nRowsByTimePeriod = (
    hourly =>  30,
    daily  =>  10,
    weekly =>  10,
    monthly => 24,
   );

# Method: reportRows
#
#     Return the rows for graphing them
#
# Returns:
#
#     array ref - the rows
#
sub reportRows
{
    my ($self) = @_;

    unless (exists($self->{reportData})) {
        my $limit = $self->limitByTimePeriod();
        $self->{reportData} = $self->SUPER::reportRows($limit);
    }
    return $self->{reportData};
}


sub limitByTimePeriod
{
    my ($self) = @_;

    my $limit;
    my $timePeriod = $self->timePeriod();
    if (exists $nRowsByTimePeriod{$timePeriod}) {
        $limit = $nRowsByTimePeriod{$timePeriod};
    } else {
        $limit = 30;
    }

    return $limit;
}

# Method: size
#
#    Override to send back as size the number of report rows
#
# Overrides:
#
#    <EBox::Model::DataTable::size>
#
sub size
{
    my ($self) = @_;

    return scalar(@{$self->reportRows()});
}


sub datasetsLabels
{
    my ($self) = @_;
    my $dbFields = $self->dbFields();

    my @labels = map { $_->{printableName}  } values %{ $dbFields };
    return \@labels;
}

# Method: checkTable
#
#  This method does some fast and general checks in the table specification
#  We override it bz for Images is acceptable to not have elements in the tableDescription
#
#  Override: <EBox::Model::DataTable>
sub checkTable
{
    my ($self, $table) = @_;

    if (not exists $table->{tableDescription}) {
        throw EBox::Exceptions::Internal('Missing tableDescription in table definition');
    }

    if (not $table->{tableName}) {
        throw EBox::Exceptions::Internal(
            'table description has not tableName field or has a empty one'
                                        );
      }

    if ((exists $table->{sortedBy}) and (exists $table->{order})) {
        if ($table->{sortedBy}and $table->{order}) {
            throw EBox::Exceptions::Internal(
             'sortedBy and order are incompatible options'
                                        );
        }
    }

}

# Method altText
#
#  Returns:
#  the alternative text for the graphic. Default to a empty string
sub altText
{
    return '';
}

sub Viewer
{
    return '/ajax/graph.mas';
}

# sub modelDomain
# {
#     return 'ebox';
# }

1;
