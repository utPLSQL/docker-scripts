#!/bin/bash
set -e

if [ "$ORACLE_OTN_USER" == "" ] || [ "$ORACLE_OTN_PASSWORD" == "" ]; then
    echo "Error: Oracle OTN username/password not specified."
    exit 1
fi

PRODUCT=""

# Call the casperjs script to return the download url.
# Then download the file using curl.
downloadFile() {
    downloadUrl=$(exec casperjs download.js $ORACLE_OTN_USER $ORACLE_OTN_PASSWORD $1 $2)
    downloadUrl=${downloadUrl%$'\r'}
    echo "DownloadURL: $downloadUrl"
    curl -o $3 -L "$downloadUrl"
}

#############################
########### START ###########
#############################

while getopts "p:" OPTNAME; do
    case "${OPTNAME}" in
        "p") PRODUCT="${OPTARG}" ;;
    esac
done

if [ "$PRODUCT" == "se12c" ]; then
    agreementUrl="http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html"
    downloadUrl="http://download.oracle.com/otn/linux/oracle12c/121020/linuxamd64_12102_database_se2_1of2.zip"
    outputFile=linuxamd64_12102_database_se2_1of2.zip
    downloadFile $agreementUrl $downloadUrl $outputFile
    agreementUrl="http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html"
    downloadUrl="http://download.oracle.com/otn/linux/oracle12c/121020/linuxamd64_12102_database_se2_2of2.zip"
    outputFile=linuxamd64_12102_database_se2_2of2.zip
    downloadFile $agreementUrl $downloadUrl $outputFile
    exit 0
fi

if [ "$PRODUCT" == "ee12c" ]; then
    agreementUrl="http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html"
    downloadUrl="http://download.oracle.com/otn/linux/oracle12c/121020/linuxamd64_12102_database_1of2.zip"
    outputFile=linuxamd64_12102_database_1of2.zip
    downloadFile $agreementUrl $downloadUrl $outputFile
    agreementUrl="http://www.oracle.com/technetwork/database/enterprise-edition/downloads/index.html"
    DOWNLOAD_URL="http://download.oracle.com/otn/linux/oracle12c/121020/linuxamd64_12102_database_2of2.zip"
    outputFile=linuxamd64_12102_database_2of2.zip
    downloadFile $agreementUrl $downloadUrl $outputFile
    exit 0
fi

if [ "$PRODUCT" == "xe11g" ]; then
    agreementUrl="http://www.oracle.com/technetwork/database/database-technologies/express-edition/downloads/index.html"
    downloadUrl="https://edelivery.oracle.com/akam/otn/linux/oracle11g/xe/oracle-xe-11.2.0-1.0.x86_64.rpm.zip"
    outputFile=oracle-xe-11.2.0-1.0.x86_64.rpm.zip
    downloadFile $agreementUrl $downloadUrl $outputFile
    exit 0
fi

if [ "$PRODUCT" == "sqlcl" ]; then
    agreementUrl="http://www.oracle.com/technetwork/developer-tools/sqlcl/downloads/index.html"
    downloadUrl="https://download.oracle.com/otn/java/sqldeveloper/sqlcl-18.3.0.259.2029.zip"
    #downloadUrl="https://download.oracle.com/otn/java/sqldeveloper/sqlcl-19.2.1.206.1649.zip"
    outputFile=sqlcl-18.3.0.259.2029.zip
    downloadFile $agreementUrl $downloadUrl $outputFile
    exit 0
fi

echo "Error: invalid product: $PRODUCT"
exit 1
