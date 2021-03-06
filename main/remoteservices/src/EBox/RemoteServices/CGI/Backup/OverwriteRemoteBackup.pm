# Copyright (C) 2010-2014 Zentyal S.L.
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

package EBox::RemoteServices::CGI::Backup::OverwriteRemoteBackup;

use base qw(EBox::CGI::ClientBase);

use EBox::RemoteServices::Backup;
use EBox::Gettext;
use EBox::Exceptions::Internal;
use EBox::Exceptions::External;

sub new 
{
    my $class = shift;
    my $self = $class->SUPER::new( @_);
    $self->{errorchain} = "RemoteServices/Backup/Index";
    $self->{redirect} = "RemoteServices/Backup/Index";
    bless($self, $class);
    return $self;
}

sub requiredParameters
{
  return [qw(name newName description)];
}

sub optionalParameters
{
  return [qw(ok cancel)];
}

sub actuate
{
  my ($self) = @_;

  $self->param('cancel') and return;

  my $backup =  new EBox::RemoteServices::Backup;
  my $oldName   = $self->param('name');

  # remove old backup
  $backup->removeRemoteBackup($oldName);

  my $newName = $self->param('newName');
  my $description = $self->param('description');

  # Go to make backup CGI with the proper parameters

  # Delete all CGI parameters
  my $request = $self->request();
  my $parameters = $request->parameters();
  $parameters->clear();

  $parameters->add('name' => $newName);
  $parameters->add('description' => $description);
  $parameters->add('backup' => 1);

  $self->setChain("RemoteServices/Backup/MakeRemoteBackup");
}

1;
