import 'package:flutter/material.dart';

/// Avatar widget showing crypto symbol with brand colors
class SymbolAvatar extends StatelessWidget {
  final String symbol;
  final double size;

  const SymbolAvatar({
    super.key,
    required this.symbol,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: _getColorForSymbol(symbol),
      child: Text(
        symbol.substring(0, symbol.length > 3 ? 3 : symbol.length),
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: size * 0.3,
        ),
      ),
    );
  }

  /// Get brand color for known crypto symbols
  Color _getColorForSymbol(String symbol) {
    switch (symbol.toUpperCase()) {
      case 'BTC':
        return const Color(0xFFF7931A); // Bitcoin Orange
      case 'ETH':
        return const Color(0xFF627EEA); // Ethereum Blue
      case 'SOL':
        return const Color(0xFF00FFA3); // Solana Green
      case 'ADA':
        return const Color(0xFF0033AD); // Cardano Blue
      case 'DOT':
        return const Color(0xFFE6007A); // Polkadot Pink
      case 'XRP':
        return const Color(0xFF23292F); // Ripple Dark
      case 'DOGE':
        return const Color(0xFFC3A634); // Dogecoin Gold
      case 'AVAX':
        return const Color(0xFFE84142); // Avalanche Red
      case 'MATIC':
        return const Color(0xFF8247E5); // Polygon Purple
      case 'LINK':
        return const Color(0xFF2A5ADA); // Chainlink Blue
      default:
        return Colors.blueGrey;
    }
  }
}
