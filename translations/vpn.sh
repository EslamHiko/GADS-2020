
# Add the Cloud SDK distribution URI as a package source
echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | sudo tee -a /etc/apt/sources.list.d/google-cloud-sdk.list

# Import the Google Cloud public key
curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -

# Update the package list and install the Cloud SDK
sudo apt-get update && sudo apt-get install google-cloud-sdk

gcloud init
:'
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
'

gcloud compute networks list

gcloud compute networks subnets list

gcloud compute firewall-rules list

gcloud beta compute ssh --zone "us-central1-b" "server-1" --project "qwiklabs-gcp-04-664dd42e323d"

ping -c 3 <Enter server-2's external IP address here>

ping -c 3 <Enter server-2's internal IP address here>

exit

gcloud beta compute ssh --zone "europe-west1-b" "server-2" --project "qwiklabs-gcp-04-664dd42e323d"

ping -c 3 <Enter server-1's external IP address here>

ping -c 3 <Enter server-1's internal IP address here>

exit


gcloud compute addresses create vpn-1-static-ip --project=qwiklabs-gcp-04-664dd42e323d --region=us-central1

gcloud compute addresses create vpn-2-static-ip --project=qwiklabs-gcp-04-664dd42e323d --region=europe-west1

gcloud compute --project "qwiklabs-gcp-04-664dd42e323d" target-vpn-gateways create "vpn-1" --region "us-central1" --network "vpn-network-1"

gcloud compute --project "qwiklabs-gcp-04-664dd42e323d" forwarding-rules create "vpn-1-rule-esp" --region "us-central1" --address "[VPN-1-STATIC-IP]" --ip-protocol "ESP" --target-vpn-gateway "vpn-1"

gcloud compute --project "qwiklabs-gcp-04-664dd42e323d" forwarding-rules create "vpn-1-rule-udp500" --region "us-central1" --address "[VPN-1-STATIC-IP]" --ip-protocol "UDP" --ports "500" --target-vpn-gateway "vpn-1"

gcloud compute --project "qwiklabs-gcp-04-664dd42e323d" forwarding-rules create "vpn-1-rule-udp4500" --region "us-central1" --address "[VPN-1-STATIC-IP]" --ip-protocol "UDP" --ports "4500" --target-vpn-gateway "vpn-1"

gcloud compute --project "qwiklabs-gcp-04-664dd42e323d" vpn-tunnels create "tunnelt1to2" --region "us-central1" --peer-address "[VPN-2-STATIC-IP]" --shared-secret "gcprocks" --ike-version "2" --local-traffic-selector "0.0.0.0/0" --target-vpn-gateway "vpn-1"

gcloud compute --project "qwiklabs-gcp-04-664dd42e323d" routes create "tunnelt1to2-route-1" --network "vpn-network-1" --next-hop-vpn-tunnel "tunnelt1to2" --next-hop-vpn-tunnel-region "us-central1" --destination-range "10.1.3.0/24"

gcloud compute --project "qwiklabs-gcp-04-664dd42e323d" target-vpn-gateways create "vpn-2" --region "europe-west1" --network "vpn-network-2"

gcloud compute --project "qwiklabs-gcp-04-664dd42e323d" forwarding-rules create "vpn-2-rule-esp" --region "europe-west1" --address "[VPN-2-STATIC-IP]" --ip-protocol "ESP" --target-vpn-gateway "vpn-2"

gcloud compute --project "qwiklabs-gcp-04-664dd42e323d" forwarding-rules create "vpn-2-rule-udp500" --region "europe-west1" --address "[VPN-2-STATIC-IP]" --ip-protocol "UDP" --ports "500" --target-vpn-gateway "vpn-2"

gcloud compute --project "qwiklabs-gcp-04-664dd42e323d" forwarding-rules create "vpn-2-rule-udp4500" --region "europe-west1" --address "[VPN-2-STATIC-IP]" --ip-protocol "UDP" --ports "4500" --target-vpn-gateway "vpn-2"

gcloud compute --project "qwiklabs-gcp-04-664dd42e323d" vpn-tunnels create "tunnelt2to1" --region "europe-west1" --peer-address "[VPN-1-STATIC-IP]" --shared-secret "gcprocks" --ike-version "2" --local-traffic-selector "0.0.0.0/0" --target-vpn-gateway "vpn-2"

gcloud compute --project "qwiklabs-gcp-04-664dd42e323d" routes create "tunnelt2to1-route-1" --network "vpn-network-2" --next-hop-vpn-tunnel "tunnelt2to1" --next-hop-vpn-tunnel-region "europe-west1" --destination-range "10.5.4.0/24"


gcloud beta compute ssh --zone "us-central1-b" "server-1" --project "qwiklabs-gcp-04-664dd42e323d"

ping -c 3 <Enter server-2's external IP address here>

ping -c 3 <Enter server-2's internal IP address here>

exit

gcloud beta compute ssh --zone "europe-west1-b" "server-2" --project "qwiklabs-gcp-04-664dd42e323d"

ping -c 3 <Enter server-1's external IP address here>

ping -c 3 <Enter server-1's internal IP address here>

exit
