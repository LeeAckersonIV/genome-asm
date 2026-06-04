#!/usr/bin/perl
use strict;
use warnings;
use Getopt::Long;

my ( $gaf_f, $patch_f, $map_f, $verbose );
GetOptions(
    'gaf=s'   => \$gaf_f,
    'patch=s' => \$patch_f,
    'map=s'   => \$map_f,
    'verbose' => \$verbose
);

# --- 1. Map Load ---
my %u4_to_u1;
open my $mf, '<', $map_f or die $!;
while (<$mf>) {
    chomp;
    my ( $u, $p ) = split(/\t/);
    $u4_to_u1{$u} = $p;
}
close $mf;

# --- 2. Patch Load ---
my %patches;
my %replaced_names;
my %old_to_new;
my %new_to_old;
my %deleted_assignments;

open my $pf, '<', $patch_f or die $!;
<$pf>;
while (<$pf>) {
    chomp;
    my ( $olds, $path, $new_n, $assign ) = split(/\t/);

    foreach my $old_name ( split( ';', $olds ) ) {
        $replaced_names{$old_name} = 1;
        push @{ $old_to_new{$old_name} }, $new_n
          unless grep { $_ eq $new_n } @{ $old_to_new{$old_name} || [] };
        push @{ $new_to_old{$new_n} }, $old_name
          unless grep { $_ eq $old_name } @{ $new_to_old{$new_n} || [] };
    }

    # If it is a deletion, save the assignment and skip the rest of the loop
    if ( uc($new_n) eq 'DELETE' || uc($path) eq 'DELETE' ) {
        foreach my $old_name ( split( ';', $olds ) ) {
            $deleted_assignments{$old_name} = $assign;
        }
        next;
    }

    push @{ $patches{$new_n} }, { path => $path, assign => $assign };

}
close $pf;

# --- 3. GAF Load & Inventory ---
my @gaf_data;
my %u4_metadata;
my %all_known_u4s;

open my $gf, '<', $gaf_f or die $!;
my $header = <$gf>;
while (<$gf>) {
    chomp;
    next if /^\s*$/;
    my ( $name, $path, $assign ) = split(/\t/);
    if ( !$path ) { ( $name, $path, $assign ) = split( /\s+/, $_, 3 ); }

    push @gaf_data, { name => $name, path => $path, assign => $assign };

    my @nodes = parse_nodes_with_dir($path);
    foreach my $node_w_dir (@nodes) {
        my $id = $node_w_dir;
        $id =~ s/[<>]//g;
        if ( $id =~ /^utig4/ ) {
            $all_known_u4s{$id} = 1;
            if ( !$u4_metadata{$id} || $name !~ /unused/ ) {
                $u4_metadata{$id} = $assign;
            }
        }
    }
}
close $gf;

# --- 4. Mark Usage ---
my %used_by_patches;
foreach my $new_name ( keys %patches ) {
    foreach my $p_entry ( @{ $patches{$new_name} } ) {
        mark_usage( $p_entry->{path}, \%used_by_patches, \%u4_to_u1,
            \%all_known_u4s, $new_name );
    }
}

# --- 5. Output Generation ---
print $header;
my %printed_u4s;

foreach my $pn ( sort keys %patches ) {
    foreach my $p_entry ( @{ $patches{$pn} } ) {
        print join( "\t", $pn, $p_entry->{path}, $p_entry->{assign} ), "\n";
        foreach my $node ( parse_nodes_with_dir( $p_entry->{path} ) ) {
            my $id = $node;
            $id =~ s/[<>]//g;
            $printed_u4s{$id} = 1 if $id =~ /^utig4/;
        }
    }
}

foreach my $line (@gaf_data) {
    if ( $replaced_names{ $line->{name} } ) {

        if ( exists $deleted_assignments{ $line->{name} } ) {
            my $del_assign = $deleted_assignments{ $line->{name} };

    # Only overwrite if the user provided a real assignment.
    # If it's "DELETE", "NA", or blank, keep the original GAF assignment intact!
            if (   defined $del_assign
                && uc($del_assign) ne 'DELETE'
                && uc($del_assign) ne 'NA'
                && $del_assign !~ /^\s*$/ )
            {
                foreach my $n ( parse_nodes_with_dir( $line->{path} ) ) {
                    my $id = $n;
                    $id =~ s/[<>]//g;
                    $u4_metadata{$id} = $del_assign if $id =~ /^utig4/;
                }
            }
            else {
                $del_assign =
                  "Original GAF Assignment";    # For verbose logging only
            }

            print STDERR
"[VERBOSE] PATH DELETED: '$line->{name}'. Orphaned nodes will use: '$del_assign'.\n"
              if $verbose;
            next;
        }

        my @replacing_patches = @{ $old_to_new{ $line->{name} } };
        my $action            = "REPLACED";
        my $new_names_str     = join( "', '", @replacing_patches );

        if ( scalar(@replacing_patches) > 1 ) {
            $action = "SPLIT";
        }
        else {
            my $the_patch = $replacing_patches[0];
            if ( scalar( @{ $new_to_old{$the_patch} } ) > 1 ) {
                $action = "MERGED";
                my $others = join( "', '",
                    grep { $_ ne $line->{name} } @{ $new_to_old{$the_patch} } );
                $new_names_str .= "' (combined with '$others')";
            }
        }

        print STDERR
"[VERBOSE] PATH $action: '$line->{name}' was replaced by patch(es) '$new_names_str'\n"
          if $verbose;
        next;
    }

    my @nodes_w_dir = parse_nodes_with_dir( $line->{path} );

    if ( $line->{name} =~ /unused/ ) {
        my $id = $nodes_w_dir[0];
        $id =~ s/[<>]//g;
        if ($id) {
            if ( !$used_by_patches{$id} ) {
                print
                  join( "\t", $line->{name}, $line->{path}, $line->{assign} ),
                  "\n";
                $printed_u4s{$id} = 1;
            }
            else {
                print STDERR
"[VERBOSE] NODE REACTIVATED: Unused node '$id' from '$line->{name}' is now used by patch '$used_by_patches{$id}'\n"
                  if $verbose;
            }
        }
    }
    else {
        my $is_covered = 0;
        foreach my $pn ( keys %patches ) {
            foreach my $p_entry ( @{ $patches{$pn} } ) {
                if ( check_overlap( $line->{path}, $p_entry->{path} ) ) {
                    $is_covered = 1;
                    last;
                }
            }
            last if $is_covered;
        }

        if ( !$is_covered ) {
            print join( "\t", $line->{name}, $line->{path}, $line->{assign} ),
              "\n";
            foreach my $n (@nodes_w_dir) {
                my $id = $n;
                $id =~ s/[<>]//g;
                $printed_u4s{$id} = 1 if $id =~ /^utig4/;
            }
        }
    }
}

