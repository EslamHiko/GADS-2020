# [Virtual Private Networks (VPN)](https://googlepluralsight.qwiklabs.com/focuses/10739599?parent=lti_session)

## Overview
In this lab, you establish VPN tunnels between two networks in separate regions such that a VM in one network can ping a VM in the other network over its internal IP address.

## Objectives
In this lab, you learn how to perform the following tasks:

- Create VPN gateways in each network
- Create VPN tunnels between the gateways
- Verify VPN connectivity

Qwiklabs setup
For each lab, you get a new GCP project and set of resources for a fixed time at no cost.

Make sure you signed into Qwiklabs using an incognito window.

Note the lab's access time (for example, img/time.png and make sure you can finish in that time block.

There is no pause feature. You can restart if needed, but you have to start at the beginning.

When ready, click img/start_lab.png.

Note your lab credentials. You will use them to sign in to Cloud Platform Console. img/open_google_console.png

Click Open Google Console.

Click Use another account and copy/paste credentials for this lab into the prompts.

If you use other credentials, you'll get errors or incur charges.

## Translation

You can find the initialization instructions for different Operating Systems Here : https://cloud.google.com/sdk/docs/quickstarts

Personally I use Ubuntu so that what I did.
```sh
# Add the Cloud SDK distribution URI as a package source
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Import the Google Cloud public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# Update the package list and install the Cloud SDK
sudo apt-get update && sudo apt-get install google-cloud-sdk

gcloud init

To continue, you must log in. Would you like to log in (Y/n)? Y

Pick cloud project to use:
 [1] [GCP-Project-ID]
 ...
 Please enter your numeric choice: 1

 Which compute zone would you like to use as project default?
 [1] [asia-east1-a]
 [2] [asia-east1-b]
 ...
 [14] Do not use default zone
 Please enter your numeric choice: [qwiklabs-zone-number]
```

Accept the terms and skip the recovery resource page.
Do not click End Lab unless you are finished with the lab or want to restart it. This clears your work and removes the project.

Task 1: Explore the networks and instances
Two custom networks with VM instances have been configured for you. For the purposes of the lab, both networks are VPC networks within a Google Cloud project. However, in a real-world application, one of these networks might be in a different Google Cloud project, on-premises, or in a different cloud.

Explore the networks
Verify that vpn-network-1 and vpn-network-2 have been created with subnets in separate regions.

In the Cloud Console, on the Navigation menu (Navigation menu), click VPC network > VPC networks.
Note the vpn-network-1 network and its subnet-a in us-central1.

Note the vpn-network-2 network and its subnet-b in europe-west1.
## Translation
```sh
gcloud compute networks list

gcloud compute networks subnets list
```

Explore the firewall rules
In the navigation pane, click Firewall.
Note the network-1-allow-ssh and network-1-allow-icmp rules for vpn-network-1.
Note the network-2-allow-ssh and network-2-allow-icmp rules for vpn-network-2.
These firewall rules allow SSH and ICMP traffic from anywhere.

## Translation
```sh
gcloud compute firewall-rules list
```

Explore the instances and their connectivity
Currently, the VPN connection between the two networks is not established. Explore the connectivity options between the instances in the networks.

In the Cloud Console, on the Navigation menu (Navigation menu), click Compute Engine > VM instances.
Click Columns, and select Network.
From server-1, you should be able to ping the following IP addresses of server-2:

External IP address

Internal IP address

Note the external and internal IP addresses for server-2.

For server-1, click SSH to launch a terminal and connect.

To test connectivity to server-2's external IP address, run the following command, replacing server-2's external IP address with the value noted earlier:

ping -c 3 <Enter server-2's external IP address here>

This works because the VM instances can communicate over the internet.

To test connectivity to server-2's internal IP address, run the following command, replacing server-2's internal IP address with the value noted earlier:

ping -c 3 <Enter server-2's internal IP address here>

You should see 100% packet loss when pinging the internal IP address because you don't have VPN connectivity yet.

