## See: https://www.ebi.ac.uk/seqdb/confluence/display/EnsGen/\
## Setting+up+a+personal+EnsemblGenomes+server+on+gunpowder

# May as well ssh gunpowder now
. /nfs/public/rw/ensembl/perlbrew/setup_gunpowder_perl.sh



ensembl_version=85
eg_version=$(echo $ensembl_version-53|bc)

cd /homes/dbolser/EG_Places/Devel/Web/

mkdir Test_Ensembl_$ensembl_version
cd    Test_Ensembl_$ensembl_version

## Set up our git tools
git clone https://github.com/Ensembl/ensembl-git-tools.git
export PATH=$PWD/ensembl-git-tools/bin:$PATH

## Grab what we need for Ensembl web
git ensembl --clone --branch release/$ensembl_version public-web

## Grab what we need for Ensembl Plants
git ensembl --clone --branch release/eg/$eg_version eg-plants

## Server configs...
git clone git@github.com:EnsemblGenomes/eg-web-ensembl-configs.git


## Move the EG specific config on top of the Ensembl config
cp -rv eg-web-ensembl-configs/my-plugins .
cp -rv eg-web-ensembl-configs/eg-conf/* ensembl-webcode/conf/
mkdir logs

## PORT
emacs my-plugins/conf/SiteDefs.pm

## SUNDRIES
emacs my-plugins/conf/ini-files/MULTI.ini


./eg-web-common/utils/drupal_import_home.pl -d plants -r 32
./eg-web-common/utils/drupal_import_species.pl -d plants
