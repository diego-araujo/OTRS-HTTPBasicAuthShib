# Configuração, arquivo Kernel/Config.pm

# Agents
$Self->{'AuthModule'} = 'Kernel::System::Auth::HTTPBasicAuth';

# Customer Auth
$Self->{'Customer::AuthModule'} = 'Kernel::System::CustomerAuth::HTTPBasicAuthShib';

# Uncomment to override the environment vars to be used
$Self->{'Customer::AuthModule::HTTPBasicAuthShib::MailEnvVar'} = 'mail';
$Self->{'Customer::AuthModule::HTTPBasicAuthShib::FirstNameEnvVar'} = 'givenName';
$Self->{'Customer::AuthModule::HTTPBasicAuthShib::LastNameEnvVar'} = 'sn';
$Self->{'Customer::AuthModule::HTTPBasicAuthShib::CustomerIDEnvVar'} = 'uid';

#Uncomment this line case you not set HTTPBasicAuthShib::MailEnvVar or may not guarantee uniqueness email
#$Self->{CustomerUser}->{CustomerUserEmailUniqCheck} = 0;
