import 'dart:convert';

import 'package:fluttea/core/constants/ui/spacing.dart';
import 'package:fluttea/core/extensions/context_x.dart';
import 'package:fluttea/core/security/crypto/aes_gcm_suite.dart';
import 'package:fluttea/core/security/crypto/chacha20_suite.dart';
import 'package:fluttea/core/security/crypto/cipher_envelope.dart';
import 'package:fluttea/core/security/crypto/cipher_registry.dart';
import 'package:fluttea/core/security/file_guard/archive_guard.dart';
import 'package:fluttea/core/security/file_guard/magic_bytes.dart';
import 'package:fluttea/core/security/hashing/hmac_signer.dart';
import 'package:fluttea/core/security/rasp/security_policy.dart';
import 'package:fluttea/core/security/rasp/security_signals.dart';
import 'package:fluttea/core/security/rasp/security_verdict.dart';
import 'package:fluttea/core/widgets/buttons/app_button.dart';
import 'package:fluttea/core/widgets/layout/app_scaffold.dart';
import 'package:fluttea/core/widgets/layout/section.dart';
import 'package:material_ui/material_ui.dart';

class SecurityExamplesScreen extends StatefulWidget {
  const new({super.key});

  @override
  State<SecurityExamplesScreen> createState() => _SecurityExamplesScreenState();
}

class _SecurityExamplesScreenState extends State<SecurityExamplesScreen> {
  final _registry = CipherRegistry.standard();
  final _hmacSigner = HmacSigner();
  final _magicInspector = const MagicBytesInspector();
  final _archiveGuard = const ArchiveGuard();

  // Crypto State
  String _activeSuiteId = AesGcmSuite.suiteId;
  CipherEnvelope? _lastEnvelope;
  String _decryptedResult = '';
  final List<int> _sampleKey = List<int>.generate(32, (i) => (i + 1) % 256);

  // HMAC State
  HmacRequestSignature? _lastSignature;

  // File Guard State
  String _fileGuardStatus = 'Belum ada uji file';

  // RASP Simulator State
  bool _isRooted = false;
  bool _isEmulator = false;
  bool _isDebugger = false;
  bool _isTampered = false;
  bool _hasProxy = false;

  Future<void> _runEncrypt() async {
    final suite = _registry.get(_activeSuiteId);
    final envelope = await suite.encryptString(
      r'Rahasia Sensitif: Saldo $100.000.000',
      key: _sampleKey,
      keyId: 'kid-2026-v1',
    );
    if (!mounted) return;
    setState(() {
      _lastEnvelope = envelope;
      _decryptedResult = '';
    });
  }

  Future<void> _runDecrypt() async {
    if (_lastEnvelope == null) return;
    final suite = _registry.get(_lastEnvelope!.suite);
    final decrypted = await suite.decryptString(_lastEnvelope!, key: _sampleKey);
    if (!mounted) return;
    setState(() => _decryptedResult = decrypted);
  }

  void _runHmac() {
    final signature = _hmacSigner.sign(
      method: 'POST',
      path: '/api/v1/transactions',
      secretKey: _sampleKey,
      body: utf8.encode('{"amount": 250000, "recipient": "08123456789"}'),
    );
    setState(() => _lastSignature = signature);
  }

  void _testFileGuardValid() {
    // PNG header
    final pngBytes = [0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0, 0];
    final valid = _magicInspector.verifyExtension(bytes: pngBytes, declaredExtension: 'png');
    setState(() {
      _fileGuardStatus = valid
          ? 'PNG Header Valid: Signature cocok dengan .png'
          : 'PNG Header Tidak Valid';
    });
  }

  void _testFileGuardZipSlip() {
    const maliciousEntry = ArchiveEntryDescriptor(
      name: '../../system/priv_app/payload.so',
      compressedSize: 512,
      uncompressedSize: 2048,
    );
    final check = _archiveGuard.inspectEntries([maliciousEntry]);
    setState(() {
      _fileGuardStatus = check.isValid ? 'Arsip Aman' : 'DIBLOKIR: ${check.reason}';
    });
  }

  SecurityVerdict _computeVerdict() {
    final signals = SecuritySignals(
      isRootedOrJailbroken: _isRooted,
      isEmulator: _isEmulator,
      isDebuggerAttached: _isDebugger,
      isTampered: _isTampered,
      hasProxyConfigured: _hasProxy,
    );
    return SecurityPolicy.prod().evaluate(signals);
  }

  @override
  Widget build(BuildContext context) {
    final verdict = _computeVerdict();

    return AppScaffold(
      appBar: AppBar(title: const Text('Security Showcase (Fase 06)')),
      body: ListView(
        padding: const EdgeInsets.all(Spacing.md),
        children: [
          _buildCryptoSection(),
          const SizedBox(height: Spacing.lg),
          _buildHmacSection(),
          const SizedBox(height: Spacing.lg),
          _buildFileGuardSection(),
          const SizedBox(height: Spacing.lg),
          _buildRaspSection(verdict),
        ],
      ),
    );
  }

