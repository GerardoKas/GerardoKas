use File::Find;
use File::Basename;
use strict;
use warnings;
use utf8;
require HTML::HeadParser;
#use Encode qw( encode decode );

my $path = shift @ARGV;
if ( !-d $path || $path eq "" ) {
    die
"NECESITO UN NOMBRE DE DIRECTORIO COMO PARAMETRO (TRY DRAG & DROP WITH A BAT BETWEEN)\n$!";
}
my $PROJ_NAME = shift @ARGV;
if ( $PROJ_NAME eq "" ) { $PROJ_NAME = "Proyecto A la deriva" }
print $PROJ_NAME;

#for debug
my $problems = 1;
my $normal   = 1;
#datos de entraaada
my @files  = ();
#my $f      = "";
my $titulo = "";
my $tmpPath   = $path;
my $EXTES   = "HTML|HTM|MHT|TXT";
my $NOEXTES = "JPG|GIF|PNG|CSS|ICO";

( $normal == 1 ) ? print "PATH:$path\n"      : 0;
( $normal == 1 ) ? print "PROJ:$PROJ_NAME\n" : 0;

#busca ficheros y los pone en 2 listas hhc y hhk
#crea hhp.
#guarda los archivos en el directorio origen

my $FILE_HHP   = "";
my $FILE_HHK   = "";
my $FILE_HHC   = "";
my $wintitle   = "Webs Compiladas By Diponto";
my $BASE       = "<HTML><HEAD></HEAD><BODY>%REPLACE%</BODY></HTML>";
my $INSERT_HHC = <<END;
<OBJECT type="text/site properties">
<param name="Window Styles" value="0x227">
<param name="ImageType" value="Folder">
</OBJECT>
END

############do DE FIND THINGBLOCK
my $CAD_FILES = "";
$CAD_FILES = "<UL>";
find( \&busca, $path );
$CAD_FILES .= "</UL>";
###########3

$FILE_HHP = HacerHHP(@files);
$FILE_HHK = $BASE;
$FILE_HHK =~ s/%REPLACE%/$CAD_FILES/;
$FILE_HHC = $BASE;
$FILE_HHC =~ s/%REPLACE%/$INSERT_HHC $CAD_FILES/;

open( SV, ">$path/$PROJ_NAME.hhp" ) or die "CANT DO";
binmode( SV, ":utf8" );
print SV $FILE_HHP;
close SV;
open( SV, ">$path/$PROJ_NAME.hhk" ) or die "CANT DO";
binmode( SV, ":utf8" );
print SV $FILE_HHK;
close SV;
open( SV, ">$path/$PROJ_NAME.hhc" ) or die "CANT DO";
binmode( SV, ":utf8" );
print SV $FILE_HHC;
close SV;
print "\nDONE ok From Perl.\nAnd Now to hhc.exe...\n";


exit;
#FIN-----------------------------------------------------
#FIN
#################################-------------------------------------------
sub busca {
    #my $f        =shift @_;
    my $fileName = $File::Find::name;
    $fileName =~ s/\//\\/g;
my $file=RemoveRaiz($fileName);
    if ( $_ =~ /\.($EXTES)$/i ) {
        mEcho("Esla extension");
        push(@files,$fileName);
        ParaCadaUno($fileName);
    } elsif ( $_ =~ /\.($NOEXTES)$/i ) {
        mEcho("EsAlternativo");
        push( @files, $fileName );
    } else {
        mEcho( "EsNoDoy:" . $file . "\n" );
        return;
    }
}
#######################------------------------------------------------------
sub ParaCadaUno {
    my $i = shift;
  #  ( $problems > 0 ) ? mEcho("\$i=$i\n") : 0;

    #si s un archivo web
    if ( $i =~ /\.(HTML?|MHT|EML)$/i ) {
        $titulo = getTitulo($i);

      ( $normal > 0 ) ? mEcho( "TitloOriginal(" . $titulo . ")" ) : 0;
    }
    #si el titulo esta en blanco
    if ( $titulo =~ /^[\s]*$/ ) {  
        $titulo = RemoveRaiz($i);
        my $p = rindex( $i, "\\" );
        $titulo = substr( $i, $p + 1, length($i) );
        ( $normal > 0 ) ? mEcho("EltituloeselNombre:($titulo)"): 0;
    }
    $CAD_FILES .= "<li><OBJECT TYPE=\"text/sitemap\">\n";
    $CAD_FILES .= "<PARAM NAME=\"Name\" VALUE=\"$titulo\">\n";
    $CAD_FILES .= "<PARAM NAME=\"Local\" VALUE=\"" . RemoveRaiz($i) . "\">\n";
    $CAD_FILES .= "</OBJECT>\n";

}
#######--------------------------------------------------------------------
sub getTitulo {
    my $d = shift;
    my $p = HTML::HeadParser->new;
    my $head;
    open( INP, "<$d" ) or die "CANT open FOR READ";
    do {
        $head = <INP>;
    } while not( $head =~ /<title>/i );
    close INP;
    $p->parse($head);
    $titulo = $p->header('title');    # to access <title>....</title>
    return $titulo;
}

sub HacerHHP {
    my $default = '""';               #RemoveRaiz($fs[0]);
    my $temp    = <<END;
[OPTIONS]
Compatibility=1.1
Default Window=Main
Default topic=$default
Compiled file=$PROJ_NAME.chm
Contents file=$PROJ_NAME.hhc
Index file=$PROJ_NAME.hhk
Error log file=$path\log.txt
Display compile progress=Yes
Full-text search=Yes
Language=0xC0A Espa�ol (alfabetizaci�n internacional)
Title=$wintitle
[WINDOWS]
Main="$wintitle","$PROJ_NAME.hhc","$PROJ_NAME.hhk","$default","$default",,,,,0x420,180,0x385e,[80,60,720,540],,,,0,,,
[FILES]
END
my $f="";
@files=sort(@files);
    foreach my $i (@files) {
        if ( -f $i ) {
            $f = RemoveRaiz($i);
            mEcho($f);
            
            $temp .= "\n" . $f;
        }
    }
    return $temp;
}
###----------------------------------------------------
sub RemoveRaiz {
    my $f = shift @_;
    ( $problems > 0 ) ? mEcho("\n\n$f\n\n") : 0;
    $f       =~ tr!\\!\/!;    #Cambiar Barras Win p Barras Unix
    $tmpPath =~ tr!\\!\/!;    #Cambiar en el Path tb

    $f =~ s!$tmpPath\/!!;     #Sustituir el BasePath por Nada
    $f =~ tr!\/!\\!;          #Volver a Barras de Win
    return $f;
}

sub mEcho {
    my $e = shift;

    # open( ER, ">>$log" );
    # print ER "$e\n[$!]\n";
    # close ER;
    print "$e\n";
}
__END__

 		#$encoded = HTML::Entities::encode($a);
     	#$titulo=HTML::Entities::encode($titulo);

		 
		  my $decoded = decode('UTF-8', $titulo);    # <-- This was missing.
		  $titulo = encode('cp1252', $decoded);
		 }

   # my $decode = decode( 'UTF-8', $titulo );    # <-- This was missing.
        #$titulo = encode( 'unicode', $decode );
       