Exit the SSH terminal.

## Translation
```sh
gcloud beta compute ssh --zone "us-central1-b" "server-1" --project "[qwiklabs-project-id]"

ping -c 3 <Enter server-2's external IP address here>

ping -c 3 <Enter server-2's internal IP address here>

exit
```

Let's try the same from server-2.

Note the external and internal IP addresses for server-1.

For server-2, click SSH to launch a terminal and connect.

To test connectivity to server-1's external IP address, run the following command, replacing server-1's external IP address with the value noted earlier:

ping -c 3 <Enter server-1's external IP address here>

To test connectivity to server-1's internal IP address, run the following command, replacing server-1's internal IP address with the value noted earlier:

ping -c 3 <Enter server-1's internal IP address here>

You should see similar results.

Exit the SSH terminal.

## Translation
```sh
gcloud beta compute ssh --zone "europe-west1-b" "server-2" --project "[qwiklabs-project-id]"

ping -c 3 <Enter server-1's external IP address here>

ping -c 3 <Enter server-1's internal IP address here>

exit
```

Why are we testing both server-1 to server-2 and server-2 to server-1?

For the purposes of this lab, the path from subnet-a to subnet-b is not the same as the path from subnet-b to subnet-a. You are using one tunnel to pass traffic in each direction. And if both tunnels are not established, you won't be able to ping the remote server on its internal IP address. The ping might reach the remote server, but the response can't be returned.

This makes it much easier to debug the lab during class. In practice, a single tunnel could be used with symmetric configuration. However, it is more common to have multiple tunnels or multiple gateways and VPNs for production work, because a single tunnel could be a single point of failure.

Task 2: Create the VPN gateways and tunnels
Establish private communication between the two VM instances by creating VPN gateways and tunnels between the two networks.

Reserve two static IP addresses
Reserve one static IP address for each VPN gateway.

In the Cloud Console, on the Navigation menu (Navigation menu), click VPC network > External IP addresses.

Click Reserve static address.

Specify the following, and leave the remaining settings as their defaults:

Property	Value (type value or select option as specified)
Name	vpn-1-static-ip
IP version	IPv4
Region	us-central1
Click Reserve.

## Translation
```sh
gcloud compute addresses create vpn-1-static-ip --project=[qwiklabs-project-id] --region=us-central1
```

Repeat the same for vpn-2-static-ip.

Click Reserve static address.

## Translation
```sh
gcloud compute addresses create vpn-2-static-ip --project=[qwiklabs-project-id] --region=europe-west1
```

Specify the following, and leave the remaining settings as their defaults:

Property	Value (type value or select option as specified)
Name	vpn-2-static-ip
IP version	IPv4
Region	europe-west1
Click Reserve.

Note both IP addresses for the next step. They will be referred to us [VPN-1-STATIC-IP] and [VPN-2-STATIC-IP].

Create the vpn-1 gateway and tunnel1to2
In the Cloud Console, on the Navigation menu (Navigation menu), click Hybrid Connectivity > VPN.

Click Create VPN Connection.

If asked, select Classic VPN, and then click Continue.

Specify the following in the VPN gateway section, and leave the remaining settings as their defaults:

Property	Value (type value or select option as specified)
Name	vpn-1
Network	vpn-network-1
Region	us-central1
IP address	vpn-1-static-ip

Specify the following in the Tunnels section, and leave the remaining settings as their defaults:

Property	Value (type value or select option as specified)
Name	tunnel1to2
Remote peer IP address	[VPN-2-STATIC-IP]
IKE pre-shared key	gcprocks
Routing options	Route-based
Remote network IP ranges	10.1.3.0/24
Make sure to replace [VPN-2-STATIC-IP] with your reserved IP address for europe-west1.

Click command line.
The gcloud command line window shows the gcloud commands to create the VPN gateway and VPN tunnels and it illustrates that three forwarding rules are also created.

