Rails Lite
=========

A clone of some of the basic functionality of Rails that implements a Rails router, controller base class,
whitelisted params, and session cookie storage. I use regular expressions to parse URI encoded input data, and a neat
algorithm to construct a nested params hash that still allows a developer to define the naming structure of form inputs however
they want (i.e. it can parse user input that comes in the form "user[address][street]=main&user[address][zip]=89436" into 
a hash such as { "user" => { "address" => { "street" => "main", "zip" => "89436" } } } ).
