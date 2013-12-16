#!/usr/bin/perl

# Alex Paciorkowski
# Written Oct 30, 2013

use strict;
use warnings;
use CGI;

my $q = new CGI;

print $q->header();

# Output stylesheet, heading
output_top($q);

if ($q->param()) {
        # Params defined, therefore form already submitted
        display_results($q);
} else {
        # It's all new, so display the form
        output_form($q);
}

# Output footer and end html
output_end($q);

exit 0;

# Outputs the start html tag, stylesheet and heading
sub output_top {
        my ($q) = @_;
        print $q->start_html(
                -title => 'SOLVE-Brain 1.0.1 Gene Annotation',
                -script => '/jquery/jquery.js',
                -script => '/jquery/jquery_tablesorter/jquery.tablesorter.js',
                -bgcolor => 'white',
                -style => {
                        -code => '
                                /*Stylesheet */
                                body {
                                        font-family: arial, sans-serif;
                                        }
                                h2 {
                                        color: darkblue;
                                        border-bottom: 1pt solid;
                                        width:100%;
                                        }
                                div {
                                        text-align: right;
                                        color: steelblue;
                                        border-top: darkblue 1pt solid;
                                        margin-top: 4pt;
                                        }
                                th {
                                        text-align: right;
                                        padding: 2pt;
                                        vertical-align: top;
                                        }
                                td {
                                }
sub output_form {
        my ($q) = @_;
        my @genelist;
        print $q->start_form(
                -name => 'genelist',
                -method => 'POST',
        );
        print $q->start_table;
        print $q->Tr(
                        print $q->h2("Gene Annotation"));
        }
# Outputs footer and end html tags
sub output_end {
        my ($q) = @_;
        print $q->div("SOLVE-Brain 1.0.1 Paciorkowski Lab (c)2013");
        print $q->end_html;
}
# Displays results
sub display_results {
        my $genelist = $q->param('genes');
        my @genes = split (/\s+/,$genelist);
        foreach my $gene(@genes) {
                print "<tr><td>$gene</td>
               <td>
                        <a href='http://www.brain-map.org/search/index.html?query=$gene&fa=false&e_sp=t&e_ag=t&e_tr=t' target='_blank'>
                        <img src='/images/aibs.png' width=75px /></a>
               </td>
               <td>
                        <a href='http://www.ncbi.nlm.nih.gov/pubmed/?term=$gene AND brain' target='_blank'>
                        <img src='/images/PubMed.png' /></a>
               </td>
               <td>
                        <a href='http://lynx.ci.uchicago.edu/gene/?geneid=$gene' target='_blank'>
                        <img src='/images/lynx.png' width=75px /></a>
               </td>
               <td>
                        <a href='http://www.informatics.jax.org/searchtool/Search.do?query=$gene&submit=Quick+Search' target='_blank'>
                        <img src='/images/mgi.png' width=75px /></a>
               </td>
               <td>
                        <a href='http://genome.ucsc.edu/cgi-bin/hgTracks?org=human&db=hg19&singleSearch=knownCanonical&position=$gene' target='_blank'>
                        <img src='/images/UCSC.png' width=75px /></a>
               </td></tr><br /><br />";
        }
        print "<br />";
}
# Outputs form
sub output_form {
        my ($q) = @_;

                                        padding: 2pt;
                                        vertical-align: top;
                                        }
                                /* End stylesheet */
                                ',
                        },
                );
                print "<img src='/images/SOLVE_brain_logo.jpg' />";
                print $q->h2("Gene Annotation");
        }

# Outputs footer and end html tags
sub output_end {
        my ($q) = @_;
        print $q->div("SOLVE-Brain 1.0.1 Paciorkowski Lab (c)2013");
        print $q->end_html;
}

# Outputs form
sub output_form {
        my ($q) = @_;
        my @genelist;
        print $q->start_form(
                -name => 'genelist',
                -method => 'POST',
        );

        print $q->start_table;
        print $q->Tr(
                        print $q->h2("Gene Annotation"));
        }

# Outputs footer and end html tags
sub output_end {
        my ($q) = @_;
        print $q->div("SOLVE-Brain 1.0.1 Paciorkowski Lab (c)2013");
        print $q->end_html;
}

# Outputs form
sub output_form {
        my ($q) = @_;
        my @genelist;
        print $q->start_form(
                -name => 'genelist',
                -method => 'POST',
        );

        print $q->start_table;
        print $q->Tr(
                $q->td('Gene list:'),
                $q->td(
                        $q->textarea(-name => "genes", -size => 40, -rows => 4)
                )
        );
        print $q->Tr(
                $q->td($q->submit(-value => 'Submit')),
                $q->td('&nbsp;')
        );
        print $q->end_table;
        print $q->end_form;
}
