## build
`forge build`

## deploy
`forge script script/DeployTicketManager.s.sol --rpc-url https://sepolia.base.org --private-key YOUR_PRIVATE_KEY --broadcast`

## test
To create event:
`cast send YOUR_CONTRACT_ADDRESS "createEvent(string,uint256)(string)" "Concert" 1 --rpc-url https://sepolia.base.org --private-key YOUR_PRIVATE_KEY`

Get your event uuid from decoded data. Then:
`cast call YOUR_CONTRACT_ADDRESS "getEvent(string)(string,uint,uint)" EVENT_UUID --rpc-url https://sepolia.base.org`

``

