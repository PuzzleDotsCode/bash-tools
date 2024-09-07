#!/bin/bash

# script to combine words and create API routes to pentest
# example:
# url_combinator.sh api v1 graphql
#
# result:
# /api/v1/graphql
# /api/graphql/v1
# /v1/api/graphql
# /v1/graphql/api
# /graphql/api/v1
# /graphql/v1/api


# Function to generate permutations
generate_permutations() {
    local prefix=$1          # Current prefix (accumulated combination)
    shift                    # Remove the first argument (prefix) from the parameters
    local endpoints=("$@")   # Remaining endpoints

    # If no more endpoints to permute, print the final combination with a leading slash
    if [ ${#endpoints[@]} -eq 0 ]; then
        echo "/$prefix"
    else
        # Iterate over all endpoints and create new permutations
        for i in "${!endpoints[@]}"; do
            # Add "/" only if prefix is not empty
            local new_prefix="$prefix${prefix:+/}${endpoints[i]}"
            local remaining=("${endpoints[@]:0:i}" "${endpoints[@]:i+1}")
            generate_permutations "$new_prefix" "${remaining[@]}"
        done
    fi
}

# Initial call to generate permutations with an empty prefix
generate_permutations "" "$@"
