The tf files provided in this example assume you have already created 2 virtual machines to use with the module.
The vm's in this example are referenced in the backend-vms.tf file.
The vm's are in a different resource group to the load balancer.
It is also possible to create the load balancer and vm's in the same group.  See the file backend-pool-association.tf.example , option B.
