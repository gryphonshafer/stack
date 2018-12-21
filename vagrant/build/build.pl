#!/usr/bin/env perl
use exact;
use FindBin;
use YAML::XS 'LoadFile';
use Template;

my $settings = LoadFile( $FindBin::Bin . '/settings.yml' );
my $tt       = Template->new({ ABSOLUTE => 1 }) || die $Template::ERROR;

sub merge_settings {
    my ( $merge, $source, $project ) = @_;
    $merge = YAML::XS::Load( YAML::XS::Dump($merge) );

    if ( ref $merge eq 'HASH' ) {
        for my $key ( keys %{$source} ) {
            if ( exists $merge->{$key} and ref $merge->{$key} eq 'HASH' and ref $source->{$key} eq 'HASH' ) {
                merge_settings( $merge->{$key}, $source->{$key} );
            }
            else {
                $merge->{$key} = YAML::XS::Load( YAML::XS::Dump( $source->{$key} ) );
            }
        }
    }
    elsif ( ref $merge eq 'ARRAY' ) {
        push( @$source, @$merge );
    }

    $merge->{project} = $project;
    return $merge;
}

for my $project (
    map {
        merge_settings( $settings->{configs}{$_}, $settings->{universal}, $_ )
    } keys %{ $settings->{configs} }
) {
    my $dir = $FindBin::Bin . '/../configs/' . $project->{project};
    mkdir $dir;

    $tt->process( $FindBin::Bin . '/Vagrantfile.tt', $project, \my $output ) or die $tt->error;

    $output =~ s/^\s+$//msg;
    open( my $output_out, '>', $dir . '/Vagrantfile' ) or die $!;
    print $output_out $output;

    my $hosts;
    if ( open( my $hosts_in, '<', $dir . '/hosts' ) ) {
        while ( <$hosts_in> ) {
            chomp;
            s/(^\s+|\s+$)//g;
            my ( $ip, @hosts ) = split(/\s+/);
            $hosts->{$ip}{$_} = 1 for (@hosts);
        }
    }
    for ( @{ $project->{hosts} } ) {
        my ($hostname) = keys %$_;
        $hosts->{ $_->{$hostname}{network}{private_network} }{$hostname} = 1
            if ( $_->{$hostname}{network}{private_network} );
    }
    my $max = ( sort { $b <=> $a } map { length } keys %$hosts )[0];
    open( my $hosts_out, '>', $dir . '/hosts' ) or die $!;
    say $hosts_out join( "\n",
        map {
            sprintf( '%-' . $max . 's %s', $_, join( ' ', sort keys %{ $hosts->{$_} } ) );
        } sort keys %$hosts
    );
}
