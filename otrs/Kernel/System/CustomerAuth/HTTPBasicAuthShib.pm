# --
# Kernel/System/CustomerAuth/HTTPBasicAuthShib.pm
# Provides HTTPBasic authentication for use with Apache's mod_shib
# This module auto-provisions customer users.
# --
package Kernel::System::CustomerAuth::HTTPBasicAuthShib;
use strict;
use warnings;
sub new {
    my ( $Type, %Param ) = @_;
    # allocate new hash for object
    my $Self = {};
    bless( $Self, $Type );
    # check needed objects
    for (qw(LogObject ConfigObject DBObject MainObject EncodeObject)) {
        $Self->{$_} = $Param{$_} || die "No $_!";
    }
    $Self->{CustomerUserObject} = Kernel::System::CustomerUser->new( %{$Self} );
    # Mellon environment vars
    $Self->{MailEnvVar}
        = $Self->{ConfigObject}->Get( 'Customer::AuthModule::HTTPBasicAuthShib::MailEnvVar')
    || 'SHIBBOLETH_mail';
    $Self->{FirstNameEnvVar}
        = $Self->{ConfigObject}->Get('Customer::AuthModule::HTTPBasicAuthShib::FirstNameEnvVar')
    || 'SHIBBOLETH_givenName';
    $Self->{LastNameEnvVar}
        = $Self->{ConfigObject}->Get( 'Customer::AuthModule::HTTPBasicAuthShib::LastNameEnvVar')
    || 'SHIBBOLETH_sn';
    $Self->{CustomerIDEnvVar}
        = $Self->{ConfigObject}->Get( 'Customer::AuthModule::HTTPBasicAuthShib::CustomerIDEnvVar')
    || 'SHIBBOLETH_customer_id';
    # Debug 0=off 1=on
    $Self->{Debug} = 1;
    $Self->{Count} = $Param{Count} || '';
    return $Self;
}
sub GetOption {
    my ( $Self, %Param ) = @_;
    # check needed stuff
    if ( !$Param{What} ) {
        $Self->{LogObject}->Log( Priority => 'error', Message => "Need What!" );
        return;
    }
    # module options
    my %Option = ( PreAuth => 1, );
    # return option
    return $Option{ $Param{What} };
}
sub Auth {
    my ( $Self, %Param ) = @_;
    # Get attributes values from environment variables
    my $User       = $ENV{REMOTE_USER};
    my $Mail       = $ENV{$Self->{MailEnvVar}} || 'invalid_email@noreply.com';
    my $FirstName  = $ENV{$Self->{FirstNameEnvVar}} || 'first_name';
    my $LastName   = $ENV{$Self->{LastNameEnvVar}} || 'last_name';
    my $CustomerID = $ENV{$Self->{CustomerIDEnvVar}} || 'default_customer';
    my $RemoteAddr = $ENV{REMOTE_ADDR} || 'Got no REMOTE_ADDR env!';
    # return on no user
    if ( !$User ) {
        $Self->{LogObject}->Log(
            Priority => 'notice',
            Message =>
                "No \$ENV{REMOTE_USER}, so not authenticated yet. Redirecting to authenticate (client REMOTE_ADDR: $RemoteAddr).",
        );
        return;
    }
    # replace parts of login
    my $Replace = $Self->{ConfigObject}->Get(
        'Customer::AuthModule::HTTPBasicAuth::Replace' . $Self->{Count},
    );
    if ($Replace) {
        $User =~ s/^\Q$Replace\E//;
    }
    # regexp on login
    my $ReplaceRegExp = $Self->{ConfigObject}->Get(
        'Customer::AuthModule::HTTPBasicAuth::ReplaceRegExp' . $Self->{Count},
    );
    if ($ReplaceRegExp) {
        $User =~ s/$ReplaceRegExp/$1/;
    }
    # Log Apache environment vars in debug mode
    if ( $Self->{Debug} > 0 ) {
        $Self->{LogObject}->Log(
            Priority => 'debug',
            Message => 'Apache environment vars:'
        );
        foreach my $var (sort keys %ENV) {
            $Self->{LogObject}->Log(
                Priority => 'debug',
                Message =>   $var . "=" . $ENV{$var},
            );
        }
    }
    # log
    $Self->{LogObject}->Log(
        Priority => 'notice',
        Message  => "User '$User' Authentication ok (REMOTE_ADDR: $RemoteAddr).",
    );
 
    # Auto-provisiong.
    # First check if customer exists
    my %UserTest = $Self->{CustomerUserObject}->CustomerUserDataGet( User => $User );
    if (! %UserTest) {
        $Self->{LogObject}->Log(
            Priority => 'notice',
            Message  => "User '$User' doesn't have an account here yet, provisioning it now",
        );
        # Add new customer
        my $newuser = $Self->{CustomerUserObject}->CustomerUserAdd(
            Source         => 'CustomerUser',
            UserFirstname  => $FirstName,
            UserLastname   => $LastName,
            UserCustomerID => $CustomerID,
            UserLogin      => $User,
            UserPassword   => $Self->{CustomerUserObject}->GenerateRandomPassword(),
            UserEmail      => $Mail,
            ValidID        => 1,
            UserID         => 1,
         );
    }
    # return user
    return $User;
}
1;