## Translation
```sh
gcloud compute --project "qwiklabs-gcp-04-664dd42e323d" target-vpn-gateways create "vpn-1" --region "us-central1" --network "vpn-network-1"

gcloud compute --project "qwiklabs-gcp-04-664dd42e323d" forwarding-rules create "vpn-1-rule-esp" --region "us-central1" --address "[VPN-1-STATIC-IP]" --ip-protocol "ESP" --target-vpn-gateway "vpn-1"

gcloud compute --project "qwiklabs-gcp-04-664dd42e323d" forwarding-rules create "vpn-1-rule-udp500" --region "us-central1" --address "[VPN-1-STATIC-IP]" --ip-protocol "UDP" --ports "500" --target-vpn-gateway "vpn-1"

gcloud compute --project "qwiklabs-gcp-04-664dd42e323d" forwarding-rules create "vpn-1-rule-udp4500" --region "us-central1" --address "[VPN-1-STATIC-IP]" --ip-protocol "UDP" --ports "4500" --target-vpn-gateway "vpn-1"

gcloud compute --project "qwiklabs-gcp-04-664dd42e323d" vpn-tunnels create "tunnelt1to2" --region "us-central1" --peer-address "[VPN-2-STATIC-IP]" --shared-secret "gcprocks" --ike-version "2" --local-traffic-selector "0.0.0.0/0" --target-vpn-gateway "vpn-1"

gcloud compute --project "qwiklabs-gcp-04-664dd42e323d" routes create "tunnelt1to2-route-1" --network "vpn-network-1" --next-hop-vpn-tunnel "tunnelt1to2" --next-hop-vpn-tunnel-region "us-central1" --destination-range "10.1.3.0/24"
```

Click Close.
Click Create.
Click Check my progress to verify the objective.

Create the 'vpn-1' gateway and tunnel
Create the vpn-2 gateway and tunnel2to1
Click VPN setup wizard.

If asked, select Classic VPN, and then click Continue.

Specify the following in the VPN gateway section, and leave the remaining settings as their defaults:

Property	Value (type value or select option as specified)
Name	vpn-2
Network	vpn-network-2
Region	europe-west1
IP address	vpn-2-static-ip
Specify the following in the Tunnels section, and leave the remaining settings as their defaults:

Property	Value (type value or select option as specified)
Name	tunnel2to1
Remote peer IP address	[VPN-1-STATIC-IP]
IKE pre-shared key	gcprocks
Routing options	Route-based
Remote network IP ranges	10.5.4.0/24
Make sure to replace [VPN-1-STATIC-IP] with your reserved IP address for us-central1.

Click Create.
Click Cloud VPN Tunnels.
Click Check my progress to verify the objective.

Create the 'vpn-2' gateway and tunnel
Wait for the VPN tunnels status to change to Established for both tunnels before continuing.

## Translation
```sh
gcloud compute --project "qwiklabs-gcp-04-664dd42e323d" target-vpn-gateways create "vpn-2" --region "europe-west1" --network "vpn-network-2"

gcloud compute --project "qwiklabs-gcp-04-664dd42e323d" forwarding-rules create "vpn-2-rule-esp" --region "europe-west1" --address "[VPN-2-STATIC-IP]" --ip-protocol "ESP" --target-vpn-gateway "vpn-2"

gcloud compute --project "qwiklabs-gcp-04-664dd42e323d" forwarding-rules create "vpn-2-rule-udp500" --region "europe-west1" --address "[VPN-2-STATIC-IP]" --ip-protocol "UDP" --ports "500" --target-vpn-gateway "vpn-2"

gcloud compute --project "qwiklabs-gcp-04-664dd42e323d" forwarding-rules create "vpn-2-rule-udp4500" --region "europe-west1" --address "[VPN-2-STATIC-IP]" --ip-protocol "UDP" --ports "4500" --target-vpn-gateway "vpn-2"

gcloud compute --project "qwiklabs-gcp-04-664dd42e323d" vpn-tunnels create "tunnelt2to1" --region "europe-west1" --peer-address "[VPN-1-STATIC-IP]" --shared-secret "gcprocks" --ike-version "2" --local-traffic-selector "0.0.0.0/0" --target-vpn-gateway "vpn-2"

gcloud compute --project "qwiklabs-gcp-04-664dd42e323d" routes create "tunnelt2to1-route-1" --network "vpn-network-2" --next-hop-vpn-tunnel "tunnelt2to1" --next-hop-vpn-tunnel-region "europe-west1" --destination-range "10.5.4.0/24"
```

