from web3 import Web3

from eth_account import Account
import dotenv
import requests
from web3.middleware import SignAndSendRawMiddlewareBuilder
from dataclasses import dataclass
import json
import fastapi
import os

dotenv.load_dotenv()

@dataclass
class User:
    topics: list[str]
    addresses: list[str]
    percentages: list[int]
    balance: int

abi_text = open("contract_wrapper_api/abi.json", "r").read()

CONTRACT_ADDRESS = "0xa338A6819C7f19B0cD55401df54bE54BbE34CC25"

app = fastapi.FastAPI()

@app.post("/donate")
async def donate(request: fastapi.Request):
    try:
        # Parse JSON body
        data = await request.json()
        
        private_key = data.get("private_key")
        amount = data.get("amount")
        
        if not private_key or not amount:
            return {"status": "error", "message": "Missing private_key or amount"}
        
        
        # Connect to Web3
        w3 = Web3(Web3.HTTPProvider(os.getenv('INFURA_URL')))
        
        # Load the smart contract
        contract = w3.eth.contract(address=CONTRACT_ADDRESS, abi=abi_text)
        
        # Get the account from the private key
        account = Account.from_key(private_key)
        
        # Inject middleware for signing and sending transactions
        w3.middleware_onion.inject(SignAndSendRawMiddlewareBuilder.build(account), layer=0)
        
        # Execute the donate function from the smart contract
        contract.functions.donate().transact({'from': account.address, 'value': amount})
 
        return {"status": "success"}
    except Exception as e:
        return {"status": "error", "message": str(e)}