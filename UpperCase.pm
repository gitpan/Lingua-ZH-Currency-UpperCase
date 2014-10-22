# $Id$
package Lingua::ZH::Currency::UpperCase;

use strict;
use vars qw( %dig @integer_unit @float_unit $VERSION @ISA @EXPORT @EXPORT_OK);

require Exporter;

@ISA = qw(Exporter AutoLoader);
@EXPORT = qw( chinese_currency_uc );
$VERSION = '0.01'; #sprintf("%d.%02d", q$Revision$ =~ /(\d+)\.(\d+)/);

%dig = ( 0 => '��',	1 => 'Ҽ',	2 => '��',	3 => '��',	4 => '��',
		 5 => '��',	6 => '½',	7 => '��',	8 => '��',	9 => '��' );
our @integer_unit = ( 'Բ','ʰ','��','Ǫ','��','ʰ','��','Ǫ','��','ʰ','��','Ǫ' );
our @float_unit = ( '��','��' );

=head1 NAME

Lingua::ZH::Currency::UpperCase - Convert Currency Numbers to Chinese UpperCase Format

=head1 SYNOPSIS

  use Lingua::ZH::Currency::UpperCase;
  print chinese_currency_uc( 2504.39 );

=head1 DESCRIPTION

The main subroutine get a number and give a chinese string which has been converted as currency
upper case for finance processing. As Check or Invoce that need.

	0 : 0
	0.03 : ������
	1.04 : ҼԲ������
	-12.00 : Ҽʰ��Բ��
	102.15 : Ҽ���㷡ԲҼ�����
	2004 : ��Ǫ����Բ��
	50142 : ������Ҽ����ʰ��Բ��
	400102 : ��ʰ����Ҽ���㷡Բ��
	50000045.01 : ��Ǫ������ʰ��Բ��Ҽ��
	123456789.00 : Ҽ�ڷ�Ǫ������ʰ����½Ǫ��۰�ʰ��Բ��
	9876543219876.123 : 9876543219876.123

=head2 chinese_currency_uc( $number )

	my $words = chinese_currency_uc( 123.45 );
	my $words = chinese_currency_uc( 123.45 );

The number is only 12 interger length and the float will restrict to 2 length,
ortherwise it just return the orignal number which passed in. If the number is
negotive, we just ignore the '-'.

chinese_currency_uc is auto exported.

=cut

sub chinese_currency_uc {
	my $given = shift;
	return 0 if ( not defined $given or $given == 0 );

	my $number = sprintf( "%.2f", $given );

	# split the number into two parts
	my ( $integer, $float ) = split(/\./, $number );
	return $given if length($integer) > 12 or length($float) > 2;
	
    # parse the interger
    my @chunks; push @chunks, $1 while ($integer =~ s/(\d{1,4})$//g);
	my $string = join ( '', 
						reverse
						map { _convert_integer_every_four_digits( $chunks[$_], $_*4 ) }
							( 0 .. $#chunks )
				 );
	
	# parse the float as needed
	unless ( $float == 0 ){
		my $count = -1;
		$string .= join ( '',
						  map {	$count++; ( $_ == 0 ) ? $_ : $dig{$_}.$float_unit[ $count ]; }
						  split( //, $float )
					);
		$string =~ s/0{1,}$//g;

	# or just append the word
	}else{
		$string .= '��';
	}	

	# make the temp '0' or '000' like to be one chinese word
	$string =~ s/0{1,}/$dig{0}/g;

	# here we done
	return $string;
}

=head2 _convert_integer_every_four_digits( $number, $start_point )

here the $number is a number which maxlength is 4. The $start_point is an array index refer
to @integer_unit. Returns a string which temporily converted, and contains some alpha number
0 to suit later handling. 

It is the private subroutine, so just leave it be.

=cut

sub _convert_integer_every_four_digits {
	my $number = shift;
	my $start = shift;
	
	my $count = $start - 1;
	
	my $string = $number;
	unless ( $number == 0 ){
		$string = join ('',
				reverse map {
					$count++;
					( $_ == 0 )
						? $_
						: $dig{$_}.$integer_unit[ $count ];
				} reverse split(//,$number)
		);
		$string =~ s/0{1,3}$/$integer_unit[ $start ]/g;
	}
	
	return $string;
}

1;
__END__


=head1 SEE ALSO

L<Lingua::ZH::Numbers::Currency>

=head1 TODO

utf-8 encoding support. oop interface. if need, there also could be a module: Lingua::ZH::Currency::LowerCase;

=head1 AUTHORS

Chun Sheng E<lt>me@chunzi.orgE<gt>

=head1 COPYRIGHT

Copyright 2004 by Chun Sheng E<lt>me@chunzi.orgE<gt>.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

See L<http://www.perl.com/perl/misc/Artistic.html>

=cut
