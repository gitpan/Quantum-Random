use strict;
use Test;
use Quantum::Random qw(quantum_random);

BEGIN {plan tests => 38}

if (!eval { require Socket; Socket::inet_aton('qrng.unige.ch') }) {
	for (1..38) {
		print "ok $_ # skip - Cannot connect to qrng.unige.ch\n";
	}
}
else {
	{
		my @numbers = quantum_random(10, 5);

		if (not @numbers) {
			ok(0) for 1..11;
		}
		else {
			ok(scalar @numbers == 10);
			for my $number (@numbers) {
				ok(length($number) == 1);
			}
		}
	}

	{
		my @numbers = quantum_random(5, 500);

		if (not @numbers) {
			ok(0) for 1..6;
		}
		else {
			ok(scalar @numbers == 5);
			for my $number (@numbers) {
				ok(length($number) <= 3);
			}
		}
	}

	{
		my @numbers = quantum_random(20, 10000);

		if (not @numbers) {
			ok(0) for 1..21;
		}
		else {
			ok(scalar @numbers == 20);
			for my $number (@numbers) {
				ok(length($number) <= 5);
			}
		}
	}
}
