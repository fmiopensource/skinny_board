 # These are the sizes of the domain (i.e. 0 for localhost, 1 for something.com)
 # for each of your environments
 SubdomainFu.tld_sizes = { :development => 1,
                           :test => 1,
                           :production => 1,
                           :stage => 1}

 # These are the subdomains that will be equivalent to no subdomain
 SubdomainFu.mirrors = ["www"]

 # This is the "preferred mirror" if you would rather show this subdomain
 # in the URL than no subdomain at all.
 SubdomainFu.preferred_mirror = "www"