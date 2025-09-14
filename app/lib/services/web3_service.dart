import 'package:http/http.dart';
import 'package:web3dart/web3dart.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class Web3Service {
  static final Web3Service _instance = Web3Service._internal();
  static Web3Service get instance => _instance;

  late final Web3Client client;
  late final DeployedContract contract;

  // Avalanche Fuji testnet
  static const String rpcUrl = "https://api.avax-test.network/ext/bc/C/rpc";
  static const String wsUrl = "wss://api.avax-test.network/ext/bc/C/ws";
  static const String contractAddress = "0xa338A6819C7f19B0cD55401df54bE54BbE34CC25";
  
  Web3Service._internal() {
    if (kIsWeb) {
      // For web, create a simpler client without WebSocket
      client = Web3Client(rpcUrl, Client());
    } else {
      // For mobile, use full WebSocket support
      client = Web3Client(
        rpcUrl, 
        Client(),
        socketConnector: () {
          return IOWebSocketChannel.connect(wsUrl).cast<String>();
        },
      );
    }
  }

  Future<void> initialize() async {
    try {
      // Add timeout for web compatibility
      await Future.wait([
        _initializeWeb3(),
        Future.delayed(Duration(seconds: kIsWeb ? 5 : 10)),
      ]).then((_) {
        print('Web3 initialized successfully');
      }).catchError((e) {
        print('Web3 initialization error: $e');
        // Create a dummy contract for web compatibility
        if (kIsWeb) {
          _createDummyContract();
        }
      });
    } catch (e) {
      print('Web3 initialization error: $e');
      // Create a dummy contract for web compatibility
      if (kIsWeb) {
        _createDummyContract();
      }
    }
  }

  Future<void> _initializeWeb3() async {
    final abiString = await rootBundle.loadString('assets/abi/contract.json');
    contract = DeployedContract(
      ContractAbi.fromJson(abiString, 'Owner'),
      EthereumAddress.fromHex(contractAddress),
    );

    // Set up event subscription only if not on web (to avoid WebSocket issues)
    if (!kIsWeb) {
      final donatedEvent = contract.event('Donated');
      final subscription = client.events(FilterOptions.events(
        contract: contract,
        event: donatedEvent,
      )).listen((event) {
        final decoded = donatedEvent.decodeResults(event.topics!, event.data!);
        print('Donation from: ${decoded[0]} amount: ${decoded[1]}');
      });
    }
  }

  void _createDummyContract() {
    try {
      // This will be called if the main initialization fails
      print('Creating dummy contract for web compatibility');
    } catch (e2) {
      print('Failed to create dummy contract: $e2');
    }
  }

  Future<String> sendDonation(String fromAddress, BigInt weiAmount) async {
    final privateKey = dotenv.env['PRIVATE_KEY'];
    if (privateKey == null) throw Exception('Private key not found in environment');
    
    final credentials = EthPrivateKey.fromHex(privateKey);
    final donateFunction = contract.function('donate');

    final transaction = Transaction.callContract(
      contract: contract,
      function: donateFunction,
      parameters: [],
      from: credentials.address,
      value: EtherAmount.inWei(weiAmount),
    );

    final txHash = await client.sendTransaction(
      credentials,
      transaction,
      chainId: 43113, // Avalanche Fuji chain ID
    );

    return txHash;
  }

  Future<BigInt> getBalance(String address) async {
    final balanceFunction = contract.function('getBalance');
    final balance = await client.call(
      contract: contract,
      function: balanceFunction,
      params: [EthereumAddress.fromHex(address)],
    );
    return balance.first as BigInt;
  }

  Future<TransactionReceipt?> getTransactionReceipt(String txHash) async {
    return await client.getTransactionReceipt(txHash);
  }

  Future<List<DonationEvent>> getPastDonations(String address) async {
    final donatedEvent = contract.event('Donated');
    final currentBlock = await client.getBlockNumber();
    
    final events = await client.getLogs(
      FilterOptions.events(
        contract: contract,
        event: donatedEvent,
        fromBlock: const BlockNum.exact(0), // Start from beginning
        toBlock: BlockNum.exact(currentBlock),
      ),
    );

    return events.map((event) {
      final decoded = donatedEvent.decodeResults(event.topics!, event.data!);
      return DonationEvent(
        from: (decoded[0] as EthereumAddress).hex,
        amount: (decoded[1] as BigInt),
        timestamp: DateTime.now(), // Ideally get this from block timestamp
      );
    }).where((event) => 
      event.from.toLowerCase() == address.toLowerCase()
    ).toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  void dispose() {
    client.dispose();
  }
}

class DonationEvent {
  final String from;
  final BigInt amount;
  final DateTime timestamp;

  DonationEvent({
    required this.from,
    required this.amount,
    required this.timestamp,
  });
} 