  Widget _buildCryptoSection() {
    return Section(
      title: '1. Dynamic Envelope Encryption',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ChoiceChip(
                label: const Text('AES-256-GCM'),
                selected: _activeSuiteId == AesGcmSuite.suiteId,
                onSelected: (v) => setState(() => _activeSuiteId = AesGcmSuite.suiteId),
              ),
              const SizedBox(width: Spacing.sm),
              ChoiceChip(
                label: const Text('ChaCha20-Poly1305'),
                selected: _activeSuiteId == ChaCha20Suite.suiteId,
                onSelected: (v) => setState(() => _activeSuiteId = ChaCha20Suite.suiteId),
              ),
            ],
          ),
          const SizedBox(height: Spacing.sm),
          Row(
            children: [
              AppButton(label: 'Encrypt Text', onPressed: _runEncrypt),
              const SizedBox(width: Spacing.sm),
              AppButton(
                label: 'Decrypt Envelope',
                variant: AppButtonVariant.tonal,
                onPressed: _lastEnvelope != null ? _runDecrypt : null,
              ),
            ],
          ),
          if (_lastEnvelope != null) ...[
            const SizedBox(height: Spacing.sm),
            Text('Envelope JSON:', style: context.text.labelSmall),
            Container(
              padding: const EdgeInsets.all(Spacing.xs),
              decoration: BoxDecoration(
                color: context.colors.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(Spacing.xs),
              ),
              child: SelectableText(_lastEnvelope!.serialize(), style: context.text.bodySmall),
            ),
          ],
          if (_decryptedResult.isNotEmpty) ...[
            const SizedBox(height: Spacing.xs),
            Text(
              'Decrypted: $_decryptedResult',
              style: context.text.bodyMedium?.copyWith(color: context.statusColors.success),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHmacSection() {
    return Section(
      title: '2. HMAC Anti-Replay Request Signature',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppButton(label: 'Generate Signature', onPressed: _runHmac),
          if (_lastSignature != null) ...[
            const SizedBox(height: Spacing.xs),
            Text('Timestamp: ${_lastSignature!.timestamp}', style: context.text.bodySmall),
            Text('Nonce: ${_lastSignature!.nonce}', style: context.text.bodySmall),
            Text('Body Hash: ${_lastSignature!.bodyHash}', style: context.text.bodySmall),
            Text('HMAC Signature: ${_lastSignature!.signature}', style: context.text.bodySmall),
          ],
        ],
      ),
    );
  }

  Widget _buildFileGuardSection() {
    return Section(
      title: '3. File Guard & Zip Slip Protection',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              AppButton(
                label: 'Test PNG',
                variant: AppButtonVariant.outlined,
                onPressed: _testFileGuardValid,
              ),
              const SizedBox(width: Spacing.sm),
              AppButton(
                label: 'Test Zip Slip',
                variant: AppButtonVariant.outlined,
                onPressed: _testFileGuardZipSlip,
              ),
            ],
          ),
          const SizedBox(height: Spacing.xs),
          Text(_fileGuardStatus, style: context.text.bodyMedium),
        ],
      ),
    );
  }

  Widget _buildRaspSection(SecurityVerdict verdict) {
    final verdictColor = switch (verdict) {
      SecurityVerdictAllow() => context.statusColors.success,
      SecurityVerdictWarn() => context.statusColors.warning,
      SecurityVerdictRestrict() => context.colors.error,
      SecurityVerdictBlock() || SecurityVerdictWipe() => context.colors.error,
    };

    return Section(
      title: '4. RASP Security Gate Simulator',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CheckboxListTile(
            title: const Text('Root / Jailbreak'),
            value: _isRooted,
            onChanged: (v) => setState(() => _isRooted = v ?? false),
          ),
          CheckboxListTile(
            title: const Text('Emulator / Simulator'),
            value: _isEmulator,
            onChanged: (v) => setState(() => _isEmulator = v ?? false),
          ),
          CheckboxListTile(
            title: const Text('Debugger Attached'),
            value: _isDebugger,
            onChanged: (v) => setState(() => _isDebugger = v ?? false),
          ),
          CheckboxListTile(
            title: const Text('Tampered Binary'),
            value: _isTampered,
            onChanged: (v) => setState(() => _isTampered = v ?? false),
          ),
          CheckboxListTile(
            title: const Text('Network Proxy'),
            value: _hasProxy,
            onChanged: (v) => setState(() => _hasProxy = v ?? false),
          ),
          const SizedBox(height: Spacing.sm),
          Text('Verdict: $verdict', style: context.text.titleSmall?.copyWith(color: verdictColor)),
        ],
      ),
    );
  }
}