Click Check my progress to verify the objective.

Tunnel establishment
Task 3: Verify VPN connectivity
From server-1, you should be able to ping the following IP addresses of server-2:

Internal IP address

External IP address

Verify server-1 to server-2 connectivity
In the Cloud Console, on the Navigation menu, click Compute Engine > VM instances.

For server-1, click SSH to launch a terminal and connect.

To test connectivity to server-2's internal IP address, run the following command:

ping -c 3 <insert server-2's internal IP address here>

Exit the server-1 SSH terminal.

For server-2, click SSH to launch a terminal and connect.

To test connectivity to server-1's internal IP address, run the following command:

ping -c 3 <insert server-1's internal IP address here>

## Translation
```sh

gcloud beta compute ssh --zone "us-central1-b" "server-1" --project "qwiklabs-gcp-04-664dd42e323d"

ping -c 3 <Enter server-2's external IP address here>

ping -c 3 <Enter server-2's internal IP address here>

exit

gcloud beta compute ssh --zone "europe-west1-b" "server-2" --project "qwiklabs-gcp-04-664dd42e323d"

ping -c 3 <Enter server-1's external IP address here>

ping -c 3 <Enter server-1's internal IP address here>

exit

```

Remove the external IP addresses
Now that you verified VPN connectivity, you can remove the instances' external IP addresses. For demonstration purposes, just do this for the server-1 instance.



On the Navigation menu, click Compute Engine > VM instances.
Select the server-1 instance and click Stop. Wait for the instance to stop.
Instances need to be stopped before you can make changes to their network interfaces.
Click on the name of the server-1 instance to open the VM instance details page.
Click Edit.
For Network interfaces, click the Edit icon (Edit).
Change External IP to None.
Click Done.
Click Save and wait for the instance details to update.
Click Start.
Click Start again to confirm that you want to start the VM instance.
Return to the VM instances page and wait for the instance to start.
Notice that External IP is set to None for the server-1 instance.
Feel free to SSH to server-2 and verify that you can still ping the server-1 instance's internal IP address. You won't be able to SSH to server-1 from the Cloud Console but you can do so from Cloud Shell using Cloud IAP as described here.

External IP addresses that don’t fall under the Free Tier will incur a small cost. Also, as a general security best practice, it’s a good idea to use internal IP addresses where applicable and since you configured Cloud VPN you no longer need to communicate between instances using their external IP address.
Task 4: Review
In this lab, you configured a VPN connection between two networks with subnets in different regions. Then you verified the VPN connection by pinging VMs in different networks using their internal IP addresses.

You configured the VPN gateways and tunnels using the Cloud Console. However, this approach obfuscated the creation of forwarding rules, which you explored with the command line button in the Console. This can help in troubleshooting a configuration.

End your lab
When you have completed your lab, click End Lab. Qwiklabs removes the resources you’ve used and cleans the account for you.

You will be given an opportunity to rate the lab experience. Select the applicable number of stars, type a comment, and then click Submit.

The number of stars indicates the following:

1 star = Very dissatisfied
2 stars = Dissatisfied
3 stars = Neutral
4 stars = Satisfied
5 stars = Very satisfied
You can close the dialog box if you don't want to provide feedback.

For feedback, suggestions, or corrections, please use the Support tab.

Copyright 2020 Google LLC All rights reserved. Google and the Google logo are trademarks of Google LLC. All other company and product names may be trademarks of the respective companies with which they are associated.
