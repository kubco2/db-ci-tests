#!/bin/bash

yum install -y mariadb-java-client mariadb-java-client-tests hamcrest junit mariadb-server

# command to obtain all tests in Java format
# find org -name '*Test.java' | cut -d'.' -f1 | tr '/' '.'
RUN_TESTS='org.mariadb.jdbc.CheckDataTest
org.mariadb.jdbc.ExecuteBatchTest
org.mariadb.jdbc.TransactionTest
org.mariadb.jdbc.ServerPrepareStatementTest
org.mariadb.jdbc.DateTest
org.mariadb.jdbc.MariaDbCompatibilityTest
org.mariadb.jdbc.ScrollTypeTest
org.mariadb.jdbc.StatementTest
org.mariadb.jdbc.LocalInfileDisableTest
org.mariadb.jdbc.GeneratedKeysTest
org.mariadb.jdbc.failover.SequentialFailoverTest
org.mariadb.jdbc.failover.AuroraFailoverTest
org.mariadb.jdbc.failover.BaseMultiHostTest
org.mariadb.jdbc.failover.LoadBalanceFailoverTest
org.mariadb.jdbc.failover.MonoServerFailoverTest
org.mariadb.jdbc.failover.CancelTest
org.mariadb.jdbc.failover.ReplicationFailoverTest
org.mariadb.jdbc.failover.OldFailoverTest
org.mariadb.jdbc.failover.AuroraAutoDiscoveryTest
org.mariadb.jdbc.failover.GaleraFailoverTest
org.mariadb.jdbc.LocalInfileInputStreamTest
org.mariadb.jdbc.ConnectionTest
org.mariadb.jdbc.UnicodeTest
org.mariadb.jdbc.AllowMultiQueriesTest
org.mariadb.jdbc.UpdateResultSetTest
org.mariadb.jdbc.ClientPreparedStatementParsingTest
org.mariadb.jdbc.DataTypeUnsignedTest
org.mariadb.jdbc.ResultSetUnsupportedMethodsTest
org.mariadb.jdbc.ResultSetTest
org.mariadb.jdbc.DatatypeTest
org.mariadb.jdbc.GeneratedTest
org.mariadb.jdbc.TimeoutTest
org.mariadb.jdbc.CancelTest
org.mariadb.jdbc.BaseTest
org.mariadb.jdbc.GiganticLoadDataInfileTest
org.mariadb.jdbc.DataSourcePoolTest
org.mariadb.jdbc.MariaDbClobTest
org.mariadb.jdbc.CallStatementTest
org.mariadb.jdbc.DistributedTransactionTest
org.mariadb.jdbc.MariaDbBlobTest
org.mariadb.jdbc.StoredProcedureTest
org.mariadb.jdbc.TimezoneDaylightSavingTimeTest
org.mariadb.jdbc.DataNTypeTest
org.mariadb.jdbc.CatalogTest
org.mariadb.jdbc.SslTest
org.mariadb.jdbc.DriverTest
org.mariadb.jdbc.GeometryTest
org.mariadb.jdbc.ComMultiPrepareStatementTest
org.mariadb.jdbc.ResultSetMetaDataTest
org.mariadb.jdbc.PasswordEncodingTest
org.mariadb.jdbc.DatatypeCompatibilityTest
org.mariadb.jdbc.PooledConnectionTest
org.mariadb.jdbc.ConnectionPoolTest
org.mariadb.jdbc.ErrorMessageTest
org.mariadb.jdbc.PreparedStatementTest
org.mariadb.jdbc.MultiTest
org.mariadb.jdbc.UpdateResultSetMethodsTest
org.mariadb.jdbc.DataTypeSignedTest
org.mariadb.jdbc.RePrepareTest
org.mariadb.jdbc.BlobTest
org.mariadb.jdbc.BasicBatchTest
org.mariadb.jdbc.MariaDbPoolDataSourceTest
org.mariadb.jdbc.DataSourceTest
org.mariadb.jdbc.StateChangeTest
org.mariadb.jdbc.DatabaseMetadataTest
org.mariadb.jdbc.JdbcParserTest
org.mariadb.jdbc.TruncateExceptionTest
org.mariadb.jdbc.internal.protocol.tls.HostnameVerifierImplTest
org.mariadb.jdbc.internal.util.DefaultOptionsTest
org.mariadb.jdbc.internal.util.dao.ClientPrepareResultTest
org.mariadb.jdbc.internal.util.UtilsTest
org.mariadb.jdbc.internal.util.SchedulerServiceProviderHolderTest
org.mariadb.jdbc.internal.util.buffer.BufferTest
org.mariadb.jdbc.UtilTest
org.mariadb.jdbc.ParserTest
org.mariadb.jdbc.FetchSizeTest
org.mariadb.jdbc.MariaDbDatabaseMetaDataTest
org.mariadb.jdbc.CollationTest
org.mariadb.jdbc.BigQueryTest
org.mariadb.jdbc.BufferTest
org.mariadb.jdbc.BooleanTest'

initialize_db() {
	systemctl start mariadb
	# remove anonymous, because tests fail otherwise
	mysql -e "DROP USER ''@'localhost'"
	mysql -e "DROP USER ''@'$(hostname)'"
	mysql -e "FLUSH PRIVILEGES"
	# create database on which tests operate
	mysql -e "CREATE DATABASE testj"
}

run_test() {
	local JAVA_PATH=.
	# import JUnit
	JAVA_PATH=$JAVA_PATH:/usr/share/java/hamcrest/core.jar
	JAVA_PATH=$JAVA_PATH:/usr/share/java/junit.jar
	# MariaDB
	JAVA_PATH=$JAVA_PATH:/usr/lib/java/mariadb-java-client.jar
	JAVA_PATH=$JAVA_PATH:/usr/lib/java/mariadb-java-client-tests.jar
	# other dependencies
	JAVA_PATH=$JAVA_PATH:/usr/share/java/slf4j/slf4j-api.jar
	JAVA_PATH=$JAVA_PATH:/usr/share/java/slf4j/slf4j-simple.jar
	JAVA_PATH=$JAVA_PATH:/usr/share/java/aws-sdk-java/aws-java-sdk-core.jar
	JAVA_PATH=$JAVA_PATH:/usr/share/java/aws-sdk-java/aws-java-sdk-rds.jar
	JAVA_PATH=$JAVA_PATH:/usr/lib/java/jna.jar
	JAVA_PATH=$JAVA_PATH:/usr/share/java/jna/jna-platform.jar
	JAVA_PATH=$JAVA_PATH:/usr/share/java/HikariCP.jar

	java -Xmx1024m -cp $JAVA_PATH org.junit.runner.JUnitCore "$1"
}

run_all() {
	local FAILED=false
	while read -r test; do
		echo "Run test: '$test'"
		run_test $test || FAILED=true
	done <<< "$RUN_TESTS"
	[ "$FAILED" == "true" ] && {
	echo '*********************************'
	echo '************ TESTS HAVE FAILURES!'
	echo '*********************************'
	return 1
	}
	[ "$FAILED" == "false" ] && {
	echo '**********************************'
	echo '************ TESTS WERE SUCCESSFUL'
	echo '**********************************'
	}
}

initialize_db
run_all


