#! /bin/bash 

# Usage
# in a first terminal, launch a fork with anvil: `anvil --fork-url https://rpc.ankr.com/polygon_mumbai`
# in a second terminal, setup the fork to your needs: `yarn setup-fork testnet-mumbai`

# Get chain name from command line arguments to get the config file
chain_name=$1
config_file="./deployments/tmp/${chain_name}.json"
ADDRESSES_PROVIDER_V2_ADDRESS=0x3Cd5334eB64ebBd4003b72022CC25465f1BFcEe6

# Deploy Sismo Connect protocol contracts on a local fork
# Deployment is made from the first account of anvil
FORK=true CHAIN_NAME=$chain_name forge script DeployAll --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast

# Get AddressesProvider owner
ADDRESSES_PROVIDER_OWNER=$(cast call $ADDRESSES_PROVIDER_V2_ADDRESS 'owner()' --rpc-url http://localhost:8545 | sed 's/000000000000000000000000//')
# Impersonate AddressesProvider owner
cast rpc anvil_impersonateAccount "$ADDRESSES_PROVIDER_OWNER"

# Check if config file is provided and exists
if [[ -z "$config_file" ]]; then
    echo "Usage: $0 <config_file>"
    exit 1
elif [[ ! -f "$config_file" ]]; then
    echo "Error: Config file $config_file does not exist."
    exit 1
fi

# Define the contract names
declare -a contract_keys=("authRequestBuilder"
                          "availableRootsRegistry"
                          "claimRequestBuilder"
                          "commitmentMapperRegistry"
                          "hydraS3Verifier"
                          "requestBuilder"
                          "signatureBuilder"
                          "sismoConnectVerifier")

declare -a contract_values=("authRequestBuilder-v1.1"
                            "sismoConnectAvailableRootsRegistry"
                            "claimRequestBuilder-v1.1"
                            "sismoConnectCommitmentMapperRegistry"
                            "hydraS3Verifier"
                            "requestBuilder-v1.1"
                            "signatureBuilder-v1.1"
                            "sismoConnectVerifier-v1.2")

# Loop over contract names
for index in "${!contract_keys[@]}"
do
    name=${contract_keys[$index]}
    value=${contract_values[$index]}
    echo "Set address of contract ${name} to ${value} in the AddressesProvider"
    # Use jq to parse the JSON file and get the contract address
    contract_address=$(jq -r .${name} ${config_file})

    # Set the contract address in the AddressesProvider by impersonating the owner thanks to --unlocked
    cast send $ADDRESSES_PROVIDER_V2_ADDRESS "set(address,string)" ${contract_address} ${value} --unlocked --from $ADDRESSES_PROVIDER_OWNER
done