foreach my $u4 ( sort keys %all_known_u4s ) {
    if ( !$printed_u4s{$u4} && !$used_by_patches{$u4} ) {
        print STDERR
"[VERBOSE] NODE ORPHANED: '$u4' was left completely unconnected and swept into unused.\n"
          if $verbose;
        my $a = $u4_metadata{$u4} || "UNKNOWN";
        printf( "%s_unused_%s\t>%s\t%s\n", lc($a), $u4, $u4, $a );
        $printed_u4s{$u4} = 1;
    }
}

# --- Subroutines ---

sub parse_nodes_with_dir {
    my $p = shift;
    return () unless $p;
    $p =~ s/\[.*?\]//g;
    return grep { $_ ne '' } split( /(?=[<>])/, $p );
}

sub reverse_complement {
    my @nodes = @_;
    my @rev;
    foreach my $n ( reverse @nodes ) {
        my $dir     = substr( $n, 0, 1 );
        my $id      = substr( $n, 1 );
        my $new_dir = ( $dir eq '>' ) ? '<' : '>';
        push @rev, $new_dir . $id;
    }
    return @rev;
}

sub mark_usage {
    my ( $path, $ref, $map, $known_u4s, $patch_name ) = @_;
    my $has_utig1 = 0;

    foreach my $node_w_dir ( parse_nodes_with_dir($path) ) {
        my $id = $node_w_dir;
        $id =~ s/[<>]//g;
        if ( $id =~ /^utig4/ ) {
            $ref->{$id} = $patch_name;
        }
        elsif ( $id =~ /^utig1/ ) {
            $has_utig1 = 1;
        }
    }

    if ($has_utig1) {
        foreach my $u4 ( keys %$known_u4s ) {
            if ( exists $map->{$u4} && check_overlap( $map->{$u4}, $path ) ) {
                $ref->{$u4} = $patch_name;
            }
        }
    }
}

sub check_overlap {
    my ( $query_path, $target_path ) = @_;

    my @q = map { s/_\d+$//gr } parse_nodes_with_dir($query_path);
    my @t = map { s/_\d+$//gr } parse_nodes_with_dir($target_path);
    return 0 unless @q && @t;

    my %t_bases;
    foreach my $tn (@t) {
        my $base = $tn;
        $base =~ s/[<>]//g;
        $t_bases{$base} = 1;
    }
    my $shares_nodes = 0;
    foreach my $qn (@q) {
        my $base = $qn;
        $base =~ s/[<>]//g;
        if ( $t_bases{$base} ) {
            $shares_nodes = 1;
            last;
        }
    }
    return 0 unless $shares_nodes;

    my @q_rev    = reverse_complement(@q);
    my $max_hits = 0;

    my %t_idx;
    for my $j ( 0 .. $#t ) {
        push @{ $t_idx{ $t[$j] } }, $j;
    }

    foreach my $q_ref ( \@q, \@q_rev ) {
        my $q_len = scalar(@$q_ref);
        for ( my $i = 0 ; $i < $q_len ; $i++ ) {
            last if ( $q_len - $i ) <= $max_hits;

            my $q_node = $q_ref->[$i];
            next unless $t_idx{$q_node};

            foreach my $j ( @{ $t_idx{$q_node} } ) {
                my $len = 0;
                while ($i + $len < $q_len
                    && $j + $len <= $#t
                    && $q_ref->[ $i + $len ] eq $t[ $j + $len ] )
                {
                    $len++;
                }
                if ( $len > $max_hits ) {
                    $max_hits = $len;
                }
            }
        }
    }

    my $threshold = ( scalar(@q) > 10 ) ? 0.9 : 0.6;
    return ( $max_hits / scalar(@q) ) >= $threshold;
}
