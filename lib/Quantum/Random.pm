# Quantum::Random - Optical quantum random number generator front-end
# Copyright (c) 2004 Adam J. Foxson. All rights reserved.

# This program is free software; you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation; either version 2 of the License, or (at your option) any later
# version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.

package Quantum::Random;

use strict;
use Exporter;
use vars qw($VERSION @ISA @EXPORT_OK $Error);

local $^W = 1;

@ISA = qw(Exporter);
@EXPORT_OK = qw(quantum_random);
$VERSION = '0.01';
#($VERSION) = '$Revision$' =~ /\s+(\d+\.\d+)\s+/;

sub quantum_random {
	my ($quantity, $maximum) = @_;

	$Error = '';

	unless (defined $quantity and defined $maximum) {
		$Error = 'ERR00: Quantity and Maximum must be specified';
		return;
	}

	if ($quantity < 1 || $quantity > 1000) {
		$Error = 'ERR01: Quantity must be >= 1 and <= 1000';
		return;
	}
	elsif ($maximum < 1 || $maximum > 10000) {
		$Error = 'ERR02: Maximum must be >= 1 and <= 10000';
		return;
	}

	my $response = trivial_http_get($quantity, $maximum);
	return if not defined $response;

	if ($response =~ m!<h3>Download random numbers</h3>([^<]+)\s</td>!) {
		return split /\s/, $1;
	}
	else {
		$Error = 'ERR03: Unable to parse response from random number server';
		return;
	}
}

# Adapted from LWP::Simple
sub trivial_http_get {
	my ($quantity, $maximum) = @_;

	my $url = "/examples/servlet/webqrng?nbRnd=$quantity&upLimit=$maximum";

	require IO::Socket;
	local $^W = 0;

	my $sock = IO::Socket::INET->new(
		PeerAddr => 'qrng.unige.ch',
		PeerPort => 80,
		Proto    => 'tcp',
		Timeout  => 15);

	if (not defined $sock) {
		$Error = 'ERR04: Unable to connect to random number server';
		return undef;
	}

	$sock->autoflush;

	print $sock join("\015\012" =>
		"GET $url HTTP/1.0",
		"Host: qrng.unige.ch",
		"User-Agent: Quantum::Random/$VERSION",
		"", "");

	my $buf = "";
	my $n;
	1 while $n = sysread($sock, $buf, 8 * 1024, length($buf));
	unless (defined $n) {
		$Error = 'ERR05: Unable to read response from random number server';
		return undef;
	}

	if ($buf =~ m,^HTTP/\d+\.\d+\s+(\d+)[^\012]*\012,) {
		my $code = $1;
		unless ($code == 200) {
			$Error = 'ERR06: Unable to successfully retrieve response ' .
				'from random number server';
			return undef;
		}
		$buf =~ s/.+?\015?\012\015?\012//s; # zap header
		return $buf;
	}

	$Error = 'ERR07: Unknown response from random number server';
	return undef;
}

1;
