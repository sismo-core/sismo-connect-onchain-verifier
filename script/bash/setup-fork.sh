#! /bin/bash 

# Get chain name from command line arguments to get the config file
chain_name=$1
config_file="./script/deployments/tmp/${chain_name}.json"

# Deploy Sismo Connect protocol contracts on a local fork
# Deployment is made from the first account of anvil
FORK=true CHAIN_NAME=$chain_name forge script DeployAll --rpc-url http://127.0.0.1:8545 --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 --broadcast

# Get AddressesProvider owner
ADDRESSES_PROVIDER_OWNER=$(cast call 0x3340Ac0CaFB3ae34dDD53dba0d7344C1Cf3EFE05 'owner()' --rpc-url http://localhost:8545 | sed 's/000000000000000000000000//')
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
declare -a contract_names=("authRequestBuilder"
                            "availableRootsRegistry"
                            "claimRequestBuilder"
                            "commitmentMapperRegistry"
                            "hydraS2Verifier"
                            "requestBuilder"
                            "signatureBuilder"
                            "sismoConnectVerifier")

# Loop over contract names
for name in "${contract_names[@]}"
do
    echo "Set address of ${name} in the AddressesProvider"
    # Use jq to parse the JSON file and get the contract address
    contract_address=$(jq -r .${name} ${config_file})

    # Set the contract address in the AddressesProvider by impersonating the owner thanks to --unlocked
    cast send 0x3340Ac0CaFB3ae34dDD53dba0d7344C1Cf3EFE05 "set(address,string)" ${contract_address} ${name}-v1 --unlocked --from $ADDRESSES_PROVIDER_OWNER
done