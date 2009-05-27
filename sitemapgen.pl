#!/usr/bin/perl -w

use File::Slurp;
use Date::Manip;

my $dir = "/var/comics.dp.cx";
my $baseurl = "http://comics.dp.cx";

my @files = read_dir($dir);
@files = grep(/html$/, @files);

@files = sort { $b cmp $a } @files;
@files = sort { -M "$dir/$a" <=> -M "$dir/$b" } @files;

open(SITEMAP,">$dir/sitemap.xml") || die "Can't open sitemap: $!";
print SITEMAP <<END;
<?xml version="1.0" encoding="UTF-8"?>
<urlset xmlns="http://www.google.com/schemas/sitemap/0.84">
END
foreach my $file (@files) {
	my $err;
	my $lastmod = -M "$dir/$file";
	$lastmod *= 86400;
	$lastmod = UnixDate(DateCalc("today", "- ${lastmod} seconds",\$err), '%O%z');
	$lastmod =~ s/(\d{2})(\d{2})$/$1:$2/;	# make sure it conforms to google
print SITEMAP <<END;
	<url>
		<loc>$baseurl/$file</loc>
		<lastmod>$lastmod</lastmod>
END
	if ($file =~ /(index|archive)/) {
		print SITEMAP "\t\t<changefreq>daily</changefreq>\n";
		print SITEMAP "\t\t<priority>1</priority>\n";
	} else {
		print SITEMAP "\t\t<changefreq>never</changefreq>\n";
		print SITEMAP "\t\t<priority>0.6</priority>\n";
	}
print SITEMAP <<END;
	</url>
END
}
print SITEMAP <<END;
</urlset>
END
close(SITEMAP);
