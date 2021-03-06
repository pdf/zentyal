# Copyright (C) 2013 Zentyal S.L.
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

package EBox::Downloader::CGI::RPCCert;
use base 'EBox::Downloader::CGI::Base';

use EBox::Global;
use EBox::Config;
use EBox::Gettext;
use EBox::Exceptions::External;

sub new
{
    my ($class, %params) = @_;
    my $self = $class->SUPER::new(@_);
    bless($self, $class);
    return  $self;
}

sub _path
{
    return EBox::Config::downloads() . 'rpcproxy.crt';
}

sub _process
{
    my ($self) = @_;
    my $openchange = EBox::Global->modInstance('openchange');
    my $file = $self->_path();
    if (not -r $file) {
        $openchange->_createRPCProxyCertificate();
        if (not -r $file) {
            throw EBox::Exceptions::External(__('Cannot create certificate for RPC Proxy with the current configuration'));
        }
    }
    $self->SUPER::_process();
}

1;
