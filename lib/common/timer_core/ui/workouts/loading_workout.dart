import 'package:eland_athletic/common/eland_responsive.dart';
import 'package:eland_athletic/common/strings.dart';
import 'package:flutter/material.dart';

class WorkoutLoadingPage extends StatelessWidget {
  const WorkoutLoadingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: r.pageHorizontalPadding,
              ),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: r.icon(
                        100,
                        minScale: 0.72,
                        maxScale: 1.2,
                      ),
                      color: theme.colorScheme.primary,
                    ),

                    SizedBox(height: r.spacing(25)),

                    Text(
                      ElandStrings.of('loading_workout').toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: theme.textTheme.headlineLarge!.color,
                        fontSize: r.font(
                          20,
                          minScale: 0.9,
                          maxScale: 1.2,
                        ),
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2,
                      ),
                    ),

                    SizedBox(height: r.spacing(60)),

                    CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}