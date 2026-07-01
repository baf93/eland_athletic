import 'package:eland_athletic/common/eland_responsive.dart';
import 'package:flutter/material.dart';

class SettingsSectionTitle extends StatelessWidget {
  final String title;

  const SettingsSectionTitle({
    super.key,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: r.spacing(12),
        top: r.compactGap,
      ),
      child: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: r.font(14),
          fontWeight: FontWeight.w800,
          color: theme.colorScheme.primary,
          letterSpacing: 1.5,
        ),
      ),
    );
  }
}

class SettingsSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const SettingsSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: r.spacing(32),
      leading: Icon(
        icon,
        color: theme.colorScheme.primary,
        size: r.icon(24),
      ),
      title: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: r.font(15),
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: r.font(12),
          color: theme.textTheme.bodyMedium?.color,
        ),
      ),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeThumbColor: theme.colorScheme.primary,
      ),
    );
  }
}

class _CompactMenu<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const _CompactMenu({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    return MenuAnchor(
      builder: (context, controller, child) {
        return InkWell(
          borderRadius: BorderRadius.circular(r.radius(8)),
          onTap: controller.open,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: r.spacing(8),
              vertical: r.spacing(4),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  value.toString().toUpperCase(),
                  style: TextStyle(
                    fontSize: r.font(14),
                    fontWeight: FontWeight.w800,
                    color: theme.textTheme.bodyLarge?.color,
                  ),
                ),
                SizedBox(width: r.spacing(4)),
                Icon(
                  Icons.expand_more,
                  size: r.icon(18),
                  color: theme.textTheme.bodyMedium?.color,
                ),
              ],
            ),
          ),
        );
      },
      menuChildren: items.map((item) {
        return MenuItemButton(
          onPressed: () => onChanged(item),
          child: Text(item.toString().toUpperCase()),
        );
      }).toList(),
    );
  }
}

class SettingsDropdownTile<T> extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final T value;
  final List<T> items;
  final ValueChanged<T?> onChanged;

  const SettingsDropdownTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      minLeadingWidth: r.spacing(32),
      leading: Icon(
        icon,
        color: theme.colorScheme.primary,
        size: r.icon(24),
      ),
      title: Text(
        title,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: r.font(15),
        ),
      ),
      subtitle: Text(
        subtitle,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: r.font(12),
          color: theme.textTheme.bodyMedium?.color,
        ),
      ),
      trailing: _CompactMenu<T>(
        value: value,
        items: items,
        onChanged: onChanged,
      ),
    );
  }
}

class SettingsActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const SettingsActionTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(r.radius(16)),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          minLeadingWidth: r.spacing(32),
          leading: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: r.icon(24),
          ),
          title: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: r.font(15),
            ),
          ),
          subtitle: subtitle.isEmpty
              ? null
              : Text(
            subtitle,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: r.font(12),
              color: theme.textTheme.bodyMedium?.color,
            ),
          ),
          trailing: trailing ??
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: r.icon(14),
                color: theme.textTheme.bodyMedium?.color,
              ),
        ),
      ),
    );
  }
}

class SettingsInfoCard extends StatelessWidget {
  final String title;
  final Widget content;

  const SettingsInfoCard({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(r.spacing(20)),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: BorderRadius.circular(r.radius(16)),
        border: Border.all(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: r.font(14),
              color: theme.colorScheme.primary,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: r.sectionGap),
          content,
        ],
      ),
    );
  }
}

class SettingsColorSelector extends StatelessWidget {
  final IconData icon;
  final String title;
  final List<Color> colors;
  final int selectedIndex;
  final ValueChanged<int> onColorSelected;

  const SettingsColorSelector({
    super.key,
    required this.icon,
    required this.title,
    required this.colors,
    required this.selectedIndex,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final r = ElandResponsive(context);

    final colorSize = r.icon(
      40,
      minScale: 0.9,
      maxScale: 1.15,
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        ListTile(
          contentPadding: EdgeInsets.zero,
          minLeadingWidth: r.spacing(32),
          leading: Icon(
            icon,
            color: theme.colorScheme.primary,
            size: r.icon(24),
          ),
          title: Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: r.font(15),
            ),
          ),
        ),

        SizedBox(height: r.sectionGap),

        Wrap(
          spacing: r.spacing(12),
          runSpacing: r.spacing(12),
          alignment: WrapAlignment.center,
          children: List.generate(colors.length, (index) {
            final isSelected = selectedIndex == index;

            return GestureDetector(
              onTap: () => onColorSelected(index),
              child: Container(
                width: colorSize,
                height: colorSize,
                decoration: BoxDecoration(
                  color: colors[index],
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: isSelected
                        ? theme.colorScheme.onSurface
                        : Colors.transparent,
                    width: 3,
                  ),
                ),
                child: isSelected
                    ? Icon(
                  Icons.check,
                  size: r.icon(20),
                  color: theme.colorScheme.onSurface,
                )
                    : null,
              ),
            );
          }),
        ),

        SizedBox(height: r.sectionGap),
      ],
    );
  }
}