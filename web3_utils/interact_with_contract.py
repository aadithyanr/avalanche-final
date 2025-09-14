from dataclasses import dataclass
from web3 import Web3
import json
import os
from eth_account import Account
import dotenv
import requests
dotenv.load_dotenv()
from web3.middleware import SignAndSendRawMiddlewareBuilder

@dataclass
class User:
    topics: list[str]
    addresses: list[str]
    percentages: list[int]
    balance: float

if os.getenv('PRIVATE_KEY') is None:
    print("Please set the PRIVATE_KEY environment variable")
    exit(1)

w3 = Web3(Web3.HTTPProvider(os.getenv('INFURA_URL')))

CONTRACT_ADDRESS = "0xa338A6819C7f19B0cD55401df54bE54BbE34CC25"

ETHERSCAN_API_KEY = os.getenv('ETHERSCAN_API_KEY')

def fetch_abi_from_etherscan(contract_address, api_key):
    # For Avalanche Fuji, we'll use the local ABI file instead
    try:
        with open('contract_wrapper_api/abi.json', 'r') as f:
            return f.read()
    except FileNotFoundError:
        print("ABI file not found. Please ensure abi.json exists in contract_wrapper_api/")
        return "[]"

def get_balance_of_user(contract, user_address):
    # call the getBalance(address) method in the contract
    balance = contract.functions.getBalance(user_address).call()
    return balance / 10**18

account = Account.from_key(os.getenv('PRIVATE_KEY'))

# Add middleware to sign transactions with the account's private key
w3.middleware_onion.inject(SignAndSendRawMiddlewareBuilder.build(account), layer=0)

def enroll_user(contract, topics: list[str], charities: list[str], charityPercents: list[int]):
    assert len(topics) == 3, "topics should have 3 elements"
    assert len(charities) == len(charityPercents), "charities and charityPercents should have the same length"
    assert sum(charityPercents) == 100, "charityPercents should sum to 100"

    # call .enroll(topics, charities, charityPercents) method in the contract
    tx_hash = contract.functions.enroll(topics, charities, charityPercents).transact({'from': account.address})
    receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
    return receipt

def get_topics(contract, address) -> list[str]:
    # This method fetches the topics of an address

    topics = contract.functions.getTopics(address).call()
    return topics

def get_user(contract, address) -> User:
    # This method fetches the topics of an address

    topics = contract.functions.getUserTopics(address).call()
    return User(topics[0], topics[1], topics[2], topics[3] / 10**18)

def get_owner(contract) -> str:
    # This method fetches the owner of the contract

    owner = contract.functions.owner().call()
    return owner

def set_topics(contract, address: str, topics: list[str]):
    # Changes the topics of a user
    tx_hash = contract.functions.setTopics(address, topics).transact({'from': account.address})
    receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
    return receipt

def set_charities(contract, address: str, addresses: list[str], percentages: list[int]):
    # Changes the charities of a user
    tx_hash = contract.functions.setCharities(address, addresses, percentages).transact({'from': account.address})
    receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
    return receipt

def donate(contract, amount: int):
    # Donates to the contract
    assert amount > 0, "Amount should be greater than 0"
    assert amount < w3.eth.get_balance(account.address), "Insufficient balance"
    tx_hash = contract.functions.donate().transact({'from': account.address, 'value': amount})
    # Value is in wei

    receipt = w3.eth.wait_for_transaction_receipt(tx_hash)
    return receipt

def split_among_charities(contract, address: str):
    # Splits the balance among the charities
    # We EXPECT a crash if this is not called by the contract owner
    contract.functions.splitAmongCharities(address).transact({'from': account.address})



def withdraw(contract):
    # Withdraws the balance of the contract
    tx_hash = contract.functions.withdraw().transact({'from': account.address})
    receipt = w3.eth.wait_for_transaction_receipt(tx_hash)

    return receipt
    

contract = w3.eth.contract(address=CONTRACT_ADDRESS, abi=json.loads(fetch_abi_from_etherscan(CONTRACT_ADDRESS, ETHERSCAN_API_KEY)))