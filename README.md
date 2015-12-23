# OTRS-HTTPBasicAuthShib
OTRS auto-provisioning of customers when using Single Sign-On


Both the custom and agent interfaces can use various authentication methods, such as a local database, or Active Directory/LDAP. It is also possible to use external authentication (HTTPBasicAuth) in which case OTRS does not take responsibility for authentication any more, but instead relies on an Apache environment variable to provide the username. The is the way forward if you want to use SAML or federated authentication, but there are some issues with.
The biggest issue is that is not possible to provision accounts in OTRS before users have logged in. This is because there is no way of knowing a user's details until they have authenticated. To overcome this I wrote a new customer authentication module for OTRS that creates customer accounts on the fly (auto-provisioning).
At the moment we have no use case yet for auto-provisioning agents. This is left as a future exercise, one idea is to auto-provisioning agents based on the value of a specific SAML attribute.
The standard HTTPBasicAuth can be used for the agent interface. 
