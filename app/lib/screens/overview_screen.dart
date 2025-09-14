import 'package:flutter/material.dart';
import '../widgets/growing_tree.dart';
import 'package:web3dart/web3dart.dart';
import '../services/wallet_service.dart';
import '../services/web3_service.dart';
import '../services/ai_service.dart';
import '../services/news_service.dart';
import '../services/transaction_service.dart';
import '../widgets/toast_notification.dart';
import '../services/toast_service.dart';

class OverviewTab extends StatefulWidget {
  const OverviewTab({super.key});

  @override
  State<OverviewTab> createState() => _OverviewTabState();
}

class _OverviewTabState extends State<OverviewTab> {
  final _treeKey = GlobalKey<GrowingTreeState>();
  bool _isMaxDepthReached = false;
  final TextEditingController _amountController = TextEditingController();
  List<AIRecommendation> _recommendations = [];
  bool _isLoadingRecommendations = true;

  @override
  void initState() {
    super.initState();
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    try {
      print('Loading AI recommendations...');
      final address = WalletService.instance.getAddress();
      print('User address: $address');
      
      if (address != null) {
        final recommendations = await AIService.getRecommendations(address);
        print('Received ${recommendations.length} recommendations');
        
        if (mounted) {
          setState(() {
            _recommendations = recommendations;
            _isLoadingRecommendations = false;
          });
          print('Updated UI with recommendations');
        }
      } else {
        print('No wallet address found');
        if (mounted) {
          setState(() {
            _isLoadingRecommendations = false;
          });
        }
      }
    } catch (e) {
      print('Error loading recommendations: $e');
      if (mounted) {
        setState(() {
          _isLoadingRecommendations = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _showDonationModal() async {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Add Funds',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amountController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Amount (AVAX)',
                  hintText: '0.01',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    final amount = double.tryParse(_amountController.text);
                    if (amount != null && amount > 0) {
                      Navigator.pop(context);
                      donateContract(amount);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF4081),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Confirm Donation',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> donateContract(double amount) async {
    try {
      ToastService.instance.showToast(
        message: 'Transaction Submitted',
        backgroundColor: Colors.grey,
        icon: const Icon(Icons.info_outline, color: Colors.white, size: 16),
      );

      final web3 = Web3Service.instance;
      final address = WalletService.instance.getAddress();
      if (address == null) {
        debugPrint('Error: No wallet address found');
        return;
      }

      final weiAmount = BigInt.from(amount * 1e18);
      final txHash = await web3.sendDonation(address, weiAmount);
      
      bool confirmed = false;
      while (!confirmed) {
        final receipt = await web3.getTransactionReceipt(txHash);
        if (receipt != null) {
          confirmed = true;
          if (receipt.status!) {
            final transaction = DonationTransaction(
              hash: txHash,
              fromAddress: address,
              toAddress: Web3Service.contractAddress,
              amount: weiAmount,
              timestamp: DateTime.now(),
              charityName: 'AI Recommended Charity',
              category: 'disaster_relief',
            );
            
            TransactionService.addTransaction(transaction);
            
            ToastService.instance.showToast(
              message: 'Donation successful!',
              backgroundColor: const Color(0xFFFF4081),
              icon: const Icon(Icons.check_circle, color: Colors.white, size: 16),
            );
            
            final state = _treeKey.currentState;
            if (!_isMaxDepthReached) {
              state?.addBranch();
            }
          } else {
            ToastService.instance.showToast(
              message: 'Transaction failed',
              backgroundColor: Colors.red,
              icon: const Icon(Icons.error, color: Colors.white, size: 16),
            );
          }
        } else {
          await Future.delayed(const Duration(seconds: 1));
        }
      }
    } catch (e) {
      ToastService.instance.showToast(
        message: 'An error occurred',
        backgroundColor: Colors.red,
        icon: const Icon(Icons.error, color: Colors.white, size: 16),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the actual available height
    final screenHeight = MediaQuery.of(context).size.height;
    final appBarHeight = AppBar().preferredSize.height;
    final statusBarHeight = MediaQuery.of(context).padding.top;
    final bottomNavHeight = 90; // Your tab bar height
    final availableHeight = screenHeight - appBarHeight - statusBarHeight - bottomNavHeight;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'AvalancheDonate',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFFF4081).withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.notifications_outlined,
                color: Color(0xFFFF4081),
                size: 18,
              ),
              onPressed: () {},
            ),
          ),
        ],
      ),
      body: SizedBox(
        height: availableHeight,
        child: Column(
          children: [
            // AI Recommendations - Simple minimal design
            if (!_isLoadingRecommendations)
              Container(
                height: 100,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI Recommendations',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: _recommendations.isEmpty
                            ? const Center(
                                child: Text(
                                  'No recommendations available',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _recommendations.length,
                                itemBuilder: (context, index) {
                                  final rec = _recommendations[index];

                                  return Container(
                                    width: 190,
                                    margin: const EdgeInsets.only(right: 8),
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(8),
                                      onTap: _showDonationModal,
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(color: Colors.grey[300]!),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.favorite_rounded,
                                              color: Color(0xFFFF4081),
                                              size: 16,
                                            ),
                                            const SizedBox(width: 6),
                                            Expanded(
                                              child: Text(
                                                rec.charity.name,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  color: Color(0xFF1F2937),
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            Text(
                                              '${(rec.relevanceScore * 100).toInt()}%',
                                              style: const TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w600,
                                                color: Color(0xFFFF4081),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            
            // Loading state for recommendations
            if (_isLoadingRecommendations)
              Container(
                height: 100,
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: const Center(
                  child: Text(
                    'Loading AI recommendations...',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            
            // Tree Section - Takes all remaining space
            Expanded(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Stack(
                  children: [
                    // Tree centered
                    Center(
                      child: GrowingTree(key: _treeKey),
                    ),
                    // Button at bottom
                    Positioned(
                      bottom: 12,
                      left: 12,
                      right: 12,
                      child: SizedBox(
                        height: 44,
                        child: ElevatedButton(
                          onPressed: _showDonationModal,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF4081),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            'Add Funds',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}