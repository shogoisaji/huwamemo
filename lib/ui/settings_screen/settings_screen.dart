import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:huwamemo/settings/text_theme.dart';
import 'package:huwamemo/utils/app_lifecycle_state_provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends HookConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appVersion = useState('');

    Widget spacer() => const SizedBox(height: 24.0);

    Future<void> inquiryURL() async {
      final Uri url = Uri.parse('https://huwamemo-lp.vercel.app/inquiry');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        return;
      }
    }

    Future<void> policyURL() async {
      final Uri url =
          Uri.parse('https://huwamemo-lp.vercel.app/privacy-policy');
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        return;
      }
    }

    Future<void> loadVersion() async {
      final packageInfo = await PackageInfo.fromPlatform();

      appVersion.value = packageInfo.version;
    }

    ref.listen<AppLifecycleState>(
      appLifecycleStateProvider,
      (previous, next) {
        if (previous == AppLifecycleState.inactive &&
            next == AppLifecycleState.resumed) {
          Navigator.pop(context);
        }
      },
    );

    useEffect(() {
      loadVersion();
      return null;
    }, const []);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            size: 32,
            color: Colors.grey.shade400,
          ),
          onPressed: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
            FocusScope.of(context).unfocus();
          },
        ),
        title: Text('情報',
            style: lightTextTheme.titleLarge!
                .copyWith(color: Colors.grey.shade400)),
      ),
      body: Stack(
        children: [
          _bg(),
          SafeArea(
            child: SingleChildScrollView(
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 500),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 16.0),
                    child: Column(
                      children: [
                        spacer(),
                        ListContentBase(
                          title: 'ライセンス',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const LicensePage(
                                          applicationName: 'ふわメモ',
                                        )));
                          },
                        ),
                        spacer(),
                        ListContentBase(
                          title: 'プライバシーポリシー',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            policyURL();
                          },
                          isWeb: true,
                        ),
                        spacer(),
                        ListContentBase(
                          title: '問い合わせ',
                          onTap: () {
                            HapticFeedback.lightImpact();
                            inquiryURL();
                          },
                          isWeb: true,
                        ),
                        spacer(),
                        ListContentBase(
                          title: 'バージョン',
                          onTap: () {},
                          tailContent: Padding(
                            padding: const EdgeInsets.only(right: 10.0),
                            child: Text(appVersion.value,
                                style: lightTextTheme.titleMedium),
                          ),
                        ),
                        spacer(),
                        const SizedBox(height: 100.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bg() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
            begin: Alignment(0.9, -1.0),
            end: Alignment(-0.5, 1.0),
            colors: [
              Color.fromARGB(255, 38, 96, 212),
              Color.fromARGB(255, 62, 62, 222),
              Color.fromARGB(255, 98, 48, 236),
            ]),
      ),
    );
  }
}

class ListContentBase extends StatelessWidget {
  const ListContentBase({
    super.key,
    required this.title,
    required this.onTap,
    this.isWeb = false,
    this.tailContent,
  });

  final String title;
  final Function() onTap;
  final bool isWeb;
  final Widget? tailContent;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 14.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Colors.blue.shade200,
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: lightTextTheme.titleMedium),
            tailContent ??
                SizedBox(
                  child: isWeb
                      ? const Padding(
                          padding: EdgeInsets.only(right: 6.0),
                          child: Icon(Icons.open_in_new, size: 28),
                        )
                      : const Icon(Icons.chevron_right_rounded, size: 36),
                ),
          ],
        ),
      ),
    );
  }
}
