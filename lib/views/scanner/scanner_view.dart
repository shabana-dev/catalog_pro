import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import '../product_details/product_details_view.dart';
import '../../controllers/product_bloc/product_bloc.dart';
import '../../controllers/product_bloc/product_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/localization/app_localizations.dart';

class ScannerView extends StatefulWidget {
  const ScannerView({super.key});

  @override
  State<ScannerView> createState() => _ScannerViewState();
}

class _ScannerViewState extends State<ScannerView> {
  bool _hasPermission = false;
  bool _isCheckingPermission = true;
  bool _isNavigating = false;
  final TextEditingController _idController = TextEditingController();
  final MobileScannerController _scannerController = MobileScannerController();

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  @override
  void dispose() {
    _idController.dispose();
    _scannerController.dispose();
    super.dispose();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.status;
    if (mounted) {
      setState(() {
        _hasPermission = status.isGranted;
        _isCheckingPermission = false;
      });
    }
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    if (mounted) {
      setState(() {
        _hasPermission = status.isGranted;
      });
    }
    if (status.isPermanentlyDenied && mounted) {
      _showPermissionDeniedDialog();
    }
  }

  void _showPermissionDeniedDialog() {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.translate('scan_qr')),
        content: Text(l10n.translate('camera_permission')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.translate('cancel')),
          ),
          TextButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: Text(l10n.translate('open_settings')),
          ),
        ],
      ),
    );
  }

  void _handleCode(String code) {
    if (_isNavigating) return;

    final uri = Uri.tryParse(code);
    if (uri != null && uri.scheme == 'catalogue' && uri.host == 'product') {
      final idStr = uri.pathSegments.isNotEmpty ? uri.pathSegments[0] : null;
      final id = int.tryParse(idStr ?? '');
      if (id != null) {
        _navigateToProduct(id);
      } else {
        _showError('product_not_found');
      }
    } else {
      _showError('invalid_qr');
    }
  }

  void _navigateToProduct(int id) {
    final state = context.read<ProductBloc>().state;
    if (state is ProductLoaded) {
      try {
        final product = state.products.firstWhere((p) => p.id == id);
        
        // Prevent multiple navigations
        if (_isNavigating) return;
        setState(() => _isNavigating = true);
        
        // Stop scanner while navigating
        _scannerController.stop();

        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => ProductDetailsView(product: product)),
        ).then((_) {
          // Restart scanner when returning
          if (mounted) {
            setState(() => _isNavigating = false);
            _scannerController.start();
          }
        });
      } catch (e) {
        _showError('product_not_found');
      }
    } else {
      _showError('no_products');
    }
  }

  void _showError(String messageKey) {
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(l10n.translate(messageKey)),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (_isCheckingPermission) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.translate('scan_qr')),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          if (_hasPermission)
            MobileScanner(
              controller: _scannerController,
              onDetect: (capture) {
                if (_isNavigating) return;
                final List<Barcode> barcodes = capture.barcodes;
                for (final barcode in barcodes) {
                  if (barcode.rawValue != null) {
                    _handleCode(barcode.rawValue!);
                    break;
                  }
                }
              },
            )
          else
            Container(
              color: Colors.black,
              child: const Center(
                child: Icon(Icons.camera_alt, size: 80, color: Colors.white24),
              ),
            ),

          _buildOverlay(context),

          Align(
            alignment: Alignment.bottomCenter,
            child: _buildManualInput(l10n),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    return Container(
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: Theme.of(context).primaryColor,
          borderRadius: 20,
          borderLength: 40,
          borderWidth: 10,
          cutOutSize: MediaQuery.of(context).size.width * 0.7,
        ),
      ),
    );
  }

  Widget _buildManualInput(AppLocalizations l10n) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 20)],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.translate('simulator_type_code'),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text("catalogue://product/", 
                style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w500)),
              Expanded(
                child: TextField(
                  controller: _idController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    hintText: "ID",
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.filled(
                onPressed: () {
                  if (_idController.text.isNotEmpty) {
                    _handleCode('catalogue://product/${_idController.text}');
                  }
                },
                icon: const Icon(Icons.send),
              ),
            ],
          ),
          if (!_hasPermission) ...[
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _requestPermission,
                icon: const Icon(Icons.camera_enhance),
                label: Text(l10n.translate('grant_permission')),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderLength;
  final double borderRadius;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 10,
    this.borderLength = 40,
    this.borderRadius = 20,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    return Path()..addRect(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;

    final paint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final cutOutRect = Rect.fromCenter(
      center: Offset(width / 2, height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );

    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()..addRRect(RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius))),
      ),
      paint,
    );

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(cutOutRect.left, cutOutRect.top + borderLength);
    path.lineTo(cutOutRect.left, cutOutRect.top);
    path.lineTo(cutOutRect.left + borderLength, cutOutRect.top);

    path.moveTo(cutOutRect.right - borderLength, cutOutRect.top);
    path.lineTo(cutOutRect.right, cutOutRect.top);
    path.lineTo(cutOutRect.right, cutOutRect.top + borderLength);

    path.moveTo(cutOutRect.right, cutOutRect.bottom - borderLength);
    path.lineTo(cutOutRect.right, cutOutRect.bottom);
    path.lineTo(cutOutRect.right - borderLength, cutOutRect.bottom);

    path.moveTo(cutOutRect.left + borderLength, cutOutRect.bottom);
    path.lineTo(cutOutRect.left, cutOutRect.bottom);
    path.lineTo(cutOutRect.left, cutOutRect.bottom - borderLength);

    canvas.drawPath(path, borderPaint);
  }

  @override
  ShapeBorder scale(double t) => this;
}
